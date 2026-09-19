import {check,literal,project} from './common.mjs';
import {identity} from '../../production_taxonomy/execution/validators.mjs';
export async function transaction(db,operation,{write=false,coreLocks=false}={}){
 let committing=false;
 try{
  await db.exec(`BEGIN ISOLATION LEVEL ${write?'READ COMMITTED READ WRITE':'REPEATABLE READ READ ONLY'}; SET LOCAL search_path=public,extensions; SET LOCAL timezone='UTC'; SET LOCAL datestyle='ISO'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='120s'; SELECT set_config('request.jwt.claims','{}',true);`);
  await identity(db);
  if(write){
   await db.exec(`SELECT set_config('esnaftavar.w52kb.target_ref',${literal(project)},true); DO $lock$ BEGIN IF NOT pg_try_advisory_xact_lock(hashtextextended('w52h-production-canonical-adapter',0)) THEN RAISE EXCEPTION 'W52KBY_CONCURRENT_EXECUTOR'; END IF; END $lock$;`);
   if(coreLocks)await db.exec('LOCK TABLE public.categories,public.products,public.shops,public.shop_products,public.brands,supabase_migrations.schema_migrations,public.canonical_categories,public.product_canonical_assignments,public.production_taxonomy_config,public.canonical_category_qualification,public.taxonomy_aliases,public.taxonomy_alias_targets,public.taxonomy_id_allocations,public.taxonomy_import_runs,public.taxonomy_node_relationships IN SHARE ROW EXCLUSIVE MODE;');
  }
  const result=await operation();committing=true;await db.exec('COMMIT;');return {...result,transaction:write?'COMMIT_ACKNOWLEDGED':'READ_ONLY_COMPLETED'};
 }catch(error){if(!db.closed)try{await db.exec('ROLLBACK;');}catch{}
  if(committing)throw new Error('W52KBY_COMMIT_OUTCOME_UNKNOWN_CONTAIN_THEN_RECONCILE');throw error;
 }
}
