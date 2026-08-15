import { readdir, readFile } from 'node:fs/promises';
import { join } from 'node:path';

import { PGlite } from '@electric-sql/pglite';

const database = new PGlite();

await database.exec(`
  CREATE ROLE anon NOLOGIN;
  CREATE ROLE authenticated NOLOGIN;

  CREATE SCHEMA auth;
  CREATE SCHEMA extensions;
  CREATE SCHEMA storage;

  CREATE TABLE auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT,
    raw_user_meta_data JSONB NOT NULL DEFAULT '{}'::JSONB
  );

  CREATE FUNCTION auth.uid()
  RETURNS UUID
  LANGUAGE sql
  STABLE
  AS $$
    SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::UUID
  $$;

  CREATE FUNCTION auth.role()
  RETURNS TEXT
  LANGUAGE sql
  STABLE
  AS $$
    SELECT NULLIF(current_setting('request.jwt.claim.role', true), '')
  $$;

  -- PGlite does not bundle pgcrypto. Supabase does. This deterministic stub
  -- exercises the canonical function bodies without weakening production SQL.
  CREATE FUNCTION extensions.gen_random_bytes(byte_count INTEGER)
  RETURNS BYTEA
  LANGUAGE sql
  VOLATILE
  AS $$
    SELECT decode(
      substring(
        replace(gen_random_uuid()::TEXT, '-', '') ||
        replace(gen_random_uuid()::TEXT, '-', '')
        FROM 1 FOR byte_count * 2
      ),
      'hex'
    )
  $$;

  CREATE TABLE storage.buckets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    public BOOLEAN NOT NULL DEFAULT false,
    file_size_limit BIGINT,
    allowed_mime_types TEXT[]
  );

  CREATE TABLE storage.objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket_id TEXT NOT NULL REFERENCES storage.buckets(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
  );
  ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

  CREATE PUBLICATION supabase_realtime;
`);

const migrationDirectory = 'supabase/migrations';
const migrationFiles = (await readdir(migrationDirectory))
  .filter((name) => name.endsWith('.sql'))
  .sort();
let legacyFixture;

for (const migrationFile of migrationFiles) {
  if (migrationFile.includes('_0009_')) {
    const { rows: legacyUsers } = await database.query(`
      INSERT INTO auth.users (email, raw_user_meta_data)
      VALUES (
        'w6-local-legacy@example.invalid',
        '{"full_name":"w6_local_legacy"}'::JSONB
      )
      RETURNING id
    `);
    const { rows: legacyProducts } = await database.query(`
      INSERT INTO public.products (name, price, stock)
      VALUES ('w6_local_legacy_product', 5, 1)
      RETURNING id
    `);
    const { rows: legacyReviews } = await database.query(
      `
        INSERT INTO public.reviews (
          user_id,
          product_id,
          rating,
          is_verified_purchase
        ) VALUES ($1, $2, 5, true)
        RETURNING id, updated_at
      `,
      [legacyUsers[0].id, legacyProducts[0].id],
    );
    legacyFixture = {
      productId: legacyProducts[0].id,
      reviewId: legacyReviews[0].id,
      updatedAt: legacyReviews[0].updated_at,
    };
  }

  let sql = await readFile(join(migrationDirectory, migrationFile), 'utf8');
  sql = sql.replace(
    'CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;',
    '-- pgcrypto is supplied by the Supabase platform and stubbed above.',
  );
  try {
    await database.exec(sql);
  } catch (error) {
    throw new Error(`Migration failed: ${migrationFile}`, { cause: error });
  }
}

const { rows: publicTableRows } = await database.query(`
  SELECT COUNT(*)::INTEGER AS count
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
`);
const publicTableCount = publicTableRows[0].count;
const { rows: buckets } = await database.query(`
  SELECT id, public, file_size_limit, allowed_mime_types
  FROM storage.buckets
  ORDER BY id
`);
const { rows: rpcNames } = await database.query(`
  SELECT routine_name
  FROM information_schema.routines
  WHERE routine_schema = 'public'
    AND routine_name IN (
      'get_product_reviews',
      'get_product_review_eligibility',
      'submit_product_review',
      'update_product_review',
      'delete_product_review'
    )
  ORDER BY routine_name
`);

if (publicTableCount !== 23) {
  throw new Error(`Expected 23 public tables, received ${publicTableCount}`);
}
if (buckets.length !== 3) {
  throw new Error(`Expected 3 active media buckets, received ${buckets.length}`);
}
if (rpcNames.length !== 5) {
  throw new Error(`Expected 5 review RPCs, received ${rpcNames.length}`);
}

const one = async (sql, parameters = []) => {
  const { rows } = await database.query(sql, parameters);
  if (rows.length !== 1) {
    throw new Error(`Expected one row, received ${rows.length}`);
  }
  return rows[0];
};

const expectDatabaseError = async (operation, expectedCode, expectedTag) => {
  try {
    await operation();
  } catch (error) {
    if (error.code !== expectedCode || !error.message.includes(expectedTag)) {
      throw error;
    }
    return;
  }
  throw new Error(`Expected ${expectedCode}/${expectedTag}`);
};

const legacyReview = await one(
  `
    SELECT is_verified_purchase, verified_transaction_item_id, updated_at
    FROM public.reviews
    WHERE id = $1
  `,
  [legacyFixture.reviewId],
);
const legacyAggregate = await one(
  `SELECT rating, reviews_count FROM public.products WHERE id = $1`,
  [legacyFixture.productId],
);
if (
  legacyReview.is_verified_purchase ||
  legacyReview.verified_transaction_item_id !== null ||
  legacyReview.updated_at.getTime() !== legacyFixture.updatedAt.getTime() ||
  Number(legacyAggregate.rating) !== 0 ||
  legacyAggregate.reviews_count !== 0
) {
  throw new Error('Legacy review preservation or aggregate isolation failed');
}

const customer = await one(`
  INSERT INTO auth.users (email, raw_user_meta_data)
  VALUES (
    'w6-local-customer@example.invalid',
    '{"full_name":"w6_local_customer"}'::JSONB
  )
  RETURNING id
`);
const otherCustomer = await one(`
  INSERT INTO auth.users (email, raw_user_meta_data)
  VALUES (
    'w6-local-other@example.invalid',
    '{"full_name":"w6_local_other"}'::JSONB
  )
  RETURNING id
`);
const merchant = await one(`
  INSERT INTO auth.users (email, raw_user_meta_data)
  VALUES (
    'w6-local-merchant@example.invalid',
    '{"full_name":"w6_local_merchant"}'::JSONB
  )
  RETURNING id
`);

await database.query(
  `UPDATE public.profiles SET role = 'merchant' WHERE id = $1`,
  [merchant.id],
);

const productOne = await one(`
  INSERT INTO public.products (name, price, stock)
  VALUES ('w6_local_product_one', 10, 1)
  RETURNING id
`);
const productTwo = await one(`
  INSERT INTO public.products (name, price, stock)
  VALUES ('w6_local_product_two', 20, 1)
  RETURNING id
`);
const shop = await one(
  `
    INSERT INTO public.shops (owner_user_id, name)
    VALUES ($1, 'w6_local_shop')
    RETURNING id
  `,
  [merchant.id],
);
const listing = await one(
  `
    INSERT INTO public.shop_products (shop_id, product_id, price)
    VALUES ($1, $2, 10)
    RETURNING id
  `,
  [shop.id, productOne.id],
);
const cart = await one(
  `
    INSERT INTO public.carts (user_id, shop_id)
    VALUES ($1, $2)
    RETURNING id
  `,
  [customer.id, shop.id],
);
await database.query(
  `
    INSERT INTO public.cart_items_v2 (cart_id, shop_product_id, quantity)
    VALUES ($1, $2, 3)
  `,
  [cart.id, listing.id],
);

const setPrincipal = async (userId) => {
  await database.query(
    `SELECT set_config('request.jwt.claim.sub', $1, false)`,
    [userId],
  );
  await database.query(
    `SELECT set_config('request.jwt.claim.role', 'authenticated', false)`,
  );
};

await setPrincipal(customer.id);
const qrSession = await one(
  `
    SELECT to_jsonb(qr) AS value
    FROM public.create_qr_session($1::UUID) AS qr
  `,
  [cart.id],
);
const qrSnapshot = await one(
  `
    SELECT product_id, quantity, unit_price
    FROM public.qr_session_items
    WHERE qr_session_id = $1
  `,
  [qrSession.value.id],
);
if (qrSnapshot.product_id !== productOne.id || qrSnapshot.quantity !== 3) {
  throw new Error('QR product snapshot did not use the server catalog UUID');
}

await database.query(
  `UPDATE public.shop_products SET product_id = $1 WHERE id = $2`,
  [productTwo.id, listing.id],
);

await setPrincipal(merchant.id);
await one(
  `SELECT public.confirm_qr_session($1::TEXT) AS value`,
  [qrSession.value.session_token],
);
await expectDatabaseError(
  () =>
    database.query(
      `SELECT public.confirm_qr_session($1::TEXT)`,
      [qrSession.value.session_token],
    ),
  '55000',
  'already been confirmed',
);

const proof = await one(
  `
    SELECT item.id, item.product_id, item.quantity
    FROM public.verified_transaction_items AS item
    JOIN public.verified_transactions AS transaction_row
      ON transaction_row.id = item.verified_transaction_id
    WHERE transaction_row.source_qr_session_id = $1
  `,
  [qrSession.value.id],
);
if (proof.product_id !== productOne.id || proof.quantity !== 3) {
  throw new Error('Verified transaction did not preserve the QR product UUID');
}

await setPrincipal(customer.id);
await expectDatabaseError(
  () =>
    database.query(
      `SELECT public.submit_product_review($1, 5, NULL, 'wrong product')`,
      [productTwo.id],
    ),
  '42501',
  '[REVIEW_NOT_VERIFIED]',
);

const repeatListing = await one(
  `
    INSERT INTO public.shop_products (shop_id, product_id, price)
    VALUES ($1, $2, 11)
    RETURNING id
  `,
  [shop.id, productOne.id],
);
const repeatCart = await one(
  `
    INSERT INTO public.carts (user_id, shop_id)
    VALUES ($1, $2)
    RETURNING id
  `,
  [customer.id, shop.id],
);
await database.query(
  `
    INSERT INTO public.cart_items_v2 (cart_id, shop_product_id, quantity)
    VALUES ($1, $2, 1)
  `,
  [repeatCart.id, repeatListing.id],
);
const repeatQr = await one(
  `
    SELECT to_jsonb(qr) AS value
    FROM public.create_qr_session($1::UUID) AS qr
  `,
  [repeatCart.id],
);
await setPrincipal(merchant.id);
await one(
  `SELECT public.confirm_qr_session($1::TEXT) AS value`,
  [repeatQr.value.session_token],
);
const repeatEvidence = await one(
  `
    SELECT COUNT(*)::INTEGER AS count
    FROM public.verified_transaction_items AS item
    JOIN public.verified_transactions AS transaction_row
      ON transaction_row.id = item.verified_transaction_id
    WHERE transaction_row.customer_user_id = $1
      AND item.product_id = $2
  `,
  [customer.id, productOne.id],
);
if (repeatEvidence.count !== 2) {
  throw new Error('Repeat purchase evidence was not independently preserved');
}

await setPrincipal(otherCustomer.id);
await expectDatabaseError(
  () =>
    database.query(
      `SELECT public.submit_product_review($1, 5, NULL, 'not eligible')`,
      [productOne.id],
    ),
  '42501',
  '[REVIEW_NOT_VERIFIED]',
);

await setPrincipal(customer.id);
const eligibility = await one(
  `SELECT public.get_product_review_eligibility($1) AS value`,
  [productOne.id],
);
if (!eligibility.value.eligible || !eligibility.value.can_submit) {
  throw new Error('Verified customer was not review eligible');
}

const createdReview = await one(
  `SELECT public.submit_product_review($1, 5, 'first', 'verified') AS value`,
  [productOne.id],
);
if (!createdReview.value.created) {
  throw new Error('First verified review was not created');
}
const reviewId = createdReview.value.review.id;

const duplicateReview = await one(
  `SELECT public.submit_product_review($1, 1, 'duplicate', 'ignored') AS value`,
  [productOne.id],
);
if (duplicateReview.value.created || duplicateReview.value.review.rating !== 5) {
  throw new Error('Duplicate review submit was not idempotent');
}

await setPrincipal(otherCustomer.id);
await expectDatabaseError(
  () =>
    database.query(
      `SELECT public.update_product_review($1, 1, NULL, NULL)`,
      [reviewId],
    ),
  'P0002',
  '[REVIEW_NOT_FOUND]',
);
const crossDelete = await one(
  `SELECT public.delete_product_review($1) AS value`,
  [reviewId],
);
if (crossDelete.value.deleted) {
  throw new Error('Cross-customer review deletion succeeded');
}

await setPrincipal(customer.id);
const updatedReview = await one(
  `SELECT public.update_product_review($1, 4, 'edited', 'updated') AS value`,
  [reviewId],
);
if (updatedReview.value.rating !== 4) {
  throw new Error('Own review update did not persist');
}
await expectDatabaseError(
  () =>
    database.query(
      `
        UPDATE public.reviews
        SET verified_transaction_item_id = NULL
        WHERE id = $1
      `,
      [reviewId],
    ),
  '42501',
  '[REVIEW_EVIDENCE_IMMUTABLE]',
);

const deletedReview = await one(
  `SELECT public.delete_product_review($1) AS value`,
  [reviewId],
);
if (!deletedReview.value.deleted) {
  throw new Error('Own review deletion failed');
}
const recreatedReview = await one(
  `SELECT public.submit_product_review($1, 3, NULL, 'recreated') AS value`,
  [productOne.id],
);
if (!recreatedReview.value.created) {
  throw new Error('Review recreation after delete failed');
}

const aggregate = await one(
  `SELECT rating, reviews_count FROM public.products WHERE id = $1`,
  [productOne.id],
);
if (Number(aggregate.rating) !== 3 || aggregate.reviews_count !== 1) {
  throw new Error('Verified-only product aggregate is inconsistent');
}

await database.query(`DELETE FROM public.carts WHERE id = $1`, [cart.id]);
await database.query(`DELETE FROM public.carts WHERE id = $1`, [repeatCart.id]);
await database.query(`DELETE FROM public.shop_products WHERE id = $1`, [listing.id]);
await database.query(`DELETE FROM public.shop_products WHERE id = $1`, [repeatListing.id]);
const durableProof = await one(
  `SELECT product_id FROM public.verified_transaction_items WHERE id = $1`,
  [proof.id],
);
if (durableProof.product_id !== productOne.id) {
  throw new Error('Catalog deletion changed durable product evidence');
}

await expectDatabaseError(
  () =>
    database.query(
      `
        INSERT INTO public.reviews (user_id, product_id, rating)
        VALUES ($1, $2, 5)
      `,
      [otherCustomer.id, productTwo.id],
    ),
  '42501',
  '[REVIEW_NOT_VERIFIED]',
);

const validStoragePath =
  `catalog/${productOne.id}/v20260815010101/w6-local.webp`;
const storedObject = await one(
  `
    INSERT INTO storage.objects (bucket_id, name)
    VALUES ('product-images', $1)
    RETURNING id
  `,
  [validStoragePath],
);
await expectDatabaseError(
  () =>
    database.query(`DELETE FROM storage.objects WHERE id = $1`, [storedObject.id]),
  '55000',
  '[STORAGE_RETENTION_WINDOW]',
);
await expectDatabaseError(
  () =>
    database.query(`
      INSERT INTO storage.objects (bucket_id, name)
      VALUES ('category-images', 'wrong/path.svg')
    `),
  '23514',
  '[STORAGE_INVALID_PATH]',
);

const reviewPrivileges = await one(`
  SELECT
    has_table_privilege('authenticated', 'public.reviews', 'INSERT')
      AS can_insert,
    has_table_privilege('authenticated', 'public.reviews', 'UPDATE')
      AS can_update,
    has_table_privilege('authenticated', 'public.reviews', 'DELETE')
      AS can_delete
`);
if (
  reviewPrivileges.can_insert ||
  reviewPrivileges.can_update ||
  reviewPrivileges.can_delete
) {
  throw new Error('Authenticated direct review mutation privilege remains');
}

const { rows: storagePolicies } = await database.query(`
  SELECT policyname
  FROM pg_catalog.pg_policies
  WHERE schemaname = 'storage'
    AND tablename = 'objects'
`);
if (storagePolicies.length !== 0) {
  throw new Error('Client storage.objects policy was unexpectedly created');
}

console.log(
  JSON.stringify({
    migrations: migrationFiles.length,
    publicTables: publicTableCount,
    buckets: buckets.map((bucket) => bucket.id),
    reviewRpcs: rpcNames.map((row) => row.routine_name),
    durableProductSnapshot: true,
    reviewLifecycle: true,
    storageGuards: true,
    legacyReviewIsolation: true,
  }),
);

await database.close();
