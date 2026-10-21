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
    await client.auth.setInitialSession(
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
      'product_submissions' => [],
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
        if (r.url.path == '/auth/v1/logout') {
          return http.Response('', 204, request: r);
        }
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
    'submissions' => media.submissions(access),
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

  Future<void> bounce(String kind) async {
    if (kind == 'renew') {
      await login(refresh: 1);
    } else if (kind == 'logout') {
      await client.auth.signOut(scope: SignOutScope.local);
      await login(refresh: 2);
    } else {
      // Queue both public SDK events before reading the live getter. S1's
      // restored value must not hide the intervening S2 event snapshot.
      await Future.wait([login(session: 's2'), login(refresh: 2)]);
    }
    await pumpEventQueue();
  }

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
    'submissions',
    'operations',
  ]) {
    for (final change in ['replacement', 'logout', 'renew']) {
      test(
        '$name fences $change event even when live identity returns',
        () async {
          handler = (r) async {
            final value = await normal(r);
            await bounce(change);
            return value;
          };
          final dynamic result = await call(name);
          if (change == 'renew') {
            expect(result.isRight(), true);
          } else {
            expect(result.fold((e) => e, (_) => null), merchantSessionChanged);
            expect(
              requests,
              hasLength(1),
              reason: 'No later authorization or write',
            );
          }
        },
      );
    }
  }
  for (final phase in ['prepare', 'storage', 'publish']) {
    for (final error in [false, true]) {
      test('upload $phase error=$error cannot revive after bounce', () async {
        var hit = false;
        handler = (r) async {
          final atPhase = switch (phase) {
            'prepare' => r.url.path.endsWith(
              'merchant_prepare_listing_image_v1',
            ),
            'storage' => r.url.path.contains('/storage/'),
            _ => r.url.path.endsWith('merchant_change_listing_images_v1'),
          };
          if (atPhase) {
            hit = true;
            await bounce('replacement');
            if (error) throw http.ClientException('synthetic late error');
          }
          return normal(r);
        };
        final result = await media.upload(access, listing.id, bytes);
        expect(hit, true);
        expect(result.fold((e) => e, (_) => null), merchantSessionChanged);
        expect(
          requests.length,
          ['prepare', 'storage', 'publish'].indexOf(phase) + 1,
        );
        expect(
          requests
              .where((r) => r.url.path.contains('/rest/'))
              .any((r) => r.body.contains('retire')),
          false,
        );
      });
    }
  }
  for (final changed in [true, false]) {
    test(
      'catalog absent capability fallback respects event history $changed',
      () async {
        handler = (r) async {
          if (r.url.path.endsWith('merchant_catalog_search_v1')) {
            if (changed) await bounce('replacement');
            return json(r, {
              'code': 'PGRST202',
              'message': 'Missing',
            }, status: 404);
          }
          return normal(r);
        };
        final result = await merchants.searchCatalog(access, query: '');
        expect(result.isRight(), !changed);
        expect(
          requests.where((r) => r.url.path.endsWith('/products')).length,
          changed ? 0 : 1,
        );
      },
    );
  }
  for (final changed in [true, false]) {
    test(
      'signed photo failure $changed never continues into another intent',
      () async {
        handler = (r) async {
          if (r.url.path.endsWith('merchant_listing_media_v1')) {
            return json(r, {
              'images': [
                for (var i = 0; i < 2; i++)
                  {
                    'id': 'image-$i',
                    'object_path': 'shops/s/l/$i.png',
                    'publication_state': 'published',
                    'is_primary': i == 0,
                    'sort_order': i,
                  },
              ],
              'max_photos': 5,
              'max_bytes': 100,
            });
          }
          if (r.url.path.contains('/storage/')) {
            if (changed) await bounce('replacement');
            throw http.ClientException('synthetic unavailable image');
          }
          return normal(r);
        };
        final result = await media.media(access, listing.id);
        expect(result.isRight(), !changed);
        expect(
          requests.where((r) => r.url.path.contains('/storage/')).length,
          changed ? 1 : 2,
        );
      },
    );
  }
}
