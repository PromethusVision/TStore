-- Slice C. Local implementation; remote application requires separate authority.
-- Preserve legacy evidence anchors, scalar service history and migration bytes.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regprocedure('public._qr_auth_session_b()') IS NULL
    OR to_regprocedure('public._commerce_immutable_b()') IS NULL
    OR to_regprocedure('public.invalidate_purchase_v2(uuid,uuid,text)') IS NULL
    OR to_regclass('public.purchase_invalidations') IS NULL
    OR to_regclass('public.verified_transaction_items') IS NULL
    OR to_regprocedure('public.delete_current_customer_account()') IS NULL
    OR to_regprocedure('extensions.pgp_sym_encrypt(text,text,text)') IS NULL
    OR to_regprocedure('extensions.pgp_sym_decrypt(bytea,text)') IS NULL THEN
    RAISE EXCEPTION '0019 requires canonical review evidence, Slice B, managed Auth and pgcrypto';
  END IF;
END $preflight$;

CREATE TABLE public.review_protocol_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.review_protocol_config(singleton) VALUES(true);

-- This mapping/key is deliberately erasable. Audit rows have no auth-user FK.
CREATE TABLE public.review_subject_keys (
  user_id uuid PRIMARY KEY,
  subject_id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  content_key text NOT NULL DEFAULT encode(extensions.gen_random_bytes(32),'hex')
);
CREATE TABLE public.review_entitlements (
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  product_id uuid NOT NULL,
  item_id uuid NOT NULL REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT,
  used_review_id uuid,
  used_at timestamptz,
  PRIMARY KEY(purchase_id,product_id),
  CHECK((used_review_id IS NULL)=(used_at IS NULL))
);
CREATE TABLE public.review_lifecycle (
  review_id uuid PRIMARY KEY,
  subject_id uuid NOT NULL,
  product_id uuid NOT NULL,
  current_revision_id uuid,
  purchase_id uuid REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  shop_id uuid,
  edit_until timestamptz NOT NULL,
  withdrawn boolean NOT NULL DEFAULT false,
  moderation text NOT NULL DEFAULT 'visible' CHECK(moderation IN ('visible','hidden','under_review')),
  abuse_flagged boolean NOT NULL DEFAULT false,
  account_deleted boolean NOT NULL DEFAULT false
);
CREATE INDEX review_lifecycle_shop ON public.review_lifecycle(shop_id,review_id);
CREATE TABLE public.review_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES public.review_lifecycle(review_id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL,
  purchase_id uuid REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  shop_id uuid,
  product_id uuid NOT NULL,
  rating smallint NOT NULL CHECK(rating BETWEEN 1 AND 5),
  encrypted_body bytea NOT NULL,
  revision_kind text NOT NULL CHECK(revision_kind IN ('create','edit','reopen','legacy_import')),
  source_created_at timestamptz,
  source_updated_at timestamptz,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE public.review_lifecycle ADD CONSTRAINT review_current_revision_fk
  FOREIGN KEY(current_revision_id) REFERENCES public.review_revisions(id) ON DELETE RESTRICT;
CREATE INDEX review_revisions_root ON public.review_revisions(review_id,recorded_at DESC,id DESC);
CREATE TABLE public.service_evaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL UNIQUE REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL,
  shop_id uuid NOT NULL,
  friendliness smallint NOT NULL CHECK(friendliness BETWEEN 1 AND 5),
  communication smallint NOT NULL CHECK(communication BETWEEN 1 AND 5),
  cleanliness smallint NOT NULL CHECK(cleanliness BETWEEN 1 AND 5),
  submitted_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX service_evaluations_latest ON public.service_evaluations(shop_id,subject_id,submitted_at DESC,id DESC);
CREATE TABLE public.review_replies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL UNIQUE REFERENCES public.review_lifecycle(review_id) ON DELETE RESTRICT,
  revision_id uuid NOT NULL REFERENCES public.review_revisions(id) ON DELETE RESTRICT,
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  shop_id uuid NOT NULL,
  subject_id uuid NOT NULL,
  encrypted_body bytea NOT NULL,
  submitted_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.review_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES public.review_lifecycle(review_id) ON DELETE RESTRICT,
  revision_id uuid REFERENCES public.review_revisions(id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL,
  event_kind text NOT NULL CHECK(event_kind IN ('withdraw','reopen','report','hide','restore','under_review','flag_abuse','clear_abuse','hide_reply','account_delete')),
  encrypted_reason bytea,
  request_id uuid NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(subject_id,request_id)
);
CREATE TABLE public.review_requests (
  subject_id uuid NOT NULL,
  request_id uuid NOT NULL,
  payload_hash bytea NOT NULL,
  receipt jsonb NOT NULL,
  PRIMARY KEY(subject_id,request_id)
);

CREATE FUNCTION public._review_subject_c(p_user uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE result uuid; BEGIN
  INSERT INTO public.review_subject_keys(user_id) VALUES(p_user) ON CONFLICT DO NOTHING;
  SELECT subject_id INTO STRICT result FROM public.review_subject_keys WHERE user_id=p_user;
  RETURN result;
END $review_c$;
CREATE FUNCTION public._review_encrypt_c(p_subject uuid,p_body jsonb) RETURNS bytea
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT extensions.pgp_sym_encrypt(p_body::text,content_key,'cipher-algo=aes256,compress-algo=1')
  FROM public.review_subject_keys WHERE subject_id=p_subject
$review_c$;
CREATE FUNCTION public._review_decrypt_c(p_subject uuid,p_body bytea) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT extensions.pgp_sym_decrypt(p_body,content_key)::jsonb
  FROM public.review_subject_keys WHERE subject_id=p_subject
$review_c$;
CREATE FUNCTION public._review_enabled_c() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT enabled FROM public.review_protocol_config WHERE singleton
$review_c$;
CREATE FUNCTION public._review_customer_c() RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE allowed boolean; BEGIN
  -- Serialize one customer's submissions, retries, withdrawals and self-delete.
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='customer' FOR UPDATE;
  allowed:=FOUND;
  PERFORM public._qr_auth_session_b();
  IF NOT allowed THEN RAISE EXCEPTION '[REVIEW_CUSTOMER_REQUIRED]' USING ERRCODE='42501'; END IF;
  RETURN public._review_subject_c(auth.uid());
END $review_c$;
CREATE FUNCTION public._review_purchase_valid_c(p_purchase uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT EXISTS(SELECT 1 FROM public.verified_transactions WHERE id=p_purchase)
    AND NOT EXISTS(SELECT 1 FROM public.purchase_invalidations WHERE purchase_id=p_purchase)
$review_c$;
CREATE FUNCTION public._review_entitlement_c() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  IF NEW.product_id IS NULL THEN RETURN NEW; END IF;
  INSERT INTO public.review_entitlements(purchase_id,product_id,item_id)
    VALUES(NEW.verified_transaction_id,NEW.product_id,NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END $review_c$;
CREATE TRIGGER review_entitlement_after_verified_item AFTER INSERT ON public.verified_transaction_items
  FOR EACH ROW EXECUTE FUNCTION public._review_entitlement_c();
-- Rights derive only from existing verified item ownership; never from QR state.
INSERT INTO public.review_entitlements(purchase_id,product_id,item_id)
  SELECT DISTINCT ON(verified_transaction_id,product_id) verified_transaction_id,product_id,id
  FROM public.verified_transaction_items WHERE product_id IS NOT NULL ORDER BY verified_transaction_id,product_id,id;

CREATE FUNCTION public._review_visible_c(p_review uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT CASE WHEN s.review_id IS NOT NULL THEN
    NOT s.withdrawn AND NOT s.account_deleted AND s.moderation='visible'
    AND public._review_purchase_valid_c(s.purchase_id)
  ELSE NOT public._review_enabled_c() OR
    (r.is_verified_purchase AND i.id IS NOT NULL AND t.customer_user_id=r.user_id
      AND i.product_id=r.product_id AND public._review_purchase_valid_c(t.id)) END
  FROM public.reviews r
  LEFT JOIN public.review_lifecycle s ON s.review_id=r.id
  LEFT JOIN public.verified_transaction_items i ON i.id=r.verified_transaction_item_id
  LEFT JOIN public.verified_transactions t ON t.id=i.verified_transaction_id WHERE r.id=p_review
$review_c$;
CREATE FUNCTION public._review_refresh_product_c(p_product uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  -- A separate statement after this lock sees the preceding writer's commit.
  PERFORM id FROM public.products WHERE id=p_product FOR UPDATE;
  UPDATE public.products SET (rating,reviews_count)=(
    SELECT coalesce(round(avg(r.rating)::numeric,1),0),count(*)::integer
    FROM public.reviews r WHERE r.product_id=p_product
      AND (EXISTS(SELECT 1 FROM public.review_lifecycle s WHERE s.review_id=r.id AND public._review_purchase_valid_c(s.purchase_id))
        OR (r.is_verified_purchase AND r.verified_transaction_item_id IS NOT NULL)) AND public._review_visible_c(r.id)
  ) WHERE id=p_product;
END $review_c$;
CREATE OR REPLACE FUNCTION public.refresh_product_rating_after_review() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  PERFORM public._review_refresh_product_c(CASE WHEN TG_OP='DELETE' THEN OLD.product_id ELSE NEW.product_id END);
  IF TG_OP='DELETE' THEN RETURN OLD; END IF; RETURN NEW;
END $review_c$;

CREATE FUNCTION public._review_adopt_c(p_review uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE r public.reviews; i public.verified_transaction_items; t public.verified_transactions; sid uuid; rev uuid;
BEGIN
  IF EXISTS(SELECT 1 FROM public.review_lifecycle WHERE review_id=p_review) THEN RETURN; END IF;
  SELECT * INTO STRICT r FROM public.reviews WHERE id=p_review FOR UPDATE;
  SELECT * INTO i FROM public.verified_transaction_items WHERE id=r.verified_transaction_item_id;
  SELECT * INTO t FROM public.verified_transactions WHERE id=i.verified_transaction_id;
  IF i.id IS NULL OR t.customer_user_id IS DISTINCT FROM r.user_id OR i.product_id IS DISTINCT FROM r.product_id OR NOT r.is_verified_purchase THEN
    -- Preserve unsupported legacy content privately, without inventing evidence.
    t.id:=NULL; t.shop_id:=NULL;
  END IF;
  sid:=public._review_subject_c(r.user_id);
  INSERT INTO public.review_lifecycle(review_id,subject_id,product_id,purchase_id,shop_id,edit_until)
    VALUES(r.id,sid,r.product_id,t.id,t.shop_id,r.created_at+interval '24 hours');
  INSERT INTO public.review_revisions(review_id,subject_id,purchase_id,shop_id,product_id,rating,encrypted_body,revision_kind,source_created_at,source_updated_at)
    VALUES(r.id,sid,t.id,t.shop_id,r.product_id,r.rating,
      public._review_encrypt_c(sid,jsonb_build_object('title',r.title,'comment',r.comment)), 'legacy_import',r.created_at,r.updated_at)
    RETURNING id INTO rev;
  UPDATE public.review_lifecycle SET current_revision_id=rev WHERE review_id=r.id;
  UPDATE public.review_entitlements SET used_review_id=r.id,used_at=r.created_at WHERE purchase_id=t.id AND product_id=r.product_id;
END $review_c$;

CREATE FUNCTION public.review_capabilities_v2() RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT jsonb_build_object('version',2,'enabled',public._review_enabled_c(),'edit_hours',24,'criteria',jsonb_build_array('friendliness','communication','cleanliness'))
$review_c$;

CREATE FUNCTION public.read_service_scores_v2(p_shop_id uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  WITH latest AS (
    SELECT DISTINCT ON(e.subject_id) e.* FROM public.service_evaluations e
    JOIN public.review_subject_keys k ON k.subject_id=e.subject_id
    WHERE e.shop_id=p_shop_id AND public._review_purchase_valid_c(e.purchase_id)
    ORDER BY e.subject_id,e.submitted_at DESC,e.id DESC
  ) SELECT jsonb_build_object('shop_id',p_shop_id,'sample_count',count(*),
    'friendliness',avg(friendliness),'communication',avg(communication),'cleanliness',avg(cleanliness),
    'average_rating',(avg(friendliness)+avg(communication)+avg(cleanliness))/3) FROM latest
$review_c$;

CREATE FUNCTION public._review_json_c(p_review uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $review_c$
  SELECT jsonb_build_object('id',r.id,'user_id',CASE WHEN r.user_id=auth.uid() THEN r.user_id ELSE '00000000-0000-0000-0000-000000000000'::uuid END,
    'product_id',r.product_id,'rating',r.rating,'title',r.title,'comment',r.comment,'images',r.images,
    'is_verified_purchase',CASE WHEN s.review_id IS NOT NULL THEN public._review_purchase_valid_c(s.purchase_id)
      ELSE r.is_verified_purchase AND r.verified_transaction_item_id IS NOT NULL END,
    'helpful_count',r.helpful_count,'created_at',r.created_at,'updated_at',r.updated_at,
    'review_version',CASE WHEN s.review_id IS NOT NULL OR public._review_enabled_c() THEN 2 ELSE 1 END,
    'edit_until',coalesce(s.edit_until,r.created_at+interval '24 hours'),
    'can_withdraw',r.user_id=auth.uid() AND NOT coalesce(s.withdrawn,false),
    'can_edit',coalesce(r.user_id=auth.uid(),false) AND
      (CASE WHEN s.review_id IS NULL AND NOT public._review_enabled_c() THEN true ELSE
        clock_timestamp()<coalesce(s.edit_until,r.created_at+interval '24 hours') AND public._review_visible_c(r.id) END),
    'withdrawn',coalesce(s.withdrawn,false),'moderation',coalesce(s.moderation,'visible'),
    'merchant_reply',CASE WHEN reply.shop_id=s.shop_id AND public._review_visible_c(r.id)
      AND NOT EXISTS(SELECT 1 FROM public.review_events e WHERE e.review_id=r.id AND e.event_kind='hide_reply')
      THEN public._review_decrypt_c(reply.subject_id,reply.encrypted_body)->>'text' END)
  FROM public.reviews r LEFT JOIN public.review_lifecycle s ON s.review_id=r.id
    LEFT JOIN public.review_replies reply ON reply.review_id=r.id WHERE r.id=p_review
$review_c$;

CREATE OR REPLACE FUNCTION public.refresh_verified_shop_rating(p_shop_id uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE scores jsonb; BEGIN
  PERFORM id FROM public.shops WHERE id=p_shop_id FOR UPDATE;
  IF public._review_enabled_c() OR EXISTS(SELECT 1 FROM public.service_evaluations WHERE shop_id=p_shop_id) THEN
    scores:=public.read_service_scores_v2(p_shop_id);
    UPDATE public.shops SET rating=coalesce(round((scores->>'average_rating')::numeric,2),0),
      rating_count=(scores->>'sample_count')::integer WHERE id=p_shop_id;
  ELSE
    UPDATE public.shops SET (rating,rating_count)=(SELECT coalesce(round(avg(rating)::numeric,2),0),count(*)::integer
      FROM public.shop_ratings WHERE shop_id=p_shop_id) WHERE id=p_shop_id;
  END IF;
END $review_c$;

CREATE FUNCTION public.submit_purchase_evaluation_v2(p_purchase_id uuid,p_request_id uuid,
  p_service jsonb DEFAULT NULL,p_products jsonb DEFAULT '[]') RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE sid uuid; t public.verified_transactions; old_t public.verified_transactions;
  payload bytea; prior public.review_requests; service public.service_evaluations;
  entry jsonb; pid uuid; ent public.review_entitlements; r public.reviews; state public.review_lifecycle;
  rev uuid; at_time timestamptz; result jsonb:='[]'; kind text; receipt jsonb;
BEGIN
  sid:=public._review_customer_c();
  IF p_request_id IS NULL OR p_purchase_id IS NULL OR p_products IS NULL OR jsonb_typeof(p_products)<>'array'
    OR jsonb_array_length(p_products)>50 THEN RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  payload:=extensions.digest(jsonb_build_object('purchase',p_purchase_id,'service',p_service,'products',p_products)::text,'sha256');
  SELECT * INTO prior FROM public.review_requests WHERE subject_id=sid AND request_id=p_request_id;
  IF FOUND THEN
    IF prior.payload_hash<>payload THEN RAISE EXCEPTION '[REVIEW_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN prior.receipt;
  END IF;
  IF NOT public._review_enabled_c() THEN RAISE EXCEPTION '[REVIEW_DISABLED]' USING ERRCODE='55000'; END IF;
  -- Shop -> purchase -> products is shared with reply, invalidation and erasure.
  PERFORM s.id FROM public.shops s JOIN public.verified_transactions tx ON tx.shop_id=s.id
    WHERE tx.id=p_purchase_id AND tx.customer_user_id=auth.uid() FOR UPDATE OF s;
  SELECT * INTO t FROM public.verified_transactions WHERE id=p_purchase_id AND customer_user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND OR NOT public._review_purchase_valid_c(p_purchase_id) THEN RAISE EXCEPTION '[REVIEW_NOT_VERIFIED]' USING ERRCODE='42501'; END IF;
  SELECT * INTO service FROM public.service_evaluations WHERE purchase_id=p_purchase_id;
  IF service.id IS NULL THEN
    IF p_service IS NULL OR jsonb_typeof(p_service)<>'object' OR
      NOT (p_service ?& ARRAY['friendliness','communication','cleanliness']) OR
      (SELECT count(*) FROM jsonb_object_keys(p_service))<>3 OR
      (p_service->>'friendliness') !~ '^[1-5]$' OR (p_service->>'communication') !~ '^[1-5]$' OR
      (p_service->>'cleanliness') !~ '^[1-5]$' OR
      p_service->>'friendliness' IS NULL OR p_service->>'communication' IS NULL OR p_service->>'cleanliness' IS NULL
      THEN RAISE EXCEPTION '[REVIEW_SERVICE_REQUIRED]' USING ERRCODE='22023'; END IF;
    INSERT INTO public.service_evaluations(purchase_id,subject_id,shop_id,friendliness,communication,cleanliness)
      VALUES(t.id,sid,t.shop_id,(p_service->>'friendliness')::smallint,(p_service->>'communication')::smallint,(p_service->>'cleanliness')::smallint)
      RETURNING * INTO service;
  ELSIF p_service IS NOT NULL AND p_service<>jsonb_build_object('friendliness',service.friendliness,'communication',service.communication,'cleanliness',service.cleanliness) THEN
    RAISE EXCEPTION '[REVIEW_SERVICE_ALREADY_SUBMITTED]' USING ERRCODE='22023';
  END IF;
  IF (SELECT count(*)<>count(DISTINCT x->>'product_id') FROM jsonb_array_elements(p_products) x) THEN
    RAISE EXCEPTION '[REVIEW_DUPLICATE_PRODUCT]' USING ERRCODE='22023'; END IF;
  -- Lock all product projections in stable order before roots to avoid batch inversions.
  PERFORM id FROM public.products WHERE id IN(SELECT (x->>'product_id')::uuid FROM jsonb_array_elements(p_products) x) ORDER BY id FOR UPDATE;
  FOR entry IN SELECT value FROM jsonb_array_elements(p_products) ORDER BY value->>'product_id' LOOP
    pid:=(entry->>'product_id')::uuid;
    IF jsonb_typeof(entry)<>'object' OR (entry-'product_id'-'rating'-'title'-'comment')<>'{}'::jsonb
      OR (entry->'title' IS NOT NULL AND jsonb_typeof(entry->'title') NOT IN ('null','string'))
      OR (entry->'comment' IS NOT NULL AND jsonb_typeof(entry->'comment') NOT IN ('null','string'))
      OR pid IS NULL OR entry->>'rating' IS NULL OR (entry->>'rating') !~ '^[1-5]$'
      OR length(coalesce(entry->>'title',''))>120 OR length(coalesce(entry->>'comment',''))>2000 THEN
      RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
    SELECT * INTO ent FROM public.review_entitlements WHERE purchase_id=t.id AND product_id=pid FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_NOT_VERIFIED]' USING ERRCODE='42501'; END IF;
    SELECT * INTO r FROM public.reviews WHERE user_id=auth.uid() AND product_id=pid FOR UPDATE;
    IF r.id IS NOT NULL THEN PERFORM public._review_adopt_c(r.id); END IF;
    -- Adoption may consume the original entitlement; always reload under lock.
    SELECT * INTO ent FROM public.review_entitlements WHERE purchase_id=t.id AND product_id=pid;
    IF ent.used_review_id IS NOT NULL THEN RAISE EXCEPTION '[REVIEW_ENTITLEMENT_USED]' USING ERRCODE='22023'; END IF;
    at_time:=clock_timestamp();
    IF r.id IS NULL THEN
      INSERT INTO public.reviews(user_id,product_id,rating,title,comment,is_verified_purchase,verified_transaction_item_id)
        VALUES(auth.uid(),pid,(entry->>'rating')::integer,nullif(btrim(entry->>'title'),''),nullif(btrim(entry->>'comment'),''),true,ent.item_id)
        RETURNING * INTO r;
      INSERT INTO public.review_lifecycle(review_id,subject_id,product_id,purchase_id,shop_id,edit_until)
        VALUES(r.id,sid,pid,t.id,t.shop_id,at_time+interval '24 hours');
      kind:='create';
    ELSE
      SELECT * INTO state FROM public.review_lifecycle WHERE review_id=r.id FOR UPDATE;
      SELECT * INTO old_t FROM public.verified_transactions WHERE id=state.purchase_id;
      IF old_t.id IS NOT NULL AND (t.confirmed_at,t.id)<=(old_t.confirmed_at,old_t.id) THEN RAISE EXCEPTION '[REVIEW_NEWER_PURCHASE_REQUIRED]' USING ERRCODE='22023'; END IF;
      UPDATE public.review_lifecycle SET purchase_id=t.id,shop_id=t.shop_id,edit_until=at_time+interval '24 hours',withdrawn=false WHERE review_id=r.id;
      UPDATE public.reviews SET rating=(entry->>'rating')::integer,title=nullif(btrim(entry->>'title'),''),comment=nullif(btrim(entry->>'comment'),'') WHERE id=r.id;
      kind:='reopen';
    END IF;
    INSERT INTO public.review_revisions(review_id,subject_id,purchase_id,shop_id,product_id,rating,encrypted_body,revision_kind,recorded_at)
      VALUES(r.id,sid,t.id,t.shop_id,pid,(entry->>'rating')::smallint,
        public._review_encrypt_c(sid,jsonb_build_object('title',nullif(btrim(entry->>'title'),''),'comment',nullif(btrim(entry->>'comment'),''))),kind,at_time)
      RETURNING id INTO rev;
    UPDATE public.review_lifecycle SET current_revision_id=rev WHERE review_id=r.id;
    UPDATE public.review_entitlements SET used_review_id=r.id,used_at=at_time WHERE purchase_id=t.id AND product_id=pid;
    IF kind='reopen' THEN INSERT INTO public.review_events(review_id,revision_id,subject_id,event_kind,request_id)
      VALUES(r.id,rev,sid,'reopen',gen_random_uuid()); END IF;
    PERFORM public._review_refresh_product_c(pid);
    result:=result||jsonb_build_array(jsonb_build_object('review_id',r.id,'product_id',pid,'revision_id',rev,'kind',kind,'edit_until',at_time+interval '24 hours'));
  END LOOP;
  receipt:=jsonb_build_object('purchase_id',t.id,'service_evaluation_id',service.id,'reviews',result);
  INSERT INTO public.review_requests VALUES(sid,p_request_id,payload,receipt);
  PERFORM public.refresh_verified_shop_rating(t.shop_id);
  RETURN receipt;
END $review_c$;

CREATE FUNCTION public.read_purchase_evaluation_v2(p_purchase_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE t public.verified_transactions; result jsonb; BEGIN
  PERFORM public._review_customer_c();
  SELECT * INTO t FROM public.verified_transactions WHERE id=p_purchase_id AND customer_user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_NOT_VERIFIED]' USING ERRCODE='42501'; END IF;
  SELECT jsonb_build_object('purchase_id',t.id,'shop_id',t.shop_id,'shop_name',t.shop_name,
    'enabled',public._review_enabled_c(),'valid',public._review_purchase_valid_c(t.id),
    'service', (SELECT jsonb_build_object('friendliness',friendliness,'communication',communication,'cleanliness',cleanliness)
       FROM public.service_evaluations WHERE purchase_id=t.id),
    'products',coalesce(jsonb_agg(jsonb_build_object('product_id',e.product_id,'product_name',i.product_name,
      'can_submit',public._review_enabled_c() AND public._review_purchase_valid_c(t.id) AND e.used_review_id IS NULL
        AND (r.id IS NULL OR origin.id IS NULL OR (t.confirmed_at,t.id)>(origin.confirmed_at,origin.id)),
      'existing_review',public._review_json_c(r.id)) ORDER BY i.product_name,e.product_id),'[]')) INTO result
  FROM public.review_entitlements e JOIN public.verified_transaction_items i ON i.id=e.item_id
  LEFT JOIN public.reviews r ON r.user_id=auth.uid() AND r.product_id=e.product_id
  LEFT JOIN public.review_lifecycle s ON s.review_id=r.id
  LEFT JOIN public.verified_transaction_items original_item ON original_item.id=r.verified_transaction_item_id
  LEFT JOIN public.verified_transactions origin ON origin.id=coalesce(s.purchase_id,original_item.verified_transaction_id)
  WHERE e.purchase_id=t.id;
  RETURN result;
END $review_c$;

CREATE FUNCTION public.read_customer_service_evaluations_v2(p_purchase_ids uuid[]) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  PERFORM public._review_customer_c();
  IF p_purchase_ids IS NULL OR cardinality(p_purchase_ids)>100 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  RETURN coalesce((SELECT jsonb_agg(jsonb_build_object('purchase_id',e.purchase_id,
    'friendliness',e.friendliness,'communication',e.communication,'cleanliness',e.cleanliness,
    'submitted_at',e.submitted_at,'valid',public._review_purchase_valid_c(e.purchase_id)) ORDER BY e.submitted_at DESC,e.id DESC)
    FROM public.service_evaluations e JOIN public.verified_transactions t ON t.id=e.purchase_id
    JOIN public.review_subject_keys k ON k.subject_id=e.subject_id AND k.user_id=auth.uid()
    WHERE t.customer_user_id=auth.uid() AND e.purchase_id=ANY(p_purchase_ids)),'[]');
END $review_c$;

-- Preserve old signatures, but keep their original implementations private.
ALTER FUNCTION public.submit_product_review(uuid,integer,text,text) RENAME TO _submit_product_review_legacy_c;
ALTER FUNCTION public.update_product_review(uuid,integer,text,text) RENAME TO _update_product_review_legacy_c;
ALTER FUNCTION public.delete_product_review(uuid) RENAME TO _delete_product_review_legacy_c;
ALTER FUNCTION public.get_product_review_eligibility(uuid) RENAME TO _get_product_review_eligibility_legacy_c;
ALTER FUNCTION public.submit_verified_shop_rating(uuid,integer) RENAME TO _submit_verified_shop_rating_legacy_c;

CREATE OR REPLACE FUNCTION public.submit_product_review(p_product_id uuid,p_rating integer,p_title text DEFAULT NULL,p_comment text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  IF public._review_enabled_c() OR EXISTS(SELECT 1 FROM public.reviews r JOIN public.review_lifecycle s ON s.review_id=r.id
      WHERE r.user_id=auth.uid() AND r.product_id=p_product_id) THEN
    RAISE EXCEPTION '[REVIEW_USE_PURCHASE_EVALUATION]' USING ERRCODE='55000'; END IF;
  RETURN public._submit_product_review_legacy_c(p_product_id,p_rating,p_title,p_comment);
END $review_c$;
CREATE OR REPLACE FUNCTION public.submit_verified_shop_rating(p_qr_session_id uuid,p_rating integer) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  IF public._review_enabled_c() OR EXISTS(SELECT 1 FROM public.service_evaluations e JOIN public.verified_transactions t ON t.id=e.purchase_id
      WHERE t.source_qr_session_id=p_qr_session_id AND t.customer_user_id=auth.uid()) THEN
    RAISE EXCEPTION '[REVIEW_USE_PURCHASE_EVALUATION]' USING ERRCODE='55000'; END IF;
  RETURN public._submit_verified_shop_rating_legacy_c(p_qr_session_id,p_rating);
END $review_c$;
CREATE OR REPLACE FUNCTION public.update_product_review(p_review_id uuid,p_rating integer,p_title text DEFAULT NULL,p_comment text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE r public.reviews; s public.review_lifecycle; sid uuid; rev uuid; origin uuid; BEGIN
  IF NOT public._review_enabled_c() AND NOT EXISTS(SELECT 1 FROM public.review_lifecycle WHERE review_id=p_review_id) THEN
    RETURN public._update_product_review_legacy_c(p_review_id,p_rating,p_title,p_comment); END IF;
  sid:=public._review_customer_c();
  IF p_rating IS NULL OR p_rating NOT BETWEEN 1 AND 5 OR length(coalesce(p_title,''))>120 OR length(coalesce(p_comment,''))>2000 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  SELECT * INTO r FROM public.reviews WHERE id=p_review_id AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
  SELECT coalesce(life.purchase_id,i.verified_transaction_id) INTO origin FROM public.reviews rr
    LEFT JOIN public.review_lifecycle life ON life.review_id=rr.id LEFT JOIN public.verified_transaction_items i ON i.id=rr.verified_transaction_item_id WHERE rr.id=r.id;
  PERFORM id FROM public.verified_transactions WHERE id=origin FOR UPDATE;
  PERFORM id FROM public.products WHERE id=r.product_id FOR UPDATE;
  PERFORM public._review_adopt_c(r.id);
  SELECT * INTO STRICT s FROM public.review_lifecycle WHERE review_id=r.id FOR UPDATE;
  IF clock_timestamp()>=s.edit_until OR NOT public._review_purchase_valid_c(s.purchase_id) OR s.withdrawn OR s.moderation<>'visible' THEN
    RAISE EXCEPTION '[REVIEW_EDIT_CLOSED]' USING ERRCODE='42501'; END IF;
  IF r.rating=p_rating AND r.title IS NOT DISTINCT FROM nullif(btrim(p_title),'') AND r.comment IS NOT DISTINCT FROM nullif(btrim(p_comment),'') THEN
    RETURN public._review_json_c(r.id); END IF;
  INSERT INTO public.review_revisions(review_id,subject_id,purchase_id,shop_id,product_id,rating,encrypted_body,revision_kind)
    VALUES(r.id,sid,s.purchase_id,s.shop_id,r.product_id,p_rating,
      public._review_encrypt_c(sid,jsonb_build_object('title',nullif(btrim(p_title),''),'comment',nullif(btrim(p_comment),''))),'edit') RETURNING id INTO rev;
  UPDATE public.review_lifecycle SET current_revision_id=rev WHERE review_id=r.id;
  UPDATE public.reviews SET rating=p_rating,title=nullif(btrim(p_title),''),comment=nullif(btrim(p_comment),'') WHERE id=r.id;
  RETURN public._review_json_c(r.id);
END $review_c$;
CREATE OR REPLACE FUNCTION public.delete_product_review(p_review_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE r public.reviews; s public.review_lifecycle; sid uuid; BEGIN
  IF NOT public._review_enabled_c() AND NOT EXISTS(SELECT 1 FROM public.review_lifecycle WHERE review_id=p_review_id) THEN
    RETURN public._delete_product_review_legacy_c(p_review_id); END IF;
  sid:=public._review_customer_c();
  SELECT * INTO r FROM public.reviews WHERE id=p_review_id AND user_id=auth.uid();
  IF NOT FOUND THEN RETURN jsonb_build_object('review_id',p_review_id,'deleted',false,'withdrawn',false); END IF;
  PERFORM id FROM public.products WHERE id=r.product_id FOR UPDATE;
  PERFORM public._review_adopt_c(r.id);
  SELECT * INTO STRICT s FROM public.review_lifecycle WHERE review_id=r.id FOR UPDATE;
  IF NOT s.withdrawn THEN
    UPDATE public.review_lifecycle SET withdrawn=true WHERE review_id=r.id;
    INSERT INTO public.review_events(review_id,revision_id,subject_id,event_kind,request_id) VALUES(r.id,s.current_revision_id,sid,'withdraw',gen_random_uuid());
    PERFORM public._review_refresh_product_c(r.product_id);
  END IF;
  RETURN jsonb_build_object('review_id',r.id,'deleted',true,'withdrawn',true);
END $review_c$;

CREATE OR REPLACE FUNCTION public.get_product_review_eligibility(p_product_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE r public.reviews; t public.verified_transactions; item uuid; origin uuid; result jsonb; BEGIN
  IF NOT public._review_enabled_c() AND NOT EXISTS(SELECT 1 FROM public.reviews rr JOIN public.review_lifecycle s ON s.review_id=rr.id
      WHERE rr.user_id=auth.uid() AND rr.product_id=p_product_id) THEN
    RETURN public._get_product_review_eligibility_legacy_c(p_product_id); END IF;
  PERFORM public._review_customer_c();
  SELECT * INTO r FROM public.reviews WHERE user_id=auth.uid() AND product_id=p_product_id;
  SELECT coalesce(s.purchase_id,i.verified_transaction_id) INTO origin FROM public.reviews rr
    LEFT JOIN public.review_lifecycle s ON s.review_id=rr.id LEFT JOIN public.verified_transaction_items i ON i.id=rr.verified_transaction_item_id WHERE rr.id=r.id;
  SELECT e.item_id INTO item FROM public.review_entitlements e
    JOIN public.verified_transactions tx ON tx.id=e.purchase_id
    LEFT JOIN public.verified_transactions previous ON previous.id=origin
    WHERE e.product_id=p_product_id AND tx.customer_user_id=auth.uid() AND e.used_review_id IS NULL
      AND public._review_purchase_valid_c(tx.id) AND (r.id IS NULL OR previous.id IS NULL OR (tx.confirmed_at,tx.id)>(previous.confirmed_at,previous.id))
    ORDER BY tx.confirmed_at DESC,tx.id DESC LIMIT 1;
  SELECT tx.* INTO t FROM public.verified_transactions tx JOIN public.verified_transaction_items i ON i.verified_transaction_id=tx.id WHERE i.id=item;
  RETURN jsonb_build_object('product_id',p_product_id,'review_version',2,'eligible',t.id IS NOT NULL OR origin IS NOT NULL,
    'can_submit',public._review_enabled_c() AND t.id IS NOT NULL,'can_reopen',public._review_enabled_c() AND r.id IS NOT NULL AND t.id IS NOT NULL,
    'existing_review_id',r.id,'own_review',public._review_json_c(r.id),'verified_transaction_item_id',item,
    'verified_transaction_id',t.id,'verified_at',t.confirmed_at);
END $review_c$;

CREATE OR REPLACE FUNCTION public.get_product_reviews(p_product_id uuid,p_limit integer DEFAULT 20,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE result jsonb; BEGIN
  IF p_product_id IS NULL OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 50 OR p_offset IS NULL OR p_offset<0 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.products WHERE id=p_product_id AND is_active) THEN
    RAISE EXCEPTION '[REVIEW_PRODUCT_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
  SELECT jsonb_build_object('product_id',p_product_id,'average_rating',coalesce(round(avg(r.rating)::numeric,1),0),
    'review_count',count(*),'rating_distribution',jsonb_build_object('1',count(*) FILTER(WHERE rating=1),'2',count(*) FILTER(WHERE rating=2),
    '3',count(*) FILTER(WHERE rating=3),'4',count(*) FILTER(WHERE rating=4),'5',count(*) FILTER(WHERE rating=5)),
    'reviews',coalesce((SELECT jsonb_agg(public._review_json_c(page.id) ORDER BY page.created_at DESC,page.id DESC)
      FROM(SELECT rr.id,rr.created_at FROM public.reviews rr WHERE rr.product_id=p_product_id AND public._review_visible_c(rr.id)
        ORDER BY rr.created_at DESC,rr.id DESC LIMIT p_limit OFFSET p_offset) page),'[]')) INTO result
    FROM public.reviews r WHERE r.product_id=p_product_id
      AND (EXISTS(SELECT 1 FROM public.review_lifecycle s WHERE s.review_id=r.id AND public._review_purchase_valid_c(s.purchase_id))
        OR (r.is_verified_purchase AND r.verified_transaction_item_id IS NOT NULL)) AND public._review_visible_c(r.id);
  RETURN result;
END $review_c$;

CREATE FUNCTION public._review_merchant_c(p_shop uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE allowed boolean; BEGIN
  PERFORM p.id FROM public.profiles p WHERE p.id=auth.uid() AND p.role='merchant' FOR SHARE;
  allowed:=FOUND;
  PERFORM public._qr_auth_session_b();
  IF NOT allowed THEN RAISE EXCEPTION '[REVIEW_MERCHANT_REQUIRED]' USING ERRCODE='42501'; END IF;
  PERFORM id FROM public.shops WHERE id=p_shop AND owner_user_id=auth.uid() AND is_active FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_SHOP_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  RETURN public._review_subject_c(auth.uid());
END $review_c$;
CREATE FUNCTION public.read_merchant_reviews_v2(p_shop_id uuid,p_filter text DEFAULT 'all',p_limit integer DEFAULT 20,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE result jsonb; BEGIN
  PERFORM public._review_merchant_c(p_shop_id);
  IF p_filter IS NULL OR p_filter NOT IN ('all','unanswered','replied','reported') OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 50 OR p_offset IS NULL OR p_offset<0 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  WITH own AS (
    SELECT r.*,s.current_revision_id,s.withdrawn,s.moderation,s.purchase_id,reply.id reply_id,
      EXISTS(SELECT 1 FROM public.review_events e JOIN public.review_subject_keys k ON k.subject_id=e.subject_id
        WHERE e.review_id=r.id AND e.revision_id=s.current_revision_id AND e.event_kind='report' AND k.user_id=auth.uid()) reported,
      public._review_visible_c(r.id) visible
    FROM public.reviews r JOIN public.review_lifecycle s ON s.review_id=r.id
    LEFT JOIN public.review_replies reply ON reply.review_id=r.id
    WHERE s.shop_id=p_shop_id AND NOT s.account_deleted
  ), filtered AS (SELECT * FROM own WHERE p_filter='all' OR (p_filter='unanswered' AND reply_id IS NULL AND visible)
    OR (p_filter='replied' AND reply_id IS NOT NULL) OR (p_filter='reported' AND reported))
  SELECT jsonb_build_object('shop_id',p_shop_id,'scores',public.read_service_scores_v2(p_shop_id),
    'awaiting_reply_count',(SELECT count(*) FROM own WHERE reply_id IS NULL AND visible),
    'total',count(*),'reviews',coalesce((SELECT jsonb_agg(jsonb_build_object(
      'review_id',page.id,'revision_id',page.current_revision_id,'product_id',page.product_id,
      'product_name',(SELECT name FROM public.products WHERE id=page.product_id),
      'rating',CASE WHEN page.visible THEN page.rating END,'title',CASE WHEN page.visible THEN page.title END,
      'comment',CASE WHEN page.visible THEN page.comment END,'created_at',page.created_at,'updated_at',page.updated_at,
      'visibility',CASE WHEN page.withdrawn THEN 'withdrawn' WHEN NOT public._review_purchase_valid_c(page.purchase_id) THEN 'invalid' ELSE page.moderation END,
      'can_reply',page.visible AND page.reply_id IS NULL,'replied',page.reply_id IS NOT NULL,'reported',page.reported,
      'merchant_reply',public._review_json_c(page.id)->'merchant_reply') ORDER BY page.updated_at DESC,page.id DESC)
      FROM(SELECT * FROM filtered ORDER BY updated_at DESC,id DESC LIMIT p_limit OFFSET p_offset) page),'[]')) INTO result FROM filtered;
  RETURN result;
END $review_c$;

CREATE FUNCTION public.reply_to_review_v2(p_shop_id uuid,p_review_id uuid,p_revision_id uuid,p_request_id uuid,p_text text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE sid uuid; s public.review_lifecycle; prior public.review_requests; payload bytea; reply_id uuid; receipt jsonb; BEGIN
  sid:=public._review_merchant_c(p_shop_id);
  IF p_request_id IS NULL OR p_text IS NULL OR length(btrim(p_text)) NOT BETWEEN 1 AND 2000 THEN RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  -- Serialize merchant request IDs, including retries aimed at another root.
  PERFORM user_id FROM public.review_subject_keys WHERE user_id=auth.uid() FOR UPDATE;
  payload:=extensions.digest(jsonb_build_object('reply',p_review_id,'shop',p_shop_id,'revision',p_revision_id,'text',btrim(p_text))::text,'sha256');
  SELECT * INTO prior FROM public.review_requests WHERE subject_id=sid AND request_id=p_request_id;
  IF FOUND THEN
    IF prior.payload_hash<>payload THEN RAISE EXCEPTION '[REVIEW_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN prior.receipt; END IF;
  SELECT * INTO s FROM public.review_lifecycle WHERE review_id=p_review_id AND shop_id=p_shop_id;
  IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_SHOP_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  PERFORM id FROM public.verified_transactions WHERE id=s.purchase_id FOR UPDATE;
  PERFORM id FROM public.products WHERE id=s.product_id FOR UPDATE;
  SELECT * INTO s FROM public.review_lifecycle WHERE review_id=p_review_id FOR UPDATE;
  IF s.shop_id<>p_shop_id OR s.current_revision_id IS DISTINCT FROM p_revision_id OR NOT public._review_visible_c(p_review_id) THEN
    RAISE EXCEPTION '[REVIEW_CHANGED]' USING ERRCODE='40001'; END IF;
  IF EXISTS(SELECT 1 FROM public.review_replies WHERE review_id=p_review_id) THEN RAISE EXCEPTION '[REVIEW_ALREADY_REPLIED]' USING ERRCODE='23505'; END IF;
  INSERT INTO public.review_replies(review_id,revision_id,purchase_id,shop_id,subject_id,encrypted_body)
    VALUES(p_review_id,s.current_revision_id,s.purchase_id,p_shop_id,sid,public._review_encrypt_c(sid,jsonb_build_object('text',btrim(p_text)))) RETURNING id INTO reply_id;
  receipt:=jsonb_build_object('reply_id',reply_id,'review_id',p_review_id);
  INSERT INTO public.review_requests VALUES(sid,p_request_id,payload,receipt);
  RETURN receipt;
END $review_c$;

CREATE FUNCTION public.review_action_v2(p_review_id uuid,p_revision_id uuid,p_request_id uuid,p_action text,p_reason text,p_shop_id uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE sid uuid; s public.review_lifecycle; prior public.review_requests; payload bytea; eid uuid; receipt jsonb; BEGIN
  IF p_action='report' THEN sid:=public._review_merchant_c(p_shop_id);
  ELSE
    PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_ADMIN_REQUIRED]' USING ERRCODE='42501'; END IF;
    PERFORM public._qr_auth_session_b();
    sid:=public._review_subject_c(auth.uid());
  END IF;
  IF p_request_id IS NULL OR p_action IS NULL OR p_action NOT IN ('report','hide','restore','under_review','flag_abuse','clear_abuse','hide_reply')
    OR p_reason IS NULL OR length(btrim(p_reason)) NOT BETWEEN 1 AND 500 THEN RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM user_id FROM public.review_subject_keys WHERE user_id=auth.uid() FOR UPDATE;
  payload:=extensions.digest(jsonb_build_object('review',p_review_id,'revision',p_revision_id,'action',p_action,'reason',btrim(p_reason),'shop',p_shop_id)::text,'sha256');
  SELECT * INTO prior FROM public.review_requests WHERE subject_id=sid AND request_id=p_request_id;
  IF FOUND THEN
    IF prior.payload_hash<>payload THEN RAISE EXCEPTION '[REVIEW_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN prior.receipt; END IF;
  SELECT * INTO s FROM public.review_lifecycle WHERE review_id=p_review_id;
  IF NOT FOUND OR (p_action='report' AND s.shop_id IS DISTINCT FROM p_shop_id) THEN RAISE EXCEPTION '[REVIEW_SHOP_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  PERFORM id FROM public.products WHERE id=s.product_id FOR UPDATE;
  SELECT * INTO s FROM public.review_lifecycle WHERE review_id=p_review_id FOR UPDATE;
  IF s.current_revision_id IS DISTINCT FROM p_revision_id OR (p_action='report' AND s.shop_id IS DISTINCT FROM p_shop_id) THEN
    RAISE EXCEPTION '[REVIEW_CHANGED]' USING ERRCODE='40001'; END IF;
  IF p_action='report' AND EXISTS(SELECT 1 FROM public.review_events WHERE review_id=p_review_id AND revision_id=p_revision_id AND subject_id=sid AND event_kind='report') THEN
    RAISE EXCEPTION '[REVIEW_ALREADY_REPORTED]' USING ERRCODE='23505'; END IF;
  IF p_action='hide_reply' AND NOT EXISTS(SELECT 1 FROM public.review_replies WHERE review_id=p_review_id) THEN
    RAISE EXCEPTION '[REVIEW_REPLY_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
  INSERT INTO public.review_events(review_id,revision_id,subject_id,event_kind,encrypted_reason,request_id)
    VALUES(p_review_id,p_revision_id,sid,p_action,public._review_encrypt_c(sid,jsonb_build_object('reason',btrim(p_reason))),p_request_id) RETURNING id INTO eid;
  UPDATE public.review_lifecycle SET moderation=CASE p_action WHEN 'hide' THEN 'hidden' WHEN 'restore' THEN 'visible' WHEN 'under_review' THEN 'under_review' ELSE moderation END,
    abuse_flagged=CASE p_action WHEN 'flag_abuse' THEN true WHEN 'clear_abuse' THEN false ELSE abuse_flagged END WHERE review_id=p_review_id;
  PERFORM public._review_refresh_product_c(s.product_id);
  receipt:=jsonb_build_object('event_id',eid,'review_id',p_review_id,'action',p_action);
  INSERT INTO public.review_requests VALUES(sid,p_request_id,payload,receipt);
  RETURN receipt;
END $review_c$;

CREATE FUNCTION public._review_fraud_refresh_c() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE pid uuid; BEGIN
  FOR pid IN SELECT DISTINCT r.product_id FROM public.reviews r
    LEFT JOIN public.review_lifecycle s ON s.review_id=r.id
    LEFT JOIN public.verified_transaction_items i ON i.id=r.verified_transaction_item_id
    WHERE coalesce(s.purchase_id,i.verified_transaction_id)=NEW.purchase_id ORDER BY r.product_id LOOP
    PERFORM public._review_refresh_product_c(pid);
  END LOOP;
  PERFORM public.refresh_verified_shop_rating((SELECT shop_id FROM public.verified_transactions WHERE id=NEW.purchase_id));
  RETURN NEW;
END $review_c$;
CREATE TRIGGER review_fraud_refresh AFTER INSERT ON public.purchase_invalidations FOR EACH ROW EXECUTE FUNCTION public._review_fraud_refresh_c();
-- Keep B's authorization, idempotency and append-only evidence, while taking
-- the shop projection lock before B takes the purchase lock.
ALTER FUNCTION public.invalidate_purchase_v2(uuid,uuid,text) RENAME TO _invalidate_purchase_legacy_c;
CREATE OR REPLACE FUNCTION public.invalidate_purchase_v2(p_purchase_id uuid,p_request_id uuid,p_reason text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Admin required' USING ERRCODE='42501'; END IF;
  PERFORM public._qr_auth_session_b();
  PERFORM s.id FROM public.shops s JOIN public.verified_transactions t ON t.shop_id=s.id WHERE t.id=p_purchase_id FOR UPDATE OF s;
  RETURN public._invalidate_purchase_legacy_c(p_purchase_id,p_request_id,p_reason);
END $review_c$;
CREATE FUNCTION public._review_erase_account_c() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE sid uuid; pid uuid; shop uuid; BEGIN
  PERFORM id FROM public.profiles WHERE id=OLD.id FOR UPDATE;
  SELECT subject_id INTO sid FROM public.review_subject_keys WHERE user_id=OLD.id FOR UPDATE;
  IF sid IS NULL THEN RETURN OLD; END IF;
  FOR shop IN SELECT DISTINCT shop_id FROM public.service_evaluations WHERE subject_id=sid ORDER BY shop_id LOOP
    PERFORM id FROM public.shops WHERE id=shop FOR UPDATE;
  END LOOP;
  FOR pid IN SELECT DISTINCT product_id FROM public.review_lifecycle WHERE subject_id=sid ORDER BY product_id LOOP
    PERFORM id FROM public.products WHERE id=pid FOR UPDATE;
  END LOOP;
  INSERT INTO public.review_events(review_id,revision_id,subject_id,event_kind,request_id)
    SELECT review_id,current_revision_id,sid,'account_delete',gen_random_uuid() FROM public.review_lifecycle WHERE subject_id=sid AND NOT account_deleted;
  UPDATE public.review_lifecycle SET account_deleted=true,withdrawn=true WHERE subject_id=sid;
  -- Ciphertext and immutable facts remain; mapping/key and public plaintext do not.
  DELETE FROM public.review_subject_keys WHERE user_id=OLD.id;
  FOR shop IN SELECT DISTINCT shop_id FROM public.service_evaluations WHERE subject_id=sid ORDER BY shop_id LOOP
    PERFORM public.refresh_verified_shop_rating(shop);
  END LOOP;
  RETURN OLD;
END $review_c$;
CREATE TRIGGER review_erase_account BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION public._review_erase_account_c();
ALTER FUNCTION public.delete_current_customer_account() RENAME TO _delete_current_customer_account_legacy_c;
CREATE OR REPLACE FUNCTION public.delete_current_customer_account() RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  PERFORM public._review_customer_c();
  PERFORM public._delete_current_customer_account_legacy_c();
END $review_c$;

CREATE FUNCTION public._review_capability_refresh_c() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE target uuid; BEGIN
  IF NEW.enabled=OLD.enabled THEN RETURN NEW; END IF;
  FOR target IN SELECT id FROM public.shops ORDER BY id LOOP PERFORM public.refresh_verified_shop_rating(target); END LOOP;
  FOR target IN SELECT DISTINCT product_id FROM public.reviews ORDER BY product_id LOOP PERFORM public._review_refresh_product_c(target); END LOOP;
  RETURN NEW;
END $review_c$;
CREATE TRIGGER review_capability_refresh AFTER UPDATE ON public.review_protocol_config FOR EACH ROW EXECUTE FUNCTION public._review_capability_refresh_c();

-- Explicit bounded import. No client or service_role can invoke it; deployment
-- review must approve the legacy import policy before an operator runs it.
CREATE FUNCTION public._review_import_legacy_c(p_limit integer DEFAULT 200) RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$
DECLARE target record; imported integer:=0; BEGIN
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 1000 OR public._review_enabled_c() THEN
    RAISE EXCEPTION 'Import requires OFF capability and a bounded batch'; END IF;
  FOR target IN SELECT r.id,r.product_id FROM public.reviews r
    WHERE NOT EXISTS(SELECT 1 FROM public.review_lifecycle s WHERE s.review_id=r.id)
    ORDER BY r.product_id,r.id LIMIT p_limit LOOP
    PERFORM id FROM public.products WHERE id=target.product_id FOR UPDATE;
    PERFORM public._review_adopt_c(target.id); imported:=imported+1;
  END LOOP;
  RETURN imported;
END $review_c$;

CREATE FUNCTION public.read_review_audit_v2(p_review_id uuid,p_limit integer DEFAULT 50,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $review_c$ BEGIN
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REVIEW_ADMIN_REQUIRED]' USING ERRCODE='42501'; END IF;
  PERFORM public._qr_auth_session_b();
  IF p_review_id IS NULL OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 100 OR p_offset IS NULL OR p_offset<0 THEN
    RAISE EXCEPTION '[REVIEW_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  RETURN jsonb_build_object('review_id',p_review_id,
    'revisions',coalesce((SELECT jsonb_agg(to_jsonb(page)-'encrypted_body'-'subject_id'||
      jsonb_build_object('body',public._review_decrypt_c(page.subject_id,page.encrypted_body)))
      FROM(SELECT * FROM public.review_revisions WHERE review_id=p_review_id ORDER BY recorded_at DESC,id DESC LIMIT p_limit OFFSET p_offset) page),'[]'),
    'events',coalesce((SELECT jsonb_agg(to_jsonb(page)-'encrypted_reason'-'subject_id'||
      jsonb_build_object('reason',public._review_decrypt_c(page.subject_id,page.encrypted_reason)))
      FROM(SELECT * FROM public.review_events WHERE review_id=p_review_id ORDER BY recorded_at DESC,id DESC LIMIT p_limit OFFSET p_offset) page),'[]'));
END $review_c$;

-- All audit and lifecycle tables are RPC-only, including service_role.
ALTER TABLE public.review_protocol_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_subject_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_lifecycle ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.review_protocol_config FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_subject_keys FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_entitlements FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_lifecycle FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_revisions FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.service_evaluations FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_replies FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_events FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.review_requests FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER review_revisions_immutable BEFORE UPDATE OR DELETE ON public.review_revisions FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER service_evaluations_immutable BEFORE UPDATE OR DELETE ON public.service_evaluations FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER review_replies_immutable BEFORE UPDATE OR DELETE ON public.review_replies FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER review_events_immutable BEFORE UPDATE OR DELETE ON public.review_events FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER review_requests_immutable BEFORE UPDATE OR DELETE ON public.review_requests FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
REVOKE ALL ON FUNCTION public._review_subject_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_encrypt_c(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_decrypt_c(uuid,bytea) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_enabled_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_customer_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_purchase_valid_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_entitlement_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_visible_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_refresh_product_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.refresh_product_rating_after_review() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_adopt_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.review_capabilities_v2() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_service_scores_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_json_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.refresh_verified_shop_rating(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.submit_purchase_evaluation_v2(uuid,uuid,jsonb,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_purchase_evaluation_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_customer_service_evaluations_v2(uuid[]) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.submit_product_review(uuid,integer,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.submit_verified_shop_rating(uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.update_product_review(uuid,integer,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.delete_product_review(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.get_product_review_eligibility(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.get_product_reviews(uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_merchant_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_merchant_reviews_v2(uuid,text,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.reply_to_review_v2(uuid,uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.review_action_v2(uuid,uuid,uuid,text,text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_fraud_refresh_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.invalidate_purchase_v2(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_erase_account_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.delete_current_customer_account() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_capability_refresh_c() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._review_import_legacy_c(integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_review_audit_v2(uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._submit_product_review_legacy_c(uuid,integer,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._update_product_review_legacy_c(uuid,integer,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._delete_product_review_legacy_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._get_product_review_eligibility_legacy_c(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._submit_verified_shop_rating_legacy_c(uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._invalidate_purchase_legacy_c(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._delete_current_customer_account_legacy_c() FROM PUBLIC,anon,authenticated,service_role;
-- Public reads go through the minimized projection. Direct legacy table reads
-- would reveal withdrawn text, customer IDs and evidence anchors.
REVOKE SELECT ON public.reviews FROM anon,authenticated;
GRANT EXECUTE ON FUNCTION public.review_capabilities_v2(),public.read_service_scores_v2(uuid),public.get_product_reviews(uuid,integer,integer) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.submit_purchase_evaluation_v2(uuid,uuid,jsonb,jsonb),public.read_purchase_evaluation_v2(uuid),
  public.read_merchant_reviews_v2(uuid,text,integer,integer),public.reply_to_review_v2(uuid,uuid,uuid,uuid,text),
  public.review_action_v2(uuid,uuid,uuid,text,text,uuid),public.get_product_review_eligibility(uuid),
  public.submit_product_review(uuid,integer,text,text),public.update_product_review(uuid,integer,text,text),
  public.delete_product_review(uuid),public.submit_verified_shop_rating(uuid,integer),
  public.invalidate_purchase_v2(uuid,uuid,text),public.read_review_audit_v2(uuid,integer,integer),public.delete_current_customer_account(),
  public.read_customer_service_evaluations_v2(uuid[]) TO authenticated;

COMMIT;
