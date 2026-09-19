import { guard, source, sql, run, container, stableJson } from './local.mjs';
import { check } from '../production_taxonomy/execution/common.mjs';
import {reconstructPlatform} from './platform-reconstruction.mjs';
export async function restore({reconcileSecurity=false}={}) {
  const isolation = guard();
  const name = 'postgres';
  {
    const existing = JSON.parse(sql('postgres', "SELECT json_agg(rolname ORDER BY rolname) FROM pg_roles WHERE rolname !~ '^pg_';"));
    const freshRoles = stableJson(existing) === stableJson(['supabase_admin']);
    check(freshRoles || stableJson(existing) === stableJson(source.roles.map(r=>r.name)), 'EXPECTED_CLUSTER_ROLES_REQUIRED');
    const roleSql = source.roles.map(r => `${r.name === 'supabase_admin' ? 'ALTER' : 'CREATE'} ROLE ${r.name} WITH ` + ['superuser','inherit','createrole','createdb','login','replication','bypassrls'].map(k => (r[k] ? '' : 'NO') + k.toUpperCase()).join(' ') + ';').join('\n');
    const membershipSql = source.memberships.map(m => `GRANT ${m.role} TO ${m.member} WITH ADMIN ${m.admin}, INHERIT ${m.inherit}, SET ${m.set};`).join('\n');
    if (freshRoles) sql('postgres', roleSql + '\n' + membershipSql);
  }
  const actualRoles = JSON.parse(sql('postgres', "SELECT jsonb_agg(jsonb_build_object('name',rolname,'superuser',rolsuper,'inherit',rolinherit,'createrole',rolcreaterole,'createdb',rolcreatedb,'login',rolcanlogin,'replication',rolreplication,'bypassrls',rolbypassrls) ORDER BY rolname) FROM pg_roles WHERE rolname !~ '^pg_';"));
  check(stableJson(actualRoles) === stableJson(source.roles), 'ROLE_ATTRIBUTES_MATCH_SOURCE');
  const actualMemberships = JSON.parse(sql('postgres', "SELECT jsonb_agg(jsonb_build_object('role',r.rolname,'member',m.rolname,'admin',a.admin_option,'inherit',a.inherit_option,'set',a.set_option) ORDER BY r.rolname,m.rolname) FROM pg_auth_members a JOIN pg_roles r ON r.oid=a.roleid JOIN pg_roles m ON m.oid=a.member WHERE m.rolname !~ '^pg_';"));
  check(stableJson(actualMemberships) === stableJson(source.memberships), 'ROLE_MEMBERSHIPS_MATCH_SOURCE');
  // Reproduce source Supabase behavior; do not promote postgres to SUPERUSER.
  const quote = s => "'" + s.replaceAll("'", "''") + "'";
  for (const [key,value] of Object.entries(source.runtime.settings)) {
    check(/^(supautils\.[a-z_]+|session_preload_libraries)$/.test(key), 'RUNTIME_SETTING_ALLOWLIST');
    sql('postgres', `ALTER SYSTEM SET ${key} TO ${quote(value)};`);
  }
  sql('postgres', 'SELECT pg_reload_conf();');
  for (const {role,setting} of source.runtime.role_settings) {
    const split = setting.indexOf('='); const key=setting.slice(0,split); const value=setting.slice(split+1);
    check(source.roles.some(r=>r.name===role) && /^[a-z_]+$/.test(key), 'SOURCE_ROLE_SETTING');
    // set_config preserves list-valued settings such as search_path without
    // treating the whole comma-separated list as one quoted identifier.
    sql('postgres', `SELECT set_config(${quote(key)},${quote(value)},false); ALTER ROLE ${role} SET ${key} FROM CURRENT;`);
  }
  sql('template1', 'DROP DATABASE postgres;');
  const exists = sql('template1', `SELECT count(*) FROM pg_database WHERE datname='${name}';`).trim() === '1';
  if (!exists) {
    // LC_COLLATE/LC_CTYPE alone did not preserve the source ICU provider.
    // Recover the exact declaration from the hash-pinned real archive.
    const schema = run(['exec',container,'pg_restore','--create','--schema-only','--file=-','/backup/production.dump']);
    const declarations = schema.split(/\r?\n/).filter(line => line.startsWith('CREATE DATABASE '));
    const expected = "CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';";
    check(declarations.length === 1 && declarations[0] === expected, 'SOURCE_DATABASE_LOCALE_METADATA');
    sql('template1', declarations[0] + '\nALTER DATABASE postgres OWNER TO postgres;');
  }
  const emptyTables = Number(sql(name, "SELECT count(*) FROM pg_tables WHERE schemaname NOT IN ('pg_catalog','information_schema');").trim());
  check(emptyTables === 0, 'FRESH_EMPTY_DATABASE_REQUIRED');
  check(Number(sql(name,"SELECT count(*) FROM pg_namespace WHERE nspname NOT IN ('pg_catalog','information_schema','public') AND nspname !~ '^pg_toast';")) === 0, 'EMPTY_SCHEMA_REQUIRED');
  const started = Date.now();
  // Restore every TOC entry exactly once. Supautils requires event triggers to be
  // created by their original owners; other objects use normal pg_restore ownership.
  const toc = run(['exec',container,'pg_restore','--list','/backup/production.dump']);
  const entries = toc.split(/\r?\n/).filter(l => /^\d+;/.test(l));
  const triggers = entries.filter(l => / EVENT TRIGGER /.test(l));
  const ordinary = entries.filter(l => !/ EVENT TRIGGER /.test(l));
  check(toc.includes('TOC Entries: 965') && entries.length === 958 && triggers.length === 7 && ordinary.length + triggers.length === entries.length && new Set(entries).size === entries.length, 'COMPLETE_TOC_PARTITION');
  console.log('LOCAL_RESTORE_STARTED');
  const args=['exec','-i',container,'pg_restore','--exit-on-error','--single-transaction','--use-list=/dev/stdin','--host=/tmp','--username=supabase_admin',`--dbname=${name}`,'/backup/production.dump'];
  run(args,ordinary.join('\n')+'\n');
  console.log('LOCAL_RESTORE_OBJECTS_COMPLETE');
  run([...args.slice(0,-1),'--use-set-session-authorization',args.at(-1)],triggers.join('\n')+'\n');
  const reconstruction=reconcileSecurity?reconstructPlatform():null;
  return {result:'PASS', isolation, toc_entries:entries.length, omitted:0, restored_owner_acl:true, source_roles_memberships:'PASS', reconstruction, duration_ms:Date.now()-started};
}
