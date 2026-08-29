#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { loadPackage, validatePrecheckSnapshot } from './lib.mjs';

function argument(name) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

if (process.argv.some((value) => ['--apply', '--remote', '--production', '--development', '--url', '--access-token'].includes(value))) {
  throw new Error('JIT_PRECHECK_IS_DRY_AND_OFFLINE_ONLY');
}
const input = argument('--input');
const snapshotPath = argument('--snapshot');
if (!input || !snapshotPath) {
  throw new Error('Usage: jit_precheck.mjs --input <package-dir> --snapshot <read-only-snapshot.json>');
}
const pkg = await loadPackage(input);
const snapshot = JSON.parse(await readFile(snapshotPath, 'utf8'));
const result = validatePrecheckSnapshot(snapshot, pkg);
process.stdout.write(`${JSON.stringify({
  ...result,
  package_sha256: pkg.manifest.package_sha256,
  remote_access_performed: false,
  apply_performed: false,
}, null, 2)}\n`);
