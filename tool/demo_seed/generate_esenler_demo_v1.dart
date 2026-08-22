import 'dart:convert';
import 'dart:io';

const seedName = 'esenler_demo_v1';
const namespaceUuid = '7a4f4b88-9d89-4a34-a226-5bc9807c7392';
const deterministicTimestamp = '2026-08-22T00:00:00Z';
const demoDescription =
    'Bu işletme EsnaftaVar test/demonstrasyon verisidir. Gerçek işletme değildir.';
const listingDescription =
    'EsnaftaVar esenler_demo_v1 demonstrasyon mağaza vitrini.';

const officialNeighborhoodSource = <String, Object>{
  'title': "Esenler'e İki Yeni Mahalle Kazandırıldı",
  'publisher': 'Esenler Belediyesi',
  'published_date': '2026-01-13',
  'url':
      'https://esenler.bel.tr/haberler/genel/esenlere-iki-yeni-mahalle-kazandirildi/',
};

const coordinateSource = <String, Object>{
  'provider': 'OpenStreetMap / Nominatim',
  'license': 'ODbL 1.0; Data © OpenStreetMap contributors',
  'verified_on': '2026-08-22',
  'lookup_url': 'https://nominatim.openstreetmap.org/lookup',
  'confidence': 'NEIGHBORHOOD_CENTER',
};

const shopOffsets = <LocationOffset>[
  LocationOffset(latitude: 0.00055, longitude: 0),
  LocationOffset(latitude: 0, longitude: 0.00072),
  LocationOffset(latitude: 0, longitude: -0.00072),
];

const neighborhoods = <NeighborhoodSpec>[
  NeighborhoodSpec(
    name: '15 Temmuz',
    latitude: 41.0620417,
    longitude: 28.8778966,
    osmType: 'relation',
    osmId: 13276411,
    south: 41.0563902,
    north: 41.0815985,
    west: 28.8660300,
    east: 28.8858729,
  ),
  NeighborhoodSpec(
    name: 'Atışalanı',
    latitude: 41.0563871,
    longitude: 28.8694017,
    osmType: 'relation',
    osmId: 9423103,
    south: 41.0532311,
    north: 41.0622704,
    west: 28.8635337,
    east: 28.8768365,
  ),
  NeighborhoodSpec(
    name: 'Birlik',
    latitude: 41.0516003,
    longitude: 28.8715638,
    osmType: 'relation',
    osmId: 9423101,
    south: 41.0459605,
    north: 41.0544344,
    west: 28.8651502,
    east: 28.8776075,
  ),
  NeighborhoodSpec(
    name: 'Çifte Havuzlar',
    latitude: 41.0267887,
    longitude: 28.8954257,
    osmType: 'relation',
    osmId: 9309109,
    south: 41.0173263,
    north: 41.0312095,
    west: 28.8854227,
    east: 28.9006289,
  ),
  NeighborhoodSpec(
    name: 'Davutpaşa',
    latitude: 41.0317026,
    longitude: 28.8906911,
    osmType: 'relation',
    osmId: 9318611,
    south: 41.0298557,
    north: 41.0341614,
    west: 28.8854573,
    east: 28.8951239,
  ),
  NeighborhoodSpec(
    name: 'Fatih',
    latitude: 41.0433860,
    longitude: 28.8674705,
    osmType: 'relation',
    osmId: 9422081,
    south: 41.0384466,
    north: 41.0453186,
    west: 28.8593461,
    east: 28.8725399,
  ),
  NeighborhoodSpec(
    name: 'Fevzi Çakmak',
    latitude: 41.0387523,
    longitude: 28.8831880,
    osmType: 'relation',
    osmId: 9421907,
    south: 41.0368999,
    north: 41.0508987,
    west: 28.8753752,
    east: 28.8861561,
  ),
  NeighborhoodSpec(
    name: 'Kazım Karabekir',
    latitude: 41.0464076,
    longitude: 28.8731584,
    osmType: 'relation',
    osmId: 9422082,
    south: 41.0415192,
    north: 41.0492288,
    west: 28.8677233,
    east: 28.8799522,
  ),
  NeighborhoodSpec(
    name: 'Kemer',
    latitude: 41.0526257,
    longitude: 28.8765710,
    osmType: 'relation',
    osmId: 9423100,
    south: 41.0473548,
    north: 41.0586996,
    west: 28.8749897,
    east: 28.8859774,
  ),
  NeighborhoodSpec(
    name: 'Menderes',
    latitude: 41.0395441,
    longitude: 28.8804397,
    osmType: 'relation',
    osmId: 9422033,
    south: 41.0375826,
    north: 41.0454031,
    west: 28.8713516,
    east: 28.8824858,
  ),
  NeighborhoodSpec(
    name: 'Mimar Sinan',
    latitude: 41.0358974,
    longitude: 28.8848756,
    osmType: 'relation',
    osmId: 9421908,
    south: 41.0338681,
    north: 41.0375826,
    west: 28.8824858,
    east: 28.8934556,
  ),
  NeighborhoodSpec(
    name: 'Namık Kemal',
    latitude: 41.0311027,
    longitude: 28.8955728,
    osmType: 'relation',
    osmId: 9318612,
    south: 41.0274601,
    north: 41.0340322,
    west: 28.8923666,
    east: 28.8991171,
  ),
  NeighborhoodSpec(
    name: 'Nine Hatun',
    latitude: 41.0370239,
    longitude: 28.8802419,
    osmType: 'relation',
    osmId: 9422004,
    south: 41.0318455,
    north: 41.0391240,
    west: 28.8725399,
    east: 28.8854573,
  ),
  NeighborhoodSpec(
    name: 'Oruçreis',
    latitude: 41.0588724,
    longitude: 28.8574858,
    osmType: 'relation',
    osmId: 9423122,
    south: 41.0545010,
    north: 41.1074804,
    west: 28.8337984,
    east: 28.8748866,
  ),
  NeighborhoodSpec(
    name: 'Tuna',
    latitude: 41.0529878,
    longitude: 28.8588572,
    osmType: 'relation',
    osmId: 9422209,
    south: 41.0432888,
    north: 41.0556928,
    west: 28.8547230,
    east: 28.8685887,
  ),
  NeighborhoodSpec(
    name: 'Turgut Reis',
    latitude: 41.0614133,
    longitude: 28.8642849,
    osmType: 'relation',
    osmId: 9423121,
    south: 41.0544753,
    north: 41.0656869,
    west: 28.8591733,
    east: 28.8687189,
  ),
  NeighborhoodSpec(
    name: 'Yavuz Selim',
    latitude: 41.0352866,
    longitude: 28.8925614,
    osmType: 'relation',
    osmId: 9318613,
    south: 41.0339025,
    north: 41.0415663,
    west: 28.8835027,
    east: 28.8962625,
  ),
  NeighborhoodSpec(
    name: 'Şehitler',
    latitude: 41.0934599,
    longitude: 28.8511416,
    osmType: 'node',
    osmId: 13596805903,
    south: 41.0834599,
    north: 41.1034599,
    west: 28.8411416,
    east: 28.8611416,
    polygonValidated: false,
  ),
  NeighborhoodSpec(
    name: 'Yeşil Vadi',
    latitude: 41.0835321,
    longitude: 28.8655644,
    osmType: 'node',
    osmId: 13596805904,
    south: 41.0735321,
    north: 41.0935321,
    west: 28.8555644,
    east: 28.8755644,
    polygonValidated: false,
  ),
];

const categorySpecs = <CategorySpec>[
  CategorySpec(
    slug: 'kirtasiye',
    name: 'Kırtasiye',
    sortOrder: 1,
    products: [
      ProductSpec('a5-spiralli-defter', 'A5 Spiralli Defter', 8990),
      ProductSpec('a4-kareli-defter', 'A4 Kareli Defter', 11990),
      ProductSpec('mavi-tukenmez-kalem-5li', "Mavi Tükenmez Kalem 5'li", 7490),
      ProductSpec(
        'a4-fotokopi-kagidi-500',
        'A4 Fotokopi Kağıdı 500 Yaprak',
        24990,
      ),
      ProductSpec('kalem-kutusu', 'Kalem Kutusu', 14990),
    ],
  ),
  CategorySpec(
    slug: 'elektronik',
    name: 'Elektronik',
    sortOrder: 2,
    products: [
      ProductSpec('usb-c-sarj-adaptoru-20w', 'USB-C Şarj Adaptörü 20W', 49990),
      ProductSpec('usb-c-sarj-kablosu-1m', 'USB-C Şarj Kablosu 1 m', 19990),
      ProductSpec('kablosuz-mouse', 'Kablosuz Mouse', 44990),
      ProductSpec('powerbank-10000', '10.000 mAh Powerbank', 99990),
      ProductSpec('bluetooth-kulaklik', 'Bluetooth Kulaklık', 79990),
    ],
  ),
  CategorySpec(
    slug: 'gida',
    name: 'Gıda',
    sortOrder: 3,
    products: [
      ProductSpec('uht-sut-1l', 'UHT Süt 1 L', 4490),
      ProductSpec('aycicek-yagi-1l', 'Ayçiçek Yağı 1 L', 10990),
      ProductSpec('makarna-500g', 'Makarna 500 g', 3490),
      ProductSpec('pirinc-1kg', 'Pirinç 1 kg', 8990),
      ProductSpec('toz-seker-1kg', 'Toz Şeker 1 kg', 5490),
    ],
  ),
  CategorySpec(
    slug: 'ayakkabi',
    name: 'Ayakkabı',
    sortOrder: 4,
    products: [
      ProductSpec(
        'erkek-gunluk-spor-ayakkabi',
        'Erkek Günlük Spor Ayakkabı',
        119990,
      ),
      ProductSpec(
        'kadin-gunluk-spor-ayakkabi',
        'Kadın Günlük Spor Ayakkabı',
        119990,
      ),
      ProductSpec('cocuk-spor-ayakkabi', 'Çocuk Spor Ayakkabı', 89990),
      ProductSpec('gunluk-terlik', 'Günlük Terlik', 34990),
      ProductSpec('su-gecirmez-bot', 'Su Geçirmez Bot', 169990),
    ],
  ),
];

const priceVariationBasisPoints = <int>[-800, -500, -300, 300, 500, 800, 1000];

void main(List<String> arguments) {
  final checkOnly = arguments.contains('--check');
  final dataset = buildDataset();
  final artifacts = <String, String>{
    'tool/demo_seed/esenler_demo_v1.json': renderManifest(dataset),
    'supabase/seeds/esenler_demo_v1.sql': renderSeedSql(dataset),
    'supabase/seeds/esenler_demo_v1_cleanup.sql': renderCleanupSql(dataset),
  };

  var failed = false;
  for (final entry in artifacts.entries) {
    final file = File(entry.key);
    if (checkOnly) {
      if (!file.existsSync() || file.readAsStringSync() != entry.value) {
        stderr.writeln('Generated artifact is stale: ${entry.key}');
        failed = true;
      }
      continue;
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
    stdout.writeln('Wrote ${entry.key}');
  }

  if (failed) exitCode = 1;
}

DemoDataset buildDataset() {
  final categories = <DemoCategory>[];
  final products = <DemoProduct>[];
  final shops = <DemoShop>[];
  final listings = <DemoShopProduct>[];

  for (final category in categorySpecs) {
    final categoryId = uuidV5(
      namespaceUuid,
      '$seedName/category/${category.slug}',
    );
    categories.add(
      DemoCategory(
        id: categoryId,
        slug: category.slug,
        name: category.name,
        description: 'EsnaftaVar $seedName demonstrasyon kategorisi.',
        sortOrder: category.sortOrder,
      ),
    );
    for (final product in category.products) {
      products.add(
        DemoProduct(
          id: uuidV5(
            namespaceUuid,
            '$seedName/product/${category.slug}/${product.slug}',
          ),
          slug: product.slug,
          name: product.name,
          description:
              'EsnaftaVar demonstrasyon kataloğu için sentetik ${product.name}.',
          categoryId: categoryId,
          categorySlug: category.slug,
          categoryName: category.name,
          basePriceCents: product.basePriceCents,
        ),
      );
    }
  }

  for (
    var neighborhoodIndex = 0;
    neighborhoodIndex < neighborhoods.length;
    neighborhoodIndex++
  ) {
    final neighborhood = neighborhoods[neighborhoodIndex];
    final omittedCategoryIndex = neighborhoodIndex % categorySpecs.length;
    final includedCategories = <CategorySpec>[
      for (var index = 0; index < categorySpecs.length; index++)
        if (index != omittedCategoryIndex) categorySpecs[index],
    ];

    for (
      var shopIndex = 0;
      shopIndex < includedCategories.length;
      shopIndex++
    ) {
      final category = includedCategories[shopIndex];
      final categoryRecord = categories.singleWhere(
        (record) => record.slug == category.slug,
      );
      final offset = shopOffsets[shopIndex];
      final shopId = uuidV5(
        namespaceUuid,
        '$seedName/shop/${neighborhoodIndex + 1}/${_slug(neighborhood.name)}/${category.slug}',
      );
      final shop = DemoShop(
        id: shopId,
        neighborhoodIndex: neighborhoodIndex + 1,
        neighborhoodName: neighborhood.name,
        categoryId: categoryRecord.id,
        categorySlug: category.slug,
        categoryName: category.name,
        name: '[DEMO] ${neighborhood.name} ${category.name}',
        address:
            '${neighborhood.name} Mahallesi, Esenler / İstanbul — Demo Konum',
        latitude: _round7(neighborhood.latitude + offset.latitude),
        longitude: _round7(neighborhood.longitude + offset.longitude),
        offsetIndex: shopIndex,
      );
      shops.add(shop);

      final categoryProducts = products
          .where((product) => product.categorySlug == category.slug)
          .toList(growable: false);
      for (
        var productIndex = 0;
        productIndex < categoryProducts.length;
        productIndex++
      ) {
        final product = categoryProducts[productIndex];
        final variationIndex =
            (neighborhoodIndex * 3 + shopIndex + productIndex) %
            priceVariationBasisPoints.length;
        final variation = priceVariationBasisPoints[variationIndex];
        final priceCents =
            (product.basePriceCents * (10000 + variation) + 5000) ~/ 10000;
        listings.add(
          DemoShopProduct(
            id: uuidV5(
              namespaceUuid,
              '$seedName/shop-product/$shopId/${product.id}',
            ),
            shopId: shopId,
            productId: product.id,
            categoryId: categoryRecord.id,
            categorySlug: category.slug,
            priceCents: priceCents,
            priceVariationBasisPoints: variation,
          ),
        );
      }
    }
  }

  return DemoDataset(
    categories: categories,
    products: products,
    shops: shops,
    shopProducts: listings,
  );
}

String renderManifest(DemoDataset dataset) {
  final encoder = JsonEncoder.withIndent('  ');
  return '${encoder.convert(dataset.toJson())}\n';
}

String renderSeedSql(DemoDataset dataset) {
  final categories = dataset.categories
      .map(
        (record) =>
            "  ('${record.id}'::uuid, ${_sqlText(record.name)}, ${_sqlText(record.description)}, NULL::text, NULL::uuid, ${record.sortOrder}, true)",
      )
      .join(',\n');
  final products = dataset.products
      .map(
        (record) =>
            "  ('${record.id}'::uuid, ${_sqlText(record.name)}, ${_sqlText(record.description)}, ${_money(record.basePriceCents)}::numeric, NULL::numeric, '${record.categoryId}'::uuid, NULL::uuid, 100, NULL::text, '{}'::text[], 0::numeric, 0, true, true, '{\"demo\":true,\"demo_seed\":\"$seedName\"}'::jsonb)",
      )
      .join(',\n');
  final shops = dataset.shops
      .map(
        (record) =>
            "  ('${record.id}'::uuid, NULL::uuid, ${_sqlText(record.name)}, ${_sqlText(demoDescription)}, ${_sqlText(record.address)}, ${record.latitude}::numeric, ${record.longitude}::numeric, NULL::text, '{}'::jsonb, true, 0::numeric, 0)",
      )
      .join(',\n');
  final listings = dataset.shopProducts
      .map(
        (record) =>
            "  ('${record.id}'::uuid, '${record.shopId}'::uuid, '${record.productId}'::uuid, ${_money(record.priceCents)}::numeric, true, ${_sqlText(listingDescription)}, '{}'::text[], true)",
      )
      .join(',\n');

  return '''-- Generated by tool/demo_seed/generate_esenler_demo_v1.dart.
-- Synthetic Esenler discovery data only. No Auth, review, rating, QR, chat,
-- notification, order, analytics, or verified-purchase rows are created.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO \$schema_preflight\$
BEGIN
  IF to_regclass('public.categories') IS NULL
     OR to_regclass('public.products') IS NULL
     OR to_regclass('public.shops') IS NULL
     OR to_regclass('public.shop_products') IS NULL THEN
    RAISE EXCEPTION
      '[ESENLER_DEMO_V1_SCHEMA_MISSING] canonical migrations 0001-0009 are required'
      USING ERRCODE = '42P01';
  END IF;
END
\$schema_preflight\$;

CREATE TEMP TABLE _esenler_demo_v1_categories (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text,
  image_url text,
  parent_id uuid,
  sort_order integer NOT NULL,
  is_active boolean NOT NULL
) ON COMMIT DROP;

INSERT INTO _esenler_demo_v1_categories VALUES
$categories;

CREATE TEMP TABLE _esenler_demo_v1_products (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  sale_price numeric,
  category_id uuid NOT NULL,
  brand_id uuid,
  stock integer NOT NULL,
  thumbnail text,
  images text[] NOT NULL,
  rating numeric NOT NULL,
  reviews_count integer NOT NULL,
  is_featured boolean NOT NULL,
  is_active boolean NOT NULL,
  attributes jsonb NOT NULL
) ON COMMIT DROP;

INSERT INTO _esenler_demo_v1_products VALUES
$products;

CREATE TEMP TABLE _esenler_demo_v1_shops (
  id uuid PRIMARY KEY,
  owner_user_id uuid,
  name text NOT NULL,
  description text,
  address text,
  latitude numeric NOT NULL,
  longitude numeric NOT NULL,
  phone text,
  opening_hours jsonb NOT NULL,
  is_active boolean NOT NULL,
  rating numeric NOT NULL,
  rating_count integer NOT NULL
) ON COMMIT DROP;

INSERT INTO _esenler_demo_v1_shops VALUES
$shops;

CREATE TEMP TABLE _esenler_demo_v1_shop_products (
  id uuid PRIMARY KEY,
  shop_id uuid NOT NULL,
  product_id uuid NOT NULL,
  price numeric NOT NULL,
  is_available boolean NOT NULL,
  description text,
  images text[] NOT NULL,
  is_active boolean NOT NULL,
  UNIQUE (shop_id, product_id)
) ON COMMIT DROP;

INSERT INTO _esenler_demo_v1_shop_products VALUES
$listings;

DO \$collision_preflight\$
BEGIN
  IF (SELECT count(*) FROM _esenler_demo_v1_categories) <> 4
     OR (SELECT count(*) FROM _esenler_demo_v1_products) <> 20
     OR (SELECT count(*) FROM _esenler_demo_v1_shops) <> 57
     OR (SELECT count(*) FROM _esenler_demo_v1_shop_products) <> 285 THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_GENERATOR_COUNT_MISMATCH]'
      USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.categories actual
    JOIN _esenler_demo_v1_categories expected USING (id)
    WHERE ROW(
      actual.name, actual.description, actual.image_url, actual.parent_id,
      actual.sort_order, actual.is_active
    ) IS DISTINCT FROM ROW(
      expected.name, expected.description, expected.image_url,
      expected.parent_id, expected.sort_order, expected.is_active
    )
  ) OR EXISTS (
    SELECT 1
    FROM public.categories actual
    JOIN _esenler_demo_v1_categories expected ON actual.name = expected.name
    WHERE actual.id <> expected.id
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CATEGORY_COLLISION] no rows changed'
      USING ERRCODE = '23505';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.products actual
    JOIN _esenler_demo_v1_products expected USING (id)
    WHERE ROW(
      actual.name, actual.description, actual.price, actual.sale_price,
      actual.category_id, actual.brand_id, actual.stock, actual.thumbnail,
      actual.images, actual.rating, actual.reviews_count, actual.is_featured,
      actual.is_active, actual.attributes
    ) IS DISTINCT FROM ROW(
      expected.name, expected.description, expected.price, expected.sale_price,
      expected.category_id, expected.brand_id, expected.stock,
      expected.thumbnail, expected.images, expected.rating,
      expected.reviews_count, expected.is_featured, expected.is_active,
      expected.attributes
    )
  ) OR EXISTS (
    SELECT 1
    FROM public.products actual
    JOIN _esenler_demo_v1_products expected ON actual.name = expected.name
    WHERE actual.id <> expected.id
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_PRODUCT_COLLISION] no rows changed'
      USING ERRCODE = '23505';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.shops actual
    JOIN _esenler_demo_v1_shops expected USING (id)
    WHERE ROW(
      actual.owner_user_id, actual.name, actual.description, actual.address,
      actual.latitude, actual.longitude, actual.phone, actual.opening_hours,
      actual.is_active, actual.rating, actual.rating_count
    ) IS DISTINCT FROM ROW(
      expected.owner_user_id, expected.name, expected.description,
      expected.address, expected.latitude, expected.longitude, expected.phone,
      expected.opening_hours, expected.is_active, expected.rating,
      expected.rating_count
    )
  ) OR EXISTS (
    SELECT 1
    FROM public.shops actual
    JOIN _esenler_demo_v1_shops expected ON actual.name = expected.name
    WHERE actual.id <> expected.id
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_SHOP_COLLISION] no rows changed'
      USING ERRCODE = '23505';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.shop_products actual
    JOIN _esenler_demo_v1_shop_products expected USING (id)
    WHERE ROW(
      actual.shop_id, actual.product_id, actual.price, actual.is_available,
      actual.description, actual.images, actual.is_active
    ) IS DISTINCT FROM ROW(
      expected.shop_id, expected.product_id, expected.price,
      expected.is_available, expected.description, expected.images,
      expected.is_active
    )
  ) OR EXISTS (
    SELECT 1
    FROM public.shop_products actual
    JOIN _esenler_demo_v1_shop_products expected
      ON actual.shop_id = expected.shop_id
     AND actual.product_id = expected.product_id
    WHERE actual.id <> expected.id
  ) OR EXISTS (
    SELECT 1
    FROM public.shop_products actual
    WHERE (
      actual.shop_id IN (SELECT id FROM _esenler_demo_v1_shops)
      OR actual.product_id IN (SELECT id FROM _esenler_demo_v1_products)
    )
      AND actual.id NOT IN (SELECT id FROM _esenler_demo_v1_shop_products)
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_LISTING_COLLISION] no rows changed'
      USING ERRCODE = '23505';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.products actual
    WHERE actual.category_id IN (SELECT id FROM _esenler_demo_v1_categories)
      AND actual.id NOT IN (SELECT id FROM _esenler_demo_v1_products)
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CATEGORY_RELATION_COLLISION] no rows changed'
      USING ERRCODE = '23505';
  END IF;
END
\$collision_preflight\$;

INSERT INTO public.categories (
  id, name, description, image_url, parent_id, sort_order, is_active,
  created_at, updated_at
)
SELECT id, name, description, image_url, parent_id, sort_order, is_active,
       '$deterministicTimestamp'::timestamptz,
       '$deterministicTimestamp'::timestamptz
FROM _esenler_demo_v1_categories
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (
  id, name, description, price, sale_price, category_id, brand_id, stock,
  thumbnail, images, rating, reviews_count, is_featured, is_active,
  attributes, created_at, updated_at
)
SELECT id, name, description, price, sale_price, category_id, brand_id, stock,
       thumbnail, images, rating, reviews_count, is_featured, is_active,
       attributes, '$deterministicTimestamp'::timestamptz,
       '$deterministicTimestamp'::timestamptz
FROM _esenler_demo_v1_products
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.shops (
  id, owner_user_id, name, description, address, latitude, longitude, phone,
  opening_hours, is_active, rating, rating_count, created_at, updated_at
)
SELECT id, owner_user_id, name, description, address, latitude, longitude,
       phone, opening_hours, is_active, rating, rating_count,
       '$deterministicTimestamp'::timestamptz,
       '$deterministicTimestamp'::timestamptz
FROM _esenler_demo_v1_shops
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.shop_products (
  id, shop_id, product_id, price, is_available, description, images,
  is_active, created_at, updated_at
)
SELECT id, shop_id, product_id, price, is_available, description, images,
       is_active, '$deterministicTimestamp'::timestamptz,
       '$deterministicTimestamp'::timestamptz
FROM _esenler_demo_v1_shop_products
ON CONFLICT (id) DO NOTHING;

DO \$postflight\$
BEGIN
  IF (SELECT count(*) FROM public.categories actual JOIN _esenler_demo_v1_categories expected USING (id)) <> 4
     OR (SELECT count(*) FROM public.products actual JOIN _esenler_demo_v1_products expected USING (id)) <> 20
     OR (SELECT count(*) FROM public.shops actual JOIN _esenler_demo_v1_shops expected USING (id)) <> 57
     OR (SELECT count(*) FROM public.shop_products actual JOIN _esenler_demo_v1_shop_products expected USING (id)) <> 285 THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_POSTFLIGHT_COUNT_MISMATCH] transaction rolled back'
      USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM _esenler_demo_v1_shops shop
    LEFT JOIN _esenler_demo_v1_shop_products listing
      ON listing.shop_id = shop.id
    GROUP BY shop.id
    HAVING count(listing.id) <> 5
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_SHOP_LISTING_COUNT_MISMATCH] transaction rolled back'
      USING ERRCODE = 'P0001';
  END IF;
END
\$postflight\$;

COMMIT;
''';
}

String renderCleanupSql(DemoDataset dataset) {
  final categoryIds = _uuidArray(dataset.categories.map((row) => row.id));
  final productIds = _uuidArray(dataset.products.map((row) => row.id));
  final shopIds = _uuidArray(dataset.shops.map((row) => row.id));
  final listingIds = _uuidArray(dataset.shopProducts.map((row) => row.id));

  return '''-- Generated by tool/demo_seed/generate_esenler_demo_v1.dart.
-- Exact-ID cleanup for $seedName. This script intentionally stops if any
-- expected row is missing, loses its demo marker, or has unexpected relations.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO \$cleanup_preflight\$
DECLARE
  category_ids uuid[] := ARRAY[$categoryIds]::uuid[];
  product_ids uuid[] := ARRAY[$productIds]::uuid[];
  shop_ids uuid[] := ARRAY[$shopIds]::uuid[];
  listing_ids uuid[] := ARRAY[$listingIds]::uuid[];
BEGIN
  IF to_regclass('public.categories') IS NULL
     OR to_regclass('public.products') IS NULL
     OR to_regclass('public.shops') IS NULL
     OR to_regclass('public.shop_products') IS NULL THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_SCHEMA_MISSING]'
      USING ERRCODE = '42P01';
  END IF;

  IF (SELECT count(*) FROM public.categories WHERE id = ANY(category_ids)) <> 4
     OR (SELECT count(*) FROM public.products WHERE id = ANY(product_ids)) <> 20
     OR (SELECT count(*) FROM public.shops WHERE id = ANY(shop_ids)) <> 57
     OR (SELECT count(*) FROM public.shop_products WHERE id = ANY(listing_ids)) <> 285 THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_EXPECTED_COUNT_MISMATCH] no rows changed'
      USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.products
    WHERE id = ANY(product_ids)
      AND attributes IS DISTINCT FROM
        '{"demo":true,"demo_seed":"$seedName"}'::jsonb
  ) OR EXISTS (
    SELECT 1 FROM public.shops
    WHERE id = ANY(shop_ids)
      AND (
        owner_user_id IS NOT NULL
        OR name NOT LIKE '[DEMO] %'
        OR description IS DISTINCT FROM ${_sqlText(demoDescription)}
        OR phone IS NOT NULL
        OR rating <> 0
        OR rating_count <> 0
      )
  ) OR EXISTS (
    SELECT 1 FROM public.shop_products
    WHERE id = ANY(listing_ids)
      AND description IS DISTINCT FROM ${_sqlText(listingDescription)}
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_MARKER_MISMATCH] no rows changed'
      USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.shop_products
    WHERE (shop_id = ANY(shop_ids) OR product_id = ANY(product_ids))
      AND NOT (id = ANY(listing_ids))
  ) OR EXISTS (
    SELECT 1 FROM public.products
    WHERE category_id = ANY(category_ids) AND NOT (id = ANY(product_ids))
  ) OR EXISTS (
    SELECT 1 FROM public.categories
    WHERE parent_id = ANY(category_ids) AND NOT (id = ANY(category_ids))
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_UNEXPECTED_CATALOG_RELATION] no rows changed'
      USING ERRCODE = 'P0001';
  END IF;

  IF EXISTS (SELECT 1 FROM public.wishlist WHERE product_id = ANY(product_ids))
     OR EXISTS (SELECT 1 FROM public.order_items WHERE product_id = ANY(product_ids))
     OR EXISTS (SELECT 1 FROM public.reviews WHERE product_id = ANY(product_ids))
     OR EXISTS (SELECT 1 FROM public.carts WHERE shop_id = ANY(shop_ids))
     OR EXISTS (SELECT 1 FROM public.cart_items_v2 WHERE shop_product_id = ANY(listing_ids))
     OR EXISTS (SELECT 1 FROM public.qr_sessions WHERE shop_id = ANY(shop_ids))
     OR EXISTS (
       SELECT 1 FROM public.qr_session_items
       WHERE shop_product_id = ANY(listing_ids) OR product_id = ANY(product_ids)
     )
     OR EXISTS (SELECT 1 FROM public.verified_transactions WHERE shop_id = ANY(shop_ids))
     OR EXISTS (
       SELECT 1 FROM public.verified_transaction_items
       WHERE shop_product_id = ANY(listing_ids) OR product_id = ANY(product_ids)
     )
     OR EXISTS (SELECT 1 FROM public.shop_ratings WHERE shop_id = ANY(shop_ids)) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_TRUST_OR_CUSTOMER_RELATION_FOUND] no rows changed'
      USING ERRCODE = 'P0001';
  END IF;
END
\$cleanup_preflight\$;

DELETE FROM public.shop_products
WHERE id = ANY(ARRAY[$listingIds]::uuid[]);

DELETE FROM public.shops
WHERE id = ANY(ARRAY[$shopIds]::uuid[]);

DELETE FROM public.products
WHERE id = ANY(ARRAY[$productIds]::uuid[]);

DELETE FROM public.categories
WHERE id = ANY(ARRAY[$categoryIds]::uuid[]);

DO \$cleanup_postflight\$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.shop_products
    WHERE id = ANY(ARRAY[$listingIds]::uuid[])
  ) OR EXISTS (
    SELECT 1 FROM public.shops
    WHERE id = ANY(ARRAY[$shopIds]::uuid[])
  ) OR EXISTS (
    SELECT 1 FROM public.products
    WHERE id = ANY(ARRAY[$productIds]::uuid[])
  ) OR EXISTS (
    SELECT 1 FROM public.categories
    WHERE id = ANY(ARRAY[$categoryIds]::uuid[])
  ) THEN
    RAISE EXCEPTION '[ESENLER_DEMO_V1_CLEANUP_POSTFLIGHT_FAILED] transaction rolled back'
      USING ERRCODE = 'P0001';
  END IF;
END
\$cleanup_postflight\$;

COMMIT;
''';
}

String uuidV5(String namespace, String name) {
  final namespaceBytes = _uuidBytes(namespace);
  final digest = _sha1(<int>[...namespaceBytes, ...utf8.encode(name)]);
  final bytes = digest.sublist(0, 16);
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

List<int> _uuidBytes(String value) {
  final hex = value.replaceAll('-', '');
  if (!RegExp(r'^[0-9a-fA-F]{32}$').hasMatch(hex)) {
    throw FormatException('Invalid UUID namespace');
  }
  return [
    for (var index = 0; index < hex.length; index += 2)
      int.parse(hex.substring(index, index + 2), radix: 16),
  ];
}

List<int> _sha1(List<int> input) {
  final message = <int>[...input, 0x80];
  while (message.length % 64 != 56) {
    message.add(0);
  }
  final bitLength = input.length * 8;
  for (var shift = 56; shift >= 0; shift -= 8) {
    message.add((bitLength >> shift) & 0xff);
  }

  var h0 = 0x67452301;
  var h1 = 0xefcdab89;
  var h2 = 0x98badcfe;
  var h3 = 0x10325476;
  var h4 = 0xc3d2e1f0;

  for (var chunk = 0; chunk < message.length; chunk += 64) {
    final words = List<int>.filled(80, 0);
    for (var index = 0; index < 16; index++) {
      final offset = chunk + index * 4;
      words[index] =
          (message[offset] << 24) |
          (message[offset + 1] << 16) |
          (message[offset + 2] << 8) |
          message[offset + 3];
    }
    for (var index = 16; index < 80; index++) {
      words[index] = _rotateLeft(
        words[index - 3] ^
            words[index - 8] ^
            words[index - 14] ^
            words[index - 16],
        1,
      );
    }

    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;

    for (var index = 0; index < 80; index++) {
      late final int f;
      late final int k;
      if (index < 20) {
        f = (b & c) | ((~b) & d);
        k = 0x5a827999;
      } else if (index < 40) {
        f = b ^ c ^ d;
        k = 0x6ed9eba1;
      } else if (index < 60) {
        f = (b & c) | (b & d) | (c & d);
        k = 0x8f1bbcdc;
      } else {
        f = b ^ c ^ d;
        k = 0xca62c1d6;
      }
      final temp = (_rotateLeft(a, 5) + f + e + k + words[index]) & 0xffffffff;
      e = d;
      d = c;
      c = _rotateLeft(b, 30);
      b = a;
      a = temp;
    }

    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
  }

  return [
    for (final word in [h0, h1, h2, h3, h4])
      for (var shift = 24; shift >= 0; shift -= 8) (word >> shift) & 0xff,
  ];
}

int _rotateLeft(int value, int amount) {
  final normalized = value & 0xffffffff;
  return ((normalized << amount) | (normalized >> (32 - amount))) & 0xffffffff;
}

String _sqlText(String value) => "'${value.replaceAll("'", "''")}'::text";

String _uuidArray(Iterable<String> values) =>
    values.map((value) => "'$value'::uuid").join(', ');

String _money(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

String _slug(String value) => value
    .toLowerCase()
    .replaceAll('ı', 'i')
    .replaceAll('ş', 's')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

double _round7(double value) => double.parse(value.toStringAsFixed(7));

double _price(int cents) => cents / 100;

class LocationOffset {
  final double latitude;
  final double longitude;

  const LocationOffset({required this.latitude, required this.longitude});

  Map<String, Object> toJson() => {
    'latitude_delta': latitude,
    'longitude_delta': longitude,
    'approximate_distance_meters': 60,
  };
}

class NeighborhoodSpec {
  final String name;
  final double latitude;
  final double longitude;
  final String osmType;
  final int osmId;
  final double south;
  final double north;
  final double west;
  final double east;
  final bool polygonValidated;

  const NeighborhoodSpec({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.osmType,
    required this.osmId,
    required this.south,
    required this.north,
    required this.west,
    required this.east,
    this.polygonValidated = true,
  });

  Map<String, Object> toJson(int index) => {
    'official_index': index,
    'name': name,
    'center': {'latitude': latitude, 'longitude': longitude},
    'bounding_box': {
      'south': south,
      'north': north,
      'west': west,
      'east': east,
    },
    'source': {
      'provider': 'OpenStreetMap / Nominatim',
      'osm_type': osmType,
      'osm_id': osmId,
      'url': 'https://www.openstreetmap.org/$osmType/$osmId',
    },
    'location_confidence': 'NEIGHBORHOOD_CENTER',
    'polygon_validation': polygonValidated
        ? 'PASS_ALL_THREE_OFFSETS_INSIDE_OSM_POLYGON_2026-08-22'
        : 'UNAVAILABLE_NEW_NEIGHBORHOOD_LOCALITY_POINT',
  };
}

class CategorySpec {
  final String slug;
  final String name;
  final int sortOrder;
  final List<ProductSpec> products;

  const CategorySpec({
    required this.slug,
    required this.name,
    required this.sortOrder,
    required this.products,
  });
}

class ProductSpec {
  final String slug;
  final String name;
  final int basePriceCents;

  const ProductSpec(this.slug, this.name, this.basePriceCents);
}

class DemoCategory {
  final String id;
  final String slug;
  final String name;
  final String description;
  final int sortOrder;

  const DemoCategory({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'description': description,
    'image_url': null,
    'parent_id': null,
    'sort_order': sortOrder,
    'is_active': true,
  };
}

class DemoProduct {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String categoryId;
  final String categorySlug;
  final String categoryName;
  final int basePriceCents;

  const DemoProduct({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categorySlug,
    required this.categoryName,
    required this.basePriceCents,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'description': description,
    'price': _price(basePriceCents),
    'sale_price': null,
    'category_id': categoryId,
    'category_slug': categorySlug,
    'category_name': categoryName,
    'brand_id': null,
    'stock': 100,
    'thumbnail': null,
    'images': <String>[],
    'rating': 0,
    'reviews_count': 0,
    'is_featured': true,
    'is_active': true,
    'attributes': {'demo': true, 'demo_seed': seedName},
  };
}

class DemoShop {
  final String id;
  final int neighborhoodIndex;
  final String neighborhoodName;
  final String categoryId;
  final String categorySlug;
  final String categoryName;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int offsetIndex;

  const DemoShop({
    required this.id,
    required this.neighborhoodIndex,
    required this.neighborhoodName,
    required this.categoryId,
    required this.categorySlug,
    required this.categoryName,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.offsetIndex,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'neighborhood_index': neighborhoodIndex,
    'neighborhood_name': neighborhoodName,
    'category_id': categoryId,
    'category_slug': categorySlug,
    'category_name': categoryName,
    'name': name,
    'description': demoDescription,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'coordinate_offset_index': offsetIndex,
    'owner_user_id': null,
    'phone': null,
    'opening_hours': <String, Object>{},
    'is_active': true,
    'rating': 0,
    'rating_count': 0,
  };
}

class DemoShopProduct {
  final String id;
  final String shopId;
  final String productId;
  final String categoryId;
  final String categorySlug;
  final int priceCents;
  final int priceVariationBasisPoints;

  const DemoShopProduct({
    required this.id,
    required this.shopId,
    required this.productId,
    required this.categoryId,
    required this.categorySlug,
    required this.priceCents,
    required this.priceVariationBasisPoints,
  });

  Map<String, Object> toJson() => {
    'id': id,
    'shop_id': shopId,
    'product_id': productId,
    'category_id': categoryId,
    'category_slug': categorySlug,
    'price': _price(priceCents),
    'price_variation_basis_points': priceVariationBasisPoints,
    'is_available': true,
    'description': listingDescription,
    'images': <String>[],
    'is_active': true,
  };
}

class DemoDataset {
  final List<DemoCategory> categories;
  final List<DemoProduct> products;
  final List<DemoShop> shops;
  final List<DemoShopProduct> shopProducts;

  const DemoDataset({
    required this.categories,
    required this.products,
    required this.shops,
    required this.shopProducts,
  });

  Map<String, Object> toJson() {
    final shopDistribution = <String, int>{
      for (final category in categorySpecs) category.name: 0,
    };
    for (final shop in shops) {
      shopDistribution.update(shop.categoryName, (count) => count + 1);
    }

    return {
      'schema_version': 1,
      'seed': seedName,
      'namespace_uuid': namespaceUuid,
      'deterministic_timestamp': deterministicTimestamp,
      'synthetic_data_notice':
          'All records are synthetic demonstration data; no real business is represented.',
      'official_neighborhood_source': officialNeighborhoodSource,
      'coordinate_source': coordinateSource,
      'location_offsets': shopOffsets.map((offset) => offset.toJson()).toList(),
      'counts': {
        'neighborhoods': neighborhoods.length,
        'categories': categories.length,
        'products': products.length,
        'shops': shops.length,
        'shop_products': shopProducts.length,
      },
      'category_shop_distribution': shopDistribution,
      'trust_rows_created': {
        'auth_users': 0,
        'orders': 0,
        'reviews': 0,
        'shop_ratings': 0,
        'qr_sessions': 0,
        'verified_transactions': 0,
        'chat_messages': 0,
        'notifications': 0,
        'analytics': 0,
      },
      'neighborhoods': [
        for (var index = 0; index < neighborhoods.length; index++)
          neighborhoods[index].toJson(index + 1),
      ],
      'categories': categories.map((row) => row.toJson()).toList(),
      'products': products.map((row) => row.toJson()).toList(),
      'shops': shops.map((row) => row.toJson()).toList(),
      'shop_products': shopProducts.map((row) => row.toJson()).toList(),
      'cleanup_manifest': {
        'category_ids': categories.map((row) => row.id).toList(),
        'product_ids': products.map((row) => row.id).toList(),
        'shop_ids': shops.map((row) => row.id).toList(),
        'shop_product_ids': shopProducts.map((row) => row.id).toList(),
      },
    };
  }
}
