import { mkdir, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import {
  loadPackage, sha256, sql, sqlBoolean, stableJson,
} from './lib.mjs';

const SCHEMA_SQL = `
-- Additive Wave 36 taxonomy bootstrap schema candidate.
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS source_key TEXT,
  ADD COLUMN IF NOT EXISTS slug TEXT,
  ADD COLUMN IF NOT EXISTS level SMALLINT,
  ADD COLUMN IF NOT EXISTS lifecycle_state TEXT,
  ADD COLUMN IF NOT EXISTS is_assignable BOOLEAN,
  ADD COLUMN IF NOT EXISTS policy_class TEXT,
  ADD COLUMN IF NOT EXISTS professional_review_status TEXT,
  ADD COLUMN IF NOT EXISTS taxonomy_version TEXT;

DO $constraints$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_source_key_not_blank_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_source_key_not_blank_check
      CHECK (source_key IS NULL OR length(btrim(source_key)) > 0) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_slug_not_blank_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_slug_not_blank_check
      CHECK (slug IS NULL OR length(btrim(slug)) > 0) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_level_range_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_level_range_check
      CHECK (level IS NULL OR level BETWEEN 1 AND 4) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_lifecycle_state_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_lifecycle_state_check
      CHECK (lifecycle_state IS NULL OR lifecycle_state IN ('staged','active','retired')) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_policy_class_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_policy_class_check
      CHECK (policy_class IS NULL OR policy_class IN ('NORMAL','AGE_RESTRICTED','REGULATED','LEGAL_REVIEW_REQUIRED','EXCLUDED')) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_professional_review_status_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_professional_review_status_check
      CHECK (professional_review_status IS NULL OR professional_review_status IN ('not_required','pending','approved','rejected')) NOT VALID;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='categories_not_own_parent_check') THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_not_own_parent_check
      CHECK (parent_id IS NULL OR parent_id <> id) NOT VALID;
  END IF;
END
$constraints$;

CREATE UNIQUE INDEX IF NOT EXISTS categories_source_key_unique_idx
  ON public.categories(source_key) WHERE source_key IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS categories_slug_unique_idx
  ON public.categories(lower(slug)) WHERE slug IS NOT NULL;
CREATE INDEX IF NOT EXISTS categories_version_level_order_idx
  ON public.categories(taxonomy_version, level, parent_id, sort_order);
CREATE INDEX IF NOT EXISTS categories_public_tree_idx
  ON public.categories(parent_id, sort_order)
  WHERE is_active=true AND lifecycle_state='active';

CREATE OR REPLACE FUNCTION public.validate_taxonomy_category_hierarchy()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path=public AS $hierarchy$
DECLARE parent_level SMALLINT; cycle_found BOOLEAN;
BEGIN
  IF NEW.level IS NULL THEN RETURN NEW; END IF;
  IF NEW.level=1 THEN
    IF NEW.parent_id IS NOT NULL THEN RAISE EXCEPTION 'L1 taxonomy category cannot have a parent'; END IF;
    RETURN NEW;
  END IF;
  IF NEW.parent_id IS NULL THEN RAISE EXCEPTION 'L2-L4 taxonomy category requires a parent'; END IF;
  IF NEW.parent_id=NEW.id THEN RAISE EXCEPTION 'taxonomy category cannot parent itself'; END IF;
  SELECT level INTO parent_level FROM public.categories WHERE id=NEW.parent_id;
  IF NOT FOUND OR parent_level IS NULL OR parent_level<>NEW.level-1 THEN
    RAISE EXCEPTION 'taxonomy parent level mismatch';
  END IF;
  WITH RECURSIVE ancestors(id,parent_id) AS (
    SELECT id,parent_id FROM public.categories WHERE id=NEW.parent_id
    UNION ALL
    SELECT c.id,c.parent_id FROM public.categories c JOIN ancestors a ON c.id=a.parent_id
  ) SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=NEW.id) INTO cycle_found;
  IF cycle_found THEN RAISE EXCEPTION 'taxonomy category cycle detected'; END IF;
  RETURN NEW;
END
$hierarchy$;
DROP TRIGGER IF EXISTS validate_taxonomy_category_hierarchy ON public.categories;
CREATE TRIGGER validate_taxonomy_category_hierarchy
  BEFORE INSERT OR UPDATE OF parent_id,level ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.validate_taxonomy_category_hierarchy();

CREATE TABLE IF NOT EXISTS public.taxonomy_id_allocations (
  planning_key TEXT PRIMARY KEY,
  category_id UUID NOT NULL UNIQUE REFERENCES public.categories(id) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED,
  taxonomy_version TEXT NOT NULL,
  allocation_source TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (length(btrim(planning_key))>0)
);
CREATE TABLE IF NOT EXISTS public.taxonomy_aliases (
  id UUID PRIMARY KEY,
  alias_kind TEXT NOT NULL CHECK (alias_kind IN ('LEGACY_REDIRECT','SEARCH_SYNONYM')),
  alias_locator TEXT NOT NULL,
  alias_text TEXT,
  alias_slug TEXT,
  alias_path TEXT,
  source_alias_type TEXT,
  resolution_state TEXT NOT NULL CHECK (resolution_state IN ('RESOLVED','AMBIGUOUS','TOMBSTONE','UNRESOLVED')),
  direct_target_category_id UUID REFERENCES public.categories(id) ON DELETE RESTRICT,
  locale TEXT NOT NULL DEFAULT 'tr-TR',
  taxonomy_version TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (length(btrim(alias_locator))>0),
  CHECK ((resolution_state='RESOLVED' AND direct_target_category_id IS NOT NULL) OR (resolution_state<>'RESOLVED' AND direct_target_category_id IS NULL)),
  UNIQUE(alias_kind,alias_locator,taxonomy_version)
);
CREATE TABLE IF NOT EXISTS public.taxonomy_alias_targets (
  alias_id UUID NOT NULL REFERENCES public.taxonomy_aliases(id) ON DELETE CASCADE,
  target_category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  PRIMARY KEY(alias_id,target_category_id)
);
CREATE TABLE IF NOT EXISTS public.taxonomy_node_relationships (
  id UUID PRIMARY KEY,
  predecessor_source_locator TEXT NOT NULL,
  successor_category_id UUID REFERENCES public.categories(id) ON DELETE RESTRICT,
  action TEXT NOT NULL CHECK (action IN ('KEEP','RENAME','MOVE','RENAME_AND_MOVE','MERGE','SPLIT','RETIRE','ALIAS_ONLY','OUT','UNRESOLVED')),
  target_state TEXT NOT NULL CHECK (target_state IN ('CANONICAL_FINAL','NO_TARGET_YET','POLICY_REVIEW','OUT_OF_SCOPE')),
  classification_rule TEXT,
  confidence TEXT,
  taxonomy_version TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (successor_category_id IS NOT NULL OR action IN ('RETIRE','OUT','UNRESOLVED')),
  UNIQUE(predecessor_source_locator,successor_category_id,action,taxonomy_version)
);
CREATE TABLE IF NOT EXISTS public.taxonomy_import_runs (
  package_sha256 TEXT PRIMARY KEY,
  taxonomy_version TEXT NOT NULL UNIQUE,
  package_kind TEXT NOT NULL,
  category_count INTEGER NOT NULL CHECK (category_count>=0),
  status TEXT NOT NULL CHECK (status IN ('APPLIED')),
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS taxonomy_aliases_slug_lookup_idx
  ON public.taxonomy_aliases(alias_kind,locale,lower(alias_slug)) WHERE alias_slug IS NOT NULL AND is_active=true;
CREATE INDEX IF NOT EXISTS taxonomy_alias_targets_target_idx ON public.taxonomy_alias_targets(target_category_id);
CREATE INDEX IF NOT EXISTS taxonomy_relationships_predecessor_idx ON public.taxonomy_node_relationships(predecessor_source_locator);
CREATE INDEX IF NOT EXISTS taxonomy_relationships_successor_idx ON public.taxonomy_node_relationships(successor_category_id) WHERE successor_category_id IS NOT NULL;

ALTER TABLE public.taxonomy_id_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_alias_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_node_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_import_runs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.taxonomy_id_allocations FROM anon,authenticated;
REVOKE ALL ON public.taxonomy_aliases FROM anon,authenticated;
REVOKE ALL ON public.taxonomy_alias_targets FROM anon,authenticated;
REVOKE ALL ON public.taxonomy_node_relationships FROM anon,authenticated;
REVOKE ALL ON public.taxonomy_import_runs FROM anon,authenticated;
`;

const QUERY_CONTRACT_SQL = `
CREATE OR REPLACE FUNCTION public.taxonomy_roots_v1(p_taxonomy_version TEXT)
RETURNS TABLE(id UUID,parent_id UUID,name TEXT,slug TEXT,level SMALLINT,is_assignable BOOLEAN,sort_order INTEGER,taxonomy_version TEXT)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path=public AS $fn$
  SELECT c.id,c.parent_id,c.name,c.slug,c.level,c.is_assignable,c.sort_order,c.taxonomy_version
  FROM public.categories c WHERE c.taxonomy_version=p_taxonomy_version AND c.level=1
    AND c.parent_id IS NULL AND c.lifecycle_state='active' AND c.is_active=true
  ORDER BY c.sort_order,c.id
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_children_v1(p_parent_id UUID,p_taxonomy_version TEXT)
RETURNS TABLE(id UUID,parent_id UUID,name TEXT,slug TEXT,level SMALLINT,is_assignable BOOLEAN,sort_order INTEGER,taxonomy_version TEXT)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path=public AS $fn$
  SELECT c.id,c.parent_id,c.name,c.slug,c.level,c.is_assignable,c.sort_order,c.taxonomy_version
  FROM public.categories c WHERE c.parent_id=p_parent_id AND c.taxonomy_version=p_taxonomy_version
    AND c.lifecycle_state='active' AND c.is_active=true ORDER BY c.sort_order,c.id
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_descendants_v1(p_category_id UUID,p_taxonomy_version TEXT)
RETURNS TABLE(id UUID,level SMALLINT,is_assignable BOOLEAN)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path=public AS $fn$
  WITH RECURSIVE d AS (
    SELECT c.id,c.parent_id,c.level,c.is_assignable FROM public.categories c
    WHERE c.id=p_category_id AND c.taxonomy_version=p_taxonomy_version AND c.lifecycle_state='active' AND c.is_active=true
    UNION ALL
    SELECT c.id,c.parent_id,c.level,c.is_assignable FROM public.categories c JOIN d ON c.parent_id=d.id
    WHERE c.taxonomy_version=p_taxonomy_version AND c.lifecycle_state='active' AND c.is_active=true
  ) SELECT d.id,d.level,d.is_assignable FROM d WHERE d.is_assignable=true
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_exact_leaf_v1(p_category_id UUID,p_taxonomy_version TEXT)
RETURNS TABLE(id UUID,name TEXT,slug TEXT,taxonomy_version TEXT)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path=public AS $fn$
  SELECT c.id,c.name,c.slug,c.taxonomy_version FROM public.categories c
  WHERE c.id=p_category_id AND c.taxonomy_version=p_taxonomy_version
    AND c.lifecycle_state='active' AND c.is_active=true AND c.is_assignable=true
    AND c.policy_class='NORMAL' AND c.professional_review_status='not_required'
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_breadcrumb_v1(p_category_id UUID,p_taxonomy_version TEXT)
RETURNS TABLE(id UUID,parent_id UUID,name TEXT,slug TEXT,level SMALLINT)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path=public AS $fn$
  WITH RECURSIVE b AS (
    SELECT c.id,c.parent_id,c.name,c.slug,c.level FROM public.categories c
    WHERE c.id=p_category_id AND c.taxonomy_version=p_taxonomy_version AND c.lifecycle_state='active' AND c.is_active=true
    UNION ALL
    SELECT p.id,p.parent_id,p.name,p.slug,p.level FROM public.categories p JOIN b ON b.parent_id=p.id
    WHERE p.taxonomy_version=p_taxonomy_version AND p.lifecycle_state='active' AND p.is_active=true
  ) SELECT b.id,b.parent_id,b.name,b.slug,b.level FROM b ORDER BY b.level
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_resolve_alias_v1(p_alias_slug TEXT,p_taxonomy_version TEXT)
RETURNS TABLE(category_id UUID,canonical_slug TEXT,resolution_state TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=public AS $fn$
  SELECT c.id,c.slug,a.resolution_state FROM public.taxonomy_aliases a
  JOIN public.categories c ON c.id=a.direct_target_category_id
  WHERE a.alias_kind='LEGACY_REDIRECT' AND a.taxonomy_version=p_taxonomy_version
    AND a.resolution_state='RESOLVED' AND a.is_active=true
    AND lower(a.alias_slug)=lower(p_alias_slug)
    AND c.lifecycle_state='active' AND c.is_active=true
$fn$;
CREATE OR REPLACE FUNCTION public.taxonomy_search_context_v1(p_term TEXT,p_taxonomy_version TEXT)
RETURNS TABLE(category_id UUID,name TEXT,slug TEXT,match_kind TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=public AS $fn$
  SELECT c.id,c.name,c.slug,'CANONICAL'::TEXT FROM public.categories c
  WHERE c.taxonomy_version=p_taxonomy_version AND c.lifecycle_state='active' AND c.is_active=true
    AND (lower(c.name)=lower(p_term) OR lower(c.slug)=lower(p_term))
  UNION
  SELECT c.id,c.name,c.slug,a.alias_kind FROM public.taxonomy_aliases a
  JOIN public.categories c ON c.id=a.direct_target_category_id
  WHERE a.taxonomy_version=p_taxonomy_version AND a.resolution_state='RESOLVED' AND a.is_active=true
    AND (lower(coalesce(a.alias_text,''))=lower(p_term) OR lower(coalesce(a.alias_slug,''))=lower(p_term))
    AND c.lifecycle_state='active' AND c.is_active=true
$fn$;
REVOKE ALL ON FUNCTION public.taxonomy_roots_v1(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_children_v1(UUID,TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_descendants_v1(UUID,TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_exact_leaf_v1(UUID,TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_breadcrumb_v1(UUID,TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_resolve_alias_v1(TEXT,TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_search_context_v1(TEXT,TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.taxonomy_roots_v1(TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_children_v1(UUID,TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_descendants_v1(UUID,TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_exact_leaf_v1(UUID,TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_breadcrumb_v1(UUID,TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_resolve_alias_v1(TEXT,TEXT) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_search_context_v1(TEXT,TEXT) TO anon,authenticated;
`;

function values(rows, columns, renderers = {}) {
  return rows.map((row) => `(${columns.map((column) => {
    if (renderers[column]) return renderers[column](row[column], row);
    return sql(row[column]);
  }).join(',')})`).join(',\n');
}

function sorted(rows, keys) {
  return [...rows].sort((left, right) => {
    for (const key of keys) {
      const compared = String(left[key] ?? '').localeCompare(String(right[key] ?? ''), 'en');
      if (compared !== 0) return compared;
    }
    return 0;
  });
}

function guardSql(pkg) {
  const { manifest } = pkg;
  const migrationValues = [...manifest.runtime_contract.migration_ledger]
    .sort((left, right) => left.version.localeCompare(right.version, 'en')
      || left.name.localeCompare(right.name, 'en'))
    .map((row) => `(${sql(row.version)},${sql(row.name)})`).join(',\n      ');
  return `
DO $guard$
DECLARE run_matches INTEGER; imported_categories INTEGER; application_rows BIGINT;
BEGIN
  IF current_setting('esnaftavar.taxonomy_target_mode',true) IS DISTINCT FROM 'local' THEN
    RAISE EXCEPTION 'W36_LOCAL_ONLY_GUARD';
  END IF;
  IF current_setting('esnaftavar.taxonomy_apply_token',true) IS DISTINCT FROM ${sql(manifest.package_sha256)} THEN
    RAISE EXCEPTION 'W36_PACKAGE_TOKEN_MISMATCH';
  END IF;
  SELECT count(*) INTO run_matches FROM public.taxonomy_import_runs
    WHERE package_sha256=${sql(manifest.package_sha256)} AND taxonomy_version=${sql(manifest.taxonomy_version)};
  SELECT count(*) INTO imported_categories FROM public.categories
    WHERE taxonomy_version=${sql(manifest.taxonomy_version)};
  SELECT (SELECT count(*) FROM public.products)+(SELECT count(*) FROM public.shops)+(SELECT count(*) FROM public.shop_products)
    INTO application_rows;
  IF application_rows<>0 THEN RAISE EXCEPTION 'W36_UNEXPECTED_NON_EMPTY_APPLICATION_TARGET'; END IF;
  IF imported_categories<>0 AND run_matches<>1 THEN RAISE EXCEPTION 'W36_UNOWNED_EXISTING_TAXONOMY_ROWS'; END IF;
  IF EXISTS (
    SELECT version,name FROM supabase_migrations.schema_migrations
    GROUP BY version,name HAVING count(*)>1
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_DUPLICATE_PAIR'; END IF;
  IF EXISTS (
    SELECT version FROM supabase_migrations.schema_migrations
    GROUP BY version HAVING count(*)>1
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_DUPLICATE_VERSION'; END IF;
  IF EXISTS (
    SELECT name FROM supabase_migrations.schema_migrations
    GROUP BY name HAVING count(*)>1
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_DUPLICATE_NAME'; END IF;
  IF EXISTS (
    SELECT 1 FROM supabase_migrations.schema_migrations
    WHERE version IS NULL OR version!~'^[0-9]{14}$'
      OR name IS NULL OR name!~'^[0-9]{4}_[a-z0-9]+(_[a-z0-9]+)*$'
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_MALFORMED_ROW'; END IF;
  IF EXISTS (
    WITH expected(version,name) AS (VALUES
      ${migrationValues}
    )
    SELECT 1 FROM expected e JOIN supabase_migrations.schema_migrations l USING(version)
    WHERE e.name<>l.name
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_NAME_MISMATCH'; END IF;
  IF EXISTS (
    WITH expected(version,name) AS (VALUES
      ${migrationValues}
    )
    SELECT 1 FROM expected e JOIN supabase_migrations.schema_migrations l USING(name)
    WHERE e.version<>l.version
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_VERSION_MISMATCH'; END IF;
  IF EXISTS (
    WITH expected(version,name) AS (VALUES
      ${migrationValues}
    )
    SELECT 1 FROM expected e LEFT JOIN supabase_migrations.schema_migrations l
      ON l.version=e.version AND l.name=e.name
    WHERE l.version IS NULL
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_MISSING'; END IF;
  IF EXISTS (
    WITH expected(version,name) AS (VALUES
      ${migrationValues}
    )
    SELECT 1 FROM supabase_migrations.schema_migrations l LEFT JOIN expected e
      ON l.version=e.version AND l.name=e.name
    WHERE e.version IS NULL
  ) THEN RAISE EXCEPTION 'W37_MIGRATION_LEDGER_UNEXPECTED'; END IF;
END
$guard$;
`;
}

function categorySql(pkg) {
  const categories = pkg.tables['categories.csv'];
  const activation = new Map(pkg.tables['activation.csv'].map((row) => [row.CATEGORY_ID, row]));
  const statements = [];
  for (const level of ['1', '2', '3', '4']) {
    const rows = sorted(categories.filter((row) => row.LEVEL === level), ['SORT_ORDER', 'PLANNING_KEY']);
    const columns = [
      'CATEGORY_ID', 'NAME', 'PARENT_CATEGORY_ID', 'SORT_ORDER', 'IS_ACTIVE',
      'PLANNING_KEY', 'SLUG', 'LEVEL', 'LIFECYCLE_STATE', 'IS_ASSIGNABLE',
      'POLICY_CLASS', 'PROFESSIONAL_REVIEW_STATUS', 'TAXONOMY_VERSION',
    ];
    const hydrated = rows.map((row) => ({ ...row, ...activation.get(row.CATEGORY_ID) }));
    statements.push(`
INSERT INTO public.categories(
  id,name,parent_id,sort_order,is_active,source_key,slug,level,lifecycle_state,
  is_assignable,policy_class,professional_review_status,taxonomy_version
) VALUES
${values(hydrated, columns, {
  CATEGORY_ID: (value) => sql(value, '::uuid'),
  PARENT_CATEGORY_ID: (value) => sql(value, value ? '::uuid' : ''),
  SORT_ORDER: (value) => String(Number(value)),
  IS_ACTIVE: (value) => sqlBoolean(value),
  LEVEL: (value) => String(Number(value)),
  IS_ASSIGNABLE: (value) => sqlBoolean(value),
})}
ON CONFLICT (id) DO NOTHING;
`);
  }
  return statements.join('\n');
}

function allocationSql(pkg) {
  const rows = sorted(pkg.tables['uuid_allocations.csv'], ['PLANNING_KEY']);
  return `
INSERT INTO public.taxonomy_id_allocations(planning_key,category_id,taxonomy_version,allocation_source) VALUES
${values(rows, ['PLANNING_KEY', 'CATEGORY_ID', 'TAXONOMY_VERSION', 'ALLOCATION_SOURCE'], {
  CATEGORY_ID: (value) => sql(value, '::uuid'),
})}
ON CONFLICT (planning_key) DO NOTHING;
`;
}

function relationshipSql(pkg) {
  const rows = sorted(pkg.tables['relationships.csv'], ['PREDECESSOR_SOURCE_LOCATOR', 'SUCCESSOR_CATEGORY_ID', 'ACTION']);
  return `
INSERT INTO public.taxonomy_node_relationships(
  id,predecessor_source_locator,successor_category_id,action,target_state,
  classification_rule,confidence,taxonomy_version
) VALUES
${values(rows, [
    'RELATIONSHIP_ID', 'PREDECESSOR_SOURCE_LOCATOR', 'SUCCESSOR_CATEGORY_ID',
    'ACTION', 'TARGET_STATE', 'CLASSIFICATION_RULE', 'CONFIDENCE', 'TAXONOMY_VERSION',
  ], {
    RELATIONSHIP_ID: (value) => sql(value, '::uuid'),
    SUCCESSOR_CATEGORY_ID: (value) => sql(value, value ? '::uuid' : ''),
  })}
ON CONFLICT (id) DO NOTHING;
`;
}

function aliasSql(pkg) {
  const aliases = sorted(pkg.tables['aliases.csv'], ['ALIAS_KIND', 'ALIAS_LOCATOR']);
  const targets = sorted(pkg.tables['alias_targets.csv'], ['ALIAS_ID', 'TARGET_CATEGORY_ID']);
  return `
INSERT INTO public.taxonomy_aliases(
  id,alias_kind,alias_locator,alias_text,alias_slug,alias_path,source_alias_type,
  resolution_state,direct_target_category_id,locale,taxonomy_version,is_active
) VALUES
${values(aliases, [
    'ALIAS_ID', 'ALIAS_KIND', 'ALIAS_LOCATOR', 'ALIAS_TEXT', 'ALIAS_SLUG',
    'ALIAS_PATH', 'SOURCE_ALIAS_TYPE', 'RESOLUTION_STATE',
    'DIRECT_TARGET_CATEGORY_ID', 'LOCALE', 'TAXONOMY_VERSION', 'IS_ACTIVE',
  ], {
    ALIAS_ID: (value) => sql(value, '::uuid'),
    DIRECT_TARGET_CATEGORY_ID: (value) => sql(value, value ? '::uuid' : ''),
    IS_ACTIVE: (value) => sqlBoolean(value),
  })}
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.taxonomy_alias_targets(alias_id,target_category_id) VALUES
${values(targets, ['ALIAS_ID', 'TARGET_CATEGORY_ID'], {
    ALIAS_ID: (value) => sql(value, '::uuid'),
    TARGET_CATEGORY_ID: (value) => sql(value, '::uuid'),
  })}
ON CONFLICT DO NOTHING;
`;
}

function postconditionSql(pkg) {
  const expected = pkg.manifest.expected;
  const version = sql(pkg.manifest.taxonomy_version);
  return `
INSERT INTO public.taxonomy_import_runs(package_sha256,taxonomy_version,package_kind,category_count,status)
VALUES (${sql(pkg.manifest.package_sha256)},${version},${sql(pkg.manifest.package_kind)},${expected.categories},'APPLIED')
ON CONFLICT (package_sha256) DO NOTHING;

DO $postconditions$
DECLARE n INTEGER; cycles INTEGER;
BEGIN
  SELECT count(*) INTO n FROM public.categories WHERE taxonomy_version=${version};
  IF n<>${expected.categories} THEN RAISE EXCEPTION 'W36_CATEGORY_COUNT'; END IF;
  SELECT count(*) INTO n FROM public.taxonomy_id_allocations WHERE taxonomy_version=${version};
  IF n<>${expected.allocations} THEN RAISE EXCEPTION 'W36_ALLOCATION_COUNT'; END IF;
  SELECT count(*) INTO n FROM public.taxonomy_aliases WHERE taxonomy_version=${version};
  IF n<>${expected.aliases} THEN RAISE EXCEPTION 'W36_ALIAS_COUNT'; END IF;
  SELECT count(*) INTO n FROM public.taxonomy_alias_targets t JOIN public.taxonomy_aliases a ON a.id=t.alias_id WHERE a.taxonomy_version=${version};
  IF n<>${expected.alias_targets} THEN RAISE EXCEPTION 'W36_ALIAS_TARGET_COUNT'; END IF;
  SELECT count(*) INTO n FROM public.taxonomy_node_relationships WHERE taxonomy_version=${version};
  IF n<>${expected.relationships} THEN RAISE EXCEPTION 'W36_RELATIONSHIP_COUNT'; END IF;
  SELECT count(*) INTO n FROM public.categories WHERE taxonomy_version=${version} AND is_active=true;
  IF n<>0 THEN RAISE EXCEPTION 'W36_BOOTSTRAP_PUBLICATION_LEAK'; END IF;
  SELECT count(*) INTO n FROM public.categories c WHERE c.taxonomy_version=${version} AND (
    (c.level=1 AND c.parent_id IS NOT NULL) OR
    (c.level>1 AND NOT EXISTS(SELECT 1 FROM public.categories p WHERE p.id=c.parent_id AND p.level=c.level-1))
  );
  IF n<>0 THEN RAISE EXCEPTION 'W36_PARENT_CONTRACT'; END IF;
  WITH RECURSIVE ancestry(origin_id,id,parent_id,visited,cycle) AS (
    SELECT c.id,c.id,c.parent_id,ARRAY[c.id],false FROM public.categories c WHERE c.taxonomy_version=${version}
    UNION ALL
    SELECT a.origin_id,p.id,p.parent_id,a.visited||p.id,p.id=ANY(a.visited)
    FROM ancestry a JOIN public.categories p ON p.id=a.parent_id
    WHERE NOT a.cycle AND cardinality(a.visited)<=5
  ) SELECT count(*) INTO cycles FROM ancestry WHERE cycle OR cardinality(visited)>4;
  IF cycles<>0 THEN RAISE EXCEPTION 'W36_CYCLE_OR_DEPTH'; END IF;
END
$postconditions$;
`;
}

function postcheckSql(pkg) {
  const version = sql(pkg.manifest.taxonomy_version);
  return `-- W36 read-only postcheck artifact\nSELECT 'categories' AS check_name,count(*)::bigint AS actual FROM public.categories WHERE taxonomy_version=${version};
SELECT 'levels' AS check_name,level::text AS key,count(*)::bigint AS actual FROM public.categories WHERE taxonomy_version=${version} GROUP BY level ORDER BY level;
SELECT 'leaves' AS check_name,count(*)::bigint AS actual FROM public.categories c WHERE c.taxonomy_version=${version} AND NOT EXISTS(SELECT 1 FROM public.categories child WHERE child.parent_id=c.id);
SELECT 'public_leak' AS check_name,count(*)::bigint AS actual FROM public.categories WHERE taxonomy_version=${version} AND is_active=true;
SELECT 'aliases' AS check_name,resolution_state AS key,count(*)::bigint AS actual FROM public.taxonomy_aliases WHERE taxonomy_version=${version} GROUP BY resolution_state ORDER BY resolution_state;
SELECT 'successor_edges' AS check_name,count(*)::bigint AS actual FROM public.taxonomy_node_relationships WHERE taxonomy_version=${version} AND successor_category_id IS NOT NULL;
`;
}

function rollbackSql(pkg) {
  const version = sql(pkg.manifest.taxonomy_version);
  const token = sql(pkg.manifest.package_sha256);
  return `-- W36 EMPTY-BOOTSTRAP ROLLBACK — local/review candidate only
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='60s';
DO $guard$
DECLARE dependencies BIGINT; package_rows BIGINT;
BEGIN
  IF current_setting('esnaftavar.taxonomy_target_mode',true) IS DISTINCT FROM 'local' THEN RAISE EXCEPTION 'W36_LOCAL_ONLY_GUARD'; END IF;
  IF current_setting('esnaftavar.taxonomy_apply_token',true) IS DISTINCT FROM ${token} THEN RAISE EXCEPTION 'W36_PACKAGE_TOKEN_MISMATCH'; END IF;
  SELECT count(*) INTO dependencies FROM public.products p JOIN public.categories c ON c.id=p.category_id WHERE c.taxonomy_version=${version};
  IF dependencies<>0 THEN RAISE EXCEPTION 'W36_ROLLBACK_DEPENDENT_PRODUCTS'; END IF;
  SELECT count(*) INTO package_rows FROM public.categories WHERE taxonomy_version=${version};
  IF package_rows NOT IN (0,${pkg.manifest.expected.categories}) THEN RAISE EXCEPTION 'W36_ROLLBACK_PARTIAL_PACKAGE'; END IF;
END
$guard$;
DELETE FROM public.taxonomy_alias_targets t USING public.taxonomy_aliases a WHERE t.alias_id=a.id AND a.taxonomy_version=${version};
DELETE FROM public.taxonomy_aliases WHERE taxonomy_version=${version};
DELETE FROM public.taxonomy_node_relationships WHERE taxonomy_version=${version};
DELETE FROM public.taxonomy_id_allocations WHERE taxonomy_version=${version};
DELETE FROM public.taxonomy_import_runs WHERE package_sha256=${token} AND taxonomy_version=${version};
DELETE FROM public.categories WHERE taxonomy_version=${version} AND level=4;
DELETE FROM public.categories WHERE taxonomy_version=${version} AND level=3;
DELETE FROM public.categories WHERE taxonomy_version=${version} AND level=2;
DELETE FROM public.categories WHERE taxonomy_version=${version} AND level=1;
COMMIT;
`;
}

export function compilePackage(pkg) {
  const header = `-- Generated by Wave 36 taxonomy migration compiler.\n-- Package SHA-256: ${pkg.manifest.package_sha256}\n-- Package kind: ${pkg.manifest.package_kind}\n-- Deterministic artifact; no timestamp, random ID, credential, or remote target.\n`;
  const forward = `${header}BEGIN;\nSET LOCAL lock_timeout='3s';\nSET LOCAL statement_timeout='120s';\n${SCHEMA_SQL}\n${guardSql(pkg)}\n${categorySql(pkg)}\n${allocationSql(pkg)}\n${relationshipSql(pkg)}\n${aliasSql(pkg)}\n${postconditionSql(pkg)}\n${QUERY_CONTRACT_SQL}\nCOMMIT;\n`;
  const rollback = `${header}${rollbackSql(pkg)}`;
  const postcheck = `${header}${postcheckSql(pkg)}`;
  return { forward, rollback, postcheck };
}

export async function compileToDirectory(inputDirectory, outputDirectory) {
  const pkg = await loadPackage(inputDirectory);
  const artifacts = compilePackage(pkg);
  const destination = resolve(outputDirectory);
  await mkdir(destination, { recursive: true });
  const artifactFiles = {};
  for (const [key, content] of Object.entries(artifacts)) {
    const name = `${key}.sql`;
    await writeFile(join(destination, name), content, 'utf8');
    artifactFiles[name] = { bytes: Buffer.byteLength(content), sha256: sha256(content) };
  }
  const artifactCore = {
    compiler_contract: 'w37-ledger-pair-compiler-v2',
    source_package_sha256: pkg.manifest.package_sha256,
    source_package_kind: pkg.manifest.package_kind,
    taxonomy_version: pkg.manifest.taxonomy_version,
    artifacts: artifactFiles,
    safety: {
      remote_mode_implemented: false,
      active_migration_directory: false,
      forward_hard_delete: false,
      rollback_scope: 'EXACT_EMPTY_BOOTSTRAP_PACKAGE_ONLY',
      arbitrary_split_assignment: false,
    },
  };
  const artifactManifest = { ...artifactCore, artifact_set_sha256: sha256(stableJson(artifactCore)) };
  await writeFile(join(destination, 'artifact_manifest.json'), `${JSON.stringify(artifactManifest, null, 2)}\n`, 'utf8');
  return { pkg, artifacts, artifactManifest, outputDirectory: destination };
}
