// W52K-CA: metadata only. No mutation or transport. ACL parsing belongs to PG.
import {check,stable,json} from './common.mjs';
export const baselinePath='tool/production_preview_bridge/execution/security-baseline.json';
export const reviewed=()=>json(baselinePath);
export const order=rows=>[...rows].sort((a,b)=>stable(a)<stable(b)?-1:stable(a)>stable(b)?1:0);
const loggingRoles=['supabase_admin','supabase_auth_admin','supabase_storage_admin'];
export const semanticQueries={
 schema:`SELECT n.nspname AS schema,CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END AS grantee,pg_get_userbyid(a.grantor) AS grantor,a.privilege_type,a.is_grantable FROM pg_namespace n CROSS JOIN LATERAL aclexplode(coalesce(n.nspacl,acldefault('n'::"char",n.nspowner))) a WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname<>'information_schema' ORDER BY 1,2,3,4,5`,
 defaults:`SELECT pg_get_userbyid(d.defaclrole) AS owner,coalesce(n.nspname,'') AS schema,d.defaclobjtype::text AS object_type,CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END AS grantee,pg_get_userbyid(a.grantor) AS grantor,a.privilege_type,a.is_grantable FROM pg_default_acl d LEFT JOIN pg_namespace n ON n.oid=d.defaclnamespace CROSS JOIN LATERAL aclexplode(d.defaclacl) a ORDER BY 1,2,3,4,5,6,7`,
 functions:`SELECT n.nspname AS schema,p.proname AS name,pg_get_function_identity_arguments(p.oid) AS arguments,CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END AS grantee,pg_get_userbyid(a.grantor) AS grantor,a.privilege_type,a.is_grantable FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace CROSS JOIN LATERAL aclexplode(coalesce(p.proacl,acldefault('f'::"char",p.proowner))) a WHERE n.nspname='auth' ORDER BY 1,2,3,4,5,6,7`,
};
// Database and role-in-database overrides take precedence on login. Never infer
// an inherited value from an overridden admin session or from SET ROLE.
export const effectiveQueries={
 logging:`SELECT setting,reset_val,source FROM pg_settings WHERE name='log_statement'`,
 overrides:`SELECT coalesce(d.datname,'*') AS database,coalesce(r.rolname,'*') AS role,s.setconfig FROM pg_db_role_setting s LEFT JOIN pg_database d ON d.oid=s.setdatabase LEFT JOIN pg_roles r ON r.oid=s.setrole WHERE s.setdatabase<>0 AND (s.setrole=0 OR r.rolname IN ('supabase_admin','supabase_auth_admin','supabase_storage_admin','supabase_read_only_user')) ORDER BY 1,2`,
};
export function config(values){
 const fields=new Map();
 for(const value of values??[]){const split=value.indexOf('=');check(split>0,'CA_ROLE_CONFIG_FORMAT');const key=value.slice(0,split);check(!fields.has(key),'CA_DUPLICATE_ROLE_SETTING');fields.set(key,value.slice(split+1));}
 return fields;
}
export function normalizeRole(row,effective){
 const fields=config(row.rolconfig);
 if(row.rolname==='supabase_auth_admin'&&fields.has('idle_in_transaction_session_timeout')){
  const match=/^(\d+)(ms|s|min|h)?$/.exec(fields.get('idle_in_transaction_session_timeout'));
  check(match,'CA_TIMEOUT_FORMAT');const value=Number(match[1])*({ms:1,s:1000,min:60000,h:3600000}[match[2]??'ms']);
  check(Number.isSafeInteger(value),'CA_TIMEOUT_RANGE');fields.set('idle_in_transaction_session_timeout',String(value));
 }
 if(loggingRoles.includes(row.rolname)){
  const value=fields.get('log_statement');
  check(value===undefined||value==='none','CA_LOGGING_EFFECTIVE_VALUE');
  if(value===undefined){const s=effective.logging;check(s.length===1&&s[0].setting==='none'&&s[0].reset_val==='none'&&['default','configuration file','command line'].includes(s[0].source),'CA_INHERITED_LOGGING_NOT_PROVEN');}
  // Canonical form retains the asserted EFFECTIVE value, never drops the check.
  fields.set('log_statement','none');
 }
 return {...row,rolconfig:[...fields].sort(([a],[b])=>a<b?-1:1).map(([k,v])=>k+'='+v)};
}
export function normalizeSecurity(raw,acl,effective){
 check(Array.isArray(effective.overrides),'CA_EFFECTIVE_SETTINGS_METADATA');
 for(const row of effective.overrides){const fields=config(row.setconfig);check(!fields.has('log_statement')&&!fields.has('default_transaction_read_only'),'CA_DATABASE_ROLE_OVERRIDE');}
 const value=structuredClone(raw);
 value.roles=value.roles.map(row=>normalizeRole(row,effective));
 value.schemas=value.schemas.map(row=>({...row,acl:order(acl.schema.filter(a=>a.schema===row.nspname))}));
 // Retain owner/schema/object type rows even for empty ACLs.
 value.defaults=value.defaults.map(row=>({...row,defaclacl:order(acl.defaults.filter(a=>a.owner===row.owner&&a.schema===row.schema&&a.object_type===row.defaclobjtype))}));
 value.authFunctions=value.authFunctions.map(row=>({...row,proacl:order(acl.functions.filter(a=>a.schema==='auth'&&a.name===row.proname&&a.arguments===row.arguments))}));
 return value;
}
export function assertPlatform(value){
 const spec=reviewed();
 for(const schema of spec.schemas){const actual=value.schemas.filter(r=>r.nspname===schema.nspname);check(actual.length===1&&stable(actual[0])===stable(schema),'CA_GRAPHQL_GRANTS');}
 for(const extension of spec.extensions){const actual=value.extensions.filter(r=>r.extname===extension.extname);check(actual.length===1&&stable(actual[0])===stable(extension),'CA_EXTENSION_OWNER');}
 const rows=value.roles.filter(r=>r.rolname===spec.read_only_role.name);
 check(rows.length===1&&config(rows[0].rolconfig).get('default_transaction_read_only')==='on','CA_READ_ONLY_ROLE_DEFAULT');
 return {graphql_grants:'PASS',extension_owners:'PASS',read_only_default:'PASS',effective_role_overrides:'CHECKED'};
}
export async function semanticSecurity(db,raw){
 const acl={},effective={};
 for(const [key,sql] of Object.entries(semanticQueries))acl[key]=(await db.query(sql)).rows;
 for(const [key,sql] of Object.entries(effectiveQueries))effective[key]=(await db.query(sql)).rows;
 const value=normalizeSecurity(raw,acl,effective);assertPlatform(value);return value;
}
