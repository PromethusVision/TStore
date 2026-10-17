-- Development-only candidate. Install only via the reviewed, source-bound wrapper.
-- No catalog rows, category activation, client grants or decisions switch here.
BEGIN;
DO $preflight$ BEGIN
 IF to_regclass('public.canonical_categories') IS NOT NULL
 OR (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false
 THEN RAISE EXCEPTION 'PUBLICATION_BASELINE_REQUIRED'; END IF;
END $preflight$;

CREATE TABLE public.catalog_publication_batches (
 id uuid PRIMARY KEY,
 plan_sha256 text NOT NULL UNIQUE CHECK(plan_sha256 ~ '^[0-9a-f]{64}$'),
 reviewed_items jsonb NOT NULL CHECK(jsonb_typeof(reviewed_items)='array' AND jsonb_array_length(reviewed_items) BETWEEN 1 AND 100),
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.catalog_publication_batches ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.catalog_publication_batches FROM PUBLIC,anon,authenticated,service_role;
CREATE FUNCTION public._catalog_publication_immutable_v1() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog AS $function$
BEGIN RAISE EXCEPTION 'PUBLICATION_RECEIPT_IMMUTABLE'; END $function$;
REVOKE ALL ON FUNCTION public._catalog_publication_immutable_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER catalog_publication_immutable BEFORE UPDATE OR DELETE ON public.catalog_publication_batches
 FOR EACH ROW EXECUTE FUNCTION public._catalog_publication_immutable_v1();

-- Zero is an explicitly tagged storage compatibility value, never a quote.
-- Preserve old rows; once tagged, a product cannot fall back to legacy semantics.
CREATE FUNCTION public._catalog_price_contract_guard_v1() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog AS $function$
BEGIN
 IF TG_OP='UPDATE' AND coalesce(OLD.attributes ? '_catalog_price_contract',false)
 AND NOT coalesce(NEW.attributes ? '_catalog_price_contract',false)
 THEN RAISE EXCEPTION 'CATALOG_PRICE_CONTRACT_IMMUTABLE'; END IF;
 IF coalesce(NEW.attributes ? '_catalog_price_contract',false) AND
 (NEW.attributes->>'_catalog_price_contract' IS DISTINCT FROM 'listing_only_v1'
 OR NEW.price IS DISTINCT FROM 0::numeric OR NEW.sale_price IS NOT NULL OR NEW.stock IS DISTINCT FROM 0)
 THEN RAISE EXCEPTION 'CATALOG_PRICE_CONTRACT_INVALID'; END IF;
 RETURN NEW;
END $function$;
REVOKE ALL ON FUNCTION public._catalog_price_contract_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER catalog_price_contract_guard BEFORE INSERT OR UPDATE ON public.products
 FOR EACH ROW EXECUTE FUNCTION public._catalog_price_contract_guard_v1();

-- Private operator helper, not an RPC capability. The bounded wrapper locks
-- the relevant tables and rechecks the reviewed schema/data before invoking it.
CREATE FUNCTION public._publish_catalog_submission_v1(
 p_submission uuid,p_product uuid,p_brand uuid,p_create boolean,p_review text
) RETURNS uuid LANGUAGE plpgsql SET search_path=pg_catalog,public AS $function$
DECLARE s public.product_submissions; p public.products; i public.product_identity;
 b public.brands; owner_id uuid; reason text;
BEGIN
 IF to_regclass('public.canonical_categories') IS NOT NULL
 OR (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false
 OR coalesce(current_setting('esnaftavar.catalog_batch_hash',true),'') !~ '^[0-9a-f]{64}$'
 THEN RAISE EXCEPTION 'PUBLICATION_NOT_REVIEWED'; END IF;
 IF p_product IS NULL OR p_create IS NULL OR p_review IS NULL OR p_review !~ '^[a-z][a-z0-9-]{2,60}$'
 THEN RAISE EXCEPTION 'PUBLICATION_ARGUMENTS'; END IF;
 SELECT * INTO STRICT s FROM public.product_submissions WHERE id=p_submission FOR UPDATE;
 IF s.status<>'pending' OR NOT public._catalog_category_allowed_v1(s.canonical_category_id)
 THEN RAISE EXCEPTION 'PUBLICATION_CANDIDATE_UNAVAILABLE'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.shops sh JOIN public.profiles u ON u.id=sh.owner_user_id
  JOIN auth.users au ON au.id=u.id WHERE sh.id=s.shop_id AND sh.is_active
  AND u.id=s.submitted_by AND u.role='merchant' AND au.email_confirmed_at IS NOT NULL
  AND au.email=u.email AND au.deleted_at IS NULL AND NOT coalesce(au.is_anonymous,false)
  AND (au.banned_until IS NULL OR au.banned_until<=now()))
 THEN RAISE EXCEPTION 'PUBLICATION_OWNER_UNAVAILABLE'; END IF;
 IF s.normalized_name IS DISTINCT FROM public.catalog_normalize_v1(s.name)
 OR s.normalized_brand IS DISTINCT FROM public.catalog_normalize_v1(s.brand)
 OR s.normalization_version<>1 OR s.gtin IS DISTINCT FROM public.catalog_gtin_v1(s.gtin)
 THEN RAISE EXCEPTION 'PUBLICATION_IDENTITY_INVALID'; END IF;
 IF s.gtin IS NOT NULL THEN
  PERFORM pg_advisory_xact_lock(hashtextextended('catalog-gtin:'||s.gtin,0));
  SELECT product_id INTO owner_id FROM public.product_identifiers WHERE gtin=s.gtin;
  IF owner_id IS NOT NULL AND owner_id<>p_product THEN RAISE EXCEPTION 'PUBLICATION_GTIN_CONFLICT'; END IF;
 END IF;
 IF p_create THEN
  IF EXISTS(SELECT 1 FROM public.products WHERE id=p_product) THEN RAISE EXCEPTION 'PUBLICATION_PRODUCT_EXISTS'; END IF;
  IF s.normalized_brand='' THEN
   IF p_brand IS NOT NULL THEN RAISE EXCEPTION 'PUBLICATION_BRAND_MISMATCH'; END IF;
  ELSE
   IF p_brand IS NULL THEN RAISE EXCEPTION 'PUBLICATION_BRAND_REQUIRED'; END IF;
   SELECT * INTO b FROM public.brands WHERE id=p_brand FOR UPDATE;
   IF FOUND THEN
    IF NOT b.is_active OR public.catalog_normalize_v1(b.name)<>s.normalized_brand
    THEN RAISE EXCEPTION 'PUBLICATION_BRAND_MISMATCH'; END IF;
   ELSE
    IF EXISTS(SELECT 1 FROM public.brands WHERE public.catalog_normalize_v1(name)=s.normalized_brand)
    THEN RAISE EXCEPTION 'PUBLICATION_BRAND_SELECTION_REQUIRED'; END IF;
    INSERT INTO public.brands(id,name) VALUES(p_brand,s.brand);
   END IF;
  END IF;
  -- Unbarcoded similarity is a review signal, never an automatic merge.
  IF EXISTS(SELECT 1 FROM public.product_identity x JOIN public.products q ON q.id=x.product_id
   WHERE x.normalized_name=s.normalized_name AND x.normalized_brand=s.normalized_brand
   AND x.model=s.model AND x.variant=s.variant AND q.category_id=s.canonical_category_id
   AND x.product_type=s.product_type AND x.origin_shop_id IS NOT DISTINCT FROM
    CASE WHEN s.product_type='merchant_unique_product' THEN s.shop_id END)
  THEN RAISE EXCEPTION 'PUBLICATION_EXISTING_SELECTION_REQUIRED'; END IF;
  INSERT INTO public.products(id,name,price,category_id,brand_id,stock,attributes)
   VALUES(p_product,s.name,0,s.canonical_category_id,p_brand,0,'{"_catalog_price_contract":"listing_only_v1"}');
  INSERT INTO public.product_identity(product_id,product_type,origin_shop_id,model,variant,normalized_name,normalized_brand)
   VALUES(p_product,s.product_type,CASE WHEN s.product_type='merchant_unique_product' THEN s.shop_id END,
    s.model,s.variant,s.normalized_name,s.normalized_brand);
 ELSE
  SELECT * INTO STRICT p FROM public.products WHERE id=p_product FOR UPDATE;
  SELECT * INTO STRICT i FROM public.product_identity WHERE product_id=p_product FOR UPDATE;
  IF NOT public._catalog_product_public_v1(p_product) OR p.category_id<>s.canonical_category_id
  OR p.brand_id IS DISTINCT FROM p_brand OR i.product_type<>s.product_type
  OR i.origin_shop_id IS DISTINCT FROM (CASE WHEN s.product_type='merchant_unique_product' THEN s.shop_id END)
  OR i.model<>s.model OR i.variant<>s.variant OR i.normalized_name<>s.normalized_name OR i.normalized_brand<>s.normalized_brand
  OR public.catalog_normalize_v1(p.name)<>s.normalized_name
  OR public.catalog_normalize_v1((SELECT name FROM public.brands WHERE id=p.brand_id))<>s.normalized_brand
  OR (p.brand_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.brands WHERE id=p.brand_id AND is_active))
  THEN RAISE EXCEPTION 'PUBLICATION_EXISTING_IDENTITY_MISMATCH'; END IF;
 END IF;
 IF s.gtin IS NOT NULL THEN
  INSERT INTO public.product_identifiers(gtin,product_id) VALUES(s.gtin,p_product) ON CONFLICT(gtin) DO NOTHING;
 END IF;
 reason:='pilot-publication:'||current_setting('esnaftavar.catalog_batch_hash')||':'||p_review;
 INSERT INTO public.product_submission_decisions(submission_id,actor_role,status,product_id,reason)
  VALUES(s.id,'postgres:reviewed-pilot-operator','approved',p_product,reason);
 UPDATE public.product_submissions SET status='approved',approved_product_id=p_product,
  decision_reason=reason,decided_at=now() WHERE id=s.id;
 RETURN p_product;
END $function$;
REVOKE ALL ON FUNCTION public._publish_catalog_submission_v1(uuid,uuid,uuid,boolean,text) FROM PUBLIC,anon,authenticated,service_role;
COMMIT;
