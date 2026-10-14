// node tool/merchant_operations/schema.test.mjs <local-pglite-package-directory>
// Ephemeral PostgreSQL; no remote credentials or connections.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createCatalogFixture } from '../catalog_media/local_fixture.mjs';
const { db, uid, asUser, category } = await createCatalogFixture(process.argv[2]);
let checks = 0;
async function check(name, fn) { await fn(); console.log(`PASS ${++checks} ${name}`); }
const call = (user=1, shop=10, offset=0, limit=20, extra={}) => asUser(user,
 'SELECT public.merchant_operations_read_v1($1,$2,$3) result',
 {params:[uid(shop),offset,limit],...extra});
try {
 await db.exec(await readFile('supabase/migrations/20261014001700_0017_merchant_daily_operations.sql','utf8'));
 await check('empty counts are exact and no data is invented', async()=>{
  assert.deepEqual((await call())[0].result, {pending_submissions:0,approved_submissions:0,rejected_submissions:0,pending_listings:0,uploads:[]});
 });
 await check('exact ownership, role and anonymous execution are enforced', async()=>{
  await call(1,11,0,20,{deny:true}); await call(3,10,0,20,{deny:true});
  await call(null,10,0,20,{deny:true,role:'anon'});
  await call(1,10,0,20,{deny:true,role:'service_role'});
  await call(1,999,0,20,{deny:true});
 });
 await check('suspended shop and revoked merchant cannot read old dashboard', async()=>{
  await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[uid(10)]);
  await call(1,10,0,20,{deny:true});
  await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[uid(10)]);
  await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[uid(1)]);
  await call(1,10,0,20,{deny:true});
  await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[uid(1)]);
 });
 await check('pagination arguments bounded and nullable inputs denied', async()=>{
  for(const [o,l] of [[-1,20],[0,0],[0,51],[null,20],[0,null]]) await call(1,10,o,l,{deny:true});
 });
 await check('counts cover more than first 100 submissions and exclude foreign owner', async()=>{
  for(let i=0;i<105;i++) await asUser(1,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{
   params:[uid(10),uid(1000+i),{name:`Candidate ${i}`,canonical_category_id:category,product_type:'shared_catalog_product'}]});
  await asUser(2,'SELECT public.merchant_submit_product_v1($1,$2,$3)',{params:[uid(11),uid(1200),{name:'Foreign candidate',canonical_category_id:category,product_type:'shared_catalog_product'}]});
  assert.equal((await call())[0].result.pending_submissions,105);
  assert.equal((await call(2,11))[0].result.pending_submissions,1);
 });
 await check('actual decision status is projected without enabling approval', async()=>{
  // Test fixture only: exercise read classification; public approval stays OFF.
  await db.exec(`UPDATE public.product_submissions SET status='rejected',decided_at=now(),decision_reason='Fixture' WHERE request_id='${uid(1000)}';
   UPDATE public.product_submissions SET status='approved',decided_at=now(),approved_product_id='${uid(20)}' WHERE request_id='${uid(1001)}'`);
  const s=(await call())[0].result;
  assert.equal(s.pending_submissions,103);assert.equal(s.approved_submissions,1);assert.equal(s.rejected_submissions,1);
  assert.equal((await db.query('SELECT decisions_enabled FROM public.catalog_media_config')).rows[0].decisions_enabled,false);
 });
 const intents=[];
 await check('pending media is grouped by listing and fully paginated', async()=>{
  for(let i=0;i<23;i++){
   await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,10,$3)',[uid(2000+i),`Photo product ${i}`,category]);
   await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,15)',[uid(3000+i),uid(10),uid(2000+i)]);
   const images=await asUser(1,"SELECT * FROM public.merchant_prepare_listing_image_v1($1,'image/png',8)",{params:[uid(3000+i)]});
   intents.push(images[0]);
  }
  await asUser(1,"SELECT public.merchant_prepare_listing_image_v1($1,'image/png',8)",{params:[uid(3000)]});
  await asUser(2,"SELECT public.merchant_prepare_listing_image_v1($1,'image/png',8)",{params:[uid(31)]});
  const first=(await call())[0].result, next=(await call(1,10,20))[0].result;
  assert.equal(first.pending_listings,23);assert.equal(first.uploads.length,20);assert.equal(next.uploads.length,3);
  assert.equal(new Set([...first.uploads,...next.uploads].map(u=>u.listing_id)).size,23);
  assert.equal(first.uploads[0].photo_count,2);
  assert.deepEqual(Object.keys(first.uploads[0]).sort(),['listing_id','photo_count','product_name']);
 });
 await check('retirement and publication leave the pending queue; inactive listings can recover',async()=>{
  await db.query('UPDATE public.shop_products SET is_active=false WHERE id=$1',[uid(3001)]);
  assert.ok((await call())[0].result.uploads.some(u=>u.listing_id===uid(3001)));
  await asUser(1,"SELECT public.merchant_change_listing_images_v1($1,'retire',$2)",{params:[uid(3001),intents[1].id]});
  const photo=intents[2];
  await db.query('INSERT INTO storage.objects(bucket_id,name,metadata) VALUES($1,$2,$3)',['listing-media',photo.object_path,{size:8,mimetype:'image/png'}]);
  await asUser(1,"SELECT public.merchant_change_listing_images_v1($1,'publish',$2)",{params:[uid(3002),photo.id]});
  assert.equal((await call())[0].result.pending_listings,21);
  assert.equal((await db.query('SELECT count(*)::int n FROM storage.objects WHERE name=$1',[photo.object_path])).rows[0].n,1);
 });
 await check('fresh read after listing edits and publication matches Customer media contract',async()=>{
  await asUser(1,'UPDATE public.shop_products SET price=24.50,is_available=false WHERE id=$1',{params:[uid(3002)]});
  let rows=await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(3002)]]});
  assert.deepEqual(rows[0].result,[]);
  await asUser(1,'UPDATE public.shop_products SET is_available=true WHERE id=$1',{params:[uid(3002)]});
  rows=await asUser(null,'SELECT public.catalog_listing_media_read_v1($1) result',{role:'anon',params:[[uid(3002)]]});
  assert.equal(rows[0].result[0].images[0].object_path,intents[2].object_path);
  const listing=await asUser(1,'SELECT price,is_available FROM public.shop_products WHERE id=$1',{params:[uid(3002)]});
  assert.equal(Number(listing[0].price),24.5);assert.equal(listing[0].is_available,true);
 });
 console.log(`PASS ${checks} merchant daily operations checks; ephemeral database only`);
} finally { await db.close(); }
