import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import { writeFile } from 'node:fs/promises';
import { readRun, credentials, runtimeEvidence, root } from './local.mjs';
import { localUrl, localRequest, requestJson } from './safety.mjs';
import { connect, migrate, seed } from './fixture.mjs';
import { databaseChecks } from './postgres_checks.mjs';
import { reviewChecks } from './review_checks.mjs';
import { reviewHttpChecks } from './review_http_checks.mjs';
import { trustCampaignChecks } from './trust_campaign_checks.mjs';
import { trustCampaignHttpChecks } from './trust_campaign_http_checks.mjs';
import { ledgerChecks, ledgerHttpChecks } from './ledger_checks.mjs';

const reviews=process.argv.includes('--reviews');
const trustCampaigns=process.argv.includes('--trust-campaigns');
const ledger=process.argv.includes('--ledger');

let db, run, environmentReady=false;
try {
  assert(process.argv[2], 'Prepared local run directory required');
  run = await readRun(process.argv[2]);
  const status = await credentials(run);
  const services = await runtimeEvidence(run);
  const url = localUrl(status.DB_URL, 'db');
  const config = { host: '127.0.0.1', port: Number(url.port), database: 'postgres', user: 'postgres',
    password: decodeURIComponent(url.password), ssl: false };
  db = await connect(config);
  environmentReady=true;
  const manifest = await migrate(db,{reviews,trustCampaigns,ledger});
  const request = (path, actor, body, method) => requestJson(status.API_URL, path, actor?.token, status.ANON_KEY, body, method);
  const rpc = async (name, actor, args) => {
    const r = await request(`/rest/v1/rpc/${name}`, actor, args);
    assert.equal(r.ok, true, `HTTP RPC failed: ${name} (${r.status})`); return r.data;
  };
  const identities = new Map();
  async function session(id) {
    const identity = identities.get(id); assert(identity);
    const login = await request('/auth/v1/token?grant_type=password', null, identity);
    assert.equal(login.status,200); assert(login.data.access_token);
    const claims = JSON.parse(Buffer.from(login.data.access_token.split('.')[1],'base64url'));
    assert.equal(claims.sub,id); assert(claims.session_id); assert.equal(claims.role,'authenticated');
    const stored = (await db.query('SELECT user_id FROM auth.sessions WHERE id=$1',[claims.session_id])).rows[0];
    assert.equal(stored.user_id,id);
    return { id, claims, token: login.data.access_token, installation: randomUUID() };
  }
  async function actor() {
    const email = `${randomUUID()}@example.invalid`, password = randomBytes(32).toString('base64url');
    const created = await requestJson(status.API_URL, '/auth/v1/admin/users', status.SERVICE_ROLE_KEY,
      status.SERVICE_ROLE_KEY, { email, password, email_confirm: true });
    assert.equal(created.ok,true); assert(created.data.id);
    identities.set(created.data.id,{email,password}); return session(created.data.id);
  }
  const f = await seed(db, await actor(), await actor(), await actor()); f.session = id=>id?session(id):actor();
  // PostgREST schema-cache reload is local only; retry a read while it catches up.
  await db.query("NOTIFY pgrst,'reload schema'");
  let ready = false;
  for (let i=0;i<30;i++) {
    const r = await request('/rest/v1/rpc/qr_capabilities_v2',f.merchant,{});
    if (r.ok) { assert.equal(r.data.enabled,false); ready=true; break; }
    await new Promise(r=>setTimeout(r,200));
  }
  assert(ready,'Managed Auth/PostgREST capability unavailable');
  const checks = [];
  const check = async (name,fn) => { await fn(); checks.push({name,result:'PASS'}); console.log(`PASS ${name}`); };
  await check('managed Auth session JWT accepted; forged signature and customer ownership denied', async()=>{
    const forged={...f.merchant,token:f.merchant.token.slice(0,-8)+'aaaaaaaa'};
    assert.equal((await request('/rest/v1/rpc/qr_capabilities_v2',forged,{})).ok,false);
    const forbidden=await request('/rest/v1/rpc/merchant_prepare_listing_image_v1',f.customer,
      {p_listing_id:randomUUID(),p_mime:'image/png',p_bytes:68});
    assert.equal(forbidden.ok,false);
  });
  await check('catalog to owned listing; price/availability update and fresh session read', async()=>{
    const rows=await rpc('merchant_catalog_search_v1',f.merchant,{p_shop_id:f.shop,p_query:'Local acceptance',p_limit:30,p_offset:0});
    assert(rows.some(r=>r.id===f.product || r.product_id===f.product));
    f.listing=randomUUID();
    assert.equal((await request('/rest/v1/shop_products',f.merchant,
      {id:f.listing,shop_id:f.shop,product_id:f.product,price:13,is_available:false})).ok,true);
    assert.equal((await request(`/rest/v1/shop_products?id=eq.${f.listing}`,f.merchant,
      {price:12,is_available:true},'PATCH')).ok,true);
    const fresh=await session(f.merchant.id);
    const read=await request(`/rest/v1/shop_products?id=eq.${f.listing}&select=id,price,is_available`,fresh,undefined,'GET');
    assert.equal(read.status,200); assert.equal(read.data[0].price,12); assert.equal(read.data[0].is_available,true);
  });
  await check('real Storage owned upload, publish, fresh Customer bytes and foreign upload denial', async()=>{
    const bytes=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64');
    const intent=await rpc('merchant_prepare_listing_image_v1',f.merchant,{p_listing_id:f.listing,p_mime:'image/png',p_bytes:bytes.length});
    const objectPath=`${intent.bucket_id}/${intent.object_path}`;
    const upload=async actor=>localRequest(status.API_URL,`/storage/v1/object/${objectPath}`,{
      method:'POST',
      headers:{apikey:status.ANON_KEY,Authorization:`Bearer ${actor.token}`,'Content-Type':'image/png','x-upsert':'false'},body:bytes});
    const foreign=await upload(f.other); assert.equal(foreign.ok,false);
    const unfinished=await request('/rest/v1/rpc/merchant_change_listing_images_v1',f.merchant,
      {p_listing_id:f.listing,p_action:'publish',p_image_id:intent.id}); assert.equal(unfinished.ok,false);
    const uploaded=await upload(f.merchant); assert.equal(uploaded.ok,true);
    await rpc('merchant_change_listing_images_v1',f.merchant,{p_listing_id:f.listing,p_action:'publish',p_image_id:intent.id});
    const freshCustomer=await session(f.customer.id);
    const media=await rpc('catalog_listing_media_read_v1',freshCustomer,{p_listing_ids:[f.listing]});
    assert.equal(media[0].images[0].id,intent.id); assert.equal(media[0].images[0].is_primary,true);
    const signed=await request(`/storage/v1/object/sign/${intent.bucket_id}`,freshCustomer,
      {paths:[intent.object_path],expiresIn:300});
    assert.equal(signed.ok,true); assert(signed.data[0].signedURL?.startsWith('/object/sign/'));
    const download=await localRequest(status.API_URL,`/storage/v1${signed.data[0].signedURL}`);
    assert.equal(download.ok,true); assert.deepEqual(download.body,bytes);
    const duplicate=await upload(f.merchant); assert.equal(duplicate.ok,false);
    // Retirement hides the public projection while retaining the object evidence.
    await rpc('merchant_change_listing_images_v1',f.merchant,{p_listing_id:f.listing,p_action:'retire',p_image_id:intent.id});
    assert.equal((await rpc('catalog_listing_media_read_v1',freshCustomer,{p_listing_ids:[f.listing]}))[0].images.length,0);
  });
  if(ledger) {
    checks.push(...await trustCampaignChecks(db,config,f));
    // D's account-erasure acceptance consumes its synthetic customer.
    f.customer=await actor();
    checks.push(...await ledgerChecks(db,config,f));
  }
  else if(trustCampaigns){
    checks.push(...await trustCampaignChecks(db,config,f));
    f.customer=await actor();
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  }else if(reviews){
    checks.push(...await reviewChecks(db,config,f));
    // C's deletion proof consumed its synthetic customer. New HTTP journey actor.
    f.customer=await actor();
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  }else checks.push(...await databaseChecks(db,config,f));
  const fresh=await session(f.merchant.id), freshCustomer=await session(f.customer.id);
  async function httpQr(quantity) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[f.customer.id]);
    const cart=randomUUID();
    assert.equal((await request('/rest/v1/carts',freshCustomer,{id:cart,user_id:f.customer.id,shop_id:f.shop})).ok,true);
    assert.equal((await request('/rest/v1/cart_items_v2',freshCustomer,{cart_id:cart,shop_product_id:f.listing,quantity})).ok,true);
    return rpc('create_qr_session_v2',freshCustomer,{p_cart_id:cart});
  }
  const httpClaim=q=>rpc('claim_existing_qr_v2',fresh,{p_shop_id:f.shop,p_installation_id:fresh.installation,
    p_request_id:randomUUID(),p_manual_code:q.manual_code});
  const claimArgs=c=>({p_claim_id:c.claim_id,p_installation_id:fresh.installation});
  await check('HTTP manual claim, idempotent completion/return and fresh Customer purchase evidence',async()=>{
    const q=await httpQr(2), c=await httpClaim(q); assert.equal(c.status,'claimed');
    const completed=await rpc('complete_existing_qr_v2',fresh,claimArgs(c)); assert.equal(completed.status,'used');
    assert.equal((await rpc('complete_existing_qr_v2',fresh,claimArgs(c))).purchase_id,completed.purchase_id);
    const purchase=await rpc('read_purchase_evidence_v2',freshCustomer,{p_purchase_id:completed.purchase_id});
    assert.equal(purchase.final_sale_minor,2400); assert.equal(purchase.items[0].quantity,2);
    const args={p_purchase_id:purchase.id,p_request_id:randomUUID(),p_installation_id:fresh.installation,
      p_items:[{purchase_item_id:purchase.items[0].id,quantity:1}],p_reason:'Local HTTP return'};
    await rpc('record_purchase_return_v2',fresh,args); await rpc('record_purchase_return_v2',fresh,args);
    const updated=await rpc('read_purchase_evidence_v2',freshCustomer,{p_purchase_id:purchase.id});
    assert.equal(updated.returns.length,1); assert.equal(updated.items[0].returned_quantity,1);
    assert.equal(updated.items[0].quantity,2); assert.equal(updated.final_sale_minor,2400);
  });
  await check('real Auth logout removes server session and prevents claimed QR finalization/reconciliation',async()=>{
    const q=await httpQr(1), c=await httpClaim(q); assert.equal(c.status,'claimed');
    assert.equal((await request('/auth/v1/logout?scope=local',fresh,undefined)).ok,true);
    assert.equal((await db.query('SELECT count(*)::int n FROM auth.sessions WHERE id=$1',[fresh.claims.session_id])).rows[0].n,0);
    // Capability metadata intentionally needs only auth.uid(); the live-session
    // boundary is on transaction operations, not this informational read.
    for(const name of ['complete_existing_qr_v2','reconcile_claim_v2']) {
      const denied=await request(`/rest/v1/rpc/${name}`,fresh,claimArgs(c));
      assert.equal(denied.ok,false); assert.equal(denied.data.code,'28000');
    }
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id])).rows[0].n,0);
  });
  if(reviews) checks.push(...await reviewHttpChecks({db,request,rpc,actor,session,f}));
  if(trustCampaigns) checks.push(...await trustCampaignHttpChecks({db,request,rpc,actor,session,f,status,localRequest}));
  if(ledger) checks.push(...await ledgerHttpChecks({db,request,rpc,session,f}));
  const evidence={result:'PASS',captured_at:new Date().toISOString(),evidence_class:'real-local-supabase-auth-postgrest-storage-postgresql',
    runtime:(await db.query('SELECT version() version')).rows[0].version,services,physical_two_device:'OPEN',checks,migrations:manifest};
  await writeFile(resolve(run.dir,'result.json'),JSON.stringify(evidence,null,2)+'\n');
  await writeFile(resolve(root,`docs/data/merchant_${ledger?'h0':trustCampaigns?'df':reviews?'c':'ab'}_managed_acceptance.json`),JSON.stringify(evidence,null,2)+'\n');
  console.log(`LOCAL_MANAGED_ACCEPTANCE_PASS: ${checks.length} groups; physical-device gate remains OPEN.`);
} catch(error) {
  console.error(`LOCAL_MANAGED_ACCEPTANCE_${environmentReady?'FAILED':'BLOCKED'}: ${error.code || error.name}; no remote fallback.`);
  if(run) await writeFile(resolve(run.dir,'failure.txt'),`${error.stack}\n`,{mode:0o600});
  process.exitCode=environmentReady?1:2;
} finally { if(db) await db.end(); }
