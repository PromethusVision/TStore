import {check,literal,facade,safeError} from './common.mjs';
import {resolveIdentity} from './identity.mjs';
import {stageA,stageB,readPreflight,readStageA,readStageB,deployStaged} from './engine.mjs';
import {removeTester,containAndRollback} from './containment.mjs';
const params={p_client_contract_version:'taxonomy-client-v1',p_taxonomy_version:'canonical-v1.0.0'};
export async function failures(h,seal){
 const results=[];
 const expectedErrors={tester_uid_missing:'W52KBY_TESTER_UID_MISSING_OR_INVALID',invalid_uid:'W52KBY_TESTER_UID_MISSING_OR_INVALID',tester_session_wrong_project:'W52KBY_TESTER_PROJECT_IDENTITY_MISMATCH',expired_tester_session:'W52KBY_SESSION_EXPIRED_SIGN_IN_EXISTING_ACCOUNT',invalid_session_signature:'W52KBY_TESTER_SESSION_INVALID',wrong_package_hash:'W52KBY_PACKAGE_HASH',public_activation_on_before_apply:'W52JB_BX_PUBLIC_ACTIVATION_OFF',schema_fingerprint_drift_before_apply:'W52JB_BX_0012_SCHEMA_DRIFT',missing_0012:'W52JB_0012_LEDGER_ENTRY_MISMATCH',allowlist_expiry_invalid:'W52KBY_LEASE_MUST_BE_POSITIVE_AT_MOST_24_HOURS'};
 const capture=async(label,run)=>{h.failedCase=label;await h.reset();let observed;try{observed=await run();}catch(error){if(safeError(error)!==expectedErrors[label])throw error;observed={expected_error:safeError(error)};}check(observed&&(observed.expected_error||observed.result!=='PASS'||observed.safe_assertion),'EXPECTED_FAILURE_OR_ASSERTION_'+label.toUpperCase());const disabled=await h.assertNoAccess();results.push({case:label,result:'PASS',outcome:observed.result??observed.expected_error,preview_authorization_left_active:disabled.active_authorizations});h.failedCase=null;console.log('BY_FAILURE_CASE_PASS: '+label);};
 for(const [label,alter]of [
  ['tester_uid_missing',s=>({...s,user:{}})],['invalid_uid',s=>({...s,user:{id:'invalid'}})],
  ['tester_session_wrong_project',()=>h.session(h.ids[0],{iss:'https://wrong.supabase.co/auth/v1'})],
  ['expired_tester_session',()=>h.session(h.ids[0],{exp:1})],
  ['invalid_session_signature',s=>({...s,access_token:s.access_token.slice(0,-2)+'xx'})],
 ])await capture(label,async()=>{await resolveIdentity(alter(h.fixture),h.key,h.fetch.bind(h));throw new Error('W52KBY_TEST_IDENTITY_WAS_ACCEPTED');});
 await capture('wrong_package_hash',()=>readPreflight(h.ctx,'0'.repeat(64),h.handle));
 await capture('public_activation_on_before_apply',async()=>{await h.ctx.db.exec('UPDATE public.production_taxonomy_config SET public_enabled=true');return readPreflight(h.ctx,seal,h.handle);});
 await capture('schema_fingerprint_drift_before_apply',async()=>{await h.ctx.db.exec('CREATE INDEX w52kby_drift ON public.categories(name)');return readPreflight(h.ctx,seal,h.handle);});
 await capture('missing_0012',async()=>{await h.ctx.db.exec("DELETE FROM supabase_migrations.schema_migrations WHERE version='20260916001200'");return readPreflight(h.ctx,seal,h.handle);});
 await capture('allowlist_expiry_invalid',()=>deployStaged(h.ctx,seal,h.handle,h.backup,{seconds:86401}));
 async function afterStageA(label,inject,{core=false,emergency=false}={}){
  await capture(label,async()=>{
   const outcome=await deployStaged(h.ctx,seal,h.handle,h.backup,{afterA:async()=>{await inject();await readStageA(h.ctx,seal,h.handle);throw new Error('W52KBY_TEST_INJECTED_FAILURE');}});
   check(outcome.containment?.preview_access_disabled,'FAILURE_NOT_CONTAINED');
   check(outcome.result===(emergency?'EMERGENCY_CONTAINMENT':core?'ROLLED_BACK_CORE_DRIFT':'ROLLED_BACK'),'UNEXPECTED_CONTAINMENT_CLASS_'+label.toUpperCase());
   if(core)check(outcome.containment.observed_core_preserved===true,'CORE_DRIFT_WAS_REPAIRED');
   return outcome;
  });
 }
 await afterStageA('bridge_deployed_default_deny_fails',async()=>{
  await h.ctx.db.exec(`INSERT INTO production_preview_private.testers(user_id,enabled,expires_at) VALUES(${literal(h.ids[0])}::uuid,true,now()+interval '1 hour');`);await h.reload();
  check((await h.client.request('/rpc/taxonomy_capabilities_v2',params)).status===200,'DEFAULT_DENY_FAILURE_NOT_REPRODUCED');
 });
 const bypass="CREATE OR REPLACE FUNCTION public._w52kb_assert_contract_v2(p_client_contract_version text,p_taxonomy_version text,p_preview boolean) RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$ BEGIN RETURN; END $fn$;";
 await afterStageA('anonymous_gains_preview',async()=>{await h.ctx.db.exec(bypass+" GRANT EXECUTE ON FUNCTION public.taxonomy_capabilities_v2(text,text) TO anon;");await h.reload();check((await h.client.request('/rpc/taxonomy_capabilities_v2',params,false)).status===200,'ANON_LEAK_NOT_REPRODUCED');});
 await afterStageA('normal_auth_gains_preview',async()=>{await h.ctx.db.exec(bypass);await h.reload();check((await h.otherClient.request('/rpc/taxonomy_capabilities_v2',params)).status===200,'NORMAL_LEAK_NOT_REPRODUCED');});
 await afterStageA('public_activation_after_stage_a',()=>h.ctx.db.exec('UPDATE public.production_taxonomy_config SET public_enabled=true'),{core:true});
 await afterStageA('schema_fingerprint_drift_after_stage_a',()=>h.ctx.db.exec('CREATE INDEX w52kby_drift ON public.categories(name)'),{core:true});
 await afterStageA('rls_drift_after_stage_a',()=>h.ctx.db.exec('CREATE POLICY w52kby_core_drift ON public.products AS RESTRICTIVE FOR SELECT TO authenticated USING(false)'),{core:true});
 await afterStageA('product_integrity_mismatch',()=>h.ctx.db.exec("UPDATE public.products SET name=name||' local fault' WHERE id=(SELECT id FROM public.products ORDER BY id LIMIT 1)"),{core:true});
 await afterStageA('listing_integrity_mismatch',()=>h.ctx.db.exec('DELETE FROM public.shop_products WHERE id=(SELECT id FROM public.shop_products ORDER BY id LIMIT 1)'),{core:true});
 await afterStageA('bridge_ledger_inconsistency',()=>h.ctx.db.exec("UPDATE supabase_migrations.schema_migrations SET name='local_fault',statements=ARRAY['local fault'] WHERE version='20260919001300'"));
 await afterStageA('bridge_ledger_missing',()=>h.ctx.db.exec("DELETE FROM supabase_migrations.schema_migrations WHERE version='20260919001300'"));
 await afterStageA('teardown_dependency_emergency',()=>h.ctx.db.exec("CREATE VIEW public.w52kby_dependency AS SELECT * FROM public.taxonomy_roots_v2('taxonomy-client-v1','canonical-v1.0.0',true)"),{emergency:true});
 for(const mode of ['insertion_failure','partial_stage_b_failure','invalid_stored_expiry'])await capture(mode,async()=>{
  const original=h.ctx.db.exec.bind(h.ctx.db);let reached=false;
  h.ctx.db.exec=async statement=>{
   if(statement.includes('WITH stamp AS')&&statement.includes('INSERT INTO production_preview_private.testers')){
    reached=true;
    if(mode==='insertion_failure'){await original('ALTER TABLE production_preview_private.testers ADD CONSTRAINT w52kby_insertion_fault CHECK(false);');return original(statement);}
    if(mode==='invalid_stored_expiry')return original(statement.replace('make_interval(secs=>3600)','make_interval(secs=>90000)'));
    await original(statement);throw new Error('W52KBY_TEST_PARTIAL_B_FAILURE');
   }return original(statement);
  };
  const result=await deployStaged(h.ctx,seal,h.handle,h.backup);check(reached&&result.result==='ROLLED_BACK'&&result.containment?.preview_access_disabled,'PARTIAL_B_NOT_CONTAINED');return result;
 });
 await capture('rollback_before_apply',async()=>{const r=await containAndRollback(h.ctx,seal,h.ids[0]);check(r.result==='ROLLED_BACK'&&r.already_absent,'ROLLBACK_BEFORE_APPLY_NOT_SAFE');return {...r,safe_assertion:true};});
 await capture('allowlist_removal_twice',async()=>{await stageA(h.ctx,seal,h.handle,h.backup);await stageB(h.ctx,seal,h.handle);const a=await removeTester(h.ctx,seal,h.ids[0]),b=await removeTester(h.ctx,seal,h.ids[0]);check(a.removed===1&&b.removed===0,'REMOVAL_NOT_IDEMPOTENT');return {result:'PASS',safe_assertion:true};});
 await capture('bridge_rollback_twice',async()=>{await stageA(h.ctx,seal,h.handle,h.backup);await stageB(h.ctx,seal,h.handle);const a=await containAndRollback(h.ctx,seal,h.ids[0]),b=await containAndRollback(h.ctx,seal,h.ids[0]);check(a.result==='ROLLED_BACK'&&b.result==='ROLLED_BACK'&&b.already_absent,'ROLLBACK_NOT_IDEMPOTENT');return {...b,safe_assertion:true};});
 await capture('public_activation_after_stage_b',async()=>{
  const r=await deployStaged(h.ctx,seal,h.handle,h.backup,{afterB:async()=>{await h.ctx.db.exec('UPDATE public.production_taxonomy_config SET public_enabled=true');await readStageB(h.ctx,seal,h.handle);}});
  check(r.result==='ROLLED_BACK_CORE_DRIFT'&&r.containment?.observed_core_preserved,'PUBLIC_B_NOT_CONTAINED');check((await h.ctx.db.query('SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows[0].public_enabled,'PUBLIC_FLAG_WAS_REPAIRED');return r;
 });
 return results;
}
