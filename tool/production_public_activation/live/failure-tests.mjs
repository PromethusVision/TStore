// Rehearsal-only faults on the network-disabled real restore. Every rejected
// operation must preserve the complete before fingerprint after rollback.
import {check,safeError,payload} from './common.mjs';
import {state,fullFingerprint} from './validators.mjs';
import {readState,activate,rollback,reconcile} from './engine.mjs';
import {requireBackup} from '../../production_public_client/live/backup.mjs';
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
 const mutate=(name,sql,active,expected)=>run(name,async()=>{await holder.db.exec('BEGIN;');await holder.db.exec(sql);await state(holder.db,active);},expected);
 return {results,
  async before(backup){
   await run('wrong_project',()=>readState(proxy({transport:{...holder.db.transport,project_ref:'wrong'}}),options),/W52LC_TARGET_IDENTITY/);
   await run('missing_authorization',()=>activate(holder.db,{...options,production_authorized:false},backup),/W52LE_EXPLICIT_ACTIVATION_AUTHORIZATION_REQUIRED/);
   await run('wrong_sql_hash',()=>activate(holder.db,{...options,sql_sha256:'0'.repeat(64)},backup),/W52LE_EXPECTED_SQL_HASH/);
   await run('wrong_seal',()=>activate(holder.db,{...options,seal_sha256:'0'.repeat(64)},backup),/W52LE_PACKAGE_HASH/);
   await run('wrong_apk_hash_evidence',()=>activate(holder.db,{...options,apk:options.aab},backup),/W52LE_FROZEN_APK_HASH/);
   await run('forged_backup',()=>activate(holder.db,{...options},{...backup}),/W52LC_VERIFIED_FRESH_BACKUP_REQUIRED/);
   await run('expired_backup',()=>requireBackup(backup,backup.baseline_fingerprint,Date.parse(backup.completed_at_utc)+900001),/W52LC_BACKUP_EXPIRED/);
   await mutate('0014_already_applied',"INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES('20260922001400','local_fault',ARRAY['not reviewed']);",false,/W52LA_REAPPLY_PROTECTION/);
   await mutate('0012_missing',"DELETE FROM supabase_migrations.schema_migrations WHERE version='20260916001200';",false,/0012_LEDGER_ENTRY_MISMATCH/);
   await mutate('0015_absent',"DELETE FROM supabase_migrations.schema_migrations WHERE version='20260922001500';",false,/W52LB_EXACT_FACADE_LEDGER/);
   await mutate('0015_definition_mismatch','ALTER FUNCTION public.production_public_read_capabilities_v1(text,text) VOLATILE;',false,/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
   await mutate('0015_grant_mismatch','GRANT EXECUTE ON FUNCTION public.production_public_read_capabilities_v1(text,text) TO PUBLIC;',false,/W52LB_FACADE_DEFINITION_OR_GRANT_DRIFT/);
   await mutate('0015_ledger_mismatch',"UPDATE supabase_migrations.schema_migrations SET statements=ARRAY['wrong'] WHERE version='20260922001500';",false,/W52LB_EXACT_FACADE_LEDGER/);
   await mutate('public_already_on','UPDATE public.production_taxonomy_config SET public_enabled=true;',false,/W52LA_PUBLIC_ALREADY_ON/);
   await mutate('active_tester_lease',"UPDATE production_preview_private.testers SET granted_at=now(),expires_at=now()+interval '1 hour',enabled=true;",false,/ACTIVE_PREVIEW_LEASE_MUST_EXPIRE_FIRST/);
   await mutate('node_count_mismatch',"INSERT INTO public.canonical_categories(id,name,level,is_active,is_assignable,lifecycle_state,taxonomy_version,policy_class,professional_review_status) VALUES(gen_random_uuid(),'Local fault',1,false,false,'staged','canonical-v1.0.0','NORMAL','not_required');",false,/CANONICAL_NODE_COUNTS/);
   await mutate('root_count_mismatch',"UPDATE public.canonical_categories SET level=1,parent_id=NULL WHERE id=(SELECT id FROM public.canonical_categories WHERE level=2 ORDER BY id LIMIT 1);",false,/CANONICAL_NODE_COUNTS/);
   await mutate('mapping_mismatch',"UPDATE public.product_canonical_assignments SET canonical_path=canonical_path||' local fault' WHERE product_id=(SELECT product_id FROM public.product_canonical_assignments ORDER BY product_id LIMIT 1);",false,/EXACT_OWNER_MAPPING/);
   await mutate('policy_gate_mismatch',"UPDATE public.canonical_category_qualification SET policy_gate='FAIL_CLOSED' WHERE category_id=(SELECT category_id FROM public.canonical_category_qualification WHERE policy_gate='PASS' ORDER BY category_id LIMIT 1);",false,/EXACT_QUALIFICATION_GATES/);
   await mutate('legacy_contract_failure',"UPDATE public.products SET name=name||' local fault' WHERE id=(SELECT id FROM public.products ORDER BY id LIMIT 1);",false,/BX_LEGACY_DATA/);
   await mutate('security_rls_drift','ALTER TABLE public.product_canonical_assignments DISABLE ROW LEVEL SECURITY;',false,/BX_0012_SCHEMA_DRIFT|BX_SCHEMA_SECURITY_DRIFT/);
   await mutate('public_write_exposure','GRANT INSERT ON public.canonical_categories TO anon;',false,/BX_0012_SCHEMA_DRIFT|BX_SCHEMA_SECURITY_DRIFT/);
   await run('rollback_before_activation',()=>rollback(holder.db,{...options}),/W52LA_EXACT_ACTIVATION_LEDGER/);
   for(const step of ['after_publication','after_ledger']){
    let reached=false;const execute=holder.db.exec.bind(holder.db);
    await run('activation_transaction_failure_'+step,()=>activate(proxy({exec:async sql=>{
     const out=await execute(sql);
     if(step==='after_publication'?sql===payload():sql.startsWith('INSERT INTO supabase_migrations.schema_migrations')&&sql.includes("'20260922001400'")){reached=true;throw Error('W52LE_INJECTED_TRANSACTION_FAILURE');}
     return out;
    }}),{...options},backup),/W52LE_INJECTED_TRANSACTION_FAILURE/);check(reached,'TRANSACTION_FAILURE_REACHED');
   }
   for(const committed of [false,true])await run('uncertain_commit_'+(committed?'committed':'aborted'),async()=>{
    let armed=false,error;const execute=holder.db.exec.bind(holder.db);
    try{await activate(proxy({exec:async sql=>{if(sql===payload())armed=true;if(armed&&sql==='COMMIT;'){if(committed)await execute(sql);throw Error('SIMULATED_ACK_LOSS');}return execute(sql);}}),{...options},backup);}catch(e){error=e;}
    check(error?.message==='W52KBY_COMMIT_OUTCOME_UNKNOWN_CONTAIN_THEN_RECONCILE','UNCERTAIN_COMMIT_REACHED');
    const result=await reconcile({open:()=>s.session()},{...options});
    check(result.result===(committed?'ROLLED_BACK_0014_ONLY':'BASELINE_NO_WRITE'),'UNCERTAIN_COMMIT_RECONCILIATION');
    throw Error('W52LE_UNCERTAIN_COMMIT_RECONCILED');
   },/W52LE_UNCERTAIN_COMMIT_RECONCILED/);
  },
  async active(backup){
   await run('actual_reapply',()=>activate(holder.db,{...options},backup),/W52LA_REAPPLY_PROTECTION/);
   await mutate('active_ledger_drift',"UPDATE supabase_migrations.schema_migrations SET statements=ARRAY['wrong'] WHERE version='20260922001400';",true,/W52LA_EXACT_ACTIVATION_LEDGER/);
   let reached=false;const execute=holder.db.exec.bind(holder.db);
   await run('partial_rollback_failure',()=>rollback(proxy({exec:async sql=>{const out=await execute(sql);if(sql===payload(true)){reached=true;throw Error('W52LE_INJECTED_ROLLBACK_FAILURE');}return out;}}),{...options}),/W52LE_INJECTED_ROLLBACK_FAILURE/);check(reached,'ROLLBACK_FAILURE_REACHED');
  },
  async after(){await run('rollback_twice',()=>rollback(holder.db,{...options}),/W52LA_EXACT_ACTIVATION_LEDGER/);},
 };
}
