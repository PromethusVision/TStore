-- W52L-B: additive public customer reads. 0014 is reserved by the reviewed
-- publication executor. Install this facade while public activation is OFF.
-- Dedicated tooling owns the ledger; never use generic db push for Production.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='120s';
DO $guard$ BEGIN
 IF current_setting('esnaftavar.w52lb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 OR current_database()<>'postgres' OR session_user<>'postgres' OR current_setting('server_version')<>'17.6'
 THEN RAISE EXCEPTION 'W52LB_EXECUTION_CONTEXT'; END IF;
 IF NOT EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations WHERE version='20260916001200')
 OR (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1) IS DISTINCT FROM false
 OR EXISTS(SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname LIKE 'production_public_%_v1')
 THEN RAISE EXCEPTION 'W52LB_OFF_CLEAN_BASELINE_REQUIRED'; END IF;
END $guard$;

CREATE FUNCTION public.production_public_read_capabilities_v1(p_client_contract_version text,p_taxonomy_version text)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
DECLARE cap record;
BEGIN
 SELECT * INTO STRICT cap FROM public.production_taxonomy_capabilities_v1(p_client_contract_version,p_taxonomy_version);
 IF NOT EXISTS(SELECT 1 FROM public.production_taxonomy_config WHERE singleton_id=1 AND public_enabled AND NOT preview_enabled)
 OR cap.public_active_root_count<>24 OR cap.preview_support OR cap.preview_enabled OR cap.rpc_generation<>1
 OR NOT cap.product_scope_requires_assignable OR NOT cap.product_scope_policy_fail_closed
 THEN RAISE EXCEPTION 'W52LB_PUBLIC_UNAVAILABLE' USING ERRCODE='42501'; END IF;
 RETURN jsonb_build_object('contract','production-public-customer-reads-v1','project_ref','mefhfvrgkwciubeajjeb',
 'public_enabled',true,'preview_required',false,'tester_required',false,'policy_fail_closed',true,
 'products_rpc','production_public_products_v1','listings_rpc','production_public_listings_v1','shops_rpc','production_public_shops_v1');
END $fn$;

CREATE FUNCTION public.production_public_products_v1(
 p_client_contract_version text,p_taxonomy_version text,
 p_category_id uuid DEFAULT NULL,p_product_id uuid DEFAULT NULL,p_brand_id uuid DEFAULT NULL,
 p_is_featured boolean DEFAULT NULL,p_term text DEFAULT NULL,p_exact_leaf boolean DEFAULT false,
 p_sort_by text DEFAULT 'created_at',p_ascending boolean DEFAULT true,p_limit integer DEFAULT 20,p_offset integer DEFAULT 0
) RETURNS TABLE(product_id uuid,canonical_category_id uuid,canonical_path text,product jsonb)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public.production_public_read_capabilities_v1(p_client_contract_version,p_taxonomy_version);
 IF p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0 OR p_ascending IS NULL
 OR p_sort_by IS NULL OR p_sort_by NOT IN ('created_at','name','price','rating') OR length(p_term)>200 OR p_exact_leaf IS NULL
 THEN RAISE EXCEPTION 'W52LB_PRODUCT_ARGUMENTS'; END IF;
 IF p_category_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.production_taxonomy_breadcrumb_v1(p_category_id,p_client_contract_version,p_taxonomy_version,false))
 THEN RAISE EXCEPTION 'W52LB_CATEGORY_UNAVAILABLE'; END IF;
 IF p_exact_leaf AND (p_category_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.production_taxonomy_exact_leaf_v1(p_category_id,p_client_contract_version,p_taxonomy_version,false)))
 THEN RAISE EXCEPTION 'W52LB_EXACT_LEAF_REQUIRED'; END IF;
 RETURN QUERY WITH allowed AS MATERIALIZED (
  SELECT m.product_id,m.canonical_category_id,m.canonical_path,c.name AS canonical_name
  FROM public.product_canonical_assignments m
  CROSS JOIN LATERAL public.production_taxonomy_exact_leaf_v1(m.canonical_category_id,p_client_contract_version,p_taxonomy_version,false) c
  WHERE public.production_taxonomy_assignment_visible_v1(m.canonical_category_id)
  AND (p_category_id IS NULL OR m.canonical_category_id IN (
   SELECT d.id FROM public.production_taxonomy_descendants_v1(p_category_id,p_client_contract_version,p_taxonomy_version,false) d))
 ), projected AS (
  SELECT p.id,m.canonical_category_id,m.canonical_path,p.name,p.created_at,
   to_jsonb(p)||jsonb_build_object('category_id',m.canonical_category_id,'legacy_category_id',p.category_id,
   'categories',jsonb_build_object('name',m.canonical_name),'brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) AS payload
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

CREATE FUNCTION public.production_public_listings_v1(
 p_client_contract_version text,p_taxonomy_version text,p_product_id uuid DEFAULT NULL,p_product_ids uuid[] DEFAULT NULL,
 p_shop_id uuid DEFAULT NULL,p_limit integer DEFAULT 100,p_offset integer DEFAULT 0
) RETURNS TABLE(shop_product_id uuid,product_id uuid,canonical_category_id uuid,canonical_path text,shop_product jsonb)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public.production_public_read_capabilities_v1(p_client_contract_version,p_taxonomy_version);
 IF p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0 OR cardinality(p_product_ids)>100
 THEN RAISE EXCEPTION 'W52LB_LISTING_ARGUMENTS'; END IF;
 RETURN QUERY SELECT sp.id,p.id,m.canonical_category_id,m.canonical_path,
  to_jsonb(sp)||jsonb_build_object('shops',to_jsonb(s),'products',to_jsonb(p)||jsonb_build_object(
   'category_id',m.canonical_category_id,'legacy_category_id',p.category_id,'categories',jsonb_build_object('name',c.name),
   'brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END))
 FROM public.shop_products sp JOIN public.shops s ON s.id=sp.shop_id JOIN public.products p ON p.id=sp.product_id
 JOIN public.product_canonical_assignments m ON m.product_id=p.id
 CROSS JOIN LATERAL public.production_taxonomy_exact_leaf_v1(m.canonical_category_id,p_client_contract_version,p_taxonomy_version,false) c
 LEFT JOIN public.brands b ON b.id=p.brand_id
 WHERE sp.is_active AND sp.is_available AND s.is_active AND p.is_active
  AND public.production_taxonomy_assignment_visible_v1(m.canonical_category_id)
  AND (p_product_id IS NULL OR p.id=p_product_id) AND (p_product_ids IS NULL OR p.id=ANY(p_product_ids))
  AND (p_shop_id IS NULL OR s.id=p_shop_id)
 ORDER BY sp.created_at DESC,sp.id LIMIT p_limit OFFSET p_offset;
END $fn$;

CREATE FUNCTION public.production_public_shops_v1(
 p_client_contract_version text,p_taxonomy_version text,p_shop_id uuid DEFAULT NULL,p_owner_ids uuid[] DEFAULT NULL,
 p_limit integer DEFAULT 100,p_offset integer DEFAULT 0
) RETURNS SETOF public.shops LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public.production_public_read_capabilities_v1(p_client_contract_version,p_taxonomy_version);
 IF p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0 OR cardinality(p_owner_ids)>100
 THEN RAISE EXCEPTION 'W52LB_SHOP_ARGUMENTS'; END IF;
 RETURN QUERY SELECT s.* FROM public.shops s WHERE s.is_active AND (p_shop_id IS NULL OR s.id=p_shop_id)
 AND (p_owner_ids IS NULL OR s.owner_user_id=ANY(p_owner_ids)) ORDER BY s.name,s.id LIMIT p_limit OFFSET p_offset;
END $fn$;

DO $grants$ DECLARE f record; BEGIN
 FOR f IN SELECT oid::regprocedure AS signature FROM pg_proc WHERE pronamespace='public'::regnamespace
 AND proname=ANY(ARRAY['production_public_read_capabilities_v1','production_public_products_v1','production_public_listings_v1','production_public_shops_v1']) LOOP
 EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',f.signature);
 EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO anon,authenticated',f.signature);
 END LOOP;
END $grants$;
COMMIT;
