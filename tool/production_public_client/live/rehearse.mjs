import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {support,originalArchive} from './local-support.mjs';
import {check,read,hash,literal,stable,safeError,directory,sourceHash,functions} from './common.mjs';
import {apply0012,readPostflight} from '../../production_taxonomy/execution/engine.mjs';
import {baseline as bridgeBaseline} from '../../production_preview_bridge/execution/validators.mjs';
import {payload as bridgePayload,version as bridgeVersion,name as bridgeName} from '../../production_preview_bridge/execution/common.mjs';
import {transaction} from '../../production_preview_bridge/live_v2/transaction.mjs';
import {httpContract} from '../../production_public_activation/local-http.mjs';
import {fullFingerprint} from './validators.mjs';
import {readState,captureFreshBackup,install,rollback} from './engine.mjs';
import {verify} from './seal.mjs';
import {failures} from './failure-tests.mjs';
const s=await support(),holder={db:null},seal=hash(read(directory+'/seal.json'));
const options={production_authorized:true,seal_sha256:seal,sql_sha256:sourceHash};
const result={format:'w52lc-real-copy-rehearsal-v1',result:'FAIL',started_at_utc:new Date().toISOString(),source_backup_sha256:originalArchive,package_sha256:seal,production_accessed:false,production_write_performed:false,development_accessed:false,activation_0014_applied:false};
let http;
try{
 result.seal_before=verify(seal);await s.create();result.restore=await s.restore({reconcileSecurity:true});holder.db=s.session();
 await holder.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await s.baseline(holder.db);await apply0012(holder.db,s.freshBackup());await readPostflight(holder.db);
 await transaction(holder.db,async()=>{await bridgeBaseline(holder.db,false);const b=bridgePayload();await holder.db.exec(b.sql);await holder.db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(bridgeVersion)},${literal(bridgeName)},${literal([b.sql])}::text[]);`);return bridgeBaseline(holder.db,true);},{write:true,coreLocks:true});
 result.before_fingerprint=await fullFingerprint(holder.db);
 const binary=s.run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);s.run(['cp','-',s.container+':/tmp'],binary);
 http=new s.HttpChecks(holder.db);await http.start();const api=httpContract(s,http);result.legacy_before=await http.legacy();
 result.preflight=await readState(holder.db,seal);
 const backup=await captureFreshBackup(holder.db,seal,async()=>{
  const metadata=s.freshBackup(),bytes=s.run(['exec',s.container,'cat','/tmp/w52jb-prewrite.dump'],undefined,true);
  const toc=s.run(['exec',s.container,'pg_restore','--list','/tmp/w52jb-prewrite.dump']);
  check(/Format: CUSTOM/.test(toc)&&/TABLE DATA public products/.test(toc)&&/FUNCTION public production_taxonomy_runtime_v1/.test(toc),'LOCAL_BACKUP_TOC');
  return {metadata,bytes,tocVerified:true};
 });
 console.log('FRESH_BACKUP_AND_STRICT_PREFLIGHT: PASS');
 const suite=failures(s,holder,options);await suite.before(backup);http.db=holder.db;
 console.log('PREDEPLOY_FAILURE_INJECTION: PASS');
 result.install=await install(holder.db,{...options},backup);result.postflight=await readState(holder.db,seal,true);
 await holder.db.exec("NOTIFY pgrst,'reload schema';");await new Promise(r=>setTimeout(r,1000));
 result.http_off={};for(const role of ['anon','authenticated']){
  result.http_off[role]={};for(const name of functions){const r=api.request(role,'/rpc/'+name,{},'POST',{p_client_contract_version:'production-taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'});check([401,403].includes(r.status)&&r.data.code==='42501','HTTP_OFF_DENIAL');result.http_off[role][name]={status:r.status,code:r.data.code};}
 }
 result.legacy_installed=await http.legacy();check(stable(result.legacy_before)===stable(result.legacy_installed),'LEGACY_CHANGED_AFTER_0015');
 console.log('0015_ATOMIC_INSTALL_OFF_DENIAL_LEGACY_SECURITY: PASS');
 await suite.installed(backup);http.db=holder.db;await readState(holder.db,seal,true);
 result.rollback=await rollback(holder.db,{...options});result.final_state=await readState(holder.db,seal);await suite.after();
 result.failure_injection=suite.results;result.failure_injection_count=suite.results.length;
 result.legacy_rollback=await http.legacy();check(stable(result.legacy_before)===stable(result.legacy_rollback),'LEGACY_CHANGED_AFTER_ROLLBACK');
 result.after_fingerprint=await fullFingerprint(holder.db);check(result.before_fingerprint===result.after_fingerprint,'EXACT_FINAL_STATE');
 result.original_archive_sections=(await s.archiveRows(holder.db,{preserve0012:true})).length;check(result.original_archive_sections===69,'ALL_ORIGINAL_ARCHIVE_SECTIONS');
 result.seal_after=verify(seal);result.result='PASS';console.log('0015_ONLY_ROLLBACK_AND_EXACT_FINAL_STATE: PASS');
}catch(e){result.safe_error=safeError(e);if(holder.db?.stderr)writeFileSync(resolve(s.path,'sql-error.private.txt'),holder.db.stderr);process.exitCode=1;}
finally{
 if(http)try{http.stop();}catch{}if(holder.db)try{await holder.db.close();}catch{}try{s.stop();}catch{}
 if(result.restore?.isolation){result.container_identity_sha256=hash(result.restore.isolation.container_id);delete result.restore.isolation.container_id;}
 result.completed_at_utc=new Date().toISOString();writeFileSync(resolve(s.path,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,failures:result.failure_injection_count,production_accessed:false}));
}
