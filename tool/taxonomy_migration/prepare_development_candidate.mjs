#!/usr/bin/env node
import { readFile, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';

import { check, sha256 } from './lib.mjs';
import { loadArtifacts } from './local_database.mjs';

const EXPECTED_PROJECT_REF = 'tnipyxnvhgelwdpykyez';
const FORBIDDEN_PRODUCTION_REF = 'mefhfvrgkwciubeajjeb';
const EXPECTED_SOURCE_HEAD = 'd9c45a1c2acd94fe0bfa52b16772718142c0664a';
const EXPECTED_FROZEN_SHA256 =
  '095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406';
const EXPECTED_MIGRATION_NAME =
  '20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap';

function argument(name) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

if (process.argv.some((value) => [
  '--remote', '--production', '--apply', '--url', '--access-token',
].includes(value))) {
  throw new Error('W37_CANDIDATE_PREPARATION_IS_LOCAL_ONLY');
}

const artifactDirectory = argument('--artifact-dir');
const packageManifestPath = argument('--package-manifest');
const outputPath = argument('--output');
const metadataPath = argument('--metadata-output');
const projectRef = argument('--project-ref');
const migrationName = argument('--migration-name');

if (!artifactDirectory || !packageManifestPath || !outputPath || !metadataPath
    || !projectRef || !migrationName) {
  throw new Error(
    'Usage: prepare_development_candidate.mjs '
    + '--artifact-dir <compiled-dir> --package-manifest <package_manifest.json> '
    + '--output <candidate.sql> --metadata-output <metadata.json> '
    + '--project-ref <ref> --migration-name <timestamp_name>',
  );
}

check(projectRef === EXPECTED_PROJECT_REF, 'W37_DEVELOPMENT_PROJECT_REF_MISMATCH');
check(projectRef !== FORBIDDEN_PRODUCTION_REF, 'W37_PRODUCTION_REF_FORBIDDEN');
check(migrationName === EXPECTED_MIGRATION_NAME, 'W37_MIGRATION_NAME_MISMATCH');

const artifacts = await loadArtifacts(resolve(artifactDirectory));
const packageManifest = JSON.parse(await readFile(resolve(packageManifestPath), 'utf8'));
check(packageManifest.package_kind === 'EXACT_CANONICAL_BOOTSTRAP', 'W37_PACKAGE_KIND');
check(packageManifest.source_package.git_head === EXPECTED_SOURCE_HEAD, 'W37_SOURCE_HEAD_MISMATCH');
check(
  packageManifest.source_package.upstream_overall_sha256 === EXPECTED_FROZEN_SHA256,
  'W37_FROZEN_PACKAGE_SHA_MISMATCH',
);
check(
  artifacts.manifest.source_package_sha256 === packageManifest.package_sha256,
  'W37_COMPILER_PACKAGE_SHA_MISMATCH',
);
check(
  artifacts.manifest.compiler_contract === 'w37-ledger-pair-compiler-v2',
  'W37_COMPILER_CONTRACT_MISMATCH',
);
check(artifacts.manifest.safety.remote_mode_implemented === false, 'W37_REMOTE_MODE_PRESENT');
check(!artifacts.forward.includes(FORBIDDEN_PRODUCTION_REF), 'W37_PRODUCTION_REF_PRESENT');

const insertionPoint = "BEGIN;\nSET LOCAL lock_timeout='3s';\n";
check(
  artifacts.forward.split(insertionPoint).length === 2,
  'W37_COMPILER_FORWARD_SHAPE_MISMATCH',
);

const operationalPrelude = `-- Local candidate migration identifier: ${migrationName}.sql
BEGIN;
SET LOCAL esnaftavar.taxonomy_target_mode='local';
SET LOCAL esnaftavar.taxonomy_apply_token='${packageManifest.package_sha256}';
DO $w37_exclusive$
BEGIN
  IF NOT pg_try_advisory_xact_lock(
    hashtextextended('esnaftavar:${EXPECTED_PROJECT_REF}:canonical-v1.0.0', 0)
  ) THEN
    RAISE EXCEPTION 'W37_SINGLE_WRITER_LOCK_UNAVAILABLE';
  END IF;
END
$w37_exclusive$;
SET LOCAL lock_timeout='3s';
`;

const candidate = artifacts.forward.replace(insertionPoint, operationalPrelude);
check(
  candidate.replace(operationalPrelude, insertionPoint) === artifacts.forward,
  'W37_COMPILER_BODY_EQUIVALENCE_FAILED',
);
check(candidate.split('pg_try_advisory_xact_lock').length === 2, 'W37_EXCLUSIVITY_PRELUDE_COUNT');
check(!candidate.includes(FORBIDDEN_PRODUCTION_REF), 'W37_PRODUCTION_REF_PRESENT_AFTER_PREPARATION');

const candidateSha256 = sha256(candidate);
const metadata = {
  contract: 'w37-development-staged-bootstrap-candidate-v2',
  migration_name: migrationName,
  intended_project_ref: EXPECTED_PROJECT_REF,
  source_head: EXPECTED_SOURCE_HEAD,
  frozen_package_sha256: EXPECTED_FROZEN_SHA256,
  normalized_package_sha256: packageManifest.package_sha256,
  compiler_contract: artifacts.manifest.compiler_contract,
  compiler_artifact_set_sha256: artifacts.manifest.artifact_set_sha256,
  compiler_forward_sha256: artifacts.manifest.artifacts['forward.sql'].sha256,
  active_migration_candidate_sha256: candidateSha256,
  compiler_body_byte_exact: true,
  migration_identifier_bound: true,
  transaction_scoped_try_advisory_lock: true,
  remote_access_performed: false,
  apply_performed: false,
};

await writeFile(resolve(outputPath), candidate, 'utf8');
await writeFile(resolve(metadataPath), `${JSON.stringify(metadata, null, 2)}\n`, 'utf8');

process.stdout.write(`${JSON.stringify({
  status: 'PASS',
  mode: 'LOCAL_CANDIDATE_PREPARATION_ONLY',
  migration_name: migrationName,
  normalized_package_sha256: packageManifest.package_sha256,
  artifact_set_sha256: artifacts.manifest.artifact_set_sha256,
  active_migration_candidate_sha256: candidateSha256,
  output: join(resolve(outputPath)),
  remote_access_performed: false,
  apply_performed: false,
}, null, 2)}\n`);
