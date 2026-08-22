import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/main_production.dart' as production_entrypoint;

const _liveOptIn = 'RUN_PRODUCTION_DEMO_FUNCTIONAL_SMOKE';
const _runLive = bool.fromEnvironment(_liveOptIn);
const _expectedProjectRef = 'mefhfvrgkwciubeajjeb';
const _expectedUrl = 'https://$_expectedProjectRef.supabase.co';
const _productionUrl = String.fromEnvironment(
  SupabaseConfig.productionUrlDartDefine,
);
const _productionAnonKey = String.fromEnvironment(
  SupabaseConfig.productionAnonKeyDartDefine,
);
const _seedName = 'esenler_demo_v1';

void main() {
  group('Production demo functional smoke safety gate', () {
    test('requires explicit opt-in and exact Production identity', () {
      expect(
        () => _requireProductionConfig(
          enabled: false,
          supabaseUrl: _expectedUrl,
          supabaseAnonKey: 'sb_publishable_readonly_contract_key',
        ),
        throwsA(isA<StateError>()),
      );

      for (final url in const [
        'https://${SupabaseConfig.developmentProjectRef}.supabase.co',
        'https://abcdefghijklmnopqrst.supabase.co',
      ]) {
        expect(
          () => _requireProductionConfig(
            enabled: true,
            supabaseUrl: url,
            supabaseAnonKey: 'sb_publishable_readonly_contract_key',
          ),
          throwsA(
            anyOf(isA<SupabaseConfigurationException>(), isA<StateError>()),
          ),
          reason: url,
        );
      }
    });

    test('uses the Production entrypoint without Development fallback', () {
      final config = _requireProductionConfig(
        enabled: true,
        supabaseUrl: _expectedUrl,
        supabaseAnonKey: 'sb_publishable_readonly_contract_key',
      );

      expect(production_entrypoint.appEnvironment, AppEnvironment.production);
      expect(config.environment, AppEnvironment.production);
      expect(config.supabaseUrl, _expectedUrl);
      expect(
        config.supabaseUrl,
        isNot(contains(SupabaseConfig.developmentProjectRef)),
      );
    });

    test('harness source contains no remote mutation operation', () {
      final source = File(
        'test/live/production_demo_functional_smoke_test.dart',
      ).readAsStringSync();
      for (final verb in const [
        'insert',
        'update',
        'upsert',
        'delete',
        'rpc',
        'invoke',
        'signUp',
        'signIn',
        'signInWithPassword',
        'signInWithOAuth',
        'signOut',
        'resend',
        'verifyOTP',
        'updateUser',
        'resetPasswordForEmail',
        'upload',
        'uploadBinary',
        'updateBinary',
        'move',
        'copy',
        'remove',
      ]) {
        expect(source, isNot(contains('.$verb(')), reason: verb);
      }
    });
  });

  test(
    'anonymous Production client sees the complete Esenler demo customer flow',
    () async {
      final config = _requireProductionConfig(
        enabled: _runLive,
        supabaseUrl: _productionUrl,
        supabaseAnonKey: _productionAnonKey,
      );
      final client = SupabaseClient(
        config.supabaseUrl,
        config.supabaseAnonKey,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.pkce),
      );
      addTearDown(client.dispose);

      expect(client.auth.currentSession, isNull);
      expect(client.auth.currentUser, isNull);

      final manifest = _readManifest();
      final expectedCategories = _manifestRows(manifest, 'categories');
      final expectedProducts = _manifestRows(manifest, 'products');
      final expectedShops = _manifestRows(manifest, 'shops');
      final expectedListings = _manifestRows(manifest, 'shop_products');

      final categories = _rows(
        await client
            .from(SupabaseTables.categories)
            .select('id,name,sort_order,parent_id,is_active')
            .eq('is_active', true)
            .order('sort_order', ascending: true),
      );
      final products = _rows(
        await client
            .from(SupabaseTables.products)
            .select(
              'id,name,description,price,category_id,stock,images,thumbnail,'
              'is_featured,is_active,attributes,categories(name)',
            )
            .eq('is_active', true)
            .order('id', ascending: true),
      );
      final shops = _rows(
        await client
            .from(SupabaseTables.shops)
            .select(
              'id,name,description,address,latitude,longitude,owner_user_id,'
              'is_active',
            )
            .eq('is_active', true)
            .order('id', ascending: true),
      );
      final listings = _rows(
        await client
            .from(SupabaseTables.shopProducts)
            .select(
              'id,shop_id,product_id,price,is_available,is_active,description,'
              'images,products(id,name,category_id,is_active),'
              'shops(id,name,address,latitude,longitude,is_active,owner_user_id)',
            )
            .eq('is_active', true)
            .eq('is_available', true)
            .order('id', ascending: true),
      );

      expect(categories, hasLength(4));
      expect(products, hasLength(20));
      expect(shops, hasLength(57));
      expect(listings, hasLength(285));

      _expectCategories(categories, expectedCategories);
      _expectProducts(products, expectedProducts);
      _expectShops(shops, expectedShops);
      _expectListings(
        listings,
        expectedListings: expectedListings,
        expectedProducts: expectedProducts,
        expectedShops: expectedShops,
      );
      _expectCategoryFlow(products, expectedCategories);
      _expectSellerAndShopFlow(listings);
      _expectNearbyFlow(shops);
      await _expectSearchFlow(
        client,
        expectedProducts: expectedProducts,
        expectedCategories: expectedCategories,
      );
    },
    skip: _runLive
        ? false
        : 'Production demo functional smoke requires $_liveOptIn=true.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

void _expectCategories(
  List<Map<String, dynamic>> actual,
  List<Map<String, dynamic>> expected,
) {
  expect(_ids(actual), unorderedEquals(_ids(expected)));
  expect(
    actual.map((row) => row['name']),
    orderedEquals(const ['Kırtasiye', 'Elektronik', 'Gıda', 'Ayakkabı']),
  );
  for (final row in actual) {
    final expectedRow = expected.singleWhere((item) => item['id'] == row['id']);
    expect(row['name'], expectedRow['name']);
    expect(row['sort_order'], expectedRow['sort_order']);
    expect(row['parent_id'], isNull);
    expect(row['is_active'], isTrue);
  }
}

void _expectProducts(
  List<Map<String, dynamic>> actual,
  List<Map<String, dynamic>> expected,
) {
  expect(_ids(actual), unorderedEquals(_ids(expected)));
  for (final row in actual) {
    final expectedRow = expected.singleWhere((item) => item['id'] == row['id']);
    expect(row['name'], expectedRow['name']);
    expect(row['category_id'], expectedRow['category_id']);
    expect(_asDouble(row['price']), _asDouble(expectedRow['price']));
    expect(row['stock'], expectedRow['stock']);
    expect(row['is_active'], isTrue);
    expect(row['is_featured'], isTrue);
    expect(row['images'], isEmpty);
    expect(row['thumbnail'], isNull);
    expect(row['attributes'], containsPair('demo_seed', _seedName));
    expect(row['attributes'], containsPair('demo', true));
    expect(_relation(row, 'categories')['name'], expectedRow['category_name']);
  }
}

void _expectShops(
  List<Map<String, dynamic>> actual,
  List<Map<String, dynamic>> expected,
) {
  expect(_ids(actual), unorderedEquals(_ids(expected)));
  expect(actual.where((row) => row['owner_user_id'] == null), hasLength(57));
  expect(
    actual.where((row) => '${row['name']}'.startsWith('[DEMO] ')),
    hasLength(57),
  );

  final coordinateKeys = <String>{};
  for (final row in actual) {
    final expectedRow = expected.singleWhere((item) => item['id'] == row['id']);
    expect(row['name'], expectedRow['name']);
    expect(row['address'], expectedRow['address']);
    expect(row['owner_user_id'], isNull);
    expect(row['is_active'], isTrue);
    final latitude = _asDouble(row['latitude']);
    final longitude = _asDouble(row['longitude']);
    expect(latitude, closeTo(_asDouble(expectedRow['latitude']), 0.00000001));
    expect(longitude, closeTo(_asDouble(expectedRow['longitude']), 0.00000001));
    expect(
      CustomerProximityHelper.hasValidCoordinates(latitude, longitude),
      isTrue,
    );
    coordinateKeys.add('$latitude,$longitude');
  }
  expect(coordinateKeys, hasLength(57));
}

void _expectListings(
  List<Map<String, dynamic>> actual, {
  required List<Map<String, dynamic>> expectedListings,
  required List<Map<String, dynamic>> expectedProducts,
  required List<Map<String, dynamic>> expectedShops,
}) {
  expect(_ids(actual), unorderedEquals(_ids(expectedListings)));
  expect(
    actual.map((row) => '${row['shop_id']}:${row['product_id']}').toSet(),
    hasLength(285),
  );

  for (final row in actual) {
    final expected = expectedListings.singleWhere(
      (item) => item['id'] == row['id'],
    );
    expect(row['shop_id'], expected['shop_id']);
    expect(row['product_id'], expected['product_id']);
    expect(_asDouble(row['price']), _asDouble(expected['price']));
    expect(row['is_active'], isTrue);
    expect(row['is_available'], isTrue);
    expect(row['images'], isEmpty);

    final product = _relation(row, 'products');
    final shop = _relation(row, 'shops');
    expect(product['id'], row['product_id']);
    expect(shop['id'], row['shop_id']);
    expect(product['is_active'], isTrue);
    expect(shop['is_active'], isTrue);
    expect(shop['owner_user_id'], isNull);

    final expectedProduct = expectedProducts.singleWhere(
      (item) => item['id'] == row['product_id'],
    );
    final expectedShop = expectedShops.singleWhere(
      (item) => item['id'] == row['shop_id'],
    );
    expect(product['name'], expectedProduct['name']);
    expect(product['category_id'], expectedProduct['category_id']);
    expect(shop['name'], expectedShop['name']);
    expect(shop['address'], expectedShop['address']);
  }
}

void _expectCategoryFlow(
  List<Map<String, dynamic>> products,
  List<Map<String, dynamic>> categories,
) {
  for (final category in categories) {
    final categoryProducts = products
        .where((product) => product['category_id'] == category['id'])
        .toList(growable: false);
    expect(categoryProducts, hasLength(5), reason: '${category['name']}');
    expect(
      categoryProducts.every(
        (product) =>
            _relation(product, 'categories')['name'] == category['name'],
      ),
      isTrue,
      reason: '${category['name']} category leakage',
    );
  }
}

void _expectSellerAndShopFlow(List<Map<String, dynamic>> listings) {
  final byProduct = <String, List<Map<String, dynamic>>>{};
  final byShop = <String, List<Map<String, dynamic>>>{};
  for (final listing in listings) {
    byProduct.putIfAbsent('${listing['product_id']}', () => []).add(listing);
    byShop.putIfAbsent('${listing['shop_id']}', () => []).add(listing);
  }

  expect(byProduct, hasLength(20));
  for (final productListings in byProduct.values) {
    expect(productListings.length, inInclusiveRange(14, 15));
    expect(
      productListings.map((row) => _asDouble(row['price'])).toSet().length,
      greaterThan(1),
    );
    expect(
      productListings.map((row) => row['shop_id']).toSet(),
      hasLength(productListings.length),
    );
  }

  expect(byShop, hasLength(57));
  for (final shopListings in byShop.values) {
    expect(shopListings, hasLength(5));
    final categoryIds = shopListings
        .map((row) => _relation(row, 'products')['category_id'])
        .toSet();
    expect(categoryIds, hasLength(1));
  }
}

void _expectNearbyFlow(List<Map<String, dynamic>> shops) {
  final reference = shops.first;
  final from = CustomerCoordinates(
    latitude: _asDouble(reference['latitude']),
    longitude: _asDouble(reference['longitude']),
  );
  final distances =
      shops
          .map(
            (shop) => (
              id: '${shop['id']}',
              distance: CustomerProximityHelper.distanceInMeters(
                from: from,
                latitude: _asDouble(shop['latitude']),
                longitude: _asDouble(shop['longitude']),
              )!,
            ),
          )
          .toList()
        ..sort((first, second) {
          final distanceOrder = first.distance.compareTo(second.distance);
          return distanceOrder != 0
              ? distanceOrder
              : first.id.compareTo(second.id);
        });

  expect(distances, hasLength(57));
  expect(distances.first.distance, closeTo(0, 0.001));
  for (var index = 1; index < distances.length; index++) {
    expect(
      distances[index].distance,
      greaterThanOrEqualTo(distances[index - 1].distance),
    );
  }
}

Future<void> _expectSearchFlow(
  SupabaseClient client, {
  required List<Map<String, dynamic>> expectedProducts,
  required List<Map<String, dynamic>> expectedCategories,
}) async {
  final exactProduct = expectedProducts.first;
  final exactMatches = _rows(
    await client
        .from(SupabaseTables.products)
        .select('id,name,category_id')
        .eq('is_active', true)
        .eq('name', exactProduct['name']),
  );
  expect(exactMatches, hasLength(1));
  expect(exactMatches.single['id'], exactProduct['id']);

  const genericQuery = 'Defter';
  final expectedGenericIds = expectedProducts
      .where(
        (product) =>
            '${product['name']}'.contains(genericQuery) ||
            '${product['description']}'.contains(genericQuery),
      )
      .map((product) => '${product['id']}')
      .toSet();
  final genericMatches = _rows(
    await client
        .from(SupabaseTables.products)
        .select('id,name,category_id')
        .eq('is_active', true)
        .or('name.ilike.%$genericQuery%,description.ilike.%$genericQuery%'),
  );
  expect(_ids(genericMatches), unorderedEquals(expectedGenericIds));

  final electronics = expectedCategories.singleWhere(
    (category) => category['name'] == 'Elektronik',
  );
  final categoryMatches = _rows(
    await client
        .from(SupabaseTables.categories)
        .select('id,name')
        .eq('is_active', true)
        .eq('name', electronics['name']),
  );
  expect(categoryMatches.single['id'], electronics['id']);
  final categoryProducts = _rows(
    await client
        .from(SupabaseTables.products)
        .select('id,name,category_id')
        .eq('is_active', true)
        .eq('category_id', electronics['id']),
  );
  expect(categoryProducts, hasLength(5));

  final noResult = _rows(
    await client
        .from(SupabaseTables.products)
        .select('id')
        .eq('is_active', true)
        .or(
          'name.ilike.%w12d_no_such_product_9f4c%,'
          'description.ilike.%w12d_no_such_product_9f4c%',
        ),
  );
  expect(noResult, isEmpty);
}

Map<String, dynamic> _readManifest() {
  final decoded = jsonDecode(
    File('tool/demo_seed/esenler_demo_v1.json').readAsStringSync(),
  );
  return Map<String, dynamic>.from(decoded as Map);
}

List<Map<String, dynamic>> _manifestRows(
  Map<String, dynamic> manifest,
  String key,
) => (manifest[key] as List)
    .map((row) => Map<String, dynamic>.from(row as Map))
    .toList(growable: false);

List<Map<String, dynamic>> _rows(dynamic response) => (response as List)
    .map((row) => Map<String, dynamic>.from(row as Map))
    .toList(growable: false);

Set<String> _ids(List<Map<String, dynamic>> rows) =>
    rows.map((row) => '${row['id']}').toSet();

Map<String, dynamic> _relation(Map<String, dynamic> row, String key) =>
    Map<String, dynamic>.from(row[key] as Map);

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse('$value');
}

SupabaseConfig _requireProductionConfig({
  required bool enabled,
  required String supabaseUrl,
  required String supabaseAnonKey,
}) {
  if (!enabled) {
    throw StateError(
      'Production demo functional smoke requires explicit $_liveOptIn opt-in.',
    );
  }

  final config = production_entrypoint.createSupabaseConfig(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  final uri = Uri.parse(config.supabaseUrl);
  if (config.environment != AppEnvironment.production ||
      config.supabaseUrl != _expectedUrl ||
      uri.host != '$_expectedProjectRef.supabase.co' ||
      uri.host.contains(SupabaseConfig.developmentProjectRef)) {
    throw StateError(
      'Functional smoke is locked to canonical EsnaftaVar Production.',
    );
  }
  return config;
}
