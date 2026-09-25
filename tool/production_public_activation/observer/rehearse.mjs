// No remote connection factory. The actual handoff runs against the current real
// archive using the original sealed executor, original SQL and original ledger.
import {writeFileSync,createWriteStream,readFileSync,unlinkSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {spawn} from 'node:child_process';
import {createServer} from 'node:http';
import {randomBytes} from 'node:crypto';
import {support,newestArchive} from './local-support.mjs';
import {check} from './classifier.mjs';
import {observe,compare} from './observe.mjs';
import {flow} from './handoff.mjs';
import {sealedBytes,observerIdentity,activationSeal} from './identity.mjs';
import {root,hash,stable,manifest,safeError as sealedError} from '../live/common.mjs';
import {activate,rollback,readState,captureFreshBackup} from '../live/engine.mjs';
import {httpContract} from '../local-http.mjs';
import {catalog,catalogHashes} from '../../production_taxonomy/execution/catalog.mjs';
import {unchanged0012Catalog,snapshot,securityMetadata} from '../../production_preview_bridge/execution/catalog.mjs';
import {contract as bridgeContract} from '../../production_preview_bridge/execution/validators.mjs';
import {activationView} from '../../production_public_client/executor.mjs';
import {contract as originalContract} from '../../production_taxonomy/execution/validators.mjs';
import {restoreOwnerAclRepresentation} from './restore-owner-acl.mjs';
const safeError=e=>e?.message?.match(/W52LF_[A-Z0-9_]+/)?.[0]??sealedError(e);
const s=await support();
const options={production_authorized:true,seal_sha256:activationSeal,sql_sha256:manifest().activation_sql_sha256,apk:process.env.W52LE_APK,aab:process.env.W52LE_AAB};
const result={format:'w52lf-real-copy-off-on-off-v1',result:'FAIL',source_backup_sha256:newestArchive,production_accessed:false,production_write_performed:false,development_accessed:false,apk_rebuilt:false,aab_rebuilt:false,started_at_utc:new Date().toISOString()};
let db,http,server,fixturePath,rolledBack=false;
const bytesBefore=sealedBytes();
// Hash all 79 archive table-data sections in the database, without retrieving rows.
function archiveFingerprint(){
 s.guard();const toc=s.run(['exec',s.container,'pg_restore','--list','/backup/production.dump']);
 const tables=toc.split(/\r?\n/).filter(l=>/^\d+;/.test(l)&&/ TABLE DATA /.test(l)).map(l=>{
  const match=l.match(/ TABLE DATA ([a-zA-Z0-9_]+) ([a-zA-Z0-9_]+) /);check(match,'ARCHIVE_TABLE_IDENTIFIER');return {schema:match[1],name:match[2]};
 });
 check(tables.length===79,'ARCHIVE_79_TABLE_DATA_SECTIONS');
 const queries=tables.map(t=>`SELECT jsonb_build_object('table','${t.schema}.${t.name}','rows',count(*),'md5',md5(coalesce(string_agg(md5(to_jsonb(t)::text),'' ORDER BY md5(to_jsonb(t)::text) COLLATE "C"),''))) FROM "${t.schema}"."${t.name}" t`);
 const rows=s.sql('postgres','BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY; '+queries.join(';')+'; COMMIT;').trim().split(/\r?\n/).map(JSON.parse).sort((a,b)=>a.table.localeCompare(b.table));
 const sequences=JSON.parse(s.sql('postgres',"SELECT coalesce(jsonb_agg(to_jsonb(s) ORDER BY schemaname,sequencename),'[]') FROM pg_sequences s WHERE schemaname NOT LIKE 'pg_%';"));
 return {tables:79,table_hashes:rows,sha256:hash(stable(rows)),sequence_sha256:hash(stable(sequences))};
}
async function differential(label){
 const row=(await db.query(`SELECT (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1) AS public_enabled,
 count(*) FILTER(WHERE public._w52kb_assignable(canonical_category_id))::int AS preview_staged_eligible,
 count(*) FILTER(WHERE public.production_taxonomy_assignment_visible_v1(canonical_category_id))::int AS public_visible
 FROM public.product_canonical_assignments`)).rows[0];
 const active=label==='ON_PUBLISHED';
 check(row.public_enabled===active&&row.preview_staged_eligible===(active?0:14)&&row.public_visible===(active?14:0),'EXACT_OLD_FALSE_FAILURE_REGRESSION');
 return {phase:label,...row,old_observer:row.preview_staged_eligible===14?'PASS':'FAIL',corrected_observer:'PASS'};
}
try{
 await s.create();result.restore=await s.restore({reconcileSecurity:true});
 result.restore.owner_acl_representation=restoreOwnerAclRepresentation(s);db=s.session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const actualCatalog=await unchanged0012Catalog(activationView(db));
 result.restore.catalog_differences=Object.keys(actualCatalog).filter(k=>actualCatalog[k]!==originalContract().catalog_after[k]);
 if(result.restore.catalog_differences.length){
  writeFileSync(resolve(s.path,'catalog.private.json'),JSON.stringify(await catalog(db)));
  throw Error('W52LF_RESTORE_CATALOG_DIFF_'+result.restore.catalog_differences.join('_').toUpperCase());
 }
 const restoredSnapshot=await snapshot(activationView(db)),expectedSnapshot=bridgeContract().after;
 result.restore.security_differences=Object.keys(restoredSnapshot.security).filter(k=>restoredSnapshot.security[k]!==expectedSnapshot.security[k]);
 if(result.restore.security_differences.length){
  writeFileSync(resolve(s.path,'security.private.json'),JSON.stringify(await securityMetadata(db)));
  throw Error('W52LF_RESTORE_SECURITY_DIFF_'+result.restore.security_differences.join('_').toUpperCase());
 }
 const binary=s.run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);s.run(['cp','-',s.container+':/tmp'],binary);
 http=new s.HttpChecks(db);await http.start();const api=httpContract(s,http);
 // Actual anonymous GETs. Single-row Accept semantics use the existing reader.
 const request=async(path,params,single=false)=>single?{status:200,data:http.request('anon',path,params,true)}:api.request('anon',path,params);
 const original=archiveFingerprint();
 result.restore.archive_table_sections=original.tables;
 const entries=(await db.query("SELECT version FROM supabase_migrations.schema_migrations WHERE version IN ('20260916001200','20260919001300','20260922001400','20260922001500') ORDER BY version")).rows.map(r=>r.version);
 check(stable(entries)===stable(['20260916001200','20260919001300','20260922001500']),'CURRENT_OFF_LEDGER_BASELINE');result.baseline_migrations=entries;
 let backupProof;
 const dump=async()=>{const metadata=s.freshBackup(),bytes=s.run(['exec',s.container,'cat','/tmp/w52jb-prewrite.dump'],undefined,true),toc=s.run(['exec',s.container,'pg_restore','--list','/tmp/w52jb-prewrite.dump']);check(/Format: CUSTOM/.test(toc)&&(toc.match(/ TABLE DATA /g)||[]).length===79,'FRESH_CURRENT_BACKUP');backupProof=metadata;return {metadata,bytes,tocVerified:true};};
 const observations={},regression=[];
 const handoff=await flow({
  gates:()=>{s.guard();check(stable(sealedBytes())===stable(bytesBefore),'SEALED_BYTES_CHANGED');return {result:'PASS',runtime_inputs:58};},
  observe:async mode=>{const value=await observe(db,options,mode,request);observations[mode]=value;regression.push(await differential(mode==='postflight'?'ON_PUBLISHED':'OFF_STAGED'));console.log('CORRECTED_OBSERVER_'+mode.toUpperCase()+': PASS');return value;},
  cli:async op=>{
   if(op==='activate'){const backup=await captureFreshBackup(db,options,dump);const value=await activate(db,{...options},backup);return {...value,production_write_attempted:true,public_activation_performed:true};}
   if(op==='rollback')return rollback(db,{...options});
   if(op==='postflight')return readState(db,options,true);
   throw Error('W52LF_UNEXPECTED_SEALED_OPERATION');
  },backupReceipt:()=>backupProof,compare,save:()=>{},safeError,progress:line=>console.log('ISOLATED_'+line),
 });
 result.handoff={result:handoff.result,activation_invoked:handoff.activation_invoked,rollback_triggered:handoff.rollback_triggered,public_enabled_final:handoff.public_enabled_final,safe_error:handoff.safe_error};
 check(handoff.result==='PASS'&&!handoff.rollback_triggered&&handoff.public_enabled_final===true,'ACTUAL_CORRECTED_HANDOFF');
 result.off=observations.preflight;result.on=observations.postflight;
 result.legacy_authenticated_on=await http.legacy();
 console.log('ACTUAL_HANDOFF_ON_WITHOUT_FALSE_ROLLBACK: PASS');
 const eligible=(await db.query('SELECT product_id::text AS id FROM public.product_canonical_assignments WHERE public.production_taxonomy_assignment_visible_v1(canonical_category_id) ORDER BY product_id')).rows.map(r=>r.id);
 const gated=(await db.query('SELECT product_id::text AS id FROM public.product_canonical_assignments WHERE NOT public.production_taxonomy_assignment_visible_v1(canonical_category_id) ORDER BY product_id')).rows.map(r=>r.id);
 check(eligible.length===14&&gated.length===6,'PRODUCT_ORACLE');
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE enabled AND expires_at>clock_timestamp()')).rows[0].n===0,'NO_ACTIVE_TESTER_ALLOWLIST');
 const path=(await db.query(`WITH RECURSIVE tree AS (SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT c.id FROM public.canonical_categories c WHERE c.level=4 AND c.is_active AND c.is_assignable ORDER BY c.id LIMIT 1) UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN tree t ON c.id=t.parent_id) SELECT id::text,level FROM tree ORDER BY level`)).rows.map(r=>r.id);
 check(path.length===4,'FOUR_LEVEL_PATH');
 const control=randomBytes(24).toString('hex'),calls={anon:{},authenticated:{}};
 server=createServer(async(req,res)=>{
  try{
   check(req.headers['x-w52lb-control']===control,'LOCAL_RELAY_AUTH');
   if(req.url==='/control/rollback'&&req.method==='POST'){
    check(!rolledBack,'ROLLBACK_ONCE');result.rollback=await rollback(db,{...options});rolledBack=true;res.writeHead(200,{'Content-Type':'application/json'});res.end('{}');return;
   }
   const role=req.headers['x-w52lb-role'];check(['anon','authenticated'].includes(role),'LOCAL_RELAY_ROLE');
   const match=req.url?.match(/^\/rest\/v1\/rpc\/([a-z0-9_]+)$/);check(match&&/^(production_taxonomy_(runtime|capabilities|roots|children|descendants|exact_leaf|breadcrumb|resolve_alias|search_context)_v1|production_public_(read_capabilities|products|listings|shops)_v1)$/.test(match[1]),'LOCAL_RELAY_RPC_ONLY');
   check(req.method==='POST','LOCAL_RELAY_METHOD');let body='';for await(const chunk of req){body+=chunk;check(body.length<20000,'LOCAL_RELAY_SIZE');}
   const r=api.request(role,'/rpc/'+match[1],{},'POST',JSON.parse(body));calls[role][match[1]]=(calls[role][match[1]]??0)+1;
   res.writeHead(r.status,{'Content-Type':'application/json'});res.end(JSON.stringify(r.data));
  }catch{res.writeHead(500,{'Content-Type':'application/json'});res.end(JSON.stringify({code:'W52LB_LOCAL_RELAY',message:'Isolated request failed safely'}));}
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 fixturePath=resolve(s.path,'flutter-fixture.private.json');writeFileSync(fixturePath,JSON.stringify({endpoint:`http://127.0.0.1:${server.address().port}`,control,isolated:true,eligible,gated,path}));
 const flutter=process.env.W52LF_FLUTTER;check(flutter?.endsWith('flutter.bat'),'FLUTTER_EXECUTABLE');
 const logPath=resolve(s.path,'flutter-private.jsonl'),output=createWriteStream(logPath);
 const code=await new Promise((done,reject)=>{
  const child=spawn(resolve(dirname(flutter),'cache/dart-sdk/bin/dart.exe'),[resolve(dirname(flutter),'cache/flutter_tools.snapshot'),'test','--no-pub','--dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC=true','--dart-define=ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=false','tool/production_public_client/flutter_integration_test.dart','--reporter','json'],{cwd:root,env:{...process.env,W52LB_FLUTTER_FIXTURE:fixturePath},windowsHide:true});
  child.stdout.pipe(output,{end:false});child.stderr.pipe(output,{end:false});child.on('error',reject);child.on('close',n=>output.end(()=>done(n)));
 });
 const events=readFileSync(logPath,'utf8').split(/\r?\n/).flatMap(line=>{try{return [JSON.parse(line)];}catch{return [];}});
 const tests=events.filter(e=>e.type==='testDone'&&!e.hidden);
 result.flutter={exit_code:code,passed:tests.filter(t=>t.result==='success'&&!t.skipped).length,failed:tests.filter(t=>t.result==='error'||t.result==='failure').length,skipped:tests.filter(t=>t.skipped).length,rpc_calls:calls,real_flutter_executed:true};
 console.log('REAL_FLUTTER_COMPLETED: '+(code===0?'PASS':'FAIL'));
 check(code===0&&result.flutter.passed===3&&result.flutter.failed===0&&result.flutter.skipped===0,'REAL_FLUTTER_INTEGRATION');check(rolledBack,'FLUTTER_ROLLBACK_REQUIRED');

 result.restored=await observe(db,options,'baseline',request);compare(result.off,result.restored,false);
 regression.push(await differential('OFF_RESTORED'));result.regression=regression;
 const final=archiveFingerprint();check(stable(original)===stable(final),'ALL_ARCHIVE_TABLES_AND_SEQUENCES_RESTORED');
 result.final_archive_fingerprint={result:'PASS',tables:79,before_sha256:original.sha256,after_sha256:final.sha256,sequence_sha256:final.sequence_sha256};
 result.rollback_restores_off='PASS';result.public_writes_denied_on=result.on.writes_denied;
 result.sealed_bytes_before=bytesBefore;result.sealed_bytes_after=sealedBytes();
 check(stable(result.sealed_bytes_before)===stable(result.sealed_bytes_after),'SEALED_BYTES_CHANGED');
 result.observer_identity=observerIdentity();result.result='PASS';
}catch(e){result.safe_error=safeError(e);if(db?.stderr)writeFileSync(resolve(s.path,'sql-error.private.txt'),db.stderr);process.exitCode=1;}
finally{
 if(server)await new Promise(r=>server.close(r));if(fixturePath)try{unlinkSync(fixturePath);}catch{}
 if(http)try{http.stop();}catch{}if(db)try{await db.close();}catch{}try{s.stop();}catch{}
 if(result.restore?.isolation)delete result.restore.isolation.container_id;
 result.completed_at_utc=new Date().toISOString();writeFileSync(resolve(s.path,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,production_accessed:false}));
}
