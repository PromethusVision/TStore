// Ephemeral PostgreSQL only; no remote drivers, URLs or credentials.
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { createCatalogFixture } from './local_fixture.mjs';
const { db, uid, asUser, category, leaf } = await createCatalogFixture(process.argv[2]);
let checks = 0;
async function check(name,fn) { await fn(); checks++; console.log(`PASS ${name}`); }
const draft={name:'Yeni kalem',brand:'',model:'',variant:'',gtin:null,canonical_category_id:category,product_type:'shared_catalog_product'};
const submit=(shop=10,request=40,data=draft)=>asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3) result',{params:[uid(shop),uid(request),data]});
await check('GTIN exact returns existing; no central product creation',async()=>{
 const r=await asUser(1,'SELECT public.merchant_catalog_lookup_v1($1,$2,$3) result',{params:[uid(10),'irrelevant','4006381333931']});
 assert.equal(r[0].result.exact,true);assert.equal(r[0].result.products[0].id,uid(20));
 const s=await submit(10,40,{...draft,gtin:'4006381333931'});assert.equal(s[0].result.existing.id,uid(20));
 assert.equal((await db.query('SELECT count(*)::int n FROM public.products')).rows[0].n,1);
});
await check('Invalid GTIN rejected',async()=>{
 for(const g of ['00000000','4006381333932','123','abcdefgh','4006381333931/../'])await asUser(1,'SELECT public.merchant_catalog_lookup_v1($1,$2,$3)',{params:[uid(10),'',g],deny:true});
});
await check('Normalization consistent supported lengths',async()=>{
 assert.equal((await db.query("SELECT public.catalog_gtin_v1('96385074') g")).rows[0].g,'00000096385074');
 assert.equal((await db.query("SELECT public.catalog_gtin_v1('036000291452') g")).rows[0].g,'00036000291452');
});
await check('Concurrent submission retries are idempotent and leave catalog untouched',async()=>{
 // PGlite queues SQL commands; issue separate concurrent RPC invocations. The
 // production advisory locks and unique indexes additionally guard real sessions.
 await db.exec(`SET ROLE authenticated; SET request.jwt.claim.sub='${uid(1)}'; SET request.jwt.claim.role='authenticated'`);
 const requests=Array.from({length:6},()=>db.query('SELECT public.merchant_submit_product_v1($1,$2,$3)',[uid(10),uid(41),{...draft,gtin:'96385074'}]));
 await Promise.all(requests);await db.exec('RESET ROLE');
 assert.equal((await db.query('SELECT count(*)::int n FROM public.product_submissions')).rows[0].n,1);
 assert.equal((await db.query('SELECT count(*)::int n FROM public.products')).rows[0].n,1);
});
await check('Idempotency key cannot change payload',async()=>{await asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{params:[uid(10),uid(41),draft],deny:true});});
await check('Different concurrent requests sharing GTIN stay private candidates, never canonical duplicates',async()=>{
 await db.exec(`SET ROLE authenticated; SET request.jwt.claim.sub='${uid(1)}'; SET request.jwt.claim.role='authenticated'`);
 const responses=await Promise.all(Array.from({length:6},(_,i)=>db.query('SELECT public.merchant_submit_product_v1($1,$2,$3) result',[uid(10),uid(100+i),{...draft,gtin:'96385074'}])));
 await db.exec('RESET ROLE');
 assert.equal(new Set(responses.map(r=>r.rows[0].result.submission.id)).size,6);
 assert.ok(responses.every(r=>r.rows[0].result.submission.status==='pending'));
 assert.equal((await db.query('SELECT count(*)::int n FROM public.products')).rows[0].n,1);
 assert.equal((await db.query("SELECT count(*)::int n FROM public.product_identifiers WHERE gtin='00000096385074'")).rows[0].n,0);
});
await check('Similarity only suggests, never merges',async()=>{
 const r=await asUser(1,'SELECT public.merchant_catalog_lookup_v1($1,$2,$3) result',{params:[uid(10),'Test',null]});assert.equal(r[0].result.exact,false);
 assert.equal(r[0].result.products.length,1);const r2=await submit(10,42,{...draft,name:'Test'});assert.equal(r2[0].result.submission.status,'pending');
});
await check('Foreign shop, customer and unauthenticated writes denied',async()=>{
 await asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{params:[uid(11),uid(43),draft],deny:true});
 await asUser(3,'SELECT public.merchant_catalog_categories_v1($1)',{params:[uid(10)],deny:true});
 await asUser(null,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{role:'anon',params:[uid(10),uid(43),draft],deny:true});
});
await check('Pending private; direct client publication denied',async()=>{
 assert.equal((await asUser(2,'SELECT * FROM public.product_submissions')).length,0);
 await asUser(null,'SELECT * FROM public.product_submissions',{role:'anon',deny:true});
 await asUser(1,"UPDATE public.product_submissions SET status='approved'",{deny:true});
 await asUser(1,'INSERT INTO public.product_identifiers VALUES($1,$2,now())',{params:['00000096385074',uid(20)],deny:true});
 await asUser(1,"INSERT INTO public.products(name,price) VALUES('bad',1)",{deny:true});
});
await check('Canonical leaf and ancestry publication required',async()=>{
 await asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{params:[uid(10),uid(44),{...draft,canonical_category_id:leaf.ancestry[0]}],deny:true});
 const staged=(await db.query("SELECT id FROM public.categories WHERE lifecycle_state='staged' LIMIT 1")).rows[0].id;
 await asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{params:[uid(10),uid(44),{...draft,canonical_category_id:staged}],deny:true});
 const r=await asUser(1,'SELECT * FROM public.merchant_catalog_categories_v1($1)',{params:[uid(10)]});assert.equal(r.length,1);
});
const submission=(await db.query('SELECT id FROM public.product_submissions ORDER BY created_at,id LIMIT 1')).rows[0].id;
await check('Operator seam disabled by default; merchant cannot decide',async()=>{
 await asUser(1,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{params:[submission,'rejected',null,'Gerekçe'],deny:true});
 await asUser(null,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{role:'service_role',params:[submission,'rejected',null,'Gerekçe'],deny:true});
});
await db.exec('UPDATE public.catalog_media_config SET decisions_enabled=true');
await check('Rejection audited, immutable and private',async()=>{
 await asUser(null,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{role:'service_role',params:[submission,'rejected',null,'Geçersiz ürün']});
 const r=await asUser(1,'SELECT status FROM public.product_submissions WHERE id=$1',{params:[submission]});assert.equal(r[0].status,'rejected');
 assert.equal((await asUser(2,'SELECT * FROM public.product_submission_decisions')).length,0);
 await assert.rejects(db.exec("UPDATE public.product_submission_decisions SET reason='changed'"));
});
const prepare=()=>asUser(1,'SELECT p.* FROM public.merchant_prepare_listing_image_v1($1,$2,$3) p',{params:[uid(30),'image/png',8]});
let first,second;
await check('Owner upload intent and server limits',async()=>{
 first=(await prepare())[0];second=(await prepare())[0];
 assert.match(first.object_path,new RegExp(`^shops/${uid(10)}/${uid(30)}/v[0-9]{14}/`));
 await asUser(2,'SELECT public.merchant_prepare_listing_image_v1($1,$2,$3)',{params:[uid(30),'image/png',8],deny:true});
 await asUser(1,'SELECT public.merchant_prepare_listing_image_v1($1,$2,$3)',{params:[uid(30),'text/html',8],deny:true});
 await asUser(1,'SELECT public.merchant_prepare_listing_image_v1($1,$2,$3)',{params:[uid(30),'image/png',8388609],deny:true});
 await db.exec('UPDATE public.catalog_media_config SET max_listing_photos=2');await asUser(1,'SELECT public.merchant_prepare_listing_image_v1($1,$2,$3)',{params:[uid(30),'image/png',8],deny:true});
});
const upload=image=>asUser(1,'INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',{params:['listing-media',image.object_path,{mimetype:'image/png',size:8}]});
await check('Storage pre-upload permission probe cannot publish unfinished bytes',async()=>{
 for(const metadata of [null,{mimetype:'image/png',contentLength:500}]) {
  await db.exec(`BEGIN; SET LOCAL ROLE authenticated; SET LOCAL request.jwt.claim.sub='${uid(1)}'; SET LOCAL request.jwt.claim.role='authenticated'`);
  await db.query('INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',['listing-media',first.object_path,metadata]);
  await assert.rejects(db.query('SELECT public.merchant_change_listing_images_v1($1,$2,$3)',[uid(30),'publish',first.id]));
  await db.exec('ROLLBACK');
 }
});
const change=(action,image=first,order=null,user=1)=>asUser(user,'SELECT public.merchant_change_listing_images_v1($1,$2,$3,$4)',{params:[uid(30),action,image?.id,order]});
await check('Storage wrong shop, unsafe path and MIME denied',async()=>{
 await asUser(2,'INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',{params:['listing-media',first.object_path,{mimetype:'image/png',size:8}],deny:true});
 await asUser(1,'INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',{params:['listing-media',first.object_path,{mimetype:'text/html',size:8}],deny:true});
 await asUser(1,'INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',{params:['listing-media','../bad.png',{mimetype:'image/png',size:8}],deny:true});
 await upload(first);await upload(second);
 await asUser(1,"UPDATE storage.objects SET name='overwrite'",{deny:true});
 await asUser(1,'DELETE FROM storage.objects',{deny:true});
});
await check('Pending photo private',async()=>{
 assert.equal((await asUser(null,'SELECT * FROM public.listing_images',{role:'anon'})).length,0);
 assert.equal((await asUser(null,'SELECT * FROM storage.objects',{role:'anon'})).length,0);
 const r=(await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30)]]}))[0].result[0];
 assert.equal(r.managed,false); // An unfinished upload must not disable valid legacy photos.
});
await check('Atomic publication and primary switch',async()=>{
 await change('publish');await change('publish',second);
 await db.query("UPDATE storage.objects SET metadata='{}'::jsonb WHERE name=$1",[second.object_path]);
 await asUser(1,'SELECT public.merchant_change_listing_images_v1($1,$2,$3)',{params:[uid(30),'primary',second.id],deny:true});
 assert.equal((await db.query('SELECT id FROM public.listing_images WHERE is_primary')).rows[0].id,first.id);
 await db.query('UPDATE storage.objects SET metadata=$1 WHERE name=$2',[{mimetype:'image/png',size:8},second.object_path]);
 await change('primary',second);
 const r=(await db.query('SELECT id FROM public.listing_images WHERE is_primary')).rows;assert.deepEqual(r.map(x=>x.id),[second.id]);
 await assert.rejects(db.query('UPDATE public.listing_images SET is_primary=true WHERE id=$1',[first.id]));
 await asUser(2,'SELECT public.merchant_change_listing_images_v1($1,$2,$3)',{params:[uid(30),'primary',first.id],deny:true});
 await db.query('UPDATE storage.objects SET metadata=$1 WHERE name=$2',[{mimetype:'image/png',size:'invalid'},second.object_path]);
 const valid=(await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30)]]}))[0].result[0];
 assert.deepEqual(valid.images.map(i=>i.id),[first.id]);
 assert.equal((await asUser(null,'SELECT * FROM public.listing_images',{role:'anon'})).length,1);
 assert.equal((await asUser(null,'SELECT * FROM storage.objects',{role:'anon'})).length,1);
 await db.query('UPDATE storage.objects SET metadata=$1 WHERE name=$2',[{mimetype:'image/png',size:8},second.object_path]);
});
await check('Deterministic reorder and no duplicate/foreign IDs',async()=>{
 await change('reorder',null,[second.id,first.id]);
 const r=(await asUser(1,'SELECT public.merchant_listing_media_v1($1) result',{params:[uid(30)]}))[0].result;
 assert.deepEqual(r.images.map(i=>i.id),[second.id,first.id]);
 await asUser(1,'SELECT public.merchant_change_listing_images_v1($1,$2,$3,$4)',{params:[uid(30),'reorder',null,[first.id,first.id]],deny:true});
});
await check('Retirement retains evidence and falls through to remaining valid photo',async()=>{
 await change('retire',second);
 const r=(await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30),uid(31)]]}))[0].result;
 assert.deepEqual(r.find(x=>x.listing_id===uid(30)).images.map(i=>i.id),[first.id]);
 assert.equal((await db.query('SELECT count(*)::int n FROM storage.objects')).rows[0].n,2);
 assert.equal((await asUser(null,'SELECT * FROM storage.objects',{role:'anon'})).length,1);
 await change('retire');
 const empty=(await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30)]]}))[0].result[0];
 assert.equal(empty.managed,true);assert.equal(empty.images.length,0);
});
await check('Unavailable and inactive listings not public; legacy price/deactivate/reactivate still works',async()=>{
 await asUser(1,'UPDATE public.shop_products SET price=15,is_available=false,is_active=false WHERE id=$1',{params:[uid(30)]});
 assert.equal((await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30)]]}))[0].result.length,0);
 await asUser(1,'UPDATE public.shop_products SET is_available=true,is_active=true WHERE id=$1',{params:[uid(30)]});
 assert.equal(Number((await db.query('SELECT price::text FROM public.shop_products WHERE id=$1',[uid(30)])).rows[0].price),15);
});
await check('GTIN unique canonical anchor and foreign unique listing denial',async()=>{
 await db.exec(`INSERT INTO public.products(id,name,price,category_id) VALUES('${uid(21)}','Başka kalem',10,'${category}');
 INSERT INTO public.product_identity(product_id,product_type,origin_shop_id,normalized_name) VALUES('${uid(21)}','merchant_unique_product','${uid(10)}','başka kalem')`);
 await assert.rejects(db.exec(`INSERT INTO public.product_identifiers(gtin,product_id) VALUES('04006381333931','${uid(21)}')`));
 await asUser(2,'INSERT INTO public.shop_products(shop_id,product_id,price) VALUES($1,$2,$3)',{params:[uid(11),uid(21),7],deny:true});
 const result=(await asUser(2,'SELECT public.merchant_catalog_search_v1($1) result',{params:[uid(11)]}))[0].result;
 assert.deepEqual(result.map(p=>p.id),[uid(20)]);
});
await check('Canonical gates protect catalog search and new listing writes',async()=>{
 const staged=(await db.query("SELECT id FROM public.categories WHERE lifecycle_state='staged' LIMIT 1")).rows[0].id;
 await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,$3,$4)',[uid(25),'Hidden',10,staged]);
 await asUser(1,'INSERT INTO public.shop_products(shop_id,product_id,price) VALUES($1,$2,$3)',{params:[uid(10),uid(25),7],deny:true});
 const result=(await asUser(1,'SELECT public.merchant_catalog_search_v1($1) result',{params:[uid(10)]}))[0].result;
 assert.equal(result.some(p=>p.id===uid(25)),false);
 await asUser(1,'SELECT public.merchant_catalog_search_v1($1)',{params:[uid(11)],deny:true});
 await db.query('DELETE FROM public.products WHERE id=$1',[uid(25)]);
});
await check('Listing identity cannot be reassigned underneath image/history ownership',async()=>{
 await asUser(1,'UPDATE public.shop_products SET product_id=$1 WHERE id=$2',{params:[uid(21),uid(30)],deny:true});
 assert.equal((await db.query('SELECT product_id FROM public.shop_products WHERE id=$1',[uid(30)])).rows[0].product_id,uid(20));
});
await check('Successful decision binds legitimate existing product and appends evidence',async()=>{
 const s=(await submit(10,60,{...draft,name:'Test kalem',gtin:'036000291452'}))[0].result.submission;
 await asUser(null,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{role:'service_role',params:[s.id,'approved',uid(20),'Mevcut kimlik doğrulandı']});
 const r=(await asUser(1,'SELECT * FROM public.product_submissions WHERE id=$1',{params:[s.id]}))[0];
 assert.equal(r.status,'approved');assert.equal(r.approved_product_id,uid(20));
 assert.equal((await db.query("SELECT product_id FROM public.product_identifiers WHERE gtin='00036000291452'")).rows[0].product_id,uid(20));
 await asUser(null,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{role:'service_role',params:[s.id,'rejected',null,'Tekrar karar'],deny:true});
});
await check('Identity/category mismatch cannot approve; no fake central insertion',async()=>{
 const s=(await submit(10,61,draft))[0].result.submission;
 await asUser(null,'SELECT public.decide_catalog_submission_v1($1,$2,$3,$4)',{role:'service_role',params:[s.id,'approved',uid(20),'Yanlış kimlik'],deny:true});
 assert.equal((await db.query('SELECT count(*)::int n FROM public.products')).rows[0].n,2);
});
const third=(await prepare())[0];await upload(third);await change('publish',third);
// Test the Production branch with the exact unchanged ancestry/qualification
// function bodies from 0012 on synthetic local tables (no guard relaxation or
// Production snapshot/activation executor). This fixture is not deployable SQL.
await db.exec(`CREATE TABLE public.canonical_categories(LIKE public.categories INCLUDING DEFAULTS);
INSERT INTO public.canonical_categories SELECT * FROM public.categories;
CREATE TABLE public.canonical_category_qualification(category_id uuid,qualification text,policy_gate text,professional_gate text);
INSERT INTO public.canonical_category_qualification SELECT id,CASE WHEN id='${category}' THEN 'LEAF_ASSIGNABLE_CANDIDATE' ELSE 'CONTAINER' END,'PASS','PASS' FROM public.canonical_categories;
CREATE TABLE public.production_taxonomy_config(singleton_id integer,public_enabled boolean); INSERT INTO public.production_taxonomy_config VALUES(1,true);
CREATE TABLE public.product_canonical_assignments(product_id uuid,canonical_category_id uuid); INSERT INTO public.product_canonical_assignments VALUES('${uid(20)}','${category}');`);
const source=await readFile('supabase/migrations/20260916001200_0012_production_canonical_side_by_side.sql','utf8');
for(const name of ['_production_taxonomy_visible_v1','production_taxonomy_assignment_visible_v1']) {
 const start=source.lastIndexOf('CREATE OR REPLACE FUNCTION public.'+name)>=0 ? source.lastIndexOf('CREATE OR REPLACE FUNCTION public.'+name) : source.lastIndexOf('CREATE FUNCTION public.'+name);
 const end=source.indexOf('$fn$;',start)+6;assert.ok(start>=0&&end>start);await db.exec(source.slice(start,end));
}
await check('Production closed publication and ancestor qualifications fail closed',async()=>{
 assert.equal((await asUser(1,'SELECT * FROM public.merchant_catalog_categories_v1($1)',{params:[uid(10)]})).length,1);
 await db.exec('UPDATE public.production_taxonomy_config SET public_enabled=false');
 assert.equal((await asUser(1,'SELECT * FROM public.merchant_catalog_categories_v1($1)',{params:[uid(10)]})).length,0);
 assert.equal((await asUser(null,'SELECT * FROM storage.objects',{role:'anon'})).length,0);
 await db.exec('UPDATE public.production_taxonomy_config SET public_enabled=true');
 await db.query("UPDATE public.canonical_category_qualification SET policy_gate='FAIL_CLOSED' WHERE category_id=$1",[leaf.ancestry[0]]);
 assert.equal((await asUser(1,'SELECT * FROM public.merchant_catalog_categories_v1($1)',{params:[uid(10)]})).length,0);
 assert.equal((await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(30)]]}))[0].result.length,0);
});
console.log(JSON.stringify({status:'PASS',checks,engine:(await db.query('SELECT version() version')).rows[0].version,remote_access:false}));
await db.close();
