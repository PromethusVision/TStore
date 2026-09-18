import { readdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { check, directory, hash, json, payload, read, root, stable } from './common.mjs';

export function measuredBundle() {
  const files = ['common.mjs','session.mjs','catalog.mjs','validators.mjs','engine.mjs','production.mjs','seal.mjs','cli.mjs','contract.json','local.mjs','restore.mjs','fingerprint_rehearsal.mjs'].map(name => `${directory}/${name}`);
  files.push('tool/production_taxonomy/real_contract_checks.mjs', 'tool/production_taxonomy/real_restore_lib.mjs',
    'tool/taxonomy_migration/lib.mjs', 'docs/TAXONOMY_W36_CATEGORY_IMPORT.csv', 'docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv',
    'docs/data/production_20_product_canonical_mapping.csv', 'docs/data/w52h_r_source_restore_metadata.json');
  // Freeze every upstream input read by the established contract verifier.
  for (const name of readdirSync(resolve(root, 'docs/data')).filter(n => /canonical.*\.csv$|production_.*\.json$/.test(n)).sort()) files.push(`docs/data/${name}`);
  const hashes = Object.fromEntries([...new Set(files)].map(path => [path, hash(read(path))]));
  return { format: 'w52jb-execution-bundle-v1', files: hashes, payload_sha256: payload().sha256, source_sha256: payload().source_sha256 };
}
export function verifyBundle(expected) {
  const sealed = json(`${directory}/bundle.json`);
  check(typeof expected === 'string' && /^[a-f0-9]{64}$/.test(expected), 'EXPLICIT_BUNDLE_HASH_REQUIRED');
  check(hash(stable(sealed)) === expected && stable(sealed) === stable(measuredBundle()), 'BUNDLE_HASH_MISMATCH');
  return expected;
}
if (process.argv[1]?.endsWith('seal.mjs')) {
  const bundle = measuredBundle();
  writeFileSync(resolve(root, directory, 'bundle.json'), JSON.stringify(bundle, null, 2) + '\n');
  console.log(JSON.stringify({ result: 'PASS', bundle_sha256: hash(stable(bundle)), payload_sha256: bundle.payload_sha256 }));
}
