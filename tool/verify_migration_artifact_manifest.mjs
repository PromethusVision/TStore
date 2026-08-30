import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';

const migrationDirectory = 'supabase/migrations';
const cutoverPlanPath = 'docs/PRODUCTION_SUPABASE_CUTOVER_PLAN.md';

const migrationFiles = (await readdir(migrationDirectory))
  .filter((name) => name.endsWith('.sql'))
  .sort();
const cutoverPlan = await readFile(cutoverPlanPath, 'utf8');
const manifestEntries = new Map(
  [...cutoverPlan.matchAll(/^\| `([^`]+\.sql)` \| `([a-f0-9]{64})` \|$/gm)]
    .map((match) => [match[1], match[2]]),
);

if (migrationFiles.length !== 10) {
  throw new Error(`Expected 10 canonical migrations, received ${migrationFiles.length}`);
}
if (manifestEntries.size !== migrationFiles.length) {
  throw new Error(
    `Expected ${migrationFiles.length} manifest entries, received ${manifestEntries.size}`,
  );
}

for (const migrationFile of migrationFiles) {
  const expectedHash = manifestEntries.get(migrationFile);
  if (expectedHash === undefined) {
    throw new Error(`Manifest entry is missing: ${migrationFile}`);
  }

  // Git stores these UTF-8 SQL artifacts with LF endings. Normalizing the
  // checkout prevents core.autocrlf from changing the release checksum.
  const checkoutText = await readFile(`${migrationDirectory}/${migrationFile}`, 'utf8');
  const canonicalBytes = Buffer.from(checkoutText.replace(/\r\n?/g, '\n'), 'utf8');
  const actualHash = createHash('sha256').update(canonicalBytes).digest('hex');
  if (actualHash !== expectedHash) {
    throw new Error(`Migration artifact hash mismatch: ${migrationFile}`);
  }
}

const unexpectedEntries = [...manifestEntries.keys()].filter(
  (migrationFile) => !migrationFiles.includes(migrationFile),
);
if (unexpectedEntries.length > 0) {
  throw new Error(`Unexpected manifest entries: ${unexpectedEntries.join(', ')}`);
}

console.log('Migration artifact manifest: PASS (10/10 canonical LF SHA-256)');
