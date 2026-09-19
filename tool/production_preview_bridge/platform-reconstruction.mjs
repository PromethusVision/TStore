// LOCAL ONLY. Never imported by the live CLI. All writes require the existing
// pinned-image/network-none/read-only-backup guard.
import {guard,sql,run,container} from './local.mjs';
import {check,literal} from './execution/common.mjs';
import {reviewed} from './execution/security-semantics.mjs';
export function reconstructPlatform(){
 guard();const spec=reviewed();
 const actual=JSON.parse(sql('postgres',"SELECT json_agg(json_build_object('extname',e.extname,'extversion',e.extversion,'nspname',n.nspname,'owner',pg_get_userbyid(e.extowner)) ORDER BY e.extname) FROM pg_extension e JOIN pg_namespace n ON n.oid=e.extnamespace WHERE e.extname IN ('pg_stat_statements','pgcrypto','uuid-ossp');"));
 // Fail closed before the explicit local ownership reconstruction if the frozen
 // restore has anything other than the independently observed three gaps.
 for(const e of spec.extensions){const row=actual.find(r=>r.extname===e.extname);check(row&&row.extversion===e.extversion&&row.nspname===e.nspname&&row.owner==='supabase_admin'&&e.owner==='postgres','CA_EXTENSION_RECONSTRUCTION_SOURCE');}
 check(actual.length===3&&spec.extensions.length===3,'CA_EXTENSION_RECONSTRUCTION_SCOPE');
 // PG17 has no ALTER EXTENSION OWNER. Supautils creates these as its privileged
 // role even with pg_restore --role=postgres. Reproduce ONLY the reviewed owner
 // and its ownership dependency inside this disposable cluster. The archive and
 // extension member objects are untouched; no role is promoted to SUPERUSER.
 sql('postgres',`BEGIN;
  UPDATE pg_catalog.pg_extension SET extowner='postgres'::regrole WHERE extname IN ('pg_stat_statements','pgcrypto','uuid-ossp') AND extowner='supabase_admin'::regrole;
  UPDATE pg_catalog.pg_shdepend d SET refobjid='postgres'::regrole WHERE d.dbid=(SELECT oid FROM pg_database WHERE datname=current_database()) AND d.classid='pg_extension'::regclass AND d.objid IN (SELECT oid FROM pg_extension WHERE extname IN ('pg_stat_statements','pgcrypto','uuid-ossp')) AND d.objsubid=0 AND d.refclassid='pg_authid'::regclass AND d.deptype='o';
  INSERT INTO pg_catalog.pg_shdepend(dbid,classid,objid,objsubid,refclassid,refobjid,deptype)
   SELECT (SELECT oid FROM pg_database WHERE datname=current_database()),'pg_extension'::regclass,e.oid,0,'pg_authid'::regclass,'postgres'::regrole,'o' FROM pg_extension e
   WHERE e.extname IN ('pg_stat_statements','pgcrypto','uuid-ossp') AND NOT EXISTS(SELECT 1 FROM pg_shdepend d WHERE d.dbid=(SELECT oid FROM pg_database WHERE datname=current_database()) AND d.classid='pg_extension'::regclass AND d.objid=e.oid AND d.deptype='o');
 COMMIT;`);
 for(const schema of spec.schemas){
  check(['graphql','graphql_public'].includes(schema.nspname)&&schema.owner==='supabase_admin','CA_SCHEMA_RECONSTRUCTION_SCOPE');
  sql('postgres',`GRANT USAGE ON SCHEMA ${schema.nspname} TO anon,authenticated,service_role; GRANT USAGE ON SCHEMA ${schema.nspname} TO postgres WITH GRANT OPTION;`);
 }
 check(spec.read_only_role.name==='supabase_read_only_user','CA_ROLE_RECONSTRUCTION_SCOPE');
 sql('postgres','ALTER ROLE supabase_read_only_user SET default_transaction_read_only=on;');
 const roles=[];
 for(const role of ['supabase_admin','supabase_auth_admin','supabase_storage_admin','supabase_read_only_user']){
  const raw=run(['exec',container,'psql','-h','/tmp','-U',role,'-d','postgres','-X','-q','-A','-t','-w','-v','ON_ERROR_STOP=1','-c',"SELECT json_build_object('log_statement',current_setting('log_statement'),'default_transaction_read_only',current_setting('default_transaction_read_only'));" ]);
  const actual=JSON.parse(raw);check(actual.log_statement==='none','CA_LOCAL_EFFECTIVE_LOGGING');
  if(role==='supabase_read_only_user')check(actual.default_transaction_read_only==='on','CA_LOCAL_EFFECTIVE_READ_ONLY');
  roles.push({role,...actual});
 }
 const ownershipDependencies=Number(sql('postgres',"SELECT count(*) FROM pg_shdepend d JOIN pg_extension e ON e.oid=d.objid WHERE d.dbid=(SELECT oid FROM pg_database WHERE datname=current_database()) AND d.classid='pg_extension'::regclass AND d.refclassid='pg_authid'::regclass AND d.refobjid='postgres'::regrole AND d.deptype='o' AND e.extname IN ('pg_stat_statements','pgcrypto','uuid-ossp');"));
 check(ownershipDependencies===3,'CA_EXTENSION_OWNER_DEPENDENCIES');
 return {result:'PASS',scope:'ISOLATED_PLATFORM_METADATA_RECONSTRUCTION',properties:6,extension_ownership_dependencies:ownershipDependencies,roles};
}
