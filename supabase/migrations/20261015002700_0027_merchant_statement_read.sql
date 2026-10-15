-- H1 read-only projection. No payout, release, funding or accounting mutation.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.reward_coupon_redemptions') IS NULL
    OR to_regprocedure('public._qr_auth_session_b()') IS NULL THEN
    RAISE EXCEPTION '0027 requires integrated H0/E checkout';
  END IF;
END $preflight$;

CREATE TABLE public.merchant_statement_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.merchant_statement_config(singleton) VALUES(true);
ALTER TABLE public.merchant_statement_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.merchant_statement_config FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION public.read_merchant_statement_v1(
  p_shop_id uuid, p_limit integer DEFAULT 20,
  p_before uuid DEFAULT NULL, p_revision text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' SET timezone='UTC' AS $h1$
DECLARE party_key uuid; cap bigint; active boolean; result jsonb;
BEGIN
  PERFORM public._qr_auth_session_b();
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='merchant' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[STATEMENT_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  PERFORM id FROM public.shops WHERE id=p_shop_id AND owner_user_id=auth.uid() AND is_active FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[STATEMENT_FORBIDDEN]' USING ERRCODE='42501'; END IF;
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 50
    OR (p_before IS NULL) <> (p_revision IS NULL)
    OR (p_revision IS NOT NULL AND (length(p_revision)>20 OR p_revision !~ '^(0|[1-9][0-9]*)$')) THEN
    RAISE EXCEPTION '[STATEMENT_INVALID_ARGUMENT]' USING ERRCODE='22023';
  END IF;
  SELECT s.enabled AND c.enabled,p.reserve_cap_minor INTO active,cap
    FROM public.merchant_statement_config s CROSS JOIN public.commerce_ledger_config c
    JOIN public.commerce_policy_versions p ON p.id=c.policy_id FOR SHARE OF s,c;
  IF active IS DISTINCT FROM true THEN
    RETURN jsonb_build_object('version',1,'enabled',false,'shop_id',p_shop_id,'currency','TRY',
      'settlement_enabled',false,'settlement_status','policy_pending',
      'accounts','[]'::jsonb,'entries','[]'::jsonb,'revision',NULL,'next_before',NULL,'reserve_cap_minor',NULL);
  END IF;
  SELECT id INTO party_key FROM public.ledger_parties WHERE kind='merchant' AND shop_id=p_shop_id;
  -- ONE statement snapshot for balances, revision, cursor and entries. No
  -- unlocked sequence watermark: an earlier transaction may commit later.
  -- Append-only journal count detects those late commits on subsequent pages.
  WITH own AS MATERIALIZED (
    SELECT p.journal_id,p.amount_minor,a.code FROM public.ledger_accounts a
      JOIN public.ledger_postings p ON p.account_id=a.id WHERE a.party_id=party_key
  ), history AS MATERIALIZED (
    SELECT j.id,j.recorded_at,s.kind,
      CASE WHEN EXISTS(SELECT 1 FROM own WHERE journal_id=s.related_journal)
        THEN s.related_journal END reverses
    FROM public.ledger_journals j JOIN public.ledger_sources s ON s.id=j.source_id
    WHERE EXISTS(SELECT 1 FROM own WHERE journal_id=j.id)
  ), windowed AS MATERIALIZED (
    SELECT * FROM history h WHERE p_before IS NULL OR
      (h.recorded_at,h.id)<(SELECT recorded_at,id FROM history WHERE id=p_before)
    ORDER BY recorded_at DESC,id DESC LIMIT p_limit+1
  ), page AS MATERIALIZED (
    SELECT * FROM windowed ORDER BY recorded_at DESC,id DESC LIMIT p_limit
  ), codes(code) AS (VALUES
    ('merchant_reserve'),('merchant_coupon_pending'),('merchant_coupon_available'),
    ('merchant_unused_pending'),('merchant_unused_available'))
  SELECT jsonb_build_object(
    'version',1,'enabled',true,'shop_id',p_shop_id,'currency','TRY',
    'settlement_enabled',false,'settlement_status','policy_pending','reserve_cap_minor',cap::text,
    'revision',(SELECT count(*)::text FROM history),
    'cursor_valid',p_before IS NULL OR EXISTS(SELECT 1 FROM history WHERE id=p_before),
    'accounts',(SELECT jsonb_agg(jsonb_build_object('code',code,'amount_minor',
      coalesce((SELECT sum(amount_minor) FROM own WHERE own.code=codes.code),0)::text) ORDER BY code) FROM codes),
    'entries',coalesce((SELECT jsonb_agg(jsonb_build_object(
      'id',h.id,'recorded_at',h.recorded_at,'kind',h.kind,'reverses',h.reverses,
      'net_minor',(SELECT sum(amount_minor)::text FROM own WHERE journal_id=h.id),
      'movements',(SELECT jsonb_agg(jsonb_build_object('code',code,'amount_minor',amount_minor::text) ORDER BY code)
        FROM own WHERE journal_id=h.id)) ORDER BY h.recorded_at DESC,h.id DESC) FROM page h),'[]'::jsonb),
    'next_before',CASE WHEN (SELECT count(*) FROM windowed)>p_limit
      THEN (SELECT id FROM page ORDER BY recorded_at,id LIMIT 1) END
  ) INTO result;
  IF p_revision IS NOT NULL AND p_revision<>result->>'revision' THEN
    RAISE EXCEPTION '[STATEMENT_CHANGED]' USING ERRCODE='40001';
  END IF;
  IF NOT (result->>'cursor_valid')::boolean THEN
    RAISE EXCEPTION '[STATEMENT_INVALID_ARGUMENT]' USING ERRCODE='22023';
  END IF;
  RETURN result-'cursor_valid';
END $h1$;
REVOKE ALL ON FUNCTION public.read_merchant_statement_v1(uuid,integer,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.read_merchant_statement_v1(uuid,integer,uuid,text) TO authenticated;
COMMIT;
