// W52H source-derived contract checks, reused against real PostgreSQL 17.6. No fixtures.
import {parseCsv} from '../taxonomy_migration/lib.mjs';
import {read,check,sha256,stableJson} from './real_restore_lib.mjs';
const owner=JSON.parse(read('docs/data/production_20_product_canonical_mapping_validation.json'));
const mapping=parseCsv(read('docs/data/production_20_product_canonical_mapping.csv')).rows;
const categoryInput=parseCsv(read('docs/TAXONOMY_W36_CATEGORY_IMPORT.csv')).rows;
const qualificationInput=parseCsv(read('docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv')).rows;
const client='production-taxonomy-client-v1',version='canonical-v1.0.0';
const first=async(db,query,args=[])=>Object.values((await db.query(query,args)).rows[0])[0];
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


export { integrity, legacyQueries, legacyMetadata, canonicalQueries };
