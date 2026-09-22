-- Dedicated executor owns the transaction, locks, validation and exact ledger.
-- No schema, policy, review, mapping, product or legacy mutation.
DO $guard$
BEGIN
 IF current_setting('esnaftavar.w52la.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 OR current_database()<>'postgres' OR session_user<>'postgres'
 OR current_setting('server_version')<>'17.6'
 OR current_setting('transaction_read_only')<>'off'
 THEN RAISE EXCEPTION 'W52LA_EXECUTION_CONTEXT'; END IF;
 IF (SELECT public_enabled FROM public.production_taxonomy_config WHERE singleton_id=1) IS DISTINCT FROM false
 OR EXISTS(SELECT 1 FROM public.canonical_categories WHERE is_active OR is_assignable OR lifecycle_state<>'staged')
 OR EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations WHERE version='20260922001400')
 THEN RAISE EXCEPTION 'W52LA_ALREADY_ACTIVE_OR_DRIFT'; END IF;
END $guard$;
WITH RECURSIVE eligible AS (
 SELECT c.id,c.parent_id,q.qualification FROM public.canonical_categories c
 JOIN public.canonical_category_qualification q ON q.category_id=c.id
 WHERE c.parent_id IS NULL AND q.policy_gate='PASS' AND q.professional_gate='PASS'
 AND q.qualification IN ('CONTAINER_NOT_ASSIGNABLE','LEAF_ASSIGNABLE_CANDIDATE')
 UNION ALL
 SELECT c.id,c.parent_id,q.qualification FROM public.canonical_categories c
 JOIN eligible p ON c.parent_id=p.id JOIN public.canonical_category_qualification q ON q.category_id=c.id
 WHERE q.policy_gate='PASS' AND q.professional_gate='PASS'
 AND q.qualification IN ('CONTAINER_NOT_ASSIGNABLE','LEAF_ASSIGNABLE_CANDIDATE')
)
UPDATE public.canonical_categories c SET is_active=true,lifecycle_state='active',
 is_assignable=(e.qualification='LEAF_ASSIGNABLE_CANDIDATE') FROM eligible e WHERE c.id=e.id;
UPDATE public.production_taxonomy_config SET public_enabled=true WHERE singleton_id=1;
UPDATE public.taxonomy_aliases a SET is_active=true WHERE a.resolution_state='RESOLVED'
 AND public._production_taxonomy_visible_v1(a.direct_target_category_id,'canonical-v1.0.0',false);
