// Validators issue SELECT and session-role commands only. CLI wraps them READ ONLY.
import { check, hash, json, payload, project, stable, version, migrationName } from './common.mjs';
import { catalog, catalogHashes, ledger, ledgerSchema, legacyDataHashes } from './catalog.mjs';
import { integrity, legacyQueries, canonicalQueries } from '../real_contract_checks.mjs';

export const contract = () => json('tool/production_taxonomy/execution/contract.json');
export async function identity(db) {
  check(db.transport?.verified === true && db.transport.project_ref === project, 'TARGET_TRANSPORT_IDENTITY');
  const row = (await db.query(`SELECT current_database() AS database,session_user::text AS role,current_setting('server_version') AS server_version`)).rows[0];
  check(row.database === 'postgres' && row.role === 'postgres' && row.server_version === '17.6', 'DATABASE_IDENTITY');
  return { project_ref: project, ...row, transport: db.transport.kind };
}
export async function legacyContract(db) {
  const result = {};
  for (const role of ['anon', 'authenticated']) result[role] = await legacyQueries(db, role);
  check(stable(result) === stable(contract().legacy_queries), 'LEGACY_SQL_CONTRACT');
  return result;
}
export async function checkLegacy(db, state = 'baseline') {
  const expected = contract();
  const counts = await integrity(db, false);
  check(stable(await legacyDataHashes(db)) === stable(expected.legacy_data), 'LEGACY_DATA_DRIFT');
  check(stable(await ledgerSchema(db)) === stable(expected.ledger_schema), 'LEDGER_SCHEMA_DRIFT');
  const rows = await ledger(db);
  check(stable(rows.filter(row => row.version !== version)) === stable(expected.ledger_baseline), 'HISTORICAL_LEDGER_DRIFT');
  const hashes = catalogHashes(await catalog(db));
  check(stable(hashes) === stable(state === 'baseline' ? expected.catalog_before : expected.catalog_after), 'SCHEMA_FINGERPRINT');
  await legacyContract(db);
  return counts;
}
export async function preflight(db, backup) {
  const target = await identity(db);
  check(backup?.verified === true && backup.project_ref === project, 'FRESH_BACKUP_REQUIRED');
  const age = Date.now() - Date.parse(backup.completed_at_utc);
  check(age >= -30000 && age <= 900000, 'BACKUP_NOT_FRESH');
  const rows = await ledger(db);
  check(!rows.some(row => row.version === version), '0012_ALREADY_APPLIED');
  check(!rows.some(row => /^001[01]_/.test(row.name) || /001[01]00$/.test(row.version)), 'UNEXPECTED_0010_0011');
  const present = (await db.query(`SELECT to_regclass('public.canonical_categories') IS NOT NULL AS present`)).rows[0].present;
  check(!present, 'UNLEDGERED_CANONICAL_OBJECTS');
  const counts = await checkLegacy(db);
  return { result: 'PASS', target, counts, mapping: '20/20_FROZEN_PACKAGE_AND_LEGACY_REFERENCES', ledger: '9_HISTORICAL_ENTRIES_UNCHANGED',
    schema_fingerprint: 'PASS', legacy_sql_contract: 'PASS', fresh_backup: { sha256: backup.sha256, size_bytes: backup.size_bytes, completed_at_utc: backup.completed_at_utc }, captured_at_utc: new Date().toISOString() };
}
export async function verifyEntry(db) {
  const rows = (await db.query('SELECT version::text,name,statements FROM supabase_migrations.schema_migrations WHERE version=$1', [version])).rows;
  check(rows.length === 1 && rows[0].name === migrationName && rows[0].statements?.length === 1 &&
    hash(rows[0].statements[0]) === payload().sha256, '0012_LEDGER_ENTRY_MISMATCH');
  return { version, name: migrationName, statements: 1, payload_sha256: payload().sha256 };
}
export async function postflight(db, withLedger = true) {
  const target = await identity(db);
  await checkLegacy(db, 'applied');
  const counts = await integrity(db, true);
  const flags = (await db.query(`SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1`)).rows;
  check(flags.length === 1 && flags[0].public_enabled === false && flags[0].preview_enabled === false, 'PUBLIC_ACTIVATION_FORBIDDEN');
  const staged = (await db.query(`SELECT count(*)::int AS n FROM public.canonical_categories WHERE is_active OR is_assignable OR lifecycle_state<>'staged'`)).rows[0].n;
  check(staged === 0, 'CANONICAL_MUST_REMAIN_STAGED');
  const hierarchy = (await db.query(`WITH RECURSIVE tree AS (SELECT id,1 AS depth FROM public.canonical_categories WHERE parent_id IS NULL UNION ALL SELECT c.id,t.depth+1 FROM public.canonical_categories c JOIN tree t ON c.parent_id=t.id) SELECT count(*)::int AS nodes,max(depth)::int AS max_depth FROM tree`)).rows[0];
  check(hierarchy.nodes === 1563 && hierarchy.max_depth === 4, 'FULL_STAGED_HIERARCHY');
  const writeGrants = (await db.query(`SELECT count(*)::int AS n FROM pg_class c CROSS JOIN (VALUES ('anon'),('authenticated')) r(role) WHERE c.relnamespace='public'::regnamespace AND c.relname IN ('canonical_categories','canonical_category_qualification','taxonomy_aliases','taxonomy_alias_targets','taxonomy_id_allocations','taxonomy_import_runs','taxonomy_node_relationships','production_taxonomy_config','product_canonical_assignments') AND (has_table_privilege(r.role,c.oid,'INSERT') OR has_table_privilege(r.role,c.oid,'UPDATE') OR has_table_privilege(r.role,c.oid,'DELETE'))`)).rows[0].n;
  check(writeGrants === 0, 'CANONICAL_CLIENT_WRITE_GRANT');
  const canonical = {};
  for (const role of ['anon', 'authenticated']) {
    await db.exec(`SET ROLE ${role};`);
    try {
      canonical[role] = await canonicalQueries(db, false);
      check((await db.query('SELECT count(*)::int AS n FROM public.product_canonical_assignments')).rows[0].n === 0, 'STAGED_ASSIGNMENT_LEAK');
    } finally { await db.exec('RESET ROLE;'); }
  }
  return { result: 'PASS', target, counts, hierarchy, client_write_grants: writeGrants, canonical_staged_contract: canonical, public_activation: false,
    policy_review_gates: 'PASS_ALL_20_STAGED_INCLUDING_6_REVIEW_GATED', legacy_sql_contract: 'PASS',
    rls_acl_schema_fingerprint: 'PASS', ledger: withLedger ? await verifyEntry(db) : 'PENDING_IN_SAME_TRANSACTION' };
}
