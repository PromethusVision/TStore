-- Read-only owner projection. No new tables, mutation grants or activation.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
 IF to_regprocedure('public._catalog_own_shop_v1(uuid)') IS NULL
 OR to_regclass('public.product_submissions') IS NULL
 OR to_regclass('public.listing_images') IS NULL THEN
  RAISE EXCEPTION 'MERCHANT_OPERATIONS_SLICE_A_REQUIRED';
 END IF;
END $preflight$;
CREATE FUNCTION public.merchant_operations_read_v1(
 p_shop_id uuid, p_offset integer DEFAULT 0, p_limit integer DEFAULT 20
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public AS $function$
BEGIN
 IF public._catalog_own_shop_v1(p_shop_id) IS NOT TRUE THEN
  RAISE EXCEPTION 'MERCHANT_OPERATIONS_FORBIDDEN' USING ERRCODE='42501';
 END IF;
 IF p_offset IS NULL OR p_offset<0 OR p_limit IS NULL OR p_limit<1 OR p_limit>50 THEN
  RAISE EXCEPTION 'MERCHANT_OPERATIONS_ARGUMENTS' USING ERRCODE='22023';
 END IF;
 RETURN (
  WITH pending AS (
   SELECT sp.id listing_id, p.name product_name, count(*)::integer photo_count,
          min(i.created_at) first_upload
   FROM public.listing_images i
   JOIN public.shop_products sp ON sp.id=i.listing_id
   JOIN public.products p ON p.id=sp.product_id
   WHERE sp.shop_id=p_shop_id AND i.publication_state='pending'
   GROUP BY sp.id,p.name
  ), counts AS (
   SELECT count(*) FILTER(WHERE status='pending') pending_submissions,
          count(*) FILTER(WHERE status='approved') approved_submissions,
          count(*) FILTER(WHERE status='rejected') rejected_submissions
   FROM public.product_submissions WHERE shop_id=p_shop_id
  ) SELECT jsonb_build_object(
   'pending_submissions',c.pending_submissions,
   'approved_submissions',c.approved_submissions,
   'rejected_submissions',c.rejected_submissions,
   'pending_listings',(SELECT count(*) FROM pending),
   'uploads',coalesce((SELECT jsonb_agg(jsonb_build_object(
     'listing_id',x.listing_id,'product_name',x.product_name,'photo_count',x.photo_count
    ) ORDER BY x.first_upload,x.listing_id) FROM (
     SELECT * FROM pending ORDER BY first_upload,listing_id LIMIT p_limit OFFSET p_offset
    ) x),'[]'::jsonb)
  ) FROM counts c
 );
END $function$;
REVOKE ALL ON FUNCTION public.merchant_operations_read_v1(uuid,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.merchant_operations_read_v1(uuid,integer,integer) TO authenticated;
COMMIT;
