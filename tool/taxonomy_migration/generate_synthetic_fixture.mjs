#!/usr/bin/env node
import { resolve } from 'node:path';
import { generateSyntheticPackage } from './lib.mjs';

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

if (process.argv.some((value) => ['--remote', '--production', '--development'].includes(value))) {
  throw new Error('REMOTE_MODE_NOT_IMPLEMENTED');
}
const repoRoot = resolve(argument('--repo-root', process.cwd()));
const output = argument('--output');
if (!output) throw new Error('Usage: generate_synthetic_fixture.mjs --output <package-dir> [--repo-root <repo>]');
const manifest = await generateSyntheticPackage(repoRoot, resolve(output));
process.stdout.write(`${JSON.stringify({
  status: 'PASS',
  warning: 'SYNTHETIC_TEST_ONLY — NEVER REMOTE',
  package_sha256: manifest.package_sha256,
  expected: manifest.expected,
}, null, 2)}\n`);
