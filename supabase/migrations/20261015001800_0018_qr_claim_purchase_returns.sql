-- Slice B. Additive local implementation; enablement defaults OFF.
-- Never apply remotely without an approved schema/auth fingerprint and authority.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regprocedure('public.merchant_operations_read_v1(uuid,integer,integer)') IS NULL
     OR to_regprocedure('public.confirm_qr_session(text)') IS NULL
     OR to_regclass('auth.sessions') IS NULL
     OR to_regprocedure('auth.jwt()') IS NULL THEN
    RAISE EXCEPTION '0018 requires 0017, canonical QR and managed Auth sessions';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
      WHERE table_schema='auth' AND table_name='sessions' AND column_name='not_after') THEN
    RAISE EXCEPTION '0018 requires verified Auth session expiry provenance';
  END IF;
END $preflight$;

CREATE TABLE public.qr_protocol_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false,
  completion_seconds integer NOT NULL DEFAULT 600 CHECK(completion_seconds BETWEEN 120 AND 600),
  code_secret bytea NOT NULL DEFAULT extensions.gen_random_bytes(32)
);
INSERT INTO public.qr_protocol_config(singleton) VALUES(true);
CREATE TABLE public.merchant_device_sessions (
  auth_session_id uuid PRIMARY KEY,
  user_id uuid NOT NULL,
  installation_id uuid NOT NULL,
  registered_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  revoked_at timestamptz
);
CREATE INDEX merchant_device_sessions_user ON public.merchant_device_sessions(user_id);
CREATE TABLE public.qr_session_protocols (
  qr_session_id uuid PRIMARY KEY REFERENCES public.qr_sessions(id) ON DELETE CASCADE,
  shop_id uuid NOT NULL,
  code_salt integer NOT NULL DEFAULT 0,
  code_digest bytea NOT NULL,
  alias_active boolean NOT NULL DEFAULT true,
  scan_expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE UNIQUE INDEX qr_live_code_scope ON public.qr_session_protocols(shop_id,code_digest) WHERE alias_active;
CREATE TABLE public.qr_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  qr_session_id uuid NOT NULL UNIQUE REFERENCES public.qr_sessions(id) ON DELETE CASCADE,
  shop_id uuid NOT NULL,
  merchant_user_id uuid NOT NULL,
  auth_session_id uuid NOT NULL,
  installation_id uuid NOT NULL,
  request_id uuid NOT NULL,
  credential_digest bytea NOT NULL,
  claimed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  completion_expires_at timestamptz NOT NULL,
  UNIQUE(merchant_user_id,request_id),
  CHECK(completion_expires_at > claimed_at)
);
CREATE TABLE public.qr_attempt_limits (
  scope text NOT NULL,
  window_start timestamptz NOT NULL,
  attempts integer NOT NULL CHECK(attempts>0),
  PRIMARY KEY(scope,window_start)
);
CREATE TABLE public.purchase_terms (
  purchase_id uuid PRIMARY KEY REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  quoted_minor bigint NOT NULL CHECK(quoted_minor>=0),
  merchant_discount_minor bigint NOT NULL DEFAULT 0 CHECK(merchant_discount_minor=0),
  final_sale_minor bigint NOT NULL CHECK(final_sale_minor=quoted_minor),
  ev_coupon_minor bigint NOT NULL DEFAULT 0 CHECK(ev_coupon_minor=0),
  customer_payment_minor bigint GENERATED ALWAYS AS(final_sale_minor-ev_coupon_minor) STORED,
  policy_version text NOT NULL DEFAULT 'quote_only_b_v1' CHECK(policy_version='quote_only_b_v1'),
  return_policy_version text NOT NULL DEFAULT 'unspecified' CHECK(return_policy_version='unspecified'),
  voluntary_return_seconds bigint CHECK(voluntary_return_seconds IS NULL),
  allocation_snapshot jsonb NOT NULL CHECK(jsonb_typeof(allocation_snapshot)='array'),
  allocation_hash bytea NOT NULL,
  finalizing_user_id uuid NOT NULL,
  finalizing_auth_session_id uuid NOT NULL,
  finalizing_installation_id uuid NOT NULL,
  claim_id uuid NOT NULL UNIQUE,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.commerce_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  event_kind text NOT NULL CHECK(event_kind IN ('purchase_confirmed','purchase_returned','return_corrected','purchase_invalidated')),
  source_id uuid NOT NULL,
  schema_version integer NOT NULL DEFAULT 1 CHECK(schema_version=1),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(event_kind,source_id)
);
CREATE TABLE public.purchase_returns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  return_kind text NOT NULL CHECK(return_kind IN ('genuine','administrative_correction')),
  actor_user_id uuid NOT NULL,
  actor_auth_session_id uuid NOT NULL,
  reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 500),
  request_id uuid NOT NULL,
  request_payload jsonb NOT NULL,
  reverses_return_id uuid UNIQUE REFERENCES public.purchase_returns(id) ON DELETE RESTRICT,
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(actor_user_id,request_id),
  CHECK((return_kind='administrative_correction')=(reverses_return_id IS NOT NULL))
);
CREATE INDEX purchase_returns_purchase ON public.purchase_returns(purchase_id);
CREATE TABLE public.purchase_return_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  return_id uuid NOT NULL REFERENCES public.purchase_returns(id) ON DELETE RESTRICT,
  purchase_item_id uuid NOT NULL REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK(quantity>0),
  sale_return_minor bigint NOT NULL CHECK(sale_return_minor>=0),
  ev_coupon_return_minor bigint NOT NULL DEFAULT 0 CHECK(ev_coupon_return_minor=0),
  UNIQUE(return_id,purchase_item_id)
);
CREATE TABLE public.purchase_invalidations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL UNIQUE REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  actor_user_id uuid NOT NULL,
  actor_auth_session_id uuid NOT NULL,
  reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 500),
  request_id uuid NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(actor_user_id,request_id)
);

CREATE FUNCTION public._commerce_immutable_b() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $body$ BEGIN
  RAISE EXCEPTION 'Commerce evidence is append-only' USING ERRCODE='55000';
END $body$;
DO $body$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['purchase_terms','commerce_events','purchase_returns',
      'purchase_return_items','purchase_invalidations'] LOOP
    EXECUTE format('CREATE TRIGGER immutable_evidence BEFORE UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b()',t);
  END LOOP;
END $body$;
-- Existing account deletion preserves these commercial snapshots already.
CREATE TRIGGER immutable_purchase_header BEFORE UPDATE OR DELETE ON public.verified_transactions
FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER immutable_purchase_item_delete BEFORE DELETE ON public.verified_transaction_items
FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();

CREATE FUNCTION public._qr_auth_session_b() RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE sid uuid; BEGIN
  IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE='28000'; END IF;
  sid := (auth.jwt()->>'session_id')::uuid;
  PERFORM s.id FROM auth.sessions s WHERE s.id=sid AND s.user_id=auth.uid()
    AND (s.not_after IS NULL OR s.not_after>clock_timestamp()) FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Live authentication session required' USING ERRCODE='28000'; END IF;
  RETURN sid;
END $body$;

CREATE FUNCTION public._qr_device_b(p_shop_id uuid,p_installation_id uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE sid uuid; d public.merchant_device_sessions; BEGIN
  IF p_installation_id IS NULL THEN RAISE EXCEPTION 'Installation required'; END IF;
  -- Serialize registrations for the principal; installation IDs cannot bypass cap.
  PERFORM pg_advisory_xact_lock(hashtextextended('merchant-session:'||auth.uid()::text,0));
  sid:=public._qr_auth_session_b();
  PERFORM p.id FROM public.profiles p WHERE p.id=auth.uid() AND p.role='merchant' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Merchant access required' USING ERRCODE='42501'; END IF;
  PERFORM s.id FROM public.shops s WHERE s.id=p_shop_id AND s.owner_user_id=auth.uid() AND s.is_active FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Merchant access required' USING ERRCODE='42501'; END IF;
  SELECT * INTO d FROM public.merchant_device_sessions WHERE auth_session_id=sid;
  IF FOUND THEN
    IF d.user_id<>auth.uid() OR d.installation_id<>p_installation_id OR d.revoked_at IS NOT NULL THEN
      RAISE EXCEPTION 'Device session revoked or mismatched' USING ERRCODE='42501'; END IF;
  ELSE
    IF (SELECT count(*) FROM public.merchant_device_sessions x JOIN auth.sessions s ON s.id=x.auth_session_id
      WHERE x.user_id=auth.uid() AND s.user_id=auth.uid() AND x.revoked_at IS NULL
      AND (s.not_after IS NULL OR s.not_after>clock_timestamp()))>=2 THEN
      RAISE EXCEPTION 'Merchant device session limit reached' USING ERRCODE='54000'; END IF;
    INSERT INTO public.merchant_device_sessions(auth_session_id,user_id,installation_id) VALUES(sid,auth.uid(),p_installation_id);
  END IF;
  RETURN sid;
END $body$;

CREATE FUNCTION public.revoke_merchant_device_session_v2(p_auth_session_id uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  PERFORM public._qr_auth_session_b();
  PERFORM pg_advisory_xact_lock(hashtextextended('merchant-session:'||auth.uid()::text,0));
  UPDATE public.merchant_device_sessions SET revoked_at=COALESCE(revoked_at,clock_timestamp())
  WHERE auth_session_id=p_auth_session_id AND user_id=auth.uid();
END $body$;

CREATE FUNCTION public._qr_digest_b(p_value text) RETURNS bytea
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT extensions.hmac(convert_to(p_value,'UTF8'),code_secret,'sha256') FROM public.qr_protocol_config WHERE singleton
$body$;
CREATE FUNCTION public._qr_code_b(p_id uuid,p_salt integer) RETURNS text
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT lpad(((('x'||substr(encode(public._qr_digest_b('code:'||p_id::text||':'||p_salt::text),'hex'),1,8))::bit(32)::bigint)%1000000)::text,6,'0')
$body$;
CREATE FUNCTION public.qr_capabilities_v2() RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT jsonb_build_object('protocol_version',2,'enabled',enabled,'scan_seconds',120,
    'completion_seconds',completion_seconds,'max_device_sessions',2,'economics_enabled',false)
  FROM public.qr_protocol_config WHERE singleton AND auth.uid() IS NOT NULL
$body$;

-- Keep original bodies/return types. Guard before legacy functions can expire v2.
ALTER FUNCTION public.create_qr_session(uuid) RENAME TO _create_qr_session_legacy_b;
ALTER FUNCTION public.get_qr_session_for_verification(text) RENAME TO _get_qr_verification_legacy_b;
ALTER FUNCTION public.confirm_qr_session(text) RENAME TO _confirm_qr_session_legacy_b;
CREATE OR REPLACE FUNCTION public.create_qr_session(p_cart_id uuid) RETURNS public.qr_sessions
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  PERFORM id FROM public.carts WHERE id=p_cart_id AND user_id=auth.uid() FOR UPDATE;
  IF EXISTS(SELECT 1 FROM public.qr_sessions q JOIN public.qr_session_protocols p ON p.qr_session_id=q.id
      WHERE q.cart_id=p_cart_id AND q.user_id=auth.uid() AND q.status='active') THEN
    RAISE EXCEPTION 'QR_V2_REQUIRED' USING ERRCODE='55000'; END IF;
  RETURN public._create_qr_session_legacy_b(p_cart_id);
END $body$;
CREATE OR REPLACE FUNCTION public.get_qr_session_for_verification(p_session_token text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  IF EXISTS(SELECT 1 FROM public.qr_sessions q JOIN public.qr_session_protocols p ON p.qr_session_id=q.id
      WHERE q.session_token=p_session_token) THEN RAISE EXCEPTION 'QR_V2_REQUIRED' USING ERRCODE='55000'; END IF;
  RETURN public._get_qr_verification_legacy_b(p_session_token);
END $body$;
CREATE OR REPLACE FUNCTION public.confirm_qr_session(p_session_token text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  IF EXISTS(SELECT 1 FROM public.qr_sessions q JOIN public.qr_session_protocols p ON p.qr_session_id=q.id
      WHERE q.session_token=p_session_token) THEN RAISE EXCEPTION 'QR_V2_REQUIRED' USING ERRCODE='55000'; END IF;
  RETURN public._confirm_qr_session_legacy_b(p_session_token);
END $body$;

CREATE FUNCTION public._qr_customer_payload_b(p_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT to_jsonb(q)||jsonb_build_object('protocol_version',2,'scan_expires_at',p.scan_expires_at,
    'purchase_id',(SELECT id FROM public.verified_transactions v WHERE v.source_qr_session_id=q.id),
    'completion_expires_at',c.completion_expires_at,'manual_code',
      CASE WHEN q.status='active' AND c.id IS NULL AND p.scan_expires_at>clock_timestamp()
        THEN public._qr_code_b(q.id,p.code_salt) END,
    'status',CASE WHEN q.status<>'active' THEN q.status WHEN c.id IS NOT NULL AND c.completion_expires_at>clock_timestamp() THEN 'claimed'
      WHEN c.id IS NULL AND p.scan_expires_at>clock_timestamp() THEN 'active' ELSE 'expired' END)
  FROM public.qr_sessions q JOIN public.qr_session_protocols p ON p.qr_session_id=q.id
  LEFT JOIN public.qr_claims c ON c.qr_session_id=q.id WHERE q.id=p_id AND q.user_id=auth.uid()
$body$;
CREATE FUNCTION public.create_qr_session_v2(p_cart_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE q public.qr_sessions; salt integer:=0; code_hash bytea; BEGIN
  PERFORM public._qr_auth_session_b();
  PERFORM id FROM public.carts WHERE id=p_cart_id AND user_id=auth.uid() AND status='active' FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Active cart not found'; END IF;
  SELECT * INTO q FROM public.qr_sessions WHERE cart_id=p_cart_id AND status='active' FOR UPDATE;
  IF FOUND THEN
    IF EXISTS(SELECT 1 FROM public.qr_session_protocols WHERE qr_session_id=q.id) THEN
      IF (public._qr_customer_payload_b(q.id)->>'status') IN ('active','claimed') THEN RETURN public._qr_customer_payload_b(q.id); END IF;
      UPDATE public.qr_sessions SET status='expired' WHERE id=q.id;
    ELSIF q.expires_at>clock_timestamp() THEN RAISE EXCEPTION 'QR_LEGACY_IN_PROGRESS';
    END IF;
  END IF;
  IF NOT (SELECT enabled FROM public.qr_protocol_config WHERE singleton) THEN RAISE EXCEPTION 'QR_V2_DISABLED'; END IF;
  q:=public._create_qr_session_legacy_b(p_cart_id);
  IF EXISTS(SELECT 1 FROM public.qr_session_items WHERE qr_session_id=q.id AND unit_price*100<>trunc(unit_price*100)) THEN
    RAISE EXCEPTION 'Quote must use exact minor units'; END IF;
  -- Active aliases serialize within a shop and are reclaimed only at terminal/expiry.
  PERFORM pg_advisory_xact_lock(hashtextextended('qr-alias:'||q.shop_id::text,0));
  UPDATE public.qr_session_protocols p SET alias_active=false FROM public.qr_sessions s
    WHERE s.id=p.qr_session_id AND p.shop_id=q.shop_id AND p.alias_active
    AND (s.status<>'active' OR COALESCE((SELECT completion_expires_at FROM public.qr_claims c WHERE c.qr_session_id=s.id),p.scan_expires_at)<=clock_timestamp());
  LOOP
    code_hash:=public._qr_digest_b('lookup:'||q.shop_id::text||':'||public._qr_code_b(q.id,salt));
    EXIT WHEN NOT EXISTS(SELECT 1 FROM public.qr_session_protocols WHERE shop_id=q.shop_id AND code_digest=code_hash AND alias_active);
    salt:=salt+1; IF salt>100 THEN RAISE EXCEPTION 'Manual code capacity unavailable'; END IF;
  END LOOP;
  INSERT INTO public.qr_session_protocols(qr_session_id,shop_id,code_salt,code_digest,scan_expires_at)
    VALUES(q.id,q.shop_id,salt,code_hash,q.expires_at);
  RETURN public._qr_customer_payload_b(q.id);
END $body$;
CREATE FUNCTION public.get_qr_session_status_v2(p_session_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  PERFORM public._qr_auth_session_b();
  RETURN public._qr_customer_payload_b(p_session_id);
END $body$;

CREATE FUNCTION public._qr_quote_valid_b(p_id uuid) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE q public.qr_sessions; BEGIN
  SELECT * INTO STRICT q FROM public.qr_sessions WHERE id=p_id;
  PERFORM l.id FROM public.qr_session_items i JOIN public.shop_products l ON l.id=i.shop_product_id
    JOIN public.products p ON p.id=l.product_id WHERE i.qr_session_id=p_id ORDER BY l.id FOR SHARE OF l,p;
  RETURN EXISTS(SELECT 1 FROM public.carts c WHERE c.id=q.cart_id AND c.user_id=q.user_id AND c.shop_id=q.shop_id AND c.status='active')
    AND q.item_count>0 AND q.total_amount*100=trunc(q.total_amount*100)
    AND q.item_count=(SELECT sum(quantity) FROM public.qr_session_items WHERE qr_session_id=p_id)
    AND q.total_amount=(SELECT sum(line_total) FROM public.qr_session_items WHERE qr_session_id=p_id)
    AND (SELECT count(*) FROM public.cart_items_v2 WHERE cart_id=q.cart_id)=(SELECT count(*) FROM public.qr_session_items WHERE qr_session_id=p_id)
    AND NOT EXISTS(SELECT 1 FROM public.qr_session_items i
      LEFT JOIN public.cart_items_v2 ci ON ci.cart_id=q.cart_id AND ci.shop_product_id=i.shop_product_id
      LEFT JOIN public.shop_products l ON l.id=i.shop_product_id LEFT JOIN public.products p ON p.id=i.product_id
      WHERE i.qr_session_id=p_id AND (ci.quantity IS DISTINCT FROM i.quantity OR l.shop_id IS DISTINCT FROM q.shop_id
        OR l.product_id IS DISTINCT FROM i.product_id OR l.price IS DISTINCT FROM i.unit_price
        OR l.is_active IS NOT TRUE OR l.is_available IS NOT TRUE OR p.is_active IS NOT TRUE
        OR i.unit_price*100<>trunc(i.unit_price*100)));
END $body$;

CREATE FUNCTION public._qr_verification_payload_b(p_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT jsonb_build_object('protocol_version',2,'session_id',q.id,'session_token',q.session_token,
    'claim_id',c.id,'status',CASE WHEN q.status<>'active' THEN q.status
      WHEN c.completion_expires_at<=clock_timestamp() THEN 'expired' ELSE 'claimed' END,
    'expires_at',q.expires_at,'scan_expires_at',p.scan_expires_at,'completion_expires_at',c.completion_expires_at,
    'used_at',q.used_at,'shop_id',q.shop_id,'shop_name',s.name,'item_count',q.item_count,'total_amount',q.total_amount,
    'purchase_id',(SELECT id FROM public.verified_transactions v WHERE v.source_qr_session_id=q.id),
    'items',(SELECT jsonb_agg(jsonb_build_object('id',i.id,'shop_product_id',i.shop_product_id,'product_id',i.product_id,
      'product_name',i.product_name,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total) ORDER BY i.id)
      FROM public.qr_session_items i WHERE i.qr_session_id=q.id))
  FROM public.qr_sessions q JOIN public.qr_session_protocols p ON p.qr_session_id=q.id
    JOIN public.qr_claims c ON c.qr_session_id=q.id JOIN public.shops s ON s.id=q.shop_id WHERE q.id=p_id
$body$;

CREATE FUNCTION public._qr_attempt_b(p_scope text,p_window timestamptz,p_max integer) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ DECLARE n integer; BEGIN
  INSERT INTO public.qr_attempt_limits(scope,window_start,attempts) VALUES(p_scope,p_window,1)
    ON CONFLICT(scope,window_start) DO UPDATE SET attempts=LEAST(public.qr_attempt_limits.attempts+1,p_max+1)
    RETURNING attempts INTO n;
  RETURN n<=p_max;
END $body$;

CREATE FUNCTION public.claim_existing_qr_v2(p_shop_id uuid,p_installation_id uuid,p_request_id uuid,
  p_session_token text DEFAULT NULL,p_manual_code text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE sid uuid; q public.qr_sessions; c public.qr_claims; qid uuid; cartid uuid; fingerprint bytea;
  minute_ok boolean; hour_ok boolean; BEGIN
  sid:=public._qr_device_b(p_shop_id,p_installation_id);
  IF p_request_id IS NULL OR (p_session_token IS NULL)=(p_manual_code IS NULL)
    OR (p_manual_code IS NOT NULL AND p_manual_code !~ '^[0-9]{6}$')
    OR (p_session_token IS NOT NULL AND length(p_session_token) NOT BETWEEN 1 AND 256) THEN
    RAISE EXCEPTION 'Invalid claim request'; END IF;
  fingerprint:=public._qr_digest_b(COALESCE('scan:'||p_session_token,'manual:'||p_manual_code));
  SELECT * INTO c FROM public.qr_claims WHERE merchant_user_id=auth.uid() AND request_id=p_request_id;
  IF FOUND THEN
    IF c.shop_id<>p_shop_id OR c.auth_session_id<>sid OR c.installation_id<>p_installation_id OR c.credential_digest<>fingerprint THEN
      RAISE EXCEPTION 'Claim request mismatch' USING ERRCODE='42501'; END IF;
    RETURN public._qr_verification_payload_b(c.qr_session_id);
  END IF;
  IF NOT (SELECT enabled FROM public.qr_protocol_config WHERE singleton) THEN RETURN jsonb_build_object('error','QR_V2_DISABLED'); END IF;
  IF EXISTS(SELECT 1 FROM public.qr_claims x JOIN public.qr_sessions s ON s.id=x.qr_session_id
    WHERE x.auth_session_id=sid AND s.status='active' AND x.completion_expires_at>clock_timestamp()
    AND NOT (p_session_token IS NOT NULL AND s.session_token=p_session_token)
    AND NOT (p_manual_code IS NOT NULL AND EXISTS(SELECT 1 FROM public.qr_session_protocols p WHERE p.qr_session_id=s.id
      AND p.code_digest=public._qr_digest_b('lookup:'||p_shop_id::text||':'||p_manual_code)))) THEN
    RETURN jsonb_build_object('error','QR_OTHER_CLAIM_OPEN'); END IF;
  minute_ok:=public._qr_attempt_b('session:'||sid::text,date_trunc('minute',clock_timestamp()),5);
  hour_ok:=public._qr_attempt_b('shop:'||p_shop_id::text,date_trunc('hour',clock_timestamp()),30);
  IF NOT minute_ok OR NOT hour_ok THEN RETURN jsonb_build_object('error','QR_RATE_LIMITED'); END IF;
  -- All failures after the debit are values, not exceptions rolling it back.
  BEGIN
    SELECT s.id,s.cart_id INTO qid,cartid FROM public.qr_sessions s
      JOIN public.qr_session_protocols p ON p.qr_session_id=s.id
      WHERE s.shop_id=p_shop_id AND ((p_session_token IS NOT NULL AND s.session_token=p_session_token)
        OR (p_manual_code IS NOT NULL AND p.alias_active AND p.code_digest=public._qr_digest_b('lookup:'||p_shop_id::text||':'||p_manual_code)));
    IF qid IS NULL THEN RETURN jsonb_build_object('error','QR_UNAVAILABLE'); END IF;
    PERFORM id FROM public.carts WHERE id=cartid FOR UPDATE;
    SELECT * INTO q FROM public.qr_sessions WHERE id=qid FOR UPDATE;
    SELECT * INTO c FROM public.qr_claims WHERE qr_session_id=qid;
    IF FOUND THEN
      IF c.auth_session_id=sid AND c.installation_id=p_installation_id AND c.merchant_user_id=auth.uid() THEN
        RETURN public._qr_verification_payload_b(qid); END IF;
      RETURN jsonb_build_object('error','QR_CLAIMED_ELSEWHERE');
    END IF;
    IF q.status<>'active' OR q.expires_at<=clock_timestamp() THEN RETURN jsonb_build_object('error','QR_EXPIRED'); END IF;
    IF public._qr_quote_valid_b(qid) IS NOT TRUE THEN
      UPDATE public.qr_sessions SET status='cancelled' WHERE id=qid;
      RETURN jsonb_build_object('error','QR_QUOTE_CHANGED'); END IF;
    IF q.expires_at<=clock_timestamp() THEN RETURN jsonb_build_object('error','QR_EXPIRED'); END IF;
    INSERT INTO public.qr_claims(qr_session_id,shop_id,merchant_user_id,auth_session_id,installation_id,request_id,
      credential_digest,completion_expires_at) VALUES(qid,p_shop_id,auth.uid(),sid,p_installation_id,p_request_id,fingerprint,
        clock_timestamp()+make_interval(secs=>(SELECT completion_seconds FROM public.qr_protocol_config WHERE singleton)));
    RETURN public._qr_verification_payload_b(qid);
  EXCEPTION WHEN OTHERS THEN RETURN jsonb_build_object('error','QR_UNAVAILABLE'); END;
END $body$;
CREATE FUNCTION public.recover_merchant_claim_v2(p_shop_id uuid,p_installation_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ DECLARE sid uuid; qid uuid; BEGIN
  sid:=public._qr_device_b(p_shop_id,p_installation_id);
  SELECT c.qr_session_id INTO qid FROM public.qr_claims c WHERE c.shop_id=p_shop_id AND c.auth_session_id=sid
    AND c.merchant_user_id=auth.uid() AND c.installation_id=p_installation_id ORDER BY c.claimed_at DESC,c.id DESC LIMIT 1;
  RETURN public._qr_verification_payload_b(qid);
END $body$;

CREATE FUNCTION public._qr_owned_claim_b(p_claim_id uuid,p_installation_id uuid) RETURNS public.qr_claims
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE c public.qr_claims; sid uuid; BEGIN
  SELECT * INTO c FROM public.qr_claims WHERE id=p_claim_id AND merchant_user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Claim not found' USING ERRCODE='42501'; END IF;
  sid:=public._qr_device_b(c.shop_id,p_installation_id);
  IF c.auth_session_id<>sid OR c.installation_id<>p_installation_id THEN
    RAISE EXCEPTION 'Claim belongs to another device session' USING ERRCODE='42501'; END IF;
  RETURN c;
END $body$;
CREATE FUNCTION public.reconcile_claim_v2(p_claim_id uuid,p_installation_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ DECLARE c public.qr_claims; BEGIN
  c:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  RETURN public._qr_verification_payload_b(c.qr_session_id);
END $body$;
CREATE FUNCTION public.cancel_claim_v2(p_claim_id uuid,p_installation_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ DECLARE c public.qr_claims; BEGIN
  c:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  PERFORM x.id FROM public.carts x JOIN public.qr_sessions q ON q.cart_id=x.id WHERE q.id=c.qr_session_id FOR UPDATE OF x;
  UPDATE public.qr_sessions SET status='cancelled' WHERE id=c.qr_session_id AND status='active';
  RETURN public._qr_verification_payload_b(c.qr_session_id);
END $body$;

CREATE FUNCTION public.complete_existing_qr_v2(p_claim_id uuid,p_installation_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE c public.qr_claims; q public.qr_sessions; pid uuid; stamp timestamptz; allocation jsonb; BEGIN
  c:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  PERFORM x.id FROM public.carts x JOIN public.qr_sessions s ON s.cart_id=x.id WHERE s.id=c.qr_session_id FOR UPDATE OF x;
  SELECT * INTO q FROM public.qr_sessions WHERE id=c.qr_session_id FOR UPDATE;
  IF q.status='used' THEN RETURN public._qr_verification_payload_b(q.id); END IF;
  -- Disabling prevents new claims, but already claimed attempts can complete/cancel.
  IF q.status<>'active' THEN RETURN public._qr_verification_payload_b(q.id); END IF;
  IF c.completion_expires_at<=clock_timestamp() THEN
    UPDATE public.qr_sessions SET status='expired' WHERE id=q.id;
    RETURN public._qr_verification_payload_b(q.id); END IF;
  IF public._qr_quote_valid_b(q.id) IS NOT TRUE THEN
    UPDATE public.qr_sessions SET status='cancelled' WHERE id=q.id;
    RETURN public._qr_verification_payload_b(q.id); END IF;
  stamp:=clock_timestamp();
  IF c.completion_expires_at<=stamp THEN
    UPDATE public.qr_sessions SET status='expired' WHERE id=q.id;
    RETURN public._qr_verification_payload_b(q.id); END IF;
  INSERT INTO public.verified_transactions(source_qr_session_id,customer_user_id,shop_id,shop_name,
    confirmed_by_user_id,item_count,total_amount,confirmed_at)
    SELECT q.id,q.user_id,q.shop_id,s.name,auth.uid(),q.item_count,q.total_amount,stamp FROM public.shops s WHERE s.id=q.shop_id
    RETURNING id INTO pid;
  INSERT INTO public.verified_transaction_items(verified_transaction_id,shop_product_id,product_id,product_name,quantity,unit_price,line_total)
    SELECT pid,i.shop_product_id,i.product_id,i.product_name,i.quantity,i.unit_price,i.line_total
    FROM public.qr_session_items i WHERE i.qr_session_id=q.id ORDER BY i.id;
  SELECT jsonb_agg(jsonb_build_object('purchase_item_id',id,'quantity',quantity,'sale_minor',(line_total*100)::bigint,'coupon_minor',0) ORDER BY id)
    INTO allocation FROM public.verified_transaction_items WHERE verified_transaction_id=pid;
  INSERT INTO public.purchase_terms(purchase_id,quoted_minor,final_sale_minor,allocation_snapshot,allocation_hash,
    finalizing_user_id,finalizing_auth_session_id,finalizing_installation_id,claim_id)
    VALUES(pid,(q.total_amount*100)::bigint,(q.total_amount*100)::bigint,allocation,extensions.digest(convert_to(allocation::text,'UTF8'),'sha256'),
      auth.uid(),c.auth_session_id,c.installation_id,c.id);
  INSERT INTO public.commerce_events(purchase_id,event_kind,source_id) VALUES(pid,'purchase_confirmed',q.id);
  UPDATE public.qr_sessions SET status='used',used_at=stamp,confirmed_by_user_id=auth.uid() WHERE id=q.id;
  UPDATE public.carts SET status='checked_out' WHERE id=q.cart_id AND status='active';
  RETURN public._qr_verification_payload_b(q.id);
END $body$;

CREATE FUNCTION public._purchase_read_b(p_purchase_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT to_jsonb(v)||jsonb_build_object('terms_classification',CASE WHEN t.purchase_id IS NULL THEN 'legacy_unclassified' ELSE 'quote_only_b_v1' END,
    'final_sale_minor',t.final_sale_minor,'ev_coupon_minor',t.ev_coupon_minor,'customer_payment_minor',t.customer_payment_minor,
    'return_policy_version',t.return_policy_version,'invalidated',EXISTS(SELECT 1 FROM public.purchase_invalidations z WHERE z.purchase_id=v.id),
    'items',(SELECT jsonb_agg(to_jsonb(i)||jsonb_build_object('returned_quantity',COALESCE((
      SELECT sum(CASE WHEN r.return_kind='genuine' THEN ri.quantity ELSE -ri.quantity END)
      FROM public.purchase_return_items ri JOIN public.purchase_returns r ON r.id=ri.return_id WHERE ri.purchase_item_id=i.id),0)) ORDER BY i.id)
      FROM public.verified_transaction_items i WHERE i.verified_transaction_id=v.id),
    'returns',COALESCE((SELECT jsonb_agg(jsonb_build_object('id',r.id,'return_kind',r.return_kind,'occurred_at',r.occurred_at,
      'reverses_return_id',r.reverses_return_id,'refund_executed',false,
      'items',(SELECT jsonb_agg(jsonb_build_object('purchase_item_id',i.purchase_item_id,'quantity',i.quantity,'sale_return_minor',i.sale_return_minor)
        ORDER BY i.purchase_item_id) FROM public.purchase_return_items i WHERE i.return_id=r.id)) ORDER BY r.occurred_at,r.id)
      FROM public.purchase_returns r WHERE r.purchase_id=v.id),'[]'::jsonb))
  - 'customer_user_id' - 'confirmed_by_user_id'
  FROM public.verified_transactions v LEFT JOIN public.purchase_terms t ON t.purchase_id=v.id WHERE v.id=p_purchase_id
$body$;
-- Preserve legacy visibility, but v2 evidence never remains readable merely
-- because a user used to be the confirming merchant. Security-definer predicate
-- avoids exposing the private terms table through a client RLS join.
CREATE FUNCTION public._purchase_participant_b(p_id uuid,p_customer uuid,p_confirmer uuid,p_shop uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $body$
  SELECT auth.uid()=p_customer OR CASE WHEN EXISTS(SELECT 1 FROM public.purchase_terms WHERE purchase_id=p_id)
    THEN public._catalog_own_shop_v1(p_shop) ELSE auth.uid()=p_confirmer END
$body$;
DROP POLICY verified_transactions_select_participant ON public.verified_transactions;
CREATE POLICY verified_transactions_select_participant_b ON public.verified_transactions FOR SELECT TO authenticated
  USING(public._purchase_participant_b(id,customer_user_id,confirmed_by_user_id,shop_id));
-- Existing item policy derives visibility through the now-guarded parent row.
CREATE FUNCTION public.read_purchase_evidence_v2(p_purchase_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ BEGIN
  PERFORM public._qr_auth_session_b();
  IF NOT EXISTS(SELECT 1 FROM public.verified_transactions v WHERE v.id=p_purchase_id AND
    (v.customer_user_id=auth.uid() OR public._catalog_own_shop_v1(v.shop_id))) THEN
    RAISE EXCEPTION 'Purchase access denied' USING ERRCODE='42501'; END IF;
  RETURN public._purchase_read_b(p_purchase_id);
END $body$;
CREATE FUNCTION public.list_merchant_purchases_v2(p_shop_id uuid,p_offset integer DEFAULT 0,p_limit integer DEFAULT 20) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$ DECLARE result jsonb; BEGIN
  PERFORM public._qr_auth_session_b();
  IF public._catalog_own_shop_v1(p_shop_id) IS NOT TRUE THEN RAISE EXCEPTION 'Purchase access denied' USING ERRCODE='42501'; END IF;
  IF p_offset IS NULL OR p_offset<0 OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 50 THEN RAISE EXCEPTION 'Invalid pagination'; END IF;
  SELECT COALESCE(jsonb_agg(public._purchase_read_b(x.id) ORDER BY x.confirmed_at DESC,x.id),'[]'::jsonb) INTO result
    FROM (SELECT id,confirmed_at FROM public.verified_transactions WHERE shop_id=p_shop_id ORDER BY confirmed_at DESC,id OFFSET p_offset LIMIT p_limit) x;
  RETURN result;
END $body$;

CREATE FUNCTION public.record_purchase_return_v2(p_purchase_id uuid,p_request_id uuid,p_items jsonb,p_reason text,
  p_installation_id uuid,p_reverses_return_id uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE v public.verified_transactions; sid uuid; existing public.purchase_returns; source public.purchase_returns;
  payload jsonb; rid uuid; line record; item public.verified_transaction_items; qty integer; returned bigint; BEGIN
  SELECT * INTO v FROM public.verified_transactions WHERE id=p_purchase_id;
  IF v.id IS NULL THEN RAISE EXCEPTION 'Purchase access denied' USING ERRCODE='42501'; END IF;
  IF p_reverses_return_id IS NULL THEN sid:=public._qr_device_b(v.shop_id,p_installation_id);
  ELSE
    sid:=public._qr_auth_session_b();
    PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Admin required' USING ERRCODE='42501'; END IF;
  END IF;
  -- Purchase row lock serializes quantities, correction and invalidation.
  PERFORM id FROM public.verified_transactions WHERE id=p_purchase_id FOR UPDATE;
  IF p_request_id IS NULL OR p_reason IS NULL OR length(btrim(p_reason)) NOT BETWEEN 1 AND 500
    OR p_items IS NULL OR jsonb_typeof(p_items)<>'array' OR jsonb_array_length(p_items) NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Invalid return request'; END IF;
  SELECT jsonb_agg(e ORDER BY e->>'purchase_item_id') INTO payload FROM jsonb_array_elements(p_items) e;
  payload:=jsonb_build_object('items',payload,'reason',btrim(p_reason),'reverses_return_id',p_reverses_return_id,'purchase_id',p_purchase_id);
  SELECT * INTO existing FROM public.purchase_returns WHERE actor_user_id=auth.uid() AND request_id=p_request_id;
  IF FOUND THEN
    IF existing.request_payload<>payload THEN RAISE EXCEPTION 'Return request mismatch'; END IF;
    RETURN public._purchase_read_b(p_purchase_id); END IF;
  IF NOT EXISTS(SELECT 1 FROM public.purchase_terms WHERE purchase_id=p_purchase_id) THEN
    RAISE EXCEPTION 'Legacy purchase terms are unclassified'; END IF;
  IF EXISTS(SELECT 1 FROM public.purchase_invalidations WHERE purchase_id=p_purchase_id) THEN RAISE EXCEPTION 'Purchase invalidated'; END IF;
  IF (SELECT count(DISTINCT e->>'purchase_item_id') FROM jsonb_array_elements(p_items) e)<>jsonb_array_length(p_items) THEN
    RAISE EXCEPTION 'Duplicate return item'; END IF;
  IF p_reverses_return_id IS NOT NULL THEN
    SELECT * INTO source FROM public.purchase_returns WHERE id=p_reverses_return_id AND purchase_id=p_purchase_id AND return_kind='genuine';
    IF source.id IS NULL OR EXISTS(SELECT 1 FROM public.purchase_returns WHERE reverses_return_id=source.id) THEN
      RAISE EXCEPTION 'Return correction unavailable'; END IF;
    IF (SELECT count(*) FROM public.purchase_return_items WHERE return_id=source.id)<>jsonb_array_length(p_items) THEN
      RAISE EXCEPTION 'Correction must reverse exact recorded return'; END IF;
  END IF;
  INSERT INTO public.purchase_returns(purchase_id,return_kind,actor_user_id,actor_auth_session_id,reason,request_id,request_payload,reverses_return_id)
    VALUES(p_purchase_id,CASE WHEN source.id IS NULL THEN 'genuine' ELSE 'administrative_correction' END,auth.uid(),sid,btrim(p_reason),p_request_id,payload,source.id)
    RETURNING id INTO rid;
  FOR line IN SELECT e FROM jsonb_array_elements(p_items) e LOOP
    IF jsonb_typeof(line.e)<>'object' OR (line.e-'purchase_item_id'-'quantity')<>'{}'::jsonb
      OR COALESCE(line.e->>'quantity','') !~ '^[1-9][0-9]{0,8}$' THEN RAISE EXCEPTION 'Invalid return item'; END IF;
    qty:=(line.e->>'quantity')::integer;
    SELECT * INTO item FROM public.verified_transaction_items WHERE id=(line.e->>'purchase_item_id')::uuid AND verified_transaction_id=p_purchase_id;
    IF item.id IS NULL THEN RAISE EXCEPTION 'Foreign purchase item'; END IF;
    SELECT COALESCE(sum(CASE WHEN r.return_kind='genuine' THEN i.quantity ELSE -i.quantity END),0) INTO returned
      FROM public.purchase_return_items i JOIN public.purchase_returns r ON r.id=i.return_id WHERE i.purchase_item_id=item.id;
    IF source.id IS NULL THEN
      IF returned+qty>item.quantity THEN RAISE EXCEPTION 'Return exceeds purchased quantity'; END IF;
    ELSIF NOT EXISTS(SELECT 1 FROM public.purchase_return_items WHERE return_id=source.id AND purchase_item_id=item.id AND quantity=qty) THEN
      RAISE EXCEPTION 'Correction must reverse exact recorded return'; END IF;
    INSERT INTO public.purchase_return_items(return_id,purchase_item_id,quantity,sale_return_minor)
      VALUES(rid,item.id,qty,(item.unit_price*100)::bigint*qty);
  END LOOP;
  INSERT INTO public.commerce_events(purchase_id,event_kind,source_id)
    VALUES(p_purchase_id,CASE WHEN source.id IS NULL THEN 'purchase_returned' ELSE 'return_corrected' END,rid);
  RETURN public._purchase_read_b(p_purchase_id);
END $body$;

CREATE FUNCTION public.invalidate_purchase_v2(p_purchase_id uuid,p_request_id uuid,p_reason text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE sid uuid; prior public.purchase_invalidations; result uuid; BEGIN
  sid:=public._qr_auth_session_b();
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Admin required' USING ERRCODE='42501'; END IF;
  IF p_request_id IS NULL OR p_reason IS NULL OR length(btrim(p_reason)) NOT BETWEEN 1 AND 500 THEN RAISE EXCEPTION 'Reason required'; END IF;
  PERFORM id FROM public.verified_transactions WHERE id=p_purchase_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Purchase not found'; END IF;
  SELECT * INTO prior FROM public.purchase_invalidations WHERE purchase_id=p_purchase_id;
  IF FOUND THEN
    IF prior.actor_user_id=auth.uid() AND prior.request_id=p_request_id AND prior.reason=btrim(p_reason) THEN RETURN prior.id; END IF;
    RAISE EXCEPTION 'Purchase already invalidated'; END IF;
  INSERT INTO public.purchase_invalidations(purchase_id,actor_user_id,actor_auth_session_id,reason,request_id)
    VALUES(p_purchase_id,auth.uid(),sid,btrim(p_reason),p_request_id) RETURNING id INTO result;
  INSERT INTO public.commerce_events(purchase_id,event_kind,source_id) VALUES(p_purchase_id,'purchase_invalidated',result);
  RETURN result;
END $body$;

-- No direct client access to tokens, session audit, terms, events or write tables.
ALTER TABLE public.qr_protocol_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.qr_protocol_config FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.merchant_device_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.merchant_device_sessions FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.qr_session_protocols ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.qr_session_protocols FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.qr_claims ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.qr_claims FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.qr_attempt_limits ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.qr_attempt_limits FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.purchase_terms ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.purchase_terms FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.commerce_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.commerce_events FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.purchase_returns ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.purchase_returns FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.purchase_return_items ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.purchase_return_items FROM PUBLIC,anon,authenticated,service_role;
ALTER TABLE public.purchase_invalidations ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.purchase_invalidations FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._commerce_immutable_b() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_auth_session_b() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_device_b(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.revoke_merchant_device_session_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_digest_b(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_code_b(uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.qr_capabilities_v2() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.create_qr_session(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.get_qr_session_for_verification(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.confirm_qr_session(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_customer_payload_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.create_qr_session_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.get_qr_session_status_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_quote_valid_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_verification_payload_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_attempt_b(text,timestamptz,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.claim_existing_qr_v2(uuid,uuid,uuid,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.recover_merchant_claim_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_owned_claim_b(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.reconcile_claim_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.cancel_claim_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.complete_existing_qr_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._purchase_read_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._purchase_participant_b(uuid,uuid,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_purchase_evidence_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.list_merchant_purchases_v2(uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.record_purchase_return_v2(uuid,uuid,jsonb,text,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.invalidate_purchase_v2(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._create_qr_session_legacy_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._get_qr_verification_legacy_b(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._confirm_qr_session_legacy_b(text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.qr_capabilities_v2(),public.create_qr_session_v2(uuid),public.get_qr_session_status_v2(uuid),
  public.claim_existing_qr_v2(uuid,uuid,uuid,text,text),public.reconcile_claim_v2(uuid,uuid),public.cancel_claim_v2(uuid,uuid),
  public.complete_existing_qr_v2(uuid,uuid),public.read_purchase_evidence_v2(uuid),public.list_merchant_purchases_v2(uuid,integer,integer),
  public.recover_merchant_claim_v2(uuid,uuid),
  public.record_purchase_return_v2(uuid,uuid,jsonb,text,uuid,uuid),public.invalidate_purchase_v2(uuid,uuid,text),
  public.revoke_merchant_device_session_v2(uuid),public.create_qr_session(uuid),public.get_qr_session_for_verification(text),public.confirm_qr_session(text)
TO authenticated;
GRANT EXECUTE ON FUNCTION public._purchase_participant_b(uuid,uuid,uuid,uuid) TO authenticated;
COMMIT;
