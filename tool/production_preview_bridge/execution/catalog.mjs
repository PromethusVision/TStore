import {catalog,catalogHashes} from '../../production_taxonomy/execution/catalog.mjs';
import {hash,stable,functions} from './common.mjs';
import {semanticSecurity} from './security-semantics.mjs';
export {catalog,catalogHashes};
// No OIDs, passwords, data rows, Auth identifiers or time-dependent fields.
export async function securityMetadata(db){
 const queries={
  schemas:`SELECT nspname,pg_get_userbyid(nspowner) AS owner,nspacl::text AS acl FROM pg_namespace WHERE nspname NOT LIKE 'pg_%' AND nspname<>'information_schema' ORDER BY nspname`,
  roles:`SELECT rolname,rolsuper,rolinherit,rolcreaterole,rolcreatedb,rolcanlogin,rolreplication,rolbypassrls,rolconfig FROM pg_roles ORDER BY rolname`,
  membership:`SELECT pg_get_userbyid(roleid) AS role,pg_get_userbyid(member) AS member,pg_get_userbyid(grantor) AS grantor,admin_option,inherit_option,set_option FROM pg_auth_members ORDER BY 1,2,3`,
  defaults:`SELECT pg_get_userbyid(defaclrole) AS owner,coalesce(n.nspname,'') AS schema,defaclobjtype::text,defaclacl::text FROM pg_default_acl d LEFT JOIN pg_namespace n ON n.oid=d.defaclnamespace ORDER BY 1,2,3`,
  authFunctions:`SELECT proname,pg_get_function_identity_arguments(oid) AS arguments,pg_get_functiondef(oid) AS definition,pg_get_userbyid(proowner) AS owner,proacl::text FROM pg_proc WHERE pronamespace='auth'::regnamespace ORDER BY 1,2`,
  extensions:`SELECT extname,extversion,n.nspname,pg_get_userbyid(extowner) AS owner FROM pg_extension e JOIN pg_namespace n ON n.oid=e.extnamespace ORDER BY extname`,
  events:`SELECT evtname,evtevent,pg_get_userbyid(evtowner) AS owner,evtfoid::regprocedure::text AS function,evtenabled,evttags FROM pg_event_trigger ORDER BY evtname`,
  privateRelations:`SELECT c.relname,c.relkind::text,pg_get_userbyid(c.relowner) AS owner,c.relrowsecurity,c.relforcerowsecurity,c.relacl::text FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='production_preview_private' ORDER BY c.relname`,
  privateColumns:`SELECT column_name,ordinal_position,data_type,udt_name,is_nullable,column_default FROM information_schema.columns WHERE table_schema='production_preview_private' ORDER BY table_name,ordinal_position`,
  privateConstraints:`SELECT c.conname,pg_get_constraintdef(c.oid) AS definition FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='production_preview_private' ORDER BY conname`,
  privatePolicies:`SELECT * FROM pg_policies WHERE schemaname='production_preview_private' ORDER BY tablename,policyname`,
  privateTriggers:`SELECT tgname,pg_get_triggerdef(t.oid) AS definition FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='production_preview_private' AND NOT t.tgisinternal ORDER BY tgname`,
  privateFunctions:`SELECT proname,pg_get_function_identity_arguments(p.oid) AS arguments,pg_get_functiondef(p.oid) AS definition,pg_get_userbyid(proowner) AS owner,proacl::text FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='production_preview_private' ORDER BY 1,2`,
  privateIndexes:`SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='production_preview_private' ORDER BY 1,2`,
  columnGrants:`SELECT n.nspname,c.relname,a.attname,a.attacl::text FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN ('public','auth','production_preview_private','supabase_migrations') AND a.attnum>0 AND NOT a.attisdropped AND a.attacl IS NOT NULL ORDER BY 1,2,3`,
 };
 const result={};for(const [key,sql]of Object.entries(queries))result[key]=(await db.query(sql)).rows;
 return result;
}
export async function securityCatalog(db){const value=await semanticSecurity(db,await securityMetadata(db));return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,hash(stable(v))]));}
export async function snapshot(db){return {public:catalogHashes(await catalog(db)),security:await securityCatalog(db)};}
export async function unchanged0012Catalog(db){const data=await catalog(db);data.functions=data.functions.filter(f=>!functions.includes(f.name));return catalogHashes(data);}
export async function canonicalData(db){
 const result={};
 for(const table of ['canonical_categories','canonical_category_qualification','taxonomy_aliases','taxonomy_alias_targets','taxonomy_id_allocations','taxonomy_import_runs','taxonomy_node_relationships','production_taxonomy_config','product_canonical_assignments']){
  result[table]=hash(stable((await db.query(`SELECT to_jsonb(t) AS row FROM public.${table} t ORDER BY to_jsonb(t)::text COLLATE "C"`)).rows));
 }return result;
}
