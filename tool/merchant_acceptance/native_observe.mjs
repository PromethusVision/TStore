// Independent loopback DB/Customer observations, never a remote SQL executor.
import assert from 'node:assert/strict';
import {readFile, writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {readRun, root} from './local.mjs';
import {nativeDatabase} from './native_fixture.mjs';
import {requestJson, localRequest} from './safety.mjs';
import {assertSyntheticLogin} from './native_contract.mjs';
import {schemaExpression, digest} from './pilot_preparation_contract.mjs';
import {installedSchemaMd5} from './pilot_installed_profile.mjs';
let run, db;
try {
  assert.equal(process.argv.length, 4);
  const name = process.argv[3];
  assert.match(name, /^[a-z][a-z0-9-]{0,70}$/);
  run = await readRun(process.argv[2]);
  const fixture = JSON.parse(await readFile(resolve(run.dir, 'native/fixture.json'), 'utf8'));
  assert.equal(fixture.kind, 'merchant-native-local-v1');
  assert.equal(fixture.project, run.project);
  assertSyntheticLogin(fixture.customer);
  const connected = await nativeDatabase(run);
  db = connected.db;
  const {status} = connected;
  const scalar = async sql => (await db.query(sql)).rows[0].value;
  assert.equal(digest(await scalar(`SELECT (${schemaExpression})::text value`), 'md5'), installedSchemaMd5);
  const shops = (await db.query('SELECT id,name,is_active FROM public.shops WHERE owner_user_id=$1', [fixture.merchant.id])).rows;
  assert.equal(shops.length, 1);
  const listings = (await db.query('SELECT id,price,is_active,is_available FROM public.shop_products WHERE shop_id=$1 AND product_id=$2', [shops[0].id, fixture.product])).rows;
  assert(listings.length <= 1);
  const signed = await requestJson(status.API_URL, '/auth/v1/token?grant_type=password', null, status.ANON_KEY,
    {email: fixture.customer.email, password: fixture.customer.password});
  assert.equal(signed.status, 200);
  const offers = await requestJson(status.API_URL,
    `/rest/v1/shop_products?select=price,is_active,is_available,images&product_id=eq.${fixture.product}&is_active=eq.true&is_available=eq.true`,
    signed.data.access_token, status.ANON_KEY, undefined, 'GET');
  assert(offers.ok);
  const media = listings.length ? await requestJson(status.API_URL, '/rest/v1/rpc/catalog_listing_media_read_v1',
    signed.data.access_token, status.ANON_KEY, {p_listing_ids: [listings[0].id]}) : {ok: true, data: []};
  assert(media.ok);
  const images = media.data.flatMap(row => row.images ?? []);
  const downloads = [];
  if (images.length) {
    assert(images.every(image => image.bucket_id === 'listing-media'));
    const signedImages = await requestJson(status.API_URL, '/storage/v1/object/sign/listing-media',
      signed.data.access_token, status.ANON_KEY, {expiresIn: 300, paths: images.map(image => image.object_path)});
    assert(signedImages.ok);
    assert.equal(signedImages.data.length, images.length);
    const expected = await readFile(resolve(root, 'assets/logos/esnaftavar-logo.png'));
    for (const image of signedImages.data) {
      assert.equal(typeof image.signedURL, 'string');
      assert(image.signedURL.startsWith('/object/sign/listing-media/'));
      const downloaded = await localRequest(status.API_URL, '/storage/v1' + image.signedURL);
      assert(downloaded.ok);
      assert.deepEqual(downloaded.body, expected, 'Customer must download the exact selected native gallery bytes');
      downloads.push({bytes: downloaded.body.length, sha256: digest(downloaded.body)});
    }
  }
  const publicProduct = await requestJson(status.API_URL, `/rest/v1/products?select=price,attributes&id=eq.${fixture.product}`,
    signed.data.access_token, status.ANON_KEY, undefined, 'GET');
  assert(publicProduct.ok);
  assert.equal(Number(publicProduct.data[0].price), 0);
  assert.equal(publicProduct.data[0].attributes._catalog_price_contract, 'listing_only_v1');
  assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'), false);
  assert.equal(await scalar('SELECT count(*)::int value FROM public.verified_transactions'), 0);
  assert.equal((await db.query('SELECT name FROM public.shops WHERE id=$1', [fixture.foreignShop])).rows[0].name, 'Native fixture shop');
  assert.equal((await db.query('SELECT is_read FROM public.notifications WHERE id=$1', [fixture.foreignNotification])).rows[0].is_read, false);
  const result = {
    captured_at: new Date().toISOString(), installed_schema_md5: installedSchemaMd5,
    merchant_shop_count: shops.length, merchant_shop_name: shops[0].name,
    listing_count: listings.length,
    listings: listings.map(({price, is_active, is_available}) => ({price, is_active, is_available})),
    customer_offers: offers.data.map(({price, is_active, is_available, images}) =>
      ({price, is_active, is_available, legacy_image_count: images?.length ?? 0})),
    customer_media_count: images.length, customer_downloads: downloads,
    central_price_sentinel: 0, central_price_contract: 'listing_only_v1',
    verified_purchases: 0, decisions_enabled: false, foreign_shop_and_notice_unchanged: true,
  };
  await writeFile(resolve(run.dir, 'native', name + '.json'), JSON.stringify(result, null, 2), {flag: 'wx'});
  console.log(JSON.stringify(result));
} catch (error) {
  if (run) await writeFile(resolve(run.dir, 'native-observe-failure.txt'), error.stack + '\n' + (error.diagnostics ?? ''), {mode: 0o600});
  console.error('NATIVE_OBSERVATION_FAILED: no remote fallback.');
  process.exitCode = 1;
} finally { if (db) await db.end(); }
