#!/usr/bin/env node
import { cp, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { compileToDirectory } from './compiler.mjs';
import {
  buildPrecheckSnapshot, check, generateSyntheticPackage, loadPackage, sha256,
  stableJson, validatePackage, validatePrecheckSnapshot,
} from './lib.mjs';
import {
  applyArtifact, createEmptyApplicationBaseline, loadArtifacts, openPGlite,
  rollbackArtifact, scalar, setLocalGuard,
} from './local_database.mjs';

function argument(name, fallback = undefined) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

function clonePackage(pkg) {
  return JSON.parse(JSON.stringify(pkg));
}

async function expectedFailure(name, operation) {
  try {
    await operation();
  } catch (error) {
    return { name, result: 'PASS', rejected_with: String(error.message).slice(0, 160) };
  }
  throw new Error(`FAILURE_CASE_DID_NOT_FAIL_CLOSED:${name}`);
}

async function packageFailureMatrix(pkg, packageDirectory, temporaryRoot) {
  const failures = [];
  const mutation = async (name, apply) => failures.push(await expectedFailure(name, () => {
    const candidate = clonePackage(pkg);
    apply(candidate);
    return validatePackage(candidate);
  }));
  await mutation('bad_uuid', (candidate) => { candidate.tables['categories.csv'][0].CATEGORY_ID = 'not-a-uuid'; });
  await mutation('duplicate_uuid', (candidate) => {
    candidate.tables['categories.csv'][1].CATEGORY_ID = candidate.tables['categories.csv'][0].CATEGORY_ID;
  });
  await mutation('missing_parent', (candidate) => {
    candidate.tables['categories.csv'].find((row) => row.LEVEL === '2').PARENT_CATEGORY_ID = '00000000-0000-4000-8000-000000000001';
  });
  await mutation('cycle', (candidate) => {
    const parent = candidate.tables['categories.csv'].find((row) => row.LEVEL === '2');
    const child = candidate.tables['categories.csv'].find((row) => row.PARENT_CATEGORY_ID === parent.CATEGORY_ID);
    parent.PARENT_CATEGORY_ID = child.CATEGORY_ID;
  });
  await mutation('l5', (candidate) => { candidate.tables['categories.csv'].at(-1).LEVEL = '5'; });
  await mutation('policy_invalid', (candidate) => { candidate.tables['activation.csv'][0].POLICY_CLASS = 'UNREVIEWED_MAGIC'; });
  await mutation('alias_duplicate', (candidate) => {
    candidate.tables['aliases.csv'][1].ALIAS_ID = candidate.tables['aliases.csv'][0].ALIAS_ID;
  });
  await mutation('ambiguous_split_missing_edges', (candidate) => {
    const alias = candidate.tables['aliases.csv'].find((row) => row.RESOLUTION_STATE === 'AMBIGUOUS');
    let kept = false;
    candidate.tables['alias_targets.csv'] = candidate.tables['alias_targets.csv'].filter((row) => {
      if (row.ALIAS_ID !== alias.ALIAS_ID) return true;
      if (!kept) { kept = true; return true; }
      return false;
    });
  });
  await mutation('ambiguous_split_without_target', (candidate) => {
    const relationship = candidate.tables['relationships.csv']
      .find((row) => row.ACTION === 'SPLIT');
    relationship.SUCCESSOR_CATEGORY_ID = '';
  });
  const checksumDirectory = join(temporaryRoot, 'checksum-mismatch');
  await cp(packageDirectory, checksumDirectory, { recursive: true });
  const categoriesPath = join(checksumDirectory, 'categories.csv');
  await writeFile(categoriesPath, `${await readFile(categoriesPath, 'utf8')}\n`, 'utf8');
  failures.push(await expectedFailure('checksum_mismatch', () => loadPackage(checksumDirectory)));
  const frozenShaDirectory = join(temporaryRoot, 'frozen-package-sha-mismatch');
  await cp(packageDirectory, frozenShaDirectory, { recursive: true });
  const frozenManifestPath = join(frozenShaDirectory, 'package_manifest.json');
  const frozenManifest = JSON.parse(await readFile(frozenManifestPath, 'utf8'));
  frozenManifest.source_package.upstream_overall_sha256 = '0'.repeat(64);
  await writeFile(frozenManifestPath, `${JSON.stringify(frozenManifest, null, 2)}\n`, 'utf8');
  failures.push(await expectedFailure(
    'frozen_package_sha_mismatch',
    () => loadPackage(frozenShaDirectory),
  ));
  failures.push(await expectedFailure('unexpected_non_empty_target', () => {
    const snapshot = buildPrecheckSnapshot(pkg);
    snapshot.counts.categories = 1;
    return validatePrecheckSnapshot(snapshot, pkg);
  }));
  failures.push(await expectedFailure('migration_history_mismatch', () => {
    const snapshot = buildPrecheckSnapshot(pkg);
    snapshot.migration_history_sha256 = '0'.repeat(64);
    return validatePrecheckSnapshot(snapshot, pkg);
  }));
  failures.push(await expectedFailure('schema_hash_mismatch', () => {
    const snapshot = buildPrecheckSnapshot(pkg);
    snapshot.schema_contract_sha256 = 'f'.repeat(64);
    return validatePrecheckSnapshot(snapshot, pkg);
  }));
  await mutation('planning_key_as_runtime_uuid', (candidate) => {
    candidate.tables['categories.csv'][0].CATEGORY_ID = candidate.tables['categories.csv'][0].PLANNING_KEY;
  });
  await mutation('assignable_container', (candidate) => {
    const container = candidate.tables['categories.csv'].find((row) => row.LEAF_YN === 'NO');
    candidate.tables['activation.csv'].find((row) => row.CATEGORY_ID === container.CATEGORY_ID).IS_ASSIGNABLE = 'YES';
  });
  return failures;
}

async function artifactFailureMatrix(artifactDirectory, temporaryRoot) {
  const tamperedDirectory = join(temporaryRoot, 'active-artifact-sha-mismatch');
  await cp(artifactDirectory, tamperedDirectory, { recursive: true });
  const forwardPath = join(tamperedDirectory, 'forward.sql');
  await writeFile(forwardPath, `${await readFile(forwardPath, 'utf8')}\n`, 'utf8');
  return [await expectedFailure(
    'active_artifact_sha_mismatch',
    () => loadArtifacts(tamperedDirectory),
  )];
}

async function ledgerFixture(
  name, pgliteRoot, pkg, forwardSql, rollbackSql, mutate, expectedError = null,
) {
  const database = await openPGlite(pgliteRoot);
  try {
    await createEmptyApplicationBaseline(database, pkg);
    if (mutate) await mutate(database, pkg.manifest.runtime_contract.migration_ledger);
    if (expectedError === null) {
      await applyArtifact(database, pkg, forwardSql);
      await rollbackArtifact(database, pkg, rollbackSql);
      return { name, result: 'PASS', accepted: true };
    }
    let rejectedWith = '';
    try {
      await applyArtifact(database, pkg, forwardSql);
    } catch (error) {
      rejectedWith = String(error.message);
    }
    try { await database.exec('ROLLBACK'); } catch { /* transaction already closed */ }
    check(rejectedWith.includes(expectedError), `LEDGER_FIXTURE_WRONG_ERROR:${name}:${rejectedWith}`);
    check(
      Number(await scalar(database, 'SELECT count(*) FROM public.categories')) === 0,
      `LEDGER_FIXTURE_PARTIAL_CATEGORIES:${name}`,
    );
    return {
      name,
      result: 'PASS',
      accepted: false,
      rejected_with: rejectedWith.slice(0, 160),
    };
  } finally {
    await database.close();
  }
}

async function ledgerFixtureMatrix(pgliteRoot, pkg, forwardSql, rollbackSql) {
  const first = pkg.manifest.runtime_contract.migration_ledger[0];
  const second = pkg.manifest.runtime_contract.migration_ledger[1];
  const fixtures = [];
  fixtures.push(await ledgerFixture('ledger_exact_9_pairs', pgliteRoot, pkg, forwardSql, rollbackSql, null));
  fixtures.push(await ledgerFixture(
    'ledger_same_version_wrong_name', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'UPDATE supabase_migrations.schema_migrations SET name=$1 WHERE version=$2',
      ['0001_wrong_name', first.version],
    ),
    'W37_MIGRATION_LEDGER_NAME_MISMATCH',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_same_name_wrong_version', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'UPDATE supabase_migrations.schema_migrations SET version=$1 WHERE name=$2',
      ['20990101010101', first.name],
    ),
    'W37_MIGRATION_LEDGER_VERSION_MISMATCH',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_missing_historical_migration', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'DELETE FROM supabase_migrations.schema_migrations WHERE version=$1',
      [first.version],
    ),
    'W37_MIGRATION_LEDGER_MISSING',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_unexpected_historical_migration', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
      ['20991231235959', '9999_unexpected_migration', []],
    ),
    'W37_MIGRATION_LEDGER_UNEXPECTED',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_duplicate_version', pgliteRoot, pkg, forwardSql, rollbackSql,
    async (database) => {
      await database.exec('ALTER TABLE supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_pkey');
      await database.query(
        'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
        [first.version, '9998_duplicate_version', []],
      );
    },
    'W37_MIGRATION_LEDGER_DUPLICATE_VERSION',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_duplicate_name', pgliteRoot, pkg, forwardSql, rollbackSql,
    async (database) => {
      await database.exec('ALTER TABLE supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_name_key');
      await database.query(
        'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
        ['20991231235958', first.name, []],
      );
    },
    'W37_MIGRATION_LEDGER_DUPLICATE_NAME',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_duplicate_pair', pgliteRoot, pkg, forwardSql, rollbackSql,
    async (database) => {
      await database.exec(`
        ALTER TABLE supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_pkey;
        ALTER TABLE supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_name_key;
      `);
      await database.query(
        'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
        [first.version, first.name, []],
      );
    },
    'W37_MIGRATION_LEDGER_DUPLICATE_PAIR',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_full_filename_in_name', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'UPDATE supabase_migrations.schema_migrations SET name=$1 WHERE version=$2',
      [first.repository_file, first.version],
    ),
    'W37_MIGRATION_LEDGER_MALFORMED_ROW',
  ));
  fixtures.push(await ledgerFixture(
    'ledger_reordered_pairs', pgliteRoot, pkg, forwardSql, rollbackSql,
    async (database, rows) => {
      await database.exec('DELETE FROM supabase_migrations.schema_migrations');
      for (const row of [...rows].reverse()) {
        await database.query(
          'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
          [row.version, row.name, []],
        );
      }
    },
  ));
  fixtures.push(await ledgerFixture(
    'ledger_malformed_row', pgliteRoot, pkg, forwardSql, rollbackSql,
    (database) => database.query(
      'UPDATE supabase_migrations.schema_migrations SET version=$1 WHERE version=$2',
      ['malformed', second.version],
    ),
    'W37_MIGRATION_LEDGER_MALFORMED_ROW',
  ));
  check(fixtures.every((item) => item.result === 'PASS'), 'LEDGER_FIXTURE_MATRIX_INCOMPLETE');
  return fixtures;
}

async function midTransactionFailure(pgliteRoot, pkg, forwardSql) {
  const database = await openPGlite(pgliteRoot);
  try {
    await createEmptyApplicationBaseline(database, pkg);
    await setLocalGuard(database, pkg.manifest.package_sha256);
    const broken = forwardSql.replace(
      /\nCOMMIT;\s*$/,
      "\nDO $injected$ BEGIN RAISE EXCEPTION 'W36_INJECTED_MID_TRANSACTION_FAILURE'; END $injected$;\nCOMMIT;\n",
    );
    let rejected = false;
    try { await database.exec(broken); } catch { rejected = true; }
    try { await database.exec('ROLLBACK'); } catch { /* transaction already closed */ }
    check(rejected, 'MID_TRANSACTION_INJECTION_NOT_REJECTED');
    check(Number(await scalar(database, 'SELECT count(*) FROM public.categories')) === 0, 'MID_TRANSACTION_PARTIAL_CATEGORIES');
    check(Number(await scalar(database, "SELECT count(*) FROM public.platform_metadata WHERE key='w36-sentinel'")) === 1, 'MID_TRANSACTION_PLATFORM_METADATA');
    return { name: 'mid_transaction_failure', result: 'PASS', partial_categories: 0 };
  } finally {
    await database.close();
  }
}

async function runCycle(pgliteRoot, pkg, artifacts, index, idempotent) {
  const database = await openPGlite(pgliteRoot);
  try {
    const engine = String(await scalar(database, 'select version()'));
    await createEmptyApplicationBaseline(database, pkg);
    const first = await applyArtifact(database, pkg, artifacts.forward);
    const second = idempotent ? await applyArtifact(database, pkg, artifacts.forward) : null;
    const rollback = await rollbackArtifact(database, pkg, artifacts.rollback);
    return {
      cycle: index,
      engine,
      forward: 'PASS',
      postcheck: first,
      idempotent_second_apply: idempotent ? 'PASS' : 'NOT_REQUESTED',
      idempotent_postcheck_sha256: second ? sha256(stableJson(second)) : null,
      rollback: 'PASS',
      rollback_postcheck: rollback,
      fresh_rebuild: 'PASS',
    };
  } finally {
    await database.close();
  }
}

async function main() {
  const forbidden = ['--remote', '--production', '--development', '--url', '--project-ref', '--access-token'];
  if (process.argv.some((value) => forbidden.includes(value))) throw new Error('REMOTE_MODE_NOT_IMPLEMENTED');
  check(process.argv.includes('--local'), 'LOCAL_FLAG_REQUIRED');
  const pgliteRoot = argument('--pglite-root');
  check(pgliteRoot, '--pglite-root is required');
  const repoRoot = resolve(argument('--repo-root', process.cwd()));
  const outputPath = argument('--output');
  const exactForwardPath = argument('--exact-forward');
  const exactForwardSha256 = argument('--exact-forward-sha256');
  check(Boolean(exactForwardPath) === Boolean(exactForwardSha256), 'EXACT_FORWARD_SHA_REQUIRED');
  const temporaryRoot = await mkdtemp(join(tmpdir(), 'esnaftavar-w36-'));
  try {
    const inputDirectory = argument('--input')
      ? resolve(argument('--input'))
      : join(temporaryRoot, 'synthetic-input');
    if (!argument('--input')) await generateSyntheticPackage(repoRoot, inputDirectory);
    const pkg = await loadPackage(inputDirectory);
    const precheck = validatePrecheckSnapshot(buildPrecheckSnapshot(pkg), pkg);
    const artifactDirectoryA = join(temporaryRoot, 'artifacts-a');
    const artifactDirectoryB = join(temporaryRoot, 'artifacts-b');
    const compiledA = await compileToDirectory(inputDirectory, artifactDirectoryA);
    const compiledB = await compileToDirectory(inputDirectory, artifactDirectoryB);
    check(
      compiledA.artifactManifest.artifact_set_sha256 === compiledB.artifactManifest.artifact_set_sha256,
      'NON_DETERMINISTIC_COMPILER_OUTPUT',
    );
    const artifacts = await loadArtifacts(artifactDirectoryA);
    check(
      artifacts.manifest.artifact_set_sha256 === compiledA.artifactManifest.artifact_set_sha256,
      'ARTIFACT_MANIFEST_DRIFT',
    );
    if (exactForwardPath) {
      const exactForward = await readFile(resolve(exactForwardPath), 'utf8');
      check(sha256(exactForward) === exactForwardSha256, 'ACTIVE_ARTIFACT_SHA_MISMATCH:exact-forward.sql');
      artifacts.forward = exactForward;
    }
    const packageFailures = await packageFailureMatrix(pkg, inputDirectory, temporaryRoot);
    const artifactFailures = await artifactFailureMatrix(artifactDirectoryA, temporaryRoot);
    const ledgerFixtures = await ledgerFixtureMatrix(
      resolve(pgliteRoot), pkg, artifacts.forward, artifacts.rollback,
    );
    const cycles = [];
    for (let index = 1; index <= 3; index += 1) {
      cycles.push(await runCycle(resolve(pgliteRoot), pkg, artifacts, index, index <= 2));
    }
    const midFailure = await midTransactionFailure(resolve(pgliteRoot), pkg, artifacts.forward);
    const ledgerFailures = ledgerFixtures.filter((item) => item.accepted === false);
    const failureMatrix = [...packageFailures, ...artifactFailures, ...ledgerFailures, midFailure];
    check(failureMatrix.every((item) => item.result === 'PASS'), 'FAILURE_MATRIX_INCOMPLETE');
    const exact = pkg.manifest.package_kind === 'EXACT_CANONICAL_BOOTSTRAP';
    const result = {
      status: 'PASS',
      mode: 'LOCAL_PGLITE_ONLY',
      package: {
        kind: pkg.manifest.package_kind,
        taxonomy_version: pkg.manifest.taxonomy_version,
        package_sha256: pkg.manifest.package_sha256,
        exact_wave36a_artifact: exact,
      },
      compiler: {
        deterministic: true,
        artifact_set_sha256: compiledA.artifactManifest.artifact_set_sha256,
        forward_bytes: compiledA.artifactManifest.artifacts['forward.sql'].bytes,
        exact_active_forward_sha256: exactForwardPath ? sha256(artifacts.forward) : null,
        exact_active_forward_replayed: Boolean(exactForwardPath),
      },
      jit_precheck: precheck,
      fresh_rebuild_cycles: cycles.length,
      forward_cycles: cycles.length,
      rollback_cycles: cycles.length,
      idempotent_second_apply_attempts: cycles.filter((cycle) => cycle.idempotent_second_apply === 'PASS').length,
      cycles,
      ledger_fixture_matrix: ledgerFixtures,
      ledger_fixture_matrix_passed: ledgerFixtures.length,
      failure_matrix: failureMatrix,
      failure_matrix_passed: failureMatrix.length,
      remote_access_performed: false,
      exact_artifact_rehearsal: exact ? 'PASS' : 'PENDING',
    };
    const serialized = `${JSON.stringify(result, null, 2)}\n`;
    if (outputPath) await writeFile(resolve(outputPath), serialized, 'utf8');
    if (!process.argv.includes('--quiet')) process.stdout.write(serialized);
  } finally {
    await rm(temporaryRoot, { recursive: true, force: true });
  }
}

await main();
