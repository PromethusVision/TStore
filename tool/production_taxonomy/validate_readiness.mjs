// Offline evidence validator; it never opens a database connection.
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { check, parseCsv, sha256, stableJson } from '../taxonomy_migration/lib.mjs';
const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const read = async p => (await readFile(resolve(root,p),'utf8')).replaceAll('\r\n','\n');
const pre = JSON.parse(await read('docs/data/w52h_production_preflight_manifest.json'));
const result = JSON.parse(await read('docs/data/w52h_production_migration_rehearsal_result.json'));
const artifact = JSON.parse(await read('tool/production_taxonomy/artifact_manifest.json'));
const rows = parseCsv(await read(pre.owner_mapping.file)).rows;
check(pre.project_ref === 'mefhfvrgkwciubeajjeb', 'WRONG_PROJECT');
check(stableJson(pre.observed.counts) === stableJson({ categories:4,roots:4,children:0,products:20,listings:285,shops:57,orphan_products:0,orphan_listings:0 }), 'BASELINE_COUNTS');
check(pre.observed.migration_ledger.length === 9 && !pre.observed.migration_ledger.some(r => /^001[01]_/.test(r.name)), 'PRODUCTION_LEDGER');
check(rows.length === 20 && new Set(rows.map(r => r.PRODUCT_ID)).size === 20, 'OWNER_ROWS');
check(rows.every(r => r.PROPOSED_CANONICAL_UUID && r.PROPOSED_CANONICAL_PATH && r.TARGET_IS_TERMINAL === 'YES' && r.OWNER_DECISION_REQUIRED === 'NO'), 'OWNER_COMPLETENESS');
check(sha256(await read(pre.owner_mapping.file)) === pre.owner_mapping.sha256_lf_utf8, 'OWNER_HASH');
check(sha256(await read(artifact.candidate)) === artifact.sha256_lf_utf8, 'CANDIDATE_HASH');
check(result.candidate.sha256_lf_utf8 === artifact.sha256_lf_utf8 && result.rehearsal_runs >= 2, 'EXACT_REHEARSAL');
check(result.runs.every(r => r.staged.exact_owner_mappings === 20 && r.activated.products === 20 && r.activated.shop_products === 285 && r.rollback.result === 'PASS' && r.restore.result === 'PASS_LOCAL_SYNTHETIC_ONLY'), 'REHEARSAL_INVARIANTS');
check(!pre.production_write_performed && !result.production_write_performed && !pre.development_accessed && !result.development_accessed, 'REMOTE_SAFETY');
const files = ['docs/RELEASE_W52H_PRODUCTION_TAXONOMY_MIGRATION_READINESS.md',
 'docs/data/w52h_production_preflight_manifest.json','docs/data/w52h_production_migration_rehearsal_result.json',artifact.candidate,
 ...(await readdir(resolve(root,'tool/production_taxonomy'))).map(n => `tool/production_taxonomy/${n}`)];
const patterns = [
 /\b(?:sb_secret_|sb_publishable_|ghp_|github_pat_)[A-Za-z0-9_-]+/,
 /\beyJ[A-Za-z0-9_-]{12,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/,
 /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
 /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/,
 /postgres(?:ql)?:\/\/[^\s'"<>]*:[^\s'"<>]+@/,
];
for (const path of files) {
 const text = await read(path);
 check(!text.includes('\uFFFD'), `ENCODING:${path}`);
 for (const pattern of patterns) check(!pattern.test(text), `SECRET_OR_PII:${path}`);
}
const gates = pre.decision_safety_gates;
const allGates = Object.values(gates).every(v => v === true);
check(allGates === pre.ready_for_product_owner_production_write_decision, 'MISREPORTED_PREFLIGHT_READINESS');
check(allGates === result.ready_for_product_owner_production_write_decision, 'MISREPORTED_RESULT_READINESS');
console.log('ARTIFACTS / MAPPING / SQL HASH / REHEARSAL / SECRET-PII SCAN: PASS');
console.log(`READY_FOR_PRODUCT_OWNER_PRODUCTION_WRITE_DECISION: ${allGates ? 'YES' : 'NO'}`);
console.log(`OPEN_GATES: ${Object.keys(gates).filter(k => !gates[k]).join(', ')}`);
if (process.argv.includes('--require-write-ready') && !allGates) process.exitCode=2;
