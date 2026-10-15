-- F: owned informational offers. Does not write cart, QR quote, reward or rank.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.badge_rule_versions') IS NULL OR to_regclass('public.listing_images') IS NULL
    OR to_regprocedure('public._qr_auth_session_b()') IS NULL THEN
    RAISE EXCEPTION '0021 requires integrated A/B/C/D';
  END IF;
END $preflight$;

CREATE TABLE public.campaign_protocol_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false,
  price_publication_enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.campaign_protocol_config(singleton) VALUES(true);
CREATE TABLE public.merchant_campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
  current_revision_id uuid,
  ever_published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX merchant_campaigns_shop ON public.merchant_campaigns(shop_id,created_at DESC,id);
CREATE TABLE public.campaign_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id uuid NOT NULL REFERENCES public.merchant_campaigns(id) ON DELETE RESTRICT,
  actor_subject uuid NOT NULL,
  action text NOT NULL CHECK(action IN ('save','activate','pause')),
  active boolean NOT NULL DEFAULT false,
  title text NOT NULL CHECK(length(title) BETWEEN 1 AND 100),
  description text NOT NULL CHECK(length(description)<=500),
  offer_type text NOT NULL CHECK(offer_type IN ('announcement','price','percentage')),
  scope text NOT NULL CHECK(scope IN ('single','multiple','all')),
  listing_ids uuid[] NOT NULL,
  image_ids uuid[] NOT NULL,
  price_minor bigint,
  percentage_basis_points integer,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL CHECK(ends_at>starts_at),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK((offer_type='announcement' AND price_minor IS NULL AND percentage_basis_points IS NULL)
    OR (offer_type='price' AND price_minor BETWEEN 1 AND 999999999 AND percentage_basis_points IS NULL)
    OR (offer_type='percentage' AND price_minor IS NULL AND percentage_basis_points BETWEEN 1 AND 10000)),
  CHECK((scope='all' AND cardinality(listing_ids)=0) OR (scope='single' AND cardinality(listing_ids)=1)
    OR (scope='multiple' AND cardinality(listing_ids) BETWEEN 2 AND 100)),
  CHECK(cardinality(image_ids)<=5 AND array_position(listing_ids,NULL) IS NULL AND array_position(image_ids,NULL) IS NULL)
);
CREATE INDEX campaign_revisions_history ON public.campaign_revisions(campaign_id,recorded_at DESC,id);
ALTER TABLE public.merchant_campaigns ADD CONSTRAINT campaign_current_revision_fk
  FOREIGN KEY(current_revision_id) REFERENCES public.campaign_revisions(id) ON DELETE RESTRICT;
CREATE TABLE public.campaign_requests (
  actor_subject uuid NOT NULL,
  request_id uuid NOT NULL,
  payload_hash bytea NOT NULL,
  receipt jsonb NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY(actor_subject,request_id)
);

CREATE FUNCTION public.campaign_capabilities_v1() RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $campaign$
  SELECT jsonb_build_object('version',1,'enabled',enabled,'price_publication_enabled',price_publication_enabled)
    FROM public.campaign_protocol_config WHERE singleton
$campaign$;
CREATE FUNCTION public._campaign_targets_f(p_revision public.campaign_revisions) RETURNS SETOF public.shop_products
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $campaign$
  SELECT sp.* FROM public.shop_products sp JOIN public.merchant_campaigns c ON c.shop_id=sp.shop_id
  WHERE c.id=p_revision.campaign_id AND (p_revision.scope='all' OR sp.id=ANY(p_revision.listing_ids))
$campaign$;
CREATE FUNCTION public._campaign_block_reason_f(p_revision public.campaign_revisions) RETURNS text
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $campaign$
DECLARE n integer; BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.campaign_protocol_config WHERE enabled) THEN RETURN 'disabled'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.merchant_campaigns c JOIN public.shops s ON s.id=c.shop_id
    JOIN public.profiles owner ON owner.id=s.owner_user_id AND owner.role='merchant'
    WHERE c.id=p_revision.campaign_id AND s.is_active) THEN RETURN 'shop_unavailable'; END IF;
  IF p_revision.offer_type<>'announcement' AND NOT EXISTS(SELECT 1 FROM public.campaign_protocol_config WHERE price_publication_enabled)
    THEN RETURN 'price_publication_pending'; END IF;
  -- All scopes follow the current sellable assortment. Explicit scopes fail as a
  -- whole if a selected item disappears; never broaden the merchant's promise.
  SELECT count(*) INTO n FROM public._campaign_targets_f(p_revision) sp WHERE public._listing_public_v1(sp.id);
  IF n=0 OR (p_revision.scope<>'all' AND n<>cardinality(p_revision.listing_ids)) THEN RETURN 'listing_unavailable'; END IF;
  IF p_revision.offer_type='price' AND EXISTS(SELECT 1 FROM public._campaign_targets_f(p_revision) sp
    WHERE public._listing_public_v1(sp.id) AND sp.price*100<=p_revision.price_minor) THEN RETURN 'price_changed'; END IF;
  RETURN NULL;
END $campaign$;
CREATE FUNCTION public._campaign_json_f(p_id uuid,p_owner boolean DEFAULT false) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $campaign$
DECLARE c public.merchant_campaigns; r public.campaign_revisions; blocked text; status_text text; result jsonb; BEGIN
  SELECT * INTO c FROM public.merchant_campaigns WHERE id=p_id;
  SELECT * INTO r FROM public.campaign_revisions WHERE id=c.current_revision_id AND campaign_id=c.id;
  IF r.id IS NULL THEN RETURN NULL; END IF;
  blocked:=public._campaign_block_reason_f(r);
  status_text:=CASE WHEN NOT r.active THEN CASE WHEN c.ever_published THEN 'paused' ELSE 'draft' END
    WHEN r.ends_at<=statement_timestamp() THEN 'ended' WHEN blocked IS NOT NULL THEN 'blocked'
    WHEN r.starts_at>statement_timestamp() THEN 'scheduled' ELSE 'active' END;
  IF NOT p_owner AND status_text<>'active' THEN RETURN NULL; END IF;
  result:=jsonb_build_object('id',c.id,'shop_id',c.shop_id,'revision_id',r.id,'title',r.title,'description',r.description,
    'type',r.offer_type,'scope',r.scope,'starts_at',r.starts_at,'ends_at',r.ends_at,'status',status_text,
    'price_minor',r.price_minor,'percentage_basis_points',r.percentage_basis_points,
    'listing_ids',r.listing_ids,
    'products',coalesce((SELECT jsonb_agg(jsonb_build_object('listing_id',sp.id,'name',p.name) ORDER BY p.name,sp.id)
      FROM public._campaign_targets_f(r) sp JOIN public.products p ON p.id=sp.product_id
      WHERE r.scope<>'all' AND (p_owner OR public._listing_public_v1(sp.id))),'[]'),
    'images',coalesce((SELECT jsonb_agg(jsonb_build_object('id',i.id,'listing_id',i.listing_id,
      'bucket_id',i.bucket_id,'object_path',i.object_path) ORDER BY array_position(r.image_ids,i.id))
      FROM public.listing_images i JOIN public.shop_products sp ON sp.id=i.listing_id AND sp.shop_id=c.shop_id
      WHERE i.id=ANY(r.image_ids) AND i.publication_state='published' AND public._listing_public_v1(sp.id)
        AND (r.scope='all' OR sp.id=ANY(r.listing_ids)) AND EXISTS(SELECT 1 FROM storage.objects o
          WHERE o.bucket_id=i.bucket_id AND o.name=i.object_path AND public._catalog_photo_metadata_v1(o.metadata,i.mime_type,i.byte_size))),'[]'));
  IF p_owner THEN result:=result||jsonb_build_object('active',r.active,'image_ids',r.image_ids,'blocked_reason',blocked); END IF;
  RETURN result;
END $campaign$;

CREATE FUNCTION public.mutate_campaign_v1(p_shop_id uuid,p_campaign_id uuid,p_expected_revision uuid,
  p_request_id uuid,p_action text,p_draft jsonb DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $campaign$
DECLARE actor uuid; c public.merchant_campaigns; r public.campaign_revisions; prior public.campaign_requests;
  payload bytea; receipt jsonb; item uuid; reason text; n integer;
BEGIN
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='merchant' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[CAMPAIGN_MERCHANT_REQUIRED]' USING ERRCODE='42501'; END IF;
  PERFORM public._qr_auth_session_b();
  -- Acquire the shop exclusively immediately: never upgrade a shared read lock.
  PERFORM id FROM public.shops WHERE id=p_shop_id AND owner_user_id=auth.uid() AND is_active FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[CAMPAIGN_SHOP_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  actor:=public._review_subject_c(auth.uid());
  PERFORM subject_id FROM public.review_subject_keys WHERE subject_id=actor FOR UPDATE;
  IF p_request_id IS NULL OR p_action IS NULL OR p_action NOT IN ('save','activate','pause') THEN
    RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  payload:=extensions.digest(jsonb_build_object('shop',p_shop_id,'campaign',p_campaign_id,'expected',p_expected_revision,
    'action',p_action,'draft',p_draft)::text,'sha256');
  SELECT * INTO prior FROM public.campaign_requests WHERE actor_subject=actor AND request_id=p_request_id;
  IF FOUND THEN
    IF prior.payload_hash<>payload THEN RAISE EXCEPTION '[CAMPAIGN_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN prior.receipt;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.campaign_protocol_config WHERE enabled) THEN RAISE EXCEPTION '[CAMPAIGN_DISABLED]' USING ERRCODE='55000'; END IF;
  IF p_campaign_id IS NULL THEN
    IF p_action<>'save' OR p_expected_revision IS NOT NULL THEN RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    SELECT count(*) INTO n FROM public.merchant_campaigns WHERE shop_id=p_shop_id;
    IF n>=500 THEN RAISE EXCEPTION '[CAMPAIGN_LIMIT]' USING ERRCODE='54000'; END IF;
    INSERT INTO public.merchant_campaigns(shop_id) VALUES(p_shop_id) RETURNING * INTO c;
  ELSE
    SELECT * INTO c FROM public.merchant_campaigns WHERE id=p_campaign_id AND shop_id=p_shop_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION '[CAMPAIGN_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
    IF c.current_revision_id IS DISTINCT FROM p_expected_revision THEN RAISE EXCEPTION '[CAMPAIGN_CHANGED]' USING ERRCODE='40001'; END IF;
    SELECT * INTO r FROM public.campaign_revisions WHERE id=c.current_revision_id;
  END IF;
  IF p_action='save' THEN
    IF jsonb_typeof(p_draft) IS DISTINCT FROM 'object' OR NOT(p_draft ?& ARRAY['title','description','type','scope','listing_ids','image_ids','starts_at','ends_at'])
      OR EXISTS(SELECT 1 FROM jsonb_object_keys(p_draft) k WHERE k NOT IN ('title','description','type','scope','listing_ids','image_ids','starts_at','ends_at','price_minor','percentage_basis_points'))
      OR jsonb_typeof(p_draft->'listing_ids') IS DISTINCT FROM 'array' OR jsonb_typeof(p_draft->'image_ids') IS DISTINCT FROM 'array' THEN
      RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    r.title:=btrim(p_draft->>'title'); r.description:=btrim(p_draft->>'description');
    IF EXISTS(SELECT 1 FROM unnest(ARRAY['title','description','type','scope','starts_at','ends_at']) k
      WHERE jsonb_typeof(p_draft->k) IS DISTINCT FROM 'string') THEN
      RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    r.offer_type:=p_draft->>'type'; r.scope:=p_draft->>'scope';
    r.starts_at:=(p_draft->>'starts_at')::timestamptz; r.ends_at:=(p_draft->>'ends_at')::timestamptz;
    IF r.starts_at IS NULL OR r.ends_at IS NULL OR NOT isfinite(r.starts_at) OR NOT isfinite(r.ends_at) THEN
      RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    IF (p_draft->>'price_minor' IS NOT NULL AND (jsonb_typeof(p_draft->'price_minor')<>'number' OR p_draft->>'price_minor' !~ '^[0-9]{1,9}$'))
      OR (p_draft->>'percentage_basis_points' IS NOT NULL AND (jsonb_typeof(p_draft->'percentage_basis_points')<>'number' OR p_draft->>'percentage_basis_points' !~ '^[0-9]{1,5}$')) THEN
      RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    r.price_minor:=(p_draft->>'price_minor')::bigint; r.percentage_basis_points:=(p_draft->>'percentage_basis_points')::integer;
    SELECT coalesce(array_agg(value::uuid),'{}') INTO r.listing_ids FROM jsonb_array_elements_text(p_draft->'listing_ids');
    SELECT coalesce(array_agg(value::uuid),'{}') INTO r.image_ids FROM jsonb_array_elements_text(p_draft->'image_ids');
    IF cardinality(r.listing_ids)<>(SELECT count(DISTINCT x) FROM unnest(r.listing_ids) x)
      OR cardinality(r.image_ids)<>(SELECT count(DISTINCT x) FROM unnest(r.image_ids) x) THEN
      RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    FOREACH item IN ARRAY r.listing_ids LOOP
      IF NOT EXISTS(SELECT 1 FROM public.shop_products WHERE id=item AND shop_id=p_shop_id) THEN
        RAISE EXCEPTION '[CAMPAIGN_LISTING_FORBIDDEN]' USING ERRCODE='42501'; END IF;
    END LOOP;
    FOREACH item IN ARRAY r.image_ids LOOP
      IF NOT EXISTS(SELECT 1 FROM public.listing_images i JOIN public.shop_products sp ON sp.id=i.listing_id
        WHERE i.id=item AND sp.shop_id=p_shop_id AND i.publication_state='published' AND (r.scope='all' OR sp.id=ANY(r.listing_ids))
        AND EXISTS(SELECT 1 FROM storage.objects o WHERE o.bucket_id=i.bucket_id AND o.name=i.object_path
          AND public._catalog_photo_metadata_v1(o.metadata,i.mime_type,i.byte_size))) THEN
        RAISE EXCEPTION '[CAMPAIGN_IMAGE_FORBIDDEN]' USING ERRCODE='42501'; END IF;
    END LOOP;
    r.active:=false;
  ELSE
    IF p_draft IS NOT NULL THEN RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    r.active:=p_action='activate';
  END IF;
  r.id:=gen_random_uuid(); r.campaign_id:=c.id; r.actor_subject:=actor; r.action:=p_action; r.recorded_at:=clock_timestamp();
  -- Constraint validation remains authoritative even when drafting is allowed
  -- before public stock, dates or the monetary publication gate are ready.
  INSERT INTO public.campaign_revisions SELECT r.*;
  IF r.active THEN
    reason:=public._campaign_block_reason_f(r);
    IF reason IS NOT NULL THEN RAISE EXCEPTION '[CAMPAIGN_BLOCKED:%]',reason USING ERRCODE='55000'; END IF;
    IF r.ends_at<=clock_timestamp() THEN RAISE EXCEPTION '[CAMPAIGN_ENDED]' USING ERRCODE='22023'; END IF;
  END IF;
  UPDATE public.merchant_campaigns SET current_revision_id=r.id,ever_published=ever_published OR r.active WHERE id=c.id;
  receipt:=jsonb_build_object('id',c.id,'shop_id',c.shop_id,'revision_id',r.id,'action',p_action);
  INSERT INTO public.campaign_requests(actor_subject,request_id,payload_hash,receipt) VALUES(actor,p_request_id,payload,receipt);
  RETURN receipt;
EXCEPTION WHEN invalid_text_representation OR datetime_field_overflow OR invalid_datetime_format
  OR check_violation OR not_null_violation OR numeric_value_out_of_range THEN
  RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023';
END $campaign$;

CREATE FUNCTION public.read_merchant_campaigns_v1(p_shop_id uuid,p_limit integer DEFAULT 30,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $campaign$ BEGIN
  PERFORM public._review_merchant_c(p_shop_id);
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 100 OR p_offset IS NULL OR p_offset NOT BETWEEN 0 AND 500 THEN
    RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  RETURN public.campaign_capabilities_v1()||jsonb_build_object('campaigns',coalesce((SELECT jsonb_agg(public._campaign_json_f(id,true) ORDER BY created_at DESC,id)
    FROM(SELECT * FROM public.merchant_campaigns WHERE shop_id=p_shop_id ORDER BY created_at DESC,id LIMIT p_limit OFFSET p_offset) page),'[]'),
    'total',(SELECT count(*) FROM public.merchant_campaigns WHERE shop_id=p_shop_id));
END $campaign$;
CREATE FUNCTION public.read_shop_campaigns_v1(p_shop_id uuid,p_listing_id uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $campaign$ BEGIN
  IF p_shop_id IS NULL THEN RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  RETURN jsonb_build_object('enabled',coalesce((SELECT enabled FROM public.campaign_protocol_config),false),
    'server_time',statement_timestamp(),
    'campaigns',coalesce((SELECT jsonb_agg(value ORDER BY id) FROM(
      SELECT c.id,public._campaign_json_f(c.id,false) value FROM public.merchant_campaigns c
      JOIN public.campaign_revisions r ON r.id=c.current_revision_id WHERE c.shop_id=p_shop_id
      AND (p_listing_id IS NULL OR EXISTS(SELECT 1 FROM public._campaign_targets_f(r) sp WHERE sp.id=p_listing_id AND public._listing_public_v1(sp.id)))
      ORDER BY c.created_at DESC,c.id LIMIT 500) rows WHERE value IS NOT NULL),'[]'));
END $campaign$;
CREATE FUNCTION public.read_campaign_history_v1(p_shop_id uuid,p_campaign_id uuid,p_limit integer DEFAULT 30,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $campaign$ BEGIN
  PERFORM public._review_merchant_c(p_shop_id);
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 100 OR p_offset IS NULL OR p_offset<0 THEN
    RAISE EXCEPTION '[CAMPAIGN_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.merchant_campaigns WHERE id=p_campaign_id AND shop_id=p_shop_id) THEN
    RAISE EXCEPTION '[CAMPAIGN_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
  RETURN jsonb_build_object('history',coalesce((SELECT jsonb_agg(jsonb_build_object('id',id,'action',action,'title',title,'recorded_at',recorded_at) ORDER BY recorded_at DESC,id)
    FROM(SELECT * FROM public.campaign_revisions WHERE campaign_id=p_campaign_id ORDER BY recorded_at DESC,id LIMIT p_limit OFFSET p_offset) page),'[]'));
END $campaign$;

ALTER TABLE public.campaign_protocol_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.campaign_protocol_config FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.merchant_campaigns FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.campaign_revisions FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.campaign_requests FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER campaign_revisions_immutable BEFORE UPDATE OR DELETE ON public.campaign_revisions FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER campaign_requests_immutable BEFORE UPDATE OR DELETE ON public.campaign_requests FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
REVOKE ALL ON FUNCTION public.campaign_capabilities_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._campaign_targets_f(public.campaign_revisions) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._campaign_block_reason_f(public.campaign_revisions) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._campaign_json_f(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.mutate_campaign_v1(uuid,uuid,uuid,uuid,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_merchant_campaigns_v1(uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_shop_campaigns_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_campaign_history_v1(uuid,uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.campaign_capabilities_v1(),public.read_shop_campaigns_v1(uuid,uuid) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mutate_campaign_v1(uuid,uuid,uuid,uuid,text,jsonb),
  public.read_merchant_campaigns_v1(uuid,integer,integer),public.read_campaign_history_v1(uuid,uuid,integer,integer) TO authenticated;
COMMIT;
