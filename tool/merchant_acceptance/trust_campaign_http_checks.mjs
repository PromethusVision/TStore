import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

export async function trustCampaignHttpChecks({db,request,rpc,session,f,status,localRequest}) {
  const checks=[];
  const check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const merchant=await session(f.merchant.id), customer=await session(f.customer.id), other=await session(f.other.id);
  let receipt, image;
  const draft={title:'Yerel HTTP duyurusu',description:'Mağazada geçerli duyuru.',type:'announcement',scope:'single',listing_ids:[f.listing],image_ids:[],
    starts_at:new Date(Date.now()-60000).toISOString(),ends_at:new Date(Date.now()+86400000).toISOString()};
  const args={p_shop_id:f.shop,p_campaign_id:null,p_expected_revision:null,p_request_id:randomUUID(),p_action:'save',p_draft:draft};
  await check('HTTP D public projection excludes evidence; private trust needs live owner session',async()=>{
    const trust=await rpc('read_my_trust_v1',merchant,{p_shop_id:f.shop});assert.equal(trust.enabled,true);assert.equal(trust.badges.length,5);
    const own=await rpc('read_my_trust_v1',customer,{});assert.equal(own.badges.length,8);
    const shared=await rpc('read_badges_v1',null,{p_shop_ids:[f.shop]});assert.equal(shared.shops[0].shop_id,f.shop);
    assert(!JSON.stringify(shared).includes('history'));assert(!JSON.stringify(shared).includes('subject_id'));
    assert.equal((await request('/rest/v1/rpc/read_my_trust_v1',other,{p_shop_id:f.shop})).ok,false);
    for(const table of ['badge_current_state','badge_award_events','badge_subjects','campaign_requests','campaign_revisions'])
      assert.equal((await request(`/rest/v1/${table}?select=*`,merchant,undefined,'GET')).ok,false);
    assert.equal((await request('/rest/v1/rpc/process_badge_refresh_v1',merchant,{p_limit:1})).ok,false);
  });
  await check('HTTP F retry/ownership and actual Storage upload -> selection -> public signed bytes',async()=>{
    const bytes=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64');
    image=await rpc('merchant_prepare_listing_image_v1',merchant,{p_listing_id:f.listing,p_mime:'image/png',p_bytes:bytes.length});
    const uploaded=await localRequest(status.API_URL,`/storage/v1/object/${image.bucket_id}/${image.object_path}`,{
      method:'POST',headers:{apikey:status.ANON_KEY,Authorization:`Bearer ${merchant.token}`,'Content-Type':'image/png','x-upsert':'false'},body:bytes});
    assert.equal(uploaded.ok,true);
    await rpc('merchant_change_listing_images_v1',merchant,{p_listing_id:f.listing,p_action:'publish',p_image_id:image.id});
    draft.image_ids=[image.id];
    assert.equal((await request('/rest/v1/rpc/mutate_campaign_v1',other,args)).ok,false);
    receipt=await rpc('mutate_campaign_v1',merchant,args);assert.deepEqual(await rpc('mutate_campaign_v1',merchant,args),receipt);
    receipt=await rpc('mutate_campaign_v1',merchant,{...args,p_campaign_id:receipt.id,p_expected_revision:receipt.revision_id,p_request_id:randomUUID(),p_action:'activate',p_draft:null});
    const page=await rpc('read_shop_campaigns_v1',null,{p_shop_id:f.shop});
    assert(Number.isFinite(Date.parse(page.server_time)));
    const current=page.campaigns.find(c=>c.id===receipt.id);assert(current);assert.equal(current.images[0].id,image.id);
    const signed=await request(`/storage/v1/object/sign/${image.bucket_id}`,customer,{paths:[current.images[0].object_path],expiresIn:120});
    assert.equal(signed.ok,true);
    const downloaded=await localRequest(status.API_URL,`/storage/v1${signed.data[0].signedURL}`);assert.equal(downloaded.ok,true);assert.deepEqual(downloaded.body,bytes);
    await rpc('merchant_change_listing_images_v1',merchant,{p_listing_id:f.listing,p_action:'retire',p_image_id:image.id});
    const after=await rpc('read_shop_campaigns_v1',null,{p_shop_id:f.shop});assert.equal(after.campaigns.find(c=>c.id===receipt.id).images.length,0);
    assert.equal((await request('/rest/v1/rpc/mutate_campaign_v1',merchant,{...args,p_campaign_id:receipt.id,p_expected_revision:receipt.revision_id,p_request_id:randomUUID()})).ok,false);
  });
  await check('HTTP F monetary gate and revoked Auth sessions cannot publish/edit/read owner history',async()=>{
    const monetary=await rpc('mutate_campaign_v1',merchant,{...args,p_draft:{...draft,image_ids:[],type:'percentage',percentage_basis_points:1000},p_request_id:randomUUID()});
    const blocked=await request('/rest/v1/rpc/mutate_campaign_v1',merchant,{...args,p_campaign_id:monetary.id,p_expected_revision:monetary.revision_id,p_action:'activate',p_draft:null,p_request_id:randomUUID()});
    assert.equal(blocked.ok,false);assert.match(blocked.data.message,/price_publication_pending/);
    assert.equal((await request('/auth/v1/logout?scope=local',merchant,undefined)).ok,true);
    for(const [name,params] of [
      ['read_my_trust_v1',{p_shop_id:f.shop}],['read_merchant_campaigns_v1',{p_shop_id:f.shop}],
      ['mutate_campaign_v1',{...args,p_campaign_id:receipt.id,p_expected_revision:receipt.revision_id,p_action:'pause',p_draft:null,p_request_id:randomUUID()}],
    ]) { const denied=await request(`/rest/v1/rpc/${name}`,merchant,params);assert.equal(denied.ok,false);assert.equal(denied.data.code,'28000'); }
    const fresh=await session(f.merchant.id);
    await rpc('mutate_campaign_v1',fresh,{...args,p_campaign_id:receipt.id,p_expected_revision:receipt.revision_id,p_action:'pause',p_draft:null,p_request_id:randomUUID()});
    assert(!(await rpc('read_shop_campaigns_v1',null,{p_shop_id:f.shop})).campaigns.some(c=>c.id===receipt.id));
  });
  return checks;
}
