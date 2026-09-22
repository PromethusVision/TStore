-- Dedicated rollback validates the exact active state and ledger before entry.
-- Retain 0012/0013 and all taxonomy/product/private-preview data.
DO $guard$
BEGIN
 IF current_setting('esnaftavar.w52la.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 OR current_database()<>'postgres' OR session_user<>'postgres'
 OR current_setting('server_version')<>'17.6'
 OR current_setting('transaction_read_only')<>'off'
 THEN RAISE EXCEPTION 'W52LA_EXECUTION_CONTEXT'; END IF;
 IF (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1) IS DISTINCT FROM true
 OR NOT EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations WHERE version='20260922001400')
 THEN RAISE EXCEPTION 'W52LA_NOT_ACTIVE'; END IF;
END $guard$;
UPDATE public.production_taxonomy_config SET public_enabled=false WHERE singleton_id=1;
UPDATE public.taxonomy_aliases SET is_active=false WHERE is_active;
UPDATE public.canonical_categories SET is_active=false,is_assignable=false,lifecycle_state='staged'
 WHERE is_active OR is_assignable OR lifecycle_state<>'staged';
