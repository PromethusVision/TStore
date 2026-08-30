#!/usr/bin/env node

import { createHash } from 'node:crypto';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const CLIENT_VERSION = 'taxonomy-client-v1';
const TAXONOMY_VERSION = 'canonical-v1.0.0';
const RPC_VERSION = 'taxonomy-rpc-v2';
const CANDIDATE_NAME =
  '20260830001100_0011_canonical_taxonomy_contract_v2.sql';
const ROLLBACK_NAME =
  '20260830001100_0011_canonical_taxonomy_contract_v2.rollback.sql';
const CANDIDATE_LEDGER = {
  version: '20260830001100',
  name: '0011_canonical_taxonomy_contract_v2',
};
const BASELINE_LEDGER = [
  ['20260812010907', '0001_core_auth_catalog'],
  ['20260812011047', '0002_shops'],
  ['20260812011128', '0003_carts_v2'],
  ['20260812013109', '0004_qr_verified_purchases'],
  ['20260812013220', '0005_verified_shop_ratings'],
  ['20260812013308', '0006_chat_notifications_account'],
  ['20260812013403', '0007_storage_realtime'],
  ['20260814000820', '0008_fix_profile_role_guard'],
  ['20260815000900', '0009_verified_product_reviews_storage'],
  ['20260829001000', '0010_canonical_taxonomy_v1_staged_bootstrap'],
];
const V1_RPCS = [
  'taxonomy_roots_v1',
  'taxonomy_children_v1',
  'taxonomy_descendants_v1',
  'taxonomy_exact_leaf_v1',
  'taxonomy_breadcrumb_v1',
  'taxonomy_resolve_alias_v1',
  'taxonomy_search_context_v1',
];
const V2_PUBLIC_RPCS = [
  'taxonomy_capabilities_v2',
  'taxonomy_roots_v2',
  'taxonomy_children_v2',
  'taxonomy_descendants_v2',
  'taxonomy_exact_leaf_v2',
  'taxonomy_breadcrumb_v2',
  'taxonomy_resolve_alias_v2',
  'taxonomy_search_context_v2',
];
const REQUIRED_NODE_FIELDS = [
  'id', 'parent_id', 'name', 'slug', 'level', 'lifecycle_state',
  'is_assignable', 'policy_class', 'professional_review_status',
  'taxonomy_version', 'has_children',
];
const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function argument(name, fallback = undefined) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

function check(condition, message) {
  if (!condition) throw new Error(message);
}

function canonicalText(value, name) {
  const text = String(value).replaceAll('\r\n', '\n');
  check(!text.includes('\r'), `W38_LONE_CR:${name}`);
  return text;
}

function sha256(value) {
  return createHash('sha256').update(value).digest('hex');
}

function stableJson(value) {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object') {
    return `{${Object.keys(value).sort().map(
      (key) => `${JSON.stringify(key)}:${stableJson(value[key])}`,
    ).join(',')}}`;
  }
  return JSON.stringify(value);
}

async function openPGlite(root) {
  const moduleUrl = pathToFileURL(join(root, 'dist', 'index.js')).href;
  const { PGlite } = await import(moduleUrl);
  return new PGlite();
}

async function scalar(database, statement, parameters = []) {
  const result = await database.query(statement, parameters);
  return Object.values(result.rows[0])[0];
}

async function expectedFailure(name, expectedTag, operation) {
  try {
    await operation();
  } catch (error) {
    const message = String(error.message);
    check(
      message.toLowerCase().includes(expectedTag.toLowerCase()),
      `W38_FAILURE_WRONG_ERROR:${name}:${message}`,
    );
    return { name, result: 'PASS', rejected_with: expectedTag };
  }
  throw new Error(`W38_FAILURE_DID_NOT_FAIL:${name}`);
}

function expectedSyncFailure(name, expectedTag, operation) {
  try {
    operation();
  } catch (error) {
    const message = String(error.message);
    check(
      message.includes(expectedTag),
      `W38_FAILURE_WRONG_ERROR:${name}:${message}`,
    );
    return { name, result: 'PASS', rejected_with: expectedTag };
  }
  throw new Error(`W38_FAILURE_DID_NOT_FAIL:${name}`);
}

function passedRegression(name, evidence) {
  return { name, result: 'PASS', evidence };
}

function validateNode(node) {
  for (const field of REQUIRED_NODE_FIELDS) {
    check(Object.hasOwn(node, field), `W38_NODE_FIELD_MISSING:${field}`);
  }
  check(UUID_PATTERN.test(node.id), 'W38_NODE_UUID_INVALID');
  check(node.parent_id === null || UUID_PATTERN.test(node.parent_id), 'W38_PARENT_UUID_INVALID');
  check(typeof node.name === 'string' && node.name.trim(), 'W38_NODE_NAME_INVALID');
  check(typeof node.slug === 'string' && node.slug.trim(), 'W38_NODE_SLUG_INVALID');
  check([1, 2, 3, 4].includes(node.level), 'W38_NODE_LEVEL_INVALID');
  check(['staged', 'active', 'retired'].includes(node.lifecycle_state), 'W38_NODE_LIFECYCLE_INVALID');
  check(typeof node.is_assignable === 'boolean', 'W38_NODE_ASSIGNABILITY_INVALID');
  check([
    'NORMAL', 'AGE_RESTRICTED', 'REGULATED',
    'LEGAL_REVIEW_REQUIRED', 'EXCLUDED',
  ].includes(node.policy_class), 'W38_NODE_POLICY_INVALID');
  check([
    'not_required', 'pending', 'approved', 'rejected',
  ].includes(node.professional_review_status), 'W38_NODE_REVIEW_INVALID');
  check(node.taxonomy_version === TAXONOMY_VERSION, 'W38_NODE_VERSION_MISMATCH');
  check(typeof node.has_children === 'boolean', 'W38_NODE_SHAPE_INVALID');
}

function validateAlias(alias) {
  check(typeof alias.alias_locator === 'string' && alias.alias_locator.trim(), 'W38_ALIAS_LOCATOR_INVALID');
  check([
    'RESOLVED', 'AMBIGUOUS', 'TOMBSTONE', 'UNRESOLVED',
  ].includes(alias.resolution_state), 'W38_ALIAS_STATE_INVALID');
  check(alias.taxonomy_version === TAXONOMY_VERSION, 'W38_ALIAS_VERSION_MISMATCH');
  if (alias.resolution_state === 'RESOLVED') {
    check(UUID_PATTERN.test(alias.direct_target_category_id), 'W38_ALIAS_TARGET_INVALID');
  } else {
    check(alias.direct_target_category_id === null, 'W38_ALIAS_NONRESOLVED_TARGET');
  }
}

function validateCapability(capability) {
  check(capability.contract_version === CLIENT_VERSION, 'W38_CAPABILITY_CLIENT_VERSION');
  check(capability.client_contract_version === CLIENT_VERSION, 'W38_CAPABILITY_EXPLICIT_CLIENT_VERSION');
  check(capability.taxonomy_version === TAXONOMY_VERSION, 'W38_CAPABILITY_TAXONOMY_VERSION');
  check(capability.taxonomy_data_version === TAXONOMY_VERSION, 'W38_CAPABILITY_DATA_VERSION');
  check(capability.rpc_contract_version === RPC_VERSION, 'W38_CAPABILITY_RPC_VERSION');
  check(capability.rpc_generation === 2, 'W38_CAPABILITY_GENERATION');
  check(capability.preview_support === true, 'W38_CAPABILITY_PREVIEW_SUPPORT');
  check(capability.preview_enabled === false, 'W38_CAPABILITY_PREVIEW_DEFAULT');
  check(
    capability.product_scope_contract ===
      'exact-leaf-visible-assignable-policy-eligible',
    'W38_CAPABILITY_PRODUCT_SCOPE_CONTRACT',
  );
  check(
    capability.product_scope_requires_assignable === true,
    'W38_CAPABILITY_PRODUCT_SCOPE_ASSIGNABILITY',
  );
  check(
    capability.product_scope_policy_fail_closed === true,
    'W38_CAPABILITY_PRODUCT_SCOPE_POLICY',
  );
  check(capability.supported_features.length === 7, 'W38_CAPABILITY_FEATURE_COUNT');
  check(capability.verified_evidence.length === 7, 'W38_CAPABILITY_EVIDENCE_COUNT');
}

function validateFixtureSet(capability, fixtureSet) {
  validateCapability(capability);
  check(fixtureSet.contract === 'w38-strict-response-fixtures-v1', 'W38_FIXTURE_CONTRACT');
  const nodes = new Map();
  for (const node of fixtureSet.nodes) {
    validateNode(node);
    check(!nodes.has(node.fixture), `W38_DUPLICATE_NODE_FIXTURE:${node.fixture}`);
    nodes.set(node.fixture, node);
  }
  for (const alias of fixtureSet.aliases) validateAlias(alias);
  for (const search of fixtureSet.search_results) {
    const matched = nodes.get(search.matched_node_fixture);
    const path = search.path_fixtures.map((name) => nodes.get(name));
    check(matched, 'W38_SEARCH_MATCH_FIXTURE_MISSING');
    check(path.length > 0 && path.every(Boolean), 'W38_SEARCH_PATH_FIXTURE_MISSING');
    check(path.at(-1).id === matched.id, 'W38_SEARCH_PATH_TERMINUS');
    check(search.taxonomy_version === TAXONOMY_VERSION, 'W38_SEARCH_VERSION_MISMATCH');
    if (search.alias_context !== null) {
      check(search.alias_context.matched_text.trim(), 'W38_SEARCH_ALIAS_TEXT');
      check(search.alias_context.locator.trim(), 'W38_SEARCH_ALIAS_LOCATOR');
    }
  }
  return {
    node_fixtures: fixtureSet.nodes.length,
    alias_fixtures: fixtureSet.aliases.length,
    search_fixtures: fixtureSet.search_results.length,
  };
}

function validateCandidateStatic(candidate, rollback) {
  check(!candidate.includes('tnipyxnvhgelwdpykyez'), 'W38_DEVELOPMENT_REF_EMBEDDED');
  check(!candidate.includes('mefhfvrgkwciubeajjeb'), 'W38_PRODUCTION_REF_EMBEDDED');
  check(!/service[_-]?role[_-]?key/i.test(candidate), 'W38_SERVICE_SECRET_MARKER');
  check(!/CREATE\s+OR\s+REPLACE\s+FUNCTION\s+public\.taxonomy_[a-z_]+_v1/i.test(candidate), 'W38_V1_REPLACEMENT');
  check(!/DROP\s+FUNCTION[^;]*taxonomy_[a-z_]+_v1/i.test(candidate + rollback), 'W38_V1_DROP');
  check(!/(INSERT\s+INTO|UPDATE|DELETE\s+FROM)\s+public\.(categories|taxonomy_aliases|taxonomy_alias_targets|taxonomy_node_relationships|taxonomy_id_allocations)/i.test(candidate), 'W38_TAXONOMY_CONTENT_MUTATION');
  check(/preview_enabled\s+BOOLEAN\s+NOT\s+NULL\s+DEFAULT\s+false/i.test(candidate), 'W38_PREVIEW_DEFAULT_NOT_FALSE');
  check(/GRANT\s+EXECUTE\s+ON\s+FUNCTION\s+public\.taxonomy_set_preview_v2\(BOOLEAN,\s*TEXT\)\s+TO\s+service_role/i.test(candidate), 'W38_TRUSTED_CONTROL_GRANT_MISSING');
  check(/REVOKE\s+ALL\s+ON\s+TABLE\s+public\.taxonomy_contract_config\s+FROM\s+PUBLIC,\s*anon,\s*authenticated/i.test(candidate), 'W38_CONFIG_REVOKE_MISSING');

  const blocks = [...candidate.matchAll(
    /CREATE OR REPLACE FUNCTION\s+public\.([a-z0-9_]+)\([\s\S]*?\)\s+[\s\S]*?AS \$fn\$[\s\S]*?\$fn\$;/g,
  )];
  check(blocks.length === 13, `W38_FUNCTION_BLOCK_COUNT:${blocks.length}`);
  for (const match of blocks) {
    if (/SECURITY DEFINER/i.test(match[0])) {
      check(
        /SET search_path = pg_catalog, public/i.test(match[0]),
        `W38_UNSAFE_SEARCH_PATH:${match[1]}`,
      );
      check(!/EXECUTE\s+format\s*\(/i.test(match[0]), `W38_DYNAMIC_SQL:${match[1]}`);
    }
  }
  const exactLeafBlock = blocks.find((match) => match[1] === 'taxonomy_exact_leaf_v2')?.[0];
  check(exactLeafBlock, 'W38_EXACT_LEAF_FUNCTION_MISSING');
  check(/c\.is_assignable\s*=\s*true/i.test(exactLeafBlock), 'W38_EXACT_LEAF_ASSIGNABILITY_GUARD');
  check(/c\.policy_class\s*<>\s*'EXCLUDED'/i.test(exactLeafBlock), 'W38_EXACT_LEAF_POLICY_GUARD');
  check(
    /c\.professional_review_status\s+NOT\s+IN\s*\(\s*'pending'\s*,\s*'rejected'\s*\)/i.test(exactLeafBlock),
    'W38_EXACT_LEAF_REVIEW_GUARD',
  );
  check(
    candidate.includes("'exact-leaf-visible-assignable-policy-eligible'::TEXT"),
    'W38_CAPABILITY_PRODUCT_SCOPE_PROOF',
  );
  for (const endpoint of V2_PUBLIC_RPCS) {
    check(candidate.includes(`public.${endpoint}(`), `W38_ENDPOINT_MISSING:${endpoint}`);
  }
  check(!/(INSERT\s+INTO|UPDATE|DELETE\s+FROM)\s+public\.categories/i.test(rollback), 'W38_ROLLBACK_CATEGORY_MUTATION');
  return { function_blocks: blocks.length, public_endpoints: V2_PUBLIC_RPCS.length };
}

async function verifyArtifacts(contractRoot, candidate, rollback, capabilityText, fixturesText) {
  const manifestPath = join(contractRoot, 'artifact_manifest.json');
  const manifest = JSON.parse(await readFile(manifestPath, 'utf8'));
  const values = {
    [CANDIDATE_NAME]: candidate,
    [ROLLBACK_NAME]: rollback,
    'capability_response.json': capabilityText,
    'strict_response_fixtures.json': fixturesText,
  };
  for (const [name, content] of Object.entries(values)) {
    const expected = manifest.artifacts[name];
    check(expected, `W38_ARTIFACT_MANIFEST_ENTRY:${name}`);
    check(Buffer.byteLength(content) === expected.bytes, `W38_ARTIFACT_BYTES:${name}`);
    check(sha256(content) === expected.sha256, `W38_ARTIFACT_SHA:${name}`);
  }
  const core = structuredClone(manifest);
  delete core.artifact_set_sha256;
  check(sha256(stableJson(core)) === manifest.artifact_set_sha256, 'W38_ARTIFACT_SET_SHA');
  return manifest;
}

async function createPlatformBaseline(database) {
  await database.exec(`
    CREATE ROLE anon NOLOGIN;
    CREATE ROLE authenticated NOLOGIN;
    CREATE ROLE service_role NOLOGIN BYPASSRLS;
    CREATE SCHEMA auth;
    CREATE SCHEMA extensions;
    CREATE SCHEMA storage;
    CREATE SCHEMA supabase_migrations;
    CREATE TABLE supabase_migrations.schema_migrations (
      version TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      statements TEXT[]
    );
    CREATE TABLE auth.users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT,
      raw_user_meta_data JSONB NOT NULL DEFAULT '{}'::JSONB
    );
    CREATE FUNCTION auth.uid()
    RETURNS UUID LANGUAGE sql STABLE
    AS $$ SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::UUID $$;
    CREATE FUNCTION auth.role()
    RETURNS TEXT LANGUAGE sql STABLE
    AS $$ SELECT NULLIF(current_setting('request.jwt.claim.role', true), '') $$;
    CREATE FUNCTION extensions.gen_random_bytes(byte_count INTEGER)
    RETURNS BYTEA LANGUAGE sql VOLATILE AS $$
      SELECT decode(
        substring(
          replace(gen_random_uuid()::TEXT, '-', '') ||
          replace(gen_random_uuid()::TEXT, '-', '')
          FROM 1 FOR byte_count * 2
        ),
        'hex'
      )
    $$;
    CREATE TABLE storage.buckets (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      public BOOLEAN NOT NULL DEFAULT false,
      file_size_limit BIGINT,
      allowed_mime_types TEXT[]
    );
    CREATE TABLE storage.objects (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      bucket_id TEXT NOT NULL REFERENCES storage.buckets(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
    CREATE PUBLICATION supabase_realtime;
  `);
}

async function applyBaselineMigrations(database, repoRoot) {
  const directory = join(repoRoot, 'supabase', 'migrations');
  const files = (await readdir(directory)).filter((name) => name.endsWith('.sql')).sort();
  check(files.length === 10, `W38_ACTIVE_MIGRATION_COUNT:${files.length}`);
  for (let index = 0; index < files.length; index += 1) {
    let sql = canonicalText(await readFile(join(directory, files[index]), 'utf8'), files[index]);
    sql = sql.replace(
      'CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;',
      '-- pgcrypto is supplied by Supabase and stubbed in this isolated rehearsal.',
    );
    await database.exec(sql);
    const [version, name] = BASELINE_LEDGER[index];
    await database.query(
      'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
      [version, name, []],
    );
  }
  return files;
}

async function categorySnapshot(database) {
  const rows = (await database.query(`
    SELECT id::TEXT, parent_id::TEXT, name, slug, level, sort_order,
      lifecycle_state, is_active, is_assignable, policy_class,
      professional_review_status, taxonomy_version
    FROM public.categories
    WHERE taxonomy_version = '${TAXONOMY_VERSION}'
    ORDER BY id
  `)).rows;
  const levels = {};
  for (const row of rows) levels[row.level] = (levels[row.level] ?? 0) + 1;
  const leaves = Number(await scalar(database, `
    SELECT count(*)::INTEGER
    FROM public.categories AS c
    WHERE c.taxonomy_version = '${TAXONOMY_VERSION}'
      AND NOT EXISTS (
        SELECT 1 FROM public.categories AS child
        WHERE child.parent_id = c.id
          AND child.taxonomy_version = c.taxonomy_version
      )
  `));
  return {
    nodes: rows.length,
    levels,
    leaves,
    uuid_unique: Number(await scalar(database, `
      SELECT count(DISTINCT id)::INTEGER FROM public.categories
      WHERE taxonomy_version = '${TAXONOMY_VERSION}'
    `)),
    public_active: Number(await scalar(database, `
      SELECT count(*)::INTEGER FROM public.categories
      WHERE taxonomy_version = '${TAXONOMY_VERSION}'
        AND lifecycle_state = 'active' AND is_active = true
    `)),
    pilot_active: Number(await scalar(database, `
      SELECT count(*)::INTEGER FROM public.categories
      WHERE taxonomy_version = '${TAXONOMY_VERSION}'
        AND lifecycle_state = 'pilot_active'
    `)),
    policy_leakage: Number(await scalar(database, `
      SELECT count(*)::INTEGER FROM public.categories
      WHERE taxonomy_version = '${TAXONOMY_VERSION}'
        AND policy_class <> 'NORMAL' AND is_active = true
    `)),
    ledger: Number(await scalar(database, 'SELECT count(*)::INTEGER FROM supabase_migrations.schema_migrations')),
    digest: sha256(stableJson(rows)),
  };
}

function assertCanonicalSnapshot(snapshot, ledgerCount) {
  check(snapshot.nodes === 1563, 'W38_SNAPSHOT_NODE_COUNT');
  check(snapshot.levels['1'] === 24, 'W38_SNAPSHOT_L1');
  check(snapshot.levels['2'] === 244, 'W38_SNAPSHOT_L2');
  check(snapshot.levels['3'] === 1096, 'W38_SNAPSHOT_L3');
  check(snapshot.levels['4'] === 199, 'W38_SNAPSHOT_L4');
  check(snapshot.leaves === 1245, 'W38_SNAPSHOT_LEAVES');
  check(snapshot.uuid_unique === 1563, 'W38_SNAPSHOT_UUID');
  check(snapshot.public_active === 0, 'W38_SNAPSHOT_PUBLIC_ACTIVE');
  check(snapshot.pilot_active === 0, 'W38_SNAPSHOT_PILOT_ACTIVE');
  check(snapshot.policy_leakage === 0, 'W38_SNAPSHOT_POLICY_LEAKAGE');
  check(snapshot.ledger === ledgerCount, 'W38_SNAPSHOT_LEDGER');
}

async function v1Contract(database) {
  const rows = (await database.query(`
    SELECT p.proname,
      pg_get_function_identity_arguments(p.oid) AS arguments,
      pg_get_function_result(p.oid) AS result,
      p.prosecdef,
      p.proconfig
    FROM pg_catalog.pg_proc AS p
    JOIN pg_catalog.pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = ANY($1::TEXT[])
    ORDER BY p.proname
  `, [V1_RPCS])).rows;
  check(rows.length === 7, `W38_V1_RPC_COUNT:${rows.length}`);
  return { count: rows.length, digest: sha256(stableJson(rows)) };
}

async function withRole(database, role, operation) {
  await database.exec(`SET ROLE ${role}`);
  try {
    return await operation();
  } finally {
    try { await database.exec('RESET ROLE'); } catch { /* reset after failed statement */ }
  }
}

async function callRows(database, role, functionName, parameters, casts) {
  const placeholders = parameters.map((_, index) => `$${index + 1}::${casts[index]}`).join(',');
  return withRole(database, role, async () => (
    database.query(`SELECT * FROM public.${functionName}(${placeholders})`, parameters)
  ));
}

async function v1Smoke(database) {
  const unknown = '00000000-0000-4000-8000-000000000000';
  const calls = [
    ['taxonomy_roots_v1', [TAXONOMY_VERSION], ['TEXT']],
    ['taxonomy_children_v1', [unknown, TAXONOMY_VERSION], ['UUID', 'TEXT']],
    ['taxonomy_descendants_v1', [unknown, TAXONOMY_VERSION], ['UUID', 'TEXT']],
    ['taxonomy_exact_leaf_v1', [unknown, TAXONOMY_VERSION], ['UUID', 'TEXT']],
    ['taxonomy_breadcrumb_v1', [unknown, TAXONOMY_VERSION], ['UUID', 'TEXT']],
    ['taxonomy_resolve_alias_v1', ['w38-not-found', TAXONOMY_VERSION], ['TEXT', 'TEXT']],
    ['taxonomy_search_context_v1', ['w38-not-found', TAXONOMY_VERSION], ['TEXT', 'TEXT']],
  ];
  for (const [name, parameters, casts] of calls) {
    const result = await callRows(database, 'anon', name, parameters, casts);
    check(result.rows.length === 0, `W38_V1_SMOKE_RESULT:${name}`);
  }
  return calls.length;
}

async function strictPostcheck(database, baseline, v1Before) {
  const after = await categorySnapshot(database);
  assertCanonicalSnapshot(after, 11);
  check(after.digest === baseline.digest, 'W38_CATEGORY_DATA_CHANGED');
  const v1After = await v1Contract(database);
  check(v1After.digest === v1Before.digest, 'W38_V1_CONTRACT_CHANGED');
  const v2Count = Number(await scalar(database, `
    SELECT count(DISTINCT p.proname)::INTEGER
    FROM pg_catalog.pg_proc AS p
    JOIN pg_catalog.pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = ANY($1::TEXT[])
  `, [V2_PUBLIC_RPCS]));
  check(v2Count === 8, `W38_V2_RPC_COUNT:${v2Count}`);
  const preview = await scalar(database, 'SELECT preview_enabled FROM public.taxonomy_contract_config WHERE singleton_id=1');
  check(preview === false, 'W38_PREVIEW_NOT_DEFAULT_OFF');
  return after;
}

async function previewExercise(database) {
  const failures = [];
  const authoritativeBeforeFixtures = await categorySnapshot(database);
  const realLeaf = (await database.query(`
    SELECT c.id::TEXT, c.name, c.level, c.is_assignable,
      c.policy_class, c.professional_review_status
    FROM public.categories AS c
    WHERE c.taxonomy_version=$1
      AND NOT EXISTS (
        SELECT 1 FROM public.categories AS child
        WHERE child.parent_id=c.id
          AND child.taxonomy_version=c.taxonomy_version
      )
    ORDER BY c.level DESC,c.sort_order,c.id
    LIMIT 1
  `, [TAXONOMY_VERSION])).rows[0];
  check(realLeaf, 'W38_REAL_NON_ASSIGNABLE_LEAF_MISSING');
  check(realLeaf.is_assignable === false, 'W38_BASELINE_LEAF_UNEXPECTEDLY_ASSIGNABLE');

  const capabilityOff = await callRows(
    database, 'anon', 'taxonomy_capabilities_v2',
    [CLIENT_VERSION, TAXONOMY_VERSION], ['TEXT', 'TEXT'],
  );
  check(capabilityOff.rows.length === 1, 'W38_CAPABILITY_ROW');
  check(capabilityOff.rows[0].preview_enabled === false, 'W38_CAPABILITY_PREVIEW_OFF');
  check(capabilityOff.rows[0].rpc_contract_version === RPC_VERSION, 'W38_CAPABILITY_RPC');
  check(
    capabilityOff.rows[0].product_scope_requires_assignable === true,
    'W38_CAPABILITY_PRODUCT_SCOPE_ASSIGNABILITY_OFF',
  );
  check(
    capabilityOff.rows[0].product_scope_policy_fail_closed === true,
    'W38_CAPABILITY_PRODUCT_SCOPE_POLICY_OFF',
  );

  const publicRoots = await callRows(
    database, 'anon', 'taxonomy_roots_v2',
    [CLIENT_VERSION, TAXONOMY_VERSION, false], ['TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(publicRoots.rows.length === 0, 'W38_PUBLIC_ROOTS_NOT_ZERO');

  const stagedLeafWithoutPreview = await callRows(
    database, 'anon', 'taxonomy_exact_leaf_v2',
    [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, false],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(stagedLeafWithoutPreview.rows.length === 0, 'W38_STAGED_LEAF_WITHOUT_PREVIEW');
  failures.push(passedRegression(
    'preview_disabled_staged_leaf_exact_scope',
    'zero qualifying product-scope rows',
  ));

  failures.push(await expectedFailure(
    'preview_requested_while_disabled', 'W38_PREVIEW_DISABLED',
    () => callRows(
      database, 'anon', 'taxonomy_roots_v2',
      [CLIENT_VERSION, TAXONOMY_VERSION, true], ['TEXT', 'TEXT', 'BOOLEAN'],
    ),
  ));
  failures.push(await expectedFailure(
    'exact_leaf_preview_requested_while_disabled', 'W38_PREVIEW_DISABLED',
    () => callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    ),
  ));
  failures.push(await expectedFailure(
    'anon_direct_config_select', 'permission denied',
    () => withRole(database, 'anon', () => database.query('SELECT * FROM public.taxonomy_contract_config')),
  ));
  failures.push(await expectedFailure(
    'authenticated_direct_config_mutation', 'permission denied',
    () => withRole(database, 'authenticated', () => database.query('UPDATE public.taxonomy_contract_config SET preview_enabled=true')),
  ));
  failures.push(await expectedFailure(
    'ordinary_client_preview_enablement', 'permission denied',
    () => callRows(
      database, 'authenticated', 'taxonomy_set_preview_v2',
      [true, TAXONOMY_VERSION], ['BOOLEAN', 'TEXT'],
    ),
  ));
  failures.push(await expectedFailure(
    'client_contract_version_mismatch', 'W38_CLIENT_CONTRACT_VERSION_MISMATCH',
    () => callRows(
      database, 'anon', 'taxonomy_capabilities_v2',
      ['taxonomy-client-v0', TAXONOMY_VERSION], ['TEXT', 'TEXT'],
    ),
  ));
  failures.push(await expectedFailure(
    'taxonomy_data_version_mismatch', 'W38_TAXONOMY_VERSION_MISMATCH',
    () => callRows(
      database, 'anon', 'taxonomy_capabilities_v2',
      [CLIENT_VERSION, 'canonical-v0'], ['TEXT', 'TEXT'],
    ),
  ));
  failures.push(await expectedFailure(
    'malformed_uuid', 'invalid input syntax for type uuid',
    () => callRows(
      database, 'anon', 'taxonomy_children_v2',
      ['not-a-uuid', CLIENT_VERSION, TAXONOMY_VERSION, false],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    ),
  ));
  const nonexistent = await callRows(
    database, 'anon', 'taxonomy_children_v2',
    ['00000000-0000-4000-8000-000000000000', CLIENT_VERSION, TAXONOMY_VERSION, false],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(nonexistent.rows.length === 0, 'W38_NONEXISTENT_UUID_RESULT');
  const nonexistentExactLeaf = await callRows(
    database, 'anon', 'taxonomy_exact_leaf_v2',
    ['00000000-0000-4000-8000-000000000000', CLIENT_VERSION, TAXONOMY_VERSION, false],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(nonexistentExactLeaf.rows.length === 0, 'W38_NONEXISTENT_EXACT_LEAF_RESULT');
  failures.push(passedRegression(
    'nonexistent_uuid_exact_leaf',
    'safe empty result',
  ));

  const enabled = await callRows(
    database, 'service_role', 'taxonomy_set_preview_v2',
    [true, TAXONOMY_VERSION], ['BOOLEAN', 'TEXT'],
  );
  check(enabled.rows[0].taxonomy_set_preview_v2 === true, 'W38_PREVIEW_ENABLE_FAILED');

  const capabilityOn = await callRows(
    database, 'anon', 'taxonomy_capabilities_v2',
    [CLIENT_VERSION, TAXONOMY_VERSION], ['TEXT', 'TEXT'],
  );
  check(capabilityOn.rows[0].preview_enabled === true, 'W38_CAPABILITY_PREVIEW_ON');
  check(capabilityOn.rows[0].preview_root_count === 24, 'W38_CAPABILITY_ROOT_COUNT');
  check(
    capabilityOn.rows[0].product_scope_contract ===
      'exact-leaf-visible-assignable-policy-eligible',
    'W38_CAPABILITY_PRODUCT_SCOPE_ON',
  );

  const roots = await callRows(
    database, 'anon', 'taxonomy_roots_v2',
    [CLIENT_VERSION, TAXONOMY_VERSION, true], ['TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(roots.rows.length === 24, `W38_PREVIEW_ROOTS:${roots.rows.length}`);
  check(roots.rows.every((row) => row.lifecycle_state === 'staged' && row.is_public_active === false), 'W38_PREVIEW_ROOT_METADATA');

  const root = roots.rows.find((row) => row.has_children) ?? roots.rows[0];
  const children = await callRows(
    database, 'anon', 'taxonomy_children_v2',
    [root.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(children.rows.length > 0, 'W38_PREVIEW_CHILDREN_EMPTY');
  const descendants = await callRows(
    database, 'anon', 'taxonomy_descendants_v2',
    [root.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(descendants.rows.length > children.rows.length, 'W38_PREVIEW_DESCENDANTS_EMPTY');

  const realNonAssignableExact = await callRows(
    database, 'anon', 'taxonomy_exact_leaf_v2',
    [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(realNonAssignableExact.rows.length === 0, 'W38_NON_ASSIGNABLE_LEAF_QUALIFIED');
  const realLeafStructuralPath = await callRows(
    database, 'anon', 'taxonomy_breadcrumb_v2',
    [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(realLeafStructuralPath.rows.length === realLeaf.level, 'W38_REAL_LEAF_STRUCTURAL_PATH');
  check(
    realLeafStructuralPath.rows.at(-1).id === realLeaf.id &&
      realLeafStructuralPath.rows.at(-1).has_children === false,
    'W38_REAL_LEAF_STRUCTURAL_PREVIEW',
  );
  failures.push(passedRegression(
    'real_non_assignable_leaf_exact_scope',
    'zero exact-leaf rows while structural breadcrumb remains visible',
  ));

  await database.exec('BEGIN');
  try {
    await database.query(
      'UPDATE public.categories SET is_assignable=true WHERE id=$1',
      [root.id],
    );
    const assignableContainer = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [root.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(assignableContainer.rows.length === 0, 'W38_ASSIGNABLE_CONTAINER_QUALIFIED');
    failures.push(passedRegression(
      'assignable_container_exact_scope',
      'zero rows because structural containers are not product scopes',
    ));
  } finally {
    await database.exec('ROLLBACK');
  }

  await database.exec('BEGIN');
  try {
    await database.query(`
      UPDATE public.categories
      SET is_assignable=true,
          policy_class='EXCLUDED',
          professional_review_status='approved'
      WHERE id=$1
    `, [realLeaf.id]);
    const policyInvalid = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(policyInvalid.rows.length === 0, 'W38_POLICY_INVALID_LEAF_QUALIFIED');
    failures.push(passedRegression(
      'policy_invalid_assignable_leaf_exact_scope',
      'zero rows for EXCLUDED policy',
    ));
  } finally {
    await database.exec('ROLLBACK');
  }

  await database.exec('BEGIN');
  try {
    await database.query(`
      UPDATE public.categories
      SET is_assignable=true,
          policy_class='REGULATED',
          professional_review_status='pending'
      WHERE id=$1
    `, [realLeaf.id]);
    const reviewInvalid = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(reviewInvalid.rows.length === 0, 'W38_REVIEW_INVALID_LEAF_QUALIFIED');
    failures.push(passedRegression(
      'professional_review_pending_assignable_leaf_exact_scope',
      'zero rows while professional review is pending',
    ));
  } finally {
    await database.exec('ROLLBACK');
  }

  await database.exec('BEGIN');
  try {
    await database.query(`
      UPDATE public.categories
      SET is_assignable=true,
          lifecycle_state='retired',
          is_active=false,
          policy_class='NORMAL',
          professional_review_status='not_required'
      WHERE id=$1
    `, [realLeaf.id]);
    const lifecycleInvalid = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(lifecycleInvalid.rows.length === 0, 'W38_RETIRED_LEAF_QUALIFIED');
    failures.push(passedRegression(
      'retired_assignable_leaf_exact_scope',
      'zero rows because retired nodes are not preview-visible',
    ));
  } finally {
    await database.exec('ROLLBACK');
  }

  await database.exec('BEGIN');
  try {
    await database.query(`
      UPDATE public.categories
      SET is_assignable=true,
          policy_class='NORMAL',
          professional_review_status='not_required'
      WHERE id=$1
    `, [realLeaf.id]);
    const positiveExactLeaf = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [realLeaf.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(positiveExactLeaf.rows.length === 1, 'W38_ASSIGNABLE_LEAF_NOT_QUALIFIED');
    check(
      positiveExactLeaf.rows[0].id === realLeaf.id &&
        positiveExactLeaf.rows[0].is_assignable === true &&
        positiveExactLeaf.rows[0].has_children === false,
      'W38_ASSIGNABLE_LEAF_RESPONSE_INVALID',
    );
    failures.push(passedRegression(
      'assignable_leaf_positive_local_fixture',
      'exactly one qualifying product-scope row',
    ));
  } finally {
    await database.exec('ROLLBACK');
  }
  const fixtureRollbackSnapshot = await categorySnapshot(database);
  check(
    fixtureRollbackSnapshot.digest === authoritativeBeforeFixtures.digest,
    'W38_PRODUCT_SCOPE_FIXTURE_LEAK',
  );

  const leafByLevel = {};
  for (const level of [2, 3, 4]) {
    const result = await database.query(`
      SELECT c.id::TEXT
      FROM public.categories AS c
      WHERE c.taxonomy_version=$1 AND c.level=$2
        AND NOT EXISTS (
          SELECT 1 FROM public.categories AS child
          WHERE child.parent_id=c.id AND child.taxonomy_version=c.taxonomy_version
        )
      ORDER BY c.sort_order,c.id LIMIT 1
    `, [TAXONOMY_VERSION, level]);
    check(result.rows.length === 1, `W38_REAL_LEAF_LEVEL_MISSING:${level}`);
    leafByLevel[level] = result.rows[0].id;
    const exactNonAssignable = await callRows(
      database, 'anon', 'taxonomy_exact_leaf_v2',
      [leafByLevel[level], CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(exactNonAssignable.rows.length === 0, `W38_NON_ASSIGNABLE_EXACT_LEAF_LEVEL:${level}`);
    const breadcrumb = await callRows(
      database, 'anon', 'taxonomy_breadcrumb_v2',
      [leafByLevel[level], CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(breadcrumb.rows.length === level, `W38_STRUCTURAL_LEAF_LEVEL:${level}`);
    check(breadcrumb.rows.at(-1).has_children === false, `W38_STRUCTURAL_LEAF_SHAPE:${level}`);
  }

  const l4Breadcrumb = await callRows(
    database, 'anon', 'taxonomy_breadcrumb_v2',
    [leafByLevel[4], CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(l4Breadcrumb.rows.length === 4, 'W38_L4_BREADCRUMB');
  check(l4Breadcrumb.rows.at(-1).id === leafByLevel[4], 'W38_BREADCRUMB_TERMINUS');

  const searchTerm = l4Breadcrumb.rows.at(-1).name;
  const search = await callRows(
    database, 'anon', 'taxonomy_search_context_v2',
    [searchTerm, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['TEXT', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(search.rows.length >= 1, 'W38_SEARCH_RESULT_EMPTY');
  check(search.rows[0].path.length >= 1, 'W38_SEARCH_PATH_EMPTY');
  check(search.rows[0].matched_node.taxonomy_version === TAXONOMY_VERSION, 'W38_SEARCH_NODE_VERSION');

  const aliasRows = [];
  const aliasSummary = (await database.query(`
    SELECT taxonomy_version,resolution_state,is_active,count(*)::INTEGER AS count
    FROM public.taxonomy_aliases
    GROUP BY taxonomy_version,resolution_state,is_active
    ORDER BY taxonomy_version,resolution_state,is_active
  `)).rows;
  for (const state of ['RESOLVED', 'AMBIGUOUS', 'TOMBSTONE', 'UNRESOLVED']) {
    const result = await database.query(`
      SELECT a.alias_locator, a.resolution_state,
        coalesce(a.alias_text,a.alias_slug,a.alias_locator) AS search_term
      FROM public.taxonomy_aliases AS a
      WHERE a.taxonomy_version=$1
        AND a.resolution_state=$2
      ORDER BY a.alias_locator
      LIMIT 1
    `, [TAXONOMY_VERSION, state]);
    if (result.rows.length === 1) aliasRows.push(result.rows[0]);
  }
  check(
    aliasRows.length === 4,
    `W38_ALIAS_STATE_FIXTURES:${aliasRows.length}:${JSON.stringify(aliasSummary)}`,
  );
  for (const alias of aliasRows) {
    const result = await callRows(
      database, 'anon', 'taxonomy_resolve_alias_v2',
      [alias.alias_locator, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ['TEXT', 'TEXT', 'TEXT', 'BOOLEAN'],
    );
    check(result.rows.length === 1, `W38_ALIAS_RESULT:${alias.resolution_state}`);
    check(result.rows[0].resolution_state === alias.resolution_state, `W38_ALIAS_STATE:${alias.resolution_state}`);
    if (alias.resolution_state === 'RESOLVED') {
      const aliasSearch = await callRows(
        database, 'anon', 'taxonomy_search_context_v2',
        [alias.search_term, CLIENT_VERSION, TAXONOMY_VERSION, true],
        ['TEXT', 'TEXT', 'TEXT', 'BOOLEAN'],
      );
      check(aliasSearch.rows.some((row) => row.matched_via_alias), 'W38_ALIAS_SEARCH_CONTEXT');
    }
  }

  const policyNode = (await database.query(`
    SELECT id::TEXT FROM public.categories
    WHERE taxonomy_version=$1 AND policy_class<>'NORMAL'
    ORDER BY level DESC,id LIMIT 1
  `, [TAXONOMY_VERSION])).rows[0];
  check(policyNode, 'W38_POLICY_FIXTURE_MISSING');
  const policyPath = await callRows(
    database, 'anon', 'taxonomy_breadcrumb_v2',
    [policyNode.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(policyPath.rows.at(-1).policy_class !== 'NORMAL', 'W38_POLICY_METADATA_MISSING');
  check(policyPath.rows.at(-1).is_assignable === false, 'W38_POLICY_ASSIGNABILITY_LEAK');

  const professionalNode = (await database.query(`
    SELECT id::TEXT FROM public.categories
    WHERE taxonomy_version=$1 AND professional_review_status<>'not_required'
    ORDER BY level DESC,id LIMIT 1
  `, [TAXONOMY_VERSION])).rows[0];
  check(professionalNode, 'W38_PROFESSIONAL_FIXTURE_MISSING');
  const professionalPath = await callRows(
    database, 'anon', 'taxonomy_breadcrumb_v2',
    [professionalNode.id, CLIENT_VERSION, TAXONOMY_VERSION, true],
    ['UUID', 'TEXT', 'TEXT', 'BOOLEAN'],
  );
  check(professionalPath.rows.at(-1).professional_review_status !== 'not_required', 'W38_PROFESSIONAL_METADATA_MISSING');

  const ambiguous = aliasRows.find((row) => row.resolution_state === 'AMBIGUOUS');
  await database.exec('BEGIN');
  try {
    await database.query(`
      DELETE FROM public.taxonomy_alias_targets
      WHERE alias_id=(
        SELECT id FROM public.taxonomy_aliases
        WHERE taxonomy_version=$1 AND alias_locator=$2
      )
    `, [TAXONOMY_VERSION, ambiguous.alias_locator]);
    failures.push(await expectedFailure(
      'ambiguous_alias_without_target_edges', 'W38_ALIAS_GRAPH_INVALID',
      () => database.query(
        'SELECT * FROM public.taxonomy_resolve_alias_v2($1,$2,$3,$4)',
        [ambiguous.alias_locator, CLIENT_VERSION, TAXONOMY_VERSION, true],
      ),
    ));
  } finally {
    await database.exec('ROLLBACK');
  }

  const disabled = await callRows(
    database, 'service_role', 'taxonomy_set_preview_v2',
    [false, TAXONOMY_VERSION], ['BOOLEAN', 'TEXT'],
  );
  check(disabled.rows[0].taxonomy_set_preview_v2 === false, 'W38_PREVIEW_DISABLE_FAILED');
  const capabilityOffAgain = await callRows(
    database, 'anon', 'taxonomy_capabilities_v2',
    [CLIENT_VERSION, TAXONOMY_VERSION], ['TEXT', 'TEXT'],
  );
  check(capabilityOffAgain.rows[0].preview_enabled === false, 'W38_PREVIEW_NOT_DISABLED');
  failures.push(await expectedFailure(
    'preview_unavailable_after_disable', 'W38_PREVIEW_DISABLED',
    () => callRows(
      database, 'anon', 'taxonomy_roots_v2',
      [CLIENT_VERSION, TAXONOMY_VERSION, true], ['TEXT', 'TEXT', 'BOOLEAN'],
    ),
  ));

  return {
    failures,
    roots: roots.rows.length,
    children: children.rows.length,
    descendants: descendants.rows.length,
    breadcrumb_depth: l4Breadcrumb.rows.length,
    search_results: search.rows.length,
    alias_states: aliasRows.map((row) => row.resolution_state).sort(),
    policy_metadata: true,
    professional_review_metadata: true,
    product_scope: {
      authoritative_leaf_name: realLeaf.name,
      authoritative_leaf_level: realLeaf.level,
      authoritative_is_assignable: realLeaf.is_assignable,
      non_assignable_exact_leaf_rows: realNonAssignableExact.rows.length,
      positive_fixture_exact_leaf_rows: 1,
      fixture_rollback: fixtureRollbackSnapshot.digest === authoritativeBeforeFixtures.digest,
      structural_preview_preserved: true,
    },
  };
}

async function runCycle({ index, repoRoot, pgliteRoot, candidate, rollback, idempotent }) {
  const database = await openPGlite(pgliteRoot);
  const cycleFailures = [];
  try {
    await createPlatformBaseline(database);
    const migrations = await applyBaselineMigrations(database, repoRoot);
    const baseline = await categorySnapshot(database);
    assertCanonicalSnapshot(baseline, 10);
    const v1Before = await v1Contract(database);

    if (index === 1) {
      await database.query(
        'DELETE FROM supabase_migrations.schema_migrations WHERE version=$1',
        [BASELINE_LEDGER.at(-1)[0]],
      );
      cycleFailures.push(await expectedFailure(
        'migration_ledger_mismatch', 'W38_MIGRATION_LEDGER_MISMATCH',
        () => database.exec(candidate),
      ));
      await database.exec('ROLLBACK');
      await database.query(
        'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
        [...BASELINE_LEDGER.at(-1), []],
      );

      const activationTarget = (await database.query(`
        SELECT id FROM public.categories
        WHERE taxonomy_version=$1 ORDER BY id LIMIT 1
      `, [TAXONOMY_VERSION])).rows[0].id;
      await database.query(
        "UPDATE public.categories SET lifecycle_state='active',is_active=true WHERE id=$1",
        [activationTarget],
      );
      cycleFailures.push(await expectedFailure(
        'unexpected_public_activation', 'W38_UNEXPECTED_PUBLIC_ACTIVATION',
        () => database.exec(candidate),
      ));
      await database.exec('ROLLBACK');
      await database.query(
        "UPDATE public.categories SET lifecycle_state='staged',is_active=false WHERE id=$1",
        [activationTarget],
      );
      check((await categorySnapshot(database)).digest === baseline.digest, 'W38_FAILURE_FIXTURE_RESTORE');
    }

    await database.exec(candidate);
    if (idempotent) await database.exec(candidate);
    await database.query(
      'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
      [CANDIDATE_LEDGER.version, CANDIDATE_LEDGER.name, []],
    );
    await strictPostcheck(database, baseline, v1Before);
    const v1SmokeCount = await v1Smoke(database);
    const preview = await previewExercise(database);
    cycleFailures.push(...preview.failures);
    const afterPreview = await categorySnapshot(database);
    check(afterPreview.digest === baseline.digest, 'W38_PREVIEW_MUTATED_TAXONOMY');
    check(afterPreview.public_active === 0 && afterPreview.pilot_active === 0, 'W38_PREVIEW_ACTIVATION_LEAK');

    if (index === 1) {
      await database.exec('BEGIN');
      try {
        await database.exec('DROP FUNCTION public.taxonomy_roots_v1(TEXT)');
        cycleFailures.push(await expectedFailure(
          'existing_v1_rpc_breakage', 'W38_V1_RPC_COUNT',
          () => v1Contract(database),
        ));
      } finally {
        await database.exec('ROLLBACK');
      }

      const interrupted = rollback.replace(
        '\nCOMMIT;\n',
        '\nSELECT 1 / 0; -- W38_INJECTED_ROLLBACK_FAILURE\nCOMMIT;\n',
      );
      cycleFailures.push(await expectedFailure(
        'rollback_interruption', 'division by zero',
        () => database.exec(interrupted),
      ));
      try { await database.exec('ROLLBACK'); } catch { /* transaction already rolled back */ }
      check(toBoolean(await scalar(database, "SELECT to_regclass('public.taxonomy_contract_config') IS NOT NULL")), 'W38_INTERRUPTED_ROLLBACK_PARTIAL');
    }

    await database.query(
      'DELETE FROM supabase_migrations.schema_migrations WHERE version=$1 AND name=$2',
      [CANDIDATE_LEDGER.version, CANDIDATE_LEDGER.name],
    );
    await database.exec(rollback);
    const afterRollback = await categorySnapshot(database);
    assertCanonicalSnapshot(afterRollback, 10);
    check(afterRollback.digest === baseline.digest, 'W38_ROLLBACK_TAXONOMY_DRIFT');
    check((await v1Contract(database)).digest === v1Before.digest, 'W38_ROLLBACK_V1_DRIFT');
    check(
      !(await scalar(database, "SELECT to_regclass('public.taxonomy_contract_config') IS NOT NULL")),
      'W38_ROLLBACK_CONFIG_REMAINS',
    );
    return {
      cycle: index,
      baseline_migrations: migrations.length,
      baseline,
      forward: 'PASS',
      idempotent_second_apply: idempotent ? 'PASS' : 'NOT_RUN',
      postcheck: 'PASS',
      preview,
      v1_compatibility: `${v1SmokeCount}/7 PASS`,
      rollback: 'PASS',
      failures: cycleFailures,
    };
  } finally {
    await database.close();
  }
}

function toBoolean(value) {
  return value === true || value === 't' || value === 1;
}

async function main() {
  check(process.argv.includes('--local'), 'W38_LOCAL_FLAG_REQUIRED');
  check(!process.argv.some((value) => [
    '--remote', '--development', '--production', '--apply-remote', '--url', '--access-token',
  ].includes(value)), 'W38_REMOTE_MODE_FORBIDDEN');
  const repoRoot = resolve(argument('--repo-root', process.cwd()));
  const pgliteRoot = resolve(argument('--pglite-root', ''));
  check(pgliteRoot, 'W38_PGLITE_ROOT_REQUIRED');
  const contractRoot = join(repoRoot, 'tool', 'taxonomy_contract_v2');
  const candidate = canonicalText(
    await readFile(join(contractRoot, 'sql', CANDIDATE_NAME), 'utf8'),
    CANDIDATE_NAME,
  );
  const rollback = canonicalText(
    await readFile(join(contractRoot, 'sql', ROLLBACK_NAME), 'utf8'),
    ROLLBACK_NAME,
  );
  const capabilityText = canonicalText(
    await readFile(join(contractRoot, 'fixtures', 'capability_response.json'), 'utf8'),
    'capability_response.json',
  );
  const fixturesText = canonicalText(
    await readFile(join(contractRoot, 'fixtures', 'strict_response_fixtures.json'), 'utf8'),
    'strict_response_fixtures.json',
  );
  const manifest = await verifyArtifacts(
    contractRoot, candidate, rollback, capabilityText, fixturesText,
  );
  const staticContract = validateCandidateStatic(candidate, rollback);
  const capability = JSON.parse(capabilityText);
  const fixtureSet = JSON.parse(fixturesText);
  const fixtureCounts = validateFixtureSet(capability, fixtureSet);

  const staticFailures = [];
  const sampleNode = structuredClone(fixtureSet.nodes[0]);
  delete sampleNode.lifecycle_state;
  staticFailures.push(expectedSyncFailure(
    'missing_lifecycle_field', 'W38_NODE_FIELD_MISSING:lifecycle_state',
    () => validateNode(sampleNode),
  ));
  const missingPolicy = structuredClone(fixtureSet.nodes[0]);
  delete missingPolicy.policy_class;
  staticFailures.push(expectedSyncFailure(
    'missing_policy_field', 'W38_NODE_FIELD_MISSING:policy_class',
    () => validateNode(missingPolicy),
  ));
  const badLevel = { ...fixtureSet.nodes[0], level: 5 };
  staticFailures.push(expectedSyncFailure(
    'invalid_level_hierarchy', 'W38_NODE_LEVEL_INVALID', () => validateNode(badLevel),
  ));
  const badAlias = { ...fixtureSet.aliases[0], resolution_state: 'GUESSED' };
  staticFailures.push(expectedSyncFailure(
    'malformed_alias_state', 'W38_ALIAS_STATE_INVALID', () => validateAlias(badAlias),
  ));
  const badFixtureVersion = { ...fixtureSet.nodes[0], taxonomy_version: 'canonical-v0' };
  staticFailures.push(expectedSyncFailure(
    'strict_fixture_taxonomy_version_mismatch', 'W38_NODE_VERSION_MISMATCH',
    () => validateNode(badFixtureVersion),
  ));
  staticFailures.push(expectedSyncFailure(
    'candidate_checksum_mismatch', 'W38_ARTIFACT_SHA', () => {
      const expected = manifest.artifacts[CANDIDATE_NAME].sha256;
      check(sha256(`${candidate}\n`) === expected, `W38_ARTIFACT_SHA:${CANDIDATE_NAME}`);
    },
  ));
  staticFailures.push(expectedSyncFailure(
    'security_definer_unsafe_search_path', 'W38_UNSAFE_SEARCH_PATH', () => {
      validateCandidateStatic(
        candidate.replace('SET search_path = pg_catalog, public', 'SET search_path = public'),
        rollback,
      );
    },
  ));

  const cycles = [];
  for (let index = 1; index <= 3; index += 1) {
    cycles.push(await runCycle({
      index,
      repoRoot,
      pgliteRoot,
      candidate,
      rollback,
      idempotent: index <= 2,
    }));
  }
  const databaseFailures = cycles.flatMap((cycle) => cycle.failures);
  const failureNames = new Set();
  const failures = [...staticFailures, ...databaseFailures].filter((failure) => {
    if (failureNames.has(failure.name)) return false;
    failureNames.add(failure.name);
    return true;
  });
  check(failures.every((failure) => failure.result === 'PASS'), 'W38_FAILURE_MATRIX');

  const result = {
    status: 'PASS',
    mode: 'LOCAL_ONLY',
    candidate: CANDIDATE_NAME,
    artifact_manifest: manifest,
    static_contract: staticContract,
    fixture_counts: fixtureCounts,
    baseline_rebuilds: cycles.length,
    forward_applies: cycles.length,
    rollbacks: cycles.length,
    idempotent_second_applies: cycles.filter(
      (cycle) => cycle.idempotent_second_apply === 'PASS',
    ).length,
    postchecks: cycles.length,
    preview_cycles: cycles.map((cycle) => cycle.preview),
    v1_compatibility: '7/7 PASS',
    failure_matrix: failures,
    failure_matrix_passed: failures.length,
    frozen_taxonomy_preserved: true,
    remote_access_performed: false,
  };
  const output = argument('--output');
  if (output) await writeFile(resolve(output), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exitCode = 1;
});
