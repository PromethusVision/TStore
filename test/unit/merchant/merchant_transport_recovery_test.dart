import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/data/supabase_catalog_media_repository.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'merchant_repository_test.dart'
    show access, draft, listing, shopRow, listingRow, user;

void main() {
  late SupabaseClient client;
  late SupabaseMerchantRepository merchants;
  late SupabaseCatalogMediaRepository media;
  late SupabaseMerchantOperationsRepository operations;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) handler;
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> login({String? session = 's1', int refresh = 0}) async {
    await client.auth.recoverSession(
      jsonEncode({
        'access_token':
            '${segment({'alg': 'none'})}.${segment({'sub': user.id, if (session != null) 'session_id': session, 'nonce': refresh, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
        'token_type': 'bearer',
        'refresh_token': 'synthetic-only',
        'user': {
          'id': user.id,
          'email': user.email,
          'app_metadata': {},
          'user_metadata': {},
          'aud': 'authenticated',
          'created_at': '2026-01-01T00:00:00Z',
        },
      }),
    );
  }

  http.Response json(http.Request r, Object? value, {int status = 200}) =>
      http.Response(
        jsonEncode(value),
        status,
        request: r,
        headers: {'content-type': 'application/json'},
      );
  Future<http.Response> normal(http.Request r) async {
    if (r.url.path.contains('/storage/')) {
      return json(r, {'Key': 'listing-media/shops/s/l/image.png'});
    }
    final table = r.url.pathSegments.last;
    return json(r, switch (table) {
      'profiles' => [
        {'id': user.id, 'email': user.email, 'role': 'merchant'},
      ],
      'shops' => r.method == 'GET' ? [shopRow()] : shopRow(),
      'shop_products' => r.method == 'GET' ? [listingRow()] : listingRow(),
      'products' => [
        {
          'id': 'product-a',
          'name': 'Product',
          'price': 1,
          'category_id': 'category',
          'stock': 0,
          'images': [],
        },
      ],
      'merchant_catalog_search_v1' => [],
      'merchant_catalog_categories_v1' => [],
      'merchant_catalog_lookup_v1' => {'exact': false, 'products': []},
      'merchant_operations_read_v1' => {
        'pending_submissions': 0,
        'approved_submissions': 0,
        'rejected_submissions': 0,
        'pending_listings': 0,
        'uploads': [],
      },
      'merchant_prepare_listing_image_v1' => {
        'id': 'image',
        'bucket_id': 'listing-media',
        'object_path': 'shops/s/l/image.png',
      },
      'merchant_listing_media_v1' => {
        'images': [],
        'max_photos': 5,
        'max_bytes': 100,
      },
      'merchant_submit_product_v1' => {
        'submission': {'id': 'request', 'name': 'X', 'status': 'pending'},
      },
      _ => null,
    });
  }

  setUp(() async {
    requests = [];
    handler = normal;
    client = SupabaseClient(
      'http://localhost:54321',
      'synthetic-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((r) async {
        requests.add(r);
        return handler(r);
      }),
    );
    await login();
    merchants = SupabaseMerchantRepository(client: client);
    media = SupabaseCatalogMediaRepository(client);
    operations = SupabaseMerchantOperationsRepository(client);
  });
  tearDown(() => client.dispose());
  final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);

  Future<dynamic> call(String name) => switch (name) {
    'access' => merchants.loadAccess(),
    'listings' => merchants.listings(access),
    'catalog' => merchants.searchCatalog(access, query: ''),
    'saveListing' => merchants.saveListing(access, draft, existing: listing),
    'saveShop' => merchants.saveShop(
      access,
      const MerchantShopDraft(name: 'New'),
    ),
    'exactListing' => merchants.readListing(access, 'product-a'),
    'categories' => media.categories(access),
    'lookup' => media.lookup(access, 'X', ''),
    'media' => media.media(access, listing.id),
    'upload' => media.upload(access, listing.id, bytes),
    'changeMedia' => media.changeMedia(
      access,
      listing.id,
      'retire',
      imageId: 'image',
    ),
    'submit' => media.submit(
      access,
      'request',
      const ProductSubmissionDraft(name: 'X', categoryId: 'category'),
    ),
    _ => operations.read(access),
  };

  for (final name in [
    'access',
    'listings',
    'catalog',
    'saveListing',
    'saveShop',
    'exactListing',
    'categories',
    'lookup',
    'media',
    'upload',
    'changeMedia',
    'submit',
    'operations',
  ]) {
    test(
      '$name rejects same-account replacement session before next step',
      () async {
        handler = (r) async {
          final value = await normal(r);
          await login(session: 's2');
          return value;
        };
        final dynamic result = await call(name);
        expect(result.fold((e) => e, (_) => null), merchantSessionChanged);
        expect(requests, hasLength(1));
      },
    );
    test('$name permits token refresh within the same Auth session', () async {
      handler = (r) async {
        final value = await normal(r);
        await login(refresh: 1);
        return value;
      };
      final dynamic result = await call(name);
      expect(result.isRight(), true);
    });
    test('$name rejects missing session provenance without HTTP', () async {
      await login(session: null);
      final dynamic result = await call(name);
      expect(result.isLeft(), true);
      expect(requests, isEmpty);
    });
  }
  test(
    'missing catalog RPC response from old session never triggers legacy fallback',
    () async {
      handler = (r) async {
        if (r.url.path.endsWith('merchant_catalog_search_v1')) {
          await login(session: 's2');
          return json(r, {
            'code': 'PGRST202',
            'message': 'Missing',
          }, status: 404);
        }
        return normal(r);
      };
      expect((await merchants.searchCatalog(access, query: '')).isLeft(), true);
      expect(requests.where((r) => r.url.path.endsWith('/products')), isEmpty);
    },
  );
  for (final phase in ['prepare', 'storage', 'publish']) {
    test(
      'lost $phase acknowledgement never automatically retires media',
      () async {
        handler = (r) async {
          if ((phase == 'prepare' &&
                  r.url.path.endsWith('merchant_prepare_listing_image_v1')) ||
              (phase == 'storage' && r.url.path.contains('/storage/')) ||
              (phase == 'publish' &&
                  r.url.path.endsWith('merchant_change_listing_images_v1'))) {
            throw http.ClientException('synthetic lost acknowledgement');
          }
          return normal(r);
        };
        expect((await media.upload(access, listing.id, bytes)).isLeft(), true);
        final changes = requests.where(
          (r) => r.url.path.endsWith('merchant_change_listing_images_v1'),
        );
        expect(
          requests.any(
            (r) => phase == 'prepare'
                ? r.url.path.endsWith('merchant_prepare_listing_image_v1')
                : phase == 'storage'
                ? r.url.path.contains('/storage/')
                : r.url.path.endsWith('merchant_change_listing_images_v1'),
          ),
          true,
        );
        expect(
          changes.any((r) => jsonDecode(r.body)['p_action'] == 'retire'),
          false,
        );
        expect(
          requests.where(
            (r) => r.url.path.endsWith('merchant_prepare_listing_image_v1'),
          ),
          hasLength(1),
        );
      },
    );
  }
  test(
    'session replacement during Storage success prevents publication and cleanup',
    () async {
      handler = (r) async {
        if (r.url.path.contains('/storage/')) await login(session: 's2');
        return normal(r);
      };
      expect(
        (await media.upload(
          access,
          listing.id,
          bytes,
        )).fold((e) => e, (_) => null),
        merchantSessionChanged,
      );
      expect(
        requests.where(
          (r) => r.url.path.endsWith('merchant_change_listing_images_v1'),
        ),
        isEmpty,
      );
    },
  );
  test(
    'session replacement during signing prevents next private URL request',
    () async {
      handler = (r) async {
        if (r.url.path.endsWith('merchant_listing_media_v1')) {
          return json(r, {
            'max_photos': 5,
            'max_bytes': 100,
            'images': [
              for (var i = 0; i < 2; i++)
                {
                  'id': '$i',
                  'object_path': 'image$i',
                  'publication_state': 'published',
                  'is_primary': i == 0,
                  'sort_order': i,
                },
            ],
          });
        }
        await login(session: 's2');
        return json(r, {'signedURL': '/object/sign/image'});
      };
      expect((await media.media(access, listing.id)).isLeft(), true);
      expect(requests, hasLength(2));
    },
  );
  test(
    'access read deadline prevents late profile response from starting shop read',
    () async {
      merchants = SupabaseMerchantRepository(
        client: client,
        readTimeout: const Duration(milliseconds: 20),
      );
      final gate = Completer<http.Response>();
      handler = (_) => gate.future;
      expect(
        (await merchants.loadAccess()).fold((e) => e, (_) => null),
        merchantReadTimeout,
      );
      gate.complete(await normal(requests.single));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(requests, hasLength(1));
    },
  );
  test(
    'media read deadline prevents late metadata from starting signing',
    () async {
      media = SupabaseCatalogMediaRepository(
        client,
        readTimeout: const Duration(milliseconds: 20),
      );
      final gate = Completer<http.Response>();
      handler = (_) => gate.future;
      expect((await media.media(access, listing.id)).isLeft(), true);
      gate.complete(
        json(requests.single, {
          'images': [
            {
              'id': 'i',
              'object_path': 'image',
              'publication_state': 'published',
              'is_primary': true,
              'sort_order': 0,
            },
          ],
          'max_photos': 5,
          'max_bytes': 100,
        }),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(requests, hasLength(1));
    },
  );
  test(
    'read deadline never converts a pending listing write into retry permission',
    () async {
      merchants = SupabaseMerchantRepository(
        client: client,
        readTimeout: const Duration(milliseconds: 10),
      );
      final gate = Completer<http.Response>();
      handler = (r) => r.method == 'PATCH' ? gate.future : normal(r);
      var completed = false;
      final write = merchants.saveListing(access, draft, existing: listing)
        ..then((_) => completed = true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(completed, false);
      final request = requests.singleWhere((r) => r.method == 'PATCH');
      gate.complete(await normal(request));
      expect((await write).isRight(), true);
    },
  );
  test(
    'timed-out product preflight cannot insert after its late response',
    () async {
      merchants = SupabaseMerchantRepository(
        client: client,
        readTimeout: const Duration(milliseconds: 20),
      );
      final gate = Completer<http.Response>();
      handler = (r) =>
          r.url.path.endsWith('/products') ? gate.future : normal(r);
      expect(
        (await merchants.saveListing(
          access,
          draft,
        )).fold((e) => e, (_) => null),
        merchantReadTimeout,
      );
      gate.complete(await normal(requests.last));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        requests.any((r) => r.method == 'POST' || r.method == 'PATCH'),
        false,
      );
    },
  );
  test(
    'exact listing recovery uses shop plus product filters and rejects foreign rows',
    () async {
      handler = (r) async => r.url.path.endsWith('shop_products')
          ? json(r, [
              {...listingRow(), 'shop_id': 'other'},
            ])
          : normal(r);
      expect((await merchants.readListing(access, 'product-a')).isLeft(), true);
      expect(
        requests.last.url.queryParameters['shop_id'],
        'eq.${access.shop!.id}',
      );
      expect(requests.last.url.queryParameters['product_id'], 'eq.product-a');
      expect(requests.every((r) => r.method == 'GET'), true);
    },
  );
}
