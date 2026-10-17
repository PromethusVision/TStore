import assert from 'node:assert/strict';
import {checkTarget,digest,quote,schemaExpression,taxonomyExpression,readOnlySql,categoryPlan} from './pilot_preparation_contract.mjs';

export const postCeSchemaMd5='78f248b24aa67f7befcc7ccdb9ec97bd';
export const cohortSources=['tool/merchant_acceptance/pilot_cohort_contract.mjs','tool/merchant_acceptance/pilot_cohort.mjs','tool/merchant_acceptance/prepare_pilot_cohort.mjs','tool/merchant_acceptance/pilot_preparation_contract.mjs','tool/merchant_acceptance/pilot_launch_contract.mjs','tool/merchant_acceptance/pilot_hosted_profile.mjs','tool/merchant_acceptance/pilot_launch_profile.mjs','tool/merchant_acceptance/pilot_contract.mjs','tool/merchant_acceptance/fixture.mjs','tool/merchant_acceptance/local.mjs','tool/merchant_acceptance/safety.mjs','tool/merchant_acceptance/docker-proxy.mjs','tool/merchant_acceptance/pilot_repository_test.dart','docs/data/merchant_pilot_test_ce_installation.json'];
cohortSources.push('tool/merchant_acceptance/prepare_pilot.mjs','tool/merchant_acceptance/package-lock.json',
 'supabase/proposals/pilot_notification_text_repair_v1.sql',
 ...['20260812000100_0001_core_auth_catalog.sql','20260812000200_0002_shops.sql','20260812000300_0003_carts_v2.sql','20260812000400_0004_qr_verified_purchases.sql','20260812000500_0005_verified_shop_ratings.sql','20260812000600_0006_chat_notifications_account.sql','20260812000700_0007_storage_realtime.sql','20260814000800_0008_fix_profile_role_guard.sql','20260815000900_0009_verified_product_reviews_storage.sql','20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql','20260830001100_0011_canonical_taxonomy_contract_v2.sql','20261013001600_0016_catalog_listing_media.sql','20261014001700_0017_merchant_daily_operations.sql'].map(x=>'supabase/migrations/'+x),
 'lib/features/merchant/runtime/merchant_runtime.dart','lib/features/merchant/data/supabase_merchant_repository.dart','lib/features/merchant/data/supabase_catalog_media_repository.dart','lib/features/merchant/data/supabase_merchant_operations_repository.dart','lib/features/notifications/data/repositories/notification_repository_impl.dart','lib/features/shop/data/repositories/shop_repository_impl.dart','lib/features/shop/data/repositories/supabase_listing_hero_media_repository.dart','lib/features/cart/data/repositories/qr_session_repository_impl.dart');
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const ref=/^[a-z][a-z0-9-]{2,60}$/;
const hash=/^[0-9a-f]{32}$/;
const seal=x=>({...x,sha256:digest(JSON.stringify(x))});
const exact=(value,keys)=>{assert(value&&typeof value==='object'&&!Array.isArray(value));assert.deepEqual(Object.keys(value).sort(),keys.sort(),'Unknown/private fields forbidden');};
const nullableId=x=>assert(x===null||typeof x==='string'&&uuid.test(x),'Exact UUID or null required');
export const normalizeCatalog=x=>x.replace(/[İI]/g,'i').toLowerCase().replace(/\s+/gu,' ').trim();

export function gtin(value) {
 if(value===null||value==='')return null;
 assert.equal(typeof value,'string');const s=value.trim();
 assert(/^(?:\d{8}|\d{12}|\d{13}|\d{14})$/.test(s)&&!/^0+$/.test(s),'Invalid GTIN');
 let sum=0;for(let i=0;i<s.length-1;i++)sum+=Number(s[i])*((s.length-1-i)%2?3:1);
 assert.equal((10-sum%10)%10,Number(s.at(-1)),'GTIN check digit');return s.padStart(14,'0');
}
export function cohortTemplate() {
 return {version:1,location:'Istanbul / Esenler',category_leaf_ids:[],
  accounts:[{slot:'merchant-01',role:'merchant',user_id:null,identity_review_ref:null},{slot:'customer-01',role:'customer',user_id:null,identity_review_ref:null}],
  products:[]};
}
export function validateIntake(input) {
 exact(input,['version','location','category_leaf_ids','accounts','products']);assert.equal(input.version,1);assert.equal(input.location,'Istanbul / Esenler');
 assert(Array.isArray(input.category_leaf_ids)&&input.category_leaf_ids.length<=50);
 input.category_leaf_ids.forEach(x=>assert(typeof x==='string'&&uuid.test(x)));assert.equal(new Set(input.category_leaf_ids).size,input.category_leaf_ids.length);
 assert(Array.isArray(input.accounts)&&input.accounts.length>0&&input.accounts.length<=20);
 const slots=new Set(),ids=new Set();
 for(const a of input.accounts){exact(a,['slot','role','user_id','identity_review_ref']);assert(['merchant','customer'].includes(a.role));assert(new RegExp('^'+a.role+'-[0-9]{2,4}$').test(a.slot));assert(!slots.has(a.slot));slots.add(a.slot);nullableId(a.user_id);if(a.user_id){assert(!ids.has(a.user_id),'Duplicate identity across slots');ids.add(a.user_id);}assert(a.identity_review_ref===null||ref.test(a.identity_review_ref));}
 assert(input.accounts.some(a=>a.role==='merchant')&&input.accounts.some(a=>a.role==='customer'),'Paired merchant and customer slots required');
 assert(Array.isArray(input.products)&&input.products.length<=100);const productSlots=new Set();
 for(const p of input.products){
  exact(p,['slot','merchant_slot','kind','name','brand','model','variant','gtin','category_id','existing_product_id','evidence_ref']);
  assert(/^product-[0-9]{2,4}$/.test(p.slot)&&!productSlots.has(p.slot));productSlots.add(p.slot);
  assert(input.accounts.some(a=>a.slot===p.merchant_slot&&a.role==='merchant'));
  assert(['physical_good','service'].includes(p.kind));
  for(const [key,max] of [['name',200],['brand',120],['model',120],['variant',120]])assert(typeof p[key]==='string'&&p[key].length<=max&&!/[\u0000-\u001f]/.test(p[key]),'Invalid product text');
  assert(p.name.trim().length>0);gtin(p.gtin);nullableId(p.category_id);nullableId(p.existing_product_id);
  assert(p.evidence_ref===null||ref.test(p.evidence_ref));
 }
 return input;
}

// No credentials or private profile fields are returned. Full row hashes are
// compared inside PostgreSQL; requested account IDs stay in ignored local files.
export const catalogHashExpression=`md5(jsonb_build_object(
 'products',(SELECT coalesce(jsonb_agg(to_jsonb(p) ORDER BY id),'[]') FROM public.products p),
 'brands',(SELECT coalesce(jsonb_agg(to_jsonb(b) ORDER BY id),'[]') FROM public.brands b),
 'identity',(SELECT coalesce(jsonb_agg(to_jsonb(i) ORDER BY product_id),'[]') FROM public.product_identity i),
 'identifiers',(SELECT coalesce(jsonb_agg(to_jsonb(g) ORDER BY gtin),'[]') FROM public.product_identifiers g))::text)`;
export function accountExpression(ids) {
 assert(Array.isArray(ids)&&ids.every(id=>uuid.test(id)));
 const list=ids.length?ids.map(x=>quote(x)+'::uuid').join(','):'NULL::uuid';
 return `(SELECT coalesce(jsonb_agg(jsonb_build_object('id',u.id,'role',p.role,
 'profile_md5',md5(to_jsonb(p)::text),'auth_created_at',u.created_at,
 'email_confirmed',u.email_confirmed_at IS NOT NULL,'email_matches',u.email=p.email,
 'banned',u.banned_until>now(),'deleted',u.deleted_at IS NOT NULL,'anonymous',u.is_anonymous,
 'owned_shops',(SELECT count(*) FROM public.shops s WHERE s.owner_user_id=u.id)) ORDER BY u.id),'[]')
 FROM auth.users u JOIN public.profiles p ON p.id=u.id WHERE u.id IN (${list}))`;
}
export function observationSql(input) {
 validateIntake(input);const ids=input.accounts.map(a=>a.user_id).filter(Boolean);
 return readOnlySql(`SELECT jsonb_build_object('schema_md5',md5((${schemaExpression})::text),
 'taxonomy_md5',md5((${taxonomyExpression})::text),'catalog_md5',${catalogHashExpression},
 'decisions_enabled',(SELECT decisions_enabled FROM public.catalog_media_config),
 'product_count',(SELECT count(*) FROM public.products),
 'catalog',(SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY id),'[]') FROM
 (SELECT p.id,p.name,coalesce(b.name,'') brand,p.category_id,p.is_active,i.product_type,i.origin_shop_id,i.model,i.variant,
 i.normalized_name,i.normalized_brand,public._catalog_product_public_v1(p.id) public_eligible,
 (SELECT coalesce(jsonb_agg(gtin ORDER BY gtin),'[]') FROM public.product_identifiers g WHERE g.product_id=p.id) gtins
 FROM public.products p LEFT JOIN public.brands b ON b.id=p.brand_id LEFT JOIN public.product_identity i ON i.product_id=p.id ORDER BY p.id LIMIT 500) x),
 'accounts',${accountExpression(ids)})::text AS observation_text`);
}
export function validateObservation(target,taxonomyText,observation) {
 checkTarget(target);exact(observation,['schema_md5','taxonomy_md5','catalog_md5','decisions_enabled','product_count','catalog','accounts']);
 assert.equal(observation.schema_md5,postCeSchemaMd5,'Fresh post-C/E schema required');
 assert.equal(observation.taxonomy_md5,digest(taxonomyText,'md5'),'Taxonomy snapshot differs');
 assert.equal(observation.decisions_enabled,false);assert(hash.test(observation.catalog_md5));
 assert(Number.isInteger(observation.product_count)&&observation.product_count>=0&&observation.product_count<=500,'Catalog snapshot too large');
 assert(Array.isArray(observation.catalog)&&observation.catalog.length===observation.product_count,'Incomplete catalog snapshot');
 assert(Array.isArray(observation.accounts)&&observation.accounts.length<=20);
 const seen=new Set();for(const p of observation.catalog){exact(p,['id','name','brand','category_id','is_active','product_type','origin_shop_id','model','variant','normalized_name','normalized_brand','public_eligible','gtins']);assert(uuid.test(p.id)&&!seen.has(p.id));seen.add(p.id);nullableId(p.category_id);nullableId(p.origin_shop_id);assert.equal(typeof p.name,'string');assert.equal(typeof p.brand,'string');assert.equal(typeof p.is_active,'boolean');assert.equal(typeof p.public_eligible,'boolean');assert([null,'shared_catalog_product','merchant_unique_product'].includes(p.product_type));for(const k of ['model','variant','normalized_name','normalized_brand'])assert(p[k]===null||typeof p[k]==='string');assert(Array.isArray(p.gtins));for(const g of p.gtins)assert.equal(gtin(g),g);}
 const users=new Set();for(const a of observation.accounts){exact(a,['id','role','profile_md5','auth_created_at','email_confirmed','email_matches','banned','deleted','anonymous','owned_shops']);assert(uuid.test(a.id)&&!users.has(a.id));users.add(a.id);assert(['customer','merchant','admin'].includes(a.role));assert(hash.test(a.profile_md5));assert(typeof a.auth_created_at==='string'&&Number.isFinite(Date.parse(a.auth_created_at)));for(const k of ['email_confirmed','email_matches','deleted','anonymous'])assert.equal(typeof a[k],'boolean');assert(a.banned===null||typeof a.banned==='boolean');assert(Number.isInteger(a.owned_shops)&&a.owned_shops>=0);}
 return observation;
}
function guarded(plan,body) {
 return `-- REVIEW ONLY: Development ${plan.target.project_ref}; explicit separate approval required.\nBEGIN;\nSET LOCAL lock_timeout='5s';\nSET LOCAL statement_timeout='30s';
DO $cohort_guard$ BEGIN
 IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'PILOT_REVIEW_NOT_APPROVED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:${plan.target.project_ref}:pilot-cohort',0)) THEN RAISE EXCEPTION 'PILOT_COMPETING_WRITER'; END IF;
 IF md5((${schemaExpression})::text)<>${quote(postCeSchemaMd5)} THEN RAISE EXCEPTION 'PILOT_SCHEMA_DRIFT'; END IF;
 IF (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false THEN RAISE EXCEPTION 'PILOT_DECISIONS_DRIFT'; END IF;
END $cohort_guard$;
${body}
COMMIT;\n`;
}
export function boundedCategories(target,taxonomyText,observation,leaves) {
 validateObservation(target,taxonomyText,observation);const original=categoryPlan(target,taxonomyText,leaves);
 const plan=seal({contract:'merchant-pilot-cohort-categories-v1',target,baseline_schema_md5:postCeSchemaMd5,
  taxonomy_md5:observation.taxonomy_md5,catalog_md5:observation.catalog_md5,leaves:original.plan.leaves,changes:original.plan.changes,
  potentially_exposed_products:observation.catalog.filter(p=>leaves.includes(p.category_id)&&p.is_active).map(p=>p.id),remote_authorized:false});
 const ids=plan.changes.map(n=>quote(n.id)+'::uuid').join(','),selected=plan.leaves.map(id=>quote(id)+'::uuid').join(',');
 return {plan,sql:guarded(plan,`LOCK TABLE public.categories,public.products,public.brands,public.product_identity,public.product_identifiers IN SHARE ROW EXCLUSIVE MODE;
DO $cohort_categories$ DECLARE before_nodes jsonb; after_nodes jsonb;
BEGIN
 before_nodes:=${taxonomyExpression};
 IF md5(before_nodes::text)<>${quote(plan.taxonomy_md5)} OR ${catalogHashExpression}<>${quote(plan.catalog_md5)} THEN RAISE EXCEPTION 'PILOT_DATA_DRIFT'; END IF;
 UPDATE public.categories SET is_active=true,lifecycle_state='active',is_assignable=(id=ANY(ARRAY[${selected}])) WHERE id=ANY(ARRAY[${ids}]);
 after_nodes:=${taxonomyExpression};
 IF EXISTS(SELECT 1 FROM unnest(ARRAY[${selected}]) id WHERE NOT public._catalog_category_allowed_v1(id)) THEN RAISE EXCEPTION 'PILOT_CATEGORY_POSTCHECK'; END IF;
 IF (SELECT jsonb_agg(CASE WHEN (n->>'id')::uuid=ANY(ARRAY[${ids}]) THEN n||jsonb_build_object('is_active',false,'lifecycle_state','staged','is_assignable',false) ELSE n END ORDER BY ord) FROM jsonb_array_elements(after_nodes) WITH ORDINALITY x(n,ord)) IS DISTINCT FROM before_nodes THEN RAISE EXCEPTION 'PILOT_UNRELATED_CATEGORY_CHANGE'; END IF;
END $cohort_categories$;`)};
}
export function accountReview(input,observation) {
 validateIntake(input);const issues=[],changes=[];
 for(const item of input.accounts){const observed=observation.accounts.find(a=>a.id===item.user_id);
  if(!item.user_id||!item.identity_review_ref){issues.push({slot:item.slot,reason:'IDENTITY_REVIEW_MISSING'});continue;}
  if(!observed){issues.push({slot:item.slot,reason:'EXISTING_AUTH_PROFILE_REQUIRED'});continue;}
  if(!observed.email_confirmed||!observed.email_matches||observed.deleted||observed.banned||observed.anonymous){issues.push({slot:item.slot,reason:'AUTH_NOT_READY'});continue;}
  if(observed.role==='admin'||observed.owned_shops!==0||(item.role==='customer'&&observed.role!=='customer')){issues.push({slot:item.slot,reason:'EXISTING_AUTHORITY_REQUIRES_SEPARATE_REVIEW'});continue;}
  if(item.role==='merchant'&&observed.role==='customer')changes.push({slot:item.slot,user_id:item.user_id,from:'customer',to:'merchant',identity_review_ref:item.identity_review_ref});
 }
 return {issues,changes,status:issues.length?'INCOMPLETE':changes.length?'PROPOSED_ONLY':'NO_ROLE_CHANGE_NEEDED'};
}
export function roleProposal(target,taxonomyText,input,observation) {
 validateObservation(target,taxonomyText,observation);const assessment=accountReview(input,observation);
 assert.equal(assessment.issues.length,0,'All account identities must be independently reviewed');assert(assessment.changes.length>0,'No role changes to propose');
 const ids=input.accounts.map(a=>a.user_id).sort();assert.deepEqual(observation.accounts.map(a=>a.id).sort(),ids,'Exact selected account snapshot required');
 const plan=seal({contract:'merchant-pilot-existing-account-role-v1',target,schema_md5:postCeSchemaMd5,
  accounts:input.accounts,before:observation.accounts,changes:assessment.changes,remote_authorized:false,
  excluded:'No Auth creation, confirmation override, invite/reset email, admin, shop creation/transfer or catalog decision enablement'});
 const changed=assessment.changes.map(a=>quote(a.user_id)+'::uuid').join(','),all=ids.map(id=>quote(id)+'::uuid').join(',');
 // Compare parsed jsonb rather than serialisation order supplied by a caller.
 const before=quote(JSON.stringify(plan.before))+'::jsonb';
 return {plan,sql:guarded(plan,`LOCK TABLE public.shops IN SHARE ROW EXCLUSIVE MODE;
DO $cohort_roles$ DECLARE before_profiles jsonb; after_profiles jsonb; changed_count integer;
BEGIN
 PERFORM 1 FROM auth.users WHERE id IN (${all}) ORDER BY id FOR UPDATE;
 PERFORM 1 FROM public.profiles WHERE id IN (${all}) ORDER BY id FOR UPDATE;
 IF ${accountExpression(ids)} IS DISTINCT FROM ${before} THEN RAISE EXCEPTION 'PILOT_ACCOUNT_DRIFT'; END IF;
 SELECT jsonb_agg(to_jsonb(p)-'role'-'updated_at' ORDER BY id) INTO before_profiles FROM public.profiles p WHERE id IN (${all});
 UPDATE public.profiles SET role='merchant' WHERE id IN (${changed}) AND role='customer';
 GET DIAGNOSTICS changed_count=ROW_COUNT;
 IF changed_count<>${assessment.changes.length} THEN RAISE EXCEPTION 'PILOT_ROLE_COUNT'; END IF;
 SELECT jsonb_agg(to_jsonb(p)-'role'-'updated_at' ORDER BY id) INTO after_profiles FROM public.profiles p WHERE id IN (${all});
 IF before_profiles IS DISTINCT FROM after_profiles OR EXISTS(SELECT 1 FROM public.profiles WHERE id IN (${changed}) AND role<>'merchant') THEN RAISE EXCEPTION 'PILOT_ROLE_POSTCHECK'; END IF;
END $cohort_roles$;`)};
}

export function catalogReview(target,taxonomyText,input,observation) {
 validateIntake(input);validateObservation(target,taxonomyText,observation);const out=[],seenGtins=new Map(),seenListings=new Set();
 for(const p of input.products){let status,matched=null;const barcode=gtin(p.gtin);
  const identity=JSON.stringify([p.kind,normalizeCatalog(p.name),normalizeCatalog(p.brand),p.model,p.variant,p.category_id,p.existing_product_id]);
  const previous=barcode?seenGtins.get(barcode):null;
  if(previous&&(previous.identity!==identity||previous.merchants.has(p.merchant_slot))){out.push({slot:p.slot,status:'DUPLICATE_GTIN_REVIEW_REQUIRED',automatic_publication:false});continue;}
  if(barcode){if(previous)previous.merchants.add(p.merchant_slot);else seenGtins.set(barcode,{identity,merchants:new Set([p.merchant_slot])});}
  if(p.existing_product_id){const listing=p.merchant_slot+':'+p.existing_product_id;if(seenListings.has(listing)){out.push({slot:p.slot,status:'DUPLICATE_LISTING_REVIEW_REQUIRED',automatic_publication:false});continue;}seenListings.add(listing);}
  if(p.kind!=='physical_good')status='SERVICES_OUT_OF_SCOPE';
  else if(!p.evidence_ref||!p.category_id)status='PRODUCT_EVIDENCE_MISSING';
  else {
   try{categoryPlan(target,taxonomyText,[p.category_id]);}catch{status='CATEGORY_REVIEW_REQUIRED';}
   if(!status&&!input.category_leaf_ids.includes(p.category_id))status='CATEGORY_NOT_SELECTED';
   const matches=barcode?observation.catalog.filter(x=>x.gtins.includes(barcode)):[];
   if(!status&&matches.length>1)status='CATALOG_INTEGRITY_CONFLICT';
   if(!status&&p.existing_product_id){matched=observation.catalog.find(x=>x.id===p.existing_product_id);
    if(!matched||matches.length&&matches[0].id!==matched.id)status='CATALOG_SELECTION_CONFLICT';
    else if(matched.product_type!=='shared_catalog_product'||matched.origin_shop_id!==null)status='UNIQUE_PRODUCT_REQUIRES_OWNER_REVIEW';
    else if(!matched.is_active||matched.category_id!==p.category_id||normalizeCatalog(p.name)!==matched.normalized_name||normalizeCatalog(p.brand)!==matched.normalized_brand||p.model!==matched.model||p.variant!==matched.variant||barcode&&!matched.gtins.includes(barcode))status='CATALOG_IDENTITY_MISMATCH';
    else status='EXISTING_PRODUCT_REVIEWED_CATEGORY_APPLY_PENDING';
   }
   if(!status)status=matches.length?'EXACT_GTIN_REQUIRES_EXPLICIT_SELECTION':'NEW_PRODUCT_MATERIALIZATION_BLOCKED';
  }
  const suggestions=observation.catalog.filter(x=>normalizeCatalog(x.name).includes(normalizeCatalog(p.name))).slice(0,10).map(x=>x.id);
  out.push({slot:p.slot,status,product_id:matched?.id??null,suggestions,automatic_publication:false});
 }
 return {items:out,publication_sql_generated:false,central_price_invented:false,
  ready_for_listing_review:out.length>0&&out.every(x=>x.status==='EXISTING_PRODUCT_REVIEWED_CATEGORY_APPLY_PENDING'),
  materialization_gate:'New product creation needs a reviewed legacy-price/publication/assignment contract; decisions stay OFF'};
}
