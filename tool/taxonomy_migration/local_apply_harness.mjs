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
  const checksumDirectory = join(temporaryRoot, 'checksum-mismatch');
  await cp(packageDirectory, checksumDirectory, { recursive: true });
  const categoriesPath = join(checksumDirectory, 'categories.csv');
  await writeFile(categoriesPath, `${await readFile(categoriesPath, 'utf8')}\n`, 'utf8');
  failures.push(await expectedFailure('checksum_mismatch', () => loadPackage(checksumDirectory)));
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
    const packageFailures = await packageFailureMatrix(pkg, inputDirectory, temporaryRoot);
    const cycles = [];
    for (let index = 1; index <= 3; index += 1) {
      cycles.push(await runCycle(resolve(pgliteRoot), pkg, artifacts, index, index <= 2));
    }
    const midFailure = await midTransactionFailure(resolve(pgliteRoot), pkg, artifacts.forward);
    const failureMatrix = [...packageFailures, midFailure];
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
      },
      jit_precheck: precheck,
      fresh_rebuild_cycles: cycles.length,
      forward_cycles: cycles.length,
      rollback_cycles: cycles.length,
      idempotent_second_apply_attempts: cycles.filter((cycle) => cycle.idempotent_second_apply === 'PASS').length,
      cycles,
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
