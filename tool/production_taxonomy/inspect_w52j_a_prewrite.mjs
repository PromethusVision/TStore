// Offline evidence inspection only. No database/network/credential access.
// Exit 0 means this inspection completed; it does NOT authorize a rollout.
import { readFileSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { parseCsv } from '../taxonomy_migration/lib.mjs';

const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const base = '2343658ee0331a20b3bfc021ed4270764943e3a8';
const target = 'mefhfvrgkwciubeajjeb';
const read = path => readFileSync(resolve(root, path), 'utf8').replaceAll('\r\n', '\n');
const json = path => JSON.parse(read(path));
const hash = value => createHash('sha256').update(value).digest('hex');
const check = (ok, code) => { if (!ok) throw new Error(code); };
const git = args => execFileSync('git', args, { cwd: root, windowsHide: true, maxBuffer: 8 * 1024 * 1024 });
const lineOf = (text, needle) => text.slice(0, text.indexOf(needle)).split('\n').length;
const reportPath = 'docs/data/w52j_a_production_post_migration_validation.json';

try {
  const started = new Date().toISOString();
  check(process.argv.length === 3 && process.argv[2] === '--write-evidence', 'EXPLICIT_EVIDENCE_OUTPUT_REQUIRED');
  check(git(['rev-parse', 'origin/main']).toString().trim() === base, 'AUTHORITATIVE_MAIN_CHANGED');
  git(['merge-base', '--is-ancestor', base, 'HEAD']);
  const artifact = json('tool/production_taxonomy/artifact_manifest.json');
  const proof = json('docs/data/w52h_r_backup_restore_validation.json');
  const preflight = json('docs/data/w52h_production_preflight_manifest.json');
  const rehearsal = json('docs/data/w52h_r_real_copy_rehearsal.json');
  const candidate = read(artifact.candidate);
  const candidateBytes = readFileSync(resolve(root, artifact.candidate));
  const candidateGit = git(['show', `${base}:${artifact.candidate}`]);
  const expectedHash = 'a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834';
  for (const value of [artifact.sha256_lf_utf8, proof.candidate.sha256_lf_utf8,
    rehearsal.candidate_sha256, hash(candidate), hash(candidateGit)]) {
    check(value === expectedHash, 'CANDIDATE_REHEARSED_HASH_MISMATCH');
  }
  check(candidate === candidateGit.toString('utf8'), 'CANDIDATE_GIT_CONTENT_CHANGED');
  check(preflight.project_ref === target, 'HISTORICAL_PROJECT_REFERENCE_MISMATCH');
  const mapping = read(proof.owner_mapping.file);
  const mappingRows = parseCsv(mapping).rows;
  check(hash(mapping) === 'f589308535f42936a1ef4c873ea446b00ed4849fb8ef872c4112956b56a28663', 'OWNER_MAPPING_HASH_MISMATCH');
  check(mappingRows.length === 20 && new Set(mappingRows.map(row => row.PRODUCT_ID)).size === 20, 'OWNER_MAPPING_COUNT');
  check(mappingRows.every(row => row.PROPOSED_CANONICAL_UUID && row.PROPOSED_CANONICAL_PATH &&
    row.TARGET_IS_TERMINAL === 'YES' && row.OWNER_DECISION_REQUIRED === 'NO'), 'OWNER_MAPPING_INCOMPLETE');
  check(proof.owner_mapping.approved === 20, 'OWNER_MAPPING_APPROVAL_COUNT');
  check(Object.keys(proof.independent_gates).length === 9 &&
    Object.values(proof.independent_gates).every(gate => gate.result === 'PASS'), 'W52HR_NINE_GATES');
  check(rehearsal.result === 'PASS' && rehearsal.isolation.server_version === '17.6', 'PG176_REHEARSAL');
  const priorBaseline = { categories: 4, products: 20, shop_products: 285, shops: 57, orphan_products: 0, orphan_listings: 0 };
  const restoreProofs = [];
  for (const stage of ['first', 'second']) {
    const executionPath = `docs/data/w52h_r_${stage}_restore_execution.json`;
    const baselinePath = `docs/data/w52h_r_${stage}_restore_baseline.json`;
    const execution = json(executionPath), baseline = json(baselinePath);
    check(execution.result === 'PASS' && execution.empty_user_tables_before_restore === 0 &&
      execution.restore_exit_code === 0 && baseline.result === 'PASS', 'CLEAN_RESTORE_PROOF');
    check(Object.entries(priorBaseline).every(([key, value]) => baseline.counts[key] === value), 'RESTORED_BASELINE_MISMATCH');
    check(baseline.archive_table_data.length === 69, 'RESTORED_TABLE_DATA_COUNT');
    restoreProofs.push({ execution: executionPath, baseline: baselinePath, result: 'PASS', observed_at_utc: baseline.captured_at_utc });
  }
  const stagedExpected = { ...priorBaseline, canonical_nodes: 1563, canonical_roots: 24,
    terminal_leaves: 1245, exact_owner_mappings: 20, broken_parent_chains: 0, duplicate_canonical_uuids: 0 };
  check(Object.entries(stagedExpected).every(([key, value]) => rehearsal.staged[key] === value), 'STAGED_REHEARSAL_INVARIANTS');
  check(rehearsal.rollback.result === 'PASS' && rehearsal.rollback.gate.public_roots === 0 &&
    rehearsal.rollback.gate.canonical_products_visible === 0, 'ROLLBACK_REHEARSAL');
  check(json('docs/data/w52h_r_rollback_preservation.json').result === 'PASS', 'ROLLBACK_PRESERVATION');
  check(rehearsal.phases.length === 4 && rehearsal.phases.every(phase => phase.sql === 'PASS' && phase.http === 'PASS'), 'HISTORICAL_LEGACY_CONTRACTS');

  const readinessPath = 'docs/RELEASE_W52H_PRODUCTION_TAXONOMY_MIGRATION_READINESS.md';
  const readiness = read(readinessPath);
  const rollbackPath = 'tool/production_taxonomy/rollback.sql', rollback = read(rollbackPath);
  const harnessPath = 'tool/production_taxonomy/real_restore_lib.mjs', harness = read(harnessPath);
  check(candidate.includes("IS DISTINCT FROM 'local-rehearsal'") &&
    candidate.includes('W52H_LOCAL_REHEARSAL_ONLY_NO_PRODUCTION_WRITE_AUTHORIZATION'), 'RECHECK_CHANGED_APPLICATION_GUARD');
  check(rollback.includes("IS DISTINCT FROM 'local-rehearsal'") &&
    rollback.includes('W52H_ROLLBACK_LOCAL_ONLY_PENDING_SEPARATE_AUTHORIZATION'), 'RECHECK_CHANGED_ROLLBACK_GUARD');
  check(harness.includes("this.prefix() + statement") && harness.includes("esnaftavar.w52h.execution_scope='local-rehearsal'") &&
    harness.includes("NetworkMode === 'none'"), 'RECHECK_CHANGED_LOCAL_EXECUTOR');
  check(readiness.includes('Uzakta ayarlanmamalıdır.') && readiness.includes('kayıt eklemez; yeni sürümün gerçek uygulama kaydı gelecekteki executor sorumluluğudur.'), 'RECHECK_CHANGED_READINESS_CONTRACT');
  check(!/(?:insert\s+into|update|delete\s+from)\s+supabase_migrations\.schema_migrations/i.test(candidate), 'RECHECK_CHANGED_LEDGER_BEHAVIOR');

  const report = {
    contract: 'w52j-a-production-side-by-side-prewrite-inspection-v1',
    status: 'STOP_BEFORE_WRITE',
    scope: 'Offline inspection of authoritative repository evidence; not live Production validation',
    inspection_started_at_utc: started,
    inspection_completed_at_utc: new Date().toISOString(),
    production_execution_started_at_utc: null,
    production_execution_completed_at_utc: null,
    production_write_authorized: true,
    authoritative_main: base,
    branch: 'astra-release/w52j-a-production-side-by-side-rollout',
    target_project: target,
    live_target_identity_verified: false,
    candidate: {
      file: artifact.candidate, rehearsed_sha256_lf_utf8: expectedHash,
      current_git_blob_sha256: hash(candidateGit), current_checkout_sha256_raw: hash(candidateBytes),
      current_checkout_sha256_lf_utf8: hash(candidate), rehearsed_hash_match: 'PASS',
      line_ending_note: 'Windows checkout CRLF differs in raw bytes; normalized content and authoritative Git blob match the exact LF UTF-8 rehearsal artifact.',
      modified: false,
    },
    owner_mapping_package: { result: 'PASS', approved: 20, unique_products: 20,
      sha256_lf_utf8: hash(mapping), live_product_reference_comparison: 'NOT_RUN' },
    historical_w52h_r_proof: {
      result: 'PASS', independent_gates_passed: 9, pg_version: '17.6', restores: restoreProofs,
      rehearsal_observed_at_utc: rehearsal.captured_at_utc, staged_counts: rehearsal.staged,
      rollback_result: 'PASS', rollback_duration_ms: rehearsal.rollback.duration_ms,
      old_w52c_sql_contract: 'PASS', old_w52c_http_contract: 'PASS',
      is_current_production_baseline: false,
    },
    blockers: [
      { code: 'APPROVED_0012_EXECUTION_IS_LOCAL_ONLY', file: artifact.candidate,
        line: lineOf(candidate, "IF current_setting('esnaftavar.w52h.execution_scope'"),
        detail: 'Exact candidate requires local-rehearsal. Setting that on Production or editing the approved SQL is outside the proven safe mechanism required by this Wave.' },
      { code: 'PRODUCTION_LEDGER_EXECUTOR_NOT_REHEARSED', file: readinessPath,
        line: lineOf(readiness, 'Gelecekteki kontrollü executor'),
        detail: 'W52H explicitly defers actual 0012 ledger recording to a future executor. Candidate and rehearsal do not record it. No state was improvised.' },
      { code: 'REHEARSED_ROLLBACK_EXECUTION_IS_LOCAL_ONLY', file: rollbackPath,
        line: lineOf(rollback, "IF current_setting('esnaftavar.w52h.execution_scope'"),
        detail: 'Available rollback is a guarded local simulation; no previously reviewed remote execution package is present.' },
    ],
    pre_write_gate: {
      TARGET_PROJECT_IDENTITY: 'NOT_RUN', MAIN_SHA: 'PASS', '0012_HASH': 'PASS',
      LIVE_BASELINE: 'NOT_RUN', MAPPING_20_20: 'PASS_OFFLINE_PACKAGE_ONLY',
      FRESH_BACKUP_CREATED: 'NOT_RUN', FRESH_BACKUP_HASHED: 'NOT_RUN',
      ROLLBACK_PROCEDURE_AVAILABLE: 'FAIL_PRODUCTION_EXECUTOR_UNPROVEN',
      EXACT_PRODUCTION_APPLY_MECHANISM: 'FAIL_LOCAL_ONLY',
      MIGRATION_LEDGER_HANDLING: 'FAIL_NOT_REHEARSED',
      decision: 'NO_GO_STOP_BEFORE_WRITE',
    },
    live_baseline: { status: 'NOT_RUN', categories: null, products: null, listings: null, shops: null,
      migration_ledger: null, schema_fingerprint: null },
    fresh_prewrite_backup: { status: 'NOT_RUN', reason: 'Stopped at offline prerequisite gate before any remote access.',
      timestamp_utc: null, source_pg_version: null, backup_tool_version: null, size_bytes: null, sha256: null },
    migrations_applied_in_this_wave: [],
    post_migration_validation: { status: 'NOT_RUN', products: null, listings: null, shops: null,
      canonical_nodes: null, canonical_roots: null, terminal_leaves: null, owner_mappings: null,
      orphan_products: null, orphan_listings: null, broken_parent_chains: null,
      duplicate_canonical_uuids: null, policy_review_gates: 'NOT_RUN', security_access: 'NOT_RUN',
      old_w52c_sql_contract: 'NOT_RUN', old_w52c_http_contract: 'NOT_RUN',
      old_w52c_physical_device_post_migration: 'NOT_RUN', canonical_staged_backend_contract: 'NOT_RUN' },
    public_canonical_activation_performed: false,
    rollback_triggered: false, rollback_result: 'NOT_REQUIRED_NO_WRITE_ATTEMPTED',
    production_left_in_safe_side_by_side_state: false,
    production_state_note: 'No change performed; existing live state was not queried. A successful side-by-side rollout is not claimed.',
    production_accessed: false, production_write_performed: false, development_accessed: false,
    credential_files_accessed: false, backup_files_accessed: false, auth_customer_storage_qr_mutations: false,
    ready_for_new_canonical_production_client_build: false, ready_for_public_canonical_activation: false,
  };
  writeFileSync(resolve(root, reportPath), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify({ offline_inspection: 'PASS', decision: report.pre_write_gate.decision,
    rehearsed_hash: 'PASS', historical_restore_proof: 'PASS', owner_mapping_package: '20/20',
    blockers: report.blockers.map(blocker => blocker.code), production_accessed: false, production_write_performed: false }, null, 2));
} catch (error) {
  console.error(/^[A-Z0-9_]+$/.test(error.message) ? error.message : 'OFFLINE_INSPECTION_FAILED_DETAILS_SUPPRESSED');
  process.exitCode = 1;
}
