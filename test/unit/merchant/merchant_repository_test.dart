import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/main_merchant_development.dart';

const user = UserEntity(
  id: 'user-a',
  email: 'esnaf@example.invalid',
  role: 'merchant',
);
final timestamp = DateTime.utc(2026, 9, 1);
final shop = ShopEntity(
  id: 'shop-a',
  ownerUserId: user.id,
  name: 'Mağaza',
  updatedAt: timestamp,
);
final access = MerchantAccess(user: user, shop: shop);
final listing = ShopProductEntity(
  id: 'listing-a',
  shopId: shop.id,
  productId: 'product-a',
  price: 10,
  updatedAt: timestamp,
);
const draft = MerchantListingDraft(
  productId: 'product-a',
  priceMinor: 1299,
  active: false,
  available: false,
  description: ' Açıklama ',
);
Map<String, dynamic> shopRow() => {
  'id': shop.id,
  'owner_user_id': user.id,
  'name': shop.name,
  'is_active': true,
  'updated_at': timestamp.toIso8601String(),
};
Map<String, dynamic> listingRow() => {
  'id': listing.id,
  'shop_id': shop.id,
  'product_id': 'product-a',
  'price': 12.99,
  'is_active': false,
  'is_available': false,
  'updated_at': timestamp.toIso8601String(),
};
http.Response json(Object? body, {int status = 200}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  late String? currentId;
  late String role;
  late bool activeShop;
  late List<http.Request> requests;
  late FutureOr<http.Response> Function(http.Request) operation;
  late SupabaseMerchantRepository repository;
  setUp(() {
    currentId = user.id;
    role = 'merchant';
    activeShop = true;
    requests = [];
    operation = (_) => json(null);
    final client = SupabaseClient(
      'https://merchant-tests.invalid',
      'local-test-key',
      httpClient: MockClient((request) async {
        requests.add(request);
        final table = request.url.pathSegments.last;
        if (request.method == 'GET' && table == 'profiles') {
          return http.Response(
            jsonEncode([
              {'id': user.id, 'email': user.email, 'role': role},
            ]),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.method == 'GET' && table == 'shops') {
          return http.Response(
            jsonEncode([
              {...shopRow(), 'is_active': activeShop},
            ]),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        final response = await operation(request);
        return http.Response(
          response.body,
          response.statusCode,
          headers: response.headers,
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    repository = SupabaseMerchantRepository(
      client: client,
      currentUserId: () => currentId,
    );
  });
  test('price uses decimal kuruş without float/locale ambiguity', () {
    for (final e in {
      '0': 0,
      '12,99': 1299,
      '12.9': 1290,
      ' 12,00 ': 1200,
    }.entries) {
      expect(MerchantListingDraft.parsePrice(e.key), e.value);
    }
    for (final invalid in [
      '-1',
      '1.234',
      '1,234.56',
      'NaN',
      'Infinity',
      '1e3',
      '',
      '1 000',
    ]) {
      expect(MerchantListingDraft.parsePrice(invalid), isNull);
    }
    expect(draft.toPayload()['price'], '12.99');
  });
  test(
    'local entrypoint rejects every remote target before client initialization',
    () {
      for (final url in [
        'https://example.supabase.co',
        'https://localhost.evil.invalid',
        '',
      ]) {
        expect(
          () => createMerchantLocalConfig(url: url, anonKey: 'key'),
          throwsA(isA<SupabaseConfigurationException>()),
        );
      }
    },
  );
  test('anonymous access performs no backend read', () async {
    currentId = null;
    expect((await repository.loadAccess()).getOrElse(() => access), isNull);
    expect(requests, isEmpty);
  });
  test('customer/admin role never gains a merchant workspace', () async {
    for (final value in ['customer', 'admin']) {
      role = value;
      final result = (await repository.loadAccess()).getOrElse(() => null)!;
      expect(result.hasRole, false);
      expect(result.shop, isNull);
      expect((await repository.saveListing(access, draft)).isLeft(), true);
      expect(requests.where((r) => r.method != 'GET'), isEmpty);
    }
  });
  test('suspended shop cannot write', () async {
    activeShop = false;
    expect((await repository.saveListing(access, draft)).isLeft(), true);
    expect(requests.where((r) => r.method != 'GET'), isEmpty);
  });
  test(
    'insert uses exact shop, decimal price and never upserts or touches master catalog',
    () async {
      operation = (request) {
        if (request.method == 'GET') {
          return json([
            {'id': 'product-a'},
          ]);
        }
        expect(request.method, 'POST');
        expect(request.url.pathSegments.last, 'shop_products');
        expect(request.headers['prefer'], isNot(contains('resolution=merge')));
        expect(jsonDecode(request.body), {
          'shop_id': shop.id,
          'product_id': 'product-a',
          'price': '12.99',
          'description': 'Açıklama',
          'is_active': false,
          'is_available': false,
        });
        return json(listingRow());
      };
      expect((await repository.saveListing(access, draft)).isRight(), true);
      expect(requests.where((r) => r.method == 'POST').length, 1);
    },
  );
  test(
    'update is shop scoped, optimistic and never rewrites identity/media',
    () async {
      operation = (request) {
        expect(request.method, 'PATCH');
        final query = request.url.queryParameters;
        expect(query['id'], 'eq.listing-a');
        expect(query['shop_id'], 'eq.shop-a');
        expect(query['product_id'], 'eq.product-a');
        expect(query['updated_at'], 'eq.${timestamp.toIso8601String()}');
        expect((jsonDecode(request.body) as Map).keys.toSet(), {
          'price',
          'description',
          'is_available',
          'is_active',
        });
        return request.method == 'GET'
            ? json([listingRow()])
            : json(listingRow());
      };
      expect(
        (await repository.saveListing(
          access,
          draft,
          existing: listing,
        )).isRight(),
        true,
      );
    },
  );
  test(
    'stale update reports conflict rather than success or retry write',
    () async {
      operation = (_) => json(null);
      final result = await repository.saveListing(
        access,
        draft,
        existing: listing,
      );
      expect(result.fold((e) => e, (_) => ''), contains('Kayıt değişmiş'));
      expect(requests.where((r) => r.method == 'PATCH').length, 1);
    },
  );
  test('foreign shop/product identity is rejected before mutation', () async {
    expect(
      (await repository.saveListing(
        access,
        draft,
        existing: listing.copyWith(shopId: 'other'),
      )).isLeft(),
      true,
    );
    expect(
      (await repository.saveListing(
        access,
        draft,
        existing: listing.copyWith(productId: 'other'),
      )).isLeft(),
      true,
    );
    expect(requests.where((r) => r.method != 'GET'), isEmpty);
  });
  test('session switch before write does not mutate the new account', () async {
    currentId = 'user-b';
    expect((await repository.saveListing(access, draft)).isLeft(), true);
    expect(requests, isEmpty);
  });
  test('late write result after logout is not shown as success', () async {
    operation = (request) {
      if (request.method == 'GET') {
        return json([
          {'id': 'product-a'},
        ]);
      }
      currentId = null;
      return json(listingRow());
    };
    final result = await repository.saveListing(access, draft);
    expect(result.fold((e) => e, (_) => ''), merchantSessionChanged);
  });
  test(
    'duplicate product returns safe error; does not expose response details',
    () async {
      operation = (request) => request.method == 'GET'
          ? json([
              {'id': 'product-a'},
            ])
          : json({
              'code': '23505',
              'message': 'secret internal constraint',
            }, status: 409);
      final result = await repository.saveListing(access, draft);
      expect(result.fold((e) => e, (_) => ''), contains('zaten var'));
      expect(result.fold((e) => e, (_) => ''), isNot(contains('secret')));
    },
  );
  test(
    'listing read includes unavailable/inactive records and stable pagination',
    () async {
      operation = (request) {
        final q = request.url.queryParameters;
        expect(q['shop_id'], 'eq.shop-a');
        expect(q.containsKey('is_active'), false);
        expect(q.containsKey('is_available'), false);
        expect(q['offset'], '$merchantPageSize');
        expect(q['limit'], '$merchantPageSize');
        expect(q['products.name'], r'ilike.%100\%\_%');
        return request.method == 'GET'
            ? json([listingRow()])
            : json(listingRow());
      };
      final items = (await repository.listings(
        access,
        page: 1,
        query: '100%_',
      )).getOrElse(() => []);
      expect(items.single.isActive, false);
      expect(items.single.isAvailable, false);
    },
  );
  test(
    'shop profile cannot change owner, role, activation or ratings',
    () async {
      operation = (request) {
        expect(request.method, 'PATCH');
        expect(request.url.queryParameters['owner_user_id'], 'eq.user-a');
        expect(request.url.queryParameters.containsKey('updated_at'), true);
        expect((jsonDecode(request.body) as Map).keys.toSet(), {
          'name',
          'description',
          'phone',
          'address',
          'opening_hours',
        });
        return json(shopRow());
      };
      expect(
        (await repository.saveShop(
          access,
          const MerchantShopDraft(name: 'Mağaza'),
        )).isRight(),
        true,
      );
    },
  );
}
