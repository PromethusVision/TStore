-- Wave 38B local/staged migration candidate.
-- Additive strict canonical taxonomy contract v2; not an active migration.
-- No environment ref, credential, taxonomy row mutation, or preview activation.

BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '120s';

DO $w38_baseline_guard$
DECLARE
  delta_count INTEGER;
  row_count INTEGER;
BEGIN
  IF to_regclass('supabase_migrations.schema_migrations') IS NULL THEN
    RAISE EXCEPTION 'W38_MIGRATION_LEDGER_MISSING';
  END IF;

  IF EXISTS (
    SELECT version, name
    FROM supabase_migrations.schema_migrations
    GROUP BY version, name
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'W38_MIGRATION_LEDGER_DUPLICATE_PAIR';
  END IF;

  WITH expected(version, name) AS (VALUES
    ('20260812010907', '0001_core_auth_catalog'),
    ('20260812011047', '0002_shops'),
    ('20260812011128', '0003_carts_v2'),
    ('20260812013109', '0004_qr_verified_purchases'),
    ('20260812013220', '0005_verified_shop_ratings'),
    ('20260812013308', '0006_chat_notifications_account'),
    ('20260812013403', '0007_storage_realtime'),
    ('20260814000820', '0008_fix_profile_role_guard'),
    ('20260815000900', '0009_verified_product_reviews_storage'),
    ('20260829001000', '0010_canonical_taxonomy_v1_staged_bootstrap')
  ), delta AS (
    SELECT * FROM (
      SELECT l.version::TEXT, l.name::TEXT
      FROM supabase_migrations.schema_migrations AS l
      EXCEPT
      SELECT e.version, e.name FROM expected AS e
    ) AS unexpected
    UNION ALL
    SELECT * FROM (
      SELECT e.version, e.name FROM expected AS e
      EXCEPT
      SELECT l.version::TEXT, l.name::TEXT
      FROM supabase_migrations.schema_migrations AS l
    ) AS missing
  )
  SELECT count(*) INTO delta_count FROM delta;
  IF delta_count <> 0 THEN
    RAISE EXCEPTION 'W38_MIGRATION_LEDGER_MISMATCH';
  END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0';
  IF row_count <> 1563 THEN RAISE EXCEPTION 'W38_CATEGORY_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND level = 1;
  IF row_count <> 24 THEN RAISE EXCEPTION 'W38_L1_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND level = 2;
  IF row_count <> 244 THEN RAISE EXCEPTION 'W38_L2_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND level = 3;
  IF row_count <> 1096 THEN RAISE EXCEPTION 'W38_L3_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND level = 4;
  IF row_count <> 199 THEN RAISE EXCEPTION 'W38_L4_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories AS c
  WHERE c.taxonomy_version = 'canonical-v1.0.0'
    AND NOT EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    );
  IF row_count <> 1245 THEN RAISE EXCEPTION 'W38_LEAF_COUNT'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories AS c
  WHERE c.taxonomy_version = 'canonical-v1.0.0'
    AND (
      c.id IS NULL OR c.name IS NULL OR c.slug IS NULL OR c.level IS NULL
      OR c.lifecycle_state IS NULL OR c.is_assignable IS NULL
      OR c.policy_class IS NULL OR c.professional_review_status IS NULL
    );
  IF row_count <> 0 THEN RAISE EXCEPTION 'W38_STRICT_NODE_FIELD_GAP'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND (lifecycle_state <> 'staged' OR is_active <> false);
  IF row_count <> 0 THEN RAISE EXCEPTION 'W38_UNEXPECTED_PUBLIC_ACTIVATION'; END IF;
END
$w38_baseline_guard$;

CREATE TABLE IF NOT EXISTS public.taxonomy_contract_config (
  singleton_id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
  client_contract_version TEXT NOT NULL,
  taxonomy_data_version TEXT NOT NULL,
  rpc_contract_version TEXT NOT NULL,
  rpc_generation SMALLINT NOT NULL CHECK (rpc_generation > 0),
  preview_supported BOOLEAN NOT NULL DEFAULT true,
  preview_enabled BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.taxonomy_contract_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.taxonomy_contract_config FROM PUBLIC, anon, authenticated;

INSERT INTO public.taxonomy_contract_config (
  singleton_id,
  client_contract_version,
  taxonomy_data_version,
  rpc_contract_version,
  rpc_generation,
  preview_supported,
  preview_enabled
) VALUES (
  1,
  'taxonomy-client-v1',
  'canonical-v1.0.0',
  'taxonomy-rpc-v2',
  2,
  true,
  false
)
ON CONFLICT (singleton_id) DO NOTHING;

CREATE OR REPLACE FUNCTION public._taxonomy_assert_contract_v2(
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  config_row public.taxonomy_contract_config%ROWTYPE;
BEGIN
  IF p_client_contract_version IS NULL
     OR btrim(p_client_contract_version) = ''
     OR p_client_contract_version <> 'taxonomy-client-v1' THEN
    RAISE EXCEPTION 'W38_CLIENT_CONTRACT_VERSION_MISMATCH';
  END IF;
  IF p_taxonomy_version IS NULL
     OR btrim(p_taxonomy_version) = ''
     OR p_taxonomy_version <> 'canonical-v1.0.0' THEN
    RAISE EXCEPTION 'W38_TAXONOMY_VERSION_MISMATCH';
  END IF;
  IF p_preview IS NULL THEN
    RAISE EXCEPTION 'W38_PREVIEW_FLAG_REQUIRED';
  END IF;

  SELECT * INTO config_row
  FROM public.taxonomy_contract_config
  WHERE singleton_id = 1;
  IF NOT FOUND
     OR config_row.client_contract_version <> p_client_contract_version
     OR config_row.taxonomy_data_version <> p_taxonomy_version
     OR config_row.rpc_contract_version <> 'taxonomy-rpc-v2'
     OR config_row.rpc_generation <> 2
     OR config_row.preview_supported <> true THEN
    RAISE EXCEPTION 'W38_CAPABILITY_CONFIG_INVALID';
  END IF;
  IF p_preview AND NOT config_row.preview_enabled THEN
    RAISE EXCEPTION 'W38_PREVIEW_DISABLED';
  END IF;
END
$fn$;

CREATE OR REPLACE FUNCTION public._taxonomy_visible_v2(
  p_category_id UUID,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
  SELECT EXISTS (
    SELECT 1
    FROM public.categories AS c
    WHERE c.id = p_category_id
      AND c.taxonomy_version = p_taxonomy_version
      AND (
        (c.lifecycle_state = 'active' AND c.is_active = true)
        OR (p_preview AND c.lifecycle_state = 'staged')
      )
  )
$fn$;

CREATE OR REPLACE FUNCTION public._taxonomy_node_json_v2(
  p_category_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  payload JSONB;
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  SELECT jsonb_build_object(
    'id', c.id,
    'parent_id', c.parent_id,
    'name', c.name,
    'slug', c.slug,
    'level', c.level,
    'lifecycle_state', c.lifecycle_state,
    'is_assignable', c.is_assignable,
    'policy_class', c.policy_class,
    'professional_review_status', c.professional_review_status,
    'taxonomy_version', c.taxonomy_version,
    'has_children', EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    'sort_order', c.sort_order,
    'is_public_active', c.lifecycle_state = 'active' AND c.is_active = true,
    'is_pilot_active', false,
    'preview_context', p_preview
  ) INTO payload
  FROM public.categories AS c
  WHERE c.id = p_category_id
    AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview);
  RETURN payload;
END
$fn$;

CREATE OR REPLACE FUNCTION public._taxonomy_path_json_v2(
  p_category_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  payload JSONB;
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  WITH RECURSIVE breadcrumb AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.categories AS c
    WHERE c.id = p_category_id
      AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT parent.id, parent.parent_id, parent.level
    FROM public.categories AS parent
    JOIN breadcrumb AS child ON child.parent_id = parent.id
    WHERE public._taxonomy_visible_v2(parent.id, p_taxonomy_version, p_preview)
  )
  SELECT coalesce(
    jsonb_agg(
      public._taxonomy_node_json_v2(
        breadcrumb.id,
        p_client_contract_version,
        p_taxonomy_version,
        p_preview
      ) ORDER BY breadcrumb.level
    ),
    '[]'::JSONB
  ) INTO payload
  FROM breadcrumb;
  RETURN payload;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_capabilities_v2(
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT
)
RETURNS TABLE(
  contract_version TEXT,
  client_contract_version TEXT,
  taxonomy_version TEXT,
  taxonomy_data_version TEXT,
  rpc_contract_version TEXT,
  rpc_generation SMALLINT,
  supported_features TEXT[],
  verified_evidence TEXT[],
  preview_support BOOLEAN,
  preview_enabled BOOLEAN,
  lifecycle_metadata BOOLEAN,
  policy_metadata BOOLEAN,
  alias_state_metadata BOOLEAN,
  path_metadata BOOLEAN,
  public_active_root_count INTEGER,
  pilot_active_root_count INTEGER,
  preview_root_count INTEGER,
  product_scope_contract TEXT,
  product_scope_requires_assignable BOOLEAN,
  product_scope_policy_fail_closed BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  config_row public.taxonomy_contract_config%ROWTYPE;
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    false
  );
  SELECT * INTO config_row
  FROM public.taxonomy_contract_config
  WHERE singleton_id = 1;

  RETURN QUERY SELECT
    config_row.client_contract_version,
    config_row.client_contract_version,
    config_row.taxonomy_data_version,
    config_row.taxonomy_data_version,
    config_row.rpc_contract_version,
    config_row.rpc_generation,
    ARRAY[
      'roots', 'children', 'descendants', 'breadcrumb',
      'alias_resolution', 'search', 'product_scopes'
    ]::TEXT[],
    ARRAY[
      'authoritative_contract_version', 'exact_rpc_signatures',
      'required_response_shapes', 'lifecycle_publication_semantics',
      'hierarchy_semantics', 'alias_outcome_semantics',
      'taxonomy_version_semantics'
    ]::TEXT[],
    config_row.preview_supported,
    config_row.preview_enabled,
    true,
    true,
    true,
    true,
    (
      SELECT count(*)::INTEGER FROM public.categories AS c
      WHERE c.taxonomy_version = p_taxonomy_version
        AND c.level = 1 AND c.parent_id IS NULL
        AND c.lifecycle_state = 'active' AND c.is_active = true
    ),
    0,
    CASE WHEN config_row.preview_enabled THEN (
      SELECT count(*)::INTEGER FROM public.categories AS c
      WHERE c.taxonomy_version = p_taxonomy_version
        AND c.level = 1 AND c.parent_id IS NULL
        AND c.lifecycle_state = 'staged'
    ) ELSE 0 END,
    'exact-leaf-visible-assignable-policy-eligible'::TEXT,
    true,
    true;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_roots_v2(
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  id UUID, parent_id UUID, name TEXT, slug TEXT, level SMALLINT,
  lifecycle_state TEXT, is_assignable BOOLEAN, policy_class TEXT,
  professional_review_status TEXT, taxonomy_version TEXT,
  has_children BOOLEAN, sort_order INTEGER, is_public_active BOOLEAN,
  is_pilot_active BOOLEAN, preview_context BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, c.is_assignable, c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.categories AS c
  WHERE c.taxonomy_version = p_taxonomy_version
    AND c.level = 1
    AND c.parent_id IS NULL
    AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
  ORDER BY c.sort_order, c.id;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_children_v2(
  p_parent_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  id UUID, parent_id UUID, name TEXT, slug TEXT, level SMALLINT,
  lifecycle_state TEXT, is_assignable BOOLEAN, policy_class TEXT,
  professional_review_status TEXT, taxonomy_version TEXT,
  has_children BOOLEAN, sort_order INTEGER, is_public_active BOOLEAN,
  is_pilot_active BOOLEAN, preview_context BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, c.is_assignable, c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.categories AS c
  WHERE c.parent_id = p_parent_id
    AND c.taxonomy_version = p_taxonomy_version
    AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
  ORDER BY c.sort_order, c.id;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_descendants_v2(
  p_category_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  id UUID, parent_id UUID, name TEXT, slug TEXT, level SMALLINT,
  lifecycle_state TEXT, is_assignable BOOLEAN, policy_class TEXT,
  professional_review_status TEXT, taxonomy_version TEXT,
  has_children BOOLEAN, sort_order INTEGER, is_public_active BOOLEAN,
  is_pilot_active BOOLEAN, preview_context BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  WITH RECURSIVE descendants AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.categories AS c
    WHERE c.id = p_category_id
      AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT child.id, child.parent_id, child.level
    FROM public.categories AS child
    JOIN descendants AS parent ON child.parent_id = parent.id
    WHERE public._taxonomy_visible_v2(child.id, p_taxonomy_version, p_preview)
  )
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, c.is_assignable, c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM descendants AS d
  JOIN public.categories AS c ON c.id = d.id
  ORDER BY c.level, c.sort_order, c.id;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_exact_leaf_v2(
  p_category_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  id UUID, parent_id UUID, name TEXT, slug TEXT, level SMALLINT,
  lifecycle_state TEXT, is_assignable BOOLEAN, policy_class TEXT,
  professional_review_status TEXT, taxonomy_version TEXT,
  has_children BOOLEAN, sort_order INTEGER, is_public_active BOOLEAN,
  is_pilot_active BOOLEAN, preview_context BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, c.is_assignable, c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    false,
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.categories AS c
  WHERE c.id = p_category_id
    AND c.taxonomy_version = p_taxonomy_version
    AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
    AND c.is_assignable = true
    AND c.policy_class <> 'EXCLUDED'
    AND c.professional_review_status NOT IN ('pending', 'rejected')
    AND NOT EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    );
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_breadcrumb_v2(
  p_category_id UUID,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  id UUID, parent_id UUID, name TEXT, slug TEXT, level SMALLINT,
  lifecycle_state TEXT, is_assignable BOOLEAN, policy_class TEXT,
  professional_review_status TEXT, taxonomy_version TEXT,
  has_children BOOLEAN, sort_order INTEGER, is_public_active BOOLEAN,
  is_pilot_active BOOLEAN, preview_context BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  WITH RECURSIVE breadcrumb AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.categories AS c
    WHERE c.id = p_category_id
      AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT parent.id, parent.parent_id, parent.level
    FROM public.categories AS parent
    JOIN breadcrumb AS child ON child.parent_id = parent.id
    WHERE public._taxonomy_visible_v2(parent.id, p_taxonomy_version, p_preview)
  )
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, c.is_assignable, c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM breadcrumb AS b
  JOIN public.categories AS c ON c.id = b.id
  ORDER BY c.level;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_resolve_alias_v2(
  p_alias_locator TEXT,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  alias_locator TEXT,
  resolution_state TEXT,
  direct_target_category_id UUID,
  taxonomy_version TEXT,
  alias_kind TEXT,
  matched_via_alias BOOLEAN,
  target_count INTEGER
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  alias_row public.taxonomy_aliases%ROWTYPE;
  alias_count INTEGER;
  edge_count INTEGER;
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  IF p_alias_locator IS NULL
     OR btrim(p_alias_locator) = ''
     OR length(p_alias_locator) > 200 THEN
    RAISE EXCEPTION 'W38_ALIAS_LOCATOR_INVALID';
  END IF;

  SELECT count(*) INTO alias_count
  FROM public.taxonomy_aliases AS a
  WHERE a.taxonomy_version = p_taxonomy_version
    AND (a.is_active = true OR p_preview)
    AND lower(a.alias_locator) = lower(btrim(p_alias_locator));
  IF alias_count = 0 THEN RETURN; END IF;
  IF alias_count <> 1 THEN RAISE EXCEPTION 'W38_ALIAS_LOCATOR_NON_UNIQUE'; END IF;

  SELECT * INTO alias_row
  FROM public.taxonomy_aliases AS a
  WHERE a.taxonomy_version = p_taxonomy_version
    AND (a.is_active = true OR p_preview)
    AND lower(a.alias_locator) = lower(btrim(p_alias_locator));

  SELECT count(*) INTO edge_count
  FROM public.taxonomy_alias_targets AS target
  WHERE target.alias_id = alias_row.id;

  IF alias_row.resolution_state = 'RESOLVED'
     AND (alias_row.direct_target_category_id IS NULL OR edge_count <> 1) THEN
    RAISE EXCEPTION 'W38_ALIAS_GRAPH_INVALID';
  ELSIF alias_row.resolution_state = 'AMBIGUOUS'
     AND (alias_row.direct_target_category_id IS NOT NULL OR edge_count < 2) THEN
    RAISE EXCEPTION 'W38_ALIAS_GRAPH_INVALID';
  ELSIF alias_row.resolution_state IN ('TOMBSTONE', 'UNRESOLVED')
     AND (alias_row.direct_target_category_id IS NOT NULL OR edge_count <> 0) THEN
    RAISE EXCEPTION 'W38_ALIAS_GRAPH_INVALID';
  ELSIF alias_row.resolution_state NOT IN (
    'RESOLVED', 'AMBIGUOUS', 'TOMBSTONE', 'UNRESOLVED'
  ) THEN
    RAISE EXCEPTION 'W38_ALIAS_STATE_INVALID';
  END IF;

  IF p_preview THEN
    IF alias_row.resolution_state = 'RESOLVED'
       AND NOT public._taxonomy_visible_v2(
         alias_row.direct_target_category_id,
         p_taxonomy_version,
         true
       ) THEN
      RAISE EXCEPTION 'W38_ALIAS_TARGET_NOT_VISIBLE';
    END IF;
  ELSE
    IF alias_row.resolution_state <> 'RESOLVED'
       OR NOT public._taxonomy_visible_v2(
         alias_row.direct_target_category_id,
         p_taxonomy_version,
         false
       ) THEN
      RETURN;
    END IF;
  END IF;

  alias_locator := alias_row.alias_locator;
  resolution_state := alias_row.resolution_state;
  direct_target_category_id := alias_row.direct_target_category_id;
  taxonomy_version := alias_row.taxonomy_version;
  alias_kind := alias_row.alias_kind;
  matched_via_alias := true;
  target_count := edge_count;
  RETURN NEXT;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_search_context_v2(
  p_term TEXT,
  p_client_contract_version TEXT,
  p_taxonomy_version TEXT,
  p_preview BOOLEAN DEFAULT false
)
RETURNS TABLE(
  matched_node JSONB,
  path JSONB,
  alias_context JSONB,
  taxonomy_version TEXT,
  match_kind TEXT,
  matched_via_alias BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
BEGIN
  PERFORM public._taxonomy_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  IF p_term IS NULL OR btrim(p_term) = '' OR length(p_term) > 200 THEN
    RAISE EXCEPTION 'W38_SEARCH_TERM_INVALID';
  END IF;

  RETURN QUERY
  WITH raw_matches AS (
    SELECT
      c.id AS category_id,
      0 AS priority,
      'CANONICAL'::TEXT AS result_match_kind,
      NULL::TEXT AS alias_matched_text,
      NULL::TEXT AS matched_alias_locator
    FROM public.categories AS c
    WHERE c.taxonomy_version = p_taxonomy_version
      AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
      AND (
        lower(c.name) = lower(btrim(p_term))
        OR lower(c.slug) = lower(btrim(p_term))
      )
    UNION ALL
    SELECT
      c.id,
      1,
      a.alias_kind,
      coalesce(a.alias_text, a.alias_slug, a.alias_locator),
      a.alias_locator
    FROM public.taxonomy_aliases AS a
    JOIN public.categories AS c ON c.id = a.direct_target_category_id
    WHERE a.taxonomy_version = p_taxonomy_version
      AND (a.is_active = true OR p_preview)
      AND a.resolution_state = 'RESOLVED'
      AND public._taxonomy_visible_v2(c.id, p_taxonomy_version, p_preview)
      AND (
        lower(coalesce(a.alias_text, '')) = lower(btrim(p_term))
        OR lower(coalesce(a.alias_slug, '')) = lower(btrim(p_term))
        OR lower(a.alias_locator) = lower(btrim(p_term))
      )
  ), selected AS (
    SELECT DISTINCT ON (raw_matches.category_id)
      raw_matches.category_id,
      raw_matches.priority,
      raw_matches.result_match_kind,
      raw_matches.alias_matched_text,
      raw_matches.matched_alias_locator
    FROM raw_matches
    ORDER BY raw_matches.category_id, raw_matches.priority
  )
  SELECT
    public._taxonomy_node_json_v2(
      selected.category_id,
      p_client_contract_version,
      p_taxonomy_version,
      p_preview
    ),
    public._taxonomy_path_json_v2(
      selected.category_id,
      p_client_contract_version,
      p_taxonomy_version,
      p_preview
    ),
    CASE WHEN selected.matched_alias_locator IS NULL THEN NULL ELSE
      jsonb_build_object(
        'matched_text', selected.alias_matched_text,
        'locator', selected.matched_alias_locator
      )
    END,
    p_taxonomy_version,
    selected.result_match_kind,
    selected.matched_alias_locator IS NOT NULL
  FROM selected
  ORDER BY selected.priority, selected.category_id
  LIMIT 50;
END
$fn$;

CREATE OR REPLACE FUNCTION public.taxonomy_set_preview_v2(
  p_enabled BOOLEAN,
  p_taxonomy_version TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  updated_state BOOLEAN;
BEGIN
  IF p_enabled IS NULL THEN RAISE EXCEPTION 'W38_PREVIEW_VALUE_REQUIRED'; END IF;
  IF p_taxonomy_version <> 'canonical-v1.0.0' THEN
    RAISE EXCEPTION 'W38_TAXONOMY_VERSION_MISMATCH';
  END IF;
  UPDATE public.taxonomy_contract_config
  SET preview_enabled = p_enabled, updated_at = now()
  WHERE singleton_id = 1
    AND taxonomy_data_version = p_taxonomy_version
    AND preview_supported = true
  RETURNING preview_enabled INTO updated_state;
  IF NOT FOUND THEN RAISE EXCEPTION 'W38_CAPABILITY_CONFIG_INVALID'; END IF;
  RETURN updated_state;
END
$fn$;

REVOKE ALL ON FUNCTION public._taxonomy_assert_contract_v2(TEXT, TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public._taxonomy_visible_v2(UUID, TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public._taxonomy_node_json_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public._taxonomy_path_json_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC, anon, authenticated, service_role;

REVOKE ALL ON FUNCTION public.taxonomy_capabilities_v2(TEXT, TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_roots_v2(TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_children_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_descendants_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_exact_leaf_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_breadcrumb_v2(UUID, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_resolve_alias_v2(TEXT, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_search_context_v2(TEXT, TEXT, TEXT, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.taxonomy_set_preview_v2(BOOLEAN, TEXT) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.taxonomy_capabilities_v2(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_roots_v2(TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_children_v2(UUID, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_descendants_v2(UUID, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_exact_leaf_v2(UUID, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_breadcrumb_v2(UUID, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_resolve_alias_v2(TEXT, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_search_context_v2(TEXT, TEXT, TEXT, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.taxonomy_set_preview_v2(BOOLEAN, TEXT) TO service_role;

DO $w38_postconditions$
DECLARE
  config_row public.taxonomy_contract_config%ROWTYPE;
  row_count INTEGER;
BEGIN
  SELECT * INTO config_row
  FROM public.taxonomy_contract_config
  WHERE singleton_id = 1;
  IF NOT FOUND
     OR config_row.client_contract_version <> 'taxonomy-client-v1'
     OR config_row.taxonomy_data_version <> 'canonical-v1.0.0'
     OR config_row.rpc_contract_version <> 'taxonomy-rpc-v2'
     OR config_row.rpc_generation <> 2
     OR config_row.preview_supported <> true THEN
    RAISE EXCEPTION 'W38_CAPABILITY_CONFIG_INVALID';
  END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0';
  IF row_count <> 1563 THEN RAISE EXCEPTION 'W38_CATEGORY_COUNT_CHANGED'; END IF;

  SELECT count(*) INTO row_count
  FROM public.categories
  WHERE taxonomy_version = 'canonical-v1.0.0'
    AND (lifecycle_state <> 'staged' OR is_active <> false);
  IF row_count <> 0 THEN RAISE EXCEPTION 'W38_UNEXPECTED_PUBLIC_ACTIVATION'; END IF;

  IF has_table_privilege('anon', 'public.taxonomy_contract_config', 'SELECT')
     OR has_table_privilege('authenticated', 'public.taxonomy_contract_config', 'SELECT')
     OR has_table_privilege('anon', 'public.taxonomy_contract_config', 'UPDATE')
     OR has_table_privilege('authenticated', 'public.taxonomy_contract_config', 'UPDATE') THEN
    RAISE EXCEPTION 'W38_CONFIG_PRIVILEGE_LEAK';
  END IF;

  IF has_function_privilege('anon', 'public.taxonomy_set_preview_v2(boolean,text)', 'EXECUTE')
     OR has_function_privilege('authenticated', 'public.taxonomy_set_preview_v2(boolean,text)', 'EXECUTE')
     OR NOT has_function_privilege('service_role', 'public.taxonomy_set_preview_v2(boolean,text)', 'EXECUTE') THEN
    RAISE EXCEPTION 'W38_PREVIEW_CONTROL_PRIVILEGE_MISMATCH';
  END IF;

  IF NOT has_function_privilege('anon', 'public.taxonomy_capabilities_v2(text,text)', 'EXECUTE')
     OR NOT has_function_privilege('authenticated', 'public.taxonomy_capabilities_v2(text,text)', 'EXECUTE') THEN
    RAISE EXCEPTION 'W38_CAPABILITY_EXECUTE_MISSING';
  END IF;
END
$w38_postconditions$;

COMMIT;
