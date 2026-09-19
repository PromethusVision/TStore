// Fault setup is confined to the local Harness. The actual live preflight and
// staged executor below are not mocked; their READ WRITE transactions are counted.
import {check,stable,safeError} from './common.mjs';
import {sql} from './local-harness.mjs';
import {deployStaged,readPreflight} from './engine.mjs';
import {snapshot,securityMetadata} from '../execution/catalog.mjs';
export async function securityFailures(h,seal){
 const results=[];
 const cases=[
  ['graphql_grant_removed','REVOKE USAGE ON SCHEMA graphql FROM anon;','CA_GRAPHQL_GRANTS'],
  ['graphql_grant_added','GRANT CREATE ON SCHEMA graphql_public TO anon;','CA_GRAPHQL_GRANTS'],
  ['graphql_grant_option','REVOKE GRANT OPTION FOR USAGE ON SCHEMA graphql FROM postgres;','CA_GRAPHQL_GRANTS'],
  // Deliberate regression of the reconstructed local owner; no live connection.
  ['extension_owner',"UPDATE pg_extension SET extowner=(SELECT oid FROM pg_roles WHERE rolname='supabase_admin') WHERE extname='pgcrypto';",'CA_EXTENSION_OWNER'],
  ['read_only_default','ALTER ROLE supabase_read_only_user SET default_transaction_read_only=off;','CA_READ_ONLY_ROLE_DEFAULT','ALTER ROLE supabase_read_only_user SET default_transaction_read_only=on;'],
  ['read_only_database_override','ALTER ROLE supabase_read_only_user IN DATABASE postgres SET default_transaction_read_only=off;','CA_DATABASE_ROLE_OVERRIDE'],
  ['logging_effective_changed',"ALTER ROLE supabase_auth_admin SET log_statement='all';",'CA_LOGGING_EFFECTIVE_VALUE','ALTER ROLE supabase_auth_admin RESET log_statement;'],
  ['rls_disabled','ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;','BX_0012_SCHEMA_DRIFT'],
  ['policy_changed','CREATE POLICY w52kca_fault ON public.products FOR SELECT TO anon USING(true);','BX_0012_SCHEMA_DRIFT'],
  ['canonical_write_grant','GRANT INSERT ON public.canonical_categories TO anon;','BX_0012_SCHEMA_DRIFT'],
  ['rpc_grant','REVOKE EXECUTE ON FUNCTION public.production_taxonomy_roots_v1(text,text,boolean) FROM anon;','BX_0012_SCHEMA_DRIFT'],
  ['rpc_signature','ALTER FUNCTION public.production_taxonomy_roots_v1(text,text,boolean) RENAME TO w52kca_signature_fault;','BX_0012_SCHEMA_DRIFT'],
  ['security_definer','ALTER FUNCTION public.production_taxonomy_roots_v1(text,text,boolean) SECURITY INVOKER;','BX_0012_SCHEMA_DRIFT'],
  ['search_path','ALTER FUNCTION public.production_taxonomy_roots_v1(text,text,boolean) SET search_path=public;','BX_0012_SCHEMA_DRIFT'],
 ];
 for(const [name,injection,code,cleanup] of cases){
  h.failedCase=name;await h.reset();await readPreflight(h.ctx,seal,h.handle);sql('postgres',injection);
  let writes=0,payloads=0,error;const exec=h.ctx.db.exec.bind(h.ctx.db);
  h.ctx.db.exec=async text=>{if(/BEGIN ISOLATION LEVEL READ COMMITTED READ WRITE/.test(text))writes++;if(text.includes('CREATE SCHEMA production_preview_private'))payloads++;return exec(text);};
  try{await deployStaged(h.ctx,seal,h.handle,h.backup);}catch(e){error=safeError(e);}
  try{check(error==='W52JB_'+code,'CA_EXPECTED_DRIFT_FAILURE_'+name.toUpperCase());check(writes===0&&payloads===0,'CA_DRIFT_REACHED_WRITE');const denial=await h.assertNoAccess();results.push({case:name,result:'PASS',safe_error:error,executor_write_capable_transactions:writes,bridge_payloads:payloads,active_preview_authorizations:denial.active_authorizations});}
  finally{if(cleanup)sql('postgres',cleanup);}
  console.log('CA_MATERIAL_DRIFT_PASS: '+name);
 }
 const benign=[
  ['acl_entry_order','REVOKE EXECUTE ON FUNCTION auth.jwt() FROM postgres; GRANT EXECUTE ON FUNCTION auth.jwt() TO postgres;'],
  ['config_key_order',"ALTER ROLE authenticator RESET lock_timeout; ALTER ROLE authenticator SET lock_timeout='8s';"],
  ['timeout_units',"ALTER ROLE supabase_auth_admin SET idle_in_transaction_session_timeout='60000';","ALTER ROLE supabase_auth_admin SET idle_in_transaction_session_timeout='1min';"],
  ['explicit_inherited_effective',"ALTER ROLE supabase_auth_admin SET log_statement=none;",'ALTER ROLE supabase_auth_admin RESET log_statement;'],
 ];
 for(const [name,injection,cleanup] of benign){
  h.failedCase=name;await h.reset();const before=await snapshot(h.ctx.db),raw=await securityMetadata(h.ctx.db);sql('postgres',injection);
  try{check(stable(raw)!==stable(await securityMetadata(h.ctx.db)),'CA_BENIGN_INJECTION_WAS_NOOP');check(stable(before)===stable(await snapshot(h.ctx.db)),'CA_BENIGN_SEMANTICS_CHANGED');await readPreflight(h.ctx,seal,h.handle);await readPreflight(h.ctx,seal,h.handle);const denial=await h.assertNoAccess();results.push({case:name,result:'PASS',preflight:'PASS_TWICE',deterministic_semantics:true,active_preview_authorizations:denial.active_authorizations});}
  finally{if(cleanup)sql('postgres',cleanup);}
  console.log('CA_BENIGN_VARIANCE_PASS: '+name);
 }
 h.failedCase=null;return results;
}
