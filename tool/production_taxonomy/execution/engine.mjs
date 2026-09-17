import { check, identifier, literal, migrationName, payload, project, stable, version } from './common.mjs';
import { catalog, catalogHashes, ledger, legacyDataHashes } from './catalog.mjs';
import { checkLegacy, contract, identity, postflight, preflight, verifyEntry } from './validators.mjs';

async function begin(db, readOnly = false) {
  // Mutations read a fresh snapshot AFTER acquiring table locks; no stale pre-lock snapshot.
  await db.exec(`BEGIN ISOLATION LEVEL ${readOnly ? 'REPEATABLE READ READ ONLY' : 'READ COMMITTED READ WRITE'}; SET LOCAL search_path=public,extensions; SET LOCAL timezone='UTC'; SET LOCAL datestyle='ISO'; SET LOCAL lock_timeout='3s'; SET LOCAL statement_timeout='120s';`);
  await identity(db);
  if (!readOnly) {
    await db.exec(`SELECT set_config('esnaftavar.w52jb.target_ref',${literal(project)},true);`);
    await db.exec(`DO $lock$ BEGIN IF NOT pg_try_advisory_xact_lock(hashtextextended('w52h-production-canonical-adapter',0)) THEN RAISE EXCEPTION 'W52JB_CONCURRENT_EXECUTOR'; END IF; END $lock$;
LOCK TABLE public.categories,public.products,public.shops,public.shop_products,public.brands,supabase_migrations.schema_migrations IN SHARE ROW EXCLUSIVE MODE;`);
  }
}
async function transaction(db, operation, readOnly = false) {
  let commitStarted = false;
  try {
    await begin(db, readOnly);
    const result = await operation();
    commitStarted = true;
    await db.exec('COMMIT;');
    return { ...result, transaction: readOnly ? 'READ_ONLY_COMPLETED' : 'COMMIT_ACKNOWLEDGED' };
  } catch (error) {
    if (!db.closed) { try { await db.exec('ROLLBACK;'); } catch { /* Connection loss rolls back an open transaction. */ } }
    if (commitStarted) throw new Error('W52JB_COMMIT_OUTCOME_UNKNOWN_RECONCILE_READ_ONLY');
    throw error;
  }
}
export async function readPreflight(db, backup) { return transaction(db, () => preflight(db, backup), true); }
export async function readPostflight(db) { return transaction(db, () => postflight(db), true); }
export async function apply0012(db, backup) {
  return transaction(db, async () => {
    const before = await preflight(db, backup);
    const application = payload();
    await db.exec(application.sql);
    const after = await postflight(db, false);
    // The data/schema and exactly this ledger row become durable together.
    await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES (${literal(version)},${literal(migrationName)},${literal([application.sql])}::text[]);`);
    after.ledger = await verifyEntry(db);
    check((await ledger(db)).length === contract().ledger_baseline.length + 1, 'LEDGER_COUNT_AFTER_APPLY');
    return { result: 'PASS', before, after, applied_only: version, payload_sha256: application.sha256 };
  });
}

export async function rollback0012(db) {
  return transaction(db, async () => {
    const expected = contract();
    const rows = await ledger(db);
    const actual = await catalog(db);
    const hasRecord = rows.some(row => row.version === version);
    if (!hasRecord) {
      check(stable(catalogHashes(actual)) === stable(expected.catalog_before), 'UNLEDGERED_OBJECTS_ROLLBACK_REFUSED');
      const counts = await checkLegacy(db);
      return { result: 'ALREADY_BASELINE_NO_OP', counts, ledger: '9_HISTORICAL_ENTRIES_UNCHANGED' };
    }
    await verifyEntry(db);
    check(stable(catalogHashes(actual)) === stable(expected.catalog_after), 'ROLLBACK_SCHEMA_DRIFT');
    check(stable(rows.filter(row => row.version !== version)) === stable(expected.ledger_baseline), 'HISTORICAL_LEDGER_DRIFT');
    const legacyBefore = await legacyDataHashes(db);
    // No CASCADE and no legacy table targets. Any external dependency aborts all drops.
    const statements = [
      ...expected.owned.functions.map(fn => ({ kind: 'function', name: fn.name, sql: `DROP FUNCTION public.${identifier(fn.name)}(${fn.arguments}) RESTRICT;` })),
      ...expected.owned.relations.map(rel => ({ kind: 'relation', name: rel.name, sql: `DROP ${rel.kind === 'v' ? 'VIEW' : rel.kind === 'S' ? 'SEQUENCE' : 'TABLE'} public.${identifier(rel.name)} RESTRICT;` })),
    ];
    for (const rel of expected.owned.relations) {
      check(actual.relations.some(item => item.name === rel.name && item.kind === rel.kind && item.owner === rel.owner), 'ROLLBACK_OWNERSHIP_MISMATCH');
    }
    for (const fn of expected.owned.functions) {
      check(actual.functions.some(item => item.name === fn.name && item.arguments === fn.arguments && item.owner === fn.owner), 'ROLLBACK_FUNCTION_OWNERSHIP_MISMATCH');
    }
    await db.exec('UPDATE public.production_taxonomy_config SET public_enabled=false,preview_enabled=false WHERE singleton_id=1;');
    // Fixed reviewed allowlist, dependency order resolved with RESTRICT inside savepoints.
    // A failure other than dependency ordering, or no progress, aborts the outer transaction.
    const commands = statements.map(item => item.sql);
    await db.exec(`DO $rollback$ DECLARE pending text[] := ${literal(commands)}::text[]; remaining text[]; command text; progress boolean;
BEGIN WHILE cardinality(pending)>0 LOOP remaining := ARRAY[]::text[]; progress := false;
 FOREACH command IN ARRAY pending LOOP BEGIN EXECUTE command; progress := true;
 EXCEPTION WHEN dependent_objects_still_exist THEN remaining := array_append(remaining,command); END; END LOOP;
 IF NOT progress THEN RAISE EXCEPTION 'W52JB_ROLLBACK_EXTERNAL_DEPENDENCY'; END IF;
 pending := remaining; END LOOP; END $rollback$;`);
    await db.exec(`DELETE FROM supabase_migrations.schema_migrations WHERE version=${literal(version)} AND name=${literal(migrationName)};`);
    check(stable(await legacyDataHashes(db)) === stable(legacyBefore), 'ROLLBACK_CHANGED_LEGACY_ROWS');
    check(stable(await ledger(db)) === stable(expected.ledger_baseline), 'ROLLBACK_LEDGER_MISMATCH');
    const counts = await checkLegacy(db);
    return { result: 'PASS', counts, objects_removed: statements.length, ledger: '0012_ONLY_REMOVED_HISTORY_PRESERVED', legacy_state: 'PASS' };
  });
}
