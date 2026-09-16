// Runs exclusively in an in-memory PostgreSQL-WASM database. No remote driver.
import { readFile, writeFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { parseCsv, sha256, stableJson, check, testOnlyUuid } from '../taxonomy_migration/lib.mjs';

check(process.argv.includes('--local'), 'LOCAL_FLAG_REQUIRED');
check(process.argv.every((a, i) => i < 2 || ['--local', '--pglite-root'].includes(a) || process.argv[i - 1] === '--pglite-root'), 'UNKNOWN_ARGUMENT');
const root = resolve(fileURLToPath(new URL('../..', import.meta.url)));
const packageRoot = resolve(process.argv[process.argv.indexOf('--pglite-root') + 1] || '');
check(process.argv.includes('--pglite-root'), 'PGLITE_ROOT_REQUIRED');
const { PGlite } = await import(pathToFileURL(resolve(packageRoot, 'dist/index.js')).href);
const read = async p => (await readFile(resolve(root, p), 'utf8')).replaceAll('\r\n', '\n');
const manifest = JSON.parse(await read('tool/production_taxonomy/artifact_manifest.json'));
const preflight = JSON.parse(await read('docs/data/w52h_production_preflight_manifest.json'));
const owner = JSON.parse(await read('docs/data/production_20_product_canonical_mapping_validation.json'));
const mapping = parseCsv(await read('docs/data/production_20_product_canonical_mapping.csv')).rows;
const categoryInput = parseCsv(await read('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')).rows;
const qualificationInput = parseCsv(await read('docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv')).rows;
const migration = await read(manifest.candidate);
check(sha256(migration) === manifest.sha256_lf_utf8, 'CANDIDATE_HASH_MISMATCH');
const old10 = await read('supabase/migrations/20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql');
const old11 = await read('supabase/migrations/20260830001100_0011_canonical_taxonomy_contract_v2.sql');
const activation = await read('tool/production_taxonomy/local_activation.sql');
const rollback = await read('tool/production_taxonomy/rollback.sql');
const client = 'production-taxonomy-client-v1';
const version = 'canonical-v1.0.0';
const first = async (db, query, args = []) => Object.values((await db.query(query, args)).rows[0])[0];

const apkFile = 'C:/Users/Mustafa/EsnaftavarReleases/w52c/1.0.0+1-main-4f0da82/EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.apk';
const apkHash = sha256(await readFile(apkFile));
check(apkHash === '096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a', 'FROZEN_APK_IDENTITY');
const sourceHead = '4f0da8201e2571200e99fa3dfe76387e3a1486ce';
const sourcePaths = [
 'lib/features/shop/data/repositories/category_repository_impl.dart',
 'lib/features/shop/data/repositories/product_repository_impl.dart',
 'lib/features/shop/data/repositories/shop_repository_impl.dart',
 'lib/core/dependency_injection/taxonomy_dependency_configuration.dart',
];
const sourceEvidence = sourcePaths.map(path => {
 const content = execFileSync('git', ['show', `${sourceHead}:${path}`], { cwd: root }).toString();
 return { path, sha256_lf_utf8: sha256(content.replaceAll('\r\n', '\n')), content };
});
check(sourceEvidence[0].content.includes(".isFilter('parent_id', null)"), 'LEGACY_HOME_SOURCE');
check(sourceEvidence[1].content.includes(".select('*, categories(name), brands(name)')"), 'LEGACY_PRODUCT_EMBED_SOURCE');
check(sourceEvidence[1].content.includes(".eq('category_id', categoryId)"), 'LEGACY_CATEGORY_FILTER_SOURCE');
check(sourceEvidence[1].content.includes("name.ilike.%$query%,description.ilike.%$query%"), 'LEGACY_SEARCH_SOURCE');
check(sourceEvidence[2].content.includes('products(*, categories(name), brands(name)), shops(*)'), 'LEGACY_SHOP_EMBED_SOURCE');
check(sourceEvidence[3].content.includes('this.runtimeRequest = TaxonomyRuntimeRequest.legacy'), 'LEGACY_RUNTIME_DEFAULT');

async function fixture(db) {
 await db.exec(`CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN; CREATE ROLE service_role NOLOGIN;
 CREATE SCHEMA auth; CREATE TABLE auth.users(id UUID PRIMARY KEY);
 CREATE FUNCTION auth.uid() RETURNS UUID LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
 CREATE TABLE public.profiles(id UUID PRIMARY KEY REFERENCES auth.users(id),role TEXT);
 CREATE FUNCTION public.set_updated_at() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at=now(); RETURN NEW; END $$;
 CREATE SCHEMA supabase_migrations;
 CREATE TABLE supabase_migrations.schema_migrations(version TEXT PRIMARY KEY,name TEXT NOT NULL,statements TEXT[]);
 `);
 const core = await read('supabase/migrations/20260812000100_0001_core_auth_catalog.sql');
 const shops = await read('supabase/migrations/20260812000200_0002_shops.sql');
 await db.exec(core.slice(core.indexOf('CREATE TABLE public.categories ('), core.indexOf('CREATE TABLE public.addresses (')));
 await db.exec(shops.slice(shops.indexOf('CREATE TABLE public.shops ('), shops.lastIndexOf('COMMIT;')));
 await db.exec(`ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
 ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY; ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
 CREATE POLICY categories_read_active ON public.categories FOR SELECT TO anon,authenticated USING(is_active=true);
 CREATE POLICY brands_read_active ON public.brands FOR SELECT TO anon,authenticated USING(is_active=true);
 CREATE POLICY products_read_active ON public.products FOR SELECT TO anon,authenticated USING(is_active=true);
 GRANT USAGE ON SCHEMA public,auth TO anon,authenticated;
 GRANT SELECT ON public.categories,public.brands,public.products,public.shops,public.shop_products,public.profiles TO anon,authenticated;
 `);
 for (const row of preflight.observed.migration_ledger) {
  await db.query('INSERT INTO supabase_migrations.schema_migrations VALUES($1,$2,$3)', [row.version, row.name, ['synthetic fixture ledger; historical scripts not applied remotely']]);
 }
 const roots = [...new Map(owner.evidence.map(p => [p.legacy_category_id, p.legacy_category])).entries()];
 for (let i = 0; i < roots.length; i++) {
  await db.query('INSERT INTO public.categories(id,name,sort_order,created_at,updated_at) VALUES($1,$2,$3,$4,$4)', [roots[i][0], roots[i][1], i, '2026-09-01T00:00:00Z']);
 }
 for (const p of owner.evidence) {
  await db.query(`INSERT INTO public.products(id,name,description,category_id,price,stock,created_at,updated_at)
   VALUES($1,$2,$3,$4,10,5,$5,$5)`, [p.product_id, p.product_name, p.description, p.legacy_category_id, '2026-09-01T00:00:00Z']);
 }
 // 57 synthetic shop IDs, 5 distinct listings each; all 20 real catalog product
 // IDs covered. No owner IDs, phone, address, coordinates, or customer data.
 for (let i = 0; i < 57; i++) {
  const shopId = testOnlyUuid(`W52H-SYNTHETIC-SHOP-${i}`);
  await db.query('INSERT INTO public.shops(id,name,created_at,updated_at) VALUES($1,$2,$3,$3)', [shopId, `Synthetic shop ${i + 1}`, '2026-09-01T00:00:00Z']);
  for (let j = 0; j < 5; j++) {
   const p = owner.evidence[(i * 5 + j) % 20];
   await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price,created_at,updated_at) VALUES($1,$2,$3,$4,$5,$5)', [testOnlyUuid(`W52H-SYNTHETIC-LISTING-${i}-${j}`), shopId, p.product_id, 10 + j, '2026-09-01T00:00:00Z']);
  }
 }
}

async function integrity(db, canonical = false) {
 const counts = {};
 for (const table of ['categories', 'products', 'shop_products', 'shops']) counts[table] = Number(await first(db, `SELECT count(*) FROM public.${table}`));
 check(stableJson(counts) === stableJson({ categories: 4, products: 20, shop_products: 285, shops: 57 }), 'LEGACY_COUNTS_CHANGED');
 const orphanProducts = Number(await first(db, 'SELECT count(*) FROM public.products p LEFT JOIN public.categories c ON c.id=p.category_id WHERE c.id IS NULL'));
 const orphanListings = Number(await first(db, 'SELECT count(*) FROM public.shop_products sp LEFT JOIN public.products p ON p.id=sp.product_id LEFT JOIN public.shops s ON s.id=sp.shop_id WHERE p.id IS NULL OR s.id IS NULL'));
 check(orphanProducts + orphanListings === 0, 'ORPHAN');
 const references = (await db.query('SELECT id::text,category_id::text FROM public.products ORDER BY id')).rows;
 check(stableJson(references) === stableJson(owner.evidence.map(p => ({ id: p.product_id, category_id: p.legacy_category_id })).sort((a, b) => a.id.localeCompare(b.id))), 'LEGACY_REFERENCES_CHANGED');
 if (!canonical) return { ...counts, orphan_products: orphanProducts, orphan_listings: orphanListings };
 const nodes = (await db.query('SELECT id::text,parent_id::text,name,source_key,slug,level,is_active,is_assignable,lifecycle_state,policy_class,professional_review_status,taxonomy_version FROM public.canonical_categories ORDER BY source_key')).rows;
 check(nodes.length === 1563 && nodes.filter(n => n.level === 1).length === 24, 'CANONICAL_NODE_COUNTS');
 const children = new Set(nodes.map(n => n.parent_id).filter(Boolean));
 check(nodes.filter(n => !children.has(n.id)).length === 1245, 'TERMINAL_COUNT');
 check(new Set(nodes.map(n => n.id)).size === 1563, 'DUPLICATE_CANONICAL_UUID');
 for (const n of nodes) {
  const expected = categoryInput.find(c => c.ID === n.id);
  check(expected && expected.PARENT_ID === (n.parent_id ?? '') && expected.NAME === n.name && Number(expected.LEVEL) === n.level, 'CANONICAL_IDENTITY_DRIFT');
  check(expected.POLICY_CLASS === n.policy_class && expected.PROFESSIONAL_REVIEW_STATUS === n.professional_review_status, 'POLICY_METADATA_CHANGED');
  check(!n.parent_id || nodes.some(p => p.id === n.parent_id && p.level === n.level - 1), 'BROKEN_PARENT');
 }
 const assignments = (await db.query('SELECT product_id::text,canonical_category_id::text,canonical_path FROM public.product_canonical_assignments ORDER BY product_id')).rows;
 check(stableJson(assignments) === stableJson(mapping.map(m => ({ product_id: m.PRODUCT_ID, canonical_category_id: m.PROPOSED_CANONICAL_UUID, canonical_path: m.PROPOSED_CANONICAL_PATH })).sort((a, b) => a.product_id.localeCompare(b.product_id))), 'EXACT_OWNER_MAPPING');
 check(assignments.every(a => !children.has(a.canonical_category_id)), 'NON_TERMINAL_PRODUCT');
 return { ...counts, canonical_nodes: nodes.length, canonical_roots: 24, terminal_leaves: 1245, exact_owner_mappings: assignments.length, orphan_products: orphanProducts, orphan_listings: orphanListings, broken_parent_chains: 0, duplicate_canonical_uuids: 0, invalid_product_targets: 0 };
}

async function legacyQueries(db, role) {
 await db.exec(`SET ROLE ${role}`);
 try {
  const queries = {
   home_categories: 'SELECT * FROM public.categories WHERE is_active AND parent_id IS NULL ORDER BY sort_order,id',
   product_listing: `SELECT c.id AS category_id,count(p.id)::int AS products FROM public.categories c LEFT JOIN public.products p ON p.category_id=c.id AND p.is_active WHERE c.is_active GROUP BY c.id ORDER BY c.id`,
   product_details: `SELECT to_jsonb(p)||jsonb_build_object('categories',jsonb_build_object('name',c.name),'brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) AS product FROM public.products p LEFT JOIN public.categories c ON c.id=p.category_id LEFT JOIN public.brands b ON b.id=p.brand_id WHERE p.is_active ORDER BY p.id`,
   seller_comparison: `SELECT sp.product_id,jsonb_agg(to_jsonb(sp)||jsonb_build_object('shops',to_jsonb(s),'products',to_jsonb(p)||jsonb_build_object('categories',jsonb_build_object('name',c.name),'brands',NULL)) ORDER BY sp.id) AS listings FROM public.shop_products sp JOIN public.shops s ON s.id=sp.shop_id JOIN public.products p ON p.id=sp.product_id JOIN public.categories c ON c.id=p.category_id WHERE sp.is_active AND sp.is_available AND s.is_active GROUP BY sp.product_id ORDER BY sp.product_id`,
   shop_details: `SELECT s.id, count(sp.id)::int AS listings, jsonb_agg(sp.id ORDER BY sp.id) AS listing_ids FROM public.shops s JOIN public.shop_products sp ON sp.shop_id=s.id WHERE s.is_active AND sp.is_active AND sp.is_available GROUP BY s.id ORDER BY s.id`,
   search: `SELECT p.id,p.category_id,c.name AS category_name FROM public.products p LEFT JOIN public.categories c ON c.id=p.category_id WHERE p.is_active AND (p.name ILIKE '%Kalem%' OR p.description ILIKE '%Kalem%') ORDER BY p.id LIMIT 50`,
  };
  const result = {};
  for (const [name, query] of Object.entries(queries)) {
   const rows = (await db.query(query)).rows;
   check(rows.length > 0, `LEGACY_QUERY_EMPTY:${name}`);
   result[name] = { rows: rows.length, result_sha256: sha256(stableJson(rows)) };
  }
  check(result.home_categories.rows === 4 && result.product_listing.rows === 4 && result.product_details.rows === 20 && result.shop_details.rows === 57 && result.seller_comparison.rows === 20, 'LEGACY_QUERY_SCOPE');
  return result;
 } finally { await db.exec('RESET ROLE'); }
}

async function expectFailure(db, name, operation, tag) {
 let failure;
 try { await operation(); } catch (e) { failure = String(e.message); }
 await db.exec('ROLLBACK');
 check(failure && (!tag || failure.includes(tag)), `EXPECTED_FAILURE:${name}:${failure}`);
 return { name, result: 'PASS', rejection: failure.split('\n')[0] };
}

async function legacyMetadata(db) {
 const tables = ['categories','products','brands','shops','shop_products'];
 return sha256(stableJson((await db.query(`SELECT
  (SELECT jsonb_agg(jsonb_build_object('table',c.relname,'rls',c.relrowsecurity,'forced',c.relforcerowsecurity,'acl',c.relacl) ORDER BY c.relname)
   FROM pg_class c WHERE c.relnamespace='public'::regnamespace AND c.relname=ANY($1::text[])) AS tables,
  (SELECT jsonb_agg(jsonb_build_object('table',tablename,'name',policyname,'using',qual,'check',with_check,'cmd',cmd,'roles',roles) ORDER BY tablename,policyname)
   FROM pg_policies WHERE schemaname='public' AND tablename=ANY($1::text[])) AS policies,
  (SELECT jsonb_agg(jsonb_build_object('table',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid)) ORDER BY conrelid::regclass::text,conname)
   FROM pg_constraint WHERE connamespace='public'::regnamespace AND conrelid IN(SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace AND relname=ANY($1::text[]))) AS constraints`, [tables])).rows));
}

async function canonicalQueries(db, active) {
 const rows = (await db.query('SELECT * FROM public.production_taxonomy_roots_v1($1,$2,false)', [client, version])).rows;
 const runtime = await first(db, 'SELECT public.production_taxonomy_runtime_v1()');
 check(runtime.public_enabled === active, 'PUBLIC_GATE');
 check(active ? rows.length > 0 : rows.length === 0, 'ROOT_VISIBILITY');
 const capabilities = (await db.query('SELECT * FROM public.production_taxonomy_capabilities_v1($1,$2)', [client, version])).rows[0];
 check(capabilities.rpc_generation === 1 && capabilities.preview_enabled === false && capabilities.preview_support === false, 'CAPABILITY');
 const productIds = new Set();
 for (const rootNode of rows) {
  const descendants = (await db.query('SELECT * FROM public.production_taxonomy_descendants_v1($1,$2,$3,false)', [rootNode.id, client, version])).rows;
  const childrenRows = (await db.query('SELECT * FROM public.production_taxonomy_children_v1($1,$2,$3,false)', [rootNode.id, client, version])).rows;
  check(descendants.length > 0 && childrenRows.every(n => n.parent_id === rootNode.id), 'TREE_CONTRACT');
  for (const n of descendants) {
   check(['id', 'parent_id', 'name', 'slug', 'level', 'lifecycle_state', 'is_assignable', 'policy_class', 'professional_review_status', 'taxonomy_version', 'has_children'].every(k => Object.hasOwn(n, k)), 'STRICT_DTO');
  }
  const products = (await db.query('SELECT * FROM public.production_taxonomy_products_v1($1,$2,$3,100,0)', [rootNode.id, client, version])).rows;
  for (const p of products) {
   check(p.product.category_id === p.canonical_category_id && p.product.legacy_category_id, 'NEW_PRODUCT_PROJECTION');
   productIds.add(p.product_id);
  }
 }
 if (active) {
  check(productIds.size === 14, 'SIX_POLICY_GATED_PRODUCTS_MUST_STAY_CLOSED');
  for (const m of mapping) {
   const q = qualificationInput.find(q => q.DEVELOPMENT_UUID === m.PROPOSED_CANONICAL_UUID);
   const leaf = (await db.query('SELECT * FROM public.production_taxonomy_exact_leaf_v1($1,$2,$3,false)', [m.PROPOSED_CANONICAL_UUID, client, version])).rows;
   const breadcrumb = (await db.query('SELECT * FROM public.production_taxonomy_breadcrumb_v1($1,$2,$3,false)', [m.PROPOSED_CANONICAL_UUID, client, version])).rows;
   if (q.QUALIFICATION === 'LEAF_ASSIGNABLE_CANDIDATE') {
    check(leaf.length === 1 && breadcrumb.length === Number(m.TARGET_LEVEL.slice(1)), 'LEAF_BREADCRUMB');
   } else check(leaf.length === 0 && breadcrumb.length === 0 && !productIds.has(m.PRODUCT_ID), 'POLICY_GATE_LEAK');
  }
 }
 const aliases = (await db.query('SELECT * FROM public.production_taxonomy_resolve_alias_v1($1,$2,$3,false)', ['powerbank', client, version])).rows;
 check(active ? aliases.length === 1 && aliases[0].direct_target_category_id === '1bd43c2b-adb9-42a9-9a8e-f179e11739e8' : aliases.length === 0, 'ALIAS_RESOLUTION');
 const search = (await db.query('SELECT * FROM public.production_taxonomy_search_context_v1($1,$2,$3,false)', ['Defterler', client, version])).rows;
 check(active ? search.length > 0 : search.length === 0, 'SEARCH_VISIBILITY');
 return { public_roots: rows.length, canonical_products_visible: productIds.size, policy_gated_products_preserved: active ? 6 : 20, alias_query_rows: aliases.length, search_query_rows: search.length, strict_rpc_contracts: 'PASS' };
}

const runs = [];
for (let cycle = 1; cycle <= 2; cycle++) {
 const db = new PGlite();
 await fixture(db);
 const engine = await first(db, 'SELECT version()');
 const baseline = await integrity(db);
 const baselineMetadata = await legacyMetadata(db);
 const localPreflight = await db.exec(await read('tool/production_taxonomy/preflight.sql'));
 const preflightRow = localPreflight.find(r => r.rows?.[0]?.preflight_evidence)?.rows[0].preflight_evidence;
 check(preflightRow && preflightRow.counts.products === 20 && preflightRow.counts.listings === 285 && preflightRow.migration_ledger.length === 9, 'PREFLIGHT_SQL_SYNTAX_AND_SHAPE');
 const originalAnon = await legacyQueries(db, 'anon');
 const originalAuthenticated = await legacyQueries(db, 'authenticated');
 const backup = await db.dumpDataDir('none');
 const backupHash = sha256(Buffer.from(await backup.arrayBuffer()));
 const negative = [];
 negative.push(await expectFailure(db, 'candidate_without_local_authorization', () => db.exec(migration), 'W52H_LOCAL_REHEARSAL_ONLY'));
 negative.push(await expectFailure(db, '0010_on_production_shape', () => db.exec(old10), 'W36_UNEXPECTED_NON_EMPTY_APPLICATION_TARGET'));
 negative.push(await expectFailure(db, '0011_on_production_ledger', () => db.exec(old11), 'W38_MIGRATION_LEDGER_MISMATCH'));
 check(await first(db, "SELECT to_regclass('public.canonical_categories') IS NULL"), 'FAILED_APPLY_ATOMICITY');
 await db.exec("SET esnaftavar.w52h.execution_scope='local-rehearsal'");
 const phases = [];
 const stageMarker = migration.indexOf('-- W52H_STAGE_D_EXACT_MAPPING');
 check(stageMarker > 0, 'STAGE_MARKER');
 await db.exec(migration.slice(0, stageMarker));
 // Same transaction and same bytes in exact order; no manual fixture repair.
 for (const role of ['anon', 'authenticated']) {
  const old = await legacyQueries(db, role);
  check(stableJson(old) === stableJson(role === 'anon' ? originalAnon : originalAuthenticated), `POST_SCHEMA_COMPATIBILITY:${role}`);
 }
 phases.push({ phase: 'POST_SCHEMA_PRE_ACTIVATION', old_client: 'PASS', new_canonical_client: 'NOT_APPLICABLE', canonical_gate: await canonicalQueries(db, false) });
 await db.exec(migration.slice(stageMarker));
 const staged = await integrity(db, true);
 check(await legacyMetadata(db) === baselineMetadata, 'LEGACY_SCHEMA_RLS_FK_CHANGED');
 for (const role of ['anon', 'authenticated']) {
  check(stableJson(await legacyQueries(db, role)) === stableJson(role === 'anon' ? originalAnon : originalAuthenticated), `POST_MAPPING_COMPATIBILITY:${role}`);
  await db.exec(`SET ROLE ${role}`);
  check(Number(await first(db, 'SELECT count(*) FROM public.product_canonical_assignments')) === 0, 'STAGED_MAPPING_VISIBILITY');
  await db.exec('RESET ROLE');
 }
 phases.push({ phase: 'POST_PRODUCT_RECLASSIFICATION', old_client: 'PASS', new_canonical_client: 'NOT_APPLICABLE', canonical_gate: await canonicalQueries(db, false) });
 negative.push(await expectFailure(db, 'double_apply_rejected_without_partial_changes', () => db.exec(migration), 'W52H_ADAPTER_ALREADY_PRESENT'));
 negative.push(await expectFailure(db, 'nonterminal_mapping_rejected', () => db.exec("BEGIN; UPDATE public.product_canonical_assignments SET canonical_category_id='714f42ff-37ee-466c-9726-796097910936' WHERE product_id=(SELECT product_id FROM public.product_canonical_assignments LIMIT 1); COMMIT;"), 'W52H_ASSIGNMENT_TARGET_NOT_CANONICAL_TERMINAL'));
 negative.push(await expectFailure(db, 'wrong_client_contract', () => db.query('SELECT * FROM public.production_taxonomy_roots_v1($1,$2,false)', ['bad', version]), 'W38_CLIENT_CONTRACT_VERSION_MISMATCH'));
 negative.push(await expectFailure(db, 'preview_never_exposes_staged_data', () => db.query('SELECT * FROM public.production_taxonomy_roots_v1($1,$2,true)', [client, version]), 'W38_PREVIEW_DISABLED'));
 await db.exec(activation);
 const activated = await integrity(db, true);
 const newClient = {};
 for (const role of ['anon', 'authenticated']) {
  check(stableJson(await legacyQueries(db, role)) === stableJson(role === 'anon' ? originalAnon : originalAuthenticated), `POST_ACTIVATION_COMPATIBILITY:${role}`);
  await db.exec(`SET ROLE ${role}`);
  newClient[role] = await canonicalQueries(db, true);
  await db.exec('RESET ROLE');
 }
 phases.push({ phase: 'POST_CANONICAL_ACTIVATION', old_client: 'PASS', new_canonical_client: 'PASS', canonical_contract: newClient });
 // Emergency gate alone must suppress every public canonical path even before
 // taxonomy flags are reset. Original W52C queries still return identical data.
 await db.exec('BEGIN; UPDATE public.production_taxonomy_config SET public_enabled=false WHERE singleton_id=1');
 const offGate = await canonicalQueries(db, false);
 const offCapability = (await db.query('SELECT * FROM public.production_taxonomy_capabilities_v1($1,$2)', [client, version])).rows[0];
 check(offCapability.public_active_root_count === 0 && offGate.public_roots === 0, 'EMERGENCY_GATE_CAPABILITY');
 await db.exec('ROLLBACK');
 for (const role of ['anon','authenticated']) {
  await db.exec(`SET ROLE ${role}`);
  negative.push(await expectFailure(db, `${role}_direct_staged_table_access`, () => db.query('SELECT * FROM public.canonical_categories LIMIT 1'), 'permission denied'));
  negative.push(await expectFailure(db, `${role}_private_helper_execute`, () => db.query('SELECT public._production_taxonomy_visible_v1($1,$2,false)', [mapping[0].PROPOSED_CANONICAL_UUID,version]), 'permission denied'));
  await db.exec('RESET ROLE');
 }
 await db.exec(rollback);
 const rolledBack = await integrity(db, true);
 check(stableJson(await legacyQueries(db, 'anon')) === stableJson(originalAnon), 'ROLLBACK_LEGACY_RESUME');
 check(stableJson(await legacyQueries(db, 'authenticated')) === stableJson(originalAuthenticated), 'ROLLBACK_AUTHENTICATED_RESUME');
 check(await legacyMetadata(db) === baselineMetadata, 'ROLLBACK_LEGACY_METADATA');
 const disabled = await canonicalQueries(db, false);
 await db.close();
 const restored = new PGlite({ loadDataDir: backup });
 const restoredCounts = await integrity(restored);
 check(await first(restored, "SELECT to_regclass('public.canonical_categories') IS NULL"), 'RESTORE_NEW_SCHEMA_REMAINS');
 check(stableJson(await legacyQueries(restored, 'anon')) === stableJson(originalAnon), 'RESTORE_QUERY_HASH');
 check(stableJson(await legacyQueries(restored, 'authenticated')) === stableJson(originalAuthenticated), 'RESTORE_AUTHENTICATED_QUERY_HASH');
 check(await legacyMetadata(restored) === baselineMetadata, 'RESTORE_LEGACY_METADATA');
 check(Number(await first(restored, 'SELECT count(*) FROM supabase_migrations.schema_migrations')) === 9, 'RESTORE_LEDGER');
 await restored.close();
 runs.push({ run: cycle, engine, baseline, staged, activated, legacy_schema_rls_fk_fingerprint: baselineMetadata, legacy_schema_rls_fk_preserved: true, rollback: { result: 'PASS', counts: rolledBack, gate: disabled }, restore: { result: 'PASS_LOCAL_SYNTHETIC_ONLY', backup_sha256: backupHash, counts: restoredCounts }, legacy_queries: { anon: originalAnon, authenticated: originalAuthenticated }, phases, negative_checks: negative });
 console.log(`RUN_${cycle}: PASS; 20 products, 285 listings, 57 shops; 20 mappings; rollback + synthetic restore PASS`);
}

const result = {
 task: 'W52H', captured_at_utc: new Date().toISOString(), base_head: preflight.base_head,
 execution: 'LOCAL_PGLITE_ONLY', candidate: manifest, rehearsal_runs: runs.length, local_rehearsal: 'PASS',
 fixture: { categories: 4, products: 20, listings: 285, shops: 57, ledger: 'Production exact versions through 0009', synthetic_shop_and_listing_values: true, real_personal_data: false },
 old_w52c: { apk: apkFile.split('/').at(-1), sha256: apkHash, source_head: sourceHead, source_evidence: sourceEvidence.map(({ content, ...e }) => e), contract_compatibility: 'PASS', validation_scope: 'Source-derived PostgreSQL queries under anon/authenticated; exact frozen APK hash verified. APK UI and PostgREST HTTP serialization not executed locally.' },
 compatibility_matrix: [{ phase: 'PRE_MIGRATION', old_client: 'PASS', new_canonical_client: 'NOT_APPLICABLE' }, ...runs[0].phases.map(({ phase, old_client, new_canonical_client }) => ({ phase, old_client, new_canonical_client }))],
 runs, products_after: 20, listings_after: 285, shops_after: 57, canonical_nodes: 1563, canonical_roots: 24, terminal_leaves: 1245, owner_mappings_applied_locally: 20, orphans: 0,
 sql_validation: 'PASS', rollback_rehearsal: 'PASS', canonical_activation_plan: 'PASS_LOCAL_SIMULATION',
 flutter_tests_analyzer: 'NOT_REQUIRED — NO_CLIENT_CHANGES',
 backup_capture_capability: 'PARTIAL', restore_capability: 'PARTIAL', restore_proof: 'PARTIAL',
 limits: ['Synthetic local database snapshot restore is not a logical Production dump restore.', 'PGlite PostgreSQL version differs from observed Production PostgreSQL 17.6.', 'PostgREST transport and physical W52C APK screens are not exercised by SQL replay.', 'Six owner-mapped products retain policy/professional gates and remain unavailable in canonical public scopes; all 20 remain in legacy runtime.'],
 production_write_performed: false, development_accessed: false, ready_for_product_owner_production_write_decision: false,
};
await writeFile(resolve(root, 'docs/data/w52h_production_migration_rehearsal_result.json'), JSON.stringify(result, null, 2) + '\n');
