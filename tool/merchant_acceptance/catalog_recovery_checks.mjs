import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

// Contract evidence over real local Auth/PostgREST/Storage. Dart transport fault
// injection is tested separately; these assertions do not simulate a device.
export async function catalogRecoveryChecks({ db, request, rpc, session, f, status, localRequest }) {
  const checks = [];
  const check = async (name, fn) => {
    await fn(); checks.push({ name, result: 'PASS' }); console.log('PASS ' + name);
  };
  const row = async (path, actor = f.merchant) => {
    const result = await request(path, actor, undefined, 'GET');
    assert.equal(result.ok, true); assert.equal(result.data.length, 1);
    return result.data[0];
  };
  const listingPath = '/rest/v1/shop_products?shop_id=eq.' + f.shop +
    '&product_id=eq.' + f.product;
  let original;
  await check('catalog recovery: exact listing read sees committed write after caller discards acknowledgement', async () => {
    original = await row(listingPath);
    const filter = listingPath + '&id=eq.' + f.listing +
      '&updated_at=eq.' + encodeURIComponent(original.updated_at);
    const write = await request(filter, f.merchant,
      { price: 23.45, is_available: false, description: 'Local recovery draft' }, 'PATCH');
    assert.equal(write.ok, true);
    // Caller intentionally ignores the operation receipt and proves current state.
    const fresh = await session(f.merchant.id);
    const stored = await row(listingPath, fresh);
    assert.equal(stored.id, f.listing); assert.equal(stored.price, 23.45);
    assert.equal(stored.is_available, false);
    assert.equal(stored.description, 'Local recovery draft');
  });
  await check('catalog recovery: stale listing revision cannot overwrite fresh values', async () => {
    const rejected = await request(listingPath + '&updated_at=eq.' + encodeURIComponent(original.updated_at),
      f.merchant, { price: 99.99, is_available: true }, 'PATCH');
    assert.equal(rejected.ok, true); // PostgREST may report success with zero rows.
    const stored = await row(listingPath);
    assert.equal(stored.price, 23.45); assert.equal(stored.is_available, false);
    assert.equal((await request(listingPath + '&updated_at=eq.' + encodeURIComponent(stored.updated_at),
      f.merchant, { price: 24.56 }, 'PATCH')).ok, true);
    assert.equal((await row(listingPath)).price, 24.56);
    const duplicate = await request('/rest/v1/shop_products', f.merchant,
      { id: randomUUID(), shop_id: f.shop, product_id: f.product, price: 1 });
    assert.equal(duplicate.ok, false); assert.equal(duplicate.data.code, '23505');
    assert.equal((await row(listingPath)).price, 24.56);
    // Restore this isolated fixture for the adjacent QR journey.
    assert.equal((await request(listingPath, f.merchant,
      { price: original.price, is_available: original.is_available,
        description: original.description }, 'PATCH')).ok, true);
  });
  await check('catalog recovery: shop revision and exact owner survive fresh session read', async () => {
    const path = '/rest/v1/shops?id=eq.' + f.shop + '&owner_user_id=eq.' + f.merchant.id;
    const before = await row(path);
    const snapshot = path + '&updated_at=eq.' + encodeURIComponent(before.updated_at);
    assert.equal((await request(snapshot, f.merchant, { name: 'Local recovered shop' }, 'PATCH')).ok, true);
    assert.equal((await request(snapshot, f.merchant, { name: 'Stale overwrite' }, 'PATCH')).ok, true);
    const fresh = await session(f.merchant.id);
    assert.equal((await row(path, fresh)).name, 'Local recovered shop');
    await request(path, f.other, { name: 'Foreign overwrite' }, 'PATCH');
    assert.equal((await row(path)).name, 'Local recovered shop');
    const duplicate = await request('/rest/v1/shops', fresh,
      { id: randomUUID(), owner_user_id: fresh.id, name: 'Duplicate onboarding' });
    assert.equal(duplicate.ok, false);
    assert.equal((await request(path, fresh, { name: before.name }, 'PATCH')).ok, true);
  });
  const bytes = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=', 'base64');
  let intent;
  await check('catalog recovery: acknowledged intent remains pending after interrupted upload', async () => {
    intent = await rpc('merchant_prepare_listing_image_v1', f.merchant,
      { p_listing_id: f.listing, p_mime: 'image/png', p_bytes: bytes.length });
    const own = await rpc('merchant_listing_media_v1', f.merchant, { p_listing_id: f.listing });
    assert.equal(own.images.find(i => i.id === intent.id).publication_state, 'pending');
    const unfinished = await request('/rest/v1/rpc/merchant_change_listing_images_v1', f.merchant,
      { p_listing_id: f.listing, p_action: 'publish', p_image_id: intent.id });
    assert.equal(unfinished.ok, false);
    const foreign = await request('/rest/v1/rpc/merchant_listing_media_v1', f.other, { p_listing_id: f.listing });
    assert.equal(foreign.ok, false);
  });
  await check('catalog recovery: existing uploaded object publishes once and repeated publication preserves image', async () => {
    const uploaded = await localRequest(status.API_URL,
      '/storage/v1/object/' + intent.bucket_id + '/' + intent.object_path, {
        method: 'POST', headers: { apikey: status.ANON_KEY,
          Authorization: 'Bearer ' + f.merchant.token, 'Content-Type': 'image/png',
          'x-upsert': 'false' }, body: bytes });
    assert.equal(uploaded.ok, true);
    const args = { p_listing_id: f.listing, p_action: 'publish', p_image_id: intent.id };
    await rpc('merchant_change_listing_images_v1', f.merchant, args);
    const fresh = await session(f.merchant.id);
    const stored = await rpc('merchant_listing_media_v1', fresh, { p_listing_id: f.listing });
    assert.equal(stored.images.filter(i => i.id === intent.id).length, 1);
    assert.equal(stored.images.find(i => i.id === intent.id).publication_state, 'published');
    await rpc('merchant_change_listing_images_v1', fresh, args);
    const customer = await rpc('catalog_listing_media_read_v1', f.customer, { p_listing_ids: [f.listing] });
    assert.equal(customer[0].images.filter(i => i.id === intent.id).length, 1);
  });
  await check('catalog recovery: explicit owner retirement hides public image and retains storage object', async () => {
    await rpc('merchant_change_listing_images_v1', f.merchant,
      { p_listing_id: f.listing, p_action: 'retire', p_image_id: intent.id });
    const customer = await rpc('catalog_listing_media_read_v1', f.customer, { p_listing_ids: [f.listing] });
    assert.equal(customer[0].images.some(i => i.id === intent.id), false);
    // No delete request is made; owner metadata stays managed, with no legacy fallback.
    const own = await rpc('merchant_listing_media_v1', f.merchant, { p_listing_id: f.listing });
    assert.equal(own.images.some(i => i.id === intent.id), false);
    assert.equal((await db.query('SELECT count(*)::int n FROM storage.objects WHERE bucket_id=$1 AND name=$2',
      [intent.bucket_id, intent.object_path])).rows[0].n, 1);
  });
  await check('catalog recovery: same request replays one submission and rejects changed payload', async () => {
    const args = { p_shop_id: f.shop, p_request_id: randomUUID(),
      p_draft: { name: 'Local recovery candidate', canonical_category_id: f.category,
        product_type: 'shared_catalog_product', brand: '', model: '', variant: '', gtin: null } };
    const first = await rpc('merchant_submit_product_v1', f.merchant, args);
    assert(first.submission?.id);
    const fresh = await session(f.merchant.id);
    const second = await rpc('merchant_submit_product_v1', fresh, args);
    assert.equal(second.submission.id, first.submission.id);
    const changed = await request('/rest/v1/rpc/merchant_submit_product_v1', fresh,
      { ...args, p_draft: { ...args.p_draft, name: 'Changed retry' } });
    assert.equal(changed.ok, false);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.product_submissions WHERE shop_id=$1 AND request_id=$2',
      [f.shop, args.p_request_id])).rows[0].n, 1);
  });
  return checks;
}
