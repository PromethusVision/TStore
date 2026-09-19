-- 0013 preview additions only. Caller must reconcile its own 0013 ledger transaction.
BEGIN;
SET LOCAL lock_timeout='3s';
DO $guard$ BEGIN
 IF current_user<>'postgres' OR current_setting('esnaftavar.w52kb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 THEN RAISE EXCEPTION 'W52KB_EXECUTION_CONTEXT'; END IF;
END $guard$;
DROP FUNCTION public.production_preview_products_v1(text,text,uuid,uuid,uuid,boolean,text,boolean,text,boolean,integer,integer) RESTRICT;
DROP FUNCTION public.production_preview_mappings_v1(text,text) RESTRICT;
DROP FUNCTION public.taxonomy_search_context_v2(TEXT,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_resolve_alias_v2(TEXT,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_breadcrumb_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_exact_leaf_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_descendants_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_children_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_roots_v2(TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public._w52kb_path_json_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public._w52kb_node_json_v2(UUID,TEXT,TEXT,BOOLEAN) RESTRICT;
DROP FUNCTION public.taxonomy_capabilities_v2(text,text) RESTRICT;
DROP FUNCTION public._w52kb_assignable(uuid) RESTRICT;
DROP FUNCTION public._w52kb_visible_v2(uuid,text,boolean) RESTRICT;
DROP FUNCTION public._w52kb_assert_contract_v2(text,text,boolean) RESTRICT;
DROP TABLE production_preview_private.testers RESTRICT;
DROP SCHEMA production_preview_private RESTRICT;
COMMIT;
