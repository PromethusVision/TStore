#!/usr/bin/env node
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import {
  CONTRACT_VERSION, EXPECTED_PROJECT_REF, HEADERS, INPUT_FILES,
  administrativeUuid, check, currentRuntimeContract, parseCsv, sha256,
  stableJson, stringifyCsv,
} from './lib.mjs';

const SOURCE_FILES = {
  activation: 'TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv',
  aliases: 'TAXONOMY_W36_ALIAS_IMPORT.csv',
  aliasTargets: 'TAXONOMY_W36_ALIAS_TARGET_EDGES.csv',
  categories: 'TAXONOMY_W36_CATEGORY_IMPORT.csv',
  allocations: 'TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv',
  relationships: 'TAXONOMY_W36_SUCCESSOR_IMPORT.csv',
};

function argument(name, fallback = undefined) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

function bool(value) {
  check(value === 'TRUE' || value === 'FALSE', `W36A_BOOLEAN:${value}`);
  return value === 'TRUE' ? 'YES' : 'NO';
}

function manifestEvidence(markdown) {
  const hashes = {};
  const pattern = /\| `([^`]+\.csv)` \| ([\d,]+) \| `([0-9a-f]{64})` \|/g;
  for (const match of markdown.matchAll(pattern)) {
    hashes[match[1]] = { rows: Number(match[2].replaceAll(',', '')), sha256: match[3] };
  }
  const overall = markdown.match(/Overall package SHA-256:\s*\n\s*`([0-9a-f]{64})`/);
  check(overall, 'W36A_OVERALL_DIGEST_MISSING');
  return { hashes, overall: overall[1] };
}

async function readVerifiedSources(sourceDirectory) {
  const docs = join(sourceDirectory, 'docs');
  const markdown = await readFile(join(docs, 'TAXONOMY_W36_BOOTSTRAP_PACKAGE_MANIFEST.md'), 'utf8');
  const evidence = manifestEvidence(markdown);
  const result = {};
  for (const [key, name] of Object.entries(SOURCE_FILES)) {
    const content = await readFile(join(docs, name));
    const expected = evidence.hashes[name];
    check(expected, `W36A_MANIFEST_FILE_MISSING:${name}`);
    check(sha256(content) === expected.sha256, `W36A_SOURCE_CHECKSUM:${name}`);
    const parsed = parseCsv(content.toString('utf8')).rows;
    check(parsed.length === expected.rows, `W36A_SOURCE_ROW_COUNT:${name}`);
    result[key] = parsed;
  }
  const aggregateLines = Object.entries(evidence.hashes).sort(([a], [b]) => a.localeCompare(b, 'en'))
    .map(([name, item]) => `${name}|${item.rows}|${item.sha256}\n`).join('');
  check(sha256(aggregateLines) === evidence.overall, 'W36A_OVERALL_DIGEST_MISMATCH');
  return { rows: result, evidence };
}

async function adapt(sourceDirectory, outputDirectory, repoRoot, sourceHead) {
  const { rows: source, evidence } = await readVerifiedSources(sourceDirectory);
  const allocationByKey = new Map(source.allocations.map((row) => [row.PLANNING_KEY, row]));
  const activationByKey = new Map(source.activation.map((row) => [row.PLANNING_KEY, row]));
  const categoryIds = new Set(source.categories.map((row) => row.ID));
  const aliasIds = new Map(source.aliases.map((row) => [row.ALIAS_IMPORT_KEY, administrativeUuid(`alias|${row.ALIAS_IMPORT_KEY}`)]));
  const categories = source.categories.map((row) => {
    const allocation = allocationByKey.get(row.SOURCE_KEY);
    check(allocation && allocation.DEVELOPMENT_UUID === row.ID, `W36A_ALLOCATION_MISMATCH:${row.SOURCE_KEY}`);
    return {
      CATEGORY_ID: row.ID,
      PLANNING_KEY: row.SOURCE_KEY,
      PARENT_CATEGORY_ID: row.PARENT_ID,
      NAME: row.NAME,
      SLUG: row.SLUG,
      LEVEL: row.LEVEL,
      SORT_ORDER: row.SORT_ORDER,
      LEAF_YN: allocation.LEAF_YN,
      TAXONOMY_VERSION: row.TAXONOMY_VERSION,
    };
  });
  const allocations = source.allocations.map((row) => ({
    PLANNING_KEY: row.PLANNING_KEY,
    CATEGORY_ID: row.DEVELOPMENT_UUID,
    TAXONOMY_VERSION: row.TAXONOMY_VERSION,
    ALLOCATION_SOURCE: `WAVE36A_EXACT:${evidence.overall}`,
  }));
  const activation = source.categories.map((category) => {
    const qualification = activationByKey.get(category.SOURCE_KEY);
    check(qualification && qualification.DEVELOPMENT_UUID === category.ID, `W36A_QUALIFICATION_MISMATCH:${category.SOURCE_KEY}`);
    const pending = category.POLICY_CLASS !== 'NORMAL' || category.PROFESSIONAL_REVIEW_STATUS !== 'not_required';
    return {
      CATEGORY_ID: category.ID,
      PLANNING_KEY: category.SOURCE_KEY,
      LIFECYCLE_STATE: category.LIFECYCLE_STATE,
      IS_ACTIVE: bool(category.IS_ACTIVE),
      IS_ASSIGNABLE: bool(category.IS_ASSIGNABLE),
      POLICY_CLASS: category.POLICY_CLASS,
      PROFESSIONAL_REVIEW_STATUS: category.PROFESSIONAL_REVIEW_STATUS,
      QUALIFICATION_STATE: pending ? 'FAIL_CLOSED_PENDING_REVIEW' : 'STRUCTURAL_APPROVED',
    };
  });
  const aliases = source.aliases.map((row) => ({
    ALIAS_ID: aliasIds.get(row.ALIAS_IMPORT_KEY),
    ALIAS_KIND: row.ALIAS_KIND,
    ALIAS_LOCATOR: row.ALIAS_LOCATOR,
    ALIAS_TEXT: row.ALIAS_TEXT,
    ALIAS_SLUG: row.ALIAS_SLUG,
    ALIAS_PATH: row.ALIAS_PATH,
    SOURCE_ALIAS_TYPE: row.SOURCE_ALIAS_TYPE,
    RESOLUTION_STATE: row.RESOLUTION_STATE,
    DIRECT_TARGET_CATEGORY_ID: row.DIRECT_TARGET_DEVELOPMENT_UUID,
    LOCALE: row.LOCALE,
    TAXONOMY_VERSION: row.TAXONOMY_VERSION,
    IS_ACTIVE: bool(row.IS_ACTIVE),
  }));
  const aliasTargets = source.aliasTargets.map((row) => {
    check(aliasIds.has(row.ALIAS_IMPORT_KEY), `W36A_ALIAS_EDGE_UNKNOWN_ALIAS:${row.ALIAS_IMPORT_KEY}`);
    check(categoryIds.has(row.TARGET_DEVELOPMENT_UUID), `W36A_ALIAS_EDGE_UNKNOWN_CATEGORY:${row.TARGET_DEVELOPMENT_UUID}`);
    return {
      ALIAS_ID: aliasIds.get(row.ALIAS_IMPORT_KEY),
      TARGET_CATEGORY_ID: row.TARGET_DEVELOPMENT_UUID,
    };
  });
  const relationships = source.relationships.map((row) => ({
    RELATIONSHIP_ID: administrativeUuid(`relationship|${row.RELATIONSHIP_IMPORT_KEY}`),
    PREDECESSOR_SOURCE_LOCATOR: row.PREDECESSOR_SOURCE_LOCATOR,
    SUCCESSOR_CATEGORY_ID: row.SUCCESSOR_CATEGORY_ID,
    ACTION: row.ACTION,
    TARGET_STATE: row.TARGET_STATE,
    CLASSIFICATION_RULE: row.CLASSIFICATION_RULE,
    CONFIDENCE: row.CONFIDENCE,
    TAXONOMY_VERSION: row.TAXONOMY_VERSION,
  }));
  const dataByFile = {
    'categories.csv': categories,
    'uuid_allocations.csv': allocations,
    'aliases.csv': aliases,
    'alias_targets.csv': aliasTargets,
    'relationships.csv': relationships,
    'activation.csv': activation,
  };
  await mkdir(outputDirectory, { recursive: true });
  const files = {};
  for (const name of INPUT_FILES) {
    const content = stringifyCsv(HEADERS[name], dataByFile[name]);
    await writeFile(join(outputDirectory, name), content, 'utf8');
    files[name] = { rows: dataByFile[name].length, sha256: sha256(content) };
  }
  const taxonomyVersion = categories[0].TAXONOMY_VERSION;
  check(categories.every((row) => row.TAXONOMY_VERSION === taxonomyVersion), 'W36A_CATEGORY_VERSION_DRIFT');
  const levelCounts = Object.fromEntries([1, 2, 3, 4].map((level) => [String(level), categories.filter((row) => row.LEVEL === String(level)).length]));
  const runtime = await currentRuntimeContract(repoRoot);
  const packageCore = {
    contract_version: CONTRACT_VERSION,
    package_kind: 'EXACT_CANONICAL_BOOTSTRAP',
    taxonomy_version: taxonomyVersion,
    target: { project_ref: EXPECTED_PROJECT_REF, requires_empty_application_tables: true },
    expected: {
      categories: categories.length,
      levels: levelCounts,
      leaves: categories.filter((row) => row.LEAF_YN === 'YES').length,
      allocations: allocations.length,
      aliases: aliases.length,
      alias_targets: aliasTargets.length,
      relationships: relationships.length,
      successor_edges: relationships.filter((row) => row.SUCCESSOR_CATEGORY_ID).length,
    },
    runtime_contract: runtime,
    source_package: {
      kind: 'WAVE36A_EXACT_LOCAL_CANDIDATE',
      git_head: sourceHead,
      upstream_overall_sha256: evidence.overall,
      source_files: evidence.hashes,
      administrative_id_derivation: 'UUIDv5(DNS namespace, esnaftavar:w36-admin:<import-key>)',
    },
    files,
    warnings: [
      'Category UUIDs are byte-for-byte Wave36A allocations.',
      'Alias/relationship UUIDs are deterministic administrative IDs derived from exact import keys; they are not category stable IDs.',
      'Package remains staged/inactive and is not remote apply authority.',
    ],
  };
  const manifest = { ...packageCore, package_sha256: sha256(stableJson(packageCore)) };
  await writeFile(join(outputDirectory, 'package_manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  return manifest;
}

if (process.argv.some((value) => ['--remote', '--production', '--development', '--url', '--access-token'].includes(value))) {
  throw new Error('REMOTE_MODE_NOT_IMPLEMENTED');
}
const source = argument('--source');
const output = argument('--output');
const repoRoot = resolve(argument('--repo-root', process.cwd()));
const sourceHead = argument('--source-head', 'UNSPECIFIED_READ_ONLY_SOURCE');
if (!source || !output) throw new Error('Usage: adapt_wave36a_package.mjs --source <archive-root> --output <normalized-package> [--source-head <sha>]');
const manifest = await adapt(resolve(source), resolve(output), repoRoot, sourceHead);
process.stdout.write(`${JSON.stringify({
  status: 'PASS',
  package_kind: manifest.package_kind,
  source_head: manifest.source_package.git_head,
  upstream_overall_sha256: manifest.source_package.upstream_overall_sha256,
  normalized_package_sha256: manifest.package_sha256,
  expected: manifest.expected,
  remote_access_performed: false,
}, null, 2)}\n`);
