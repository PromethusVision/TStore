-- Wave 38B local rollback artifact. Removes only additive v2 contract objects.

BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '120s';

DROP FUNCTION IF EXISTS public.taxonomy_set_preview_v2(BOOLEAN, TEXT);
DROP FUNCTION IF EXISTS public.taxonomy_search_context_v2(TEXT, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_resolve_alias_v2(TEXT, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_breadcrumb_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_exact_leaf_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_descendants_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_children_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_roots_v2(TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public.taxonomy_capabilities_v2(TEXT, TEXT);
DROP FUNCTION IF EXISTS public._taxonomy_path_json_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public._taxonomy_node_json_v2(UUID, TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public._taxonomy_visible_v2(UUID, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS public._taxonomy_assert_contract_v2(TEXT, TEXT, BOOLEAN);
DROP TABLE IF EXISTS public.taxonomy_contract_config;

COMMIT;
