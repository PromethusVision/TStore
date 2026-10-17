import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

// Real local HTTP contract evidence. Deliberately discarding a response models
// unknown acknowledgement; it does not claim a physical-device/network test.
export async function commerceRecoveryChecks({ db, request, rpc, session, f }) {
  const checks = [];
  const check = async (name, action) => {
    await action();
    checks.push({ name: 'commerce recovery: ' + name, result: 'PASS' });
    console.log('PASS commerce recovery: ' + name);
  };
  await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  f.listing = randomUUID();
  assert.equal((await request('/rest/v1/shop_products', f.merchant, {
    id: f.listing, shop_id: f.shop, product_id: f.product,
    price: 12, is_available: true, is_active: true,
  })).ok, true);
  async function qr(quantity = 2) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'", [f.customer.id]);
    const cart = randomUUID();
    assert.equal((await request('/rest/v1/carts', f.customer,
      { id: cart, user_id: f.customer.id, shop_id: f.shop })).ok, true);
    assert.equal((await request('/rest/v1/cart_items_v2', f.customer,
      { cart_id: cart, shop_product_id: f.listing, quantity })).ok, true);
    return rpc('create_qr_session_v2', f.customer, { p_cart_id: cart });
  }
  const args = claim => ({ p_claim_id: claim.claim_id, p_installation_id: f.merchant.installation });
  async function claim(q, requestId = randomUUID()) {
    return rpc('claim_existing_qr_v2', f.merchant, {
      p_shop_id: f.shop, p_installation_id: f.merchant.installation,
      p_request_id: requestId, p_manual_code: q.manual_code,
    });
  }
  const returnArgs = (p, quantity, id = randomUUID(), actor = f.merchant) => ({
    p_purchase_id: p.id, p_request_id: id, p_installation_id: actor.installation,
    p_items: [{ purchase_item_id: p.items[0].id, quantity }],
    p_reason: 'Local commerce recovery',
  });
  let firstQr, firstClaim, purchase, pendingReturn;
  await check('lost claim acknowledgement recovers same identity and fixed deadline', async () => {
    firstQr = await qr();
    const requestId = randomUUID();
    firstClaim = await claim(firstQr, requestId);
    const retry = await claim(firstQr, requestId);
    const recovered = await rpc('recover_merchant_claim_v2', f.merchant,
      { p_shop_id: f.shop, p_installation_id: f.merchant.installation });
    assert.equal(recovered.claim_id, firstClaim.claim_id);
    assert.equal(retry.claim_id, firstClaim.claim_id);
    assert.equal(retry.completion_expires_at, firstClaim.completion_expires_at);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.qr_claims WHERE qr_session_id=$1',
      [firstQr.id])).rows[0].n, 1);
  });
  await check('lost completion acknowledgement reconciles one immutable purchase', async () => {
    await rpc('complete_existing_qr_v2', f.merchant, args(firstClaim));
    const recovered = await rpc('reconcile_claim_v2', f.merchant, args(firstClaim));
    const replay = await rpc('complete_existing_qr_v2', f.merchant, args(firstClaim));
    assert.equal(recovered.status, 'used'); assert.equal(replay.purchase_id, recovered.purchase_id);
    for (const key of ['session_id', 'session_token', 'shop_id', 'claim_id',
      'expires_at', 'completion_expires_at', 'total_amount', 'item_count', 'items']) {
      assert.deepEqual(recovered[key], firstClaim[key]);
    }
    purchase = await rpc('read_purchase_evidence_v2', f.merchant, { p_purchase_id: recovered.purchase_id });
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE source_qr_session_id=$1',
      [firstQr.id])).rows[0].n, 1);
  });
  await check('full return retry after zero remaining units preserves one return and original sale', async () => {
    pendingReturn = returnArgs(purchase, 2);
    await rpc('record_purchase_return_v2', f.merchant, pendingReturn);
    const replay = await rpc('record_purchase_return_v2', f.merchant, pendingReturn);
    assert.equal(replay.returns.length, 1); assert.equal(replay.items[0].returned_quantity, 2);
    assert.equal(replay.items[0].quantity, 2); assert.equal(replay.final_sale_minor, 2400);
    assert.equal(replay.returns[0].refund_executed, false);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.purchase_returns WHERE purchase_id=$1',
      [purchase.id])).rows[0].n, 1);
  });
  await check('changed payload cannot reuse a stored request or create partial evidence', async () => {
    const rejected = await request('/rest/v1/rpc/record_purchase_return_v2', f.merchant,
      { ...pendingReturn, p_reason: 'changed retry payload' });
    assert.equal(rejected.ok, false);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.purchase_returns WHERE purchase_id=$1',
      [purchase.id])).rows[0].n, 1);
  });
  await check('same owner fresh Auth session replays exact return but cannot take another session claim', async () => {
    const fresh = await session(f.merchant.id);
    const denied = await request('/rest/v1/rpc/reconcile_claim_v2', fresh,
      { ...args(firstClaim), p_installation_id: fresh.installation });
    assert.equal(denied.ok, false);
    const replay = await rpc('record_purchase_return_v2', fresh,
      { ...pendingReturn, p_installation_id: fresh.installation });
    assert.equal(replay.returns.length, 1);
    // Fresh device grant created by the return is explicitly logged out.
    assert.equal((await request('/auth/v1/logout?scope=local', fresh)).ok, true);
  });
  await check('gate off still permits exact historical return reconciliation', async () => {
    await db.query('UPDATE public.qr_protocol_config SET enabled=false');
    const replay = await rpc('record_purchase_return_v2', f.merchant, pendingReturn);
    assert.equal(replay.returns.length, 1);
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  });
  await check('competing returns cannot exceed immutable purchased quantity', async () => {
    const c = await claim(await qr());
    const completed = await rpc('complete_existing_qr_v2', f.merchant, args(c));
    const p = await rpc('read_purchase_evidence_v2', f.merchant, { p_purchase_id: completed.purchase_id });
    const results = await Promise.all([1, 2].map(() =>
      request('/rest/v1/rpc/record_purchase_return_v2', f.merchant, returnArgs(p, 2))));
    assert.equal(results.filter(r => r.ok).length, 1);
    assert.equal(results.filter(r => !r.ok).length, 1);
    const updated = await rpc('read_purchase_evidence_v2', f.merchant, { p_purchase_id: p.id });
    assert.equal(updated.items[0].returned_quantity, 2); assert.equal(updated.returns.length, 1);
  });
  await check('other merchant cannot read history, read detail or record return', async () => {
    for (const [name, body] of [
      ['list_merchant_purchases_v2', { p_shop_id: f.shop, p_offset: 0, p_limit: 20 }],
      ['read_purchase_evidence_v2', { p_purchase_id: purchase.id }],
      ['record_purchase_return_v2', returnArgs(purchase, 1, randomUUID(), f.other)],
    ]) assert.equal((await request('/rest/v1/rpc/' + name, f.other, body)).ok, false);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.purchase_returns WHERE purchase_id=$1',
      [purchase.id])).rows[0].n, 1);
  });
  await check('purchase list and detail agree after recovery without customer identity leak', async () => {
    const rows = await rpc('list_merchant_purchases_v2', f.merchant,
      { p_shop_id: f.shop, p_offset: 0, p_limit: 20 });
    const row = rows.find(p => p.id === purchase.id);
    assert(row); assert.equal(row.items[0].returned_quantity, 2);
    for (const p of rows) {
      assert.equal(p.shop_id, f.shop);
      for (const key of ['customer_user_id', 'email', 'phone', 'session_token']) assert.equal(key in p, false);
    }
  });
  await check('logged out merchant cannot replay a return despite holding its old token', async () => {
    assert.equal((await request('/auth/v1/logout?scope=local', f.merchant)).ok, true);
    const denied = await request('/rest/v1/rpc/record_purchase_return_v2', f.merchant, pendingReturn);
    assert.equal(denied.ok, false); assert.equal(denied.data.code, '28000');
    assert.equal((await db.query('SELECT count(*)::int n FROM public.purchase_returns WHERE purchase_id=$1',
      [purchase.id])).rows[0].n, 1);
  });
  return checks;
}
