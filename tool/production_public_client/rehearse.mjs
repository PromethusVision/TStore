// Actual Flutter -> Supabase Dart client -> loopback-only relay -> real
// PostgREST -> network-disabled PG17.6 restored from the frozen real archive.
import {writeFileSync,createWriteStream,readFileSync,unlinkSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {spawn} from 'node:child_process';
import {createServer} from 'node:http';
import {randomBytes} from 'node:crypto';
import {support,originalArchive} from './local-support.mjs';
import {check,root,hash,stable,literal,safeError,json,directory,functions} from './common.mjs';
import {apply0012,readPostflight} from '../production_taxonomy/execution/engine.mjs';
import {baseline as bridgeBaseline} from '../production_preview_bridge/execution/validators.mjs';
import {payload as bridgePayload,version as bridgeVersion,name as bridgeName} from '../production_preview_bridge/execution/common.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';
import {snapshot,canonicalData} from '../production_preview_bridge/execution/catalog.mjs';
import {httpContract} from '../production_public_activation/local-http.mjs';
import {verify} from './seal.mjs';
import {install,publication,uninstall,preflight,activationView,verifyFacade} from './executor.mjs';
import {preflight as activationPreflight} from '../production_public_activation/validators.mjs';
const s=await support(),seal=json(directory+'/seal.json').sha256;
const result={format:'w52lb-real-flutter-production-copy-v1',result:'FAIL',source_backup_sha256:originalArchive,package_sha256:seal,production_accessed:false,production_write_performed:false,development_accessed:false,started_at_utc:new Date().toISOString()};
let db,http,server,rolledBack=false,fixturePath;
try{
 check(s.container==='w52kb-lbproof','PROOF_CONTAINER');verify(seal);await s.create();result.restore=await s.restore({reconcileSecurity:true});db=s.session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await s.baseline(db);await apply0012(db,s.freshBackup());await readPostflight(db);
 await transaction(db,async()=>{await bridgeBaseline(db,false);const b=bridgePayload();await db.exec(b.sql);await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(bridgeVersion)},${literal(bridgeName)},${literal([b.sql])}::text[]);`);return bridgeBaseline(db,true);},{write:true,coreLocks:true});
 const beforeSchema=await snapshot(db),beforeData=await canonicalData(db);
 const binary=s.run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);s.run(['cp','-',s.container+':/tmp'],binary);
 http=new s.HttpChecks(db);await http.start();const api=httpContract(s,http);result.legacy_before=await http.legacy();
 result.facade_install=await install(db,seal);console.log('ADDITIVE_FACADE_OFF_INSTALL: PASS');
 result.drift_rejections={};
 for(const [label,mutation]of Object.entries({
  facade_grants:'GRANT EXECUTE ON FUNCTION public.production_public_read_capabilities_v1(text,text) TO PUBLIC;',
  facade_ledger:"UPDATE supabase_migrations.schema_migrations SET name='tampered' WHERE version='20260922001500';",
  unrelated_function:'CREATE FUNCTION public.w52lb_unexpected_function() RETURNS integer LANGUAGE sql AS $$ SELECT 1 $$;',
  canonical_write:'GRANT UPDATE ON public.canonical_categories TO anon;'
 })){
  await db.exec('BEGIN;');let rejected;
  try{await db.exec(mutation);await activationPreflight(activationView(db));}catch(e){rejected=safeError(e);}finally{await db.exec('ROLLBACK;');}
  check(rejected&&rejected!=='W52LB_PRIVATE_ERROR_SUPPRESSED','DRIFT_MUST_FAIL');result.drift_rejections[label]={result:'PASS',safe_error:rejected};
 }
 await verifyFacade(db);console.log('FACADE_AND_ACTIVATION_DRIFT_REJECTIONS: PASS');
 await db.exec("NOTIFY pgrst,'reload schema';");await new Promise(r=>setTimeout(r,1200));
 const args={p_client_contract_version:'production-taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'};
 function offChecks(){const result={};for(const role of ['anon','authenticated']){result[role]={};for(const fn of functions){const response=api.request(role,'/rpc/'+fn,{},'POST',args);check([401,403].includes(response.status)&&response.data.code==='42501','OFF_FACADE_DENIAL');result[role][fn]=response.status;}}return result;}
 result.public_off_before=offChecks();result.activation=await publication(db,seal,true);console.log('LOCAL_PUBLIC_ACTIVATION_WITH_FACADE: PASS');
 result.legacy_active=await http.legacy();check(stable(result.legacy_before)===stable(result.legacy_active),'LEGACY_AFTER_ACTIVATION');
 const eligible=(await db.query('SELECT product_id::text AS id FROM public.product_canonical_assignments WHERE public.production_taxonomy_assignment_visible_v1(canonical_category_id) ORDER BY product_id')).rows.map(r=>r.id);
 const gated=(await db.query('SELECT product_id::text AS id FROM public.product_canonical_assignments WHERE NOT public.production_taxonomy_assignment_visible_v1(canonical_category_id) ORDER BY product_id')).rows.map(r=>r.id);
 check(eligible.length===14&&gated.length===6,'PRODUCT_ORACLE');
 check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers')).rows[0].n===0,'NO_TESTER_ALLOWLIST');
 const path=(await db.query(`WITH RECURSIVE tree AS (SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT c.id FROM public.canonical_categories c WHERE c.level=4 AND c.is_active AND c.is_assignable ORDER BY c.id LIMIT 1) UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN tree t ON c.id=t.parent_id) SELECT id::text,level FROM tree ORDER BY level`)).rows.map(r=>r.id);
 check(path.length===4,'FOUR_LEVEL_PATH');
 const control=randomBytes(24).toString('hex'),calls={anon:{},authenticated:{}};
 server=createServer(async(req,res)=>{
  try{
   check(req.headers['x-w52lb-control']===control,'LOCAL_RELAY_AUTH');
   if(req.url==='/control/rollback'&&req.method==='POST'){
    check(!rolledBack,'ROLLBACK_ONCE');result.rollback=await publication(db,seal,false);rolledBack=true;res.writeHead(200,{'Content-Type':'application/json'});res.end('{}');return;
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
 const flutter=process.env.W52LB_FLUTTER;check(flutter?.endsWith('flutter.bat'),'FLUTTER_EXECUTABLE');
 const logPath=resolve(s.path,'flutter-private.jsonl'),output=createWriteStream(logPath);
 const code=await new Promise((done,reject)=>{
  const child=spawn(resolve(dirname(flutter),'cache/dart-sdk/bin/dart.exe'),[resolve(dirname(flutter),'cache/flutter_tools.snapshot'),'test','--no-pub','tool/production_public_client/flutter_integration_test.dart','--reporter','json'],{cwd:root,env:{...process.env,W52LB_FLUTTER_FIXTURE:fixturePath},windowsHide:true});
  child.stdout.pipe(output,{end:false});child.stderr.pipe(output,{end:false});child.on('error',reject);child.on('close',n=>output.end(()=>done(n)));
 });
 const events=readFileSync(logPath,'utf8').split(/\r?\n/).flatMap(line=>{try{return [JSON.parse(line)];}catch{return [];}});
 const tests=events.filter(e=>e.type==='testDone'&&!e.hidden);
 result.flutter={exit_code:code,passed:tests.filter(t=>t.result==='success'&&!t.skipped).length,failed:tests.filter(t=>t.result==='error'||t.result==='failure').length,skipped:tests.filter(t=>t.skipped).length,rpc_calls:calls,real_flutter_executed:true};
 console.log('REAL_FLUTTER_COMPLETED: '+(code===0?'PASS':'FAIL'));
 check(code===0&&result.flutter.passed===3&&result.flutter.failed===0&&result.flutter.skipped===0,'REAL_FLUTTER_INTEGRATION');check(rolledBack,'FLUTTER_ROLLBACK_REQUIRED');
 result.public_off_after=offChecks();result.legacy_rollback=await http.legacy();check(stable(result.legacy_before)===stable(result.legacy_rollback),'LEGACY_AFTER_ROLLBACK');
 result.facade_uninstall=await uninstall(db,seal);await preflight(db,seal);
 check(stable(await snapshot(db))===stable(beforeSchema),'EXACT_SCHEMA_ROLLBACK');check(stable(await canonicalData(db))===stable(beforeData),'EXACT_DATA_ROLLBACK');
 result.original_archive_sections=(await s.archiveRows(db,{preserve0012:true})).length;check(result.original_archive_sections===69,'ALL_ARCHIVE_ROWS');
 result.eligible_products=14;result.gated_products_excluded=6;result.no_tester_allowlist=true;result.full_rollback='PASS';result.seal_after=verify(seal);result.result='PASS';
}catch(e){result.safe_error=safeError(e);if(db?.stderr)writeFileSync(resolve(s.path,'sql-error.private.txt'),db.stderr);process.exitCode=1;}
finally{
 if(server)await new Promise(r=>server.close(r));if(fixturePath)try{unlinkSync(fixturePath);}catch{}
 if(http)try{http.stop();}catch{}if(db)try{await db.close();}catch{}try{s.stop();}catch{}
 if(result.restore?.isolation)delete result.restore.isolation.container_id;
 result.completed_at_utc=new Date().toISOString();writeFileSync(resolve(s.path,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,production_accessed:false}));
}
