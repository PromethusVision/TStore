-- E physical coupon checkout. Local implementation; rollout defaults OFF.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regprocedure('public._reward_mature_e(uuid)') IS NULL
    OR to_regprocedure('public._complete_existing_qr_before_e(uuid,uuid)') IS NULL
    OR to_regclass('public.reward_coupon_sources') IS NULL THEN
    RAISE EXCEPTION '0025 requires integrated B/H0/E earning lifecycle';
  END IF;
END $preflight$;
CREATE TABLE public.reward_checkout_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.reward_checkout_config DEFAULT VALUES;
CREATE TABLE public.reward_product_classifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), product_id uuid NOT NULL REFERENCES public.products(id),
  revision bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
  classification text NOT NULL CHECK(classification IN ('ordinary','cash_equivalent','unknown')),
  policy_ref text NOT NULL CHECK(length(btrim(policy_ref)) BETWEEN 1 AND 200),
  reason text NOT NULL CHECK(length(btrim(reason)) BETWEEN 1 AND 500),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX reward_classification_product ON public.reward_product_classifications(product_id,revision DESC);
CREATE TABLE public.reward_checkout_approvals (
  qr_ref uuid PRIMARY KEY REFERENCES public.reward_qr_contracts(qr_ref),
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id), auth_session_id uuid NOT NULL,
  request_id uuid NOT NULL, fingerprint text NOT NULL CHECK(fingerprint ~ '^[a-f0-9]{64}$'),
  sale_minor bigint NOT NULL CHECK(sale_minor>=0), coupon_minor bigint NOT NULL CHECK(coupon_minor>0 AND coupon_minor<=sale_minor),
  allocation jsonb NOT NULL CHECK(jsonb_typeof(allocation)='array'),
  approved_at timestamptz NOT NULL DEFAULT clock_timestamp(), UNIQUE(customer_party,request_id)
);
CREATE TABLE public.reward_coupon_redemptions (
  purchase_id uuid PRIMARY KEY REFERENCES public.verified_transactions(id),
  qr_ref uuid NOT NULL UNIQUE REFERENCES public.reward_checkout_approvals(qr_ref),
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  amount_minor bigint NOT NULL CHECK(amount_minor>0), journal_id uuid NOT NULL UNIQUE REFERENCES public.ledger_journals(id)
);
-- Immutable attribution is separate from the single monetary ledger.
CREATE TABLE public.reward_source_uses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), source_purchase uuid NOT NULL REFERENCES public.reward_contributions(purchase_id),
  amount_minor bigint NOT NULL CHECK(amount_minor>0),
  redemption_purchase uuid REFERENCES public.reward_coupon_redemptions(purchase_id),
  offset_id uuid, journal_id uuid NOT NULL REFERENCES public.ledger_journals(id),
  CHECK((redemption_purchase IS NULL)<>(offset_id IS NULL))
);
CREATE INDEX reward_source_uses_source ON public.reward_source_uses(source_purchase);
CREATE TABLE public.reward_spent_offsets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), source_purchase uuid NOT NULL UNIQUE REFERENCES public.reward_contributions(purchase_id),
  customer_party uuid NOT NULL REFERENCES public.ledger_parties(id),
  invalidation_event uuid NOT NULL UNIQUE REFERENCES public.commerce_events(id),
  amount_minor bigint NOT NULL CHECK(amount_minor>0), journal_id uuid NOT NULL REFERENCES public.ledger_journals(id),
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE public.reward_source_uses ADD FOREIGN KEY(offset_id) REFERENCES public.reward_spent_offsets(id);

CREATE FUNCTION public._checkout_enabled_e() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT public._reward_enabled_e() AND coalesce((SELECT enabled FROM public.reward_checkout_config),false)
$e$;
CREATE FUNCTION public._checkout_accepted_e(p_shop uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT coalesce((SELECT preferred_acceptance FROM public.reward_shop_preferences WHERE shop_id=p_shop),false)
    OR EXISTS(SELECT 1 FROM public.referral_packages WHERE shop_id=p_shop AND expires_at>clock_timestamp())
    OR EXISTS(SELECT 1 FROM public.reward_reservations r JOIN public.referral_packages p ON p.id=r.package_id
      WHERE p.shop_id=p_shop AND r.state IN ('reserved','checkout_hold'))
$e$;
CREATE FUNCTION public._checkout_source_remaining_e(p_source uuid) RETURNS bigint LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT CASE WHEN (SELECT sum(delta) FROM public.reward_contribution_events WHERE purchase_id=r.purchase_id)=1
    THEN r.amount_minor-coalesce((SELECT sum(amount_minor) FROM public.reward_source_uses WHERE source_purchase=r.purchase_id),0) ELSE 0 END::bigint
  FROM public.reward_contributions r WHERE r.purchase_id=p_source
$e$;
CREATE FUNCTION public._checkout_coupon_remaining_e(p_coupon uuid) RETURNS bigint LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT coalesce(sum(public._checkout_source_remaining_e(purchase_id)),0)::bigint FROM public.reward_coupon_sources WHERE coupon_id=p_coupon
$e$;
-- Trusted internal operation only. No client/admin role may guess the legal perimeter.
CREATE FUNCTION public.attest_reward_product_classification_v1(p_product uuid,p_classification text,p_policy_ref text,p_reason text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE result uuid;
BEGIN
  PERFORM public._reward_lock_e();
  INSERT INTO public.reward_product_classifications(product_id,classification,policy_ref,reason)
    VALUES(p_product,p_classification,btrim(p_policy_ref),btrim(p_reason)) RETURNING id INTO result;
  RETURN result;
END $e$;
CREATE FUNCTION public._checkout_cart_e(p_cart uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE quote jsonb; items jsonb; shop_key uuid; party_key uuid; balance_value numeric; eligible boolean; accepting boolean; fingerprint text;
BEGIN
  SELECT shop_id INTO shop_key FROM public.carts WHERE id=p_cart AND user_id=auth.uid() AND status='active';
  IF shop_key IS NULL THEN RAISE EXCEPTION '[CHECKOUT_CART_ACCESS]' USING ERRCODE='42501'; END IF;
  quote:=public._reward_cart_quote_e(p_cart);
  IF (quote->>'valid')::boolean IS DISTINCT FROM true THEN RAISE EXCEPTION '[CHECKOUT_QUOTE_INVALID]' USING ERRCODE='22023'; END IF;
  SELECT jsonb_agg(jsonb_build_object('listing_id',l.id,'quantity',i.quantity,'sale_minor',(l.price*100*i.quantity)::bigint::text,
    'classification_ref',k.id,'classification',coalesce(k.classification,'unknown')) ORDER BY l.id),
    bool_and(coalesce(k.classification='ordinary',false)) INTO items,eligible
    FROM public.cart_items_v2 i JOIN public.shop_products l ON l.id=i.shop_product_id
    LEFT JOIN LATERAL (SELECT * FROM public.reward_product_classifications WHERE product_id=l.product_id ORDER BY revision DESC LIMIT 1) k ON true
    WHERE i.cart_id=p_cart;
  SELECT id INTO party_key FROM public.ledger_parties WHERE kind='customer' AND user_id=auth.uid();
  IF public._reward_enabled_e() AND party_key IS NOT NULL THEN PERFORM public._reward_mature_e(party_key); END IF;
  SELECT public._ledger_balance_h0(id) INTO balance_value FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_coupon';
  accepting:=public._checkout_accepted_e(shop_key);
  fingerprint:=encode(extensions.digest(jsonb_build_array(quote->>'fingerprint',items,accepting)::text,'sha256'),'hex');
  RETURN jsonb_build_object('version',1,'cart_id',p_cart,'shop_id',shop_key,'server_now',clock_timestamp(),'currency','TRY',
    'enabled',public._checkout_enabled_e(),'fingerprint',fingerprint,'sale_minor',((quote->>'minor')::numeric::bigint)::text,
    'coupon_available_minor',coalesce(balance_value,0)::text,
    'maximum_coupon_minor',CASE WHEN public._checkout_enabled_e() AND eligible AND accepting
      THEN least(coalesce(balance_value,0),(quote->>'minor')::numeric)::bigint::text ELSE '0' END,
    'eligibility',CASE WHEN NOT eligible THEN 'classification_unavailable' WHEN NOT accepting THEN 'merchant_not_accepting' ELSE 'eligible' END,
    'items',items);
END $e$;
CREATE FUNCTION public.preview_coupon_checkout_v1(p_cart uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE existing jsonb; approval public.reward_checkout_approvals; shop_key uuid; available numeric;
BEGIN
  PERFORM public._reward_customer_e();
  PERFORM id FROM public.carts WHERE id=p_cart AND user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[CHECKOUT_CART_ACCESS]' USING ERRCODE='42501'; END IF;
  PERFORM public._reward_lock_e();
  SELECT a.* INTO approval FROM public.reward_checkout_approvals a JOIN public.qr_sessions q ON q.id=a.qr_ref
    WHERE q.cart_id=p_cart AND q.user_id=auth.uid() AND q.status IN ('active','used') ORDER BY q.created_at DESC LIMIT 1;
  IF approval.qr_ref IS NOT NULL THEN
    SELECT shop_id INTO shop_key FROM public.qr_sessions WHERE id=approval.qr_ref;
    existing:=public._qr_customer_payload_b(approval.qr_ref);
    IF existing->>'status' IN ('active','claimed','used') THEN
      SELECT public._ledger_balance_h0(id) INTO available FROM public.ledger_accounts WHERE party_id=approval.customer_party AND code='customer_coupon';
      RETURN jsonb_build_object('version',1,'cart_id',p_cart,'shop_id',shop_key,'currency','TRY','server_now',clock_timestamp(),
        'enabled',public._checkout_enabled_e(),'fingerprint',approval.fingerprint,'sale_minor',approval.sale_minor::text,
        'coupon_available_minor',coalesce(available,0)::text,'maximum_coupon_minor','0','eligibility','eligible','existing_qr',existing);
    END IF;
  END IF;
  RETURN public._checkout_cart_e(p_cart);
END $e$;
CREATE FUNCTION public._checkout_allocate_e(p_items jsonb,p_coupon bigint) RETURNS jsonb LANGUAGE sql IMMUTABLE SET search_path='' AS $e$
  WITH items AS (SELECT x,(x->>'listing_id')::uuid id,(x->>'sale_minor')::numeric sale FROM jsonb_array_elements(p_items) x),
  portions AS (SELECT *,coalesce(trunc(sale*p_coupon/nullif(sum(sale) OVER(),0)),0) base,
    coalesce(mod(sale*p_coupon,nullif(sum(sale) OVER(),0)),0) remainder FROM items),
  ranked AS (SELECT *,row_number() OVER(ORDER BY remainder DESC,id) rank,p_coupon-sum(base) OVER() extra FROM portions)
  SELECT jsonb_agg(x||jsonb_build_object('coupon_minor',(base+CASE WHEN rank<=extra THEN 1 ELSE 0 END)::bigint::text) ORDER BY id) FROM ranked
$e$;
CREATE FUNCTION public.create_coupon_qr_v1(p_cart uuid,p_request uuid,p_fingerprint text,p_coupon_minor text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE party_key uuid; sid uuid; preview jsonb; payload jsonb; qid uuid; approval public.reward_checkout_approvals; amount_value bigint;
BEGIN
  PERFORM public._reward_customer_e(); sid:=public._qr_auth_session_b();
  PERFORM id FROM public.carts WHERE id=p_cart AND user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[CHECKOUT_CART_ACCESS]' USING ERRCODE='42501'; END IF;
  PERFORM public._reward_lock_e();
  IF p_request IS NULL OR p_fingerprint IS NULL OR p_fingerprint !~ '^[a-f0-9]{64}$'
    OR p_coupon_minor IS NULL OR p_coupon_minor !~ '^[1-9][0-9]{0,18}$' OR p_coupon_minor::numeric>9223372036854775807 THEN
    RAISE EXCEPTION '[CHECKOUT_ARGUMENT]' USING ERRCODE='22023'; END IF;
  amount_value:=p_coupon_minor::bigint;
  party_key:=public.ensure_ledger_party_v1('customer',auth.uid());
  SELECT * INTO approval FROM public.reward_checkout_approvals WHERE customer_party=party_key AND request_id=p_request;
  IF FOUND THEN
    IF approval.auth_session_id<>sid OR approval.fingerprint<>p_fingerprint OR approval.coupon_minor<>amount_value
      OR NOT EXISTS(SELECT 1 FROM public.qr_sessions WHERE id=approval.qr_ref AND cart_id=p_cart) THEN
      RAISE EXCEPTION '[CHECKOUT_REPLAY_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN public.get_qr_session_status_v2(approval.qr_ref);
  END IF;
  IF NOT public._checkout_enabled_e() THEN RAISE EXCEPTION '[CHECKOUT_DISABLED]' USING ERRCODE='55000'; END IF;
  preview:=public._checkout_cart_e(p_cart);
  IF preview->>'fingerprint'<>p_fingerprint THEN RAISE EXCEPTION '[CHECKOUT_QUOTE_CHANGED]' USING ERRCODE='40001'; END IF;
  IF amount_value>(preview->>'maximum_coupon_minor')::bigint THEN RAISE EXCEPTION '[CHECKOUT_COUPON_UNAVAILABLE]' USING ERRCODE='22023'; END IF;
  -- Never retrofit consent to a QR already exposed to a merchant or to old clients.
  IF EXISTS(SELECT 1 FROM public.qr_sessions q WHERE q.cart_id=p_cart AND q.status='active'
    AND public._qr_customer_payload_b(q.id)->>'status' IN ('active','claimed')) THEN
    RAISE EXCEPTION '[CHECKOUT_EXISTING_QR]' USING ERRCODE='55000'; END IF;
  payload:=public.create_reward_qr_v1(p_cart); qid:=(payload->>'id')::uuid;
  IF qid IS NULL THEN RAISE EXCEPTION '[CHECKOUT_QR_UNAVAILABLE]' USING ERRCODE='55000'; END IF;
  INSERT INTO public.reward_checkout_approvals(qr_ref,customer_party,auth_session_id,request_id,fingerprint,sale_minor,coupon_minor,allocation)
    VALUES(qid,party_key,sid,p_request,p_fingerprint,(preview->>'sale_minor')::bigint,amount_value,
      public._checkout_allocate_e(preview->'items',amount_value));
  RETURN public.get_qr_session_status_v2(qid);
END $e$;

-- Remaining workflow definitions below share B's QR, H0's journal and E's epoch.
ALTER TABLE public.purchase_terms DROP CONSTRAINT purchase_terms_ev_coupon_minor_check;
ALTER TABLE public.purchase_terms ADD CONSTRAINT purchase_terms_coupon_e_check CHECK(ev_coupon_minor BETWEEN 0 AND final_sale_minor);
ALTER TABLE public.purchase_terms DROP CONSTRAINT purchase_terms_policy_version_check;
ALTER TABLE public.purchase_terms ADD CONSTRAINT purchase_terms_policy_e_check CHECK(policy_version IN ('quote_only_b_v1','coupon_checkout_e_v1'));
ALTER TABLE public.purchase_terms DROP CONSTRAINT purchase_terms_return_policy_version_check;
ALTER TABLE public.purchase_terms ADD CONSTRAINT purchase_terms_return_policy_e_check CHECK(return_policy_version IN ('unspecified','reward_snapshot_e_v1'));
ALTER TABLE public.purchase_terms DROP CONSTRAINT purchase_terms_voluntary_return_seconds_check;
ALTER TABLE public.purchase_terms ADD CONSTRAINT purchase_terms_return_seconds_e_check CHECK(voluntary_return_seconds IS NULL OR voluntary_return_seconds>=0);
ALTER TABLE public.purchase_return_items DROP CONSTRAINT purchase_return_items_ev_coupon_return_minor_check;
ALTER TABLE public.purchase_return_items ADD CONSTRAINT purchase_return_coupon_e_check CHECK(ev_coupon_return_minor BETWEEN 0 AND sale_return_minor);

CREATE FUNCTION public._checkout_terms_payload_e(p_qr uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT jsonb_build_object('version',1,'sale_minor',sale_minor::text,'coupon_minor',coupon_minor::text,
    'payment_minor',(sale_minor-coupon_minor)::text,'approved_at',approved_at,'fingerprint',fingerprint)
  FROM public.reward_checkout_approvals WHERE qr_ref=p_qr
$e$;
ALTER FUNCTION public._qr_customer_payload_b(uuid) RENAME TO _qr_customer_payload_before_checkout;
CREATE OR REPLACE FUNCTION public._qr_customer_payload_b(p_id uuid) RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path='' AS $e$
  SELECT public._qr_customer_payload_before_checkout(p_id)||jsonb_build_object('coupon_checkout',public._checkout_terms_payload_e(p_id))
$e$;
ALTER FUNCTION public._qr_verification_payload_b(uuid) RENAME TO _qr_verification_payload_before_checkout;
CREATE OR REPLACE FUNCTION public._qr_verification_payload_b(p_id uuid) RETURNS jsonb LANGUAGE sql SECURITY DEFINER SET search_path='' AS $e$
  SELECT public._qr_verification_payload_before_checkout(p_id)||jsonb_build_object('coupon_checkout',public._checkout_terms_payload_e(p_id))
$e$;
ALTER FUNCTION public.complete_reward_qr_v1(uuid,uuid,text) RENAME TO _complete_reward_qr_before_checkout;
CREATE OR REPLACE FUNCTION public.complete_reward_qr_v1(p_claim_id uuid,p_installation_id uuid,p_actual_sale_minor text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE claim_row public.qr_claims;
BEGIN
  claim_row:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  IF EXISTS(SELECT 1 FROM public.reward_checkout_approvals WHERE qr_ref=claim_row.qr_session_id) THEN
    RAISE EXCEPTION '[CHECKOUT_CONFIRMATION_REQUIRED]' USING ERRCODE='55000'; END IF;
  RETURN public._complete_reward_qr_before_checkout(p_claim_id,p_installation_id,p_actual_sale_minor);
END $e$;
CREATE FUNCTION public.complete_coupon_qr_v1(p_claim_id uuid,p_installation_id uuid,p_sale_minor text,p_coupon_minor text,p_payment_minor text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE claim_row public.qr_claims; approval public.reward_checkout_approvals;
BEGIN
  claim_row:=public._qr_owned_claim_b(p_claim_id,p_installation_id);
  PERFORM c.id FROM public.carts c JOIN public.qr_sessions q ON q.cart_id=c.id WHERE q.id=claim_row.qr_session_id FOR UPDATE OF c;
  PERFORM public._reward_lock_e();
  SELECT * INTO approval FROM public.reward_checkout_approvals WHERE qr_ref=claim_row.qr_session_id;
  IF approval.qr_ref IS NULL OR p_sale_minor IS DISTINCT FROM approval.sale_minor::text
    OR p_coupon_minor IS DISTINCT FROM approval.coupon_minor::text OR p_payment_minor IS DISTINCT FROM (approval.sale_minor-approval.coupon_minor)::text THEN
    RAISE EXCEPTION '[CHECKOUT_ATTESTATION_MISMATCH]' USING ERRCODE='22023'; END IF;
  -- Exact receipts remain reconcilable after gate-off; no second debit occurs.
  INSERT INTO public.reward_sale_attestations(qr_ref,claim_ref,actual_sale_minor)
    VALUES(approval.qr_ref,claim_row.id,approval.sale_minor) ON CONFLICT DO NOTHING;
  RETURN public._complete_existing_qr_before_e(p_claim_id,p_installation_id);
END $e$;

CREATE FUNCTION public._checkout_purchase_terms_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE approval public.reward_checkout_approvals; contract public.reward_qr_contracts; purchase_row public.verified_transactions;
  merchant_party uuid; reserve_key uuid; pending_key uuid; coupon_key uuid; account_key uuid; source_key uuid; journal_key uuid;
  reserve_part bigint; cap bigint; lines jsonb; allocation jsonb; remaining bigint; take_value bigint; item record;
BEGIN
  SELECT * INTO STRICT purchase_row FROM public.verified_transactions WHERE id=NEW.purchase_id;
  SELECT * INTO approval FROM public.reward_checkout_approvals WHERE qr_ref=purchase_row.source_qr_session_id;
  IF NOT FOUND THEN RETURN NEW; END IF;
  PERFORM public._reward_lock_e();
  SELECT * INTO STRICT contract FROM public.reward_qr_contracts WHERE qr_ref=approval.qr_ref;
  IF NOT EXISTS(SELECT 1 FROM public.reward_sale_attestations WHERE qr_ref=approval.qr_ref AND claim_ref=NEW.claim_id AND actual_sale_minor=approval.sale_minor)
    OR NEW.quoted_minor<>approval.sale_minor THEN RAISE EXCEPTION '[CHECKOUT_UNATTESTED]' USING ERRCODE='55000'; END IF;
  -- Consent belongs to a live customer session, even when a merchant finalizes.
  PERFORM s.id FROM auth.sessions s JOIN public.ledger_parties p ON p.user_id=s.user_id
    WHERE s.id=approval.auth_session_id AND p.id=approval.customer_party AND (s.not_after IS NULL OR s.not_after>clock_timestamp()) FOR SHARE OF s;
  IF NOT FOUND THEN RAISE EXCEPTION '[CHECKOUT_CUSTOMER_SESSION_ENDED]' USING ERRCODE='28000'; END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(approval.allocation) x
    JOIN public.shop_products l ON l.id=(x->>'listing_id')::uuid
    LEFT JOIN LATERAL(SELECT * FROM public.reward_product_classifications WHERE product_id=l.product_id ORDER BY revision DESC LIMIT 1) k ON true
    WHERE k.id IS DISTINCT FROM (x->>'classification_ref')::uuid OR k.classification IS DISTINCT FROM 'ordinary') THEN
    RAISE EXCEPTION '[CHECKOUT_CLASSIFICATION_CHANGED]' USING ERRCODE='55000'; END IF;
  merchant_party:=public.ensure_ledger_party_v1('merchant',purchase_row.shop_id);
  reserve_key:=public._reward_account_e(merchant_party,'merchant_reserve');
  pending_key:=public._reward_account_e(merchant_party,'merchant_coupon_pending');
  coupon_key:=public._reward_account_e(approval.customer_party,'customer_coupon');
  -- Lock complete account set before calculating reserve allocation, in UUID order.
  FOR account_key IN SELECT unnest(ARRAY[reserve_key,pending_key,coupon_key]) ORDER BY 1 LOOP
    UPDATE public.ledger_account_locks SET epoch=epoch+1 WHERE account_id=account_key;
  END LOOP;
  SELECT reserve_cap_minor INTO cap FROM public.commerce_policy_versions WHERE id=contract.policy_id;
  reserve_part:=least(approval.coupon_minor,greatest(0,cap-public._ledger_balance_h0(reserve_key))::bigint);
  lines:=jsonb_build_array(jsonb_build_object('account_id',coupon_key,'amount_minor',(-approval.coupon_minor)::text));
  IF reserve_part>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',reserve_key,'amount_minor',reserve_part::text)); END IF;
  IF approval.coupon_minor>reserve_part THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',pending_key,'amount_minor',(approval.coupon_minor-reserve_part)::text)); END IF;
  source_key:=public.record_commerce_source_v1('coupon_redemption',NEW.purchase_id,merchant_party,approval.coupon_minor,contract.policy_id,approval.qr_ref);
  journal_key:=public._post_balanced_journal_before_e(source_key,lines);
  INSERT INTO public.reward_coupon_redemptions(purchase_id,qr_ref,customer_party,amount_minor,journal_id)
    VALUES(NEW.purchase_id,approval.qr_ref,approval.customer_party,approval.coupon_minor,journal_key);
  remaining:=approval.coupon_minor;
  FOR item IN SELECT r.purchase_id,public._checkout_source_remaining_e(r.purchase_id) available
    FROM public.reward_coupons c JOIN public.reward_coupon_sources s ON s.coupon_id=c.id
    JOIN public.reward_contributions r ON r.purchase_id=s.purchase_id WHERE c.customer_party=approval.customer_party
    ORDER BY c.issued_at,c.id,r.earned_at,r.purchase_id LOOP
    take_value:=least(remaining,item.available);
    IF take_value>0 THEN
      INSERT INTO public.reward_source_uses(source_purchase,amount_minor,redemption_purchase,journal_id)
        VALUES(item.purchase_id,take_value,NEW.purchase_id,journal_key); remaining:=remaining-take_value;
    END IF;
    EXIT WHEN remaining=0;
  END LOOP;
  IF remaining<>0 THEN RAISE EXCEPTION '[CHECKOUT_BALANCE_CHANGED]' USING ERRCODE='40001'; END IF;
  SELECT jsonb_agg(jsonb_build_object('purchase_item_id',i.id,'quantity',i.quantity,'sale_minor',x->>'sale_minor',
    'coupon_minor',x->>'coupon_minor') ORDER BY i.id) INTO allocation
    FROM public.verified_transaction_items i JOIN jsonb_array_elements(approval.allocation) x ON (x->>'listing_id')::uuid=i.shop_product_id
    WHERE i.verified_transaction_id=NEW.purchase_id;
  IF jsonb_array_length(allocation)<>jsonb_array_length(approval.allocation) THEN RAISE EXCEPTION '[CHECKOUT_ALLOCATION_MISMATCH]'; END IF;
  NEW.ev_coupon_minor:=approval.coupon_minor; NEW.policy_version:='coupon_checkout_e_v1';
  NEW.return_policy_version:='reward_snapshot_e_v1'; NEW.voluntary_return_seconds:=contract.voluntary_return_seconds;
  NEW.allocation_snapshot:=allocation; NEW.allocation_hash:=extensions.digest(convert_to(allocation::text,'UTF8'),'sha256');
  RETURN NEW;
END $e$;
CREATE TRIGGER checkout_purchase_terms BEFORE INSERT ON public.purchase_terms FOR EACH ROW EXECUTE FUNCTION public._checkout_purchase_terms_e();

-- Return evidence only: exact cumulative allocation; no cash refund/coupon restoration.
CREATE FUNCTION public._checkout_return_item_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE return_row public.purchase_returns; terms public.purchase_terms; allocation jsonb; quantity_value bigint; returned_value bigint; returned_sale numeric; returned_coupon numeric;
BEGIN
  SELECT * INTO STRICT return_row FROM public.purchase_returns WHERE id=NEW.return_id;
  SELECT * INTO STRICT terms FROM public.purchase_terms WHERE purchase_id=return_row.purchase_id;
  IF terms.policy_version<>'coupon_checkout_e_v1' THEN RETURN NEW; END IF;
  IF return_row.reverses_return_id IS NOT NULL THEN
    SELECT sale_return_minor,ev_coupon_return_minor INTO NEW.sale_return_minor,NEW.ev_coupon_return_minor
      FROM public.purchase_return_items WHERE return_id=return_row.reverses_return_id AND purchase_item_id=NEW.purchase_item_id;
    RETURN NEW;
  END IF;
  SELECT x INTO STRICT allocation FROM jsonb_array_elements(terms.allocation_snapshot) x WHERE (x->>'purchase_item_id')::uuid=NEW.purchase_item_id;
  quantity_value:=(allocation->>'quantity')::bigint;
  SELECT coalesce(sum(CASE WHEN r.return_kind='genuine' THEN i.quantity ELSE -i.quantity END),0),
    coalesce(sum(CASE WHEN r.return_kind='genuine' THEN i.sale_return_minor ELSE -i.sale_return_minor END),0),
    coalesce(sum(CASE WHEN r.return_kind='genuine' THEN i.ev_coupon_return_minor ELSE -i.ev_coupon_return_minor END),0)
    INTO returned_value,returned_sale,returned_coupon
    FROM public.purchase_return_items i JOIN public.purchase_returns r ON r.id=i.return_id WHERE i.purchase_item_id=NEW.purchase_item_id;
  NEW.sale_return_minor:=trunc(((allocation->>'sale_minor')::numeric-returned_sale)*NEW.quantity/(quantity_value-returned_value));
  NEW.ev_coupon_return_minor:=trunc(((allocation->>'coupon_minor')::numeric-returned_coupon)*NEW.quantity/(quantity_value-returned_value));
  RETURN NEW;
END $e$;
CREATE TRIGGER checkout_return_item BEFORE INSERT ON public.purchase_return_items FOR EACH ROW EXECUTE FUNCTION public._checkout_return_item_e();

CREATE OR REPLACE FUNCTION public._reward_post_e(p_kind text,p_ref uuid,p_party uuid,p_policy uuid,p_lines jsonb) RETURNS uuid
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
    WHERE a.currency<>'TRY' OR (a.code IN ('customer_future_offset','platform_offset_control') AND p_kind<>'reward_compensation')
      OR (a.code='merchant_reserve' AND (x->>'amount_minor')::bigint>0)
      OR (a.code NOT IN ('platform_clearing','platform_offset_control') AND public._ledger_balance_h0(a.id)+(x->>'amount_minor')::bigint<0)) THEN
    RAISE EXCEPTION '[REWARD_POST_OVERDRAFT_OR_SOURCE]' USING ERRCODE='22023'; END IF;
  INSERT INTO public.ledger_journals(source_id,posting_count,postings_hash) VALUES(source_key,n,digest_value) RETURNING * INTO posted;
  INSERT INTO public.ledger_postings(journal_id,account_id,amount_minor)
    SELECT posted.id,(x->>'account_id')::uuid,(x->>'amount_minor')::bigint FROM jsonb_array_elements(normalized) x;
  RETURN posted.id;
END $e$;
CREATE OR REPLACE FUNCTION public._reward_earn_e(p_purchase uuid,p_event uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
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
    OR terms_row.final_sale_minor<>contract.quoted_minor OR (terms_row.ev_coupon_minor<>0 AND NOT EXISTS(SELECT 1 FROM public.reward_coupon_redemptions WHERE purchase_id=p_purchase AND amount_minor=terms_row.ev_coupon_minor)) THEN
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
ALTER FUNCTION public._reward_compensate_e(uuid,uuid,text,timestamptz) RENAME TO _reward_compensate_before_checkout;
CREATE OR REPLACE FUNCTION public._reward_compensate_e(p_purchase uuid,p_event uuid,p_kind text,p_occurred timestamptz) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE contribution public.reward_contributions; pack public.referral_packages; spent bigint; unspent bigint;
  platform_party uuid; journal_key uuid; coupon_key uuid; lines jsonb;
BEGIN
  SELECT * INTO contribution FROM public.reward_contributions WHERE purchase_id=p_purchase;
  IF NOT FOUND OR EXISTS(SELECT 1 FROM public.reward_contribution_events WHERE source_ref=p_event) THEN RETURN; END IF;
  SELECT coalesce(sum(amount_minor),0) INTO spent FROM public.reward_source_uses WHERE source_purchase=p_purchase;
  IF spent=0 OR p_kind<>'purchase_invalidated' THEN
    PERFORM public._reward_compensate_before_checkout(p_purchase,p_event,p_kind,p_occurred); RETURN;
  END IF;
  IF (SELECT sum(delta) FROM public.reward_contribution_events WHERE purchase_id=p_purchase)<>1 THEN RETURN; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.purchase_invalidations WHERE purchase_id=p_purchase) OR spent>contribution.amount_minor THEN
    RAISE EXCEPTION '[CHECKOUT_OFFSET_EVIDENCE]' USING ERRCODE='23514'; END IF;
  SELECT * INTO STRICT pack FROM public.referral_packages WHERE id=contribution.package_id;
  SELECT coupon_id INTO STRICT coupon_key FROM public.reward_coupon_sources WHERE purchase_id=p_purchase;
  platform_party:=public.ensure_ledger_party_v1('platform',NULL); unspent:=contribution.amount_minor-spent;
  lines:=jsonb_build_array(
    jsonb_build_object('account_id',public._reward_account_e(pack.party_id,'package_free'),'amount_minor',contribution.amount_minor::text),
    jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_clearing'),'amount_minor',(-spent)::text),
    jsonb_build_object('account_id',public._reward_account_e(contribution.customer_party,'customer_future_offset'),'amount_minor',spent::text),
    jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_offset_control'),'amount_minor',(-spent)::text));
  IF unspent>0 THEN lines:=lines||jsonb_build_array(jsonb_build_object('account_id',public._reward_account_e(contribution.customer_party,'customer_coupon'),'amount_minor',(-unspent)::text)); END IF;
  journal_key:=public._reward_post_e('reward_compensation',p_event,contribution.customer_party,contribution.policy_id,lines);
  INSERT INTO public.reward_spent_offsets(source_purchase,customer_party,invalidation_event,amount_minor,journal_id)
    VALUES(p_purchase,contribution.customer_party,p_event,spent,journal_key);
  INSERT INTO public.reward_contribution_events(purchase_id,source_ref,delta,reason,coupon_id,journal_id)
    VALUES(p_purchase,p_event,-1,'invalidated',coupon_key,journal_key);
  INSERT INTO public.reward_capacity_events(package_id,source_ref,kind,free_delta,held_delta,consumed_delta,expired_delta,journal_id)
    VALUES(pack.id,p_event,'restore',1,0,-1,0,journal_key);
  PERFORM public._reward_expire_package_e(pack.id);
END $e$;

-- Pending sources may still be genuinely returned. Offset recovery happens at
-- mature issuance, in the same transaction before any spendable value appears.
CREATE FUNCTION public._checkout_recover_mature_e(p_sources uuid[],p_party uuid,p_policy uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE obligation record; source_key uuid; available bigint; recover_value bigint; remaining bigint; take_value bigint;
  platform_party uuid; journal_key uuid; last_journal uuid;
BEGIN
  platform_party:=public.ensure_ledger_party_v1('platform',NULL);
  FOR obligation IN SELECT o.*,o.amount_minor-coalesce((SELECT sum(amount_minor) FROM public.reward_source_uses WHERE offset_id=o.id),0) outstanding
    FROM public.reward_spent_offsets o WHERE o.customer_party=p_party ORDER BY o.created_at,o.id LOOP
    SELECT coalesce(sum(public._checkout_source_remaining_e(x)),0) INTO available FROM unnest(p_sources) x;
    recover_value:=least(available,obligation.outstanding); CONTINUE WHEN recover_value=0;
    journal_key:=public._reward_post_e('reward_compensation',gen_random_uuid(),p_party,p_policy,jsonb_build_array(
      jsonb_build_object('account_id',public._reward_account_e(p_party,'customer_pending'),'amount_minor',(-recover_value)::text),
      jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_clearing'),'amount_minor',recover_value::text),
      jsonb_build_object('account_id',public._reward_account_e(p_party,'customer_future_offset'),'amount_minor',(-recover_value)::text),
      jsonb_build_object('account_id',public._reward_account_e(platform_party,'platform_offset_control'),'amount_minor',recover_value::text)));
    remaining:=recover_value;
    FOREACH source_key IN ARRAY p_sources LOOP
      take_value:=least(remaining,public._checkout_source_remaining_e(source_key));
      IF take_value>0 THEN INSERT INTO public.reward_source_uses(source_purchase,amount_minor,offset_id,journal_id)
        VALUES(source_key,take_value,obligation.id,journal_key); remaining:=remaining-take_value; END IF;
      EXIT WHEN remaining=0;
    END LOOP;
    IF remaining<>0 THEN RAISE EXCEPTION '[CHECKOUT_OFFSET_ALLOCATION]'; END IF;
    last_journal:=journal_key;
  END LOOP;
  RETURN last_journal;
END $e$;


CREATE OR REPLACE FUNCTION public._reward_mature_e(p_party uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE sources uuid[]; policy_key uuid; source_total numeric; latest_maturity timestamptz; policy_row public.commerce_policy_versions;
  coupon_key uuid; journal_key uuid; batch integer; distinct_policies integer; effective_total bigint; recovery_journal uuid;
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
    recovery_journal:=public._checkout_recover_mature_e(sources,p_party,policy_key);
    SELECT sum(public._checkout_source_remaining_e(x)) INTO effective_total FROM unnest(sources) x;
    IF effective_total>0 THEN
    journal_key:=public._reward_transfer_e('reward_capacity',coupon_key,p_party,policy_key,
      public._reward_account_e(p_party,'customer_pending'),public._reward_account_e(p_party,'customer_coupon'),effective_total);
    ELSE journal_key:=recovery_journal; END IF;
    INSERT INTO public.reward_coupons(id,customer_party,policy_id,face_minor,expires_at,journal_id)
      VALUES(coupon_key,p_party,policy_key,source_total::bigint,CASE WHEN policy_row.coupon_expiry_seconds IS NULL THEN NULL
        ELSE clock_timestamp()+make_interval(secs=>policy_row.coupon_expiry_seconds) END,journal_key);
    INSERT INTO public.reward_coupon_sources(coupon_id,purchase_id) SELECT coupon_key,unnest(sources);
  END LOOP;
END $e$;
CREATE OR REPLACE FUNCTION public._reward_customer_seal_e() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE party_key uuid; coupon_key uuid; expected_pending numeric; expected_coupon numeric; actual_pending numeric; actual_coupon numeric; expected_offset numeric; actual_offset numeric;
BEGIN
  IF TG_TABLE_NAME='reward_coupons' THEN party_key:=NEW.customer_party; coupon_key:=NEW.id;
  ELSIF TG_TABLE_NAME='reward_coupon_sources' THEN
    coupon_key:=NEW.coupon_id; SELECT customer_party INTO party_key FROM public.reward_coupons WHERE id=coupon_key;
  ELSIF TG_TABLE_NAME IN ('reward_source_uses','reward_spent_offsets') THEN
    SELECT customer_party INTO party_key FROM public.reward_contributions WHERE purchase_id=NEW.source_purchase;
  ELSIF TG_TABLE_NAME='reward_coupon_redemptions' THEN party_key:=NEW.customer_party;
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
  SELECT coalesce(sum(public._checkout_coupon_remaining_e(id)),0) INTO expected_coupon FROM public.reward_coupons WHERE customer_party=party_key;
  SELECT coalesce(sum(o.amount_minor-coalesce((SELECT sum(amount_minor) FROM public.reward_source_uses WHERE offset_id=o.id),0)),0)
    INTO expected_offset FROM public.reward_spent_offsets o WHERE o.customer_party=party_key;
  SELECT public._ledger_balance_h0(id) INTO actual_offset FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_future_offset';
  IF coalesce(actual_offset,0)<>expected_offset OR expected_offset<0 OR EXISTS(SELECT 1 FROM public.reward_contributions r WHERE r.customer_party=party_key
    AND coalesce((SELECT sum(amount_minor) FROM public.reward_source_uses WHERE source_purchase=r.purchase_id),0)>r.amount_minor) THEN
    RAISE EXCEPTION '[CHECKOUT_SOURCE_OFFSET_INVARIANT]' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM public.reward_spent_offsets o WHERE o.customer_party=party_key
    AND coalesce((SELECT sum(amount_minor) FROM public.reward_source_uses WHERE offset_id=o.id),0)>o.amount_minor)
    OR EXISTS(SELECT 1 FROM public.reward_source_uses u JOIN public.reward_contributions r ON r.purchase_id=u.source_purchase
      LEFT JOIN public.reward_spent_offsets o ON o.id=u.offset_id LEFT JOIN public.reward_coupon_redemptions d ON d.purchase_id=u.redemption_purchase
      WHERE r.customer_party=party_key AND (coalesce(o.customer_party,d.customer_party)<>party_key
        OR NOT EXISTS(SELECT 1 FROM public.reward_coupon_sources WHERE purchase_id=r.purchase_id))) THEN
    RAISE EXCEPTION '[CHECKOUT_SOURCE_OWNERSHIP_INVARIANT]' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM public.reward_coupon_redemptions d WHERE d.customer_party=party_key AND d.amount_minor IS DISTINCT FROM
    (SELECT sum(amount_minor) FROM public.reward_source_uses WHERE redemption_purchase=d.purchase_id)) THEN
    RAISE EXCEPTION '[CHECKOUT_REDEMPTION_INVARIANT]' USING ERRCODE='23514'; END IF;
  SELECT public._ledger_balance_h0(id) INTO actual_pending FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_pending';
  SELECT public._ledger_balance_h0(id) INTO actual_coupon FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_coupon';
  IF coalesce(actual_pending,0)<>expected_pending OR coalesce(actual_coupon,0)<>expected_coupon THEN
    RAISE EXCEPTION '[REWARD_CUSTOMER_ACCOUNT_INVARIANT]' USING ERRCODE='23514'; END IF;
  RETURN NULL;
END $e$;
CREATE OR REPLACE FUNCTION public.read_reward_state_v1() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
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
    'remaining_minor',public._checkout_coupon_remaining_e(c.id)::text) ORDER BY c.issued_at DESC,c.id),'[]'::jsonb)
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
    'merchants',CASE WHEN public._reward_enabled_e() THEN merchants ELSE '[]'::jsonb END,'redemption_enabled',false,'currency','TRY','checkout_enabled',public._checkout_enabled_e(),
    'future_offset_minor',coalesce((SELECT public._ledger_balance_h0(id) FROM public.ledger_accounts WHERE party_id=party_key AND code='customer_future_offset'),0)::text);
END $e$;
CREATE OR REPLACE FUNCTION public._purchase_read_b(p_purchase_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT to_jsonb(v)||jsonb_build_object('terms_classification',CASE WHEN t.purchase_id IS NULL THEN 'legacy_unclassified' ELSE t.policy_version END,
     'final_sale_minor',CASE WHEN t.policy_version='coupon_checkout_e_v1' THEN to_jsonb(t.final_sale_minor::text) ELSE to_jsonb(t.final_sale_minor) END,
    'ev_coupon_minor',CASE WHEN t.policy_version='coupon_checkout_e_v1' THEN to_jsonb(t.ev_coupon_minor::text) ELSE to_jsonb(t.ev_coupon_minor) END,
    'customer_payment_minor',CASE WHEN t.policy_version='coupon_checkout_e_v1' THEN to_jsonb(t.customer_payment_minor::text) ELSE to_jsonb(t.customer_payment_minor) END,
    'coupon_restoration_executed',false,
    'return_policy_version',t.return_policy_version,'invalidated',EXISTS(SELECT 1 FROM public.purchase_invalidations z WHERE z.purchase_id=v.id),
    'items',(SELECT jsonb_agg(to_jsonb(i)||jsonb_build_object('returned_quantity',COALESCE((
      SELECT sum(CASE WHEN r.return_kind='genuine' THEN ri.quantity ELSE -ri.quantity END)
      FROM public.purchase_return_items ri JOIN public.purchase_returns r ON r.id=ri.return_id WHERE ri.purchase_item_id=i.id),0)) ORDER BY i.id)
      FROM public.verified_transaction_items i WHERE i.verified_transaction_id=v.id),
    'returns',COALESCE((SELECT jsonb_agg(jsonb_build_object('id',r.id,'return_kind',r.return_kind,'occurred_at',r.occurred_at,
      'reverses_return_id',r.reverses_return_id,'refund_executed',false,
      'items',(SELECT jsonb_agg(jsonb_build_object('purchase_item_id',i.purchase_item_id,'quantity',i.quantity,'sale_return_minor',CASE WHEN t.policy_version='coupon_checkout_e_v1' THEN to_jsonb(i.sale_return_minor::text) ELSE to_jsonb(i.sale_return_minor) END,'ev_coupon_return_minor',i.ev_coupon_return_minor::text)
        ORDER BY i.purchase_item_id) FROM public.purchase_return_items i WHERE i.return_id=r.id)) ORDER BY r.occurred_at,r.id)
      FROM public.purchase_returns r WHERE r.purchase_id=v.id),'[]'::jsonb))
  - 'customer_user_id' - 'confirmed_by_user_id'
  FROM public.verified_transactions v LEFT JOIN public.purchase_terms t ON t.purchase_id=v.id WHERE v.id=p_purchase_id
$body$;
CREATE FUNCTION public.coupon_checkout_capabilities_v1() RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $e$
  SELECT jsonb_build_object('version',1,'enabled',public._checkout_enabled_e(),'currency','TRY',
    'cash_refunds_enabled',false,'coupon_restoration_enabled',false,'merchant_price_amendment_enabled',false)
$e$;
CREATE CONSTRAINT TRIGGER checkout_use_sealed AFTER INSERT ON public.reward_source_uses DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();
CREATE CONSTRAINT TRIGGER checkout_offset_sealed AFTER INSERT ON public.reward_spent_offsets DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();
CREATE CONSTRAINT TRIGGER checkout_redemption_sealed AFTER INSERT ON public.reward_coupon_redemptions DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._reward_customer_seal_e();
ALTER TABLE public.reward_checkout_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_product_classifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_checkout_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_coupon_redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_source_uses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_spent_offsets ENABLE ROW LEVEL SECURITY;
DO $security$ DECLARE name text; BEGIN
  FOREACH name IN ARRAY ARRAY['reward_checkout_config','reward_product_classifications','reward_checkout_approvals',
    'reward_coupon_redemptions','reward_source_uses','reward_spent_offsets'] LOOP
    EXECUTE format('REVOKE ALL ON public.%I FROM PUBLIC,anon,authenticated,service_role',name);
    IF name<>'reward_checkout_config' THEN
      EXECUTE format('CREATE TRIGGER checkout_immutable BEFORE UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b()',name);
    END IF;
  END LOOP;
END $security$;
REVOKE ALL ON FUNCTION public._checkout_enabled_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_accepted_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_source_remaining_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_coupon_remaining_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.attest_reward_product_classification_v1(uuid,text,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_cart_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.preview_coupon_checkout_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_allocate_e(jsonb,bigint) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.create_coupon_qr_v1(uuid,uuid,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_terms_payload_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_customer_payload_before_checkout(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_customer_payload_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_verification_payload_before_checkout(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._qr_verification_payload_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._complete_reward_qr_before_checkout(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.complete_reward_qr_v1(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.complete_coupon_qr_v1(uuid,uuid,text,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_purchase_terms_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_return_item_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_compensate_before_checkout(uuid,uuid,text,timestamp with time zone) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._reward_compensate_e(uuid,uuid,text,timestamp with time zone) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_recover_mature_e(uuid[],uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.coupon_checkout_capabilities_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON SEQUENCE public.reward_product_classifications_revision_seq FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.coupon_checkout_capabilities_v1() TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.preview_coupon_checkout_v1(uuid),public.create_coupon_qr_v1(uuid,uuid,text,text),
  public.complete_coupon_qr_v1(uuid,uuid,text,text,text),public.complete_reward_qr_v1(uuid,uuid,text) TO authenticated;
CREATE FUNCTION public.read_customer_checkout_terms_v1(p_purchase_ids uuid[]) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  PERFORM public._reward_customer_e();
  IF p_purchase_ids IS NULL OR cardinality(p_purchase_ids) NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION '[CHECKOUT_ARGUMENT]' USING ERRCODE='22023'; END IF;
  RETURN (SELECT coalesce(jsonb_agg(jsonb_build_object('purchase_id',v.id,'coupon_checkout',public._checkout_terms_payload_e(d.qr_ref)) ORDER BY v.id),'[]'::jsonb)
    FROM public.verified_transactions v JOIN public.reward_coupon_redemptions d ON d.purchase_id=v.id
    WHERE v.customer_user_id=auth.uid() AND v.id=ANY(p_purchase_ids));
END $e$;
REVOKE ALL ON FUNCTION public.read_customer_checkout_terms_v1(uuid[]) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.read_customer_checkout_terms_v1(uuid[]) TO authenticated;
COMMIT;
