-- Drop only this additive facade after public activation has been rolled back.
-- The executor verifies the exact definitions, grants and ledger first.
DO $guard$ BEGIN
 IF current_setting('esnaftavar.w52lb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 OR (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1) IS DISTINCT FROM false
 THEN RAISE EXCEPTION 'W52LB_ROLLBACK_OFF_REQUIRED'; END IF;
END $guard$;
DROP FUNCTION public.production_public_listings_v1(text,text,uuid,uuid[],uuid,integer,integer);
DROP FUNCTION public.production_public_products_v1(text,text,uuid,uuid,uuid,boolean,text,boolean,text,boolean,integer,integer);
DROP FUNCTION public.production_public_shops_v1(text,text,uuid,uuid[],integer,integer);
DROP FUNCTION public.production_public_read_capabilities_v1(text,text);
