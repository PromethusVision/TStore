// Offline, bounded review preparation. No hosted connection or apply API.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {checkTarget, digest, quote, schemaExpression, readOnlySql} from './pilot_preparation_contract.mjs';
import {catalogHashExpression} from './pilot_cohort_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';

export const powerbankManifestPath='docs/data/merchant_pilot_powerbank_category.json';
export const powerbankProofPath='docs/data/merchant_pilot_powerbank_acceptance.json';
export const fullCategoryExpression="(SELECT coalesce(jsonb_agg(to_jsonb(c) ORDER BY id),'[]') FROM public.categories c)";
const ids={root:'dae0270c-90ac-4248-919b-05531cf7c0e8',parent:'1bd43c2b-adb9-42a9-9a8e-f179e11739e8',leaf:'e704d61e-72ca-4609-ba79-e431c780881d'};
const exact=(v,keys)=>assert.deepEqual(Object.keys(v).sort(),[...keys].sort(),'Unexpected observation fields');
const md5=x=>assert(typeof x==='string'&&/^[a-f0-9]{32}$/.test(x),'Exact database fingerprint required');
export async function powerbankManifest(repo){
  const m=JSON.parse(await readFile(resolve(repo,powerbankManifestPath),'utf8'));
  return validatePowerbankManifest(m);
}
export function validatePowerbankManifest(m){
  assert.equal(m.kind,'merchant-pilot-powerbank-category-v1');
  assert.equal(m.authority,'LOCAL_PREPARATION_AND_TEST_ONLY');
  assert.equal(m.remote_authorized,false);
  assert.deepEqual(m.path,['Elektronik','Güç, Şarj & Bağlantı','Powerbank']);
  assert.equal(m.root_id,ids.root);assert.equal(m.parent_id,ids.parent);
  assert.deepEqual(m.node,{id:ids.leaf,name:'Powerbank',source_key:'CANONICAL-001564',slug:'powerbank-001564',level:3,sort_order:1,policy_class:'NORMAL',professional_review_status:'not_required',taxonomy_version:'canonical-v1.0.0'});
  return m;
}
const nodeFields="'id',id,'name',name,'parent_id',parent_id,'level',level,'is_active',is_active,'is_assignable',is_assignable,'lifecycle_state',lifecycle_state,'policy_class',policy_class,'professional_review_status',professional_review_status,'taxonomy_version',taxonomy_version";
export function powerbankObservationSql(){
  return readOnlySql(`SELECT jsonb_build_object(
    'schema_md5',md5((${schemaExpression})::text),
    'categories_md5',md5((${fullCategoryExpression})::text),
    'catalog_md5',${catalogHashExpression},
    'category_count',(SELECT count(*) FROM public.categories),
    'active_count',(SELECT count(*) FROM public.categories WHERE is_active OR lifecycle_state='active'),
    'product_count',(SELECT count(*) FROM public.products),
    'listing_count',(SELECT count(*) FROM public.shop_products),
    'root',(SELECT jsonb_build_object(${nodeFields}) FROM public.categories WHERE id='${ids.root}'),
    'parent',(SELECT jsonb_build_object(${nodeFields}) FROM public.categories WHERE id='${ids.parent}'),
    'children',(SELECT count(*) FROM public.categories WHERE parent_id='${ids.parent}'),
    'identity_collisions',(SELECT count(*) FROM public.categories WHERE id='${ids.leaf}' OR source_key='CANONICAL-001564' OR lower(slug)='powerbank-001564')
  )::text AS observation_text`);
}
export function validatePowerbankObservation(target,o){
  checkTarget(target);
  exact(o,['schema_md5','categories_md5','catalog_md5','category_count','active_count','product_count','listing_count','root','parent','children','identity_collisions']);
  for(const key of ['schema_md5','categories_md5','catalog_md5'])md5(o[key]);
  assert.equal(o.schema_md5,installedSchemaMd5,'Exact installed schema required');
  assert.equal(o.category_count,1563,'Only the reviewed initial extension');
  for(const key of ['active_count','product_count','listing_count','children','identity_collisions'])assert.equal(o[key],0,'Initial empty/staged baseline required: '+key);
  for(const [node,id,name,parent,level] of [[o.root,ids.root,'Elektronik',null,1],[o.parent,ids.parent,'Güç, Şarj & Bağlantı',ids.root,2]]){
    assert.deepEqual(node,{id,name,parent_id:parent,level,is_active:false,is_assignable:false,lifecycle_state:'staged',policy_class:'NORMAL',professional_review_status:'not_required',taxonomy_version:'canonical-v1.0.0'},'Approved ancestry only');
  }
}
export function powerbankCategoryPlan(target,o,m){
  validatePowerbankObservation(target,o);
  validatePowerbankManifest(m);
  const data={kind:'merchant-pilot-powerbank-category-review-v1',target,remote_authorized:false,
    before:o,manifest_sha256:digest(JSON.stringify(m)),
    changes:{insert:{...m.node,parent_id:ids.parent,is_active:true,is_assignable:true,lifecycle_state:'active'},
      activate_ancestors:[ids.root,ids.parent]},
    excluded:['Product publication','Listing or price writes','Accounts or roles','Schema or permission changes','Production'],
    note:'Exactly one new leaf and two existing ancestors. Historical aliases and manifests are not rewritten.'};
  const plan={...data,sha256:digest(JSON.stringify(data))};
  const newRow=JSON.stringify(plan.changes.insert);
  const sql=`-- REVIEW ONLY: Development ${target.project_ref}. Separate owner approval and target verification required.
-- The token prevents accidental execution; it is not human authorization or server identity.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $powerbank_guard$ BEGIN
 IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'POWERBANK_REVIEW_NOT_APPROVED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:${target.project_ref}:pilot-cohort',0)) THEN RAISE EXCEPTION 'POWERBANK_COMPETING_WRITER'; END IF;
END $powerbank_guard$;
LOCK TABLE public.categories,public.products,public.brands,public.product_identity,public.product_identifiers,public.shop_products IN SHARE ROW EXCLUSIVE MODE;
DO $powerbank_change$
DECLARE prior jsonb; after_nodes jsonb; changed integer; added uuid;
BEGIN
 IF md5((${schemaExpression})::text)<>${quote(o.schema_md5)} THEN RAISE EXCEPTION 'POWERBANK_SCHEMA_DRIFT'; END IF;
 prior:=${fullCategoryExpression};
 IF md5(prior::text)<>${quote(o.categories_md5)} OR ${catalogHashExpression}<>${quote(o.catalog_md5)}
    OR (SELECT count(*) FROM public.shop_products)<>0 THEN RAISE EXCEPTION 'POWERBANK_DATA_DRIFT'; END IF;
 IF (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false THEN RAISE EXCEPTION 'POWERBANK_DECISION_DRIFT'; END IF;
 IF (SELECT count(*) FROM public.categories)<>1563 OR EXISTS(SELECT 1 FROM public.categories WHERE is_active OR lifecycle_state='active' OR parent_id='${ids.parent}')
 OR (SELECT jsonb_build_object(${nodeFields}) FROM public.categories WHERE id='${ids.root}') IS DISTINCT FROM ${quote(JSON.stringify(o.root))}::jsonb
 OR (SELECT jsonb_build_object(${nodeFields}) FROM public.categories WHERE id='${ids.parent}') IS DISTINCT FROM ${quote(JSON.stringify(o.parent))}::jsonb
 OR EXISTS(SELECT 1 FROM public.products) THEN RAISE EXCEPTION 'POWERBANK_BASELINE_MISMATCH'; END IF;
 IF EXISTS(SELECT 1 FROM public.categories WHERE id='${ids.leaf}' OR source_key='CANONICAL-001564' OR lower(slug)='powerbank-001564') THEN RAISE EXCEPTION 'POWERBANK_IDENTITY_EXISTS'; END IF;
 INSERT INTO public.categories(id,name,parent_id,sort_order,is_active,source_key,slug,level,lifecycle_state,is_assignable,policy_class,professional_review_status,taxonomy_version)
 SELECT id,name,parent_id,sort_order,is_active,source_key,slug,level,lifecycle_state,is_assignable,policy_class,professional_review_status,taxonomy_version
 FROM jsonb_populate_record(NULL::public.categories,${quote(newRow)}::jsonb) RETURNING id INTO added;
 IF added IS DISTINCT FROM '${ids.leaf}'::uuid THEN RAISE EXCEPTION 'POWERBANK_INSERT_COUNT'; END IF;
 UPDATE public.categories SET is_active=true,lifecycle_state='active'
 WHERE id IN ('${ids.root}','${ids.parent}') AND NOT is_active AND lifecycle_state='staged' AND NOT is_assignable;
 GET DIAGNOSTICS changed=ROW_COUNT;
 IF changed<>2 THEN RAISE EXCEPTION 'POWERBANK_ANCESTRY_DRIFT'; END IF;
 after_nodes:=${fullCategoryExpression};
 IF jsonb_array_length(after_nodes)<>jsonb_array_length(prior)+1
 OR (SELECT jsonb_agg(n ORDER BY n->>'id') FROM jsonb_array_elements(prior) n WHERE n->>'id' NOT IN ('${ids.root}','${ids.parent}'))
 IS DISTINCT FROM (SELECT jsonb_agg(n ORDER BY n->>'id') FROM jsonb_array_elements(after_nodes) n WHERE n->>'id' NOT IN ('${ids.root}','${ids.parent}','${ids.leaf}'))
 THEN RAISE EXCEPTION 'POWERBANK_UNRELATED_CHANGE'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(prior) old JOIN jsonb_array_elements(after_nodes) fresh ON old->>'id'=fresh->>'id'
 WHERE old->>'id' IN ('${ids.root}','${ids.parent}') AND old-ARRAY['is_active','lifecycle_state','updated_at'] IS DISTINCT FROM fresh-ARRAY['is_active','lifecycle_state','updated_at'])
 THEN RAISE EXCEPTION 'POWERBANK_ANCESTOR_FIELDS'; END IF;
 IF NOT public._catalog_category_allowed_v1('${ids.leaf}') OR public._catalog_category_allowed_v1('${ids.parent}') THEN RAISE EXCEPTION 'POWERBANK_ASSIGNMENT_POSTCHECK'; END IF;
 IF ${catalogHashExpression}<>${quote(o.catalog_md5)} OR (SELECT count(*) FROM public.shop_products)<>0
 OR md5((${schemaExpression})::text)<>${quote(o.schema_md5)} THEN RAISE EXCEPTION 'POWERBANK_SCOPE_POSTCHECK'; END IF;
END $powerbank_change$;
COMMIT;
`;
  return {plan,sql};
}

// Recovery is a separately reviewed deactivation, never deletion or UUID reuse.
// It is deliberately unavailable once any products/listings exist.
export function powerbankRollbackPlan(target,o,m){
  checkTarget(target);validatePowerbankManifest(m);
  exact(o,['schema_md5','categories_md5','catalog_md5','category_count','active_count','product_count','listing_count','root','parent','children','identity_collisions']);
  for(const k of ['schema_md5','categories_md5','catalog_md5'])md5(o[k]);
  assert.equal(o.schema_md5,installedSchemaMd5);
  assert.equal(o.category_count,1564);assert.equal(o.active_count,3);
  assert.equal(o.children,1);assert.equal(o.identity_collisions,1);
  assert.equal(o.product_count,0);assert.equal(o.listing_count,0);
  // The same immutable ancestor fields must still hold after activation.
  validatePowerbankObservation(target,{...o,category_count:1563,active_count:0,children:0,identity_collisions:0,
    root:{...o.root,is_active:false,lifecycle_state:'staged'},parent:{...o.parent,is_active:false,lifecycle_state:'staged'}});
  for(const n of [o.root,o.parent]){assert.equal(n.is_active,true);assert.equal(n.lifecycle_state,'active');}
  const data={kind:'merchant-pilot-powerbank-deactivation-review-v1',target,remote_authorized:false,before:o,retained_id:ids.leaf};
  const plan={...data,sha256:digest(JSON.stringify(data))};
  const sql=`-- REVIEW ONLY: ${target.project_ref}; separate recovery approval required. No DELETE.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
LOCK TABLE public.categories,public.products,public.brands,public.product_identity,public.product_identifiers,public.shop_products IN SHARE ROW EXCLUSIVE MODE;
DO $powerbank_recovery$
DECLARE prior jsonb; after_nodes jsonb; changed integer;
BEGIN
 IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'POWERBANK_RECOVERY_NOT_APPROVED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:${target.project_ref}:pilot-cohort',0)) THEN RAISE EXCEPTION 'POWERBANK_COMPETING_WRITER'; END IF;
 IF md5((${schemaExpression})::text)<>${quote(o.schema_md5)} THEN RAISE EXCEPTION 'POWERBANK_SCHEMA_DRIFT'; END IF;
 prior:=${fullCategoryExpression};
 IF md5(prior::text)<>${quote(o.categories_md5)} OR ${catalogHashExpression}<>${quote(o.catalog_md5)}
 OR EXISTS(SELECT 1 FROM public.products) OR EXISTS(SELECT 1 FROM public.shop_products)
 OR (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false THEN RAISE EXCEPTION 'POWERBANK_RECOVERY_DRIFT'; END IF;
 UPDATE public.categories SET is_active=false,lifecycle_state='staged',is_assignable=false
 WHERE id IN ('${ids.root}','${ids.parent}','${ids.leaf}') AND is_active AND lifecycle_state='active';
 GET DIAGNOSTICS changed=ROW_COUNT;
 IF changed<>3 THEN RAISE EXCEPTION 'POWERBANK_RECOVERY_COUNT'; END IF;
 after_nodes:=${fullCategoryExpression};
 IF jsonb_array_length(after_nodes)<>jsonb_array_length(prior)
 OR (SELECT jsonb_agg(n ORDER BY n->>'id') FROM jsonb_array_elements(prior) n WHERE n->>'id' NOT IN ('${ids.root}','${ids.parent}','${ids.leaf}'))
 IS DISTINCT FROM (SELECT jsonb_agg(n ORDER BY n->>'id') FROM jsonb_array_elements(after_nodes) n WHERE n->>'id' NOT IN ('${ids.root}','${ids.parent}','${ids.leaf}'))
 OR public._catalog_category_allowed_v1('${ids.leaf}') THEN RAISE EXCEPTION 'POWERBANK_RECOVERY_POSTCHECK'; END IF;
 IF ${catalogHashExpression}<>${quote(o.catalog_md5)} OR md5((${schemaExpression})::text)<>${quote(o.schema_md5)}
 OR EXISTS(SELECT 1 FROM public.categories WHERE is_active OR lifecycle_state='active')
 THEN RAISE EXCEPTION 'POWERBANK_RECOVERY_SCOPE'; END IF;
END $powerbank_recovery$;
COMMIT;
`;
  return {plan,sql};
}
