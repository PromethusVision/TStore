-- Slice A only. Candidate for local rehearsal and later reviewed deployment.
-- Does not activate taxonomy, create central prices, or install an Admin UI.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
 IF to_regclass('public.profiles') IS NULL OR to_regclass('public.products') IS NULL
 OR to_regclass('public.shops') IS NULL OR to_regclass('public.shop_products') IS NULL
 OR to_regclass('storage.buckets') IS NULL OR to_regclass('storage.objects') IS NULL
 THEN RAISE EXCEPTION 'CATALOG_MEDIA_BASELINE_REQUIRED'; END IF;
 IF (to_regclass('public.canonical_categories') IS NOT NULL AND to_regprocedure('public.production_taxonomy_assignment_visible_v1(uuid)') IS NULL)
 OR (to_regclass('public.canonical_categories') IS NULL AND to_regprocedure('public.taxonomy_exact_leaf_v2(uuid,text,text,boolean)') IS NULL)
 THEN RAISE EXCEPTION 'CATALOG_MEDIA_TAXONOMY_CONTRACT_REQUIRED'; END IF;
END $preflight$;

CREATE TABLE public.catalog_media_config (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 max_listing_photos integer NOT NULL DEFAULT 6 CHECK(max_listing_photos BETWEEN 1 AND 12),
 max_photo_bytes integer NOT NULL DEFAULT 8388608 CHECK(max_photo_bytes BETWEEN 1 AND 8388608),
 decisions_enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.catalog_media_config DEFAULT VALUES;
ALTER TABLE public.catalog_media_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.catalog_media_config FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.catalog_normalize_v1(p_text text) RETURNS text
LANGUAGE sql IMMUTABLE SET search_path=pg_catalog AS $function$
 SELECT btrim(regexp_replace(lower(translate(coalesce(p_text,''),'İI','ii')), '[[:space:]]+', ' ', 'g'))
$function$;
CREATE FUNCTION public.catalog_gtin_v1(p_text text) RETURNS text
LANGUAGE plpgsql IMMUTABLE SET search_path=pg_catalog AS $function$
DECLARE s text:=btrim(p_text); total integer:=0; i integer;
BEGIN
 IF s IS NULL OR s='' THEN RETURN NULL; END IF;
 IF s !~ '^[0-9]+$' OR s ~ '^0+$' OR length(s) NOT IN (8,12,13,14) THEN
  RAISE EXCEPTION 'CATALOG_INVALID_GTIN' USING ERRCODE='22023';
 END IF;
 FOR i IN 1..length(s)-1 LOOP
  total:=total+substring(s,i,1)::integer*CASE WHEN (length(s)-i)%2=1 THEN 3 ELSE 1 END;
 END LOOP;
 IF (10-total%10)%10<>right(s,1)::integer THEN
  RAISE EXCEPTION 'CATALOG_INVALID_GTIN' USING ERRCODE='22023';
 END IF;
 RETURN lpad(s,14,'0');
END $function$;

CREATE TABLE public.product_identity (
 product_id uuid PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
 product_type text NOT NULL CHECK(product_type IN ('shared_catalog_product','merchant_unique_product')),
 origin_shop_id uuid REFERENCES public.shops(id) ON DELETE RESTRICT,
 model text NOT NULL DEFAULT '' CHECK(length(model)<=120),
 variant text NOT NULL DEFAULT '' CHECK(length(variant)<=120),
 normalized_name text NOT NULL,
 normalized_brand text NOT NULL DEFAULT '',
 normalization_version integer NOT NULL DEFAULT 1 CHECK(normalization_version=1),
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK((product_type='shared_catalog_product' AND origin_shop_id IS NULL)
  OR (product_type='merchant_unique_product' AND origin_shop_id IS NOT NULL))
);
INSERT INTO public.product_identity(product_id,product_type,normalized_name,normalized_brand)
 SELECT p.id,'shared_catalog_product',public.catalog_normalize_v1(p.name),public.catalog_normalize_v1(b.name)
 FROM public.products p LEFT JOIN public.brands b ON b.id=p.brand_id;
CREATE TABLE public.product_identifiers (
 gtin text PRIMARY KEY CHECK(gtin=public.catalog_gtin_v1(gtin)),
 product_id uuid NOT NULL REFERENCES public.product_identity(product_id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX product_identifiers_product ON public.product_identifiers(product_id);
CREATE TABLE public.product_submissions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
 submitted_by uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
 request_id uuid NOT NULL,
 name text NOT NULL CHECK(length(btrim(name)) BETWEEN 1 AND 200),
 brand text NOT NULL DEFAULT '' CHECK(length(brand)<=120),
 model text NOT NULL DEFAULT '' CHECK(length(model)<=120),
 variant text NOT NULL DEFAULT '' CHECK(length(variant)<=120),
 normalized_name text NOT NULL,
 normalized_brand text NOT NULL,
 normalization_version integer NOT NULL DEFAULT 1 CHECK(normalization_version=1),
 gtin text CHECK(gtin=public.catalog_gtin_v1(gtin)),
 canonical_category_id uuid NOT NULL,
 product_type text NOT NULL CHECK(product_type IN ('shared_catalog_product','merchant_unique_product')),
 status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','rejected')),
 approved_product_id uuid REFERENCES public.products(id) ON DELETE RESTRICT,
 decision_reason text,
 created_at timestamptz NOT NULL DEFAULT now(),
 decided_at timestamptz,
 UNIQUE(shop_id,request_id),
 CHECK((status='pending' AND approved_product_id IS NULL AND decided_at IS NULL)
  OR (status='approved' AND approved_product_id IS NOT NULL AND decided_at IS NOT NULL)
  OR (status='rejected' AND approved_product_id IS NULL AND decided_at IS NOT NULL))
);
CREATE INDEX product_submissions_shop ON public.product_submissions(shop_id,created_at DESC,id);
CREATE TABLE public.product_submission_decisions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 submission_id uuid NOT NULL UNIQUE REFERENCES public.product_submissions(id) ON DELETE RESTRICT,
 actor_role text NOT NULL,
 status text NOT NULL CHECK(status IN ('approved','rejected')),
 product_id uuid REFERENCES public.products(id) ON DELETE RESTRICT,
 reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 1000),
 created_at timestamptz NOT NULL DEFAULT now()
);

-- Production uses the unchanged qualified ancestry gate. Development uses
-- the existing v2 leaf contract; neither branch enables publication itself.
CREATE FUNCTION public._catalog_category_allowed_v1(p_id uuid) RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE allowed boolean;
BEGIN
 IF to_regclass('public.canonical_categories') IS NOT NULL THEN
  EXECUTE 'SELECT public.production_taxonomy_assignment_visible_v1($1)' INTO allowed USING p_id;
 ELSE
  WITH RECURSIVE ancestors AS (
   SELECT * FROM public.categories WHERE id=p_id
   UNION ALL SELECT c.* FROM public.categories c JOIN ancestors a ON c.id=a.parent_id
  ) SELECT EXISTS(SELECT 1 FROM ancestors WHERE id=p_id AND is_assignable)
   AND NOT EXISTS(SELECT 1 FROM public.categories WHERE parent_id=p_id)
   AND NOT EXISTS(SELECT 1 FROM ancestors WHERE is_active IS DISTINCT FROM true OR lifecycle_state IS DISTINCT FROM 'active'
    OR taxonomy_version IS DISTINCT FROM 'canonical-v1.0.0' OR policy_class IS NULL OR policy_class='EXCLUDED'
    OR professional_review_status IS NULL OR professional_review_status IN ('pending','rejected')) INTO allowed;
 END IF;
 RETURN coalesce(allowed,false);
END $function$;
CREATE FUNCTION public._catalog_product_public_v1(p_id uuid) RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE allowed boolean;
BEGIN
 IF to_regclass('public.canonical_categories') IS NOT NULL THEN
  EXECUTE 'SELECT EXISTS(SELECT 1 FROM public.products p JOIN public.product_canonical_assignments a
   ON a.product_id=p.id WHERE p.id=$1 AND p.is_active
   AND public._catalog_category_allowed_v1(a.canonical_category_id))' INTO allowed USING p_id;
 ELSE
  SELECT EXISTS(SELECT 1 FROM public.products p WHERE p.id=p_id AND p.is_active
   AND public._catalog_category_allowed_v1(p.category_id)) INTO allowed;
 END IF;
 RETURN coalesce(allowed,false);
END $function$;
CREATE FUNCTION public._catalog_own_shop_v1(p_id uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
 SELECT auth.role()='authenticated' AND auth.uid() IS NOT NULL AND EXISTS(SELECT 1 FROM public.shops s
 JOIN public.profiles p ON p.id=s.owner_user_id WHERE s.id=p_id AND s.owner_user_id=auth.uid()
 AND s.is_active AND p.role='merchant')
$function$;
CREATE FUNCTION public.merchant_catalog_categories_v1(p_shop_id uuid)
RETURNS TABLE(id uuid,name text) LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
BEGIN
 IF NOT public._catalog_own_shop_v1(p_shop_id) THEN RAISE EXCEPTION 'CATALOG_FORBIDDEN' USING ERRCODE='42501'; END IF;
 IF to_regclass('public.canonical_categories') IS NOT NULL THEN
  RETURN QUERY EXECUTE 'WITH RECURSIVE paths AS (SELECT c.id,c.name AS label FROM public.canonical_categories c WHERE parent_id IS NULL
   UNION ALL SELECT c.id,p.label||'' > ''||c.name FROM public.canonical_categories c JOIN paths p ON c.parent_id=p.id)
   SELECT p.id,p.label FROM paths p WHERE public._catalog_category_allowed_v1(p.id) ORDER BY p.label,p.id';
 ELSE
  RETURN QUERY WITH RECURSIVE paths AS (SELECT c.id,c.name AS label FROM public.categories c WHERE parent_id IS NULL
   UNION ALL SELECT c.id,p.label||' > '||c.name FROM public.categories c JOIN paths p ON c.parent_id=p.id)
   SELECT p.id,p.label FROM paths p WHERE public._catalog_category_allowed_v1(p.id) ORDER BY p.label,p.id;
 END IF;
END $function$;
CREATE FUNCTION public.merchant_catalog_lookup_v1(p_shop_id uuid,p_name text DEFAULT '',p_gtin text DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE g text:=public.catalog_gtin_v1(p_gtin); exact_product uuid; matches jsonb;
BEGIN
 IF NOT public._catalog_own_shop_v1(p_shop_id) THEN RAISE EXCEPTION 'CATALOG_FORBIDDEN' USING ERRCODE='42501'; END IF;
 IF length(p_name)>200 THEN RAISE EXCEPTION 'CATALOG_ARGUMENTS'; END IF;
 SELECT i.product_id INTO exact_product FROM public.product_identifiers i JOIN public.product_identity d USING(product_id)
 WHERE i.gtin=g AND public._catalog_product_public_v1(i.product_id)
 AND (d.origin_shop_id IS NULL OR d.origin_shop_id=p_shop_id);
 SELECT coalesce(jsonb_agg(x.payload),'[]'::jsonb) INTO matches FROM (
  SELECT to_jsonb(p)||jsonb_build_object('brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) payload
  FROM public.products p LEFT JOIN public.brands b ON b.id=p.brand_id LEFT JOIN public.product_identity d ON d.product_id=p.id
  WHERE public._catalog_product_public_v1(p.id) AND (d.origin_shop_id IS NULL OR d.origin_shop_id=p_shop_id)
  AND ((exact_product IS NOT NULL AND p.id=exact_product) OR (exact_product IS NULL AND length(btrim(p_name))>=2
   AND position(public.catalog_normalize_v1(p_name) IN public.catalog_normalize_v1(p.name))>0))
  ORDER BY p.name,p.id LIMIT 10
 ) x;
 RETURN jsonb_build_object('exact',exact_product IS NOT NULL,'products',matches);
END $function$;
CREATE FUNCTION public.merchant_catalog_search_v1(p_shop_id uuid,p_query text DEFAULT '',p_limit integer DEFAULT 30,p_offset integer DEFAULT 0)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
BEGIN
 IF NOT public._catalog_own_shop_v1(p_shop_id) THEN RAISE EXCEPTION 'CATALOG_FORBIDDEN' USING ERRCODE='42501'; END IF;
 IF p_query IS NULL OR length(p_query)>100 OR p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0
 THEN RAISE EXCEPTION 'CATALOG_ARGUMENTS' USING ERRCODE='22023'; END IF;
 RETURN coalesce((SELECT jsonb_agg(x.payload ORDER BY x.name,x.id) FROM (
  SELECT p.id,p.name,to_jsonb(p)||jsonb_build_object('brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) payload
  FROM public.products p LEFT JOIN public.brands b ON b.id=p.brand_id LEFT JOIN public.product_identity i ON i.product_id=p.id
  WHERE public._catalog_product_public_v1(p.id) AND (i.origin_shop_id IS NULL OR i.origin_shop_id=p_shop_id)
   AND (btrim(p_query)='' OR position(public.catalog_normalize_v1(p_query) IN public.catalog_normalize_v1(p.name))>0)
  ORDER BY p.name,p.id LIMIT p_limit OFFSET p_offset
 ) x),'[]'::jsonb);
END $function$;
CREATE FUNCTION public.merchant_submit_product_v1(p_shop_id uuid,p_request_id uuid,p_draft jsonb)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE g text:=public.catalog_gtin_v1(p_draft->>'gtin'); existing public.product_submissions; lookup jsonb; result public.product_submissions;
BEGIN
 IF NOT public._catalog_own_shop_v1(p_shop_id) THEN RAISE EXCEPTION 'CATALOG_FORBIDDEN' USING ERRCODE='42501'; END IF;
 IF p_request_id IS NULL OR p_draft IS NULL OR NOT public._catalog_category_allowed_v1((p_draft->>'canonical_category_id')::uuid)
 THEN RAISE EXCEPTION 'CATALOG_CATEGORY_UNAVAILABLE' USING ERRCODE='22023'; END IF;
 -- Per-shop idempotency and global GTIN serialize with the decision seam.
 PERFORM pg_advisory_xact_lock(hashtextextended(p_shop_id::text||p_request_id::text,0));
 IF g IS NOT NULL THEN PERFORM pg_advisory_xact_lock(hashtextextended('catalog-gtin:'||g,0)); END IF;
 SELECT * INTO existing FROM public.product_submissions WHERE shop_id=p_shop_id AND request_id=p_request_id;
 IF FOUND THEN
  IF existing.name IS DISTINCT FROM btrim(p_draft->>'name') OR existing.brand IS DISTINCT FROM btrim(coalesce(p_draft->>'brand',''))
   OR existing.model IS DISTINCT FROM btrim(coalesce(p_draft->>'model','')) OR existing.variant IS DISTINCT FROM btrim(coalesce(p_draft->>'variant',''))
   OR existing.gtin IS DISTINCT FROM g OR existing.canonical_category_id IS DISTINCT FROM (p_draft->>'canonical_category_id')::uuid
   OR existing.product_type IS DISTINCT FROM p_draft->>'product_type' THEN RAISE EXCEPTION 'CATALOG_REQUEST_REUSED'; END IF;
  RETURN jsonb_build_object('submission',to_jsonb(existing));
 END IF;
 lookup:=public.merchant_catalog_lookup_v1(p_shop_id,p_draft->>'name',g);
 IF (lookup->>'exact')::boolean THEN RETURN jsonb_build_object('existing',lookup->'products'->0); END IF;
 INSERT INTO public.product_submissions(shop_id,submitted_by,request_id,name,brand,model,variant,normalized_name,normalized_brand,gtin,canonical_category_id,product_type)
 VALUES(p_shop_id,auth.uid(),p_request_id,btrim(p_draft->>'name'),btrim(coalesce(p_draft->>'brand','')),btrim(coalesce(p_draft->>'model','')),
 btrim(coalesce(p_draft->>'variant','')),public.catalog_normalize_v1(p_draft->>'name'),public.catalog_normalize_v1(p_draft->>'brand'),g,
 (p_draft->>'canonical_category_id')::uuid,p_draft->>'product_type') RETURNING * INTO result;
 RETURN jsonb_build_object('submission',to_jsonb(result));
END $function$;
-- Disabled operator seam. Approves an ALREADY legitimately materialized product;
-- never synthesizes the legacy NOT NULL price. Later Admin slice owns activation.
CREATE FUNCTION public.decide_catalog_submission_v1(p_submission_id uuid,p_status text,p_product_id uuid,p_reason text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE s public.product_submissions; identity public.product_identity; g_owner uuid; assigned uuid;
BEGIN
 IF auth.role() IS DISTINCT FROM 'service_role' OR NOT (SELECT decisions_enabled FROM public.catalog_media_config)
 THEN RAISE EXCEPTION 'CATALOG_DECISIONS_DISABLED' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT s FROM public.product_submissions WHERE id=p_submission_id FOR UPDATE;
 IF s.status<>'pending' OR p_status IS NULL OR p_status NOT IN ('approved','rejected') OR length(btrim(p_reason)) NOT BETWEEN 1 AND 1000 OR p_reason IS NULL
 THEN RAISE EXCEPTION 'CATALOG_DECISION_ARGUMENTS'; END IF;
 IF s.gtin IS NOT NULL THEN PERFORM pg_advisory_xact_lock(hashtextextended('catalog-gtin:'||s.gtin,0)); END IF;
 IF p_status='approved' THEN
  -- Serialize different GTIN decisions targeting one existing identity too.
  PERFORM 1 FROM public.products WHERE id=p_product_id FOR UPDATE;
  IF NOT public._catalog_product_public_v1(p_product_id) OR NOT public._catalog_category_allowed_v1(s.canonical_category_id)
  THEN RAISE EXCEPTION 'CATALOG_APPROVAL_UNAVAILABLE'; END IF;
  IF to_regclass('public.canonical_categories') IS NOT NULL THEN
   EXECUTE 'SELECT canonical_category_id FROM public.product_canonical_assignments WHERE product_id=$1' INTO assigned USING p_product_id;
  ELSE SELECT category_id INTO assigned FROM public.products WHERE id=p_product_id; END IF;
  IF assigned IS DISTINCT FROM s.canonical_category_id THEN RAISE EXCEPTION 'CATALOG_CATEGORY_MISMATCH'; END IF;
  SELECT * INTO identity FROM public.product_identity WHERE product_id=p_product_id FOR UPDATE;
  IF FOUND AND (identity.product_type<>s.product_type OR identity.origin_shop_id IS DISTINCT FROM
    CASE WHEN s.product_type='merchant_unique_product' THEN s.shop_id ELSE NULL END
    OR identity.model<>s.model OR identity.variant<>s.variant OR identity.normalized_name<>s.normalized_name
    OR identity.normalized_brand<>s.normalized_brand) THEN RAISE EXCEPTION 'CATALOG_IDENTITY_MISMATCH'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.products p LEFT JOIN public.brands b ON b.id=p.brand_id WHERE p.id=p_product_id
   AND public.catalog_normalize_v1(p.name)=s.normalized_name AND public.catalog_normalize_v1(b.name)=s.normalized_brand)
  THEN RAISE EXCEPTION 'CATALOG_IDENTITY_MISMATCH'; END IF;
  INSERT INTO public.product_identity(product_id,product_type,origin_shop_id,model,variant,normalized_name,normalized_brand)
  VALUES(p_product_id,s.product_type,CASE WHEN s.product_type='merchant_unique_product' THEN s.shop_id END,s.model,s.variant,s.normalized_name,s.normalized_brand)
  ON CONFLICT(product_id) DO NOTHING;
  IF s.gtin IS NOT NULL THEN
   SELECT product_id INTO g_owner FROM public.product_identifiers WHERE gtin=s.gtin;
   IF g_owner IS NOT NULL AND g_owner<>p_product_id THEN RAISE EXCEPTION 'CATALOG_GTIN_ALREADY_ASSIGNED' USING ERRCODE='23505'; END IF;
   INSERT INTO public.product_identifiers(gtin,product_id) VALUES(s.gtin,p_product_id) ON CONFLICT(gtin) DO NOTHING;
  END IF;
 ELSIF p_product_id IS NOT NULL THEN RAISE EXCEPTION 'CATALOG_REJECTION_PRODUCT'; END IF;
 INSERT INTO public.product_submission_decisions(submission_id,actor_role,status,product_id,reason)
 VALUES(s.id,auth.role(),p_status,p_product_id,btrim(p_reason));
 UPDATE public.product_submissions SET status=p_status,approved_product_id=p_product_id,decision_reason=btrim(p_reason),decided_at=now() WHERE id=s.id;
END $function$;

-- Public product-images cannot keep draft/retired bytes private. Reuse its
-- controlled path/MIME conventions in a dedicated private bucket instead.
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 VALUES('listing-media','listing-media',false,8388608,ARRAY['image/jpeg','image/png','image/webp']);
CREATE TABLE public.listing_images (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 listing_id uuid NOT NULL REFERENCES public.shop_products(id) ON DELETE RESTRICT,
 bucket_id text NOT NULL DEFAULT 'listing-media' CHECK(bucket_id='listing-media'),
 object_path text NOT NULL UNIQUE,
 mime_type text NOT NULL CHECK(mime_type IN ('image/jpeg','image/png','image/webp')),
 byte_size integer NOT NULL CHECK(byte_size BETWEEN 1 AND 8388608),
 sort_order integer NOT NULL CHECK(sort_order>=0),
 is_primary boolean NOT NULL DEFAULT false,
 publication_state text NOT NULL DEFAULT 'pending' CHECK(publication_state IN ('pending','published','retired')),
 uploaded_by uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(),
 published_at timestamptz,
 CHECK((publication_state='published' AND published_at IS NOT NULL)
  OR (publication_state='pending' AND published_at IS NULL) OR publication_state='retired'),
 CHECK(NOT is_primary OR publication_state='published')
);
CREATE UNIQUE INDEX listing_images_one_primary ON public.listing_images(listing_id) WHERE is_primary AND publication_state='published';
CREATE INDEX listing_images_order ON public.listing_images(listing_id,sort_order,id);
CREATE FUNCTION public._catalog_photo_metadata_v1(p_metadata jsonb,p_mime text,p_bytes integer) RETURNS boolean
LANGUAGE sql IMMUTABLE SET search_path=pg_catalog AS $function$
 SELECT coalesce(p_metadata->>'mimetype'=p_mime AND CASE
  WHEN p_metadata->>'size' ~ '^[0-9]{1,8}$' THEN (p_metadata->>'size')::integer=p_bytes ELSE false END,false)
$function$;
CREATE FUNCTION public._listing_public_v1(p_id uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
 SELECT EXISTS(SELECT 1 FROM public.shop_products sp JOIN public.shops s ON s.id=sp.shop_id
 WHERE sp.id=p_id AND sp.is_active AND sp.is_available AND s.is_active AND public._catalog_product_public_v1(sp.product_id))
$function$;
CREATE FUNCTION public._listing_own_v1(p_id uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
 SELECT EXISTS(SELECT 1 FROM public.shop_products sp WHERE sp.id=p_id AND public._catalog_own_shop_v1(sp.shop_id))
$function$;
CREATE FUNCTION public.merchant_listing_media_v1(p_listing_id uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
BEGIN
 IF NOT public._listing_own_v1(p_listing_id) THEN RAISE EXCEPTION 'MEDIA_FORBIDDEN' USING ERRCODE='42501'; END IF;
 RETURN jsonb_build_object('max_photos',(SELECT max_listing_photos FROM public.catalog_media_config),
 'max_bytes',(SELECT max_photo_bytes FROM public.catalog_media_config),'images',coalesce((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.sort_order,i.id)
 FROM public.listing_images i WHERE i.listing_id=p_listing_id AND i.publication_state<>'retired'),'[]'::jsonb));
END $function$;
CREATE FUNCTION public.merchant_prepare_listing_image_v1(p_listing_id uuid,p_mime text,p_bytes integer) RETURNS public.listing_images
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE sp public.shop_products; cap public.catalog_media_config; result public.listing_images; image_id uuid:=gen_random_uuid(); ext text;
BEGIN
 SELECT * INTO STRICT sp FROM public.shop_products WHERE id=p_listing_id FOR UPDATE;
 IF NOT public._listing_own_v1(sp.id) THEN RAISE EXCEPTION 'MEDIA_FORBIDDEN' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT cap FROM public.catalog_media_config;
 IF p_mime IS NULL OR p_mime NOT IN ('image/jpeg','image/png','image/webp') OR p_bytes IS NULL OR p_bytes<1 OR p_bytes>cap.max_photo_bytes
 THEN RAISE EXCEPTION 'MEDIA_INVALID_FILE' USING ERRCODE='22023'; END IF;
 IF (SELECT count(*) FROM public.listing_images WHERE listing_id=sp.id AND publication_state<>'retired')>=cap.max_listing_photos
 THEN RAISE EXCEPTION 'MEDIA_LIMIT' USING ERRCODE='22023'; END IF;
 ext:=CASE p_mime WHEN 'image/jpeg' THEN 'jpg' WHEN 'image/png' THEN 'png' ELSE 'webp' END;
 INSERT INTO public.listing_images(id,listing_id,object_path,mime_type,byte_size,sort_order,uploaded_by)
 VALUES(image_id,sp.id,'shops/'||sp.shop_id||'/'||sp.id||'/v'||to_char(clock_timestamp() AT TIME ZONE 'UTC','YYYYMMDDHH24MISS')||'/'||image_id||'.'||ext,
 p_mime,p_bytes,coalesce((SELECT max(sort_order)+1 FROM public.listing_images WHERE listing_id=sp.id),0),auth.uid()) RETURNING * INTO result;
 RETURN result;
END $function$;
CREATE FUNCTION public.merchant_change_listing_images_v1(p_listing_id uuid,p_action text,p_image_id uuid DEFAULT NULL,p_order uuid[] DEFAULT NULL) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
DECLARE image public.listing_images; count_live integer;
BEGIN
 PERFORM 1 FROM public.shop_products WHERE id=p_listing_id FOR UPDATE;
 IF NOT public._listing_own_v1(p_listing_id) THEN RAISE EXCEPTION 'MEDIA_FORBIDDEN' USING ERRCODE='42501'; END IF;
 IF p_action='reorder' THEN
  SELECT count(*) INTO count_live FROM public.listing_images WHERE listing_id=p_listing_id AND publication_state<>'retired';
  IF p_order IS NULL OR cardinality(p_order)<>count_live OR (SELECT count(DISTINCT x) FROM unnest(p_order) x)<>count_live
   OR EXISTS(SELECT 1 FROM unnest(p_order) x WHERE NOT EXISTS(SELECT 1 FROM public.listing_images i WHERE i.id=x AND i.listing_id=p_listing_id AND i.publication_state<>'retired'))
  THEN RAISE EXCEPTION 'MEDIA_INVALID_ORDER'; END IF;
  UPDATE public.listing_images i SET sort_order=a.ordinality::integer-1,updated_at=now()
   FROM unnest(p_order) WITH ORDINALITY a(id,ordinality) WHERE i.id=a.id;
  RETURN;
 END IF;
 SELECT * INTO STRICT image FROM public.listing_images WHERE id=p_image_id AND listing_id=p_listing_id FOR UPDATE;
 IF p_action='publish' AND NOT EXISTS(SELECT 1 FROM public.shop_products sp WHERE sp.id=p_listing_id AND public._catalog_product_public_v1(sp.product_id))
 THEN RAISE EXCEPTION 'MEDIA_PRODUCT_UNAVAILABLE' USING ERRCODE='22023'; END IF;
 IF p_action='retire' THEN
  UPDATE public.listing_images SET publication_state='retired',is_primary=false,updated_at=now() WHERE id=image.id;
 ELSIF p_action IN ('publish','primary') AND image.publication_state<>'retired' THEN
  IF p_action='primary' AND image.publication_state<>'published' THEN RAISE EXCEPTION 'MEDIA_NOT_PUBLISHED'; END IF;
  IF NOT EXISTS(SELECT 1 FROM storage.objects o WHERE o.bucket_id=image.bucket_id AND o.name=image.object_path
   AND public._catalog_photo_metadata_v1(o.metadata,image.mime_type,image.byte_size))
  THEN RAISE EXCEPTION 'MEDIA_UPLOAD_INCOMPLETE'; END IF;
  IF p_action='primary' OR NOT EXISTS(SELECT 1 FROM public.listing_images WHERE listing_id=p_listing_id AND is_primary AND publication_state='published') THEN
   UPDATE public.listing_images SET is_primary=false,updated_at=now() WHERE listing_id=p_listing_id AND is_primary;
   UPDATE public.listing_images SET publication_state='published',is_primary=true,updated_at=now(),published_at=coalesce(published_at,now()) WHERE id=image.id;
  ELSE UPDATE public.listing_images SET publication_state='published',updated_at=now(),published_at=coalesce(published_at,now()) WHERE id=image.id; END IF;
 ELSE RAISE EXCEPTION 'MEDIA_INVALID_ACTION'; END IF;
END $function$;
CREATE FUNCTION public.catalog_listing_media_read_v1(p_listing_ids uuid[]) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
BEGIN
 IF p_listing_ids IS NULL OR cardinality(p_listing_ids)>100 THEN RAISE EXCEPTION 'MEDIA_ARGUMENTS'; END IF;
 RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('listing_id',sp.id,
  'managed',EXISTS(SELECT 1 FROM public.listing_images i WHERE i.listing_id=sp.id AND i.published_at IS NOT NULL),
  'images',coalesce((SELECT jsonb_agg(jsonb_build_object('id',i.id,'bucket_id',i.bucket_id,'object_path',i.object_path,'is_primary',i.is_primary,'sort_order',i.sort_order)
   ORDER BY i.is_primary DESC,i.sort_order,i.id) FROM public.listing_images i
   WHERE i.listing_id=sp.id AND i.publication_state='published' AND EXISTS(SELECT 1 FROM storage.objects o
    WHERE o.bucket_id=i.bucket_id AND o.name=i.object_path AND public._catalog_photo_metadata_v1(o.metadata,i.mime_type,i.byte_size))),'[]'::jsonb)))
  FROM public.shop_products sp WHERE sp.id=ANY(p_listing_ids) AND public._listing_public_v1(sp.id)),'[]'::jsonb);
END $function$;

-- Immutable object ownership/path and append-only decisions. No client table
-- mutations are granted; all new writes use the narrow RPCs above.
CREATE FUNCTION public._catalog_append_only_v1() RETURNS trigger LANGUAGE plpgsql SET search_path=pg_catalog AS $function$
BEGIN RAISE EXCEPTION 'CATALOG_IMMUTABLE'; END $function$;
CREATE TRIGGER product_submission_decisions_immutable BEFORE UPDATE OR DELETE ON public.product_submission_decisions
 FOR EACH ROW EXECUTE FUNCTION public._catalog_append_only_v1();
CREATE FUNCTION public._listing_storage_insert_v1(p_bucket text,p_path text,p_metadata jsonb) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
 SELECT EXISTS(SELECT 1 FROM public.listing_images i WHERE i.bucket_id=p_bucket AND i.object_path=p_path
 AND i.publication_state='pending' AND i.uploaded_by=auth.uid() AND public._listing_own_v1(i.listing_id)
 -- Storage's permission probe precedes upload and may have no metadata or
 -- only mimetype/contentLength (multipart length is not the object's size).
 -- Final object metadata MUST pass the strict size/MIME check to publish.
 AND (p_metadata IS NULL OR (
  (NOT (p_metadata ? 'mimetype') OR p_metadata->>'mimetype'=i.mime_type)
  AND (NOT (p_metadata ? 'size') OR public._catalog_photo_metadata_v1(p_metadata,i.mime_type,i.byte_size)))))
$function$;
CREATE FUNCTION public._listing_storage_read_v1(p_bucket text,p_path text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
 SELECT EXISTS(SELECT 1 FROM public.listing_images i WHERE i.bucket_id=p_bucket AND i.object_path=p_path
 AND (public._listing_own_v1(i.listing_id) OR (i.publication_state='published' AND public._listing_public_v1(i.listing_id)
  AND EXISTS(SELECT 1 FROM storage.objects o WHERE o.bucket_id=i.bucket_id AND o.name=i.object_path
   AND public._catalog_photo_metadata_v1(o.metadata,i.mime_type,i.byte_size)))))
$function$;
CREATE POLICY listing_media_owned_upload ON storage.objects FOR INSERT TO authenticated
 WITH CHECK(public._listing_storage_insert_v1(bucket_id,name,metadata));
CREATE POLICY listing_media_safe_read ON storage.objects FOR SELECT TO anon,authenticated
 USING(bucket_id='listing-media' AND public._listing_storage_read_v1(bucket_id,name));
-- Deliberately no object UPDATE/DELETE: versioned uploads never overwrite
-- evidence; retirement retains bytes. Pending intents can be retired by owner.

ALTER TABLE public.product_identity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_identifiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_submission_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_images ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.product_identity,public.product_identifiers,public.product_submissions,public.product_submission_decisions,public.listing_images FROM PUBLIC,anon,authenticated,service_role;
GRANT SELECT ON public.product_identity,public.product_identifiers,public.listing_images TO anon,authenticated;
GRANT SELECT ON public.product_submissions,public.product_submission_decisions TO authenticated;
CREATE POLICY catalog_identity_public ON public.product_identity FOR SELECT TO anon,authenticated USING(public._catalog_product_public_v1(product_id));
CREATE POLICY catalog_identifiers_public ON public.product_identifiers FOR SELECT TO anon,authenticated USING(public._catalog_product_public_v1(product_id));
CREATE POLICY catalog_submissions_owned ON public.product_submissions FOR SELECT TO authenticated USING(public._catalog_own_shop_v1(shop_id));
CREATE POLICY catalog_decisions_owned ON public.product_submission_decisions FOR SELECT TO authenticated
 USING(EXISTS(SELECT 1 FROM public.product_submissions s WHERE s.id=submission_id AND public._catalog_own_shop_v1(s.shop_id)));
CREATE POLICY listing_images_owned_or_published ON public.listing_images FOR SELECT TO anon,authenticated
 USING(public._listing_own_v1(listing_id) OR (publication_state='published' AND public._listing_storage_read_v1(bucket_id,object_path)));

-- Self-service cannot appropriate another merchant's unique catalog identity.
CREATE FUNCTION public._catalog_listing_identity_guard_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $function$
BEGIN
 IF TG_OP='UPDATE' AND (NEW.shop_id IS DISTINCT FROM OLD.shop_id OR NEW.product_id IS DISTINCT FROM OLD.product_id)
 THEN RAISE EXCEPTION 'CATALOG_LISTING_IDENTITY_IMMUTABLE' USING ERRCODE='42501'; END IF;
 IF TG_OP='INSERT' AND NOT public._catalog_product_public_v1(NEW.product_id)
 THEN RAISE EXCEPTION 'CATALOG_PRODUCT_UNAVAILABLE' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM public.product_identity i WHERE i.product_id=NEW.product_id AND i.product_type='merchant_unique_product' AND i.origin_shop_id<>NEW.shop_id)
 THEN RAISE EXCEPTION 'CATALOG_UNIQUE_OWNER' USING ERRCODE='42501'; END IF;
 RETURN NEW;
END $function$;
CREATE TRIGGER catalog_listing_identity_guard BEFORE INSERT OR UPDATE OF shop_id,product_id ON public.shop_products
 FOR EACH ROW EXECUTE FUNCTION public._catalog_listing_identity_guard_v1();

REVOKE ALL ON FUNCTION public.catalog_normalize_v1(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.catalog_gtin_v1(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_category_allowed_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_product_public_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_own_shop_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_catalog_categories_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_catalog_lookup_v1(uuid,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_submit_product_v1(uuid,uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.decide_catalog_submission_v1(uuid,text,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_photo_metadata_v1(jsonb,text,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._listing_public_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._listing_own_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_listing_media_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_prepare_listing_image_v1(uuid,text,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_change_listing_images_v1(uuid,text,uuid,uuid[]) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.catalog_listing_media_read_v1(uuid[]) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_append_only_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._listing_storage_insert_v1(text,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._listing_storage_read_v1(text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._catalog_listing_identity_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.merchant_catalog_search_v1(uuid,text,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.merchant_catalog_categories_v1(uuid),
 public.merchant_catalog_search_v1(uuid,text,integer,integer),
 public.merchant_catalog_lookup_v1(uuid,text,text),public.merchant_submit_product_v1(uuid,uuid,jsonb),
 public.merchant_listing_media_v1(uuid),public.merchant_prepare_listing_image_v1(uuid,text,integer),
 public.merchant_change_listing_images_v1(uuid,text,uuid,uuid[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.decide_catalog_submission_v1(uuid,text,uuid,text) TO service_role;
GRANT EXECUTE ON FUNCTION public.catalog_listing_media_read_v1(uuid[]),public._catalog_product_public_v1(uuid),
 public._catalog_own_shop_v1(uuid),public._listing_public_v1(uuid),public._listing_own_v1(uuid),
 public._listing_storage_read_v1(text,text),public.catalog_gtin_v1(text) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public._listing_storage_insert_v1(text,text,jsonb) TO authenticated;
COMMIT;
