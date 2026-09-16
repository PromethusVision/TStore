ALTER TABLE public.production_taxonomy_config
 ADD COLUMN public_enabled BOOLEAN NOT NULL DEFAULT false;
CREATE TABLE public.product_canonical_assignments (
 product_id UUID PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
 legacy_category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
 canonical_category_id UUID NOT NULL REFERENCES public.canonical_categories(id) ON DELETE RESTRICT,
 canonical_path TEXT NOT NULL CHECK(length(btrim(canonical_path))>0),
 owner_mapping_sha256 TEXT NOT NULL CHECK(owner_mapping_sha256 ~ '^[a-f0-9]{64}$'),
 owner_approved BOOLEAN NOT NULL DEFAULT true CHECK(owner_approved),
 created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.product_canonical_assignments ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.product_canonical_assignments FROM PUBLIC,anon,authenticated,service_role;
CREATE FUNCTION public._w52h_validate_product_assignment()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path=pg_catalog,public AS $fn$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.products WHERE id=NEW.product_id AND category_id=NEW.legacy_category_id)
 THEN RAISE EXCEPTION 'W52H_PRODUCT_LEGACY_REFERENCE_MISMATCH'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.canonical_categories WHERE id=NEW.canonical_category_id AND taxonomy_version='canonical-v1.0.0')
 OR EXISTS(SELECT 1 FROM public.canonical_categories WHERE parent_id=NEW.canonical_category_id)
 THEN RAISE EXCEPTION 'W52H_ASSIGNMENT_TARGET_NOT_CANONICAL_TERMINAL'; END IF;
 RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION public._w52h_validate_product_assignment() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER w52h_product_assignment_guard BEFORE INSERT OR UPDATE ON public.product_canonical_assignments
 FOR EACH ROW EXECUTE FUNCTION public._w52h_validate_product_assignment();

-- Closed publication gate and complete eligible ancestry, not just a leaf flag.
CREATE OR REPLACE FUNCTION public._production_taxonomy_visible_v1(
 p_category_id UUID,p_taxonomy_version TEXT,p_preview BOOLEAN
) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 WITH RECURSIVE ancestors AS (
  SELECT id,parent_id,is_active,lifecycle_state,taxonomy_version FROM public.canonical_categories WHERE id=p_category_id
  UNION ALL
  SELECT c.id,c.parent_id,c.is_active,c.lifecycle_state,c.taxonomy_version
  FROM public.canonical_categories c JOIN ancestors a ON c.id=a.parent_id
 ) SELECT p_preview=false
 AND coalesce((SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1),false)
 AND EXISTS(SELECT 1 FROM ancestors)
 AND NOT EXISTS(
  SELECT 1 FROM ancestors a LEFT JOIN public.canonical_category_qualification q ON q.category_id=a.id
  WHERE NOT a.is_active OR a.lifecycle_state<>'active' OR a.taxonomy_version<>p_taxonomy_version
   OR q.category_id IS NULL OR q.policy_gate<>'PASS' OR q.professional_gate<>'PASS'
 )
$fn$;

-- SQL invoker preserves product RLS. Only the mapping relation has a narrow
-- public read policy; base table product/category semantics do not change.
CREATE FUNCTION public.production_taxonomy_assignment_visible_v1(p_category_id UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 SELECT public._production_taxonomy_visible_v1(p_category_id,'canonical-v1.0.0',false)
 AND EXISTS(SELECT 1 FROM public.canonical_categories c
  JOIN public.canonical_category_qualification q ON q.category_id=c.id
  WHERE c.id=p_category_id AND c.is_assignable
   AND q.qualification='LEAF_ASSIGNABLE_CANDIDATE'
   AND NOT EXISTS(SELECT 1 FROM public.canonical_categories child WHERE child.parent_id=c.id))
$fn$;
GRANT SELECT ON public.product_canonical_assignments TO anon,authenticated;
CREATE POLICY w52h_visible_product_assignments ON public.product_canonical_assignments
 FOR SELECT TO anon,authenticated USING (
  public.production_taxonomy_assignment_visible_v1(canonical_category_id)
  AND EXISTS(SELECT 1 FROM public.products p WHERE p.id=product_id AND p.is_active)
 );

CREATE FUNCTION public.production_taxonomy_runtime_v1()
RETURNS JSONB LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 SELECT jsonb_build_object('client_contract','production-taxonomy-client-v1',
  'taxonomy_version','canonical-v1.0.0','rpc_contract','production-taxonomy-rpc-v1',
  'public_enabled',public_enabled,'preview_enabled',false,
  'product_scope_rpc','production_taxonomy_products_v1','legacy_fallback_supported',true)
 FROM public.production_taxonomy_config WHERE singleton_id=1
$fn$;

CREATE FUNCTION public.production_taxonomy_products_v1(
 p_category_id UUID,p_client_contract_version TEXT,p_taxonomy_version TEXT,
 p_limit INTEGER DEFAULT 20,p_offset INTEGER DEFAULT 0
) RETURNS TABLE(product_id UUID,canonical_category_id UUID,canonical_path TEXT,product JSONB)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM * FROM public.production_taxonomy_capabilities_v1(p_client_contract_version,p_taxonomy_version);
 IF p_category_id IS NULL OR p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0
 THEN RAISE EXCEPTION 'W52H_PRODUCT_SCOPE_ARGUMENTS'; END IF;
 RETURN QUERY
 SELECT p.id,a.canonical_category_id,a.canonical_path,
  to_jsonb(p) || jsonb_build_object('category_id',a.canonical_category_id,
   'legacy_category_id',p.category_id,'categories',jsonb_build_object('name',n.name))
 FROM public.products p JOIN public.product_canonical_assignments a ON a.product_id=p.id
 JOIN public.production_taxonomy_descendants_v1(p_category_id,p_client_contract_version,p_taxonomy_version,false) n
  ON n.id=a.canonical_category_id
 WHERE p.is_active AND n.is_assignable AND NOT n.has_children
 ORDER BY p.created_at,p.id LIMIT p_limit OFFSET p_offset;
END $fn$;

-- Default EXECUTE belongs to PUBLIC in PostgreSQL; close helpers explicitly.
DO $grants$
DECLARE f RECORD;
BEGIN
 FOR f IN SELECT oid::regprocedure AS signature,proname FROM pg_proc
  WHERE pronamespace='public'::regnamespace AND
  (proname LIKE 'production_taxonomy_%_v1' OR proname LIKE '\_production_taxonomy_%_v1')
 LOOP
  EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',f.signature);
  IF f.proname LIKE 'production_taxonomy_%_v1' THEN
   EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO anon,authenticated',f.signature);
  END IF;
 END LOOP;
END $grants$;
REVOKE ALL ON public.taxonomy_id_allocations,public.taxonomy_aliases,public.taxonomy_alias_targets,
 public.taxonomy_node_relationships,public.taxonomy_import_runs FROM PUBLIC,anon,authenticated;
