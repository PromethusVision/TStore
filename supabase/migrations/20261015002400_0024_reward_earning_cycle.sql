-- E earning lifecycle only. No remote/provider/redemption/settlement activation.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regprocedure('public.post_balanced_journal_v1(uuid,jsonb)') IS NULL
    OR to_regprocedure('public.complete_existing_qr_v2(uuid,uuid)') IS NULL THEN
    RAISE EXCEPTION '0024 requires integrated B/C/D/F/H0';
  END IF;
END $preflight$;

CREATE TABLE public.reward_program_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.reward_program_config DEFAULT VALUES;
-- Short transaction serialization; no balance and no network/provider call.
CREATE TABLE public.reward_runtime_lock (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), epoch numeric NOT NULL DEFAULT 0 CHECK(epoch>=0)
);
INSERT INTO public.reward_runtime_lock DEFAULT VALUES;
CREATE TABLE public.reward_shop_preferences (
  shop_id uuid PRIMARY KEY REFERENCES public.shops(id), preferred_acceptance boolean NOT NULL DEFAULT false,
  voluntary_return_seconds integer CHECK(voluntary_return_seconds BETWEEN 0 AND 31536000),
  revision bigint NOT NULL DEFAULT 1 CHECK(revision>0)
);
CREATE TABLE public.reward_funding_attestations (
  id uuid PRIMARY KEY, shop_id uuid NOT NULL REFERENCES public.shops(id), consent_ref uuid NOT NULL,
  external_ref uuid NOT NULL UNIQUE, external_paid_minor bigint NOT NULL CHECK(external_paid_minor>=0),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.referral_packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), shop_id uuid NOT NULL REFERENCES public.shops(id),
  party_id uuid NOT NULL UNIQUE REFERENCES public.ledger_parties(id),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  funding_id uuid NOT NULL UNIQUE REFERENCES public.reward_funding_attestations(id),
  activated_at timestamptz NOT NULL, expires_at timestamptz NOT NULL CHECK(expires_at>activated_at)
);
CREATE INDEX referral_packages_shop ON public.referral_packages(shop_id,expires_at);
CREATE TABLE public.reward_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), cart_ref uuid NOT NULL,
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  created_at timestamptz NOT NULL, expires_at timestamptz NOT NULL CHECK(expires_at>created_at)
);
CREATE INDEX reward_attempt_cart ON public.reward_attempts(cart_ref,created_at DESC);
CREATE TABLE public.reward_reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), attempt_id uuid NOT NULL REFERENCES public.reward_attempts(id),
  package_id uuid NOT NULL REFERENCES public.referral_packages(id),
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  state text NOT NULL CHECK(state IN ('reserved','checkout_hold','released','consumed')),
  deadline timestamptz NOT NULL, qr_ref uuid UNIQUE,
  cart_fingerprint bytea NOT NULL CHECK(octet_length(cart_fingerprint)=32),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE UNIQUE INDEX reward_one_live_reservation ON public.reward_reservations(customer_party) WHERE state IN ('reserved','checkout_hold');
CREATE TABLE public.reward_qr_contracts (
  qr_ref uuid PRIMARY KEY, customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  reservation_id uuid REFERENCES public.reward_reservations(id),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  voluntary_return_seconds integer CHECK(voluntary_return_seconds>=0),
  return_policy_revision bigint, quoted_minor bigint NOT NULL CHECK(quoted_minor>=0),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.reward_sale_attestations (
  qr_ref uuid PRIMARY KEY REFERENCES public.reward_qr_contracts(qr_ref), claim_ref uuid NOT NULL UNIQUE,
  actual_sale_minor bigint NOT NULL CHECK(actual_sale_minor>=0),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.reward_contributions (
  purchase_id uuid PRIMARY KEY REFERENCES public.verified_transactions(id),
  package_id uuid NOT NULL REFERENCES public.referral_packages(id),
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  amount_minor bigint NOT NULL CHECK(amount_minor>0),
  earned_at timestamptz NOT NULL, matures_at timestamptz NOT NULL CHECK(matures_at>earned_at)
);
CREATE INDEX reward_contribution_order ON public.reward_contributions(customer_party,earned_at,purchase_id);
CREATE TABLE public.reward_coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  face_minor bigint NOT NULL CHECK(face_minor>0), issued_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  expires_at timestamptz, journal_id uuid NOT NULL UNIQUE REFERENCES public.ledger_journals(id)
);
CREATE TABLE public.reward_coupon_sources (
  coupon_id uuid NOT NULL REFERENCES public.reward_coupons(id),
  purchase_id uuid NOT NULL UNIQUE REFERENCES public.reward_contributions(purchase_id),
  PRIMARY KEY(coupon_id,purchase_id)
);
CREATE TABLE public.reward_contribution_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), purchase_id uuid NOT NULL REFERENCES public.reward_contributions(purchase_id),
  source_ref uuid NOT NULL UNIQUE, delta integer NOT NULL CHECK(delta IN (-1,1)),
  reason text NOT NULL CHECK(reason IN ('earned','return','correction','invalidated')),
  coupon_id uuid REFERENCES public.reward_coupons(id), journal_id uuid NOT NULL UNIQUE REFERENCES public.ledger_journals(id),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.reward_capacity_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), package_id uuid NOT NULL REFERENCES public.referral_packages(id),
  source_ref uuid NOT NULL UNIQUE, kind text NOT NULL CHECK(kind IN ('fund','hold','release','consume','restore','expire','reconsume')),
  free_delta integer NOT NULL, held_delta integer NOT NULL, consumed_delta integer NOT NULL, expired_delta integer NOT NULL,
  journal_id uuid NOT NULL UNIQUE REFERENCES public.ledger_journals(id),
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK((kind='fund' AND free_delta>0 AND held_delta=0 AND consumed_delta=0 AND expired_delta=0)
    OR(kind<>'fund' AND free_delta+held_delta+consumed_delta+expired_delta=0))
);
CREATE INDEX reward_capacity_package ON public.reward_capacity_events(package_id);

ALTER TABLE public.ledger_sources DROP CONSTRAINT ledger_sources_kind_check;
ALTER TABLE public.ledger_sources ADD CONSTRAINT ledger_sources_kind_e_check CHECK(kind IN (
  'coupon_redemption','unused_package_fund','platform_service','receivable_release','package_funding','reward_issue',
  'return','admin_reversal','offset_created','offset_recovered','reward_funding','reward_capacity','reward_compensation'));

CREATE FUNCTION public._reward_lock_e() RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  UPDATE public.reward_runtime_lock SET epoch=epoch+1 WHERE singleton;
  IF NOT FOUND THEN RAISE EXCEPTION '[REWARD_UNAVAILABLE]' USING ERRCODE='55000'; END IF;
END $e$;
CREATE FUNCTION public._reward_enabled_e() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT coalesce((SELECT r.enabled AND c.enabled AND p.version=1 AND EXISTS(SELECT 1 FROM public.qr_protocol_config WHERE enabled) FROM public.reward_program_config r
    CROSS JOIN public.commerce_ledger_config c JOIN public.commerce_policy_versions p ON p.id=c.policy_id),false)
$e$;
CREATE FUNCTION public._reward_customer_e() RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  PERFORM public._qr_auth_session_b();
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='customer' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REWARD_CUSTOMER_REQUIRED]' USING ERRCODE='42501'; END IF;
  RETURN auth.uid();
END $e$;
CREATE FUNCTION public._reward_account_e(p_party uuid,p_code text) RETURNS uuid LANGUAGE sql SECURITY DEFINER SET search_path='' AS $e$
  SELECT public.ensure_ledger_account_v1(p_party,p_code)
$e$;
CREATE FUNCTION public._reward_post_e(p_kind text,p_ref uuid,p_party uuid,p_policy uuid,p_lines jsonb) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE normalized jsonb; n integer; total numeric; positive numeric; account_key uuid; source_key uuid; posted public.ledger_journals; digest_value bytea;
BEGIN
  IF p_kind IS NULL OR p_kind NOT IN ('reward_funding','reward_capacity','reward_compensation')
    OR jsonb_typeof(p_lines) IS DISTINCT FROM 'array' OR jsonb_array_length(p_lines) NOT BETWEEN 2 AND 8 THEN
    RAISE EXCEPTION '[REWARD_POST_ARGUMENT]' USING ERRCODE='22023'; END IF;
  SELECT jsonb_agg(jsonb_build_object('account_id',(x->>'account_id')::uuid,'amount_minor',((x->>'amount_minor')::bigint)::text) ORDER BY (x->>'account_id')::uuid),
    count(DISTINCT (x->>'account_id')::uuid),sum((x->>'amount_minor')::bigint),
    sum((x->>'amount_minor')::numeric) FILTER(WHERE (x->>'amount_minor')::numeric>0)
    INTO normalized,n,total,positive FROM jsonb_array_elements(p_lines) x;
  IF n<>jsonb_array_length(p_lines) OR total IS DISTINCT FROM 0::numeric OR positive IS NULL OR positive<=0
    OR EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x WHERE (x->>'amount_minor')::bigint=0) THEN
    RAISE EXCEPTION '[REWARD_POST_UNBALANCED]' USING ERRCODE='22023'; END IF;
  source_key:=public.record_commerce_source_v1(p_kind,p_ref,p_party,positive::bigint,p_policy,p_ref);
  digest_value:=extensions.digest(normalized::text,'sha256');
  SELECT * INTO posted FROM public.ledger_journals WHERE source_id=source_key;
  IF FOUND THEN
    IF posted.postings_hash<>digest_value THEN RAISE EXCEPTION '[REWARD_REPLAY_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN posted.id;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.commerce_ledger_config WHERE enabled) THEN RAISE EXCEPTION '[LEDGER_DISABLED]' USING ERRCODE='55000'; END IF;
  FOR account_key IN SELECT (x->>'account_id')::uuid FROM jsonb_array_elements(normalized) x ORDER BY 1 LOOP
    UPDATE public.ledger_account_locks SET epoch=epoch+1 WHERE account_id=account_key;
    IF NOT FOUND THEN RAISE EXCEPTION '[LEDGER_ACCOUNT_UNKNOWN]' USING ERRCODE='22023'; END IF;
  END LOOP;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE a.currency<>'TRY' OR a.code='customer_future_offset' OR a.code='platform_offset_control'
      OR (a.code='merchant_reserve' AND (x->>'amount_minor')::bigint>0)
      OR (a.code<>'platform_clearing' AND public._ledger_balance_h0(a.id)+(x->>'amount_minor')::bigint<0)) THEN
    RAISE EXCEPTION '[REWARD_POST_OVERDRAFT_OR_SOURCE]' USING ERRCODE='22023'; END IF;
  INSERT INTO public.ledger_journals(source_id,posting_count,postings_hash) VALUES(source_key,n,digest_value) RETURNING * INTO posted;
  INSERT INTO public.ledger_postings(journal_id,account_id,amount_minor)
    SELECT posted.id,(x->>'account_id')::uuid,(x->>'amount_minor')::bigint FROM jsonb_array_elements(normalized) x;
  RETURN posted.id;
END $e$;
CREATE FUNCTION public._reward_transfer_e(p_kind text,p_ref uuid,p_party uuid,p_policy uuid,p_from uuid,p_to uuid,p_amount bigint) RETURNS uuid
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $e$
  SELECT public._reward_post_e(p_kind,p_ref,p_party,p_policy,jsonb_build_array(
    jsonb_build_object('account_id',p_from,'amount_minor',(-p_amount)::text),jsonb_build_object('account_id',p_to,'amount_minor',p_amount::text)))
$e$;
CREATE FUNCTION public._reward_capacity_e(p_package uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT jsonb_build_object('free',coalesce(sum(free_delta),0),'held',coalesce(sum(held_delta),0),
    'consumed',coalesce(sum(consumed_delta),0),'expired',coalesce(sum(expired_delta),0))
  FROM public.reward_capacity_events WHERE package_id=p_package
$e$;
CREATE FUNCTION public._reward_seal_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE target uuid; pack public.referral_packages; policy_row public.commerce_policy_versions; cap jsonb; free_value numeric; held_value numeric;
BEGIN
  IF TG_TABLE_NAME='referral_packages' THEN target:=NEW.id; ELSE target:=NEW.package_id; END IF;
  SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=target;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=pack.policy_id;
  cap:=public._reward_capacity_e(target);
  IF (cap->>'free')::integer<0 OR (cap->>'held')::integer<0 OR (cap->>'consumed')::integer<0 OR (cap->>'expired')::integer<0
    OR (cap->>'free')::integer+(cap->>'held')::integer+(cap->>'consumed')::integer+(cap->>'expired')::integer<>policy_row.package_slots THEN
    RAISE EXCEPTION '[REWARD_CAPACITY_INVARIANT]' USING ERRCODE='23514'; END IF;
  SELECT public._ledger_balance_h0(id) INTO free_value FROM public.ledger_accounts WHERE party_id=pack.party_id AND code='package_free';
  SELECT public._ledger_balance_h0(id) INTO held_value FROM public.ledger_accounts WHERE party_id=pack.party_id AND code='package_held';
  IF free_value IS DISTINCT FROM (cap->>'free')::numeric*policy_row.contribution_minor
    OR coalesce(held_value,0)<>(cap->>'held')::numeric*policy_row.contribution_minor
    OR (cap->>'held')::bigint<>(SELECT count(*) FROM public.reward_reservations WHERE package_id=target AND state IN ('reserved','checkout_hold')) THEN
    RAISE EXCEPTION '[REWARD_FUND_CAPACITY_INVARIANT]' USING ERRCODE='23514'; END IF;
  RETURN NULL;
END $e$;
CREATE CONSTRAINT TRIGGER reward_package_sealed AFTER INSERT ON public.referral_packages DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_seal_e();
CREATE CONSTRAINT TRIGGER reward_capacity_sealed AFTER INSERT ON public.reward_capacity_events DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_seal_e();

CREATE FUNCTION public._reward_expire_package_e(p_package uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE pack public.referral_packages; policy_row public.commerce_policy_versions; free_slots integer; event_key uuid; journal_key uuid; merchant_party uuid;
BEGIN
  SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=p_package;
  IF pack.expires_at>clock_timestamp() THEN RETURN; END IF;
  free_slots:=(public._reward_capacity_e(pack.id)->>'free')::integer;
  IF free_slots=0 THEN RETURN; END IF;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=pack.policy_id;
  merchant_party:=public.ensure_ledger_party_v1('merchant',pack.shop_id); event_key:=gen_random_uuid();
  journal_key:=public._reward_transfer_e('reward_capacity',event_key,pack.party_id,pack.policy_id,
    public._reward_account_e(pack.party_id,'package_free'),public._reward_account_e(merchant_party,'merchant_unused_pending'),free_slots::bigint*policy_row.contribution_minor);
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(pack.id,event_key,'expire',-free_slots,0,0,free_slots,journal_key);
END $e$;
CREATE FUNCTION public._reward_release_e(p_reservation uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE reservation public.reward_reservations; pack public.referral_packages; amount_value bigint; event_key uuid; journal_key uuid;
BEGIN
  SELECT * INTO STRICT reservation FROM public.reward_reservations WHERE id=p_reservation;
  IF reservation.state NOT IN ('reserved','checkout_hold') THEN RETURN; END IF;
  SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=reservation.package_id;
  SELECT contribution_minor INTO amount_value FROM public.commerce_policy_versions WHERE id=pack.policy_id;
  event_key:=gen_random_uuid();
  journal_key:=public._reward_transfer_e('reward_capacity',event_key,pack.party_id,pack.policy_id,
    public._reward_account_e(pack.party_id,'package_held'),public._reward_account_e(pack.party_id,'package_free'),amount_value);
  UPDATE public.reward_reservations SET state='released' WHERE id=reservation.id;
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(pack.id,event_key,'release',1,-1,0,0,journal_key);
  PERFORM public._reward_expire_package_e(pack.id);
END $e$;
CREATE FUNCTION public._reward_cart_quote_e(p_cart uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT jsonb_build_object('minor',coalesce(sum(ci.quantity::numeric*l.price*100),0)::text,
    'valid',coalesce(bool_and(l.is_active AND l.is_available AND p.is_active AND l.shop_id=c.shop_id
      AND l.price*100=trunc(l.price*100) AND l.price>=0 AND ci.quantity>0),false),
    'fingerprint',encode(extensions.digest(coalesce(jsonb_agg(jsonb_build_array(ci.shop_product_id,ci.quantity,l.price,l.is_active,l.is_available,p.is_active)
      ORDER BY ci.shop_product_id),'[]'::jsonb)::text,'sha256'),'hex'))
  FROM public.carts c JOIN public.cart_items_v2 ci ON ci.cart_id=c.id JOIN public.shop_products l ON l.id=ci.shop_product_id
    JOIN public.products p ON p.id=l.product_id WHERE c.id=p_cart AND c.status='active'
$e$;
CREATE FUNCTION public._reward_reconcile_e(p_limit integer DEFAULT 200) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE item record;
BEGIN
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 1000 THEN RAISE EXCEPTION '[REWARD_INVALID_LIMIT]'; END IF;
  PERFORM public._reward_lock_e();
  FOR item IN SELECT r.id FROM public.reward_reservations r JOIN public.reward_attempts a ON a.id=r.attempt_id
    JOIN public.ledger_parties p ON p.id=r.customer_party
    WHERE r.state IN ('reserved','checkout_hold') AND (r.deadline<=clock_timestamp() OR p.user_id IS NULL
      OR NOT EXISTS(SELECT 1 FROM public.carts c WHERE c.id=a.cart_ref AND c.status='active')
      OR (r.state='checkout_hold' AND NOT EXISTS(SELECT 1 FROM public.qr_sessions q WHERE q.id=r.qr_ref AND q.status='active')))
    ORDER BY r.package_id,r.id LIMIT p_limit LOOP
    PERFORM public._reward_release_e(item.id);
  END LOOP;
  FOR item IN SELECT p.id FROM public.referral_packages p WHERE p.expires_at<=clock_timestamp()
    AND (public._reward_capacity_e(p.id)->>'free')::integer>0 ORDER BY p.id LIMIT p_limit LOOP
    PERFORM public._reward_expire_package_e(item.id);
  END LOOP;
END $e$;
CREATE FUNCTION public.activate_referral_package_v1(p_shop uuid,p_request uuid,p_consent uuid,p_external_ref uuid,p_external_paid text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE prior public.reward_funding_attestations; policy_row public.commerce_policy_versions; package_key uuid; package_party uuid; merchant_party uuid;
  platform_party uuid; reserve_key uuid; coupon_key uuid; unused_key uuid; due numeric; reserve_use bigint; coupon_use bigint; unused_use bigint;
  paid_value bigint; lines jsonb; journal_key uuid; stamp timestamptz; lock_key uuid; payment_accounts uuid[];
BEGIN
  IF p_shop IS NULL OR p_request IS NULL OR p_consent IS NULL OR p_external_ref IS NULL OR p_external_paid IS NULL
    OR p_external_paid !~ '^(0|[1-9][0-9]{0,18})$' THEN RAISE EXCEPTION '[REWARD_FUNDING_ARGUMENT]' USING ERRCODE='22023'; END IF;
  paid_value:=p_external_paid::bigint;
  PERFORM public._reward_lock_e();
  SELECT * INTO prior FROM public.reward_funding_attestations WHERE id=p_request;
  IF FOUND THEN
    IF ROW(prior.shop_id,prior.consent_ref,prior.external_ref,prior.external_paid_minor) IS DISTINCT FROM ROW(p_shop,p_consent,p_external_ref,paid_value) THEN
      RAISE EXCEPTION '[REWARD_FUNDING_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN (SELECT id FROM public.referral_packages WHERE funding_id=prior.id);
  END IF;
  IF NOT public._reward_enabled_e() THEN RAISE EXCEPTION '[REWARD_DISABLED]' USING ERRCODE='55000'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.shops s JOIN public.profiles p ON p.id=s.owner_user_id
    WHERE s.id=p_shop AND s.is_active AND p.role='merchant') THEN RAISE EXCEPTION '[REWARD_SHOP_UNAVAILABLE]' USING ERRCODE='22023'; END IF;
  PERFORM public._reward_reconcile_e();
  IF EXISTS(SELECT 1 FROM public.referral_packages WHERE shop_id=p_shop AND expires_at>clock_timestamp()) THEN
    RAISE EXCEPTION '[REWARD_PACKAGE_ACTIVE]' USING ERRCODE='22023'; END IF;
  SELECT p.* INTO STRICT policy_row FROM public.commerce_policy_versions p JOIN public.commerce_ledger_config c ON c.policy_id=p.id;
  merchant_party:=public.ensure_ledger_party_v1('merchant',p_shop); platform_party:=public.ensure_ledger_party_v1('platform');
  reserve_key:=public._reward_account_e(merchant_party,'merchant_reserve');
  coupon_key:=public._reward_account_e(merchant_party,'merchant_coupon_available'); unused_key:=public._reward_account_e(merchant_party,'merchant_unused_available');
  package_key:=gen_random_uuid(); package_party:=public.ensure_ledger_party_v1('package',package_key,p_shop);
  -- Include every posting account before calculating the external remainder;
  -- acquiring a subset first would invert H0's global UUID account-lock order.
  payment_accounts:=ARRAY[reserve_key,coupon_key,unused_key,public._reward_account_e(package_party,'package_free'),
    public._reward_account_e(platform_party,'platform_service'),public._reward_account_e(platform_party,'platform_clearing')];
  FOR lock_key IN SELECT unnest(payment_accounts) ORDER BY 1 LOOP
    UPDATE public.ledger_account_locks SET epoch=epoch+1 WHERE account_id=lock_key;
  END LOOP;
  due:=policy_row.package_fund_minor::numeric+policy_row.package_fee_minor;
  reserve_use:=least(due,public._ledger_balance_h0(reserve_key)); due:=due-reserve_use;
  coupon_use:=least(due,public._ledger_balance_h0(coupon_key)); due:=due-coupon_use;
  unused_use:=least(due,public._ledger_balance_h0(unused_key)); due:=due-unused_use;
  IF paid_value<>due THEN RAISE EXCEPTION '[REWARD_FUNDING_AMOUNT]' USING ERRCODE='22023'; END IF;
  INSERT INTO public.reward_funding_attestations(id,shop_id,consent_ref,external_ref,external_paid_minor,policy_id)
    VALUES(p_request,p_shop,p_consent,p_external_ref,paid_value,policy_row.id);
  stamp:=clock_timestamp();
  INSERT INTO public.referral_packages(id,shop_id,party_id,policy_id,funding_id,activated_at,expires_at)
    VALUES(package_key,p_shop,package_party,policy_row.id,p_request,stamp,stamp+make_interval(secs=>policy_row.package_seconds));
  lines:=jsonb_build_array(jsonb_build_object('account_id',public._reward_account_e(package_party,'package_free'),'amount_minor',policy_row.package_fund_minor::text));
  IF policy_row.package_fee_minor>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_service'),'amount_minor',policy_row.package_fee_minor::text)); END IF;
  IF reserve_use>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',reserve_key,'amount_minor',(-reserve_use)::text)); END IF;
  IF coupon_use>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',coupon_key,'amount_minor',(-coupon_use)::text)); END IF;
  IF unused_use>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',unused_key,'amount_minor',(-unused_use)::text)); END IF;
  IF paid_value>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_clearing'),'amount_minor',(-paid_value)::text)); END IF;
  journal_key:=public._reward_post_e('reward_funding',p_request,package_party,policy_row.id,lines);
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(package_key,p_request,'fund',policy_row.package_slots,0,0,0,journal_key);
  RETURN package_key;
END $e$;

CREATE FUNCTION public.ensure_reward_reservation_v1(p_cart uuid,p_start_new boolean DEFAULT false) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE cart_row public.carts; party_key uuid; attempt public.reward_attempts; reservation public.reward_reservations;
  pack public.referral_packages; policy_row public.commerce_policy_versions; quote_value jsonb; journal_key uuid; event_key uuid; item record; stamp timestamptz;
BEGIN
  PERFORM public._reward_customer_e();
  IF p_start_new IS NULL THEN RAISE EXCEPTION '[REWARD_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  SELECT * INTO cart_row FROM public.carts WHERE id=p_cart AND user_id=auth.uid() AND status='active' FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REWARD_CART_UNAVAILABLE]' USING ERRCODE='42501'; END IF;
  PERFORM public._reward_lock_e();
  IF NOT public._reward_enabled_e() THEN RETURN jsonb_build_object('status','disabled','server_now',clock_timestamp()); END IF;
  PERFORM public._reward_reconcile_e();
  party_key:=public.ensure_ledger_party_v1('customer',auth.uid());
  SELECT p.* INTO STRICT policy_row FROM public.commerce_policy_versions p JOIN public.commerce_ledger_config c ON c.policy_id=p.id;
  SELECT * INTO attempt FROM public.reward_attempts WHERE cart_ref=p_cart AND customer_party=party_key ORDER BY created_at DESC,id DESC LIMIT 1;
  SELECT * INTO reservation FROM public.reward_reservations WHERE customer_party=party_key AND state IN ('reserved','checkout_hold');
  IF reservation.id IS NOT NULL AND reservation.deadline<=clock_timestamp() THEN
    PERFORM public._reward_release_e(reservation.id); reservation:=NULL;
  END IF;
  IF reservation.id IS NOT NULL AND (SELECT cart_ref FROM public.reward_attempts WHERE id=reservation.attempt_id)<>p_cart THEN
    PERFORM public._reward_release_e(reservation.id); reservation:=NULL;
  END IF;
  quote_value:=public._reward_cart_quote_e(p_cart);
  IF (quote_value->>'valid')::boolean IS NOT TRUE OR (quote_value->>'minor')::numeric<policy_row.eligible_minimum_minor THEN
    IF reservation.id IS NOT NULL THEN PERFORM public._reward_release_e(reservation.id); END IF;
    RETURN jsonb_build_object('status','below_threshold','attempt_id',attempt.id,'expires_at',attempt.expires_at,'server_now',clock_timestamp());
  END IF;
  IF reservation.state='checkout_hold' THEN
    RETURN jsonb_build_object('status','checkout_hold','attempt_id',attempt.id,'expires_at',reservation.deadline,'server_now',clock_timestamp());
  END IF;
  stamp:=clock_timestamp();
  IF attempt.id IS NOT NULL AND attempt.expires_at<=stamp AND NOT p_start_new THEN
    RETURN jsonb_build_object('status','attempt_expired','attempt_id',attempt.id,'expires_at',attempt.expires_at,'server_now',stamp);
  END IF;
  IF attempt.id IS NULL OR attempt.expires_at<=stamp THEN
    INSERT INTO public.reward_attempts(cart_ref,customer_party,created_at,expires_at)
      VALUES(p_cart,party_key,stamp,stamp+make_interval(secs=>policy_row.reservation_seconds)) RETURNING * INTO attempt;
  END IF;
  IF reservation.id IS NOT NULL THEN
    UPDATE public.reward_reservations SET cart_fingerprint=decode(quote_value->>'fingerprint','hex') WHERE id=reservation.id;
    RETURN jsonb_build_object('status','reserved','attempt_id',attempt.id,'expires_at',attempt.expires_at,'server_now',clock_timestamp());
  END IF;
  SELECT p.* INTO pack FROM public.referral_packages p WHERE p.shop_id=cart_row.shop_id AND p.expires_at>clock_timestamp()
    AND (public._reward_capacity_e(p.id)->>'free')::integer>0 ORDER BY p.activated_at,p.id LIMIT 1;
  IF pack.id IS NULL THEN RETURN jsonb_build_object('status','no_capacity','attempt_id',attempt.id,'expires_at',attempt.expires_at,'server_now',clock_timestamp()); END IF;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=pack.policy_id;
  event_key:=gen_random_uuid();
  journal_key:=public._reward_transfer_e('reward_capacity',event_key,pack.party_id,pack.policy_id,
    public._reward_account_e(pack.party_id,'package_free'),public._reward_account_e(pack.party_id,'package_held'),policy_row.contribution_minor);
  INSERT INTO public.reward_reservations(attempt_id,package_id,customer_party,state,deadline,cart_fingerprint)
    VALUES(attempt.id,pack.id,party_key,'reserved',attempt.expires_at,decode(quote_value->>'fingerprint','hex'));
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(pack.id,event_key,'hold',-1,1,0,0,journal_key);
  RETURN jsonb_build_object('status','reserved','attempt_id',attempt.id,'expires_at',attempt.expires_at,'server_now',clock_timestamp());
END $e$;

CREATE FUNCTION public.create_reward_qr_v1(p_cart uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE payload jsonb; reservation public.reward_reservations; policy_key uuid; party_key uuid; qid uuid; preference public.reward_shop_preferences;
BEGIN
  PERFORM public._reward_customer_e();
  PERFORM id FROM public.carts WHERE id=p_cart AND user_id=auth.uid() AND status='active' FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REWARD_CART_UNAVAILABLE]' USING ERRCODE='42501'; END IF;
  PERFORM public._reward_lock_e();
  -- An existing contract can be recovered even when new enrollment is disabled.
  SELECT q.id INTO qid FROM public.qr_sessions q JOIN public.reward_qr_contracts e ON e.qr_ref=q.id
    WHERE q.cart_id=p_cart AND q.status='active' AND (public._qr_customer_payload_b(q.id)->>'status') IN ('active','claimed');
  IF FOUND THEN RETURN public._qr_customer_payload_b(qid); END IF;
  IF NOT public._reward_enabled_e() THEN RAISE EXCEPTION '[REWARD_DISABLED]' USING ERRCODE='55000'; END IF;
  PERFORM public.ensure_reward_reservation_v1(p_cart,false);
  payload:=public.create_qr_session_v2(p_cart); qid:=(payload->>'id')::uuid;
  -- A pre-existing B-only QR must not be retroactively enrolled after a claim.
  IF EXISTS(SELECT 1 FROM public.qr_claims WHERE qr_session_id=qid) THEN RAISE EXCEPTION '[REWARD_EXISTING_CLAIM]' USING ERRCODE='55000'; END IF;
  party_key:=public.ensure_ledger_party_v1('customer',auth.uid());
  SELECT policy_id INTO policy_key FROM public.commerce_ledger_config;
  SELECT * INTO reservation FROM public.reward_reservations WHERE customer_party=party_key AND state='reserved'
    AND attempt_id IN (SELECT id FROM public.reward_attempts WHERE cart_ref=p_cart) AND deadline>clock_timestamp();
  SELECT p.* INTO preference FROM public.reward_shop_preferences p JOIN public.qr_sessions q ON q.shop_id=p.shop_id WHERE q.id=qid;
  INSERT INTO public.reward_qr_contracts(qr_ref,customer_party,reservation_id,policy_id,voluntary_return_seconds,return_policy_revision,quoted_minor)
    SELECT q.id,party_key,reservation.id,coalesce((SELECT policy_id FROM public.referral_packages WHERE id=reservation.package_id),policy_key),
      preference.voluntary_return_seconds,preference.revision,(q.total_amount*100)::bigint FROM public.qr_sessions q WHERE q.id=qid;
  IF reservation.id IS NOT NULL THEN
    UPDATE public.reward_reservations SET state='checkout_hold',qr_ref=qid,deadline=(payload->>'scan_expires_at')::timestamptz WHERE id=reservation.id;
  END IF;
  RETURN payload;
END $e$;
CREATE FUNCTION public._reward_claim_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE reservation public.reward_reservations;
BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.reward_qr_contracts WHERE qr_ref=NEW.qr_session_id) THEN RETURN NEW; END IF;
  PERFORM public._reward_lock_e();
  IF NOT EXISTS(SELECT 1 FROM public.qr_sessions WHERE id=NEW.qr_session_id AND status='active' AND expires_at>clock_timestamp()) THEN
    RAISE EXCEPTION '[REWARD_SCAN_EXPIRED]' USING ERRCODE='55000'; END IF;
  SELECT r.* INTO reservation FROM public.reward_reservations r JOIN public.reward_qr_contracts q ON q.reservation_id=r.id
    WHERE q.qr_ref=NEW.qr_session_id AND r.state='checkout_hold';
  IF reservation.id IS NOT NULL THEN
    IF reservation.deadline<=clock_timestamp() THEN RAISE EXCEPTION '[REWARD_HOLD_EXPIRED]' USING ERRCODE='55000'; END IF;
    UPDATE public.reward_reservations SET deadline=NEW.completion_expires_at WHERE id=reservation.id;
  END IF;
  RETURN NEW;
END $e$;
CREATE TRIGGER reward_claim_hold AFTER INSERT ON public.qr_claims FOR EACH ROW EXECUTE FUNCTION public._reward_claim_e();
CREATE FUNCTION public._reward_qr_terminal_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE reservation public.reward_reservations;
BEGIN
  IF NEW.status IN ('cancelled','expired') AND OLD.status='active' THEN
    SELECT * INTO reservation FROM public.reward_reservations WHERE qr_ref=NEW.id AND state='checkout_hold';
    IF reservation.id IS NOT NULL THEN PERFORM public._reward_lock_e(); PERFORM public._reward_release_e(reservation.id); END IF;
  END IF;
  RETURN NEW;
END $e$;
CREATE TRIGGER reward_qr_release AFTER UPDATE OF status ON public.qr_sessions FOR EACH ROW EXECUTE FUNCTION public._reward_qr_terminal_e();

ALTER FUNCTION public._qr_verification_payload_b(uuid) RENAME TO _qr_verification_payload_before_e;
CREATE OR REPLACE FUNCTION public._qr_verification_payload_b(p_id uuid) RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path='' AS $e$
  SELECT public._qr_verification_payload_before_e(p_id)||jsonb_build_object(
    'reward_confirmation_required',EXISTS(SELECT 1 FROM public.reward_qr_contracts WHERE qr_ref=p_id),
    'reward_sale_minor',(SELECT quoted_minor::text FROM public.reward_qr_contracts WHERE qr_ref=p_id))
$e$;
ALTER FUNCTION public.complete_existing_qr_v2(uuid,uuid) RENAME TO _complete_existing_qr_before_e;
CREATE OR REPLACE FUNCTION public.complete_existing_qr_v2(p_claim_id uuid,p_installation_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE claim_row public.qr_claims;
BEGIN
  claim_row:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  IF EXISTS(SELECT 1 FROM public.reward_qr_contracts WHERE qr_ref=claim_row.qr_session_id) THEN
    RAISE EXCEPTION '[REWARD_CONFIRMATION_REQUIRED]' USING ERRCODE='55000'; END IF;
  RETURN public._complete_existing_qr_before_e(p_claim_id,p_installation_id);
END $e$;
CREATE FUNCTION public.complete_reward_qr_v1(p_claim_id uuid,p_installation_id uuid,p_actual_sale_minor text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE claim_row public.qr_claims; contract public.reward_qr_contracts; payload jsonb;
BEGIN
  claim_row:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  PERFORM c.id FROM public.carts c JOIN public.qr_sessions q ON q.cart_id=c.id WHERE q.id=claim_row.qr_session_id FOR UPDATE OF c;
  PERFORM public._reward_lock_e();
  SELECT * INTO contract FROM public.reward_qr_contracts WHERE qr_ref=claim_row.qr_session_id;
  IF contract.qr_ref IS NULL OR p_actual_sale_minor IS NULL OR p_actual_sale_minor !~ '^(0|[1-9][0-9]{0,18})$'
    OR p_actual_sale_minor::numeric<>contract.quoted_minor THEN RAISE EXCEPTION '[REWARD_SALE_MISMATCH]' USING ERRCODE='22023'; END IF;
  INSERT INTO public.reward_sale_attestations(qr_ref,claim_ref,actual_sale_minor) VALUES(contract.qr_ref,claim_row.id,contract.quoted_minor) ON CONFLICT DO NOTHING;
  payload:=public._complete_existing_qr_before_e(p_claim_id,p_installation_id);
  RETURN payload;
END $e$;

CREATE FUNCTION public._reward_earn_e(p_purchase uuid,p_event uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE purchase_row public.verified_transactions; contract public.reward_qr_contracts; reservation public.reward_reservations;
  pack public.referral_packages; policy_row public.commerce_policy_versions; source_key uuid; journal_key uuid; from_key uuid; terms_row public.purchase_terms;
BEGIN
  SELECT * INTO STRICT purchase_row FROM public.verified_transactions WHERE id=p_purchase;
  SELECT * INTO contract FROM public.reward_qr_contracts WHERE qr_ref=purchase_row.source_qr_session_id;
  IF contract.qr_ref IS NULL THEN RETURN; END IF;
  IF EXISTS(SELECT 1 FROM public.reward_contributions WHERE purchase_id=p_purchase) THEN RETURN; END IF;
  PERFORM public._reward_reconcile_e();
  SELECT * INTO STRICT terms_row FROM public.purchase_terms WHERE purchase_id=p_purchase;
  IF NOT EXISTS(SELECT 1 FROM public.reward_sale_attestations WHERE qr_ref=contract.qr_ref AND claim_ref=terms_row.claim_id AND actual_sale_minor=terms_row.final_sale_minor)
    OR terms_row.ev_coupon_minor<>0 OR terms_row.final_sale_minor<>contract.quoted_minor THEN
    RAISE EXCEPTION '[REWARD_SALE_UNATTESTED]' USING ERRCODE='55000'; END IF;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=contract.policy_id;
  SELECT * INTO reservation FROM public.reward_reservations WHERE id=contract.reservation_id AND state='checkout_hold';
  IF terms_row.customer_payment_minor<policy_row.eligible_minimum_minor THEN
    IF reservation.id IS NOT NULL THEN PERFORM public._reward_release_e(reservation.id); END IF;
    RETURN;
  END IF;
  IF reservation.id IS NOT NULL AND reservation.deadline>purchase_row.confirmed_at THEN
    SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=reservation.package_id;
    from_key:=public._reward_account_e(pack.party_id,'package_held');
  ELSE
    IF reservation.id IS NOT NULL THEN PERFORM public._reward_release_e(reservation.id); reservation:=NULL; END IF;
    SELECT p.* INTO pack FROM public.referral_packages p WHERE p.shop_id=purchase_row.shop_id AND p.expires_at>clock_timestamp()
      AND p.policy_id=contract.policy_id AND (public._reward_capacity_e(p.id)->>'free')::integer>0 ORDER BY p.activated_at,p.id LIMIT 1;
    IF pack.id IS NULL THEN RETURN; END IF;
    from_key:=public._reward_account_e(pack.party_id,'package_free');
  END IF;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=pack.policy_id;
  journal_key:=public._reward_transfer_e('reward_capacity',p_event,contract.customer_party,pack.policy_id,
    from_key,public._reward_account_e(contract.customer_party,'customer_pending'),policy_row.contribution_minor);
  INSERT INTO public.reward_contributions(purchase_id,package_id,customer_party,policy_id,amount_minor,earned_at,matures_at)
    VALUES(p_purchase,pack.id,contract.customer_party,pack.policy_id,policy_row.contribution_minor,purchase_row.confirmed_at,
      purchase_row.confirmed_at+make_interval(secs=>greatest(policy_row.minimum_maturity_seconds,coalesce(contract.voluntary_return_seconds,0))));
  INSERT INTO public.reward_contribution_events(purchase_id,source_ref,delta,reason,journal_id)
    VALUES(p_purchase,p_event,1,'earned',journal_key);
  IF reservation.id IS NOT NULL THEN UPDATE public.reward_reservations SET state='consumed' WHERE id=reservation.id; END IF;
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(pack.id,p_event,'consume',CASE WHEN reservation.id IS NULL THEN -1 ELSE 0 END,CASE WHEN reservation.id IS NULL THEN 0 ELSE -1 END,1,0,journal_key);
END $e$;

CREATE FUNCTION public._reward_compensate_e(p_purchase uuid,p_event uuid,p_kind text,p_occurred timestamptz) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE contribution public.reward_contributions; pack public.referral_packages; policy_row public.commerce_policy_versions;
  active_value integer; remaining_value numeric; valid_value boolean; coupon_key uuid; journal_key uuid; source_account uuid; target_account uuid;
  merchant_party uuid; capacity jsonb;
BEGIN
  SELECT * INTO contribution FROM public.reward_contributions WHERE purchase_id=p_purchase;
  IF NOT FOUND OR EXISTS(SELECT 1 FROM public.reward_contribution_events WHERE source_ref=p_event) THEN RETURN; END IF;
  SELECT coalesce(sum(delta),0) INTO active_value FROM public.reward_contribution_events WHERE purchase_id=p_purchase;
  IF p_kind IN ('purchase_returned','return_corrected') AND p_occurred>=contribution.matures_at AND active_value=1 THEN RETURN; END IF;
  SELECT t.customer_payment_minor-coalesce((SELECT sum(CASE WHEN r.return_kind='genuine' THEN i.sale_return_minor-i.ev_coupon_return_minor ELSE -i.sale_return_minor+i.ev_coupon_return_minor END)
    FROM public.purchase_returns r JOIN public.purchase_return_items i ON i.return_id=r.id WHERE r.purchase_id=p_purchase),0)
    INTO remaining_value FROM public.purchase_terms t WHERE t.purchase_id=p_purchase;
  SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=contribution.policy_id;
  valid_value:=remaining_value>=policy_row.eligible_minimum_minor AND NOT EXISTS(SELECT 1 FROM public.purchase_invalidations WHERE purchase_id=p_purchase);
  IF (active_value=1 AND valid_value) OR (active_value=0 AND NOT valid_value) THEN RETURN; END IF;
  IF active_value NOT IN (0,1) THEN RAISE EXCEPTION '[REWARD_CONTRIBUTION_INVARIANT]'; END IF;
  SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=contribution.package_id;
  SELECT coupon_id INTO coupon_key FROM public.reward_coupon_sources WHERE purchase_id=p_purchase;
  source_account:=public._reward_account_e(contribution.customer_party,CASE WHEN coupon_key IS NULL THEN 'customer_pending' ELSE 'customer_coupon' END);
  target_account:=public._reward_account_e(pack.party_id,'package_free');
  IF NOT valid_value THEN
    journal_key:=public._reward_transfer_e('reward_compensation',p_event,contribution.customer_party,contribution.policy_id,source_account,target_account,contribution.amount_minor);
    INSERT INTO public.reward_contribution_events(purchase_id,source_ref,delta,reason,coupon_id,journal_id)
      VALUES(p_purchase,p_event,-1,CASE WHEN p_kind='purchase_invalidated' THEN 'invalidated' ELSE 'return' END,coupon_key,journal_key);
    INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
      VALUES(pack.id,p_event,'restore',1,0,-1,0,journal_key);
    PERFORM public._reward_expire_package_e(pack.id);
  ELSE
    capacity:=public._reward_capacity_e(pack.id);
    IF pack.expires_at<=clock_timestamp() THEN
      merchant_party:=public.ensure_ledger_party_v1('merchant',pack.shop_id);
      target_account:=public._reward_account_e(merchant_party,'merchant_unused_pending');
      IF (capacity->>'expired')::integer<1 THEN RAISE EXCEPTION '[REWARD_CORRECTION_CAPACITY]'; END IF;
    ELSIF (capacity->>'free')::integer<1 THEN RAISE EXCEPTION '[REWARD_CORRECTION_CAPACITY]'; END IF;
    journal_key:=public._reward_transfer_e('reward_compensation',p_event,contribution.customer_party,contribution.policy_id,target_account,source_account,contribution.amount_minor);
    INSERT INTO public.reward_contribution_events(purchase_id,source_ref,delta,reason,coupon_id,journal_id)
      VALUES(p_purchase,p_event,1,'correction',coupon_key,journal_key);
    INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
      VALUES(pack.id,p_event,'reconsume',CASE WHEN pack.expires_at>clock_timestamp() THEN -1 ELSE 0 END,0,1,CASE WHEN pack.expires_at<=clock_timestamp() THEN -1 ELSE 0 END,journal_key);
  END IF;
END $e$;

CREATE FUNCTION public._reward_commerce_event_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.verified_transactions v JOIN public.reward_qr_contracts q ON q.qr_ref=v.source_qr_session_id WHERE v.id=NEW.purchase_id) THEN RETURN NEW; END IF;
  PERFORM public._reward_lock_e();
  IF NEW.event_kind='purchase_confirmed' THEN PERFORM public._reward_earn_e(NEW.purchase_id,NEW.id);
  ELSE PERFORM public._reward_compensate_e(NEW.purchase_id,NEW.id,NEW.event_kind,NEW.occurred_at); END IF;
  RETURN NEW;
END $e$;
CREATE TRIGGER reward_commerce_effect AFTER INSERT ON public.commerce_events FOR EACH ROW EXECUTE FUNCTION public._reward_commerce_event_e();

-- H0's generic kernel cannot bypass the E capacity or coupon allocation owner.
ALTER FUNCTION public.post_balanced_journal_v1(uuid,jsonb) RENAME TO _post_balanced_journal_before_e;
CREATE OR REPLACE FUNCTION public.post_balanced_journal_v1(p_source uuid,p_postings jsonb) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  IF EXISTS(SELECT 1 FROM public.ledger_sources WHERE id=p_source AND kind IN ('reward_funding','reward_capacity','reward_compensation')) THEN
    RAISE EXCEPTION '[REWARD_KERNEL_REQUIRED]' USING ERRCODE='55000'; END IF;
  IF jsonb_typeof(p_postings)='array' AND EXISTS(SELECT 1 FROM jsonb_array_elements(p_postings) x
    JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE EXISTS(SELECT 1 FROM public.referral_packages WHERE party_id=a.party_id)
      OR EXISTS(SELECT 1 FROM public.reward_attempts WHERE customer_party=a.party_id)) THEN
    RAISE EXCEPTION '[REWARD_KERNEL_REQUIRED]' USING ERRCODE='55000'; END IF;
  RETURN public._post_balanced_journal_before_e(p_source,p_postings);
EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN
  RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023';
END $e$;

CREATE FUNCTION public._reward_mature_e(p_party uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE sources uuid[]; policy_key uuid; source_total numeric; latest_maturity timestamptz; policy_row public.commerce_policy_versions;
  coupon_key uuid; journal_key uuid; batch integer; distinct_policies integer;
BEGIN
  FOR batch IN 1..50 LOOP
    SELECT array_agg(c.purchase_id ORDER BY c.earned_at,c.purchase_id),min(c.policy_id::text)::uuid,
      count(DISTINCT c.policy_id),sum(c.amount_minor),max(c.matures_at)
      INTO sources,policy_key,distinct_policies,source_total,latest_maturity FROM (
        SELECT r.* FROM public.reward_contributions r WHERE r.customer_party=p_party
          AND (SELECT sum(delta) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id)=1
          AND NOT EXISTS(SELECT 1 FROM public.reward_coupon_sources WHERE purchase_id=r.purchase_id)
        ORDER BY r.earned_at,r.purchase_id LIMIT 5) c;
    IF coalesce(cardinality(sources),0)<5 OR latest_maturity>clock_timestamp() THEN RETURN; END IF;
    SELECT * INTO STRICT policy_row FROM public.commerce_policy_versions WHERE id=policy_key;
    IF distinct_policies<>1 OR policy_row.version<>1 OR policy_row.cycle_purchases<>5 OR source_total<>policy_row.coupon_minor THEN
      RAISE EXCEPTION '[REWARD_POLICY_TRANSITION_PENDING]' USING ERRCODE='55000'; END IF;
    coupon_key:=gen_random_uuid();
    journal_key:=public._reward_transfer_e('reward_capacity',coupon_key,p_party,policy_key,
      public._reward_account_e(p_party,'customer_pending'),public._reward_account_e(p_party,'customer_coupon'),source_total::bigint);
    INSERT INTO public.reward_coupons(id,customer_party,policy_id,face_minor,expires_at,journal_id)
      VALUES(coupon_key,p_party,policy_key,source_total::bigint,CASE WHEN policy_row.coupon_expiry_seconds IS NULL THEN NULL
        ELSE clock_timestamp()+make_interval(secs=>policy_row.coupon_expiry_seconds) END,journal_key);
    INSERT INTO public.reward_coupon_sources(coupon_id,purchase_id) SELECT coupon_key,unnest(sources);
  END LOOP;
END $e$;
CREATE FUNCTION public._reward_customer_seal_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE party_key uuid; coupon_key uuid; expected_pending numeric; expected_coupon numeric; actual_pending numeric; actual_coupon numeric;
BEGIN
  IF TG_TABLE_NAME='reward_coupons' THEN party_key:=NEW.customer_party; coupon_key:=NEW.id;
  ELSIF TG_TABLE_NAME='reward_coupon_sources' THEN
    coupon_key:=NEW.coupon_id; SELECT customer_party INTO party_key FROM public.reward_coupons WHERE id=coupon_key;
  ELSE SELECT customer_party INTO party_key FROM public.reward_contributions WHERE purchase_id=NEW.purchase_id; END IF;
  IF coupon_key IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.reward_coupons c JOIN public.commerce_policy_versions p ON p.id=c.policy_id
    WHERE c.id=coupon_key AND (SELECT count(*) FROM public.reward_coupon_sources WHERE coupon_id=c.id)=p.cycle_purchases
      AND (SELECT sum(r.amount_minor) FROM public.reward_coupon_sources s JOIN public.reward_contributions r ON r.purchase_id=s.purchase_id
        WHERE s.coupon_id=c.id AND r.customer_party=c.customer_party AND r.policy_id=c.policy_id)=c.face_minor) THEN
    RAISE EXCEPTION '[REWARD_COUPON_SOURCE_INVARIANT]' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM public.reward_contributions r WHERE r.customer_party=party_key
    AND (SELECT coalesce(sum(delta),0) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id) NOT IN (0,1)) THEN
    RAISE EXCEPTION '[REWARD_CONTRIBUTION_INVARIANT]' USING ERRCODE='23514'; END IF;
  SELECT coalesce(sum(r.amount_minor*(SELECT coalesce(sum(delta),0) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id)),0)
    INTO expected_pending FROM public.reward_contributions r WHERE r.customer_party=party_key
      AND NOT EXISTS(SELECT 1 FROM public.reward_coupon_sources WHERE purchase_id=r.purchase_id);
  SELECT coalesce(sum(face_minor),0) INTO expected_coupon FROM public.reward_coupons WHERE customer_party=party_key;
  expected_coupon:=expected_coupon+coalesce((SELECT sum(e.delta*r.amount_minor) FROM public.reward_contribution_events e
    JOIN public.reward_contributions r ON r.purchase_id=e.purchase_id WHERE r.customer_party=party_key AND e.coupon_id IS NOT NULL),0);
  SELECT public._ledger_balance_h0(id) INTO actual_pending FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_pending';
  SELECT public._ledger_balance_h0(id) INTO actual_coupon FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_coupon';
  IF coalesce(actual_pending,0)<>expected_pending OR coalesce(actual_coupon,0)<>expected_coupon THEN
    RAISE EXCEPTION '[REWARD_CUSTOMER_ACCOUNT_INVARIANT]' USING ERRCODE='23514'; END IF;
  RETURN NULL;
END $e$;
CREATE CONSTRAINT TRIGGER reward_coupon_sealed AFTER INSERT ON public.reward_coupons DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();
CREATE CONSTRAINT TRIGGER reward_coupon_sources_sealed AFTER INSERT ON public.reward_coupon_sources DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();
CREATE CONSTRAINT TRIGGER reward_contribution_sealed AFTER INSERT ON public.reward_contribution_events DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();

CREATE FUNCTION public.reward_capabilities_v1() RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT jsonb_build_object('version',1,'enabled',public._reward_enabled_e(),'goal',p.cycle_purchases,'currency','TRY',
    'minimum_minor',p.eligible_minimum_minor::text,'contribution_minor',p.contribution_minor::text,'coupon_minor',p.coupon_minor::text,
    'package_slots',p.package_slots,'package_fund_minor',p.package_fund_minor::text,'package_fee_minor',p.package_fee_minor::text,
    'package_seconds',p.package_seconds,'reservation_seconds',p.reservation_seconds,'minimum_maturity_seconds',p.minimum_maturity_seconds,
    'package_purchase_enabled',false,'redemption_enabled',false,'settlement_enabled',false)
  FROM public.commerce_policy_versions p JOIN public.commerce_ledger_config c ON c.policy_id=p.id
$e$;
CREATE FUNCTION public.read_merchant_reward_v1(p_shop uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE preference public.reward_shop_preferences; packages jsonb; forced_value boolean;
BEGIN
  PERFORM public._review_merchant_c(p_shop);
  PERFORM public._reward_lock_e();
  IF EXISTS(SELECT 1 FROM public.commerce_ledger_config WHERE enabled) THEN PERFORM public._reward_reconcile_e(); END IF;
  SELECT * INTO preference FROM public.reward_shop_preferences WHERE shop_id=p_shop;
  forced_value:=EXISTS(SELECT 1 FROM public.referral_packages WHERE shop_id=p_shop AND expires_at>clock_timestamp())
    OR EXISTS(SELECT 1 FROM public.reward_reservations r JOIN public.referral_packages p ON p.id=r.package_id
      WHERE p.shop_id=p_shop AND r.state IN ('reserved','checkout_hold'));
  SELECT coalesce(jsonb_agg(jsonb_build_object('id',p.id,'activated_at',p.activated_at,'expires_at',p.expires_at,
    'expired',p.expires_at<=clock_timestamp(),'capacity',public._reward_capacity_e(p.id),'total_slots',c.package_slots,
    'fund_minor',c.package_fund_minor::text,'service_fee_minor',c.package_fee_minor::text) ORDER BY p.activated_at DESC,p.id),'[]'::jsonb)
    INTO packages FROM (SELECT * FROM public.referral_packages WHERE shop_id=p_shop ORDER BY activated_at DESC,id LIMIT 20) p
      JOIN public.commerce_policy_versions c ON c.id=p.policy_id;
  RETURN jsonb_build_object('enabled',public._reward_enabled_e(),'shop_id',p_shop,'server_now',clock_timestamp(),'packages',packages,
    'preferred_acceptance',coalesce(preference.preferred_acceptance,false),'forced_acceptance',forced_value,
    'effective_acceptance',forced_value OR coalesce(preference.preferred_acceptance,false),
    'voluntary_return_seconds',preference.voluntary_return_seconds,'preference_revision',coalesce(preference.revision,0),
    'package_purchase_enabled',false,'redemption_enabled',false);
END $e$;
CREATE FUNCTION public.set_merchant_reward_preference_v1(p_shop uuid,p_preferred boolean,p_expected_revision bigint) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE current_revision bigint; payload jsonb;
BEGIN
  PERFORM public._review_merchant_c(p_shop);
  IF p_preferred IS NULL OR p_expected_revision IS NULL OR p_expected_revision<0 THEN RAISE EXCEPTION '[REWARD_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM public._reward_lock_e();
  IF NOT public._reward_enabled_e() THEN RAISE EXCEPTION '[REWARD_DISABLED]' USING ERRCODE='55000'; END IF;
  SELECT revision INTO current_revision FROM public.reward_shop_preferences WHERE shop_id=p_shop;
  IF coalesce(current_revision,0)<>p_expected_revision THEN
    RAISE EXCEPTION '[REWARD_PREFERENCE_CHANGED]' USING ERRCODE='40001'; END IF;
  payload:=public.read_merchant_reward_v1(p_shop);
  IF NOT p_preferred AND (payload->>'forced_acceptance')::boolean THEN RAISE EXCEPTION '[REWARD_ACCEPTANCE_LOCKED]' USING ERRCODE='55000'; END IF;
  INSERT INTO public.reward_shop_preferences(shop_id,preferred_acceptance) VALUES(p_shop,p_preferred)
    ON CONFLICT(shop_id) DO UPDATE SET preferred_acceptance=excluded.preferred_acceptance,revision=public.reward_shop_preferences.revision+1;
  RETURN public.read_merchant_reward_v1(p_shop);
END $e$;
CREATE FUNCTION public.read_reward_state_v1() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE party_key uuid; pending_count integer; coupon_value numeric; coupons jsonb; merchants jsonb; history jsonb; pending_value numeric;
BEGIN
  PERFORM public._reward_customer_e();
  PERFORM public._reward_lock_e();
  SELECT id INTO party_key FROM public.ledger_parties WHERE kind='customer' AND user_id=auth.uid();
  IF public._reward_enabled_e() AND party_key IS NOT NULL THEN PERFORM public._reward_reconcile_e(); PERFORM public._reward_mature_e(party_key); END IF;
  SELECT count(*) INTO pending_count FROM public.reward_contributions r WHERE r.customer_party=party_key
    AND (SELECT sum(delta) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id)=1
    AND NOT EXISTS(SELECT 1 FROM public.reward_coupon_sources WHERE purchase_id=r.purchase_id);
  SELECT public._ledger_balance_h0(id) INTO pending_value FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_pending';
  SELECT public._ledger_balance_h0(id) INTO coupon_value FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_coupon';
  SELECT coalesce(jsonb_agg(jsonb_build_object('id',c.id,'issued_at',c.issued_at,'expires_at',c.expires_at,'face_minor',c.face_minor::text,
    'remaining_minor',(c.face_minor+coalesce((SELECT sum(e.delta*r.amount_minor) FROM public.reward_contribution_events e
      JOIN public.reward_contributions r ON r.purchase_id=e.purchase_id WHERE e.coupon_id=c.id),0))::text) ORDER BY c.issued_at DESC,c.id),'[]'::jsonb)
    INTO coupons FROM (SELECT * FROM public.reward_coupons WHERE customer_party=party_key ORDER BY issued_at DESC,id LIMIT 50) c;
  SELECT coalesce(jsonb_agg(jsonb_build_object('purchase_id',r.purchase_id,'earned_at',r.earned_at,'matures_at',r.matures_at,
    'valid',(SELECT sum(delta) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id)=1,
    'issued',EXISTS(SELECT 1 FROM public.reward_coupon_sources WHERE purchase_id=r.purchase_id)) ORDER BY r.earned_at DESC,r.purchase_id),'[]'::jsonb)
    INTO history FROM (SELECT * FROM public.reward_contributions WHERE customer_party=party_key ORDER BY earned_at DESC,purchase_id LIMIT 50) r;
  SELECT coalesce(jsonb_agg(jsonb_build_object('id',s.id,'name',s.name) ORDER BY s.name,s.id),'[]'::jsonb) INTO merchants
    FROM (SELECT s.id,s.name FROM public.shops s WHERE s.is_active AND EXISTS(SELECT 1 FROM public.referral_packages p
      WHERE p.shop_id=s.id AND p.expires_at>clock_timestamp() AND (public._reward_capacity_e(p.id)->>'free')::integer>0) ORDER BY s.name,s.id LIMIT 50) s;
  RETURN jsonb_build_object('enabled',public._reward_enabled_e(),'server_now',clock_timestamp(),'goal',5,'pending_count',pending_count,
    'pending_minor',coalesce(pending_value,0)::text,'coupon_minor',coalesce(coupon_value,0)::text,'coupons',coupons,'history',history,
    'merchants',CASE WHEN public._reward_enabled_e() THEN merchants ELSE '[]'::jsonb END,'redemption_enabled',false,'currency','TRY');
END $e$;

ALTER TABLE public.reward_program_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_runtime_lock ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_shop_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_funding_attestations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_qr_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_sale_attestations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_coupon_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_contribution_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_capacity_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.reward_program_config,public.reward_runtime_lock,public.reward_shop_preferences,public.reward_funding_attestations,
  public.referral_packages,public.reward_attempts,public.reward_reservations,public.reward_qr_contracts,public.reward_sale_attestations,
  public.reward_contributions,public.reward_coupons,public.reward_coupon_sources,public.reward_contribution_events,public.reward_capacity_events
  FROM PUBLIC,anon,authenticated,service_role;
DO $immutable$ DECLARE table_name text; BEGIN
  FOREACH table_name IN ARRAY ARRAY['reward_funding_attestations','referral_packages','reward_attempts','reward_qr_contracts',
    'reward_sale_attestations','reward_contributions','reward_coupons','reward_coupon_sources','reward_contribution_events','reward_capacity_events'] LOOP
    EXECUTE format('CREATE TRIGGER reward_immutable BEFORE UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b()',table_name);
  END LOOP;
END $immutable$;
REVOKE ALL ON FUNCTION public._reward_lock_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_enabled_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_customer_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_account_e(uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_post_e(text,uuid,uuid,uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_transfer_e(text,uuid,uuid,uuid,uuid,uuid,bigint) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_capacity_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_seal_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_expire_package_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_release_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_cart_quote_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_reconcile_e(integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.activate_referral_package_v1(uuid,uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.ensure_reward_reservation_v1(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.create_reward_qr_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_claim_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_qr_terminal_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_verification_payload_before_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_verification_payload_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._complete_existing_qr_before_e(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.complete_existing_qr_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.complete_reward_qr_v1(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_earn_e(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_compensate_e(uuid,uuid,text,timestamptz) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_commerce_event_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._post_balanced_journal_before_e(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.post_balanced_journal_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_mature_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_customer_seal_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.reward_capabilities_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_merchant_reward_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.set_merchant_reward_preference_v1(uuid,boolean,bigint) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_reward_state_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.reward_capabilities_v1() TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.ensure_reward_reservation_v1(uuid,boolean),public.create_reward_qr_v1(uuid),
  public.complete_existing_qr_v2(uuid,uuid),public.complete_reward_qr_v1(uuid,uuid,text),public.read_merchant_reward_v1(uuid),
  public.set_merchant_reward_preference_v1(uuid,boolean,bigint),public.read_reward_state_v1() TO authenticated;
COMMIT;
