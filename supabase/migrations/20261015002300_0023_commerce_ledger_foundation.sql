-- H0: inert accounting substrate. No funding/provider, reward or payout activation.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.commerce_events') IS NULL OR to_regclass('public.campaign_revisions') IS NULL
    OR to_regprocedure('public._qr_auth_session_b()') IS NULL THEN
    RAISE EXCEPTION '0023 requires integrated B/C/D/F';
  END IF;
END $preflight$;

CREATE TABLE public.commerce_policy_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), version integer NOT NULL UNIQUE CHECK(version>0),
  currency text NOT NULL CHECK(currency='TRY'),
  eligible_minimum_minor bigint NOT NULL CHECK(eligible_minimum_minor>0),
  cycle_purchases integer NOT NULL CHECK(cycle_purchases BETWEEN 1 AND 100),
  contribution_minor bigint NOT NULL CHECK(contribution_minor>0),
  coupon_minor bigint NOT NULL CHECK(coupon_minor=cycle_purchases::numeric*contribution_minor),
  package_slots integer NOT NULL CHECK(package_slots BETWEEN 1 AND 100000),
  package_fund_minor bigint NOT NULL CHECK(package_fund_minor=package_slots::numeric*contribution_minor),
  package_fee_minor bigint NOT NULL CHECK(package_fee_minor>=0),
  package_seconds integer NOT NULL CHECK(package_seconds>0),
  reservation_seconds integer NOT NULL CHECK(reservation_seconds>0),
  minimum_maturity_seconds integer NOT NULL CHECK(minimum_maturity_seconds>0),
  reserve_cap_minor bigint NOT NULL CHECK(reserve_cap_minor>=0),
  coupon_expiry_seconds integer CHECK(coupon_expiry_seconds>0),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
INSERT INTO public.commerce_policy_versions(version,currency,eligible_minimum_minor,cycle_purchases,contribution_minor,
  coupon_minor,package_slots,package_fund_minor,package_fee_minor,package_seconds,reservation_seconds,
  minimum_maturity_seconds,reserve_cap_minor,coupon_expiry_seconds)
VALUES(1,'TRY',50000,5,5000,25000,100,500000,75000,7776000,1800,86400,100000,NULL);
CREATE TABLE public.commerce_ledger_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), enabled boolean NOT NULL DEFAULT false,
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id)
);
INSERT INTO public.commerce_ledger_config(policy_id) SELECT id FROM public.commerce_policy_versions WHERE version=1;

CREATE TABLE public.ledger_parties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), kind text NOT NULL CHECK(kind IN ('platform','merchant','customer','package')),
  shop_id uuid REFERENCES public.shops(id) ON DELETE RESTRICT,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  package_ref uuid, recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  CHECK(((kind='platform' AND shop_id IS NULL AND user_id IS NULL AND package_ref IS NULL)
    OR (kind='merchant' AND shop_id IS NOT NULL AND user_id IS NULL AND package_ref IS NULL)
    OR (kind='customer' AND shop_id IS NULL AND package_ref IS NULL)
    OR (kind='package' AND shop_id IS NOT NULL AND user_id IS NULL AND package_ref IS NOT NULL)) IS TRUE)
);
CREATE UNIQUE INDEX ledger_one_platform ON public.ledger_parties(kind) WHERE kind='platform';
CREATE UNIQUE INDEX ledger_merchant_party ON public.ledger_parties(shop_id) WHERE kind='merchant';
CREATE UNIQUE INDEX ledger_customer_party ON public.ledger_parties(user_id) WHERE kind='customer' AND user_id IS NOT NULL;
CREATE UNIQUE INDEX ledger_package_party ON public.ledger_parties(package_ref) WHERE kind='package';
CREATE TABLE public.ledger_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), party_id uuid NOT NULL REFERENCES public.ledger_parties(id),
  code text NOT NULL CHECK(code IN ('platform_clearing','platform_service','platform_offset_control',
    'merchant_reserve','merchant_coupon_pending','merchant_coupon_available','merchant_unused_pending','merchant_unused_available',
    'customer_pending','customer_coupon','customer_future_offset','package_free','package_held')),
  currency text NOT NULL DEFAULT 'TRY' CHECK(currency='TRY'),
  UNIQUE(party_id,code)
);
-- Operational serialization only. Never a mutable monetary balance.
CREATE TABLE public.ledger_account_locks (
  account_id uuid PRIMARY KEY REFERENCES public.ledger_accounts(id), epoch numeric NOT NULL DEFAULT 0 CHECK(epoch>=0)
);
CREATE TABLE public.ledger_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind text NOT NULL CHECK(kind IN ('coupon_redemption','unused_package_fund','platform_service','receivable_release',
    'package_funding','reward_issue','return','admin_reversal','offset_created','offset_recovered')),
  source_id uuid NOT NULL, party_id uuid NOT NULL REFERENCES public.ledger_parties(id),
  amount_minor bigint NOT NULL CHECK(amount_minor>0), currency text NOT NULL DEFAULT 'TRY' CHECK(currency='TRY'),
  policy_id uuid NOT NULL REFERENCES public.commerce_policy_versions(id),
  evidence_ref uuid NOT NULL, related_journal uuid, accrual_journal uuid,
  reason text NOT NULL DEFAULT '' CHECK(length(reason)<=500),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(), UNIQUE(kind,source_id),
  CHECK(((kind IN ('admin_reversal','offset_created','offset_recovered') AND related_journal IS NOT NULL AND length(btrim(reason))>0)
    OR (kind NOT IN ('admin_reversal','offset_created','offset_recovered') AND related_journal IS NULL)) IS TRUE),
  CHECK((kind='offset_recovered')=(accrual_journal IS NOT NULL))
);
CREATE TABLE public.ledger_journals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), source_id uuid NOT NULL UNIQUE REFERENCES public.ledger_sources(id),
  posting_count integer NOT NULL CHECK(posting_count BETWEEN 2 AND 32),
  postings_hash bytea NOT NULL CHECK(octet_length(postings_hash)=32),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE public.ledger_sources ADD FOREIGN KEY(related_journal) REFERENCES public.ledger_journals(id);
ALTER TABLE public.ledger_sources ADD FOREIGN KEY(accrual_journal) REFERENCES public.ledger_journals(id);
CREATE UNIQUE INDEX ledger_one_reversal ON public.ledger_sources(related_journal) WHERE kind='admin_reversal';
CREATE TABLE public.ledger_postings (
  journal_id uuid NOT NULL REFERENCES public.ledger_journals(id),
  account_id uuid NOT NULL REFERENCES public.ledger_accounts(id),
  amount_minor bigint NOT NULL CHECK(amount_minor<>0 AND amount_minor>=-9223372036854775807),
  PRIMARY KEY(journal_id,account_id)
);
CREATE INDEX ledger_postings_account ON public.ledger_postings(account_id,journal_id);
CREATE TABLE public.ledger_consumer_receipts (
  consumer text NOT NULL CHECK(length(consumer) BETWEEN 1 AND 80),
  event_id uuid NOT NULL REFERENCES public.commerce_events(id),
  journal_id uuid NOT NULL REFERENCES public.ledger_journals(id),
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(), PRIMARY KEY(consumer,event_id)
);

CREATE FUNCTION public._ledger_party_guard_h0() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $h0$
BEGIN
  IF TG_OP='UPDATE' AND OLD.kind='customer' AND OLD.user_id IS NOT NULL AND NEW.user_id IS NULL
    AND (to_jsonb(OLD)-'user_id')=(to_jsonb(NEW)-'user_id') THEN RETURN NEW; END IF;
  RAISE EXCEPTION '[LEDGER_IMMUTABLE]' USING ERRCODE='55000';
END $h0$;
CREATE TRIGGER ledger_party_identity BEFORE UPDATE OR DELETE ON public.ledger_parties FOR EACH ROW EXECUTE FUNCTION public._ledger_party_guard_h0();
CREATE FUNCTION public._ledger_account_guard_h0() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $h0$
BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=NEW.party_id AND kind=split_part(NEW.code,'_',1)) THEN
    RAISE EXCEPTION '[LEDGER_ACCOUNT_TYPE]' USING ERRCODE='23514'; END IF;
  INSERT INTO public.ledger_account_locks(account_id) VALUES(NEW.id);
  RETURN NEW;
END $h0$;
CREATE TRIGGER ledger_account_type AFTER INSERT ON public.ledger_accounts FOR EACH ROW EXECUTE FUNCTION public._ledger_account_guard_h0();

CREATE FUNCTION public.ensure_ledger_party_v1(p_kind text,p_ref uuid DEFAULT NULL,p_shop uuid DEFAULT NULL) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE found_id uuid;
BEGIN
  IF p_kind IS NULL OR p_kind NOT IN ('platform','merchant','customer','package')
    OR (p_kind='platform' AND (p_ref IS NOT NULL OR p_shop IS NOT NULL))
    OR (p_kind<>'platform' AND p_ref IS NULL)
    OR (p_kind<>'package' AND p_shop IS NOT NULL) THEN RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('h0-party:'||p_kind||coalesce(p_ref::text,''),0));
  IF p_kind='merchant' AND NOT EXISTS(SELECT 1 FROM public.shops WHERE id=p_ref) THEN RAISE EXCEPTION '[LEDGER_PARTY_UNKNOWN]' USING ERRCODE='22023'; END IF;
  IF p_kind='customer' THEN
    PERFORM id FROM auth.users WHERE id=p_ref FOR SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION '[LEDGER_PARTY_UNKNOWN]' USING ERRCODE='22023'; END IF;
  END IF;
  IF p_kind='package' AND NOT EXISTS(SELECT 1 FROM public.shops WHERE id=p_shop) THEN RAISE EXCEPTION '[LEDGER_PARTY_UNKNOWN]' USING ERRCODE='22023'; END IF;
  SELECT id INTO found_id FROM public.ledger_parties WHERE kind=p_kind AND
    (p_kind='platform' OR (p_kind='merchant' AND shop_id=p_ref) OR (p_kind='customer' AND user_id=p_ref) OR (p_kind='package' AND package_ref=p_ref));
  IF found_id IS NOT NULL THEN
    IF p_kind='package' AND NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=found_id AND shop_id=p_shop) THEN
      RAISE EXCEPTION '[LEDGER_PARTY_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN found_id;
  END IF;
  INSERT INTO public.ledger_parties(kind,shop_id,user_id,package_ref)
    VALUES(p_kind,CASE WHEN p_kind='merchant' THEN p_ref WHEN p_kind='package' THEN p_shop END,
      CASE WHEN p_kind='customer' THEN p_ref END,CASE WHEN p_kind='package' THEN p_ref END) RETURNING id INTO found_id;
  RETURN found_id;
END $h0$;
CREATE FUNCTION public.ensure_ledger_account_v1(p_party uuid,p_code text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE found_id uuid; BEGIN
  INSERT INTO public.ledger_accounts(party_id,code) VALUES(p_party,p_code) ON CONFLICT(party_id,code) DO NOTHING;
  SELECT id INTO found_id FROM public.ledger_accounts WHERE party_id=p_party AND code=p_code;
  RETURN found_id;
END $h0$;

CREATE FUNCTION public.record_commerce_source_v1(p_kind text,p_source uuid,p_party uuid,p_amount bigint,p_policy uuid,
  p_evidence uuid,p_related uuid DEFAULT NULL,p_accrual uuid DEFAULT NULL,p_reason text DEFAULT '') RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE source_row public.ledger_sources;
BEGIN
  INSERT INTO public.ledger_sources(kind,source_id,party_id,amount_minor,policy_id,evidence_ref,related_journal,accrual_journal,reason)
    VALUES(p_kind,p_source,p_party,p_amount,p_policy,p_evidence,p_related,p_accrual,p_reason)
    ON CONFLICT(kind,source_id) DO NOTHING;
  SELECT * INTO source_row FROM public.ledger_sources WHERE kind=p_kind AND source_id=p_source;
  IF ROW(source_row.party_id,source_row.amount_minor,source_row.policy_id,source_row.evidence_ref,source_row.related_journal,source_row.accrual_journal,source_row.reason)
    IS DISTINCT FROM ROW(p_party,p_amount,p_policy,p_evidence,p_related,p_accrual,p_reason) THEN
    RAISE EXCEPTION '[LEDGER_SOURCE_CONFLICT]' USING ERRCODE='22023'; END IF;
  RETURN source_row.id;
EXCEPTION WHEN check_violation OR not_null_violation OR foreign_key_violation THEN
  RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023';
END $h0$;

CREATE FUNCTION public._ledger_balance_h0(p_account uuid) RETURNS numeric LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $h0$
  SELECT coalesce(sum(amount_minor),0) FROM public.ledger_postings WHERE account_id=p_account
$h0$;
CREATE FUNCTION public._ledger_seal_h0() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE target uuid; j public.ledger_journals; actual jsonb; n integer; total numeric;
BEGIN
  IF TG_TABLE_NAME='ledger_journals' THEN target:=NEW.id; ELSE target:=NEW.journal_id; END IF;
  SELECT * INTO j FROM public.ledger_journals WHERE id=target;
  SELECT count(*),sum(amount_minor),jsonb_agg(jsonb_build_object('account_id',account_id,'amount_minor',amount_minor::text) ORDER BY account_id)
    INTO n,total,actual FROM public.ledger_postings WHERE journal_id=target;
  IF n<>j.posting_count OR total IS DISTINCT FROM 0::numeric OR extensions.digest(actual::text,'sha256') IS DISTINCT FROM j.postings_hash THEN
    RAISE EXCEPTION '[LEDGER_UNBALANCED_OR_UNSEALED]' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM public.ledger_accounts a JOIN public.ledger_postings p ON p.account_id=a.id
    WHERE p.journal_id=target AND a.code NOT IN ('platform_clearing','platform_offset_control') AND public._ledger_balance_h0(a.id)<0) THEN
    RAISE EXCEPTION '[LEDGER_OVERDRAFT]' USING ERRCODE='23514'; END IF;
  RETURN NULL;
END $h0$;
CREATE CONSTRAINT TRIGGER ledger_journal_sealed AFTER INSERT ON public.ledger_journals DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._ledger_seal_h0();
CREATE CONSTRAINT TRIGGER ledger_postings_sealed AFTER INSERT ON public.ledger_postings DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION public._ledger_seal_h0();

CREATE FUNCTION public.post_balanced_journal_v1(p_source uuid,p_postings jsonb) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE source_row public.ledger_sources; original public.ledger_sources; related public.ledger_journals;
  policy_row public.commerce_policy_versions; posted public.ledger_journals; normalized jsonb; digest_value bytea;
  n integer; positive numeric; total numeric; account_key uuid; reserve_account uuid; pending_account uuid; coupon_account uuid;
  reserve_before numeric; reserve_delta numeric; required_reserve numeric; unspent_customer numeric;
BEGIN
  SELECT * INTO source_row FROM public.ledger_sources WHERE id=p_source FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[LEDGER_SOURCE_UNKNOWN]' USING ERRCODE='22023'; END IF;
  IF jsonb_typeof(p_postings) IS DISTINCT FROM 'array' THEN RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF jsonb_array_length(p_postings) NOT BETWEEN 2 AND 32 OR EXISTS(SELECT 1 FROM jsonb_array_elements(p_postings) x
    WHERE jsonb_typeof(x) IS DISTINCT FROM 'object' OR NOT(x ?& ARRAY['account_id','amount_minor'])
    OR (SELECT count(*) FROM jsonb_object_keys(x))<>2 OR jsonb_typeof(x->'account_id') IS DISTINCT FROM 'string'
    OR jsonb_typeof(x->'amount_minor') IS DISTINCT FROM 'string' OR (x->>'amount_minor') !~ '^-?[1-9][0-9]{0,18}$') THEN
    RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  SELECT count(DISTINCT (x->>'account_id')::uuid),sum((x->>'amount_minor')::bigint),
    coalesce(sum((x->>'amount_minor')::numeric) FILTER(WHERE (x->>'amount_minor')::numeric>0),0),
    jsonb_agg(jsonb_build_object('account_id',(x->>'account_id')::uuid,'amount_minor',((x->>'amount_minor')::bigint)::text) ORDER BY (x->>'account_id')::uuid)
    INTO n,total,positive,normalized FROM jsonb_array_elements(p_postings) x;
  IF n<>jsonb_array_length(p_postings) OR total<>0 OR positive<>source_row.amount_minor::numeric*(CASE WHEN source_row.kind='offset_recovered' THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION '[LEDGER_UNBALANCED]' USING ERRCODE='22023'; END IF;
  digest_value:=extensions.digest(normalized::text,'sha256');
  SELECT * INTO posted FROM public.ledger_journals WHERE source_id=p_source;
  IF FOUND THEN
    IF posted.postings_hash<>digest_value THEN RAISE EXCEPTION '[LEDGER_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN posted.id;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM public.commerce_ledger_config WHERE enabled) THEN RAISE EXCEPTION '[LEDGER_DISABLED]' USING ERRCODE='55000'; END IF;
  SELECT * INTO policy_row FROM public.commerce_policy_versions WHERE id=source_row.policy_id;
  -- All referenced prior journals serialize before account locks, in UUID order.
  PERFORM id FROM public.ledger_journals WHERE id IN (source_row.related_journal,source_row.accrual_journal) ORDER BY id FOR UPDATE;
  IF source_row.kind IN ('coupon_redemption','platform_service') THEN
    reserve_account:=public.ensure_ledger_account_v1(source_row.party_id,'merchant_reserve');
  END IF;
  IF source_row.kind='offset_created' THEN
    pending_account:=public.ensure_ledger_account_v1(source_row.party_id,'customer_pending');
    coupon_account:=public.ensure_ledger_account_v1(source_row.party_id,'customer_coupon');
  END IF;
  FOR account_key IN SELECT (x->>'account_id')::uuid FROM jsonb_array_elements(normalized) x
    UNION SELECT reserve_account WHERE reserve_account IS NOT NULL
    UNION SELECT pending_account WHERE pending_account IS NOT NULL
    UNION SELECT coupon_account WHERE coupon_account IS NOT NULL ORDER BY 1 LOOP
    UPDATE public.ledger_account_locks SET epoch=epoch+1 WHERE account_id=account_key;
    IF NOT FOUND THEN RAISE EXCEPTION '[LEDGER_ACCOUNT_UNKNOWN]' USING ERRCODE='22023'; END IF;
  END LOOP;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE a.currency<>source_row.currency OR (a.code NOT IN ('platform_clearing','platform_offset_control')
      AND public._ledger_balance_h0(a.id)+(x->>'amount_minor')::bigint<0)) THEN RAISE EXCEPTION '[LEDGER_OVERDRAFT]' USING ERRCODE='22023'; END IF;
  -- Reserve rules apply to the whole source, including callers of the generic kernel.
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE a.code='merchant_reserve' AND source_row.kind NOT IN ('coupon_redemption','platform_service','admin_reversal')) THEN
    RAISE EXCEPTION '[LEDGER_RESERVE_SOURCE]' USING ERRCODE='22023'; END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE a.code='merchant_reserve' AND (x->>'amount_minor')::bigint>0
      AND public._ledger_balance_h0(a.id)+(x->>'amount_minor')::bigint>policy_row.reserve_cap_minor) THEN
    RAISE EXCEPTION '[LEDGER_RESERVE_CAP]' USING ERRCODE='22023'; END IF;
  IF source_row.kind IN ('coupon_redemption','unused_package_fund','platform_service','receivable_release') THEN
    IF NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=source_row.party_id AND kind='merchant')
      OR EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
        JOIN public.ledger_parties p ON p.id=a.party_id WHERE p.kind<>'platform' AND p.id<>source_row.party_id
          AND NOT(source_row.kind='coupon_redemption' AND a.code='customer_coupon' AND (x->>'amount_minor')::bigint<0)) THEN
      RAISE EXCEPTION '[LEDGER_SOURCE_PARTY]' USING ERRCODE='22023'; END IF;
  END IF;
  IF source_row.kind IN ('coupon_redemption','platform_service') THEN
    SELECT coalesce(sum(p.amount_minor),0) INTO reserve_before FROM public.ledger_postings p WHERE p.account_id=reserve_account;
    SELECT coalesce(sum((x->>'amount_minor')::bigint),0) INTO reserve_delta FROM jsonb_array_elements(normalized) x WHERE (x->>'account_id')::uuid=reserve_account;
    required_reserve:=CASE WHEN source_row.kind='coupon_redemption' THEN least(source_row.amount_minor::numeric,greatest(0,policy_row.reserve_cap_minor-reserve_before))
      ELSE -least(source_row.amount_minor::numeric,reserve_before) END;
    IF reserve_delta<>required_reserve THEN RAISE EXCEPTION '[LEDGER_RESERVE_ALLOCATION]' USING ERRCODE='22023'; END IF;
  END IF;
  IF source_row.kind IN ('coupon_redemption','unused_package_fund') AND EXISTS(
    SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE CASE WHEN (x->>'amount_minor')::bigint<0 THEN a.code<>'platform_clearing'
        AND NOT(source_row.kind='coupon_redemption' AND a.code='customer_coupon')
      WHEN source_row.kind='coupon_redemption' THEN a.code NOT IN ('merchant_reserve','merchant_coupon_pending')
      ELSE a.code<>'merchant_unused_pending' END) THEN RAISE EXCEPTION '[LEDGER_SOURCE_ALLOCATION]' USING ERRCODE='22023'; END IF;
  IF source_row.kind='platform_service' AND EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
    WHERE CASE WHEN (x->>'amount_minor')::bigint>0 THEN a.code<>'platform_service'
      ELSE a.code NOT IN ('merchant_reserve','merchant_coupon_available','merchant_unused_available') END) THEN
    RAISE EXCEPTION '[LEDGER_SERVICE_ALLOCATION]' USING ERRCODE='22023'; END IF;
  IF source_row.kind='receivable_release' THEN
    IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
      WHERE CASE WHEN (x->>'amount_minor')::bigint<0 THEN a.code NOT IN ('merchant_coupon_pending','merchant_unused_pending')
        ELSE a.code NOT IN ('merchant_coupon_available','merchant_unused_available') END)
      OR EXISTS(SELECT 1 FROM (SELECT split_part(a.code,'_',2) pool,sum((x->>'amount_minor')::bigint) amount
        FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid GROUP BY 1) pools WHERE amount<>0) THEN
      RAISE EXCEPTION '[LEDGER_RELEASE_ALLOCATION]' USING ERRCODE='22023'; END IF;
  END IF;
  IF source_row.kind='reward_issue' AND (NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=source_row.party_id AND kind='customer' AND user_id IS NOT NULL)
    OR EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
      WHERE CASE WHEN (x->>'amount_minor')::bigint>0 THEN a.party_id<>source_row.party_id OR a.code NOT IN ('customer_pending','customer_coupon')
        ELSE a.code NOT IN ('platform_clearing','package_free','package_held','customer_pending') OR (a.code='customer_pending' AND a.party_id<>source_row.party_id) END)) THEN
    RAISE EXCEPTION '[LEDGER_REWARD_ALLOCATION]' USING ERRCODE='22023'; END IF;
  IF source_row.kind='package_funding' THEN
    IF NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=source_row.party_id AND kind='package')
      OR source_row.amount_minor::numeric<>policy_row.package_fund_minor::numeric+policy_row.package_fee_minor
      OR EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid WHERE
        NOT((a.code='platform_clearing' AND (x->>'amount_minor')::bigint=-source_row.amount_minor)
          OR(a.code='package_free' AND a.party_id=source_row.party_id AND (x->>'amount_minor')::bigint=policy_row.package_fund_minor)
          OR(a.code='platform_service' AND (x->>'amount_minor')::bigint=policy_row.package_fee_minor))) THEN
      RAISE EXCEPTION '[LEDGER_FUNDING_ALLOCATION]' USING ERRCODE='22023'; END IF;
  END IF;
  IF source_row.kind='return' THEN
    RAISE EXCEPTION '[LEDGER_RETURN_POLICY_PENDING]' USING ERRCODE='55000';
  END IF;
  IF source_row.kind='admin_reversal' THEN
    SELECT * INTO related FROM public.ledger_journals WHERE id=source_row.related_journal;
    SELECT * INTO original FROM public.ledger_sources WHERE id=related.source_id;
    IF original.kind IN ('admin_reversal','offset_created','offset_recovered') OR original.party_id<>source_row.party_id
      OR original.amount_minor<>source_row.amount_minor OR original.policy_id<>source_row.policy_id
      OR EXISTS(SELECT 1 FROM public.ledger_sources s JOIN public.ledger_journals j ON j.source_id=s.id WHERE s.kind='offset_created' AND s.related_journal=related.id)
      OR normalized IS DISTINCT FROM (SELECT jsonb_agg(jsonb_build_object('account_id',account_id,'amount_minor',(-amount_minor)::text) ORDER BY account_id)
        FROM public.ledger_postings WHERE journal_id=related.id) THEN RAISE EXCEPTION '[LEDGER_REVERSAL_CONFLICT]' USING ERRCODE='22023'; END IF;
  END IF;
  -- Offset journals are memo obligations, not a cash-debt account. Recovery also
  -- consumes pending future accrual in this same transaction, never just a counter.
  IF source_row.kind IN ('offset_created','offset_recovered') THEN
    SELECT * INTO related FROM public.ledger_journals WHERE id=source_row.related_journal;
    SELECT * INTO original FROM public.ledger_sources WHERE id=related.source_id;
    IF original.party_id<>source_row.party_id OR NOT EXISTS(SELECT 1 FROM public.ledger_parties WHERE id=source_row.party_id AND kind='customer') THEN
      RAISE EXCEPTION '[LEDGER_OFFSET_SOURCE]' USING ERRCODE='22023'; END IF;
    IF source_row.kind='offset_created' THEN
      -- H0 has no issued-coupon lot allocation. Conservatively exclude all current
      -- unspent customer value; E must supply per-source spent allocation before
      -- supporting cases this conservative bound cannot represent.
      unspent_customer:=public._ledger_balance_h0(pending_account)+public._ledger_balance_h0(coupon_account);
      IF original.kind<>'reward_issue' OR EXISTS(SELECT 1 FROM public.ledger_sources s JOIN public.ledger_journals j ON j.source_id=s.id WHERE s.kind='admin_reversal' AND s.related_journal=related.id)
        OR source_row.amount_minor+(SELECT coalesce(sum(s.amount_minor),0) FROM public.ledger_sources s JOIN public.ledger_journals j ON j.source_id=s.id
          WHERE s.kind='offset_created' AND s.related_journal=related.id)>greatest(0,original.amount_minor::numeric-unspent_customer) THEN RAISE EXCEPTION '[LEDGER_OFFSET_LIMIT]' USING ERRCODE='22023'; END IF;
    ELSE
      IF original.kind<>'offset_created' OR source_row.amount_minor+(SELECT coalesce(sum(s.amount_minor),0) FROM public.ledger_sources s JOIN public.ledger_journals j ON j.source_id=s.id
        WHERE s.kind='offset_recovered' AND s.related_journal=related.id)>original.amount_minor
        OR NOT EXISTS(SELECT 1 FROM public.ledger_journals j JOIN public.ledger_sources s ON s.id=j.source_id
          WHERE j.id=source_row.accrual_journal AND s.kind='reward_issue' AND s.party_id=source_row.party_id
            AND s.amount_minor>=source_row.amount_minor+(SELECT coalesce(sum(r.amount_minor),0) FROM public.ledger_sources r JOIN public.ledger_journals rj ON rj.source_id=r.id
              WHERE r.kind='offset_recovered' AND r.accrual_journal=j.id)) THEN RAISE EXCEPTION '[LEDGER_OFFSET_LIMIT]' USING ERRCODE='22023'; END IF;
    END IF;
    IF EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid WHERE
      CASE WHEN source_row.kind='offset_created' THEN
        NOT((a.code='customer_future_offset' AND a.party_id=source_row.party_id AND (x->>'amount_minor')::bigint=source_row.amount_minor)
          OR(a.code='platform_offset_control' AND (x->>'amount_minor')::bigint=-source_row.amount_minor))
      ELSE NOT((a.code IN ('customer_future_offset','customer_pending') AND a.party_id=source_row.party_id AND (x->>'amount_minor')::bigint=-source_row.amount_minor)
          OR(a.code IN ('platform_offset_control','platform_clearing') AND (x->>'amount_minor')::bigint=source_row.amount_minor)) END)
      OR n<>(CASE WHEN source_row.kind='offset_created' THEN 2 ELSE 4 END) THEN RAISE EXCEPTION '[LEDGER_OFFSET_ALLOCATION]' USING ERRCODE='22023'; END IF;
  ELSIF source_row.kind<>'admin_reversal' AND EXISTS(SELECT 1 FROM jsonb_array_elements(normalized) x JOIN public.ledger_accounts a ON a.id=(x->>'account_id')::uuid
      WHERE a.code IN ('customer_future_offset','platform_offset_control')) THEN RAISE EXCEPTION '[LEDGER_OFFSET_SOURCE]' USING ERRCODE='22023';
  END IF;
  INSERT INTO public.ledger_journals(source_id,posting_count,postings_hash) VALUES(p_source,n,digest_value) RETURNING * INTO posted;
  INSERT INTO public.ledger_postings(journal_id,account_id,amount_minor)
    SELECT posted.id,(x->>'account_id')::uuid,(x->>'amount_minor')::bigint FROM jsonb_array_elements(normalized) x;
  RETURN posted.id;
EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range OR not_null_violation THEN
  RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023';
END $h0$;

CREATE FUNCTION public.reverse_commerce_journal_v1(p_original uuid,p_request uuid,p_reason text) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE original public.ledger_sources; source_key uuid; lines jsonb;
BEGIN
  SELECT s.* INTO original FROM public.ledger_journals j JOIN public.ledger_sources s ON s.id=j.source_id WHERE j.id=p_original;
  IF NOT FOUND THEN RAISE EXCEPTION '[LEDGER_SOURCE_UNKNOWN]' USING ERRCODE='22023'; END IF;
  source_key:=public.record_commerce_source_v1('admin_reversal',p_request,original.party_id,original.amount_minor,original.policy_id,p_original,p_original,NULL,p_reason);
  SELECT jsonb_agg(jsonb_build_object('account_id',account_id,'amount_minor',(-amount_minor)::text) ORDER BY account_id)
    INTO lines FROM public.ledger_postings WHERE journal_id=p_original;
  RETURN public.post_balanced_journal_v1(source_key,lines);
END $h0$;
CREATE FUNCTION public.consume_commerce_event_v1(p_consumer text,p_event uuid,p_source uuid,p_postings jsonb) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE target uuid; prior uuid; BEGIN
  IF p_consumer IS NULL OR length(p_consumer) NOT BETWEEN 1 AND 80 OR p_event IS NULL THEN RAISE EXCEPTION '[LEDGER_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('h0-consumer:'||p_consumer||':'||p_event::text,0));
  IF NOT EXISTS(SELECT 1 FROM public.commerce_events e JOIN public.ledger_sources s ON s.id=p_source
    WHERE e.id=p_event AND s.evidence_ref IN (e.id,e.source_id,e.purchase_id)) THEN
    RAISE EXCEPTION '[LEDGER_EVENT_SOURCE]' USING ERRCODE='22023'; END IF;
  target:=public.post_balanced_journal_v1(p_source,p_postings);
  SELECT journal_id INTO prior FROM public.ledger_consumer_receipts WHERE consumer=p_consumer AND event_id=p_event;
  IF prior IS NOT NULL AND prior<>target THEN RAISE EXCEPTION '[LEDGER_CONSUMER_CONFLICT]' USING ERRCODE='22023'; END IF;
  INSERT INTO public.ledger_consumer_receipts(consumer,event_id,journal_id) VALUES(p_consumer,p_event,target) ON CONFLICT DO NOTHING;
  RETURN target;
END $h0$;

CREATE FUNCTION public.commerce_ledger_capabilities_v1() RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $h0$
  SELECT jsonb_build_object('version',1,'enabled',c.enabled,'policy_version',p.version,'currency',p.currency,
    'funding_enabled',false,'rewards_enabled',false,'settlement_enabled',false)
  FROM public.commerce_ledger_config c JOIN public.commerce_policy_versions p ON p.id=c.policy_id
$h0$;
CREATE FUNCTION public.read_my_commerce_accounts_v1(p_shop_id uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $h0$
DECLARE party_key uuid; enabled_value boolean; result jsonb;
BEGIN
  PERFORM public._qr_auth_session_b();
  IF p_shop_id IS NOT NULL THEN
    PERFORM public._review_merchant_c(p_shop_id);
    SELECT id INTO party_key FROM public.ledger_parties WHERE kind='merchant' AND shop_id=p_shop_id;
  ELSE
    IF NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=auth.uid() AND role='customer') THEN RAISE EXCEPTION '[LEDGER_CUSTOMER_REQUIRED]' USING ERRCODE='42501'; END IF;
    SELECT id INTO party_key FROM public.ledger_parties WHERE kind='customer' AND user_id=auth.uid();
  END IF;
  SELECT enabled INTO enabled_value FROM public.commerce_ledger_config;
  IF enabled_value IS DISTINCT FROM true THEN RETURN jsonb_build_object('enabled',false,'currency','TRY','accounts','[]'::jsonb,'settlement_enabled',false); END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('code',code,'amount_minor',public._ledger_balance_h0(id)::text) ORDER BY code),'[]'::jsonb)
    INTO result FROM public.ledger_accounts WHERE party_id=party_key;
  RETURN jsonb_build_object('enabled',true,'currency','TRY','shop_id',p_shop_id,'accounts',result,'settlement_enabled',false);
END $h0$;

ALTER TABLE public.commerce_policy_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commerce_ledger_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_account_locks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_journals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_consumer_receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.commerce_policy_versions,public.commerce_ledger_config,public.ledger_parties,
  public.ledger_accounts,public.ledger_account_locks,public.ledger_sources,public.ledger_journals,
  public.ledger_postings,public.ledger_consumer_receipts FROM PUBLIC,anon,authenticated,service_role;
DO $permissions$ DECLARE object_name text; BEGIN
  FOREACH object_name IN ARRAY ARRAY['commerce_policy_versions','commerce_ledger_config','ledger_parties','ledger_accounts','ledger_account_locks',
    'ledger_sources','ledger_journals','ledger_postings','ledger_consumer_receipts'] LOOP
    IF object_name NOT IN ('commerce_ledger_config','ledger_account_locks','ledger_parties') THEN
      EXECUTE format('CREATE TRIGGER ledger_immutable BEFORE UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b()',object_name);
    END IF;
  END LOOP;
END $permissions$;
REVOKE ALL ON FUNCTION public._ledger_party_guard_h0() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._ledger_account_guard_h0() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.ensure_ledger_party_v1(text,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.ensure_ledger_account_v1(uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.record_commerce_source_v1(text,uuid,uuid,bigint,uuid,uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._ledger_balance_h0(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._ledger_seal_h0() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.post_balanced_journal_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.reverse_commerce_journal_v1(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.consume_commerce_event_v1(text,uuid,uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.commerce_ledger_capabilities_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_my_commerce_accounts_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.commerce_ledger_capabilities_v1() TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.read_my_commerce_accounts_v1(uuid) TO authenticated;
COMMIT;
