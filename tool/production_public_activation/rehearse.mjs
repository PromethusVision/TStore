// Fresh real Production-copy rehearsal. Only the generated isolated Docker
// transport can execute. No private Production config or session is loaded.
import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {randomUUID} from 'node:crypto';
import {support,originalArchive} from './local-support.mjs';
import {check,hash,stable,literal,project,safeError,version} from './common.mjs';
import {apply0012,readPostflight as read0012} from '../production_taxonomy/execution/engine.mjs';
import {baseline as bridgeBaseline} from '../production_preview_bridge/execution/validators.mjs';
import {payload as bridgePayload,version as bridgeVersion,name as bridgeName} from '../production_preview_bridge/execution/common.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';
import {canonicalData,snapshot} from '../production_preview_bridge/execution/catalog.mjs';
import {preservedData} from './policy.mjs';
import {verify} from './seal.mjs';
import {activate,rollback,readPreflight,readPostflight} from './executor.mjs';
import {failureTests} from './failure-tests.mjs';
import {httpContract} from './local-http.mjs';
const seal=process.env.W52LA_SEAL_SHA256,s=await support();
check(['w52kb-laone','w52kb-latwo'].includes(s.container),'TWO_FRESH_REHEARSAL_CONTAINERS');
const holder={db:null};let http;
const result={format:'w52la-real-production-copy-rehearsal-v1',result:'FAIL',started_at_utc:new Date().toISOString(),source_backup_sha256:originalArchive,package_sha256:seal,production_accessed:false,production_write_performed:false,development_accessed:false,flutter_client_executed:false};
try{
 result.seal_before=verify(seal);s.run(['image','inspect',s.imageDigest]);await s.create();result.restore=await s.restore({reconcileSecurity:true});holder.db=s.session();
 await holder.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await s.baseline(holder.db);result.original_archive_table_sections=69;
 await apply0012(holder.db,s.freshBackup());await read0012(holder.db);
 await transaction(holder.db,async()=>{
  await bridgeBaseline(holder.db,false);const b=bridgePayload();await holder.db.exec(b.sql);
  await holder.db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(bridgeVersion)},${literal(bridgeName)},${literal([b.sql])}::text[]);`);
  await bridgeBaseline(holder.db,true);return {result:'PASS'};
 },{write:true,coreLocks:true});
 // An expired LOCAL-only lease proves activation does not erase the bridge's
 // data and never needs a tester. No real user's UID is read or recorded.
 const fixture=randomUUID();
 await holder.db.exec(`INSERT INTO auth.users(id,aud,role,email,raw_app_meta_data,raw_user_meta_data) VALUES(${literal(fixture)}::uuid,'authenticated','authenticated','w52la-isolated-fixture@local.invalid','{}','{}'); INSERT INTO production_preview_private.testers(user_id,enabled,granted_at,expires_at) VALUES(${literal(fixture)}::uuid,true,now()-interval '2 hours',now()-interval '1 hour');`);
 const beforeData=await canonicalData(holder.db),beforePreserved=await preservedData(holder.db),beforeSchema=await snapshot(holder.db);
 const binary=s.run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);s.run(['cp','-',s.container+':/tmp'],binary);
 http=new s.HttpChecks(holder.db);await http.start();const api=httpContract(s,http);
 result.legacy_before=await http.legacy();result.http_before=await api.canonical(holder.db,false);
 result.preflight=await readPreflight(holder.db,seal);console.log('PUBLIC_ACTIVATION_PREFLIGHT: PASS');
 if(s.container==='w52kb-laone'){
  result.failure_injection=await failureTests(s,holder,seal);http.db=holder.db;
  console.log('PUBLIC_ACTIVATION_FAILURE_GATES: PASS');
 }
 result.activation=await activate(holder.db,seal);result.independent_postflight=await readPostflight(holder.db,seal);
 result.http_active=await api.canonical(holder.db,true);result.legacy_active=await http.legacy();
 check(stable(result.legacy_before)===stable(result.legacy_active),'LEGACY_HTTP_AFTER_ACTIVATION');
 check(stable(await preservedData(holder.db))===stable(beforePreserved),'ACTIVE_UNREVIEWED_FIELDS');
 check(stable(await snapshot(holder.db))===stable(beforeSchema),'ACTIVE_SCHEMA_SECURITY');
 result.active_alias_count=(await holder.db.query('SELECT count(*)::int AS n FROM public.taxonomy_aliases WHERE is_active')).rows[0].n;
 let reapplied;try{await activate(holder.db,seal);}catch(e){reapplied=e;}
 check(reapplied?.message==='W52LA_REAPPLY_PROTECTION','REAPPLY_MUST_STOP');
 result.reapply={result:'PASS',safe_stop:safeError(reapplied)};
 console.log('PUBLIC_24_ROOTS_14_PRODUCTS_LEGACY_HTTP: PASS');
 result.rollback=await rollback(holder.db,seal);result.final_preflight=await readPreflight(holder.db,seal);
 result.http_rollback=await api.canonical(holder.db,false);result.legacy_rollback=await http.legacy();
 check(stable(result.legacy_before)===stable(result.legacy_rollback),'LEGACY_HTTP_AFTER_ROLLBACK');
 check(stable(await canonicalData(holder.db))===stable(beforeData),'FULL_CANONICAL_ROWS_NOT_RESTORED');
 check(stable(await preservedData(holder.db))===stable(beforePreserved),'EXPIRED_PRIVATE_LEASE_CHANGED');
 check(stable(await snapshot(holder.db))===stable(beforeSchema),'ROLLBACK_SCHEMA_SECURITY');
 let twice;try{await rollback(holder.db,seal);}catch(e){twice=e;}
 check(twice?.message==='W52LA_EXACT_ACTIVATION_LEDGER','ROLLBACK_TWICE');result.rollback_twice={result:'PASS',safe_stop:safeError(twice)};
 result.full_rows_including_timestamps_restored='PASS';result.private_allowlist_preserved='PASS';
 // Remove only the synthetic local fixture after its preservation is proved.
 await holder.db.exec(`DELETE FROM production_preview_private.testers WHERE user_id=${literal(fixture)}::uuid; DELETE FROM auth.users WHERE id=${literal(fixture)}::uuid;`);
 const archive=await s.archiveRows(holder.db,{preserve0012:true});check(archive.length===69,'ALL_ORIGINAL_DATA_SECTIONS');
 result.archive_rows_after='PASS_ALL_69';result.manual_sql_repairs=false;result.seal_after=verify(seal);result.result='PASS';console.log('PUBLIC_ACTIVATION_EXACT_ROLLBACK: PASS');
}catch(e){result.safe_error=safeError(e);process.exitCode=1;}
finally{
 if(http)try{http.stop();}catch{}if(holder.db)try{await holder.db.close();}catch{}try{s.stop();}catch{}
 if(result.restore?.isolation){result.container_identity_sha256=hash(result.restore.isolation.container_id);delete result.restore.isolation.container_id;}
 result.completed_at_utc=new Date().toISOString();writeFileSync(resolve(s.path,'rehearsal.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,production_accessed:false}));
}
