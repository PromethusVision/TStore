-- Enforce the frozen net-payment threshold at consent, before claim/completion.
-- Forward-only correction; 0024/0025 and immutable approval/QR evidence stay intact.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.reward_checkout_approvals') IS NULL
    OR to_regprocedure('public.ensure_reward_reservation_v1(uuid,boolean)') IS NULL
    OR to_regprocedure('public._reward_release_e(uuid)') IS NULL THEN
    RAISE EXCEPTION '0026 requires the 0025 coupon checkout lifecycle';
  END IF;
END $preflight$;

-- Also repairs an old gross-price reservation recreated while the same approved
-- QR is live. Only the immutable approval and its snapshotted policy are authority.
CREATE FUNCTION public._checkout_release_below_threshold_e(p_qr uuid) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE approved record; reservation record;
BEGIN
  PERFORM public._reward_lock_e();
  SELECT q.cart_id,a.customer_party INTO approved
    FROM public.reward_checkout_approvals a
    JOIN public.reward_qr_contracts c ON c.qr_ref=a.qr_ref
    JOIN public.commerce_policy_versions p ON p.id=c.policy_id
    JOIN public.qr_sessions q ON q.id=a.qr_ref
    JOIN public.qr_session_protocols protocol ON protocol.qr_session_id=q.id
    LEFT JOIN public.qr_claims claim ON claim.qr_session_id=q.id
    WHERE a.qr_ref=p_qr AND q.status='active'
      AND coalesce(claim.completion_expires_at,protocol.scan_expires_at)>clock_timestamp()
      AND a.sale_minor-a.coupon_minor<p.eligible_minimum_minor;
  IF NOT FOUND THEN RETURN false; END IF;
  FOR reservation IN
    SELECT r.id FROM public.reward_reservations r JOIN public.reward_attempts t ON t.id=r.attempt_id
    WHERE r.customer_party=approved.customer_party AND t.cart_ref=approved.cart_id
      AND r.state IN ('reserved','checkout_hold') ORDER BY r.package_id,r.id
  LOOP
    -- Existing idempotent release returns both the slot and its earmarked fund;
    -- an expired package routes the restored fund through its existing expiry rule.
    PERFORM public._reward_release_e(reservation.id);
  END LOOP;
  RETURN true;
END $e$;

CREATE FUNCTION public._checkout_approval_capacity_e() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
BEGIN
  PERFORM public._checkout_release_below_threshold_e(NEW.qr_ref);
  RETURN NEW;
END $e$;
CREATE TRIGGER checkout_approval_capacity AFTER INSERT ON public.reward_checkout_approvals
FOR EACH ROW EXECUTE FUNCTION public._checkout_approval_capacity_e();

ALTER FUNCTION public.ensure_reward_reservation_v1(uuid,boolean) RENAME TO _ensure_reward_reservation_before_coupon_threshold;
CREATE OR REPLACE FUNCTION public.ensure_reward_reservation_v1(p_cart uuid,p_start_new boolean DEFAULT false) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $e$
DECLARE approved_qr uuid; attempt public.reward_attempts;
BEGIN
  PERFORM public._reward_customer_e();
  IF p_start_new IS NULL THEN RAISE EXCEPTION '[REWARD_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM id FROM public.carts WHERE id=p_cart AND user_id=auth.uid() AND status='active' FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[REWARD_CART_UNAVAILABLE]' USING ERRCODE='42501'; END IF;
  PERFORM public._reward_lock_e();
  IF public._reward_enabled_e() THEN
    SELECT q.id INTO approved_qr FROM public.qr_sessions q
      JOIN public.reward_checkout_approvals a ON a.qr_ref=q.id
      WHERE q.cart_id=p_cart AND q.user_id=auth.uid() AND q.status='active'
        AND public._qr_customer_payload_b(q.id)->>'status' IN ('active','claimed')
      ORDER BY q.created_at DESC,q.id LIMIT 1;
    IF approved_qr IS NOT NULL AND public._checkout_release_below_threshold_e(approved_qr) THEN
      SELECT t.* INTO attempt FROM public.reward_attempts t JOIN public.ledger_parties p ON p.id=t.customer_party
        WHERE t.cart_ref=p_cart AND p.user_id=auth.uid() ORDER BY t.created_at DESC,t.id DESC LIMIT 1;
      -- Even an explicit retry cannot override active consent or renew its attempt.
      RETURN jsonb_build_object('status','below_threshold','attempt_id',attempt.id,
        'expires_at',attempt.expires_at,'server_now',clock_timestamp());
    END IF;
  END IF;
  RETURN public._ensure_reward_reservation_before_coupon_threshold(p_cart,p_start_new);
END $e$;

REVOKE ALL ON FUNCTION public._checkout_release_below_threshold_e(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._checkout_approval_capacity_e() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._ensure_reward_reservation_before_coupon_threshold(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.ensure_reward_reservation_v1(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.ensure_reward_reservation_v1(uuid,boolean) TO authenticated;

-- Preserve existing approvals and deadlines; repair only their ineligible live
-- capacity through the same ledger-backed release, with transaction-wide rollback.
DO $repair$ DECLARE item record;
BEGIN
  PERFORM public._reward_lock_e();
  FOR item IN SELECT a.qr_ref FROM public.reward_checkout_approvals a
    JOIN public.qr_sessions q ON q.id=a.qr_ref WHERE q.status='active' ORDER BY a.qr_ref
  LOOP
    PERFORM public._checkout_release_below_threshold_e(item.qr_ref);
  END LOOP;
END $repair$;
COMMIT;
