import {verify} from './seal.mjs';
import {readPreflight,deploy,rollback,readRollbackValidation,revoke} from './engine.mjs';
import {preflight,baseline} from './validators.mjs';
import {check,project,stable,literal} from './common.mjs';
import {validatePlan} from './authorization.mjs';
import {asRole,denied,call} from './rpc-checks.mjs';
import {snapshot} from './catalog.mjs';
export async function expectFailure(label,operation,results){
 const codes={wrong_target_identity:'TARGET_TRANSPORT_IDENTITY',wrong_package_hash:'BX_PACKAGE_HASH',missing_uid_input:'BX_UID_REQUIRED',invalid_uid_input:'BX_UID_INVALID',expired_approval_input:'BX_EXPIRY_WINDOW',expiry_over_30_days:'BX_EXPIRY_WINDOW',rollback_before_apply:'BX_REAPPLY_OR_LEDGER_STATE',missing_0012:'0012_LEDGER_ENTRY_MISMATCH',public_activation_on:'BX_PUBLIC_ACTIVATION_OFF',schema_drift:'BX_0012_SCHEMA_DRIFT', '0012_ledger_payload_drift':'0012_LEDGER_ENTRY_MISMATCH',failure_during_bridge_transaction:'BX_TEST_TRANSACTION_FAILURE',bridge_already_applied:'BX_REAPPLY_OR_LEDGER_STATE',rollback_twice:'BX_REAPPLY_OR_LEDGER_STATE'};
 let failed=false;try{await operation();}catch(error){check(error.message===`W52JB_${codes[label]}`,'BX_UNEXPECTED_TEST_ERROR_'+label.toUpperCase()+'_'+(/^W52JB_[A-Z0-9_]+$/.test(error.message)?error.message:'PRIVATE_ERROR'));failed=true;}
 check(failed,'BX_FAILURE_EXPECTED_'+label.toUpperCase());results.push({case:label,result:'PASS_SAFE_REFUSAL'});
}
export async function beforeTests(db,packageHash,plan,backup,results){
 await expectFailure('wrong_target_identity',()=>readPreflight({...db,transport:{verified:true,project_ref:'wrong'},exec:db.exec.bind(db),query:db.query.bind(db)},packageHash,plan),results);
 await expectFailure('wrong_package_hash',()=>readPreflight(db,'0'.repeat(64),plan),results);
 await expectFailure('missing_uid_input',()=>readPreflight(db,packageHash,{...plan,user_ids:[]}),results);
 await expectFailure('invalid_uid_input',()=>readPreflight(db,packageHash,{...plan,user_ids:['not-a-uuid']}),results);
 await expectFailure('expired_approval_input',()=>readPreflight(db,packageHash,{...plan,expires_at_utc:'2020-01-01T00:00:00Z'}),results);
 await expectFailure('expiry_over_30_days',()=>validatePlan({...plan,expires_at_utc:new Date(Date.now()+31*86400000).toISOString()}),results);
 await expectFailure('rollback_before_apply',()=>rollback(db,packageHash),results);
 // Local-only uncommitted corruption. Exercise the SAME validator used under
// the live executor's locked preflight, then roll back every fixture change.
 for(const [label,sql]of [
  ['missing_0012',"DELETE FROM supabase_migrations.schema_migrations WHERE version='20260916001200'"],
  ['public_activation_on','UPDATE public.production_taxonomy_config SET public_enabled=true'],
  ['schema_drift','CREATE INDEX w52kbx_drift_probe ON public.categories(name)'],
  ['0012_ledger_payload_drift',"UPDATE supabase_migrations.schema_migrations SET statements=ARRAY['wrong'] WHERE version='20260916001200'"],
 ]){
  await db.exec('BEGIN;');try{await db.exec(sql);await expectFailure(label,()=>preflight(db,plan),results);}finally{await db.exec('ROLLBACK;');}
 }
 const before=stable(await snapshot(db));
 // Fault outside production code: throw immediately after the real bridge DDL.
 let injected=false;
 const proxy={transport:db.transport,get closed(){return db.closed;},query:db.query.bind(db),exec:async sql=>{const result=await db.exec(sql);if(sql.includes('CREATE SCHEMA production_preview_private')){injected=true;throw new Error('W52JB_BX_TEST_TRANSACTION_FAILURE');}return result;}};
 await expectFailure('failure_during_bridge_transaction',()=>deploy(proxy,packageHash,plan,backup),results);
 check(injected&&stable(await snapshot(db))===before,'BX_TRANSACTION_ATOMICITY');await readRollbackValidation(db,packageHash);
}
export async function afterTests(db,packageHash,plan,backup,results){
 await expectFailure('bridge_already_applied',()=>deploy(db,packageHash,plan,backup),results);
 for(const role of ['anon','authenticated']){
  await db.exec('BEGIN READ ONLY;');try{await asRole(db,role,null,()=>denied(db,call('taxonomy_capabilities_v2')));}finally{await db.exec('ROLLBACK;');}
  results.push({case:role==='anon'?'anonymous_preview':'authenticated_non_preview',result:'PASS_DENIED'});
 }
 await db.exec('BEGIN READ ONLY;');try{await asRole(db,'authenticated',plan.user_ids[0],()=>denied(db,call('taxonomy_roots_v2',{p_preview:true,p_client_contract_version:'wrong'}),'P0001'));}finally{await db.exec('ROLLBACK;');}
 results.push({case:'wrong_contract_version',result:'PASS_DENIED'});
 await db.exec("BEGIN; UPDATE production_preview_private.testers SET granted_at=now()-interval '2 hours',expires_at=now()-interval '1 hour';");
 try{await asRole(db,'authenticated',plan.user_ids[0],()=>denied(db,call('taxonomy_capabilities_v2')));}finally{await db.exec('ROLLBACK;');}
 results.push({case:'expired_allowlist_entry',result:'PASS_DENIED'});
 // Prove products remain subject to invoker RLS using a rollback-only local policy.
 let product;await db.exec('BEGIN READ ONLY;');try{await asRole(db,'authenticated',plan.user_ids[0],async()=>{product=(await db.query(call('production_preview_products_v1'))).rows[0].product_id;check((await db.query(call('production_preview_products_v1',{p_product_id:product}))).rows.length===1,'BX_RLS_POSITIVE_CONTROL');});}finally{await db.exec('ROLLBACK;');}
 await db.exec(`BEGIN; CREATE POLICY w52kbx_restrictive_probe ON public.products AS RESTRICTIVE FOR SELECT TO authenticated USING(id<>${literal(product)}::uuid);`);
 try{await asRole(db,'authenticated',plan.user_ids[0],async()=>check((await db.query(call('production_preview_products_v1',{p_product_id:product}))).rows.length===0,'BX_RLS_PROBE'));}finally{await db.exec('ROLLBACK;');}
 results.push({case:'restrictive_product_rls',result:'PASS_PRESERVED'});
 // Use the real removal mechanism; caller rolls the bridge back afterwards.
 await revoke(db,packageHash,plan);
 await db.exec('BEGIN READ ONLY;');try{await asRole(db,'authenticated',plan.user_ids[0],()=>denied(db,call('taxonomy_capabilities_v2')));}finally{await db.exec('ROLLBACK;');}
 results.push({case:'runtime_uid_revocation',result:'PASS_DENIED'});
}
