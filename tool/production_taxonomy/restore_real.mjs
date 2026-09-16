import { guard, source, sql, run, container, check, stableJson, writeEvidence, safeFailure } from './real_restore_lib.mjs';

try {
  check(process.argv.length === 3 && ['--first','--second'].includes(process.argv[2]), 'RESTORE_STAGE_REQUIRED');
  const first = process.argv[2] === '--first';
  const name = first ? 'w52hr_first' : 'w52hr_second';
  const isolation = guard();
  if (first) {
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
  const exists = sql('postgres', `SELECT count(*) FROM pg_database WHERE datname='${name}';`).trim() === '1';
  if (!exists) sql('postgres', `CREATE DATABASE ${name} OWNER postgres TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';`);
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
  console.log('RESTORE_ALL_ORDINARY_OBJECTS_STARTED');
  const args=['exec','-i',container,'pg_restore','--exit-on-error','--single-transaction','--use-list=/dev/stdin','--host=/tmp','--username=supabase_admin',`--dbname=${name}`,'/backup/production.dump'];
  run(args,ordinary.join('\n')+'\n');
  console.log('RESTORE_ALL_ORDINARY_OBJECTS_COMPLETE');
  run([...args.slice(0,-1),'--use-set-session-authorization',args.at(-1)],triggers.join('\n')+'\n');
  const result = { contract:'w52h-r-real-restore-execution-v1', captured_at_utc:new Date().toISOString(), result:'PASS', database:name, isolation, empty_user_tables_before_restore:emptyTables, restore_exit_code:0, duration_ms:Date.now()-started, restore_tool:'pg_restore 17.6', original_archive_used:true, owner_and_acl_restored:true, schema_or_table_filters_used:false, toc_partition:{total:entries.length,ordinary:ordinary.length,event_triggers:triggers.length,omitted:0,reason:'Supautils event-trigger creation runs as the original owner; all other objects use standard pg_restore ownership'},source_role_attributes_and_memberships:'PASS', cluster_role_passwords_imported:false,production_database_credentials_provided:false, production_write_performed:false, baseline_validation:'PENDING' };
  writeEvidence(first ? 'w52h_r_first_restore_execution.json' : 'w52h_r_second_restore_execution.json', result);
  console.log(JSON.stringify(result));
} catch (error) { safeFailure(error); }
