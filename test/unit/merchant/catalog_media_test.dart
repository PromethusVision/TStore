import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/data/supabase_catalog_media_repository.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/shop/data/repositories/supabase_listing_hero_media_repository.dart';
import '../shop/listing_hero_test.dart' show seller;

const access = MerchantAccess(
  user: UserEntity(id: 'user', email: 'a@example.invalid', role: 'merchant'),
  shop: ShopEntity(id: 'shop', ownerUserId: 'user', name: 'A'),
);
http.Response response(
  Object value, {
  int status = 200,
  http.Request? request,
}) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json'},
  request:
      request ??
      http.Request(
        'POST',
        Uri.parse('http://localhost:54321/rest/v1/rpc/local_fixture'),
      ),
);
void main() {
  test(
    'installed catalog gate is used; permission errors never fall back',
    () async {
      for (final denied in [false, true]) {
        final requests = <http.Request>[];
        final client = SupabaseClient(
          'http://localhost:54321',
          'local-fixture-key',
          httpClient: MockClient((r) async {
            requests.add(r);
            if (r.url.path.endsWith('profiles')) {
              return response([
                {
                  'id': 'user',
                  'email': 'a@example.invalid',
                  'role': 'merchant',
                },
              ], request: r);
            }
            if (r.url.path.endsWith('shops')) {
              return response([
                {
                  'id': 'shop',
                  'owner_user_id': 'user',
                  'name': 'A',
                  'is_active': true,
                },
              ], request: r);
            }
            if (denied) {
              return response(
                {'code': '42501', 'message': 'denied'},
                status: 403,
                request: r,
              );
            }
            return response([
              {
                'id': 'p',
                'name': 'P',
                'price': 8,
                'category_id': 'c',
                'stock': 1,
                'images': [],
              },
            ], request: r);
          }),
        );
        final result = await SupabaseMerchantRepository(
          client: client,
          currentUserId: () => 'user',
          currentSessionKey: () => 'synthetic-session',
        ).searchCatalog(access, query: 'P', page: 2);
        expect(result.isLeft(), denied);
        expect(requests.last.url.path, endsWith('merchant_catalog_search_v1'));
        expect(jsonDecode(requests.last.body)['p_offset'], 60);
        expect(
          requests.where((r) => r.url.path.endsWith('/products')),
          isEmpty,
        );
        await client.dispose();
      }
    },
  );
  test('GTIN check digits and canonical padding', () {
    expect(normalizeGtin('4006381333931'), '04006381333931');
    expect(normalizeGtin('04006381333931'), '04006381333931');
    expect(normalizeGtin('96385074'), '00000096385074');
    expect(normalizeGtin('036000291452'), '00036000291452');
    expect(normalizeGtin(''), isNull);
    for (final g in [
      '4006381333932',
      '00000000',
      '123',
      '4006381333931.png',
      'abcd',
      '400638133393 1',
    ]) {
      expect(() => normalizeGtin(g), throwsFormatException);
    }
  });
  test(
    'candidate owns no central price, stock or media; identity type is explicit',
    () {
      const draft = ProductSubmissionDraft(
        name: ' Kalem ',
        categoryId: 'category',
        model: 'Model',
        variant: 'Blue',
        uniqueToShop: true,
      );
      expect(draft.error, isNull);
      expect(draft.toJson()['product_type'], 'merchant_unique_product');
      expect(draft.toJson()['name'], 'Kalem');
      expect(draft.toJson().keys, isNot(contains('price')));
      expect(draft.toJson().keys, isNot(contains('stock')));
      expect(
        const ProductSubmissionDraft(name: '', categoryId: 'x').error,
        isNotNull,
      );
      expect(
        const ProductSubmissionDraft(name: 'X', categoryId: '').error,
        isNotNull,
      );
    },
  );
  test('truthful submission status labels', () {
    for (final pair in [
      ('pending', 'İnceleniyor'),
      ('approved', 'Onaylandı'),
      ('rejected', 'Reddedildi'),
    ]) {
      expect(
        ProductSubmission(id: 'id', name: 'X', status: pair.$1).statusLabel,
        pair.$2,
      );
    }
  });
  test('upload sniffs supported signatures; unsafe bytes rejected', () {
    expect(
      listingImageMime(Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10])),
      'image/png',
    );
    expect(listingImageMime(Uint8List.fromList([255, 216, 255])), 'image/jpeg');
    expect(
      listingImageMime(Uint8List.fromList('RIFF0000WEBP'.codeUnits)),
      'image/webp',
    );
    expect(listingImageMime(Uint8List.fromList('<script>'.codeUnits)), isNull);
  });
  test('foreign or changed session cannot send client requests', () async {
    var calls = 0;
    final client = SupabaseClient(
      'http://localhost:54321',
      'local-placeholder',
      httpClient: MockClient((r) async {
        calls++;
        return response([]);
      }),
    );
    final repo = SupabaseCatalogMediaRepository(
      client,
      currentUserId: () => 'other',
      currentSessionKey: () => 'synthetic-session',
    );
    expect((await repo.categories(access)).isLeft(), true);
    expect(calls, 0);
    await client.dispose();
  });
  test('session change during lookup discards returned private data', () async {
    var id = 'user';
    final client = SupabaseClient(
      'http://localhost:54321',
      'local-placeholder',
      httpClient: MockClient((r) async {
        id = 'other';
        return response({'exact': false, 'products': []});
      }),
    );
    final repo = SupabaseCatalogMediaRepository(
      client,
      currentUserId: () => id,
      currentSessionKey: () => 'synthetic-session',
    );
    expect(
      await repo.lookup(access, 'name', ''),
      const Left<String, CatalogLookup>(merchantSessionChanged),
    );
    await client.dispose();
  });
  test(
    'submission payload binds exact shop and idempotency key with pending result',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'http://localhost:54321',
        'local-placeholder',
        httpClient: MockClient((r) async {
          requests.add(r);
          return response({
            'submission': {'id': 's', 'name': 'X', 'status': 'pending'},
          });
        }),
      );
      final repo = SupabaseCatalogMediaRepository(
        client,
        currentUserId: () => 'user',
        currentSessionKey: () => 'synthetic-session',
      );
      final result = await repo.submit(
        access,
        'request',
        const ProductSubmissionDraft(name: 'X', categoryId: 'c'),
      );
      expect(result.fold((_) => null, (v) => v.submission?.status), 'pending');
      final body = jsonDecode(requests.single.body);
      expect(body['p_shop_id'], 'shop');
      expect(body['p_request_id'], 'request');
      expect(body['p_draft'].containsKey('status'), false);
      expect(body['p_draft'].containsKey('price'), false);
      await client.dispose();
    },
  );
  test('managed retired-only listing never revives legacy URLs', () async {
    final client = SupabaseClient(
      'http://localhost:54321',
      'local-placeholder',
      httpClient: MockClient(
        (r) async => response([
          {'listing_id': 'a', 'managed': true, 'images': []},
        ]),
      ),
    );
    expect(
      await SupabaseListingHeroMediaRepository(client).photos([
        seller('a', 1, images: ['https://example.invalid/old.png']),
      ]),
      isEmpty,
    );
    await client.dispose();
  });
  test(
    'batch signing preserves primary/other/next seller order and skips invalid URLs',
    () async {
      final client = SupabaseClient(
        'http://localhost:54321',
        'local-placeholder',
        httpClient: MockClient((r) async {
          if (r.url.path.contains('/rest/v1/')) {
            return response([
              {
                'listing_id': 'a',
                'managed': true,
                'images': [
                  {'bucket_id': 'listing-media', 'object_path': 'primary'},
                  {'bucket_id': 'listing-media', 'object_path': 'other'},
                ],
              },
              {
                'listing_id': 'b',
                'managed': true,
                'images': [
                  {'bucket_id': 'listing-media', 'object_path': 'next'},
                ],
              },
            ]);
          }
          expect(jsonDecode(r.body)['paths'], ['primary', 'other', 'next']);
          return response([
            {
              'path': 'next',
              'signedURL': '/object/sign/next?token=local-fixture',
            },
            {'path': 'other', 'signedURL': null},
            {
              'path': 'primary',
              'signedURL': '/object/sign/primary?token=local-fixture',
            },
          ]);
        }),
      );
      final photos = await SupabaseListingHeroMediaRepository(
        client,
      ).photos([seller('a', 1), seller('b', 2)]);
      expect(photos.map((p) => p.listingId), ['a', 'b']);
      expect(photos.first.source, contains('/primary?'));
      await client.dispose();
    },
  );
  test(
    'missing migration preserves legacy; network/auth errors do not',
    () async {
      for (final code in ['PGRST202', '42501']) {
        final client = SupabaseClient(
          'http://localhost:54321',
          'local-placeholder',
          httpClient: MockClient(
            (r) async =>
                response({'code': code, 'message': 'fixture'}, status: 404),
          ),
        );
        final call = SupabaseListingHeroMediaRepository(client).photos([
          seller('a', 1, images: ['https://example.invalid/old.png']),
        ]);
        if (code == 'PGRST202') {
          expect((await call).single.listingId, 'a');
        } else {
          await expectLater(call, throwsA(isA<PostgrestException>()));
        }
        await client.dispose();
      }
    },
  );
}
