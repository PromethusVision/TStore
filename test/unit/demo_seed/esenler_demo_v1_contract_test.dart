import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/demo_seed/generate_esenler_demo_v1.dart' as seed;

const expectedNeighborhoods = <String>[
  '15 Temmuz',
  'Atışalanı',
  'Birlik',
  'Çifte Havuzlar',
  'Davutpaşa',
  'Fatih',
  'Fevzi Çakmak',
  'Kazım Karabekir',
  'Kemer',
  'Menderes',
  'Mimar Sinan',
  'Namık Kemal',
  'Nine Hatun',
  'Oruçreis',
  'Tuna',
  'Turgut Reis',
  'Yavuz Selim',
  'Şehitler',
  'Yeşil Vadi',
];

void main() {
  late Map<String, dynamic> manifest;
  late List<Map<String, dynamic>> neighborhoods;
  late List<Map<String, dynamic>> categories;
  late List<Map<String, dynamic>> products;
  late List<Map<String, dynamic>> shops;
  late List<Map<String, dynamic>> listings;
  late String seedSql;
  late String cleanupSql;

  setUpAll(() {
    manifest =
        jsonDecode(
              File('tool/demo_seed/esenler_demo_v1.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    neighborhoods = _records(manifest['neighborhoods']);
    categories = _records(manifest['categories']);
    products = _records(manifest['products']);
    shops = _records(manifest['shops']);
    listings = _records(manifest['shop_products']);
    seedSql = File('supabase/seeds/esenler_demo_v1.sql').readAsStringSync();
    cleanupSql = File(
      'supabase/seeds/esenler_demo_v1_cleanup.sql',
    ).readAsStringSync();
  });

  group('deterministic artifact generation', () {
    test('UUIDv5 implementation matches the RFC 4122 reference vector', () {
      expect(
        seed.uuidV5('6ba7b810-9dad-11d1-80b4-00c04fd430c8', 'www.widgets.com'),
        '21f7f8de-8051-5b89-8680-0195ef798b6a',
      );
    });

    test('materialized artifacts exactly match a fresh generation', () {
      final dataset = seed.buildDataset();

      expect(
        seed.renderManifest(dataset),
        seed.renderManifest(seed.buildDataset()),
      );
      expect(
        File('tool/demo_seed/esenler_demo_v1.json').readAsStringSync(),
        seed.renderManifest(dataset),
      );
      expect(seedSql, seed.renderSeedSql(dataset));
      expect(cleanupSql, seed.renderCleanupSql(dataset));
    });

    test('all materialized identifiers are stable UUIDv5 values', () {
      final ids = <String>[
        ...categories.map((row) => row['id'] as String),
        ...products.map((row) => row['id'] as String),
        ...shops.map((row) => row['id'] as String),
        ...listings.map((row) => row['id'] as String),
      ];
      final uuidV5Pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.every(uuidV5Pattern.hasMatch), isTrue);
    });
  });

  group('official Esenler geography contract', () {
    test('contains the exact official 19-neighborhood order', () {
      expect(
        neighborhoods.map((row) => row['name'] as String).toList(),
        expectedNeighborhoods,
      );
      expect(manifest['counts'], containsPair('neighborhoods', 19));
    });

    test(
      'creates exactly three unique, valid coordinates per neighborhood',
      () {
        for (final neighborhood in neighborhoods) {
          final name = neighborhood['name'] as String;
          final neighborhoodShops = shops
              .where((shop) => shop['neighborhood_name'] == name)
              .toList();
          expect(neighborhoodShops, hasLength(3), reason: name);
          expect(
            neighborhoodShops
                .map((shop) => '${shop['latitude']},${shop['longitude']}')
                .toSet(),
            hasLength(3),
            reason: name,
          );

          final center = neighborhood['center'] as Map<String, dynamic>;
          final bounds = neighborhood['bounding_box'] as Map<String, dynamic>;
          for (final shop in neighborhoodShops) {
            final latitude = (shop['latitude'] as num).toDouble();
            final longitude = (shop['longitude'] as num).toDouble();
            expect(latitude, inInclusiveRange(-90, 90), reason: shop['name']);
            expect(
              longitude,
              inInclusiveRange(-180, 180),
              reason: shop['name'],
            );
            expect(
              latitude,
              inInclusiveRange(bounds['south'] as num, bounds['north'] as num),
              reason: shop['name'],
            );
            expect(
              longitude,
              inInclusiveRange(bounds['west'] as num, bounds['east'] as num),
              reason: shop['name'],
            );
            final distance = _distanceMeters(
              (center['latitude'] as num).toDouble(),
              (center['longitude'] as num).toDouble(),
              latitude,
              longitude,
            );
            expect(distance, inInclusiveRange(50, 70), reason: shop['name']);
          }
        }
      },
    );

    test('records polygon evidence honestly for the two new neighborhoods', () {
      final byName = {
        for (final neighborhood in neighborhoods)
          neighborhood['name'] as String: neighborhood,
      };

      for (final name in ['Şehitler', 'Yeşil Vadi']) {
        expect(
          byName[name]!['polygon_validation'],
          'UNAVAILABLE_NEW_NEIGHBORHOOD_LOCALITY_POINT',
        );
        expect(byName[name]!['location_confidence'], 'NEIGHBORHOOD_CENTER');
        final source = byName[name]!['source'] as Map<String, dynamic>;
        expect(source['osm_type'], 'node');
      }

      for (final neighborhood in neighborhoods.take(17)) {
        expect(
          neighborhood['polygon_validation'],
          'PASS_ALL_THREE_OFFSETS_INSIDE_OSM_POLYGON_2026-08-22',
        );
      }
    });
  });

  group('catalog and shop distribution contract', () {
    test(
      'has exactly 4 categories, 20 shared products, 57 shops, 285 listings',
      () {
        expect(categories, hasLength(4));
        expect(products, hasLength(20));
        expect(shops, hasLength(57));
        expect(listings, hasLength(285));
        expect(manifest['counts'], {
          'neighborhoods': 19,
          'categories': 4,
          'products': 20,
          'shops': 57,
          'shop_products': 285,
        });
      },
    );

    test('rotating omission yields the required 14/14/14/15 shop split', () {
      expect(manifest['category_shop_distribution'], {
        'Kırtasiye': 14,
        'Elektronik': 14,
        'Gıda': 14,
        'Ayakkabı': 15,
      });
      for (final name in expectedNeighborhoods) {
        final categoryNames = shops
            .where((shop) => shop['neighborhood_name'] == name)
            .map((shop) => shop['category_name'])
            .toSet();
        expect(categoryNames, hasLength(3), reason: name);
      }
    });

    test(
      'each category has five canonical products shared by all its shops',
      () {
        for (final category in categories) {
          final categoryId = category['id'];
          final categoryProducts = products
              .where((product) => product['category_id'] == categoryId)
              .toList();
          final categoryShops = shops
              .where((shop) => shop['category_id'] == categoryId)
              .toList();
          final expectedProductIds = categoryProducts
              .map((product) => product['id'])
              .toSet();

          expect(categoryProducts, hasLength(5), reason: category['name']);
          for (final shop in categoryShops) {
            final actualProductIds = listings
                .where((listing) => listing['shop_id'] == shop['id'])
                .map((listing) => listing['product_id'])
                .toSet();
            expect(
              actualProductIds,
              expectedProductIds,
              reason: shop['name'] as String,
            );
          }
        }
      },
    );

    test(
      'each shop has five active matching listings with positive varied prices',
      () {
        final productById = {
          for (final product in products) product['id'] as String: product,
        };
        for (final shop in shops) {
          final shopListings = listings
              .where((listing) => listing['shop_id'] == shop['id'])
              .toList();
          expect(shopListings, hasLength(5), reason: shop['name']);
          for (final listing in shopListings) {
            final product = productById[listing['product_id']]!;
            expect(listing['category_id'], shop['category_id']);
            expect(product['category_id'], shop['category_id']);
            expect((listing['price'] as num), greaterThan(0));
            expect(listing['is_active'], isTrue);
            expect(listing['is_available'], isTrue);
          }
        }

        for (final product in products) {
          final prices = listings
              .where((listing) => listing['product_id'] == product['id'])
              .map((listing) => listing['price'])
              .toSet();
          expect(prices.length, greaterThan(1), reason: product['name']);
        }
      },
    );

    test(
      'shop and product records remain explicitly synthetic and trust-neutral',
      () {
        expect(shops.map((shop) => shop['name']).toSet(), hasLength(57));
        for (final shop in shops) {
          expect((shop['name'] as String).startsWith('[DEMO] '), isTrue);
          expect(shop['address'], contains(shop['neighborhood_name']));
          expect(shop['address'], contains('Demo'));
          expect(shop['owner_user_id'], isNull);
          expect(shop['phone'], isNull);
          expect(shop['rating'], 0);
          expect(shop['rating_count'], 0);
        }
        for (final product in products) {
          expect(product['brand_id'], isNull);
          expect(product['thumbnail'], isNull);
          expect(product['images'], isEmpty);
          expect(product['is_featured'], isTrue);
          expect(product['attributes'], {
            'demo': true,
            'demo_seed': 'esenler_demo_v1',
          });
        }
        expect(manifest['trust_rows_created'], {
          'auth_users': 0,
          'orders': 0,
          'reviews': 0,
          'shop_ratings': 0,
          'qr_sessions': 0,
          'verified_transactions': 0,
          'chat_messages': 0,
          'notifications': 0,
          'analytics': 0,
        });
      },
    );
  });

  group('seed and cleanup safety contract', () {
    test(
      'seed is fail-closed, idempotent, and never overwrites collisions',
      () {
        expect(seedSql, contains(r'$collision_preflight$'));
        expect(seedSql, contains('[ESENLER_DEMO_V1_CATEGORY_COLLISION]'));
        expect(seedSql, contains('[ESENLER_DEMO_V1_PRODUCT_COLLISION]'));
        expect(seedSql, contains('[ESENLER_DEMO_V1_SHOP_COLLISION]'));
        expect(seedSql, contains('[ESENLER_DEMO_V1_LISTING_COLLISION]'));
        expect(
          RegExp(r'ON CONFLICT \(id\) DO NOTHING').allMatches(seedSql),
          hasLength(4),
        );
        expect(seedSql.toUpperCase(), isNot(contains('DO UPDATE')));
      },
    );

    test('seed never creates trust, Auth, legacy order, or analytics rows', () {
      for (final table in [
        'auth.users',
        'orders',
        'order_items',
        'reviews',
        'shop_ratings',
        'qr_sessions',
        'qr_session_items',
        'verified_transactions',
        'verified_transaction_items',
        'chat_messages',
        'notifications',
      ]) {
        expect(
          seedSql.toLowerCase(),
          isNot(contains('insert into $table')),
          reason: table,
        );
      }
    });

    test(
      'cleanup manifest contains every exact ID and dependency-safe guards',
      () {
        final cleanupManifest =
            manifest['cleanup_manifest'] as Map<String, dynamic>;
        expect(cleanupManifest['category_ids'], hasLength(4));
        expect(cleanupManifest['product_ids'], hasLength(20));
        expect(cleanupManifest['shop_ids'], hasLength(57));
        expect(cleanupManifest['shop_product_ids'], hasLength(285));

        for (final ids in cleanupManifest.values) {
          for (final id in ids as List<dynamic>) {
            expect(cleanupSql, contains(id as String));
          }
        }
        expect(
          cleanupSql,
          contains(
            '[ESENLER_DEMO_V1_CLEANUP_TRUST_OR_CUSTOMER_RELATION_FOUND]',
          ),
        );
        expect(
          cleanupSql,
          contains('[ESENLER_DEMO_V1_CLEANUP_EXPECTED_COUNT_MISMATCH]'),
        );
        expect(cleanupSql, contains('DELETE FROM public.shop_products'));
        expect(cleanupSql, contains('DELETE FROM public.shops'));
        expect(cleanupSql, contains('DELETE FROM public.products'));
        expect(cleanupSql, contains('DELETE FROM public.categories'));
        expect(
          RegExp(
            r'DELETE FROM public\.[a-z_]+\s+WHERE id = ANY',
            multiLine: true,
          ).allMatches(cleanupSql),
          hasLength(4),
        );
      },
    );

    test('artifacts contain no environment credential or project binding', () {
      final combined = [
        jsonEncode(manifest),
        seedSql,
        cleanupSql,
      ].join('\n').toLowerCase();
      for (final forbidden in [
        'tnipyxnvhgelwdpykyez',
        'mefhfvrgkwciubeajjeb',
        '.supabase.co',
        'service_role',
        'service-role',
        'supabase_anon_key',
        'supabase_publishable_key',
        'eyjhbgcio',
      ]) {
        expect(combined, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

List<Map<String, dynamic>> _records(Object? value) => (value! as List<dynamic>)
    .cast<Map<String, dynamic>>()
    .toList(growable: false);

double _distanceMeters(
  double fromLatitude,
  double fromLongitude,
  double toLatitude,
  double toLongitude,
) {
  const earthRadiusMeters = 6371000.0;
  final latitudeDelta = _radians(toLatitude - fromLatitude);
  final longitudeDelta = _radians(toLongitude - fromLongitude);
  final firstLatitude = _radians(fromLatitude);
  final secondLatitude = _radians(toLatitude);
  final haversine =
      math.pow(math.sin(latitudeDelta / 2), 2).toDouble() +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.pow(math.sin(longitudeDelta / 2), 2).toDouble();
  return 2 *
      earthRadiusMeters *
      math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
}

double _radians(double degrees) => degrees * math.pi / 180;
