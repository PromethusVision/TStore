import {check,literal,project,version,name,payload,stable} from './common.mjs';
import {canonicalData} from './catalog.mjs';
import {verify} from './seal.mjs';
import {validatePlan,authorize} from './authorization.mjs';
import {identity} from '../../production_taxonomy/execution/validators.mjs';
import {baseline,preflight,postflight,security} from './validators.mjs';
async function transaction(db,fn,readOnly=true){
 let committing=false;
 try{
  await db.exec(`BEGIN ISOLATION LEVEL ${readOnly?'REPEATABLE READ READ ONLY':'READ COMMITTED READ WRITE'}; SET LOCAL search_path=public,extensions; SET LOCAL timezone='UTC'; SET LOCAL datestyle='ISO'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='120s'; SELECT set_config('request.jwt.claims','{}',true);`);
  await identity(db);
  if(!readOnly)await db.exec(`SELECT set_config('esnaftavar.w52kb.target_ref',${literal(project)},true);
DO $lock$ BEGIN IF NOT pg_try_advisory_xact_lock(hashtextextended('w52h-production-canonical-adapter',0)) THEN RAISE EXCEPTION 'W52JB_BX_CONCURRENT_EXECUTOR'; END IF; END $lock$;
LOCK TABLE public.categories,public.products,public.shops,public.shop_products,public.brands,supabase_migrations.schema_migrations,public.canonical_categories,public.product_canonical_assignments,public.production_taxonomy_config,public.canonical_category_qualification,public.taxonomy_aliases,public.taxonomy_alias_targets,public.taxonomy_id_allocations,public.taxonomy_import_runs,public.taxonomy_node_relationships IN SHARE ROW EXCLUSIVE MODE;`);
  const result=await fn();committing=true;await db.exec('COMMIT;');
  return {...result,transaction:readOnly?'READ_ONLY_COMPLETED':'COMMIT_ACKNOWLEDGED'};
 }catch(error){if(!db.closed)try{await db.exec('ROLLBACK;');}catch{}
  if(committing)throw new Error('W52JB_BX_COMMIT_OUTCOME_UNKNOWN_READ_ONLY_RECONCILIATION_REQUIRED');throw error;
 }
}
export async function readPreflight(db,packageHash,plan){verify(packageHash);validatePlan(plan);return transaction(db,()=>preflight(db,plan));}
export async function readPostflight(db,packageHash,plan){verify(packageHash);validatePlan(plan);return transaction(db,()=>postflight(db,plan));}
export async function readRollbackValidation(db,packageHash){verify(packageHash);return transaction(db,()=>baseline(db,false));}
function backupGate(backup){
 check(backup?.verified===true&&backup.project_ref===project,'BX_VERIFIED_BACKUP_REQUIRED');
 const age=Date.now()-Date.parse(backup.completed_at_utc);check(Number.isFinite(age)&&age>=-30000&&age<=900000,'BX_BACKUP_FRESHNESS');
}
export async function deploy(db,packageHash,plan,backup){
 verify(packageHash);validatePlan(plan);backupGate(backup);
 const before=await readPreflight(db,packageHash,plan);
 return transaction(db,async()=>{
  verify(packageHash);backupGate(backup);await preflight(db,plan);
  const dataBefore=await canonicalData(db);
  const application=payload();await db.exec(application.sql);
  await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([application.sql])}::text[]);`);
  await authorize(db,plan);
  const after=await postflight(db,plan);
  check(stable(await canonicalData(db))===stable(dataBefore),'BX_DEPLOY_CANONICAL_DATA_CHANGED');
  return {result:'PASS',package_sha256:packageHash,payload_sha256:application.sha256,only_migration:version,before,after,atomic:'BRIDGE_LEDGER_ALLOWLIST_VALIDATION'};
 },false);
}
export async function rollback(db,packageHash){
 verify(packageHash);
 await transaction(db,()=>baseline(db,true));
 return transaction(db,async()=>{
  verify(packageHash);await baseline(db,true);await security(db);
  const dataBefore=await canonicalData(db);
  await db.exec(payload(true).sql);
  await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)} AND name=${literal(name)} AND statements=${literal([payload().sql])}::text[];`);
  check(stable(await canonicalData(db))===stable(dataBefore),'BX_ROLLBACK_CANONICAL_DATA_CHANGED');
  return {...await baseline(db,false),removed_only:version,canonical_0012_preserved:true};
 },false);
}
export async function revoke(db,packageHash,plan){
 verify(packageHash);validatePlan(plan,Date.now(),true);
 await transaction(db,()=>baseline(db,true));
 return transaction(db,async()=>{
  verify(packageHash);await baseline(db,true);await security(db);
  const count=(await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE user_id=ANY($1::uuid[])',[plan.user_ids])).rows[0].n;
  check(count===plan.user_ids.length,'BX_REVOKE_EXACT_MEMBERS_REQUIRED');
  await db.exec(`DELETE FROM production_preview_private.testers WHERE user_id=ANY(${literal(plan.user_ids)}::uuid[]);`);
  check((await db.query('SELECT count(*)::int AS n FROM production_preview_private.testers WHERE user_id=ANY($1::uuid[])',[plan.user_ids])).rows[0].n===0,'BX_REVOKE_FAILED');
  await baseline(db,true);return {result:'PASS',revoked_count:count,public_activation:false};
 },false);
}
