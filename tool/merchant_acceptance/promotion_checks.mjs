import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {rpc,sqlAs} from './fixture.mjs';
import {writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {root} from './local.mjs';

export async function promotionChecks(db,config,f) {
 const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
 const call=(name,args=[],actor=f.merchant)=>rpc(config,actor,name,args);
 const read=(actor=f.merchant,offset=0)=>call('read_merchant_promotions_v1',[f.shop,offset],actor);
 const selection=(family='store',extra={})=>({family,variant:0,listing_id:null,campaign_id:null,image_id:null,...extra});
 const preview=(s,actor=f.merchant)=>call('preview_merchant_promotion_v1',[f.shop,JSON.stringify(s)],actor);
 const save=(s,p,d=null,expected=null,request=randomUUID(),actor=f.merchant)=>
   call('mutate_merchant_promotion_v1',[f.shop,d,expected,request,'save',JSON.stringify(s),p.fingerprint],actor);
 const history=(id,offset=0)=>call('read_promotion_history_v1',[f.shop,id,offset]);
 const scalar=async(sql,args=[])=>Object.values((await db.query(sql,args)).rows[0])[0];
 const listing=randomUUID(),foreign=randomUUID(),image=randomUUID(),path=`shops/${f.shop}/${listing}/v20261015120000/${image}.png`;
 await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,123.45),($4,$5,$3,120)',[listing,f.shop,f.product,foreign,f.otherShop]);
 await check('G disabled feature has no drafts and checks owner before gate',async()=>{
   assert.equal(await scalar('SELECT enabled FROM public.merchant_promotion_config'),false);
   assert.equal((await read()).enabled,false);
   assert.deepEqual((await read()).items,[]);
   for(const a of [f.other,f.customer])await assert.rejects(read(a),e=>e.code==='42501');
   await assert.rejects(save(selection(),{fingerprint:'x'}),e=>e.code==='55000');
 });
 await db.query('UPDATE public.merchant_promotion_config SET enabled=true');
 const s=selection('product',{listing_id:listing});let p,originalPreview,receipt,request=randomUUID();
 await check('G grounded templates use exact current price and reject caller-authored claims',async()=>{
   p=await preview(s);originalPreview=p;assert(p.ready);assert(p.snapshot.body.includes('123,45 TL'));assert.equal(p.snapshot.title,'Local acceptance kalem');
   for(const family of ['store','invitation'])for(const variant of [0,1]){
     const value=await preview(selection(family,{variant}));assert(value.ready);assert.equal(value.snapshot.facts.template_version,1);
   }
   for(const invalid of [{...s,title:'En ucuz'}, {...s,variant:2},{...s,variant:null},{...s,family:'paid'},{family:'store'},
     {...s,listing_id:null},{...s,campaign_id:randomUUID()},{...s,image_id:'url' }])
     await assert.rejects(preview(invalid),e=>e.code==='22023');
   assert.equal((await preview({...s,listing_id:foreign})).ready,false);
   const options=await call('read_promotion_sources_v1',[f.shop,'listing','kalem',0]);
   assert.deepEqual(options.items.map(x=>x.id),[listing]);
   assert.deepEqual((await call('read_promotion_sources_v1',[f.shop,'listing','%',0])).items,[]);
 });
 await check('G save is exact-once under simultaneous retries and immutable receipt replay',async()=>{
   const values=await Promise.all([save(s,p,null,null,request),save(s,p,null,null,request)]);
   assert.deepEqual(values[0],values[1]);receipt=values[0];
   assert.equal((await read()).items.length,1);assert.equal((await history(receipt.id)).items.length,1);
   await assert.rejects(save({...s,variant:1},p,null,null,request),e=>e.code==='22023');
   await assert.rejects(save(s,p,null,null,request,f.other),e=>e.code==='42501');
 });
 await check('G price drift releases no stale copy; failed save creates no partial root',async()=>{
   await db.query('UPDATE public.shop_products SET price=200 WHERE id=$1',[listing]);
   const roots=await scalar('SELECT count(*) FROM public.merchant_promotion_drafts');
   await assert.rejects(save(s,p),e=>e.code==='40001');
   assert.equal(await scalar('SELECT count(*) FROM public.merchant_promotion_drafts'),roots);
   assert.equal((await read()).items[0].status,'needs_update');
   assert((await read()).items[0].snapshot.body.includes('123,45'));
   assert.deepEqual(await save(s,p,null,null,request),receipt);
   p=await preview(s);assert(p.snapshot.body.includes('200,00'));
   const prior=receipt;receipt=await save(s,p,receipt.id,receipt.revision_id);
   await assert.rejects(save(s,p,prior.id,prior.revision_id),e=>e.code==='40001');
 });
 await check('G competing editors cannot overwrite one another',async()=>{
   const prior=receipt;const results=await Promise.allSettled([save(s,p,prior.id,prior.revision_id),save(s,p,prior.id,prior.revision_id)]);
   assert.equal(results.filter(x=>x.status==='fulfilled').length,1);
   assert.equal(results.find(x=>x.status==='rejected').reason.code,'40001');
   receipt=results.find(x=>x.status==='fulfilled').value;
 });
 await check('G stock, category and shop-name changes invalidate saved source snapshots',async()=>{
   await db.query('UPDATE public.shop_products SET is_available=false WHERE id=$1',[listing]);
   assert.equal((await preview(s)).ready,false);assert.equal((await read()).items[0].status,'needs_update');
   await db.query('UPDATE public.shop_products SET is_available=true WHERE id=$1',[listing]);
   await db.query('UPDATE public.categories SET is_active=false WHERE id=$1',[f.category]);
   assert.equal((await preview(s)).ready,false);
   await db.query('UPDATE public.categories SET is_active=true WHERE id=$1',[f.category]);
   await db.query("UPDATE public.shops SET name='New local name' WHERE id=$1",[f.shop]);
   await assert.rejects(save(s,p),e=>e.code==='40001');
   p=await preview(s);
 });
 await check('G only owned published photos with matching Storage metadata are selectable',async()=>{
   await db.query(`INSERT INTO public.listing_images(id,listing_id,bucket_id,object_path,mime_type,byte_size,sort_order,is_primary,publication_state,uploaded_by,published_at)
      VALUES($1,$2,'listing-media',$3,'image/png',68,0,true,'published',$4,now())`,[image,listing,path,f.merchant.id]);
   assert.equal((await preview({...s,image_id:image})).ready,false);
   await db.query("INSERT INTO storage.objects(bucket_id,name,metadata) VALUES('listing-media',$1,$2)",[path,{mimetype:'image/png',size:68}]);
   const photo=await preview({...s,image_id:image});assert(photo.ready);assert.equal(photo.images[0].object_path,path);
   assert.equal((await preview({...s,image_id:randomUUID()})).ready,false);
   await db.query("UPDATE storage.objects SET metadata='{}' WHERE name=$1",[path]);
   await assert.rejects(save({...s,image_id:image},photo),e=>e.code==='40001');
   await db.query("UPDATE storage.objects SET metadata=$2 WHERE name=$1",[path,{mimetype:'image/png',size:68}]);
 });
 let campaign;
 await check('G offers require active currently eligible campaign and ignore ungrounded freeform copy',async()=>{
   await db.query('UPDATE public.campaign_protocol_config SET enabled=true,price_publication_enabled=true');
   const draft={title:'En ucuz en iyi',description:'Garantili kazanç',type:'percentage',scope:'single',listing_ids:[listing],image_ids:[image],
     price_minor:null,percentage_basis_points:1250,starts_at:new Date(Date.now()-60000).toISOString(),ends_at:new Date(Date.now()+3600000).toISOString()};
   campaign=await call('mutate_campaign_v1',[f.shop,null,null,randomUUID(),'save',JSON.stringify(draft)]);
   const campaignId=campaign.campaign_id??campaign.id;
   const revision=campaign.revision_id;
   // The campaign RPC returns its explicit receipt shape, checked here rather than guessed in clients.
   assert(campaignId && revision);
   campaign=await call('mutate_campaign_v1',[f.shop,campaignId,revision,randomUUID(),'activate',null]);
   const offer=selection('offer',{campaign_id:campaignId,listing_id:listing,image_id:image});
   const value=await preview(offer);assert(value.ready);assert(value.snapshot.body.includes('%12,5'));
   assert(!JSON.stringify(value.snapshot).includes('En ucuz'));assert(!JSON.stringify(value.snapshot).includes('Garantili'));
   const record=await save(offer,value);
   await call('mutate_campaign_v1',[f.shop,campaignId,campaign.revision_id,randomUUID(),'pause',null]);
   assert.equal((await preview(offer)).ready,false);
   assert.equal((await read()).items.find(x=>x.id===record.id).status,'needs_update');
   await assert.rejects(save(offer,value),e=>e.code==='40001');
 });
 await check('G archive is reversible append-only history and never a publish operation',async()=>{
   receipt=await call('mutate_merchant_promotion_v1',[f.shop,receipt.id,receipt.revision_id,randomUUID(),'archive',null,null]);
   assert.equal((await read()).items.find(x=>x.id===receipt.id).status,'archived');
   p=await preview(s);receipt=await save(s,p,receipt.id,receipt.revision_id);
   assert.equal((await read()).items.find(x=>x.id===receipt.id).status,'draft');
   const rows=(await history(receipt.id)).items;assert(rows.some(x=>x.action==='archive'));assert(rows.length>=5);
   for(const row of rows)assert.deepEqual(Object.keys(row).sort(),['action','recorded_at','revision_id','snapshot']);
   await assert.rejects(db.query('UPDATE public.merchant_promotion_revisions SET action=action WHERE draft_id=$1',[receipt.id]),/append-only/);
   await assert.rejects(db.query('DELETE FROM public.merchant_promotion_requests WHERE request_id=$1',[request]),/append-only/);
   await assert.rejects(call('mutate_merchant_promotion_v1',[f.shop,receipt.id,receipt.revision_id,randomUUID(),'publish',null,null]),e=>e.code==='22023');
 });
 await check('G stable root pagination survives edits, archive and new drafts',async()=>{
   const simple=selection(),value=await preview(simple);
   for(let i=0;i<21;i++)await save(simple,value);
   const first=await read();assert.equal(first.items.length,20);assert(first.has_more);
   await save(simple,value);
   const next=await read(f.merchant,20);assert(!next.items.some(x=>first.items.some(y=>y.id===x.id)));
   assert.equal(new Set([...first.items,...next.items].map(x=>x.id)).size,24);
   for(const offset of [-1,null,501])await assert.rejects(read(f.merchant,offset),e=>e.code==='22023');
 });
 await check('G raw tables/helpers and foreign history are private; no financial or notification side effects',async()=>{
   for(const role of ['anon','authenticated','service_role'])for(const table of ['merchant_promotion_config','merchant_promotion_drafts','merchant_promotion_revisions','merchant_promotion_requests'])
     assert.equal(await scalar("SELECT has_table_privilege($1,$2,'SELECT,INSERT,UPDATE,DELETE')",[role,'public.'+table]),false);
   await assert.rejects(sqlAs(config,f.merchant,'SELECT public._promotion_preview_g($1,$2)',[f.shop,selection()]),e=>e.code==='42501');
   await assert.rejects(call('read_promotion_history_v1',[f.shop,receipt.id,0],f.other),e=>e.code==='42501');
   const counts=()=>scalar(`SELECT jsonb_build_array((SELECT count(*) FROM public.ledger_journals),(SELECT count(*) FROM public.notifications),(SELECT count(*) FROM public.referral_packages))::text`);
   const before=await counts();await save(s,await preview(s));assert.equal(await counts(),before);
 });
 await check('G live role, shop suspension, revoked session and emergency gate govern reads and replay',async()=>{
   await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.shop]);
   await assert.rejects(read(),e=>e.code==='42501');
   await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.shop]);
   await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
   await assert.rejects(read(),e=>e.code==='42501');
   await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]);
   const revoked=await f.session(f.merchant.id);await db.query('DELETE FROM auth.sessions WHERE id=$1',[revoked.claims.session_id]);
   await assert.rejects(read(revoked),e=>e.code==='28000');
   await db.query('UPDATE public.merchant_promotion_config SET enabled=false');
   assert.equal((await read()).enabled,false);assert.deepEqual((await history(receipt.id)).items,[]);
   assert.equal((await save(s,originalPreview,null,null,request)).id,receipt.id); // replay original committed ID even after edits/gate.
   await db.query('UPDATE public.merchant_promotion_config SET enabled=true');
 });
 f.promotion={selection:s,listing,image,path};
 return checks;
}
export async function promotionHttpChecks({db,request,rpc,session,f,status,localRequest}) {
 const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
 const args={p_shop_id:f.shop};
 await check('G actual Storage bytes use existing upload/sign path; retired image cannot be saved',async()=>{
   const bytes=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64');
   const image=await rpc('merchant_prepare_listing_image_v1',f.merchant,{p_listing_id:f.promotion.listing,p_mime:'image/png',p_bytes:bytes.length});
   const uploaded=await localRequest(status.API_URL,`/storage/v1/object/${image.bucket_id}/${image.object_path}`,{
     method:'POST',headers:{apikey:status.ANON_KEY,Authorization:`Bearer ${f.merchant.token}`,'Content-Type':'image/png','x-upsert':'false'},body:bytes});
   assert(uploaded.ok);
   await rpc('merchant_change_listing_images_v1',f.merchant,{p_listing_id:f.promotion.listing,p_action:'publish',p_image_id:image.id});
   const selection={...f.promotion.selection,image_id:image.id};
   const preview=await rpc('preview_merchant_promotion_v1',f.merchant,{...args,p_selection:selection});
   assert(preview.ready);assert.equal(preview.snapshot.image.id,image.id);
   const signed=await request('/storage/v1/object/sign/listing-media',f.merchant,{paths:[preview.snapshot.image.object_path],expiresIn:120});
   assert(signed.ok);
   const downloaded=await localRequest(status.API_URL,`/storage/v1${signed.data[0].signedURL}`);
   assert(downloaded.ok);assert.deepEqual(downloaded.body,bytes);
   await rpc('merchant_change_listing_images_v1',f.merchant,{p_listing_id:f.promotion.listing,p_action:'retire',p_image_id:image.id});
   const rejected=await request('/rest/v1/rpc/mutate_merchant_promotion_v1',f.merchant,{...args,p_draft_id:null,p_expected_revision:null,
     p_request_id:randomUUID(),p_action:'save',p_selection:selection,p_fingerprint:preview.fingerprint});
   assert.equal(rejected.data.code,'40001');
 });
 await check('G real Auth and PostgREST return decodable owner list and preview',async()=>{
   const list=await rpc('read_merchant_promotions_v1',f.merchant,args);
   const preview=await rpc('preview_merchant_promotion_v1',f.merchant,{...args,p_selection:f.promotion.selection});
   assert.equal(list.items.length,20);assert(preview.ready);
   const history=await rpc('read_promotion_history_v1',f.merchant,{...args,p_draft_id:list.items[0].id});
   await writeFile(resolve(root,'docs/data/merchant_promotion_g_contract.json'),JSON.stringify({evidence_class:'synthetic-local-postgrest',shop_id:f.shop,list,preview,history},null,2)+'\n');
 });
 await check('G HTTP role boundaries, raw tables, logout and repeated mutation receipt',async()=>{
   for(const actor of [null,f.other,f.customer])assert.equal((await request('/rest/v1/rpc/read_merchant_promotions_v1',actor,args)).ok,false);
   for(const table of ['merchant_promotion_config','merchant_promotion_drafts','merchant_promotion_revisions','merchant_promotion_requests'])
     assert.equal((await request('/rest/v1/'+table+'?select=*',f.merchant,undefined,'GET')).ok,false);
   const preview=await rpc('preview_merchant_promotion_v1',f.merchant,{...args,p_selection:f.promotion.selection});
   const command={...args,p_draft_id:null,p_expected_revision:null,p_request_id:randomUUID(),p_action:'save',p_selection:f.promotion.selection,p_fingerprint:preview.fingerprint};
   const first=await rpc('mutate_merchant_promotion_v1',f.merchant,command);
   assert.deepEqual(await rpc('mutate_merchant_promotion_v1',f.merchant,command),first);
   const actor=await session(f.merchant.id);
   assert.equal((await request('/auth/v1/logout?scope=local',actor,{})).ok,true);
   assert.equal((await request('/rest/v1/rpc/mutate_merchant_promotion_v1',actor,command)).data.code,'28000');
 });
 return checks;
}
