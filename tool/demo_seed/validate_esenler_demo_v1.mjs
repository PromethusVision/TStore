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

  -- PGlite does not bundle pgcrypto. Supabase does. The local-only stub keeps
  -- canonical function parsing/execution representative without changing SQL.
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

for (const migrationFile of migrationFiles) {
  let sql = await readFile(join(migrationDirectory, migrationFile), 'utf8');
  sql = sql.replace(
    'CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;',
    '-- pgcrypto is supplied by Supabase and stubbed in this local harness.',
  );
  try {
    await database.exec(sql);
  } catch (error) {
    throw new Error(`Migration failed: ${migrationFile}`, { cause: error });
  }
}

if (migrationFiles.length !== 9) {
  throw new Error(`Expected 9 canonical migrations, received ${migrationFiles.length}`);
}

const seedSql = await readFile('supabase/seeds/esenler_demo_v1.sql', 'utf8');
const cleanupSql = await readFile(
  'supabase/seeds/esenler_demo_v1_cleanup.sql',
  'utf8',
);

const one = async (sql) => {
  const { rows } = await database.query(sql);
  if (rows.length !== 1) {
    throw new Error(`Expected one row, received ${rows.length}`);
  }
  return rows[0];
};

const counts = () =>
  one(`
    SELECT
      (SELECT count(*)::INTEGER FROM public.categories) AS categories,
      (SELECT count(*)::INTEGER FROM public.products) AS products,
      (SELECT count(*)::INTEGER FROM public.shops) AS shops,
      (SELECT count(*)::INTEGER FROM public.shop_products) AS shop_products
  `);

const assertCounts = (actual, expected, stage) => {
  for (const [key, value] of Object.entries(expected)) {
    if (actual[key] !== value) {
      throw new Error(`${stage}: expected ${key}=${value}, received ${actual[key]}`);
    }
  }
};

await database.exec(seedSql);
assertCounts(
  await counts(),
  { categories: 4, products: 20, shops: 57, shop_products: 285 },
  'first seed',
);

// The exact same artifact must be a no-op, not a duplicate or overwrite pass.
await database.exec(seedSql);
assertCounts(
  await counts(),
  { categories: 4, products: 20, shops: 57, shop_products: 285 },
  'idempotent second seed',
);

const publicReads = await one(`
  SELECT
    (SELECT count(*)::INTEGER FROM public.categories WHERE is_active) AS categories,
    (SELECT count(*)::INTEGER FROM public.products WHERE is_active) AS products,
    (
      SELECT count(*)::INTEGER FROM public.products
      WHERE is_active AND is_featured
    ) AS featured_products,
    (SELECT count(*)::INTEGER FROM public.shops WHERE is_active) AS shops,
    (
      SELECT count(*)::INTEGER
      FROM public.shop_products listing
      JOIN public.shops shop ON shop.id = listing.shop_id
      JOIN public.products product ON product.id = listing.product_id
      WHERE listing.is_active
        AND listing.is_available
        AND shop.is_active
        AND product.is_active
    ) AS listings
`);
assertCounts(
  publicReads,
  {
    categories: 4,
    products: 20,
    featured_products: 20,
    shops: 57,
    listings: 285,
  },
  'representative public reads',
);

const sellerComparison = await one(`
  WITH seller_counts AS (
    SELECT product_id, count(*)::INTEGER AS seller_count,
           count(DISTINCT price)::INTEGER AS price_count
    FROM public.shop_products
    WHERE is_active AND is_available
    GROUP BY product_id
  )
  SELECT
    count(*)::INTEGER AS products,
    min(seller_count)::INTEGER AS minimum_sellers,
    max(seller_count)::INTEGER AS maximum_sellers,
    bool_and(price_count > 1) AS all_products_have_price_variation
  FROM seller_counts
`);
if (
  sellerComparison.products !== 20 ||
  sellerComparison.minimum_sellers !== 14 ||
  sellerComparison.maximum_sellers !== 15 ||
  !sellerComparison.all_products_have_price_variation
) {
  throw new Error(`Seller comparison contract failed: ${JSON.stringify(sellerComparison)}`);
}

const locationInputs = await one(`
  SELECT
    count(*)::INTEGER AS shops,
    count(DISTINCT (latitude, longitude))::INTEGER AS coordinates,
    bool_and(latitude BETWEEN -90 AND 90) AS latitude_valid,
    bool_and(longitude BETWEEN -180 AND 180) AS longitude_valid
  FROM public.shops
`);
if (
  locationInputs.shops !== 57 ||
  locationInputs.coordinates !== 57 ||
  !locationInputs.latitude_valid ||
  !locationInputs.longitude_valid
) {
  throw new Error(`Location input contract failed: ${JSON.stringify(locationInputs)}`);
}

const trustRows = await one(`
  SELECT
    (SELECT count(*)::INTEGER FROM auth.users) AS auth_users,
    (SELECT count(*)::INTEGER FROM public.orders) AS orders,
    (SELECT count(*)::INTEGER FROM public.reviews) AS reviews,
    (SELECT count(*)::INTEGER FROM public.shop_ratings) AS shop_ratings,
    (SELECT count(*)::INTEGER FROM public.qr_sessions) AS qr_sessions,
    (SELECT count(*)::INTEGER FROM public.verified_transactions)
      AS verified_transactions,
    (SELECT count(*)::INTEGER FROM public.chat_messages) AS chat_messages,
    (SELECT count(*)::INTEGER FROM public.notifications) AS notifications
`);
assertCounts(
  trustRows,
  {
    auth_users: 0,
    orders: 0,
    reviews: 0,
    shop_ratings: 0,
    qr_sessions: 0,
    verified_transactions: 0,
    chat_messages: 0,
    notifications: 0,
  },
  'trust rows',
);

await database.exec(cleanupSql);
assertCounts(
  await counts(),
  { categories: 0, products: 0, shops: 0, shop_products: 0 },
  'cleanup',
);

const schema = await one(`
  SELECT count(*)::INTEGER AS public_tables
  FROM information_schema.tables
  WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
`);
if (schema.public_tables !== 23) {
  throw new Error(`Canonical schema changed after cleanup: ${schema.public_tables}`);
}

console.log(
  JSON.stringify({
    migrations: migrationFiles.length,
    firstSeed: { categories: 4, products: 20, shops: 57, shopProducts: 285 },
    idempotentSecondSeed: true,
    representativePublicReads: publicReads,
    sellerComparison,
    locationInputs,
    trustRows,
    cleanup: { categories: 0, products: 0, shops: 0, shopProducts: 0 },
    canonicalPublicTablesAfterCleanup: schema.public_tables,
  }),
);

await database.close();
