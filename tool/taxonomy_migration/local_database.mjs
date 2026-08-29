import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { check, stableJson } from './lib.mjs';

export async function openPGlite(pgliteRoot) {
  check(pgliteRoot, '--pglite-root is required');
  const moduleUrl = pathToFileURL(join(pgliteRoot, 'dist', 'index.js')).href;
  const { PGlite } = await import(moduleUrl);
  return new PGlite();
}

export async function scalar(database, statement, parameters = []) {
  const result = await database.query(statement, parameters);
  return Object.values(result.rows[0])[0];
}

export async function createEmptyApplicationBaseline(database, pkg) {
  await database.exec(`
    CREATE ROLE anon NOLOGIN;
    CREATE ROLE authenticated NOLOGIN;
    CREATE SCHEMA supabase_migrations;
    CREATE TABLE supabase_migrations.schema_migrations (
      version TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      statements TEXT[]
    );
    CREATE TABLE public.platform_metadata (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    );
    INSERT INTO public.platform_metadata VALUES ('w36-sentinel','must-survive-taxonomy-rollback');
    CREATE TABLE public.categories (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL CHECK (length(btrim(name))>0),
      description TEXT,
      image_url TEXT,
      parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_active BOOLEAN NOT NULL DEFAULT true,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    CREATE INDEX categories_parent_sort_idx ON public.categories(parent_id,sort_order);
    CREATE TABLE public.products (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
      price NUMERIC(10,2) NOT NULL DEFAULT 0,
      stock INTEGER NOT NULL DEFAULT 0,
      is_active BOOLEAN NOT NULL DEFAULT true
    );
    CREATE TABLE public.shops (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT true
    );
    CREATE TABLE public.shop_products (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      shop_id UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
      product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
      price NUMERIC NOT NULL DEFAULT 0,
      is_available BOOLEAN NOT NULL DEFAULT true,
      is_active BOOLEAN NOT NULL DEFAULT true,
      UNIQUE(shop_id,product_id)
    );
    ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
    CREATE POLICY categories_read_active ON public.categories
      FOR SELECT TO anon,authenticated USING (is_active=true);
    GRANT USAGE ON SCHEMA public TO anon,authenticated;
    GRANT SELECT ON public.categories TO anon,authenticated;
  `);
  for (const [index, file] of pkg.manifest.runtime_contract.migration_files.entries()) {
    const version = file.name.slice(0, 14);
    await database.query(
      'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES ($1,$2,$3)',
      [version || String(index + 1), file.name, []],
    );
  }
}

export async function setLocalGuard(database, packageSha256) {
  await database.exec(`SET esnaftavar.taxonomy_target_mode='local';`);
  await database.exec(`SET esnaftavar.taxonomy_apply_token='${packageSha256}';`);
}

async function categoryExactness(database, pkg) {
  const rows = (await database.query(`
    SELECT id::text AS category_id,source_key AS planning_key,parent_id::text AS parent_category_id,
      name,slug,level::text AS level,sort_order::text AS sort_order,
      lifecycle_state,is_active,is_assignable,policy_class,professional_review_status,taxonomy_version
    FROM public.categories WHERE taxonomy_version=$1 ORDER BY source_key
  `, [pkg.manifest.taxonomy_version])).rows;
  const activation = new Map(pkg.tables['activation.csv'].map((row) => [row.CATEGORY_ID, row]));
  const expected = [...pkg.tables['categories.csv']].sort((a, b) => a.PLANNING_KEY.localeCompare(b.PLANNING_KEY, 'en'))
    .map((row) => {
      const state = activation.get(row.CATEGORY_ID);
      return {
        category_id: row.CATEGORY_ID,
        planning_key: row.PLANNING_KEY,
        parent_category_id: row.PARENT_CATEGORY_ID || null,
        name: row.NAME,
        slug: row.SLUG,
        level: row.LEVEL,
        sort_order: row.SORT_ORDER,
        lifecycle_state: state.LIFECYCLE_STATE,
        is_active: state.IS_ACTIVE === 'YES',
        is_assignable: state.IS_ASSIGNABLE === 'YES',
        policy_class: state.POLICY_CLASS,
        professional_review_status: state.PROFESSIONAL_REVIEW_STATUS,
        taxonomy_version: row.TAXONOMY_VERSION,
      };
    });
  check(stableJson(rows) === stableJson(expected), 'POSTCHECK_CATEGORY_EXACTNESS');
}

export async function runPostchecks(database, pkg) {
  const version = pkg.manifest.taxonomy_version;
  const expected = pkg.manifest.expected;
  const levelsRows = (await database.query(`
    SELECT level::text AS level,count(*)::int AS count FROM public.categories
    WHERE taxonomy_version=$1 GROUP BY level ORDER BY level
  `, [version])).rows;
  const levels = Object.fromEntries(levelsRows.map((row) => [row.level, row.count]));
  const result = {
    categories: Number(await scalar(database, 'SELECT count(*) FROM public.categories WHERE taxonomy_version=$1', [version])),
    levels,
    leaves: Number(await scalar(database, `
      SELECT count(*) FROM public.categories c WHERE c.taxonomy_version=$1
      AND NOT EXISTS(SELECT 1 FROM public.categories child WHERE child.parent_id=c.id)
    `, [version])),
    parent_errors: Number(await scalar(database, `
      SELECT count(*) FROM public.categories c WHERE c.taxonomy_version=$1 AND (
        (c.level=1 AND c.parent_id IS NOT NULL) OR
        (c.level>1 AND NOT EXISTS(SELECT 1 FROM public.categories p WHERE p.id=c.parent_id AND p.level=c.level-1))
      )
    `, [version])),
    cycles_or_depth: Number(await scalar(database, `
      WITH RECURSIVE a(origin_id,id,parent_id,visited,cycle) AS (
        SELECT c.id,c.id,c.parent_id,ARRAY[c.id],false FROM public.categories c WHERE c.taxonomy_version=$1
        UNION ALL SELECT a.origin_id,p.id,p.parent_id,a.visited||p.id,p.id=ANY(a.visited)
        FROM a JOIN public.categories p ON p.id=a.parent_id
        WHERE NOT a.cycle AND cardinality(a.visited)<=5
      ) SELECT count(*) FROM a WHERE cycle OR cardinality(visited)>4
    `, [version])),
    duplicate_source_keys: Number(await scalar(database, `
      SELECT count(*) FROM (SELECT source_key FROM public.categories WHERE taxonomy_version=$1 GROUP BY source_key HAVING count(*)<>1) q
    `, [version])),
    duplicate_slugs: Number(await scalar(database, `
      SELECT count(*) FROM (SELECT lower(slug) FROM public.categories WHERE taxonomy_version=$1 GROUP BY lower(slug) HAVING count(*)<>1) q
    `, [version])),
    public_or_policy_leakage: Number(await scalar(database, `
      SELECT count(*) FROM public.categories WHERE taxonomy_version=$1 AND (
        is_active=true OR lifecycle_state<>'staged' OR
        ((policy_class<>'NORMAL' OR professional_review_status<>'not_required') AND is_active=true)
      )
    `, [version])),
    allocations: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_id_allocations WHERE taxonomy_version=$1', [version])),
    aliases: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_aliases WHERE taxonomy_version=$1', [version])),
    alias_targets: Number(await scalar(database, `
      SELECT count(*) FROM public.taxonomy_alias_targets t JOIN public.taxonomy_aliases a ON a.id=t.alias_id WHERE a.taxonomy_version=$1
    `, [version])),
    alias_state_errors: Number(await scalar(database, `
      SELECT count(*) FROM public.taxonomy_aliases a WHERE a.taxonomy_version=$1 AND (
        (a.resolution_state='RESOLVED' AND (a.direct_target_category_id IS NULL OR (SELECT count(*) FROM public.taxonomy_alias_targets t WHERE t.alias_id=a.id)<>1)) OR
        (a.resolution_state='AMBIGUOUS' AND (a.direct_target_category_id IS NOT NULL OR (SELECT count(*) FROM public.taxonomy_alias_targets t WHERE t.alias_id=a.id)<2)) OR
        (a.resolution_state IN ('TOMBSTONE','UNRESOLVED') AND (a.direct_target_category_id IS NOT NULL OR EXISTS(SELECT 1 FROM public.taxonomy_alias_targets t WHERE t.alias_id=a.id)))
      )
    `, [version])),
    relationships: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships WHERE taxonomy_version=$1', [version])),
    successor_edges: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships WHERE taxonomy_version=$1 AND successor_category_id IS NOT NULL', [version])),
    split_edge_errors: Number(await scalar(database, `
      SELECT count(*) FROM (
        SELECT predecessor_source_locator FROM public.taxonomy_node_relationships
        WHERE taxonomy_version=$1 AND action='SPLIT'
        GROUP BY predecessor_source_locator HAVING count(successor_category_id)<>count(*)
      ) q
    `, [version])),
    import_runs: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_import_runs WHERE package_sha256=$1 AND taxonomy_version=$2', [pkg.manifest.package_sha256, version])),
    platform_sentinel: Number(await scalar(database, "SELECT count(*) FROM public.platform_metadata WHERE key='w36-sentinel' AND value='must-survive-taxonomy-rollback'")),
  };
  check(result.categories === expected.categories, 'POSTCHECK_CATEGORIES');
  check(stableJson(result.levels) === stableJson(expected.levels), 'POSTCHECK_LEVELS');
  check(result.leaves === expected.leaves, 'POSTCHECK_LEAVES');
  check(result.parent_errors === 0, 'POSTCHECK_PARENTS');
  check(result.cycles_or_depth === 0, 'POSTCHECK_CYCLES');
  check(result.duplicate_source_keys === 0 && result.duplicate_slugs === 0, 'POSTCHECK_DUPLICATES');
  check(result.public_or_policy_leakage === 0, 'POSTCHECK_POLICY_VISIBILITY');
  check(result.allocations === expected.allocations, 'POSTCHECK_ALLOCATIONS');
  check(result.aliases === expected.aliases && result.alias_targets === expected.alias_targets, 'POSTCHECK_ALIASES');
  check(result.alias_state_errors === 0, 'POSTCHECK_ALIAS_STATES');
  check(result.relationships === expected.relationships && result.successor_edges === expected.successor_edges, 'POSTCHECK_RELATIONSHIPS');
  check(result.split_edge_errors === 0, 'POSTCHECK_SPLITS');
  check(result.import_runs === 1, 'POSTCHECK_IMPORT_RUN');
  check(result.platform_sentinel === 1, 'POSTCHECK_PLATFORM_METADATA');
  await categoryExactness(database, pkg);

  const functions = [
    'taxonomy_roots_v1', 'taxonomy_children_v1', 'taxonomy_descendants_v1',
    'taxonomy_exact_leaf_v1', 'taxonomy_breadcrumb_v1',
    'taxonomy_resolve_alias_v1', 'taxonomy_search_context_v1',
  ];
  const installedFunctions = Number(await scalar(database, `
    SELECT count(DISTINCT proname) FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname=ANY($1::text[])
  `, [functions]));
  check(installedFunctions === functions.length, 'POSTCHECK_RPC_CONTRACT');
  await database.exec('SET ROLE anon');
  const publicRoots = Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_roots_v1($1)', [version]));
  const denied = [];
  for (const table of ['taxonomy_id_allocations', 'taxonomy_aliases', 'taxonomy_alias_targets', 'taxonomy_node_relationships', 'taxonomy_import_runs']) {
    try { await database.query(`SELECT count(*) FROM public.${table}`); } catch { denied.push(table); }
  }
  await database.exec('RESET ROLE');
  check(publicRoots === 0, 'POSTCHECK_STAGED_ROOT_VISIBILITY');
  check(denied.length === 5, 'POSTCHECK_ADMIN_TABLE_VISIBILITY');
  result.public_roots = publicRoots;
  result.admin_tables_denied = denied.length;
  result.rpc_contract_functions = installedFunctions;
  result.category_exactness = 'PASS';
  return result;
}

export async function applyArtifact(database, pkg, forwardSql) {
  await setLocalGuard(database, pkg.manifest.package_sha256);
  await database.exec(forwardSql);
  return runPostchecks(database, pkg);
}

export async function rollbackArtifact(database, pkg, rollbackSql) {
  await setLocalGuard(database, pkg.manifest.package_sha256);
  await database.exec(rollbackSql);
  const result = {
    categories: Number(await scalar(database, 'SELECT count(*) FROM public.categories')),
    products: Number(await scalar(database, 'SELECT count(*) FROM public.products')),
    shops: Number(await scalar(database, 'SELECT count(*) FROM public.shops')),
    shop_products: Number(await scalar(database, 'SELECT count(*) FROM public.shop_products')),
    allocations: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_id_allocations')),
    aliases: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_aliases')),
    alias_targets: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_alias_targets')),
    relationships: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_node_relationships')),
    import_runs: Number(await scalar(database, 'SELECT count(*) FROM public.taxonomy_import_runs')),
    migration_ledger: Number(await scalar(database, 'SELECT count(*) FROM supabase_migrations.schema_migrations')),
    platform_sentinel: Number(await scalar(database, "SELECT count(*) FROM public.platform_metadata WHERE key='w36-sentinel'")),
  };
  for (const key of ['categories', 'products', 'shops', 'shop_products', 'allocations', 'aliases', 'alias_targets', 'relationships', 'import_runs']) {
    check(result[key] === 0, `ROLLBACK_NOT_EMPTY:${key}`);
  }
  check(result.migration_ledger === pkg.manifest.runtime_contract.migration_files.length, 'ROLLBACK_MIGRATION_LEDGER');
  check(result.platform_sentinel === 1, 'ROLLBACK_PLATFORM_METADATA');
  return result;
}

export async function loadArtifacts(directory) {
  const [forward, rollback, postcheck, manifestText] = await Promise.all([
    readFile(join(directory, 'forward.sql'), 'utf8'),
    readFile(join(directory, 'rollback.sql'), 'utf8'),
    readFile(join(directory, 'postcheck.sql'), 'utf8'),
    readFile(join(directory, 'artifact_manifest.json'), 'utf8'),
  ]);
  return { forward, rollback, postcheck, manifest: JSON.parse(manifestText) };
}
