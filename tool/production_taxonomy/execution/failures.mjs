// Faults exist only in this isolated local harness; the Production engine has no fault switches.
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { create, session, stop, freshBackup } from './local.mjs';
import { restore } from './restore.mjs';
import { baseline } from './baseline.mjs';
import { apply0012, rollback0012, readPreflight, readPostflight } from './engine.mjs';
import { productionSession } from './production.mjs';
import { verifyBundle } from './seal.mjs';
import { check, hash, json, literal, payload, project, root, safeError, stable, validateBackup, version } from './common.mjs';

const results=[]; let backup; let active;
async function connection() {const db=session();await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");return db;}
async function preserved(applied=false) {
 const db=await connection();try {await (applied?readPostflight(db):readPreflight(db,backup));} finally{await db.close();}
}
async function failure(name,setup,operation=apply0012,applied=false,expectedCode) {
 const db=await connection();let code;
 try {if(setup)await setup(db);await operation(db,backup);} catch(e){code=safeError(e);} finally{await db.close();}
 check(code && (!expectedCode || code===expectedCode),'FAILURE_NOT_DETECTED_'+name.toUpperCase());
 await preserved(applied);results.push({case:name,result:'PASS',detected:code,partial_corruption:false});console.log(JSON.stringify(results.at(-1)));
}
function inject(db,sql,when='lock') {
 const exec=db.exec.bind(db);let used=false;
 db.exec=async statement=>{
  const result=await exec(statement);
  if(!used&&(when==='lock'?statement.includes('LOCK TABLE public.categories'):statement===payload().sql)) {used=true;await exec(sql);}
  return result;
 };
}
try {
 const bundle=hash(stable(json('tool/production_taxonomy/execution/bundle.json')));verifyBundle(bundle);
 await create();await restore(); active=await connection();await baseline(active);await active.close();active=null;backup=freshBackup();
 await failure('wrong_target_identity',db=>{db.transport={...db.transport,project_ref:'wrong-project'};},apply0012,false,'W52JB_TARGET_TRANSPORT_IDENTITY');
 await failure('wrong_baseline_count',db=>inject(db,'DELETE FROM public.shop_products WHERE id=(SELECT id FROM public.shop_products ORDER BY id LIMIT 1);'),apply0012,false,'W52JB_CONTRACT_LEGACY_COUNTS_CHANGED');
 await failure('0012_marked_without_objects',db=>inject(db,`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES (${literal(version)},'0012_production_canonical_side_by_side',ARRAY[]::text[]);`),apply0012,false,'W52JB_0012_ALREADY_APPLIED');
 for(const n of ['0010','0011']) await failure(`unexpected_${n}_ledger`,db=>inject(db,`INSERT INTO supabase_migrations.schema_migrations(version,name) VALUES ('20990916${n}00','${n}_unexpected');`),apply0012,false,'W52JB_UNEXPECTED_0010_0011');
 await failure('missing_mapping_row',db=>inject(db,'DELETE FROM public.product_canonical_assignments WHERE product_id=(SELECT product_id FROM public.product_canonical_assignments ORDER BY product_id LIMIT 1);','payload'),apply0012,false,'W52JB_CONTRACT_EXACT_OWNER_MAPPING');
 await failure('sql_failure_before_completion',db=>{
  const exec=db.exec.bind(db);db.exec=sql=>exec(sql===payload().sql?sql+'\nSELECT 1/0;':sql);
 },apply0012,false,'W52JB_PSQL_22012');
 await failure('ledger_insert_failure',db=>{
  const exec=db.exec.bind(db);db.exec=sql=>exec(sql.startsWith('INSERT INTO supabase_migrations.schema_migrations')?'SELECT 1/0;':sql);
 },apply0012,false,'W52JB_PSQL_22012');
 await failure('missing_backup',null,db=>apply0012(db,null),false,'W52JB_FRESH_BACKUP_REQUIRED');
 await failure('stale_backup',null,db=>apply0012(db,{...backup,completed_at_utc:new Date(Date.now()-3600000).toISOString()}),false,'W52JB_BACKUP_NOT_FRESH');
 active=await connection();const before=await rollback0012(active);check(before.result==='ALREADY_BASELINE_NO_OP','ROLLBACK_BEFORE_APPLY');await active.close();active=null;
 results.push({case:'rollback_before_apply',result:'PASS',outcome:before.result,partial_corruption:false});
 active=await connection();await apply0012(active,backup);await active.close();active=null;
 await failure('0012_already_applied_reapply',null,apply0012,true,'W52JB_0012_ALREADY_APPLIED');
 await failure('rollback_external_dependency',db=>inject(db,'CREATE VIEW public.w52jb_unrelated_test_view AS SELECT id FROM public.canonical_categories;'),rollback0012,true,'W52JB_ROLLBACK_SCHEMA_DRIFT');
 active=await connection();await rollback0012(active);const twice=await rollback0012(active);check(twice.result==='ALREADY_BASELINE_NO_OP','ROLLBACK_TWICE');await baseline(active);await active.close();active=null;
 results.push({case:'rollback_called_twice',result:'PASS',outcome:twice.result,partial_corruption:false});
 for(const [name,operation,expected] of [
  ['production_wrong_project_before_connection',()=>productionSession({authorized:true,project:'wrong-project'}),'W52JB_TARGET_PROJECT'],
  ['production_authorization_absent',()=>productionSession({project}),'W52JB_FUTURE_PRODUCTION_AUTHORIZATION_REQUIRED'],
  ['wrong_bundle_hash',()=>verifyBundle('0'.repeat(64)),'W52JB_BUNDLE_HASH_MISMATCH'],
  ['backup_hash_mismatch',()=>validateBackup({...backup,size_bytes:5},Buffer.from('PGDMP')),'W52JB_BACKUP_HASH'],
 ]) {let code;try{operation();}catch(e){code=safeError(e);}check(code===expected,'OFFLINE_FAILURE_'+name.toUpperCase());results.push({case:name,result:'PASS',detected:code,connection_opened:false});}
 const result={result:'PASS',bundle_sha256:bundle,captured_at_utc:new Date().toISOString(),cases:results.length,results,automatic_transaction_rollback:true,manual_sql_repairs:0,production_accessed:false};
 writeFileSync(resolve(root,'docs/data/w52j_b_failure_injection.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({result:'PASS',cases:results.length}));
}catch(error){console.error(safeError(error));process.exitCode=1;}
finally{if(active)await active.close();try{stop();}catch{}}
