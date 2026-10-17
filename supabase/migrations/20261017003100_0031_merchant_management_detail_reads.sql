-- Exact-owner recovery projections only. No writes, tables or new business rules.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
DO $preflight$ BEGIN
 IF to_regprocedure('public._campaign_json_f(uuid,boolean)') IS NULL
 OR to_regprocedure('public._promotion_json_g(uuid,boolean)') IS NULL
 OR to_regprocedure('public._promotion_owner_g(uuid,boolean)') IS NULL THEN
   RAISE EXCEPTION '0031 requires integrated F/G owner and projection contracts';
 END IF;
END $preflight$;

CREATE FUNCTION public.read_merchant_campaign_detail_v1(p_shop_id uuid,p_campaign_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $recovery$
DECLARE capability jsonb; item jsonb;
BEGIN
 -- Reuse the read-only live-session/role/shop guard. The review guard also
 -- allocates a pseudonymous subject, which an exact recovery read does not need.
 PERFORM public._promotion_owner_g(p_shop_id);
 IF p_campaign_id IS NULL THEN RAISE EXCEPTION '[CAMPAIGN_ID_INVALID]' USING ERRCODE='22023'; END IF;
 capability:=public.campaign_capabilities_v1();
 IF (capability->>'enabled')::boolean THEN
   SELECT public._campaign_json_f(id,true) INTO item FROM public.merchant_campaigns
   WHERE id=p_campaign_id AND shop_id=p_shop_id;
 END IF;
 RETURN capability||jsonb_build_object('shop_id',p_shop_id,'campaign',item);
END $recovery$;

CREATE FUNCTION public.read_merchant_promotion_detail_v1(p_shop_id uuid,p_draft_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $recovery$
DECLARE is_enabled boolean; item jsonb;
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id);
 IF p_draft_id IS NULL THEN RAISE EXCEPTION '[PROMOTION_ID_INVALID]' USING ERRCODE='22023'; END IF;
 SELECT enabled INTO is_enabled FROM public.merchant_promotion_config WHERE singleton;
 IF is_enabled THEN
   SELECT public._promotion_json_g(id,true) INTO item FROM public.merchant_promotion_drafts
   WHERE id=p_draft_id AND shop_id=p_shop_id;
 END IF;
 RETURN jsonb_build_object('enabled',is_enabled,'shop_id',p_shop_id,'draft',item);
END $recovery$;

REVOKE ALL ON FUNCTION public.read_merchant_campaign_detail_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_merchant_promotion_detail_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.read_merchant_campaign_detail_v1(uuid,uuid),
 public.read_merchant_promotion_detail_v1(uuid,uuid) TO authenticated;
COMMIT;
