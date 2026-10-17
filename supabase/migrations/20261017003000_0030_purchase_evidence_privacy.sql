-- Merchant B/E recovery: restore the existing minimized participant projection.
-- Additive correction after 0025/0026. Historical migrations remain untouched.
-- PostgreSQL binds '-' before '||': subtracting from the right-hand JSON object
-- did not remove actor identifiers originating in to_jsonb(v).
-- This changes only projection fields, never purchase, return or ledger evidence.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regprocedure('public._purchase_read_b(uuid)') IS NULL
    OR to_regclass('public.reward_checkout_approvals') IS NULL
    OR NOT EXISTS(SELECT 1 FROM information_schema.columns
      WHERE table_schema='public' AND table_name='purchase_return_items'
        AND column_name='ev_coupon_return_minor') THEN
    RAISE EXCEPTION '0030 requires the complete 0025 purchase/coupon evidence contract';
  END IF;
END $preflight$;

CREATE OR REPLACE FUNCTION public._purchase_read_b(p_purchase_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path='' AS $body$
  SELECT (to_jsonb(v) - 'customer_user_id' - 'confirmed_by_user_id')
    ||jsonb_build_object('terms_classification',CASE WHEN t.purchase_id IS NULL THEN 'legacy_unclassified' ELSE t.policy_version END,
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
  FROM public.verified_transactions v LEFT JOIN public.purchase_terms t ON t.purchase_id=v.id WHERE v.id=p_purchase_id
$body$;

-- Preserve the private helper boundary; public RPCs still authorize participants.
REVOKE ALL ON FUNCTION public._purchase_read_b(uuid) FROM PUBLIC,anon,authenticated,service_role;
COMMIT;
