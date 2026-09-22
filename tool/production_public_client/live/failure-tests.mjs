// Faults are executed ONLY in the network-disabled restored copy. Every case
// proves the complete fingerprint is identical after recovery, not just an error.
import {check,stable,payload,safeError} from './common.mjs';
import {state,offContract,fullFingerprint} from './validators.mjs';
import {readState,install,rollback,reconcile} from './engine.mjs';
import {requireBackup} from './backup.mjs';
export function failures(s,holder,options){
 const results=[];
 const proxy=overrides=>new Proxy(holder.db,{get(target,key){if(key in overrides)return overrides[key];const value=target[key];return typeof value==='function'?value.bind(target):value;}});
 async function recover(){if(holder.db.closed){holder.db=s.session();await holder.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");}else await holder.db.exec('ROLLBACK;');}
 async function run(name,operation,expected){
  const before=await fullFingerprint(holder.db);let error;
  try{await operation();}catch(e){error=e;}finally{await recover();}
  check(error&&expected.test(error.message),'FAILURE_EXPECTATION_'+name.toUpperCase()+'_'+safeError(error));
  check(await fullFingerprint(holder.db)===before,'FAILURE_RESIDUE_'+name.toUpperCase());
  results.push({case:name,result:'PASS',safe_stop:safeError(error),exact_state_preserved:true});
 }
 async function mutate(name,sql,installed,expected,validator){
  return run(name,async()=>{await holder.db.exec('BEGIN;');await holder.db.exec(sql);await (validator??(db=>state(db,installed)))(holder.db);},expected);
 }
 return {results,
  async before(backup){
   await run('wrong_project',()=>readState(proxy({transport:{...holder.db.transport,project_ref:'wrong'}}),options.seal_sha256),/W52LC_TARGET_IDENTITY/);
   await run('missing_explicit_authorization',()=>install(holder.db,{...options,production_authorized:false},backup),/W52LC_EXPLICIT_DEPLOY_AUTHORIZATION_REQUIRED/);
   await run('wrong_sql_hash',()=>install(holder.db,{...options,sql_sha256:'0'.repeat(64)},backup),/W52LC_EXPECTED_SQL_HASH/);
   await run('wrong_runtime_seal',()=>install(holder.db,{...options,seal_sha256:'0'.repeat(64)},backup),/W52LC_PACKAGE_HASH/);
   await run('missing_or_forged_backup',()=>install(holder.db,{...options},{...backup}),/W52LC_VERIFIED_FRESH_BACKUP_REQUIRED/);
   await run('stale_backup',()=>requireBackup(backup,backup.baseline_fingerprint,Date.parse(backup.completed_at_utc)+900001),/W52LC_BACKUP_EXPIRED/);
   await mutate('0012_missing',"DELETE FROM supabase_migrations.schema_migrations WHERE version='20260916001200';",false,/0012_LEDGER_ENTRY_MISMATCH/);
   await mutate('unexpected_0014_ledger',"INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES('20260922001400','failure_fixture_only',ARRAY['not an activation payload']);",false,/W52LC_0014_MUST_BE_ABSENT/);
   await mutate('public_already_on',"UPDATE public.production_taxonomy_config SET public_enabled=true;",false,/W52LC_PUBLIC_MUST_STAY_OFF/);
   await run('rollback_before_apply',()=>rollback(holder.db,{...options}),/W52LC_0015_LEDGER_REQUIRED/);
   for(const step of ['after_functions','after_ledger']){
    let reached=false;const execute=holder.db.exec.bind(holder.db);
    await run('partial_transaction_'+step,()=>install(proxy({exec:async sql=>{
     const out=await execute(sql);
     if(step==='after_functions'?sql===payload():sql.startsWith('INSERT INTO supabase_migrations.schema_migrations')&&sql.includes("'20260922001500'")){reached=true;throw Error('W52LC_INJECTED_TRANSACTION_FAILURE');}
     return out;
    }}),{...options},backup),/W52LC_INJECTED_TRANSACTION_FAILURE/);check(reached,'PARTIAL_FAILURE_REACHED');
   }
   for(const committed of [false,true])await run('uncertain_commit_'+(committed?'committed':'aborted'),async()=>{
    let armed=false,error;const execute=holder.db.exec.bind(holder.db);
    try{await install(proxy({exec:async sql=>{
     if(sql===payload())armed=true;
     if(armed&&sql==='COMMIT;'){if(committed)await execute(sql);throw Error('SIMULATED_ACK_LOSS');}
     return execute(sql);
    }}),{...options},backup);}catch(e){error=e;}
    check(error?.message==='W52KBY_COMMIT_OUTCOME_UNKNOWN_CONTAIN_THEN_RECONCILE','UNCERTAIN_COMMIT_REACHED');
    const result=await reconcile({open:()=>s.session()},{...options});
    check(result.result===(committed?'ROLLED_BACK_0015_ONLY':'BASELINE_NO_WRITE'),'UNCERTAIN_COMMIT_RECONCILIATION');
    throw Error('W52LC_UNCERTAIN_COMMIT_RECONCILED');
   },/W52LC_UNCERTAIN_COMMIT_RECONCILED/);
  },
  async installed(backup){
   await run('0015_already_applied',()=>install(holder.db,{...options},backup),/W52LC_0015_ALREADY_APPLIED/);
   await mutate('wrong_function_definition',"ALTER FUNCTION public.production_public_read_capabilities_v1(text,text) VOLATILE;",true,/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
   await mutate('wrong_public_execute_grant',"GRANT EXECUTE ON FUNCTION public.production_public_read_capabilities_v1(text,text) TO PUBLIC;",true,/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
   await mutate('wrong_service_role_grant',"GRANT EXECUTE ON FUNCTION public.production_public_products_v1(text,text,uuid,uuid,uuid,boolean,text,boolean,text,boolean,integer,integer) TO service_role;",true,/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
   await mutate('ledger_mismatch',"UPDATE supabase_migrations.schema_migrations SET statements=ARRAY['tampered'] WHERE version='20260922001500';",true,/W52LB_EXACT_FACADE_LEDGER/);
   await mutate('rls_disabled',"ALTER TABLE public.product_canonical_assignments DISABLE ROW LEVEL SECURITY;",true,/BX_0012_SCHEMA_DRIFT|SCHEMA_SECURITY_DRIFT/);
   await mutate('canonical_write_grant',"GRANT UPDATE ON public.canonical_categories TO anon;",true,/BX_0012_SCHEMA_DRIFT|SCHEMA_SECURITY_DRIFT/);
   // Test the actual behavioral denial validator separately from fingerprint
   // checks: an OFF function that returns instead of denying must fail too.
   let firstSqlError;const executeDenial=holder.db.exec.bind(holder.db);
   await mutate('public_off_behavior_leak',"CREATE OR REPLACE FUNCTION public.production_public_read_capabilities_v1(p_client_contract_version text,p_taxonomy_version text) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $$ BEGIN RETURN '{}'::jsonb; END $$;",true,/W52JB_BX_EXPECTED_DENIAL|W52JB_PSQL_XX000|W52JB_SESSION_NOT_AVAILABLE/,
    ()=>offContract(proxy({exec:async sql=>{try{return await executeDenial(sql);}catch(e){firstSqlError??=e;throw e;}}})));
   check(/W52JB_BX_EXPECTED_DENIAL|W52JB_PSQL_XX000/.test(firstSqlError?.message),'OFF_BEHAVIOR_FAILURE_REASON');
   results.at(-1).underlying_safe_error=safeError(firstSqlError);
   const execute=holder.db.exec.bind(holder.db);let reached=false;
   await run('partial_rollback_failure',()=>rollback(proxy({exec:async sql=>{const out=await execute(sql);if(sql.includes('DROP FUNCTION public.production_public_listings_v1')){reached=true;throw Error('W52LC_INJECTED_ROLLBACK_FAILURE');}return out;}}),{...options}),/W52LC_INJECTED_ROLLBACK_FAILURE/);check(reached,'ROLLBACK_FAILURE_REACHED');
  },
  async after(){await run('rollback_twice',()=>rollback(holder.db,{...options}),/W52LC_0015_LEDGER_REQUIRED/);},
 };
}
