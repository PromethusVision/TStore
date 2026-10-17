import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {checkTarget,digest,quote,schemaExpression,taxonomyExpression,readOnlySql} from './pilot_preparation_contract.mjs';
import {postCeSchemaMd5,catalogHashExpression,cohortSources,boundedCategories,roleProposal,validateObservation,accountReview} from './pilot_cohort_contract.mjs';
export const publicationSource='supabase/proposals/pilot_catalog_publication_v1.sql';
export const publicationVersion='20261018003300';
export const publicationSources=[...cohortSources,publicationSource,
 'tool/merchant_acceptance/pilot_publication_contract.mjs','tool/merchant_acceptance/pilot_publication.mjs',
 'tool/merchant_acceptance/prepare_pilot_publication.mjs',
 'tool/merchant_acceptance/prepare_pilot_publication_cohort.mjs',
 'lib/features/shop/domain/entities/product_entity.dart','lib/features/shop/data/models/product_model.dart',
 'lib/features/shop/data/repositories/product_repository_impl.dart','lib/features/shop/data/repositories/canonical_rpc_product_repository.dart',
 'lib/features/wishlist/data/repositories/wishlist_repository_impl.dart','lib/features/wishlist/data/models/wishlist_item_model.dart',
 'lib/core/common/widgets/horizontal_product_card.dart','lib/core/common/widgets/vertical_product_card.dart',
 'lib/features/shop/presentation/views/wishlist_view.dart','lib/features/shop/presentation/views/recently_viewed_products_view.dart'];
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const ref=/^[a-z][a-z0-9-]{2,60}$/;
const md5=/^[0-9a-f]{32}$/;
export const lf=s=>s.replaceAll('\r\n','\n');
export async function verifyPublicationProof(repo){
 const proof=JSON.parse(await readFile(resolve(repo,'docs/data/merchant_pilot_publication_acceptance.json'),'utf8'));
 assert.equal(proof.kind,'merchant-pilot-publication-local-only-v1');assert.equal(proof.result,'PASS');assert.equal(proof.remote_access,'NONE');
 assert(md5.test(proof.installed_schema_md5)&&proof.installed_schema_md5!==postCeSchemaMd5);
 assert(proof.checks.length>=29&&proof.checks.every(x=>x.result==='PASS'));assert.equal(proof.client_checks.length,18);assert(proof.client_checks.every(x=>x.result==='PASS'));
 assert.deepEqual(proof.sources.map(x=>x.path),publicationSources);
 for(const s of proof.sources)assert.equal(digest(lf(await readFile(resolve(repo,s.path),'utf8'))),s.sha256_lf,'Local proof stale: '+s.path);
 return proof;
}
const seal=x=>({...x,sha256:digest(JSON.stringify(x))});
// Reuse the unchanged J6 row/category/authority checks after an independently
// verified J7 schema installation. Only the exact schema/token literals change;
// the delivered plan records the real baseline, never a fabricated observation.
export function postPublicationCohortPlans(target,taxonomy,input,observation,expectedSchemaMd5){
 checkTarget(target);assert(md5.test(expectedSchemaMd5)&&expectedSchemaMd5!==postCeSchemaMd5);
 assert.equal(observation.schema_md5,expectedSchemaMd5,'Exact rehearsed J7 schema required');
 const rows={...observation,schema_md5:postCeSchemaMd5};validateObservation(target,taxonomy,rows);
 assert.deepEqual(observation.accounts.map(x=>x.id).sort(),input.accounts.map(x=>x.user_id).filter(Boolean).sort(),'Exact selected account snapshot required');
 const upgrade=original=>{
  const {sha256,...old}=original.plan;
  const plan=seal({...old,contract:old.contract+'-post-publication',baseline_schema_md5:expectedSchemaMd5,
   ...(old.schema_md5?{schema_md5:expectedSchemaMd5}:{}),
   observation_schema_md5:observation.schema_md5,original_contract_sha256:sha256});
  let sql=original.sql;
  for(const [from,to] of [[quote(sha256),quote(plan.sha256)],[quote(postCeSchemaMd5),quote(expectedSchemaMd5)]]){
   assert.equal(sql.split(from).length,2,'Unexpected J6 envelope changed');sql=sql.replace(from,to);
  }
  return {plan,sql};
 };
 const assessment=accountReview(input,rows);
 return {categories:input.category_leaf_ids.length?upgrade(boundedCategories(target,taxonomy,rows,input.category_leaf_ids)):null,
  roles:!assessment.issues.length&&assessment.changes.length?upgrade(roleProposal(target,taxonomy,input,rows)):null};
}
// User-supplied catalog text may contain dollar quote delimiters, even when
// escaped as a SQL string. Choose a block delimiter absent from the entire body.
export function publicationBlock(body){let tag='$publication_'+digest(body)+'$';while(body.includes(tag))tag=tag.slice(0,-1)+'x$';return `DO ${tag} ${body} ${tag};`;}
function exact(x,keys){assert(x&&typeof x==='object'&&!Array.isArray(x));assert.deepEqual(Object.keys(x).sort(),keys.sort(),'Unexpected input fields');}
export const publicationTemplate=()=>({version:1,batch_id:null,compatibility_review_ref:null,items:[]});
export function validatePublication(input,complete=false){
 exact(input,['version','batch_id','compatibility_review_ref','items']);assert.equal(input.version,1);
 assert(input.batch_id===null||uuid.test(input.batch_id));assert(input.compatibility_review_ref===null||ref.test(input.compatibility_review_ref));
 assert(Array.isArray(input.items)&&input.items.length<=100);
 const seen=new Set(),creates=new Set();
 for(const i of input.items){exact(i,['submission_id','product_id','brand_id','create','kind','review_ref']);
  assert(uuid.test(i.submission_id)&&uuid.test(i.product_id));assert(i.brand_id===null||uuid.test(i.brand_id));
  assert.equal(typeof i.create,'boolean');assert.equal(i.kind,'physical_good','Services remain out of scope');assert(ref.test(i.review_ref));
  assert(!seen.has(i.submission_id),'Duplicate submission');seen.add(i.submission_id);
  if(i.create){assert(!creates.has(i.product_id),'Duplicate product creation');creates.add(i.product_id);}
 }
 if(complete)assert(input.batch_id&&input.compatibility_review_ref&&input.items.length,'Exact reviewed submissions and compatible client evidence required');
 return input;
}
export async function loadPublication(repo){const sql=lf(await readFile(resolve(repo,publicationSource),'utf8'));assert(sql.includes('\nBEGIN;\n')&&sql.endsWith('COMMIT;\n'));return {sql,sha256_lf:digest(sql)};}
function envelope(plan,body){return `-- REVIEW ONLY: ${plan.target.project_ref}. Token is NOT target identity or human authorization.\nBEGIN;\nSET LOCAL lock_timeout='5s';\nSET LOCAL statement_timeout='60s';
DO $guard$ BEGIN
 IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'PUBLICATION_REVIEW_NOT_APPROVED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:pilot-catalog-publication',0)) THEN RAISE EXCEPTION 'PUBLICATION_COMPETING_WRITER'; END IF;
END $guard$;
${body}
COMMIT;\n`;}
const tables='public.categories,public.products,public.brands,public.product_identity,public.product_identifiers,public.product_submissions,public.product_submission_decisions,public.catalog_media_config,public.shops,public.profiles,public.shop_products';
export function publicationSchemaPlan(target,source){
 checkTarget(target);assert.equal(digest(source.sql),source.sha256_lf);
 const plan=seal({contract:'pilot-catalog-schema-v1',target,baseline_schema_md5:postCeSchemaMd5,source_sha256_lf:source.sha256_lf,
  version:publicationVersion,name:'0033_pilot_catalog_publication',remote_authorized:false,
  effects:['Private append-only batch receipts','Private operator helper; no API execute grant','Tagged legacy-price guard; existing product values unchanged','One ledger entry; decisions remain OFF'],
  rollback:'Failed transaction rolls back completely. After commit preserve audit; separately review forward correction, never erase publication or purchase evidence.'});
 const body=source.sql.slice(source.sql.indexOf('\nBEGIN;\n')+8,source.sql.lastIndexOf('COMMIT;'));
 return {plan,sql:envelope(plan,`LOCK TABLE ${tables},supabase_migrations.schema_migrations IN SHARE ROW EXCLUSIVE MODE;
DO $baseline$ BEGIN
 IF md5((${schemaExpression})::text)<>${quote(postCeSchemaMd5)} THEN RAISE EXCEPTION 'PUBLICATION_SCHEMA_DRIFT'; END IF;
END $baseline$;
${body}
INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${quote(plan.version)},${quote(plan.name)},ARRAY[${quote(source.sql)}]);
NOTIFY pgrst,'reload schema';`)};
}
function selection(input){return input.items.length?input.items.map(i=>quote(i.submission_id)+'::uuid').join(','):'NULL::uuid';}
function selectedExpression(input){return `(SELECT coalesce(jsonb_agg(jsonb_build_object(
 'submission',to_jsonb(s),'shop_md5',md5(to_jsonb(sh)::text),'role',p.role,'owner',sh.owner_user_id,
 'auth_ready',coalesce(au.email_confirmed_at IS NOT NULL AND au.email=p.email AND au.deleted_at IS NULL
 AND NOT coalesce(au.is_anonymous,false) AND (au.banned_until IS NULL OR au.banned_until<=now()),false),
 'shop_active',sh.is_active,'category_allowed',public._catalog_category_allowed_v1(s.canonical_category_id)) ORDER BY s.id),'[]')
 FROM public.product_submissions s JOIN public.shops sh ON sh.id=s.shop_id JOIN public.profiles p ON p.id=sh.owner_user_id
 LEFT JOIN auth.users au ON au.id=p.id WHERE s.id IN (${selection(input)}))`;}
export function publicationObservationSql(input){
 validatePublication(input);
 return readOnlySql(`SELECT jsonb_build_object('schema_md5',md5((${schemaExpression})::text),
 'taxonomy_md5',md5((${taxonomyExpression})::text),'catalog_md5',${catalogHashExpression},
 'selected',${selectedExpression(input)},'decisions_enabled',(SELECT decisions_enabled FROM public.catalog_media_config),
 'catalog_count',(SELECT count(*) FROM public.products),'brand_count',(SELECT count(*) FROM public.brands),
 'catalog',(SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY id),'[]') FROM (SELECT p.id,p.name,p.brand_id,p.category_id,p.is_active,
 i.product_type,i.origin_shop_id,i.model,i.variant,i.normalized_name,i.normalized_brand,
 (SELECT coalesce(jsonb_agg(gtin ORDER BY gtin),'[]') FROM public.product_identifiers g WHERE g.product_id=p.id) gtins
 FROM public.products p LEFT JOIN public.product_identity i ON i.product_id=p.id ORDER BY p.id LIMIT 500) x),
 'brands',(SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY id),'[]') FROM (SELECT id,name,is_active FROM public.brands ORDER BY id LIMIT 500) x))::text observation_text`);
}
export function publicationPlan(target,input,observation,expectedSchemaMd5){
 checkTarget(target);validatePublication(input,true);assert(md5.test(expectedSchemaMd5)&&expectedSchemaMd5!==postCeSchemaMd5);
 exact(observation,['schema_md5','taxonomy_md5','catalog_md5','selected','decisions_enabled','catalog_count','brand_count','catalog','brands']);
 assert.equal(observation.schema_md5,expectedSchemaMd5,'Installed publication schema proof required');
 for(const k of ['taxonomy_md5','catalog_md5'])assert(md5.test(observation[k]));assert.equal(observation.decisions_enabled,false);
 for(const [count,rows] of [['catalog_count','catalog'],['brand_count','brands']]){assert(Number.isInteger(observation[count])&&observation[count]>=0&&observation[count]<=500);assert.equal(observation[rows].length,observation[count],'Incomplete identity inventory');}
 assert.deepEqual(observation.selected.map(x=>x.submission.id).sort(),input.items.map(x=>x.submission_id).sort(),'Exactly selected submissions required');
 for(const row of observation.selected){assert.equal(row.submission.status,'pending');assert.equal(row.role,'merchant');assert.equal(row.owner,row.submission.submitted_by);assert.equal(row.auth_ready,true);assert.equal(row.shop_active,true);assert.equal(row.category_allowed,true);}
 const plan=seal({contract:'pilot-catalog-publication-v1',target,input,observation,remote_authorized:false,
  legacy_price:'Tagged zero storage sentinel; listing-only client required. Never a free product or a merchant quote.',
  effects:'Exact submissions → catalog identities and append-only decisions; no listing, category, account, marketing or feature activation.'});
 const calls=input.items.map(i=>`PERFORM public._publish_catalog_submission_v1(${quote(i.submission_id)}::uuid,${quote(i.product_id)}::uuid,${i.brand_id?quote(i.brand_id)+'::uuid':'NULL::uuid'},${i.create},${quote(i.review_ref)});`).join('\n');
 const reason='pilot-publication:'+plan.sha256+':';
 const sql=envelope(plan,`LOCK TABLE ${tables},public.catalog_publication_batches IN SHARE ROW EXCLUSIVE MODE;
-- Lock selected Auth authority too; concurrent ban/deletion must finish before the recheck.
SELECT u.id FROM auth.users u WHERE u.id IN (SELECT submitted_by FROM public.product_submissions WHERE id IN (${selection(input)})) ORDER BY u.id FOR SHARE;
${publicationBlock(`DECLARE previous_count bigint; previous_listings text; BEGIN
 IF md5((${schemaExpression})::text)<>${quote(expectedSchemaMd5)} THEN RAISE EXCEPTION 'PUBLICATION_SCHEMA_DRIFT'; END IF;
 IF EXISTS(SELECT 1 FROM public.catalog_publication_batches WHERE id=${quote(input.batch_id)}::uuid OR plan_sha256=${quote(plan.sha256)}) THEN RAISE EXCEPTION 'PUBLICATION_ALREADY_APPLIED_CHECK_RECEIPT'; END IF;
 IF (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false
 OR md5((${taxonomyExpression})::text)<>${quote(observation.taxonomy_md5)} OR ${catalogHashExpression}<>${quote(observation.catalog_md5)}
 OR ${selectedExpression(input)} IS DISTINCT FROM ${quote(JSON.stringify(observation.selected))}::jsonb
 THEN RAISE EXCEPTION 'PUBLICATION_DATA_DRIFT'; END IF;
 SELECT count(*) INTO previous_count FROM public.products;
 SELECT md5(coalesce(jsonb_agg(to_jsonb(sp) ORDER BY id),'[]')::text) INTO previous_listings FROM public.shop_products sp;
 PERFORM set_config('esnaftavar.catalog_batch_hash',${quote(plan.sha256)},true);
 ${calls}
 IF (SELECT count(*) FROM public.products)<>previous_count+${input.items.filter(i=>i.create).length}
 OR (SELECT md5(coalesce(jsonb_agg(to_jsonb(sp) ORDER BY id),'[]')::text) FROM public.shop_products sp)<>previous_listings
 OR EXISTS(SELECT 1 FROM jsonb_array_elements(${quote(JSON.stringify(input.items))}::jsonb) x
 LEFT JOIN public.product_submissions s ON s.id=(x->>'submission_id')::uuid
 LEFT JOIN public.product_submission_decisions d ON d.submission_id=s.id
 WHERE s.status IS DISTINCT FROM 'approved' OR s.approved_product_id IS DISTINCT FROM (x->>'product_id')::uuid
 OR d.product_id IS DISTINCT FROM s.approved_product_id OR d.reason IS DISTINCT FROM ${quote(reason)}||(x->>'review_ref'))
 THEN RAISE EXCEPTION 'PUBLICATION_POSTCHECK'; END IF;
 INSERT INTO public.catalog_publication_batches(id,plan_sha256,reviewed_items) VALUES(${quote(input.batch_id)}::uuid,${quote(plan.sha256)},${quote(JSON.stringify(input.items))}::jsonb);
END`)} `);
 const receipt=readOnlySql(`SELECT id,plan_sha256,reviewed_items,created_at FROM public.catalog_publication_batches WHERE id=${quote(input.batch_id)}::uuid;
SELECT s.id,s.status,s.approved_product_id,d.reason FROM public.product_submissions s LEFT JOIN public.product_submission_decisions d ON d.submission_id=s.id WHERE s.id IN (${selection(input)}) ORDER BY s.id`);
 return {plan,sql,receipt};
}
