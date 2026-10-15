import assert from 'node:assert/strict';
import { randomUUID, createHash } from 'node:crypto';
import { connect, rpc, sqlAs } from './fixture.mjs';

const delay = ms => new Promise(r => setTimeout(r, ms));
async function blocked(db, pid) {
  for (let i = 0; i < 80; i++) {
    if ((await db.query('SELECT cardinality(pg_blocking_pids($1))>0 blocked', [pid])).rows[0].blocked) return;
    await delay(25);
  }
  assert.fail('Second independent connection did not contend on a real PostgreSQL lock');
}

export async function contended(db, first, second) {
  const held = Promise.withResolvers(), release = Promise.withResolvers(), started = Promise.withResolvers();
  let secondPid;
  const one = first({ hold: async () => { held.resolve(); await release.promise; } });
  one.catch(held.reject);
  let two, failure;
  try {
    await held.promise;
    two = second({ before: async client => {
      secondPid = (await client.query('SELECT pg_backend_pid() pid')).rows[0].pid; started.resolve();
    } });
    two.catch(started.reject);
    await started.promise; await blocked(db, secondPid);
  } catch(error) { failure=error; } finally { release.resolve(); }
  const results=await Promise.allSettled([one, two]);
  if(failure) throw failure;
  return results;
}

export async function databaseChecks(db, config, f) {
  const checks = [];
  const check = async (name, fn) => { await fn(); checks.push({ name, result: 'PASS' }); console.log(`PASS ${name}`); };
  const call = (actor, name, params, options) => rpc(config, actor, name, params, options);
  const merchant = f.merchant, device = merchant.installation;
  const clearQuota = () => db.query('DELETE FROM public.qr_attempt_limits WHERE scope=$1 OR scope LIKE $2',
    [`shop:${f.shop}`, 'session:%']); // The guarded, fresh fixture contains synthetic users only.
  const claim = (q, options, actor = merchant, manual = false) => call(actor, 'claim_existing_qr_v2',
    [f.shop, actor.installation, randomUUID(), manual ? null : q.session_token, manual ? q.manual_code : null], options);
  const complete = (c, options, actor = merchant) => call(actor, 'complete_existing_qr_v2', [c.claim_id, actor.installation], options);
  const listing = f.listing ?? randomUUID();
  if (!f.listing) await sqlAs(config, merchant, 'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12)', [listing,f.shop,f.product]);
  f.listing = listing;
  async function fresh(qty = 3, legacy = false) {
    await clearQuota();
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'", [f.customer.id]);
    const cart = randomUUID();
    await sqlAs(config, f.customer, 'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)', [cart,f.customer.id,f.shop]);
    await sqlAs(config, f.customer, 'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,$3)', [cart,listing,qty]);
    return call(f.customer, legacy ? 'create_qr_session' : 'create_qr_session_v2', [cart]);
  }
  await check('real pgcrypto extension membership and standard SHA256/HMAC vectors', async () => {
    const result = (await db.query(`SELECT encode(extensions.digest('abc','sha256'),'hex') digest,
      encode(extensions.hmac('Hi There'::bytea,decode(repeat('0b',20),'hex'),'sha256'),'hex') hmac,
      (SELECT count(*)::int FROM pg_depend d JOIN pg_extension e ON e.oid=d.refobjid
       WHERE e.extname='pgcrypto' AND d.objid=ANY(ARRAY['extensions.hmac(bytea,bytea,text)'::regprocedure::oid,
       'extensions.digest(bytea,text)'::regprocedure::oid,'extensions.gen_random_bytes(integer)'::regprocedure::oid])) members`)).rows[0];
    assert.equal(result.digest, createHash('sha256').update('abc').digest('hex'));
    assert.equal(result.hmac, 'b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7');
    assert.equal(result.members, 3);
  });
  await check('default OFF preserves legacy confirmation and unclassified history', async () => {
    assert.equal((await call(merchant, 'qr_capabilities_v2', [])).enabled, false);
    await assert.rejects(fresh());
    const q = await fresh(1, true);
    assert.equal((await call(merchant, 'confirm_qr_session', [q.session_token])).status, 'used');
  });
  await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  let claimed, purchase;
  await check('simultaneous scan and manual code contend and produce one claim', async () => {
    const q = await fresh();
    const results = await contended(db, options => claim(q, options), options => claim(q, options, merchant, true));
    assert(results.every(r => r.status === 'fulfilled'));
    claimed = results[0].value;
    assert.equal(claimed.status, 'claimed'); assert.equal(results[1].value.claim_id, claimed.claim_id);
    assert.equal(results[1].value.completion_expires_at, claimed.completion_expires_at);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.qr_claims WHERE qr_session_id=$1',[q.id])).rows[0].n, 1);
  });
  await check('double finalization blocks then returns one purchase and one event', async () => {
    const results = await contended(db, options => complete(claimed,options), options => complete(claimed,options));
    assert(results.every(r => r.status === 'fulfilled'));
    assert.equal(results[0].value.status,'used'); assert.equal(results[0].value.purchase_id,results[1].value.purchase_id);
    purchase = await call(f.customer,'read_purchase_evidence_v2',[results[0].value.purchase_id]);
    assert.equal(purchase.final_sale_minor,3600);
    const n = (await db.query("SELECT count(*)::int n FROM public.commerce_events WHERE purchase_id=$1 AND event_kind='purchase_confirmed'",[purchase.id])).rows[0].n;
    assert.equal(n,1);
    assert.equal((await db.query('SELECT octet_length(allocation_hash) n FROM public.purchase_terms WHERE purchase_id=$1',[purchase.id])).rows[0].n,32);
  });
  const returnArgs = (request, qty) => [purchase.id,request,[{purchase_item_id:purchase.items[0].id,quantity:qty}],'Local return',device,null];
  await check('concurrent excessive returns cannot exceed the original quantity', async () => {
    const results = await contended(db,
      options => call(merchant,'record_purchase_return_v2',returnArgs(randomUUID(),2),options),
      options => call(merchant,'record_purchase_return_v2',returnArgs(randomUUID(),2),options));
    assert.equal(results[0].status,'fulfilled'); assert.equal(results[1].status,'rejected');
    assert.match(results[1].reason.message,/exceeds/);
    const current = await call(f.customer,'read_purchase_evidence_v2',[purchase.id]);
    assert.equal(current.items[0].returned_quantity,2); assert.equal(current.items[0].quantity,3);
    assert.equal(current.final_sale_minor,3600); assert.equal(current.returns.length,1);
  });
  await check('concurrent identical return retry writes exactly one additional return', async () => {
    const args = returnArgs(randomUUID(),1);
    const results = await contended(db,
      options => call(merchant,'record_purchase_return_v2',args,options),
      options => call(merchant,'record_purchase_return_v2',args,options));
    assert(results.every(r=>r.status==='fulfilled'));
    const current = await call(f.customer,'read_purchase_evidence_v2',[purchase.id]);
    assert.equal(current.items[0].returned_quantity,3); assert.equal(current.returns.length,2);
    await assert.rejects(call(merchant,'record_purchase_return_v2',returnArgs(args[1],2)),/mismatch/);
  });
  await check('independent sessions cannot steal a claim and cap serializes at two', async () => {
    const second = await f.session(merchant.id), third = await f.session(merchant.id);
    const q = await fresh(), c = await claim(q);
    const results = await contended(db, options => claim(q,options,second), options => claim(q,options,third));
    assert.equal(results[0].value.error,'QR_CLAIMED_ELSEWHERE');
    assert.equal(results[1].status,'rejected'); assert.match(results[1].reason.message,/limit/);
    await assert.rejects(complete(c,undefined,second));
    await call(merchant,'cancel_claim_v2',[c.claim_id,device]);
    await db.query('DELETE FROM auth.sessions WHERE id=ANY($1::uuid[])',[[second.claims.session_id,third.claims.session_id]]);
  });
  await check('current owner, active shop and merchant role are rechecked', async () => {
    const q = await fresh(), c = await claim(q);
    await assert.rejects(claim(q,undefined,f.other));
    await db.query('UPDATE public.shops SET owner_user_id=$1 WHERE id=$2',[f.customer.id,f.shop]);
    await assert.rejects(complete(c));
    await db.query('UPDATE public.shops SET owner_user_id=$1 WHERE id=$2',[merchant.id,f.shop]);
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.shop]);
    await assert.rejects(complete(c));
    await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.shop]);
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[merchant.id]);
    await assert.rejects(complete(c));
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[merchant.id]);
    await call(merchant,'cancel_claim_v2',[c.claim_id,device]);
  });
  await check('listing update racing finalization rejects stale quote after waiting', async () => {
    const q=await fresh(), c=await claim(q);
    const results = await contended(db,
      options => sqlAs(config,merchant,'UPDATE public.shop_products SET price=13 WHERE id=$1',[listing],options),
      options => complete(c,options));
    assert.equal(results[0].status,'fulfilled'); assert.equal(results[1].value.status,'cancelled');
    await db.query('UPDATE public.shop_products SET price=12 WHERE id=$1',[listing]);
  });
  await check('customer quantity edit cannot commit through a locked finalization', async () => {
    const q=await fresh(), c=await claim(q);
    const results=await contended(db, options=>complete(c,options), options=>sqlAs(config,f.customer,
      'UPDATE public.cart_items_v2 SET quantity=2 WHERE cart_id=$1',[q.cart_id],options));
    assert.equal(results[0].value.status,'used');
    assert(results[1].status==='rejected' || results[1].value.rowCount===0,'Checked-out cart edit must fail closed');
    assert.equal((await db.query('SELECT quantity FROM public.cart_items_v2 WHERE cart_id=$1',[q.cart_id])).rows[0].quantity,3);
  });
  await check('customer deletion wins first and cancels the waiting finalization', async () => {
    const q=await fresh(), c=await claim(q);
    const results=await contended(db, options=>sqlAs(config,f.customer,
      'DELETE FROM public.cart_items_v2 WHERE cart_id=$1',[q.cart_id],options), options=>complete(c,options));
    assert.equal(results[0].value.rowCount,1); assert.equal(results[1].value.status,'cancelled');
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id])).rows[0].n,0);
  });
  await check('completion deadline is rechecked after a real lock wait', async () => {
    const q=await fresh(), c=await claim(q), locker=await connect(config);
    const started=Promise.withResolvers(); let pending;
    try {
      await locker.query('BEGIN');
      await locker.query('SELECT id FROM public.carts WHERE id=$1 FOR UPDATE',[q.cart_id]);
      await db.query("UPDATE public.qr_claims SET completion_expires_at=clock_timestamp()+interval '400 milliseconds' WHERE id=$1",[c.claim_id]);
      pending=complete(c,{before:async client=>started.resolve((await client.query('SELECT pg_backend_pid() pid')).rows[0].pid)});
      pending.catch(started.reject);
      await blocked(db,await started.promise);
      await delay(500); await locker.query('COMMIT');
      assert.equal((await pending).status,'expired');
      assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id])).rows[0].n,0);
    } finally { await locker.query('ROLLBACK'); await locker.end(); if(pending) await pending.catch(()=>{}); }
  });
  await check('concurrent invalid guesses commit a bounded attempt quota', async () => {
    const second=Number((await db.query('SELECT extract(second FROM clock_timestamp()) AS seconds')).rows[0].seconds);
    if(second>57) await delay((61-second)*1000); // Avoid crossing a real fixed-window boundary in this assertion.
    await clearQuota();
    const results=await Promise.all(Array.from({length:6},()=>call(merchant,'claim_existing_qr_v2',
      [f.shop,device,randomUUID(),null,'999999'])));
    assert.equal(results.filter(r=>r.error==='QR_UNAVAILABLE').length,5);
    assert.equal(results.filter(r=>r.error==='QR_RATE_LIMITED').length,1);
  });
  await check('owned image slots serialize at six; another merchant cannot reserve them', async () => {
    await assert.rejects(call(f.other,'merchant_prepare_listing_image_v1',[listing,'image/png',68]));
    for(let i=0;i<5;i++) await call(merchant,'merchant_prepare_listing_image_v1',[listing,'image/png',68]);
    const results=await contended(db,
      options=>call(merchant,'merchant_prepare_listing_image_v1',[listing,'image/png',68],options),
      options=>call(merchant,'merchant_prepare_listing_image_v1',[listing,'image/png',68],options));
    assert.equal(results[0].status,'fulfilled'); assert.equal(results[1].status,'rejected');
    assert.match(results[1].reason.message,/MEDIA_LIMIT/);
    const media=await call(merchant,'merchant_listing_media_v1',[listing]); assert.equal(media.images.length,6);
    for(const image of media.images) await call(merchant,'merchant_change_listing_images_v1',[listing,'retire',image.id,null]);
  });
  await check('flag OFF drains existing claim without legacy endpoint bypass', async () => {
    const q=await fresh(), c=await claim(q);
    await db.query('UPDATE public.qr_protocol_config SET enabled=false');
    await assert.rejects(call(merchant,'confirm_qr_session',[q.session_token]),/QR_V2_REQUIRED/);
    assert.equal((await complete(c)).status,'used');
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  });
  await check('revoked session fails even with previously valid claim identity', async () => {
    const q=await fresh(), c=await claim(q);
    await call(merchant,'revoke_merchant_device_session_v2',[merchant.claims.session_id]);
    await assert.rejects(complete(c),/revoked/);
    await assert.rejects(call(merchant,'reconcile_claim_v2',[c.claim_id,device]),/revoked/);
  });
  return checks;
}
