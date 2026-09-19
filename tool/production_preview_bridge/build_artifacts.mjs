// Generate additive facade definitions from the frozen DTO functions, not 0010/0011.
import {readFileSync,writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
const root=resolve(import.meta.dirname,'../..');
const source=readFileSync(resolve(root,'supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql'),'utf8').replaceAll('\r\n','\n');
if(createHash('sha256').update(source).digest('hex')!=='a72332213046505047e3e01d0d3795343b4e0d0eff8567388db464536ddc4834')throw Error('FROZEN_0012_CHANGED');
function facade(name){
 const start=source.indexOf(`CREATE OR REPLACE FUNCTION public.${name}(`);
 if(start<0)throw Error('FUNCTION_NOT_FOUND');
 const end=source.indexOf('$fn$;',start)+6;
 return source.slice(start,end).replace('CREATE OR REPLACE FUNCTION','CREATE FUNCTION')
 .replaceAll('_production_taxonomy_','_w52kb_').replaceAll('production_taxonomy_','taxonomy_').replaceAll('_v1(', '_v2(')
 .replaceAll('c.is_assignable','public._w52kb_assignable(c.id)');
}
const publicNames=['capabilities','roots','children','descendants','exact_leaf','breadcrumb','resolve_alias','search_context'];
const header=`-- W52K-B / 0013: private authenticated preview only. 0012 is unchanged.
-- Empty, expiring operator-managed allowlist. No client grant/mutation endpoint.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='120s';
DO $guard$ BEGIN
 IF current_user<>'postgres' OR current_database()<>'postgres' OR current_setting('server_version')<>'17.6'
 OR current_setting('esnaftavar.w52kb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 THEN RAISE EXCEPTION 'W52KB_EXECUTION_CONTEXT'; END IF;
 IF NOT EXISTS(SELECT 1 FROM supabase_migrations.schema_migrations WHERE version='20260916001200' AND name='0012_production_canonical_side_by_side')
 OR EXISTS(SELECT 1 FROM public.production_taxonomy_config WHERE public_enabled OR preview_enabled)
 OR (SELECT count(*) FROM public.canonical_categories)<>1563
 OR (SELECT count(*) FROM public.product_canonical_assignments)<>20
 THEN RAISE EXCEPTION 'W52KB_STAGED_BASELINE_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM pg_proc WHERE pronamespace='public'::regnamespace AND proname=ANY(ARRAY[${publicNames.map(n=>`'taxonomy_${n}_v2'`).join(',')}]))
 THEN RAISE EXCEPTION 'W52KB_EXISTING_CONTRACT_REFUSED'; END IF;
END $guard$;
CREATE SCHEMA production_preview_private AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA production_preview_private FROM PUBLIC,anon,authenticated,service_role;
CREATE TABLE production_preview_private.testers (
 user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 enabled boolean NOT NULL DEFAULT false,
 granted_at timestamptz NOT NULL DEFAULT now(),
 expires_at timestamptz NOT NULL,
 CHECK(expires_at>granted_at AND expires_at<=granted_at+interval '30 days')
);
ALTER TABLE production_preview_private.testers ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON production_preview_private.testers FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION public._w52kb_assert_contract_v2(p_client_contract_version text,p_taxonomy_version text,p_preview boolean)
RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 IF auth.role() IS DISTINCT FROM 'authenticated' OR auth.uid() IS NULL
 OR NOT EXISTS(SELECT 1 FROM production_preview_private.testers t WHERE t.user_id=auth.uid() AND t.enabled AND t.granted_at<=now() AND t.expires_at>now())
 THEN RAISE EXCEPTION 'W52KB_PREVIEW_UNAUTHORIZED' USING ERRCODE='42501'; END IF;
 IF p_client_contract_version IS DISTINCT FROM 'taxonomy-client-v1' OR p_taxonomy_version IS DISTINCT FROM 'canonical-v1.0.0'
 THEN RAISE EXCEPTION 'W38_CLIENT_CONTRACT_VERSION_MISMATCH'; END IF;
 IF p_preview IS DISTINCT FROM true THEN RAISE EXCEPTION 'W52KB_PRIVATE_PREVIEW_REQUIRED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.production_taxonomy_config WHERE singleton_id=1 AND NOT public_enabled AND NOT preview_enabled)
 THEN RAISE EXCEPTION 'W52KB_PUBLIC_ACTIVATION_MUST_REMAIN_OFF'; END IF;
 IF (SELECT count(*) FROM public.product_canonical_assignments)<>20
 OR EXISTS(SELECT 1 FROM public.products p LEFT JOIN public.product_canonical_assignments a ON a.product_id=p.id WHERE a.product_id IS NULL)
 THEN RAISE EXCEPTION 'W52KB_MAPPING_INCOMPLETE'; END IF;
END $fn$;

CREATE FUNCTION public._w52kb_visible_v2(p_category_id uuid,p_taxonomy_version text,p_preview boolean)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 WITH RECURSIVE ancestors AS (
  SELECT id,parent_id,lifecycle_state,taxonomy_version,policy_class FROM public.canonical_categories WHERE id=p_category_id
  UNION ALL SELECT c.id,c.parent_id,c.lifecycle_state,c.taxonomy_version,c.policy_class FROM public.canonical_categories c JOIN ancestors a ON c.id=a.parent_id
 ) SELECT p_preview=true AND EXISTS(SELECT 1 FROM ancestors)
 AND NOT EXISTS(SELECT 1 FROM ancestors WHERE lifecycle_state<>'staged' OR taxonomy_version<>p_taxonomy_version OR policy_class='EXCLUDED')
$fn$;

CREATE FUNCTION public._w52kb_assignable(p_category_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 WITH RECURSIVE ancestors AS (
  SELECT id,parent_id FROM public.canonical_categories WHERE id=p_category_id
  UNION ALL SELECT c.id,c.parent_id FROM public.canonical_categories c JOIN ancestors a ON c.id=a.parent_id
 ) SELECT public._w52kb_visible_v2(p_category_id,'canonical-v1.0.0',true)
 AND EXISTS(SELECT 1 FROM public.canonical_category_qualification WHERE category_id=p_category_id AND qualification='LEAF_ASSIGNABLE_CANDIDATE')
 AND NOT EXISTS(SELECT 1 FROM public.canonical_categories WHERE parent_id=p_category_id)
 AND NOT EXISTS(SELECT 1 FROM ancestors a LEFT JOIN public.canonical_category_qualification q ON q.category_id=a.id WHERE q.category_id IS NULL OR q.policy_gate<>'PASS' OR q.professional_gate<>'PASS')
$fn$;

CREATE FUNCTION public.taxonomy_capabilities_v2(p_client_contract_version text,p_taxonomy_version text)
RETURNS SETOF jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public._w52kb_assert_contract_v2(p_client_contract_version,p_taxonomy_version,true);
 RETURN NEXT jsonb_build_object(
  'contract_version','taxonomy-client-v1','client_contract_version','taxonomy-client-v1',
  'taxonomy_version','canonical-v1.0.0','taxonomy_data_version','canonical-v1.0.0',
  'rpc_contract_version','taxonomy-rpc-v2','rpc_generation',2,
  'supported_features',ARRAY['roots','children','descendants','breadcrumb','alias_resolution','search','product_scopes'],
  'verified_evidence',ARRAY['authoritative_contract_version','exact_rpc_signatures','required_response_shapes','lifecycle_publication_semantics','hierarchy_semantics','alias_outcome_semantics','taxonomy_version_semantics'],
  'preview_support',true,'preview_enabled',true,'lifecycle_metadata',true,'policy_metadata',true,'alias_state_metadata',true,'path_metadata',true,
  'public_active_root_count',0,'pilot_active_root_count',0,'preview_root_count',(SELECT count(*) FROM public.canonical_categories WHERE parent_id IS NULL AND public._w52kb_visible_v2(id,p_taxonomy_version,true)),
  'product_scope_contract','exact-leaf-visible-assignable-policy-eligible','product_scope_requires_assignable',true,'product_scope_policy_fail_closed',true,
  'preview_authorized',true,'preview_subject',auth.uid(),'public_enabled',false,'project_ref','mefhfvrgkwciubeajjeb',
  'preview_bridge_contract','production-private-preview-v1','product_scope_rpc','production_preview_products_v1');
END $fn$;
`;
const product=`
-- Exact owner mappings are readable for review, including six gated mappings.
-- Eligibility never grants product visibility or assignment for those six.
CREATE FUNCTION public.production_preview_mappings_v1(p_client_contract_version text,p_taxonomy_version text)
RETURNS TABLE(product_id uuid,canonical_category_id uuid,canonical_path text,canonical_name text,eligible boolean)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
BEGIN
 PERFORM public._w52kb_assert_contract_v2(p_client_contract_version,p_taxonomy_version,true);
 RETURN QUERY SELECT a.product_id,a.canonical_category_id,a.canonical_path,c.name,public._w52kb_assignable(c.id)
 FROM public.product_canonical_assignments a JOIN public.canonical_categories c ON c.id=a.canonical_category_id ORDER BY a.product_id;
END $fn$;

-- INVOKER deliberately preserves caller RLS on products and brands.
CREATE FUNCTION public.production_preview_products_v1(
 p_client_contract_version text,p_taxonomy_version text,
 p_category_id uuid DEFAULT NULL,p_product_id uuid DEFAULT NULL,p_brand_id uuid DEFAULT NULL,
 p_is_featured boolean DEFAULT NULL,p_term text DEFAULT NULL,p_exact_leaf boolean DEFAULT false,
 p_sort_by text DEFAULT 'created_at',p_ascending boolean DEFAULT true,p_limit integer DEFAULT 20,p_offset integer DEFAULT 0
) RETURNS TABLE(product_id uuid,canonical_category_id uuid,canonical_path text,product jsonb)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path=pg_catalog,public AS $fn$
BEGIN
 -- Capability checks identity, allowlist, public OFF and mapping completeness.
 PERFORM * FROM public.taxonomy_capabilities_v2(p_client_contract_version,p_taxonomy_version);
 IF p_limit IS NULL OR p_limit<1 OR p_limit>100 OR p_offset IS NULL OR p_offset<0 OR p_ascending IS NULL
 OR p_sort_by IS NULL OR p_sort_by NOT IN ('created_at','name','price','rating') OR length(p_term)>200 OR p_exact_leaf IS NULL
 THEN RAISE EXCEPTION 'W52KB_PRODUCT_SCOPE_ARGUMENTS'; END IF;
 IF p_category_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.taxonomy_breadcrumb_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true))
 THEN RAISE EXCEPTION 'W52KB_CATEGORY_UNAVAILABLE'; END IF;
 IF p_exact_leaf AND (p_category_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.taxonomy_exact_leaf_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true)))
 THEN RAISE EXCEPTION 'W52KB_EXACT_LEAF_REQUIRED'; END IF;
 RETURN QUERY WITH allowed AS MATERIALIZED (
  SELECT m.* FROM public.production_preview_mappings_v1(p_client_contract_version,p_taxonomy_version) m
  WHERE m.eligible AND (p_category_id IS NULL OR m.canonical_category_id IN (
   SELECT d.id FROM public.taxonomy_descendants_v2(p_category_id,p_client_contract_version,p_taxonomy_version,true) d
  ))
 ), projected AS (
  SELECT p.id,m.canonical_category_id,m.canonical_path,p.name,p.created_at,
   to_jsonb(p)||jsonb_build_object('category_id',m.canonical_category_id,'legacy_category_id',p.category_id,'categories',jsonb_build_object('name',m.canonical_name),
    'brands',CASE WHEN b.id IS NULL THEN NULL ELSE jsonb_build_object('name',b.name) END) AS payload
  FROM public.products p JOIN allowed m ON m.product_id=p.id LEFT JOIN public.brands b ON b.id=p.brand_id
  WHERE p.is_active AND (p_product_id IS NULL OR p.id=p_product_id) AND (p_brand_id IS NULL OR p.brand_id=p_brand_id)
   AND (p_is_featured IS NULL OR p.is_featured=p_is_featured)
   AND (p_term IS NULL OR p.name ILIKE '%'||p_term||'%' OR p.description ILIKE '%'||p_term||'%')
 ) SELECT x.id,x.canonical_category_id,x.canonical_path,x.payload FROM projected x
 ORDER BY
  CASE WHEN p_sort_by='name' AND p_ascending THEN x.name END ASC,
  CASE WHEN p_sort_by='name' AND NOT p_ascending THEN x.name END DESC,
  CASE WHEN p_sort_by='price' AND p_ascending THEN (x.payload->>'price')::numeric END ASC,
  CASE WHEN p_sort_by='price' AND NOT p_ascending THEN (x.payload->>'price')::numeric END DESC,
  CASE WHEN p_sort_by='rating' AND p_ascending THEN (x.payload->>'rating')::numeric END ASC,
  CASE WHEN p_sort_by='rating' AND NOT p_ascending THEN (x.payload->>'rating')::numeric END DESC,
  CASE WHEN p_sort_by='created_at' AND p_ascending THEN x.created_at END ASC,
  CASE WHEN p_sort_by='created_at' AND NOT p_ascending THEN x.created_at END DESC,x.id
 LIMIT p_limit OFFSET p_offset;
END $fn$;
`;
const names=[...publicNames.map(n=>`taxonomy_${n}_v2`),'production_preview_mappings_v1','production_preview_products_v1'];
const grants=`
DO $grants$ DECLARE f record; BEGIN
 FOR f IN SELECT oid::regprocedure AS signature,proname FROM pg_proc WHERE pronamespace='public'::regnamespace
 AND (proname=ANY(ARRAY[${names.map(n=>`'${n}'`).join(',')}]) OR proname LIKE '\\_w52kb\\_%') LOOP
 EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',f.signature);
 IF f.proname=ANY(ARRAY[${names.map(n=>`'${n}'`).join(',')}]) THEN EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO authenticated',f.signature); END IF;
 END LOOP;
END $grants$;
COMMIT;
`;
const sql=header+['_production_taxonomy_node_json_v1','_production_taxonomy_path_json_v1',...publicNames.slice(1).map(n=>`production_taxonomy_${n}_v1`)].map(facade).join('\n\n')+product+grants;
writeFileSync(resolve(root,'supabase/migrations/20260919001300_0013_production_canonical_private_preview.sql'),sql);
// Exact additions only, no CASCADE, no mutation of 0012 or historical ledger.
const rollback=`-- 0013 preview additions only. Caller must reconcile its own 0013 ledger transaction.
BEGIN;
SET LOCAL lock_timeout='3s';
DO $guard$ BEGIN
 IF current_user<>'postgres' OR current_setting('esnaftavar.w52kb.target_ref',true) IS DISTINCT FROM 'mefhfvrgkwciubeajjeb'
 THEN RAISE EXCEPTION 'W52KB_EXECUTION_CONTEXT'; END IF;
END $guard$;
${[...sql.matchAll(/CREATE FUNCTION public\.([a-z_0-9]+)\(([^]*?)\)\s*RETURNS/g)].reverse().map(m=>{const args=m[2].trim().split(',').map(a=>a.trim().split(/\s+/)[1]).join(',');return `DROP FUNCTION public.${m[1]}(${args}) RESTRICT;`;}).join('\n')}
DROP TABLE production_preview_private.testers RESTRICT;
DROP SCHEMA production_preview_private RESTRICT;
COMMIT;
`;
writeFileSync(resolve(import.meta.dirname,'rollback.sql'),rollback);
console.log('PREVIEW_ARTIFACTS_GENERATED');
