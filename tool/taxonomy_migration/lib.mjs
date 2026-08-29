import { createHash } from 'node:crypto';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { basename, join, resolve } from 'node:path';

export const CONTRACT_VERSION = 'w36-taxonomy-package-v1';
export const EXPECTED_PROJECT_REF = 'tnipyxnvhgelwdpykyez';
export const INPUT_FILES = [
  'categories.csv',
  'uuid_allocations.csv',
  'aliases.csv',
  'alias_targets.csv',
  'relationships.csv',
  'activation.csv',
];

export const HEADERS = {
  'categories.csv': [
    'CATEGORY_ID', 'PLANNING_KEY', 'PARENT_CATEGORY_ID', 'NAME', 'SLUG',
    'LEVEL', 'SORT_ORDER', 'LEAF_YN', 'TAXONOMY_VERSION',
  ],
  'uuid_allocations.csv': [
    'PLANNING_KEY', 'CATEGORY_ID', 'TAXONOMY_VERSION', 'ALLOCATION_SOURCE',
  ],
  'aliases.csv': [
    'ALIAS_ID', 'ALIAS_KIND', 'ALIAS_LOCATOR', 'ALIAS_TEXT', 'ALIAS_SLUG',
    'ALIAS_PATH', 'SOURCE_ALIAS_TYPE', 'RESOLUTION_STATE',
    'DIRECT_TARGET_CATEGORY_ID', 'LOCALE', 'TAXONOMY_VERSION', 'IS_ACTIVE',
  ],
  'alias_targets.csv': ['ALIAS_ID', 'TARGET_CATEGORY_ID'],
  'relationships.csv': [
    'RELATIONSHIP_ID', 'PREDECESSOR_SOURCE_LOCATOR', 'SUCCESSOR_CATEGORY_ID',
    'ACTION', 'TARGET_STATE', 'CLASSIFICATION_RULE', 'CONFIDENCE',
    'TAXONOMY_VERSION',
  ],
  'activation.csv': [
    'CATEGORY_ID', 'PLANNING_KEY', 'LIFECYCLE_STATE', 'IS_ACTIVE',
    'IS_ASSIGNABLE', 'POLICY_CLASS', 'PROFESSIONAL_REVIEW_STATUS',
    'QUALIFICATION_STATE',
  ],
};

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const POLICY_CLASSES = new Set([
  'NORMAL', 'AGE_RESTRICTED', 'REGULATED', 'LEGAL_REVIEW_REQUIRED', 'EXCLUDED',
]);
const PROFESSIONAL_STATES = new Set(['not_required', 'pending', 'approved', 'rejected']);
const RELATIONSHIP_ACTIONS = new Set([
  'KEEP', 'RENAME', 'MOVE', 'RENAME_AND_MOVE', 'MERGE', 'SPLIT', 'RETIRE',
  'ALIAS_ONLY', 'OUT', 'UNRESOLVED',
]);
const TARGET_STATES = new Set([
  'CANONICAL_FINAL', 'NO_TARGET_YET', 'POLICY_REVIEW', 'OUT_OF_SCOPE',
]);
const ALIAS_STATES = new Set(['RESOLVED', 'AMBIGUOUS', 'TOMBSTONE', 'UNRESOLVED']);
const ALIAS_KINDS = new Set(['LEGACY_REDIRECT', 'SEARCH_SYNONYM']);
const QUALIFICATION_STATES = new Set(['STRUCTURAL_APPROVED', 'FAIL_CLOSED_PENDING_REVIEW']);

export function fail(message) {
  throw new Error(message);
}

export function check(condition, message) {
  if (!condition) fail(message);
}

export function sha256(value) {
  return createHash('sha256').update(value).digest('hex');
}

export function stableJson(value) {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object') {
    const fields = Object.keys(value).sort()
      .map((key) => `${JSON.stringify(key)}:${stableJson(value[key])}`);
    return `{${fields.join(',')}}`;
  }
  return JSON.stringify(value);
}

export function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = '';
  let quoted = false;
  const input = text.replace(/^\uFEFF/, '');
  for (let index = 0; index < input.length; index += 1) {
    const character = input[index];
    if (quoted) {
      if (character === '"' && input[index + 1] === '"') {
        value += '"';
        index += 1;
      } else if (character === '"') quoted = false;
      else value += character;
    } else if (character === '"') quoted = true;
    else if (character === ',') {
      row.push(value);
      value = '';
    } else if (character === '\n') {
      row.push(value.replace(/\r$/, ''));
      if (row.some((cell) => cell.length > 0)) rows.push(row);
      row = [];
      value = '';
    } else value += character;
  }
  check(!quoted, 'CSV_UNTERMINATED_QUOTE');
  if (value.length > 0 || row.length > 0) {
    row.push(value.replace(/\r$/, ''));
    rows.push(row);
  }
  const headers = rows.shift() ?? [];
  return {
    headers,
    rows: rows.map((cells) => Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? '']))),
  };
}

function csvCell(value) {
  const text = String(value ?? '');
  return `"${text.replaceAll('"', '""')}"`;
}

export function stringifyCsv(headers, rows) {
  const lines = [headers.map(csvCell).join(',')];
  for (const row of rows) lines.push(headers.map((header) => csvCell(row[header])).join(','));
  return `${lines.join('\n')}\n`;
}

export function splitTargets(value) {
  return String(value ?? '').split('||').map((part) => part.trim()).filter(Boolean);
}

export function sql(value, cast = '') {
  if (value === null || value === undefined || value === '') return 'NULL';
  return `'${String(value).replaceAll("'", "''")}'${cast}`;
}

export function sqlBoolean(value) {
  return value === true || value === 'YES' ? 'TRUE' : 'FALSE';
}

export function testOnlyUuid(key) {
  const digest = sha256(`ESNAFTAVAR-W36-SYNTHETIC-ONLY|${key}`).slice(0, 32).split('');
  digest[12] = '4';
  digest[16] = ['8', '9', 'a', 'b'][Number.parseInt(digest[16], 16) % 4];
  return `${digest.slice(0, 8).join('')}-${digest.slice(8, 12).join('')}-${digest.slice(12, 16).join('')}-${digest.slice(16, 20).join('')}-${digest.slice(20).join('')}`;
}

export function administrativeUuid(key) {
  const namespace = Buffer.from('6ba7b8109dad11d180b400c04fd430c8', 'hex');
  const digest = createHash('sha1')
    .update(namespace)
    .update(Buffer.from(`esnaftavar:w36-admin:${key}`, 'utf8'))
    .digest()
    .subarray(0, 16);
  digest[6] = (digest[6] & 0x0f) | 0x50;
  digest[8] = (digest[8] & 0x3f) | 0x80;
  const hex = digest.toString('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

function normalizedSlug(name, planningKey) {
  const folded = name.normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9]+/g, '-').replace(/^-|-$/g, '').toLowerCase();
  return `${folded || 'node'}-${planningKey.slice(-6).toLowerCase()}`;
}

function canonicalName(row) {
  return row[`L${Number(row.LEVEL.slice(1))}_NAME`].trim();
}

function relationshipTargetState(row) {
  if (row.FINAL_ACTION === 'OUT') return 'OUT_OF_SCOPE';
  if (row.RUNTIME_DISPOSITION === 'POLICY_REVIEW') return 'POLICY_REVIEW';
  if (!row.TARGET_PLANNING_KEYS.trim()) return 'NO_TARGET_YET';
  return 'CANONICAL_FINAL';
}

function aliasResolution(row, targetIds) {
  if (targetIds.length === 1) return 'RESOLVED';
  if (targetIds.length > 1) return 'AMBIGUOUS';
  if (['RETIRE', 'OUT'].includes(row.SOURCE_ACTION)) return 'TOMBSTONE';
  return 'UNRESOLVED';
}

export async function currentRuntimeContract(repoRoot) {
  const migrationDirectory = join(repoRoot, 'supabase', 'migrations');
  const names = (await readdir(migrationDirectory)).filter((name) => name.endsWith('.sql')).sort();
  const migrationFiles = [];
  for (const name of names) {
    const content = await readFile(join(migrationDirectory, name));
    migrationFiles.push({ name, sha256: sha256(content) });
  }
  const migrationHistorySha256 = sha256(stableJson(migrationFiles));
  const schemaContract = {
    public_tables: ['categories', 'products', 'shops', 'shop_products'],
    empty_required: true,
    taxonomy_schema_baseline: 'w34-hardened-additive-v1',
    platform_metadata_ownership: 'excluded',
  };
  return {
    migration_files: migrationFiles,
    migration_history_sha256: migrationHistorySha256,
    schema_contract_sha256: sha256(stableJson(schemaContract)),
    schema_contract: schemaContract,
  };
}

export async function generateSyntheticPackage(repoRoot, outputDirectory) {
  const taxonomyVersion = 'canonical-v1-w36-synthetic-only';
  const manifest = parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv'), 'utf8')).rows;
  const registry = parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_FINAL_SPLIT_MERGE_REGISTRY.csv'), 'utf8')).rows;
  const aliasSource = parseCsv(await readFile(join(repoRoot, 'docs', 'TAXONOMY_W34_ALIAS_REDIRECT_MANIFEST.csv'), 'utf8')).rows;
  const categoryIds = new Map(manifest.map((row) => [row.PLANNING_KEY, testOnlyUuid(`category|${row.PLANNING_KEY}`)]));
  const siblingOrders = new Map();
  const categories = manifest.map((row) => {
    const parent = row.PARENT_PLANNING_KEY;
    const order = (siblingOrders.get(parent) ?? 0) + 1;
    siblingOrders.set(parent, order);
    return {
      CATEGORY_ID: categoryIds.get(row.PLANNING_KEY),
      PLANNING_KEY: row.PLANNING_KEY,
      PARENT_CATEGORY_ID: parent ? categoryIds.get(parent) : '',
      NAME: canonicalName(row),
      SLUG: normalizedSlug(canonicalName(row), row.PLANNING_KEY),
      LEVEL: String(Number(row.LEVEL.slice(1))),
      SORT_ORDER: String(order),
      LEAF_YN: row.LEAF_YN,
      TAXONOMY_VERSION: taxonomyVersion,
    };
  });
  const allocations = manifest.map((row) => ({
    PLANNING_KEY: row.PLANNING_KEY,
    CATEGORY_ID: categoryIds.get(row.PLANNING_KEY),
    TAXONOMY_VERSION: taxonomyVersion,
    ALLOCATION_SOURCE: 'SYNTHETIC_TEST_ONLY_DETERMINISTIC',
  }));
  const activation = manifest.map((row) => ({
    CATEGORY_ID: categoryIds.get(row.PLANNING_KEY),
    PLANNING_KEY: row.PLANNING_KEY,
    LIFECYCLE_STATE: 'staged',
    IS_ACTIVE: 'NO',
    IS_ASSIGNABLE: row.ASSIGNABLE_YN,
    POLICY_CLASS: row.POLICY_CLASS,
    PROFESSIONAL_REVIEW_STATUS: row.PROFESSIONAL_REVIEW_REQUIRED === 'YES' ? 'pending' : 'not_required',
    QUALIFICATION_STATE: row.POLICY_CLASS === 'NORMAL' && row.PROFESSIONAL_REVIEW_REQUIRED === 'NO'
      ? 'STRUCTURAL_APPROVED'
      : 'FAIL_CLOSED_PENDING_REVIEW',
  }));
  const relationships = [];
  for (const row of registry) {
    const targetKeys = splitTargets(row.TARGET_PLANNING_KEYS);
    for (const targetKey of targetKeys.length > 0 ? targetKeys : ['']) {
      const edgeKey = `${row.LEGACY_NODE_ID}|${targetKey}|${row.FINAL_ACTION}`;
      relationships.push({
        RELATIONSHIP_ID: testOnlyUuid(`relationship|${edgeKey}`),
        PREDECESSOR_SOURCE_LOCATOR: row.LEGACY_NODE_ID,
        SUCCESSOR_CATEGORY_ID: targetKey ? categoryIds.get(targetKey) : '',
        ACTION: row.FINAL_ACTION,
        TARGET_STATE: relationshipTargetState(row),
        CLASSIFICATION_RULE: row.RUNTIME_DISPOSITION,
        CONFIDENCE: 'SOURCE_RECONCILIATION',
        TAXONOMY_VERSION: taxonomyVersion,
      });
    }
  }
  const aliases = [];
  const aliasTargets = [];
  for (const row of aliasSource) {
    const targetIds = splitTargets(row.CANONICAL_PLANNING_KEY).map((key) => categoryIds.get(key));
    const aliasId = testOnlyUuid(`alias|${row.LEGACY_SLUG}`);
    const resolution = aliasResolution(row, targetIds);
    aliases.push({
      ALIAS_ID: aliasId,
      ALIAS_KIND: 'LEGACY_REDIRECT',
      ALIAS_LOCATOR: row.LEGACY_SLUG,
      ALIAS_TEXT: row.LEGACY_NAME,
      ALIAS_SLUG: row.LEGACY_SLUG,
      ALIAS_PATH: row.LEGACY_PATH,
      SOURCE_ALIAS_TYPE: row.ALIAS_TYPE,
      RESOLUTION_STATE: resolution,
      DIRECT_TARGET_CATEGORY_ID: resolution === 'RESOLVED' ? targetIds[0] : '',
      LOCALE: 'tr-TR',
      TAXONOMY_VERSION: taxonomyVersion,
      IS_ACTIVE: 'YES',
    });
    for (const targetId of targetIds) aliasTargets.push({ ALIAS_ID: aliasId, TARGET_CATEGORY_ID: targetId });
  }
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
  const levelCounts = Object.fromEntries([1, 2, 3, 4].map((level) => [String(level), categories.filter((row) => row.LEVEL === String(level)).length]));
  const runtime = await currentRuntimeContract(repoRoot);
  const packageCore = {
    contract_version: CONTRACT_VERSION,
    package_kind: 'SYNTHETIC_TEST_ONLY',
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
    files,
    warnings: [
      'SYNTHETIC TEST-ONLY UUIDs; never import into Development or Production.',
      'This package proves the compiler contract, not the pending Wave36A exact artifact.',
    ],
  };
  const packageManifest = { ...packageCore, package_sha256: sha256(stableJson(packageCore)) };
  await writeFile(join(outputDirectory, 'package_manifest.json'), `${JSON.stringify(packageManifest, null, 2)}\n`, 'utf8');
  return packageManifest;
}

function exactHeaders(actual, expected, name) {
  check(JSON.stringify(actual) === JSON.stringify(expected), `INPUT_HEADER_MISMATCH:${name}`);
}

function validateUuid(value, label) {
  check(UUID_PATTERN.test(value), `BAD_UUID:${label}`);
  check(!value.toUpperCase().startsWith('CANONICAL-'), `PLANNING_KEY_AS_RUNTIME_UUID:${label}`);
}

function unique(rows, keyFn, label) {
  const seen = new Set();
  for (const row of rows) {
    const key = keyFn(row);
    check(key && !seen.has(key), `DUPLICATE_${label}:${key}`);
    seen.add(key);
  }
  return seen;
}

function yesNo(value, label) {
  check(value === 'YES' || value === 'NO', `INVALID_YES_NO:${label}`);
}

export async function loadPackage(inputDirectory) {
  const directory = resolve(inputDirectory);
  const manifestText = await readFile(join(directory, 'package_manifest.json'), 'utf8');
  const packageManifest = JSON.parse(manifestText);
  check(packageManifest.contract_version === CONTRACT_VERSION, 'INPUT_CONTRACT_VERSION');
  const packageCore = { ...packageManifest };
  delete packageCore.package_sha256;
  check(sha256(stableJson(packageCore)) === packageManifest.package_sha256, 'PACKAGE_MANIFEST_CHECKSUM_MISMATCH');
  const tables = {};
  for (const name of INPUT_FILES) {
    const content = await readFile(join(directory, name), 'utf8');
    const expected = packageManifest.files?.[name];
    check(expected, `INPUT_FILE_UNDECLARED:${name}`);
    check(sha256(content) === expected.sha256, `INPUT_FILE_CHECKSUM_MISMATCH:${name}`);
    const parsed = parseCsv(content);
    exactHeaders(parsed.headers, HEADERS[name], name);
    check(parsed.rows.length === expected.rows, `INPUT_ROW_COUNT_MISMATCH:${name}`);
    tables[name] = parsed.rows;
  }
  const loaded = { directory, manifest: packageManifest, tables };
  validatePackage(loaded);
  return loaded;
}

export function validatePackage(pkg) {
  const { manifest, tables } = pkg;
  const categories = tables['categories.csv'];
  const allocations = tables['uuid_allocations.csv'];
  const aliases = tables['aliases.csv'];
  const aliasTargets = tables['alias_targets.csv'];
  const relationships = tables['relationships.csv'];
  const activation = tables['activation.csv'];
  check(manifest.target?.project_ref === EXPECTED_PROJECT_REF, 'PACKAGE_TARGET_PROJECT_REF');
  check(manifest.target?.requires_empty_application_tables === true, 'PACKAGE_EMPTY_TARGET_REQUIRED');
  check(categories.length === manifest.expected.categories, 'CATEGORY_EXPECTED_COUNT');
  check(allocations.length === manifest.expected.allocations, 'ALLOCATION_EXPECTED_COUNT');
  check(aliases.length === manifest.expected.aliases, 'ALIAS_EXPECTED_COUNT');
  check(aliasTargets.length === manifest.expected.alias_targets, 'ALIAS_TARGET_EXPECTED_COUNT');
  check(relationships.length === manifest.expected.relationships, 'RELATIONSHIP_EXPECTED_COUNT');
  const categoryIds = unique(categories, (row) => row.CATEGORY_ID, 'CATEGORY_UUID');
  const planningKeys = unique(categories, (row) => row.PLANNING_KEY, 'PLANNING_KEY');
  const slugs = unique(categories, (row) => row.SLUG.toLocaleLowerCase('tr-TR'), 'CATEGORY_SLUG');
  void slugs;
  const byId = new Map(categories.map((row) => [row.CATEGORY_ID, row]));
  const byPlanningKey = new Map(categories.map((row) => [row.PLANNING_KEY, row]));
  const levels = { '1': 0, '2': 0, '3': 0, '4': 0 };
  for (const row of categories) {
    validateUuid(row.CATEGORY_ID, `category:${row.PLANNING_KEY}`);
    check(row.CATEGORY_ID !== row.PLANNING_KEY, `PLANNING_KEY_AS_RUNTIME_UUID:${row.PLANNING_KEY}`);
    check(row.NAME.trim().length > 0 && row.NAME === row.NAME.trim(), `INVALID_CATEGORY_NAME:${row.PLANNING_KEY}`);
    check(row.SLUG.trim().length > 0 && row.SLUG === row.SLUG.trim(), `INVALID_CATEGORY_SLUG:${row.PLANNING_KEY}`);
    const level = Number(row.LEVEL);
    check(Number.isInteger(level) && level >= 1 && level <= 4, `INVALID_LEVEL:${row.PLANNING_KEY}`);
    levels[row.LEVEL] += 1;
    yesNo(row.LEAF_YN, `leaf:${row.PLANNING_KEY}`);
    check(row.TAXONOMY_VERSION === manifest.taxonomy_version, `CATEGORY_VERSION_MISMATCH:${row.PLANNING_KEY}`);
    if (level === 1) check(row.PARENT_CATEGORY_ID === '', `L1_PARENT:${row.PLANNING_KEY}`);
    else {
      validateUuid(row.PARENT_CATEGORY_ID, `parent:${row.PLANNING_KEY}`);
      const parent = byId.get(row.PARENT_CATEGORY_ID);
      check(parent, `MISSING_PARENT:${row.PLANNING_KEY}`);
      check(Number(parent.LEVEL) === level - 1, `PARENT_LEVEL_MISMATCH:${row.PLANNING_KEY}`);
    }
    check(Number.isInteger(Number(row.SORT_ORDER)) && Number(row.SORT_ORDER) >= 0, `INVALID_SORT_ORDER:${row.PLANNING_KEY}`);
  }
  check(stableJson(levels) === stableJson(manifest.expected.levels), 'LEVEL_COUNT_MISMATCH');
  const childrenByParent = new Map();
  for (const row of categories) {
    if (!row.PARENT_CATEGORY_ID) continue;
    if (!childrenByParent.has(row.PARENT_CATEGORY_ID)) childrenByParent.set(row.PARENT_CATEGORY_ID, []);
    childrenByParent.get(row.PARENT_CATEGORY_ID).push(row.CATEGORY_ID);
  }
  const leafCount = categories.filter((row) => !childrenByParent.has(row.CATEGORY_ID)).length;
  check(leafCount === manifest.expected.leaves, 'LEAF_COUNT_MISMATCH');
  for (const row of categories) {
    const structuralLeaf = !childrenByParent.has(row.CATEGORY_ID);
    check((row.LEAF_YN === 'YES') === structuralLeaf, `LEAF_FLAG_MISMATCH:${row.PLANNING_KEY}`);
    const visited = new Set();
    let cursor = row;
    while (cursor.PARENT_CATEGORY_ID) {
      check(!visited.has(cursor.CATEGORY_ID), `CATEGORY_CYCLE:${row.PLANNING_KEY}`);
      visited.add(cursor.CATEGORY_ID);
      cursor = byId.get(cursor.PARENT_CATEGORY_ID);
      check(cursor, `MISSING_PARENT:${row.PLANNING_KEY}`);
    }
  }
  unique(allocations, (row) => row.PLANNING_KEY, 'ALLOCATION_PLANNING_KEY');
  unique(allocations, (row) => row.CATEGORY_ID, 'ALLOCATION_UUID');
  check(allocations.length === categories.length, 'MISSING_ALLOCATION_ROWS');
  for (const row of allocations) {
    validateUuid(row.CATEGORY_ID, `allocation:${row.PLANNING_KEY}`);
    const category = byPlanningKey.get(row.PLANNING_KEY);
    check(category && category.CATEGORY_ID === row.CATEGORY_ID, `ALLOCATION_CATEGORY_MISMATCH:${row.PLANNING_KEY}`);
    check(row.TAXONOMY_VERSION === manifest.taxonomy_version, `ALLOCATION_VERSION_MISMATCH:${row.PLANNING_KEY}`);
    check(row.ALLOCATION_SOURCE.trim().length > 0, `ALLOCATION_SOURCE_MISSING:${row.PLANNING_KEY}`);
  }
  unique(activation, (row) => row.PLANNING_KEY, 'ACTIVATION_PLANNING_KEY');
  check(activation.length === categories.length, 'MISSING_ACTIVATION_ROWS');
  for (const row of activation) {
    validateUuid(row.CATEGORY_ID, `activation:${row.PLANNING_KEY}`);
    const category = byPlanningKey.get(row.PLANNING_KEY);
    check(category && category.CATEGORY_ID === row.CATEGORY_ID, `ACTIVATION_CATEGORY_MISMATCH:${row.PLANNING_KEY}`);
    check(row.LIFECYCLE_STATE === 'staged', `BOOTSTRAP_MUST_BE_STAGED:${row.PLANNING_KEY}`);
    yesNo(row.IS_ACTIVE, `active:${row.PLANNING_KEY}`);
    yesNo(row.IS_ASSIGNABLE, `assignable:${row.PLANNING_KEY}`);
    check(row.IS_ACTIVE === 'NO', `BOOTSTRAP_ACTIVATION_NOT_ALLOWED:${row.PLANNING_KEY}`);
    check(POLICY_CLASSES.has(row.POLICY_CLASS), `INVALID_POLICY:${row.PLANNING_KEY}`);
    check(PROFESSIONAL_STATES.has(row.PROFESSIONAL_REVIEW_STATUS), `INVALID_PROFESSIONAL_STATE:${row.PLANNING_KEY}`);
    check(QUALIFICATION_STATES.has(row.QUALIFICATION_STATE), `INVALID_QUALIFICATION_STATE:${row.PLANNING_KEY}`);
    if (row.IS_ASSIGNABLE === 'YES') check(category.LEAF_YN === 'YES', `CONTAINER_ASSIGNABLE:${row.PLANNING_KEY}`);
    if (row.POLICY_CLASS !== 'NORMAL' || row.PROFESSIONAL_REVIEW_STATUS !== 'not_required') {
      check(row.QUALIFICATION_STATE === 'FAIL_CLOSED_PENDING_REVIEW', `UNAPPROVED_POLICY_STATE:${row.PLANNING_KEY}`);
    } else {
      check(row.QUALIFICATION_STATE === 'STRUCTURAL_APPROVED', `NORMAL_QUALIFICATION_STATE:${row.PLANNING_KEY}`);
    }
  }
  const aliasIds = unique(aliases, (row) => row.ALIAS_ID, 'ALIAS_UUID');
  unique(aliases, (row) => `${row.ALIAS_KIND}|${row.ALIAS_LOCATOR}|${row.TAXONOMY_VERSION}`, 'ALIAS_LOCATOR');
  const aliasById = new Map(aliases.map((row) => [row.ALIAS_ID, row]));
  const targetIdsByAlias = new Map();
  unique(aliasTargets, (row) => `${row.ALIAS_ID}|${row.TARGET_CATEGORY_ID}`, 'ALIAS_TARGET_EDGE');
  for (const row of aliasTargets) {
    validateUuid(row.ALIAS_ID, 'alias-target:alias');
    validateUuid(row.TARGET_CATEGORY_ID, 'alias-target:category');
    check(aliasIds.has(row.ALIAS_ID), `UNKNOWN_ALIAS_TARGET_ALIAS:${row.ALIAS_ID}`);
    check(categoryIds.has(row.TARGET_CATEGORY_ID), `UNKNOWN_ALIAS_TARGET_CATEGORY:${row.TARGET_CATEGORY_ID}`);
    if (!targetIdsByAlias.has(row.ALIAS_ID)) targetIdsByAlias.set(row.ALIAS_ID, []);
    targetIdsByAlias.get(row.ALIAS_ID).push(row.TARGET_CATEGORY_ID);
  }
  for (const row of aliases) {
    validateUuid(row.ALIAS_ID, `alias:${row.ALIAS_LOCATOR}`);
    check(ALIAS_KINDS.has(row.ALIAS_KIND), `INVALID_ALIAS_KIND:${row.ALIAS_LOCATOR}`);
    check(ALIAS_STATES.has(row.RESOLUTION_STATE), `INVALID_ALIAS_STATE:${row.ALIAS_LOCATOR}`);
    check(row.TAXONOMY_VERSION === manifest.taxonomy_version, `ALIAS_VERSION_MISMATCH:${row.ALIAS_LOCATOR}`);
    yesNo(row.IS_ACTIVE, `alias-active:${row.ALIAS_LOCATOR}`);
    const targets = targetIdsByAlias.get(row.ALIAS_ID) ?? [];
    if (row.RESOLUTION_STATE === 'RESOLVED') {
      validateUuid(row.DIRECT_TARGET_CATEGORY_ID, `alias-direct:${row.ALIAS_LOCATOR}`);
      check(targets.length === 1 && targets[0] === row.DIRECT_TARGET_CATEGORY_ID, `RESOLVED_ALIAS_EDGE_MISMATCH:${row.ALIAS_LOCATOR}`);
    } else {
      check(row.DIRECT_TARGET_CATEGORY_ID === '', `NON_RESOLVED_ALIAS_DIRECT_TARGET:${row.ALIAS_LOCATOR}`);
      if (row.RESOLUTION_STATE === 'AMBIGUOUS') check(targets.length >= 2, `AMBIGUOUS_ALIAS_MISSING_EDGES:${row.ALIAS_LOCATOR}`);
      else check(targets.length === 0, `TOMBSTONE_ALIAS_HAS_EDGE:${row.ALIAS_LOCATOR}`);
    }
  }
  unique(relationships, (row) => row.RELATIONSHIP_ID, 'RELATIONSHIP_UUID');
  unique(relationships, (row) => `${row.PREDECESSOR_SOURCE_LOCATOR}|${row.SUCCESSOR_CATEGORY_ID}|${row.ACTION}|${row.TAXONOMY_VERSION}`, 'RELATIONSHIP_EDGE');
  const relationshipByPredecessor = new Map();
  for (const row of relationships) {
    validateUuid(row.RELATIONSHIP_ID, `relationship:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    check(RELATIONSHIP_ACTIONS.has(row.ACTION), `INVALID_RELATIONSHIP_ACTION:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    check(TARGET_STATES.has(row.TARGET_STATE), `INVALID_TARGET_STATE:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    check(row.TAXONOMY_VERSION === manifest.taxonomy_version, `RELATIONSHIP_VERSION_MISMATCH:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    if (row.SUCCESSOR_CATEGORY_ID) {
      validateUuid(row.SUCCESSOR_CATEGORY_ID, `successor:${row.PREDECESSOR_SOURCE_LOCATOR}`);
      check(categoryIds.has(row.SUCCESSOR_CATEGORY_ID), `UNKNOWN_SUCCESSOR:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    } else check(['RETIRE', 'OUT', 'UNRESOLVED'].includes(row.ACTION), `MISSING_SUCCESSOR:${row.PREDECESSOR_SOURCE_LOCATOR}`);
    if (!relationshipByPredecessor.has(row.PREDECESSOR_SOURCE_LOCATOR)) relationshipByPredecessor.set(row.PREDECESSOR_SOURCE_LOCATOR, []);
    relationshipByPredecessor.get(row.PREDECESSOR_SOURCE_LOCATOR).push(row);
  }
  for (const [locator, rows] of relationshipByPredecessor) {
    if (rows[0].ACTION === 'SPLIT') {
      check(rows.length >= 1 && rows.every((row) => row.SUCCESSOR_CATEGORY_ID), `SPLIT_MISSING_SUCCESSOR_EDGE:${locator}`);
      check(rows.every((row) => !/first|nearest/i.test(row.CLASSIFICATION_RULE)), `ARBITRARY_SPLIT_ASSIGNMENT:${locator}`);
    }
  }
  check(relationships.filter((row) => row.SUCCESSOR_CATEGORY_ID).length === manifest.expected.successor_edges, 'SUCCESSOR_EDGE_COUNT_MISMATCH');
  const objectIds = [...categoryIds, ...aliasIds, ...relationships.map((row) => row.RELATIONSHIP_ID)];
  check(new Set(objectIds).size === objectIds.length, 'CROSS_OBJECT_UUID_COLLISION');
  return {
    package_sha256: manifest.package_sha256,
    categories: categories.length,
    levels,
    leaves: leafCount,
    aliases: aliases.length,
    alias_targets: aliasTargets.length,
    relationships: relationships.length,
  };
}

export function buildPrecheckSnapshot(pkg, overrides = {}) {
  const runtime = pkg.manifest.runtime_contract;
  return {
    snapshot_kind: 'LOCAL_SYNTHETIC_READ_ONLY',
    project_ref: pkg.manifest.target.project_ref,
    counts: { categories: 0, products: 0, shops: 0, shop_products: 0 },
    migration_files: runtime.migration_files,
    migration_history_sha256: runtime.migration_history_sha256,
    schema_contract_sha256: runtime.schema_contract_sha256,
    single_writer: { observed: true, writer_count: 1, write_freeze_declared: true },
    drift: { detected: false, unexpected_objects: [] },
    ...overrides,
  };
}

export function validatePrecheckSnapshot(snapshot, pkg) {
  const expected = pkg.manifest.runtime_contract;
  check(snapshot.project_ref === pkg.manifest.target.project_ref, 'PRECHECK_PROJECT_REF_MISMATCH');
  for (const table of ['categories', 'products', 'shops', 'shop_products']) {
    check(Number(snapshot.counts?.[table]) === 0, `PRECHECK_NON_EMPTY_TARGET:${table}`);
  }
  check(snapshot.migration_history_sha256 === expected.migration_history_sha256, 'PRECHECK_MIGRATION_HISTORY_MISMATCH');
  check(snapshot.schema_contract_sha256 === expected.schema_contract_sha256, 'PRECHECK_SCHEMA_HASH_MISMATCH');
  check(stableJson(snapshot.migration_files) === stableJson(expected.migration_files), 'PRECHECK_MIGRATION_FILES_MISMATCH');
  check(snapshot.single_writer?.observed === true, 'PRECHECK_SINGLE_WRITER_UNOBSERVED');
  check(snapshot.single_writer?.writer_count === 1, 'PRECHECK_WRITER_COUNT');
  check(snapshot.single_writer?.write_freeze_declared === true, 'PRECHECK_WRITE_FREEZE_MISSING');
  check(snapshot.drift?.detected === false, 'PRECHECK_UNEXPECTED_DRIFT');
  check((snapshot.drift?.unexpected_objects ?? []).length === 0, 'PRECHECK_UNEXPECTED_OBJECTS');
  return { status: 'PASS', mode: 'DRY_NO_APPLY', project_ref: snapshot.project_ref };
}

export async function writeJson(path, value) {
  await mkdir(resolve(path, '..'), { recursive: true }).catch(() => {});
  await writeFile(path, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

export function packageSummary(pkg) {
  return {
    directory: pkg.directory,
    kind: pkg.manifest.package_kind,
    taxonomy_version: pkg.manifest.taxonomy_version,
    package_sha256: pkg.manifest.package_sha256,
    expected: pkg.manifest.expected,
    files: INPUT_FILES.map((name) => ({ name: basename(name), ...pkg.manifest.files[name] })),
  };
}
