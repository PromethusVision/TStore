// Faults exist only inside rollback-only transactions of the isolated copy.
import {check,safeError,stable,body,version} from './common.mjs';
import {preflight} from './validators.mjs';
import {readPreflight,activate,rollback} from './executor.mjs';
import {canonicalData,snapshot} from '../production_preview_bridge/execution/catalog.mjs';
import {ledger,legacyDataHashes} from '../production_taxonomy/execution/catalog.mjs';
const fingerprint=async db=>stable({canonical:await canonicalData(db),legacy:await legacyDataHashes(db),catalog:await snapshot(db),ledger:await ledger(db)});
export async function failureTests(s,holder,seal){
 const results=[];
 async function recover(){if(holder.db.closed){holder.db=s.session();await holder.db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");}else await holder.db.exec('ROLLBACK;');}
 const initial=await fingerprint(holder.db);
 async function injected(name,sql,expected){
  let injected=false,caught,queryError;
  try{
   await holder.db.exec('BEGIN;');await holder.db.exec(sql);injected=true;
   const observed=new Proxy(holder.db,{get(target,key){
    if(key==='query')return async(...args)=>{try{return await target.query(...args);}catch(e){queryError??=e;throw e;}};
    const value=target[key];return typeof value==='function'?value.bind(target):value;
   }});
   await preflight(observed);
  }catch(e){caught=e;}finally{await recover();}
  // psql ON_ERROR_STOP closes on SQL errors; a later RESET ROLE may itself
  // report SESSION_NOT_AVAILABLE. Preserve the first query's actual SQLSTATE.
  caught=queryError??caught;
  check(injected&&caught&&expected.test(caught.message),'FAILURE_CASE_'+name.toUpperCase()+'_'+safeError(caught));
  check(await fingerprint(holder.db)===initial,'FAILURE_LEFT_STATE_'+name.toUpperCase());
  results.push({case:name,result:'PASS',safe_stop:safeError(caught),state_restored:'EXACT'});
 }
 const proxy=overrides=>new Proxy(holder.db,{get(target,key){if(key in overrides)return overrides[key];const v=target[key];return typeof v==='function'?v.bind(target):v;}});
 let identityError;try{await readPreflight(proxy({transport:{verified:true,project_ref:'wrong',kind:'ISOLATED_REAL_BACKUP_RESTORE'}}),seal);}catch(e){identityError=e;}
 check(identityError?.message==='W52JB_TARGET_TRANSPORT_IDENTITY','WRONG_IDENTITY_STOP');results.push({case:'wrong_production_identity',result:'PASS',safe_stop:safeError(identityError)});
 await injected('public_already_on','UPDATE public.production_taxonomy_config SET public_enabled=true;',/W52LA_PUBLIC_ALREADY_ON/);
 await injected('node_count_mismatch',"INSERT INTO public.canonical_categories(id,name,level,is_active,is_assignable,lifecycle_state,taxonomy_version,policy_class,professional_review_status) VALUES(gen_random_uuid(),'Local failure injection',1,false,false,'staged','canonical-v1.0.0','NORMAL','not_required');",/CANONICAL_NODE_COUNTS/);
 await injected('root_count_mismatch',"UPDATE public.canonical_categories SET level=1,parent_id=NULL WHERE id=(SELECT id FROM public.canonical_categories WHERE level=2 ORDER BY id LIMIT 1);",/CANONICAL_NODE_COUNTS/);
 await injected('mapping_mismatch',"UPDATE public.product_canonical_assignments SET canonical_path=canonical_path||' local failure' WHERE product_id=(SELECT product_id FROM public.product_canonical_assignments ORDER BY product_id LIMIT 1);",/EXACT_OWNER_MAPPING/);
 await injected('policy_gate_mismatch',"UPDATE public.canonical_category_qualification SET policy_gate='FAIL_CLOSED' WHERE category_id=(SELECT category_id FROM public.canonical_category_qualification WHERE policy_gate='PASS' ORDER BY category_id LIMIT 1);",/EXACT_QUALIFICATION_GATES/);
 await injected('legacy_contract_broken',"UPDATE public.products SET name=name||' local failure' WHERE id=(SELECT id FROM public.products ORDER BY id LIMIT 1);",/BX_LEGACY_DATA/);
 await injected('public_capability_incorrect','UPDATE public.production_taxonomy_config SET rpc_generation=2;',/W52JB_PSQL_P0001|^CAPABILITY$/);
 await injected('anonymous_write_exposure','GRANT INSERT ON public.canonical_categories TO anon;',/BX_0012_SCHEMA_DRIFT|BX_SCHEMA_SECURITY_DRIFT/);
 await injected('rls_policy_drift','ALTER TABLE public.product_canonical_assignments DISABLE ROW LEVEL SECURITY;',/BX_0012_SCHEMA_DRIFT|BX_SCHEMA_SECURITY_DRIFT/);
 await injected('active_private_preview_lease',"UPDATE production_preview_private.testers SET granted_at=now(),expires_at=now()+interval '1 hour',enabled=true;",/ACTIVE_PREVIEW_LEASE_MUST_EXPIRE_FIRST/);
 await injected('alias_data_drift',"UPDATE public.taxonomy_aliases SET alias_locator=alias_locator||'-local-failure' WHERE id=(SELECT id FROM public.taxonomy_aliases ORDER BY id LIMIT 1);",/EXACT_STRUCTURAL_DATA/);
 let reached=false,transactionError;
 const execute=holder.db.exec.bind(holder.db);
 try{await activate(proxy({exec:async sql=>{const output=await execute(sql);if(sql===body(false)){reached=true;throw Error('W52LA_INJECTED_TRANSACTION_FAILURE');}return output;}}),seal);}catch(e){transactionError=e;}
 await recover();check(reached&&transactionError?.message==='W52LA_INJECTED_TRANSACTION_FAILURE','TRANSACTION_FAILURE_INJECTION');
 check(await fingerprint(holder.db)===initial,'TRANSACTION_FAILURE_NOT_ATOMIC');results.push({case:'activation_transaction_failure_after_sql',result:'PASS',public_state_and_ledger:'EXACT_ROLLBACK'});
 let rollbackError;try{await rollback(holder.db,seal);}catch(e){rollbackError=e;}
 check(rollbackError?.message==='W52LA_EXACT_ACTIVATION_LEDGER','ROLLBACK_BEFORE_ACTIVATION');
 check(await fingerprint(holder.db)===initial,'ROLLBACK_BEFORE_CHANGED_DATA');results.push({case:'rollback_before_activation',result:'PASS',safe_stop:safeError(rollbackError)});
 let liveError;try{await activate(proxy({transport:{verified:true,project_ref:'mefhfvrgkwciubeajjeb',kind:'LIVE_PRODUCTION'}}),seal);}catch(e){liveError=e;}
 check(liveError?.message==='W52LA_READINESS_PACKAGE_LOCAL_WRITE_ONLY','LIVE_BOUNDARY');results.push({case:'live_write_transport_refused',result:'PASS',safe_stop:safeError(liveError)});
 await readPreflight(holder.db,seal);return results;
}
