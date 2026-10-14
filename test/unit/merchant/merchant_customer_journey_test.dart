import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_repository.dart';
import 'package:t_store/features/merchant/data/supabase_catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/data/repositories/supabase_listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';
import 'catalog_media_test.dart' show response;

T value<T>(Either<String, T> result) =>
    result.fold((e) => throw StateError(e), (v) => v);

void main() {
  test(
    'synthetic transport journey: catalog → listing → photo → new clients → Customer source',
    () async {
      // Stateful transport fixture, NOT a real Supabase/Storage acceptance test.
      const merchant = 'owner',
          shop = 'shop',
          product = 'product',
          listing = 'listing';
      const path = 'shops/shop/listing/v20261014000000/photo.png';
      final productRow = {
        'id': product,
        'name': 'Örnek ürün',
        'price': 8,
        'category_id': 'category',
        'stock': 0,
        'images': <String>[],
        'is_active': true,
      };
      final shopRow = {
        'id': shop,
        'owner_user_id': merchant,
        'name': 'Örnek mağaza',
        'is_active': true,
      };
      Map<String, dynamic>? saved;
      var uploaded = false, published = false, retired = false;
      final requests = <String>[];
      http.Response json(Object? body, http.Request r) =>
          response(body ?? {}, request: r);
      SupabaseClient connect() => SupabaseClient(
        'http://localhost:54321',
        'synthetic-client-key',
        httpClient: MockClient((r) async {
          final route = r.url.path;
          requests.add('${r.method} $route');
          if (route.endsWith('/profiles')) {
            return json([
              {
                'id': merchant,
                'email': 'esnaf@example.invalid',
                'role': 'merchant',
              },
            ], r);
          }
          if (route.endsWith('/shops')) return json([shopRow], r);
          if (route.endsWith('/merchant_catalog_search_v1')) {
            return json([productRow], r);
          }
          if (route.endsWith('/products')) return json([productRow], r);
          if (route.endsWith('/shop_products')) {
            if (r.method == 'POST' || r.method == 'PATCH') {
              final body = jsonDecode(r.body) as Map<String, dynamic>;
              saved = {
                ...?saved,
                ...body,
                'id': listing,
                'shop_id': shop,
                'product_id': product,
                'price': double.parse(body['price'].toString()),
                'updated_at': '2026-10-14T00:00:00Z',
                'products': productRow,
                'shops': shopRow,
              };
            }
            if (r.method == 'POST' || r.method == 'PATCH') {
              return json(saved, r);
            }
            return json([if (saved != null) saved], r);
          }
          if (route.endsWith('/merchant_prepare_listing_image_v1')) {
            expect(jsonDecode(r.body)['p_listing_id'], listing);
            return json({
              'id': 'image',
              'bucket_id': 'listing-media',
              'object_path': path,
            }, r);
          }
          if (route == '/storage/v1/object/listing-media/$path') {
            expect(r.method, 'POST');
            expect(r.headers['x-upsert'], 'false');
            expect(r.bodyBytes.length, greaterThan(8));
            uploaded = true;
            return json({'Key': 'listing-media/$path'}, r);
          }
          if (route.endsWith('/merchant_change_listing_images_v1')) {
            final action = jsonDecode(r.body)['p_action'];
            if (action == 'publish') {
              expect(uploaded, true);
              published = true;
            }
            if (action == 'retire') {
              retired = true;
            }
            return json(null, r);
          }
          if (route.endsWith('/catalog_listing_media_read_v1')) {
            return json([
              if (saved?['is_available'] == true && saved?['is_active'] == true)
                {
                  'listing_id': listing,
                  'managed': published,
                  'images': [
                    if (published && !retired)
                      {'bucket_id': 'listing-media', 'object_path': path},
                  ],
                },
            ], r);
          }
          if (route == '/storage/v1/object/sign/listing-media') {
            expect(jsonDecode(r.body)['paths'], [path]);
            return json([
              {
                'path': path,
                'signedURL':
                    '/object/sign/listing-media/$path?token=synthetic-only',
              },
            ], r);
          }
          fail('Unexpected synthetic route: ${r.method} $route');
        }),
      );
      var client = connect();
      var repo = SupabaseMerchantRepository(
        client: client,
        currentUserId: () => merchant,
      );
      final access = value(await repo.loadAccess())!;
      final catalog = value(await repo.searchCatalog(access, query: 'Örnek'));
      expect(catalog.single.id, product);
      final first = value(
        await repo.saveListing(
          access,
          const MerchantListingDraft(productId: product, priceMinor: 1250),
        ),
      );
      final edited = value(
        await repo.saveListing(
          access,
          const MerchantListingDraft(productId: product, priceMinor: 2450),
          existing: first,
        ),
      );
      expect(edited.price, 24.5);
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aS6sAAAAASUVORK5CYII=',
      );
      value(
        await SupabaseCatalogMediaRepository(
          client,
          currentUserId: () => merchant,
        ).upload(access, listing, png),
      );
      expect(published, true);
      await client.dispose();
      // New client/repository instances must reconstruct from server responses.
      client = connect();
      addTearDown(client.dispose);
      repo = SupabaseMerchantRepository(
        client: client,
        currentUserId: () => merchant,
      );
      final reloaded = value(
        await repo.listings(value(await repo.loadAccess())!),
      );
      expect(reloaded.single.price, 24.5);
      expect(reloaded.single.isAvailable, true);
      final customer = connect();
      addTearDown(customer.dispose);
      final media = SupabaseListingHeroMediaRepository(customer);
      final ranked = SellerRanking.rank(
        [ShopProductModel.fromJson(saved!)],
        null,
        SellerSortOption.cheapest,
      );
      final photos = await media.photos(
        ranked.map((r) => r.shopProduct).toList(),
      );
      expect(photos.single.listingId, listing);
      expect(photos.single.shopName, 'Örnek mağaza');
      expect(photos.single.source, contains(path));
      value(
        await SupabaseCatalogMediaRepository(
          client,
          currentUserId: () => merchant,
        ).changeMedia(access, listing, 'retire', imageId: 'image'),
      );
      expect(await media.photos(reloaded), isEmpty);
      expect(uploaded, true, reason: 'Logical retirement retains bytes');
      expect(
        requests
            .where((r) => r.contains('/storage/v1/object/listing-media/'))
            .length,
        1,
      );
    },
  );
}
