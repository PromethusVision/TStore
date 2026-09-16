-- Local simulation ONLY, never part of the staged adapter migration.
BEGIN;
DO $guard$
BEGIN
 IF current_setting('esnaftavar.w52h.execution_scope',true) IS DISTINCT FROM 'local-rehearsal'
 THEN RAISE EXCEPTION 'W52H_ACTIVATION_SIMULATION_LOCAL_ONLY'; END IF;
 IF (SELECT count(*) FROM public.product_canonical_assignments WHERE owner_approved)<>20
 THEN RAISE EXCEPTION 'W52H_OWNER_MAPPING_INCOMPLETE'; END IF;
END $guard$;
-- Only existing qualified leaves and their full eligible ancestor chains.
WITH RECURSIVE eligible AS (
 SELECT c.id,c.parent_id FROM public.canonical_categories c
 JOIN public.canonical_category_qualification q ON q.category_id=c.id
 WHERE q.qualification='LEAF_ASSIGNABLE_CANDIDATE' AND q.policy_gate='PASS' AND q.professional_gate='PASS'
 UNION
 SELECT c.id,c.parent_id FROM public.canonical_categories c JOIN eligible e ON e.parent_id=c.id
 JOIN public.canonical_category_qualification q ON q.category_id=c.id
 WHERE q.policy_gate='PASS' AND q.professional_gate='PASS'
) UPDATE public.canonical_categories c SET lifecycle_state='active',is_active=true,
 is_assignable=(q.qualification='LEAF_ASSIGNABLE_CANDIDATE')
FROM eligible e,public.canonical_category_qualification q WHERE c.id=e.id AND q.category_id=c.id;
UPDATE public.production_taxonomy_config SET public_enabled=true WHERE singleton_id=1;
UPDATE public.taxonomy_aliases a SET is_active=true
 WHERE a.resolution_state='RESOLVED'
 AND public._production_taxonomy_visible_v1(a.direct_target_category_id,'canonical-v1.0.0',false);
COMMIT;
