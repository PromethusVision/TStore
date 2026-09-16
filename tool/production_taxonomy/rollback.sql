-- Soft rollback simulation: preserve all original and staged data.
-- No product FK restoration is needed because products.category_id never moved.
BEGIN;
DO $guard$
BEGIN
 IF current_setting('esnaftavar.w52h.execution_scope',true) IS DISTINCT FROM 'local-rehearsal'
 THEN RAISE EXCEPTION 'W52H_ROLLBACK_LOCAL_ONLY_PENDING_SEPARATE_AUTHORIZATION'; END IF;
END $guard$;
UPDATE public.production_taxonomy_config SET public_enabled=false,preview_enabled=false WHERE singleton_id=1;
UPDATE public.canonical_categories SET is_active=false,is_assignable=false,lifecycle_state='staged';
UPDATE public.taxonomy_aliases SET is_active=false WHERE taxonomy_version='canonical-v1.0.0';
COMMIT;
