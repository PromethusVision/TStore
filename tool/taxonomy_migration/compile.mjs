#!/usr/bin/env node
import { compileToDirectory } from './compiler.mjs';

function argument(name) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

if (process.argv.some((value) => ['--remote', '--production', '--development', '--url', '--project-ref'].includes(value))) {
  throw new Error('REMOTE_MODE_NOT_IMPLEMENTED');
}
const input = argument('--input');
const output = argument('--output');
if (!input || !output) throw new Error('Usage: compile.mjs --input <package-dir> --output <artifact-dir>');
const result = await compileToDirectory(input, output);
process.stdout.write(`${JSON.stringify({
  status: 'PASS',
  mode: 'LOCAL_COMPILATION_ONLY',
  package_sha256: result.pkg.manifest.package_sha256,
  artifact_set_sha256: result.artifactManifest.artifact_set_sha256,
  output: result.outputDirectory,
}, null, 2)}\n`);
