-- W52K-B / 0013: private authenticated preview only. 0012 is unchanged.
-- Empty, expiring operator-managed allowlist. No client grant/mutation endpoint.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='120s';
DO $guard$ BEGIN
 IF current_user<>'postgres' OR current_database()<>'postgres' OR current_setting('server_version')<>'17.6'
 OR current_setting('esnaftavar.w52kb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 THEN RAISE EXCEPTION 'W52KB_EXECUTION_CONTEXT'; END IF;
 IF NOT EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations WHERE version='20260916001200' AND name='0012_production_canonical_side_by_side')
 OR EXISTS(SELECT 1 FROM public.production_taxonomy_config WHERE public_enabled OR preview_enabled)
 OR (SELECT count(*) FROM public.canonical_categories)<>1563
 OR (SELECT count(*) FROM public.product_canonical_assignments)<>20
 THEN RAISE EXCEPTION 'W52KB_STAGED_BASELINE_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname=ANY(ARRAY['taxonomy_capabilities_v2','taxonomy_roots_v2','taxonomy_children_v2','taxonomy_descendants_v2','taxonomy_exact_leaf_v2','taxonomy_breadcrumb_v2','taxonomy_resolve_alias_v2','taxonomy_search_context_v2']))
 THEN RAISE EXCEPTION 'W52KB_EXISTING_CONTRACT_REFUSED'; END IF;
END $guard$;
CREATE SCHEMA production_preview_private AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA production_preview_private FROM PUBLIC,anon,authenticated,service_role;
CREATE TABLE production_preview_private.testers (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 enabled boolean NOT NULL DEFAULT false,
 granted_at timestamptz NOT NULL DEFAULT now(),
 expires_at timestamptz NOT NULL,
 CHECK(expires_at>granted_at AND expires_at<=granted_at+interval '30 days')
);
ALTER TABLE production_preview_private.testers ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON production_preview_private.testers FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION public._w52kb_assert_contract_v2(p_client_contract_version text,p_taxonomy_version text,p_preview boolean)
RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 IF auth.role() IS DISTINCT FROM 'authenticated' OR auth.uid() IS NULL
 OR NOT EXISTS(SELECT 1 FROM production_preview_private.testers t WHERE t.user_id=auth.uid() AND t.enabled AND t.granted_at<=now() AND t.expires_at>now())
 THEN RAISE EXCEPTION 'W52KB_PREVIEW_UNAUTHORIZED' USING ERRCODE='42501'; END IF;
 IF p_client_contract_version IS DISTINCT FROM 'taxonomy-client-v1' OR p_taxonomy_version IS DISTINCT FROM 'canonical-v1.0.0'
 THEN RAISE EXCEPTION 'W38_CLIENT_CONTRACT_VERSION_MISMATCH'; END IF;
 IF p_preview IS DISTINCT FROM true THEN RAISE EXCEPTION 'W52KB_PRIVATE_PREVIEW_REQUIRED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.production_taxonomy_config WHERE singleton_id=1 AND NOT public_enabled AND NOT preview_enabled)
 THEN RAISE EXCEPTION 'W52KB_PUBLIC_ACTIVATION_MUST_REMAIN_OFF'; END IF;
 IF (SELECT count(*) FROM public.product_canonical_assignments)<>20
 OR EXISTS(SELECT 1 FROM public.products p LEFT JOIN public.product_canonical_assignments a ON a.product_id=p.id WHERE a.product_id IS NULL)
 THEN RAISE EXCEPTION 'W52KB_MAPPING_INCOMPLETE'; END IF;
END $fn$;

CREATE FUNCTION public._w52kb_visible_v2(p_category_id uuid,p_taxonomy_version text,p_preview boolean)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 WITH RECURSIVE ancestors AS (
  SELECT id,parent_id,lifecycle_state,taxonomy_version,policy_class FROM public.canonical_categories WHERE id=p_category_id
  UNION ALL SELECT c.id,c.parent_id,c.lifecycle_state,c.taxonomy_version,c.policy_class FROM public.canonical_categories c JOIN ancestors a ON c.id=a.parent_id
 ) SELECT p_preview=true AND EXISTS(SELECT 1 FROM ancestors)
 AND NOT EXISTS(SELECT 1 FROM ancestors WHERE lifecycle_state<>'staged' OR taxonomy_version<>p_taxonomy_version OR policy_class='EXCLUDED')
$fn$;

CREATE FUNCTION public._w52kb_assignable(p_category_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 WITH RECURSIVE ancestors AS (
  SELECT id,parent_id FROM public.canonical_categories WHERE id=p_category_id
  UNION ALL SELECT c.id,c.parent_id FROM public.canonical_categories c JOIN ancestors a ON c.id=a.parent_id
 ) SELECT public._w52kb_visible_v2(p_category_id,'canonical-v1.0.0',true)
 AND EXISTS(SELECT 1 FROM public.canonical_category_qualification WHERE category_id=p_category_id AND qualification='LEAF_ASSIGNABLE_CANDIDATE')
 AND NOT EXISTS(SELECT 1 FROM public.canonical_categories WHERE parent_id=p_category_id)
 AND NOT EXISTS(SELECT 1 FROM ancestors a LEFT JOIN public.canonical_category_qualification q ON q.category_id=a.id WHERE q.category_id IS NULL OR q.policy_gate<>'PASS' OR q.professional_gate<>'PASS')
$fn$;

CREATE FUNCTION public.taxonomy_capabilities_v2(p_client_contract_version text,p_taxonomy_version text)
RETURNS SETOF jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public._w52kb_assert_contract_v2(p_client_contract_version,p_taxonomy_version,true);
 RETURN NEXT jsonb_build_object(
  'contract_version','taxonomy-client-v1','client_contract_version','taxonomy-client-v1',
  'taxonomy_version','canonical-v1.0.0','taxonomy_data_version','canonical-v1.0.0',
  'rpc_contract_version','taxonomy-rpc-v2','rpc_generation',2,
  'supported_features',ARRAY['roots','children','descendants','breadcrumb','alias_resolution','search','product_scopes'],
  'verified_evidence',ARRAY['authoritative_contract_version','exact_rpc_signatures','required_response_shapes','lifecycle_publication_semantics','hierarchy_semantics','alias_outcome_semantics','taxonomy_version_semantics'],
  'preview_support',true,'preview_enabled',true,'lifecycle_metadata',true,'policy_metadata',true,'alias_state_metadata',true,'path_metadata',true,
  'public_active_root_count',0,'pilot_active_root_count',0,'preview_root_count',(SELECT count(*) FROM public.canonical_categories WHERE parent_id IS NULL AND public._w52kb_visible_v2(id,p_taxonomy_version,true)),
  'product_scope_contract','exact-leaf-visible-assignable-policy-eligible','product_scope_requires_assignable',true,'product_scope_policy_fail_closed',true,
  'preview_authorized',true,'preview_subject',auth.uid(),'public_enabled',false,'project_ref','mefhfvrgkwciubeajjeb',
  'preview_bridge_contract','production-private-preview-v1','product_scope_rpc','production_preview_products_v1');
END $fn$;
CREATE FUNCTION public._w52kb_node_json_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
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
    'is_assignable', public._w52kb_assignable(c.id),
    'policy_class', c.policy_class,
    'professional_review_status', c.professional_review_status,
    'taxonomy_version', c.taxonomy_version,
    'has_children', EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    'sort_order', c.sort_order,
    'is_public_active', c.lifecycle_state = 'active' AND c.is_active = true,
    'is_pilot_active', false,
    'preview_context', p_preview
  ) INTO payload
  FROM public.canonical_categories AS c
  WHERE c.id = p_category_id
    AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview);
  RETURN payload;
END
$fn$;


CREATE FUNCTION public._w52kb_path_json_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  WITH RECURSIVE breadcrumb AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.canonical_categories AS c
    WHERE c.id = p_category_id
      AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT parent.id, parent.parent_id, parent.level
    FROM public.canonical_categories AS parent
    JOIN breadcrumb AS child ON child.parent_id = parent.id
    WHERE public._w52kb_visible_v2(parent.id, p_taxonomy_version, p_preview)
  )
  SELECT coalesce(
    jsonb_agg(
      public._w52kb_node_json_v2(
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


CREATE FUNCTION public.taxonomy_roots_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, public._w52kb_assignable(c.id), c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.canonical_categories AS c
  WHERE c.taxonomy_version = p_taxonomy_version
    AND c.level = 1
    AND c.parent_id IS NULL
    AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
  ORDER BY c.sort_order, c.id;
END
$fn$;


CREATE FUNCTION public.taxonomy_children_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, public._w52kb_assignable(c.id), c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.canonical_categories AS c
  WHERE c.parent_id = p_parent_id
    AND c.taxonomy_version = p_taxonomy_version
    AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
  ORDER BY c.sort_order, c.id;
END
$fn$;


CREATE FUNCTION public.taxonomy_descendants_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  WITH RECURSIVE descendants AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.canonical_categories AS c
    WHERE c.id = p_category_id
      AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT child.id, child.parent_id, child.level
    FROM public.canonical_categories AS child
    JOIN descendants AS parent ON child.parent_id = parent.id
    WHERE public._w52kb_visible_v2(child.id, p_taxonomy_version, p_preview)
  )
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, public._w52kb_assignable(c.id), c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM descendants AS d
  JOIN public.canonical_categories AS c ON c.id = d.id
  ORDER BY c.level, c.sort_order, c.id;
END
$fn$;


CREATE FUNCTION public.taxonomy_exact_leaf_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, public._w52kb_assignable(c.id), c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    false,
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM public.canonical_categories AS c
  WHERE c.id = p_category_id
    AND c.taxonomy_version = p_taxonomy_version
    AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
    AND public._w52kb_assignable(c.id) = true
    AND c.policy_class <> 'EXCLUDED'
    AND c.professional_review_status NOT IN ('pending', 'rejected')
    AND NOT EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    );
END
$fn$;


CREATE FUNCTION public.taxonomy_breadcrumb_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
    p_client_contract_version,
    p_taxonomy_version,
    p_preview
  );
  RETURN QUERY
  WITH RECURSIVE breadcrumb AS (
    SELECT c.id, c.parent_id, c.level
    FROM public.canonical_categories AS c
    WHERE c.id = p_category_id
      AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
    UNION ALL
    SELECT parent.id, parent.parent_id, parent.level
    FROM public.canonical_categories AS parent
    JOIN breadcrumb AS child ON child.parent_id = parent.id
    WHERE public._w52kb_visible_v2(parent.id, p_taxonomy_version, p_preview)
  )
  SELECT
    c.id, c.parent_id, c.name, c.slug, c.level,
    c.lifecycle_state, public._w52kb_assignable(c.id), c.policy_class,
    c.professional_review_status, c.taxonomy_version,
    EXISTS (
      SELECT 1 FROM public.canonical_categories AS child
      WHERE child.parent_id = c.id
        AND child.taxonomy_version = c.taxonomy_version
    ),
    c.sort_order,
    c.lifecycle_state = 'active' AND c.is_active = true,
    false,
    p_preview
  FROM breadcrumb AS b
  JOIN public.canonical_categories AS c ON c.id = b.id
  ORDER BY c.level;
END
$fn$;


CREATE FUNCTION public.taxonomy_resolve_alias_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
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
       AND NOT public._w52kb_visible_v2(
         alias_row.direct_target_category_id,
         p_taxonomy_version,
         true
       ) THEN
      RAISE EXCEPTION 'W38_ALIAS_TARGET_NOT_VISIBLE';
    END IF;
  ELSE
    IF alias_row.resolution_state <> 'RESOLVED'
       OR NOT public._w52kb_visible_v2(
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


CREATE FUNCTION public.taxonomy_search_context_v2(
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
  PERFORM public._w52kb_assert_contract_v2(
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
    FROM public.canonical_categories AS c
    WHERE c.taxonomy_version = p_taxonomy_version
      AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
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
    JOIN public.canonical_categories AS c ON c.id = a.direct_target_category_id
    WHERE a.taxonomy_version = p_taxonomy_version
      AND (a.is_active = true OR p_preview)
      AND a.resolution_state = 'RESOLVED'
      AND public._w52kb_visible_v2(c.id, p_taxonomy_version, p_preview)
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
    public._w52kb_node_json_v2(
      selected.category_id,
      p_client_contract_version,
      p_taxonomy_version,
      p_preview
    ),
    public._w52kb_path_json_v2(
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

-- Exact owner mappings are readable for review, including six gated mappings.
-- Eligibility never grants product visibility or assignment for those six.
CREATE FUNCTION public.production_preview_mappings_v1(p_client_contract_version text,p_taxonomy_version text)
RETURNS TABLE(product_id uuid,canonical_category_id uuid,canonical_path text,canonical_name text,eligible boolean)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public._w52kb_assert_contract_v2(p_client_contract_version,p_taxonomy_version,true);
 RETURN QUERY SELECT a.product_id,a.canonical_category_id,a.canonical_path,c.name,public._w52kb_assignable(c.id)
 FROM public.product_canonical_assignments a JOIN public.canonical_categories c ON c.id=a.canonical_category_id ORDER BY a.product_id;
END $fn$;

-- INVOKER deliberately preserves caller RLS on products and brands.
CREATE FUNCTION public.production_preview_products_v1(
 p_client_contract_version text,p_taxonomy_version text,
 p_category_id uuid DEFAULT NULL,p_product_id uuid DEFAULT NULL,p_brand_id uuid DEFAULT NULL,
 p_is_featured boolean DEFAULT NULL,p_term text DEFAULT NULL,p_exact_leaf boolean DEFAULT false,
 p_sort_by text DEFAULT 'created_at',p_ascending boolean DEFAULT true,p_limit integer DEFAULT 20,p_offset integer DEFAULT 0
) RETURNS TABLE(product_id uuid,canonical_category_id uuid,canonical_path text,product jsonb)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 -- Capability checks identity, allowlist, public OFF and mapping completeness.
 PERFORM * FROM public.taxonomy_capabilities_v2(p_client_contract_version,p_taxonomy_version);
 IF p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0 OR p_ascending IS NULL
 OR p_sort_by IS NULL OR p_sort_by NOT IN ('created_at','name','price','rating') OR length(p_term)>200 OR p_exact_leaf IS NULL
 THEN RAISE EXCEPTION 'W52KB_PRODUCT_SCOPE_ARGUMENTS'; END IF;
 IF p_category_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.taxonomy_breadcrumb_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true))
 THEN RAISE EXCEPTION 'W52KB_CATEGORY_UNAVAILABLE'; END IF;
 IF p_exact_leaf AND (p_category_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.taxonomy_exact_leaf_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true)))
 THEN RAISE EXCEPTION 'W52KB_EXACT_LEAF_REQUIRED'; END IF;
 RETURN QUERY WITH allowed AS MATERIALIZED (
  SELECT m.* FROM public.production_preview_mappings_v1(p_client_contract_version,p_taxonomy_version) m
  WHERE m.eligible AND (p_category_id IS NULL OR m.canonical_category_id IN (
   SELECT d.id FROM public.taxonomy_descendants_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true) d
  ))
 ), projected AS (
  SELECT p.id,m.canonical_category_id,m.canonical_path,p.name,p.created_at,
   to_jsonb(p)||jsonb_build_object('category_id',m.canonical_category_id,'legacy_category_id',p.category_id,'categories',jsonb_build_object('name',m.canonical_name),
    'brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) AS payload
  FROM public.products p JOIN allowed m ON m.product_id=p.id LEFT JOIN public.brands b ON b.id=p.brand_id
  WHERE p.is_active AND (p_product_id IS NULL OR p.id=p_product_id) AND (p_brand_id IS NULL OR p.brand_id=p_brand_id)
   AND (p_is_featured IS NULL OR p.is_featured=p_is_featured)
   AND (p_term IS NULL OR p.name ILIKE '%'||p_term||'%' OR p.description ILIKE '%'||p_term||'%')
 ) SELECT x.id,x.canonical_category_id,x.canonical_path,x.payload FROM projected x
 ORDER BY
  CASE WHEN p_sort_by='name' AND p_ascending THEN x.name END ASC,
  CASE WHEN p_sort_by='name' AND NOT p_ascending THEN x.name END DESC,
  CASE WHEN p_sort_by='price' AND p_ascending THEN (x.payload->>'price')::numeric END ASC,
  CASE WHEN p_sort_by='price' AND NOT p_ascending THEN (x.payload->>'price')::numeric END DESC,
  CASE WHEN p_sort_by='rating' AND p_ascending THEN (x.payload->>'rating')::numeric END ASC,
  CASE WHEN p_sort_by='rating' AND NOT p_ascending THEN (x.payload->>'rating')::numeric END DESC,
  CASE WHEN p_sort_by='created_at' AND p_ascending THEN x.created_at END ASC,
  CASE WHEN p_sort_by='created_at' AND NOT p_ascending THEN x.created_at END DESC,x.id
 LIMIT p_limit OFFSET p_offset;
END $fn$;

DO $grants$ DECLARE f record; BEGIN
 FOR f IN SELECT oid::regprocedure AS signature,proname FROM pg_proc WHERE pronamespace='public'::regnamespace
 AND (proname=ANY(ARRAY['taxonomy_capabilities_v2','taxonomy_roots_v2','taxonomy_children_v2','taxonomy_descendants_v2','taxonomy_exact_leaf_v2','taxonomy_breadcrumb_v2','taxonomy_resolve_alias_v2','taxonomy_search_context_v2','production_preview_mappings_v1','production_preview_products_v1']) OR proname LIKE '\_w52kb\_%') LOOP
 EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',f.signature);
 IF f.proname=ANY(ARRAY['taxonomy_capabilities_v2','taxonomy_roots_v2','taxonomy_children_v2','taxonomy_descendants_v2','taxonomy_exact_leaf_v2','taxonomy_breadcrumb_v2','taxonomy_resolve_alias_v2','taxonomy_search_context_v2','production_preview_mappings_v1','production_preview_products_v1']) THEN EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated',f.signature); END IF;
 END LOOP;
END $grants$;
COMMIT;
