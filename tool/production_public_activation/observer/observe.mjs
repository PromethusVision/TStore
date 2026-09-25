// Read-only supplemental validation. Never imports the Production connector.
import {check,authoritative,classify} from './classifier.mjs';
import {hash,stable,target} from '../live/common.mjs';
import {verify} from '../live/seal.mjs';
import {state as sealedState} from '../live/validators.mjs';
import {transaction} from '../../production_preview_bridge/live_v2/transaction.mjs';
import {integrity} from '../../production_taxonomy/real_contract_checks.mjs';
import {asRole} from '../../production_preview_bridge/execution/rpc-checks.mjs';
import {httpChecks} from './legacy-http.mjs';
import {publicHttp} from './public-http.mjs';
export async function classification(db,active){
 // ON intentionally never evaluates _w52kb_assignable: it requires staged ancestors.
 const predicate=active?'production_taxonomy_assignment_visible_v1':'_w52kb_assignable';
 const row=(await db.query(`SELECT count(*)::int AS total,
 count(*) FILTER(WHERE public.${predicate}(canonical_category_id))::int AS eligible,
 count(*) FILTER(WHERE NOT public.${predicate}(canonical_category_id))::int AS gated,
 count(*) FILTER(WHERE public.production_taxonomy_assignment_visible_v1(canonical_category_id))::int AS public_visible,
 (SELECT count(*)::int FROM public.canonical_categories WHERE level=1 AND public._production_taxonomy_visible_v1(id,'canonical-v1.0.0',false)) AS roots,
 (SELECT count(*)::int FROM public.canonical_categories WHERE is_active AND lifecycle_state='active') AS published,
 (SELECT count(*)::int FROM public.canonical_categories WHERE public.production_taxonomy_assignment_visible_v1(id)) AS leaves,
 (SELECT count(*)::int FROM supabase_migrations.schema_migrations WHERE version='20260922001400') AS activation_entries
 FROM public.product_canonical_assignments`)).rows[0];
 return classify(active,row);
}
async function coverage(db){
 const counts=await integrity(db,true);
 const tables=(await db.query("SELECT n.nspname AS schema,c.relname AS name FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN ('public','auth','storage','production_preview_private') AND c.relkind IN ('r','p') ORDER BY n.nspname,c.relname")).rows;
 const data={};for(const table of tables){
  check(/^[a-zA-Z0-9_]+$/.test(table.schema)&&/^[a-zA-Z0-9_]+$/.test(table.name),'SAFE_TABLE_IDENTIFIER');
  const subtract=table.schema!=='public'?'':({canonical_categories:"-'is_active'-'is_assignable'-'lifecycle_state'",production_taxonomy_config:"-'public_enabled'",taxonomy_aliases:"-'is_active'"}[table.name]??'');
  data[table.schema+'.'+table.name]=(await db.query(`SELECT count(*)::int AS count,md5(coalesce(string_agg(row_hash,'' ORDER BY row_hash COLLATE "C"),'')) AS server_rowset_md5 FROM (SELECT md5((to_jsonb(t)${subtract})::text) AS row_hash FROM "${table.schema}"."${table.name}" t) protected_rows`)).rows[0];
 }
 const metadata={relations:"SELECT n.nspname,c.relname,c.relkind::text,pg_get_userbyid(c.relowner) AS owner,c.relrowsecurity,c.relforcerowsecurity,c.relacl::text FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname IN ('auth','storage') ORDER BY 1,2",columns:"SELECT * FROM information_schema.columns WHERE table_schema IN ('auth','storage') ORDER BY table_schema,table_name,ordinal_position",policies:"SELECT * FROM pg_policies WHERE schemaname IN ('auth','storage') ORDER BY schemaname,tablename,policyname",functions:"SELECT n.nspname,p.proname,pg_get_function_identity_arguments(p.oid) AS args,pg_get_functiondef(p.oid) AS definition,pg_get_userbyid(p.proowner) AS owner,p.proacl::text FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname IN ('auth','storage') AND p.prokind IN ('f','p') ORDER BY 1,2,3"};
 const protection={};for(const[k,sql]of Object.entries(metadata))protection[k]=hash(stable((await db.query(sql)).rows));
 return {result:'PASS',counts,table_count:tables.length,data,auth_storage_metadata:protection,excluded_from_row_hashes:'Only exact reviewed 0014 publication fields; sealed validator checks their exact values'};
}
export const writeProbeStatements=[
 'EXPLAIN (FORMAT JSON) UPDATE public.canonical_categories SET is_active=is_active WHERE false',
 'EXPLAIN (FORMAT JSON) DELETE FROM public.canonical_categories WHERE false',
 'EXPLAIN (FORMAT JSON) INSERT INTO public.canonical_categories(id) SELECT id FROM public.canonical_categories WHERE false',
];
export async function deniedWritePlans(db){
 for(const role of ['anon','authenticated'])await asRole(db,role,null,async()=>{
  for(const sql of writeProbeStatements)await db.exec(`DO $probe$ BEGIN BEGIN EXECUTE '${sql}'; EXCEPTION WHEN insufficient_privilege THEN RETURN; END; RAISE EXCEPTION 'W52LE_WRITE_AUTHORIZATION_UNEXPECTEDLY_ALLOWED' USING ERRCODE='XX000'; END $probe$;`);
 });
 return {result:'PASS',roles:['anon','authenticated'],probes:6,sqlstate:'42501',method:'READ_ONLY_EXPLAIN_WITHOUT_ANALYZE_AUTHORIZATION_CHECK',dml_executed:false};
}
async function references(db){
 const assignments=(await db.query('SELECT product_id::text AS id,public.production_taxonomy_assignment_visible_v1(canonical_category_id) AS eligible FROM public.product_canonical_assignments ORDER BY product_id')).rows;
 const path=(await db.query(`WITH RECURSIVE tree AS (SELECT id,parent_id,level FROM public.canonical_categories WHERE id=(SELECT id FROM public.canonical_categories WHERE level=4 AND is_active AND is_assignable ORDER BY id LIMIT 1) UNION ALL SELECT c.id,c.parent_id,c.level FROM public.canonical_categories c JOIN tree t ON c.id=t.parent_id) SELECT id::text FROM tree ORDER BY level`)).rows.map(r=>r.id);
 return {eligible:assignments.filter(r=>r.eligible).map(r=>r.id),gated:assignments.filter(r=>!r.eligible).map(r=>r.id),path};
}

export async function observe(db,options,mode,request){
 verify(options.seal_sha256);target(db);
 const result=await transaction(db,async()=>{
  // Determine authoritative state BEFORE choosing predicates or validating availability.
  const flags=await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1');
  const active=authoritative(flags.rows,mode);
  const classified=await classification(db,active);
  const state=await sealedState(db,active),extra=await coverage(db),writes_denied=await deniedWritePlans(db);
  const http=await httpChecks(request,{installed:!active});
  const public_http=active?await publicHttp(await references(db),request):null;
  return {result:'PASS',state,classification:classified,coverage:extra,http,writes_denied,public_http};
 });
 // A new read-only snapshot detects a transition during the HTTP checks.
 await transaction(db,async()=>{
  authoritative((await db.query('SELECT public_enabled,preview_enabled FROM public.production_taxonomy_config WHERE singleton_id=1')).rows,mode);
  return {};
 });
 return result;
}
export function compare(before,after,active){
 check(before.classification.public_enabled===false&&after.classification.public_enabled===active,'COMPARE_EXPECTED_STATE');
 // State-dependent classification and visibility must NOT be compared as immutable data.
 check(stable(before.coverage)===stable(after.coverage),'UNREVIEWED_DATA_OR_METADATA_CHANGED');
 check(stable(before.http.legacy)===stable(after.http.legacy),'LEGACY_HTTP_CHANGED');
 if(!active){
  check(before.state.fingerprint===after.state.fingerprint,'BASELINE_FINGERPRINT_NOT_RESTORED');
  check(stable(before.classification)===stable(after.classification),'OFF_CLASSIFICATION_NOT_RESTORED');
  check(stable(before.http.facade_off)===stable(after.http.facade_off),'OFF_FACADE_NOT_RESTORED');
 }
 return {result:'PASS',immutable_coverage:'PASS',legacy_http:'PASS',restored_baseline:!active};
}
