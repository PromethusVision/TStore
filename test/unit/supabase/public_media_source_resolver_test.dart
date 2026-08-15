import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';

void main() {
  const productId = '11111111-1111-4111-8111-111111111111';
  const shopId = '22222222-2222-4222-8222-222222222222';
  const shopProductId = '33333333-3333-4333-8333-333333333333';
  const categoryId = '44444444-4444-4444-8444-444444444444';
  const bannerId = '55555555-5555-4555-8555-555555555555';

  group('PublicMediaSourceResolver controlled paths', () {
    late List<(String, String)> calls;
    late PublicMediaSourceResolver resolver;

    setUp(() {
      calls = <(String, String)>[];
      resolver = PublicMediaSourceResolver.withUrlBuilder((bucket, path) {
        calls.add((bucket, path));
        return 'https://media.example/storage/$bucket/$path';
      });
    });

    test('resolves a catalog product path from product-images', () {
      const path = 'catalog/$productId/primary.webp';

      expect(
        resolver.resolveCatalogProduct(path, productId: productId),
        'https://media.example/storage/product-images/$path',
      );
      expect(calls, [('product-images', path)]);
    });

    test('resolves a shop-specific product path from product-images', () {
      const path = 'shops/$shopId/$shopProductId/primary.webp';

      expect(
        resolver.resolveShopProduct(
          path,
          shopId: shopId,
          shopProductId: shopProductId,
        ),
        'https://media.example/storage/product-images/$path',
      );
      expect(calls, [('product-images', path)]);
    });

    test('resolves a category catalog path from category-images', () {
      const path = 'catalog/$categoryId/tile.png';

      expect(
        resolver.resolveCategory(path, categoryId: categoryId),
        'https://media.example/storage/category-images/$path',
      );
      expect(calls, [('category-images', path)]);
    });

    test('resolves a banner catalog path from banner-images', () {
      const path = 'catalog/$bannerId/home-hero.jpg';

      expect(
        resolver.resolveBanner(path, bannerId: bannerId),
        'https://media.example/storage/banner-images/$path',
      );
      expect(calls, [('banner-images', path)]);
    });

    test('keeps a valid legacy HTTPS URL without calling Storage', () {
      const legacy = 'https://legacy-cdn.example/products/image.png?version=2';

      expect(
        resolver.resolveCatalogProduct(legacy, productId: productId),
        legacy,
      );
      expect(calls, isEmpty);
    });

    test('rejects malformed and unsupported URL schemes', () {
      for (final source in <String>[
        'https://',
        'javascript:alert(1)',
        'data:image/png;base64,AA==',
        'file:///tmp/image.png',
        r'C:\images\product.png',
        'http://cdn.example/image.png',
      ]) {
        expect(
          resolver.resolveCatalogProduct(source, productId: productId),
          isNull,
          reason: source,
        );
      }
      expect(calls, isEmpty);
    });

    test('rejects unknown buckets, owners, and unsafe paths', () {
      for (final source in <String>[
        'product-images/catalog/$productId/image.png',
        'avatars/$productId/image.png',
        'catalog/another-product/image.png',
        'shops/$shopId/$shopProductId/image.png',
        'catalog/$productId/../image.png',
        'catalog/$productId/%2e%2e/image.png',
        'catalog/$productId/image.png?download=true',
        '/catalog/$productId/image.png',
      ]) {
        expect(
          resolver.resolveCatalogProduct(source, productId: productId),
          isNull,
          reason: source,
        );
      }
      expect(calls, isEmpty);
    });

    test('returns null for empty and null values', () {
      expect(
        resolver.resolveCatalogProduct(null, productId: productId),
        isNull,
      );
      expect(resolver.resolveCatalogProduct('', productId: productId), isNull);
      expect(
        resolver.resolveCatalogProduct('   ', productId: productId),
        isNull,
      );
      expect(calls, isEmpty);
    });

    test('drops invalid list members while preserving valid order', () {
      const path = 'catalog/$productId/secondary.webp';

      expect(
        resolver.resolveCatalogProducts(const [
          'javascript:alert(1)',
          'https://legacy.example/primary.webp',
          path,
        ], productId: productId),
        [
          'https://legacy.example/primary.webp',
          'https://media.example/storage/product-images/$path',
        ],
      );
    });

    test('fails closed when public URL generation fails or is unsafe', () {
      final throwingResolver = PublicMediaSourceResolver.withUrlBuilder(
        (_, _) => throw StateError('not initialized'),
      );
      final unsafeResolver = PublicMediaSourceResolver.withUrlBuilder(
        (_, _) => 'http://remote.example/image.png',
      );

      expect(
        throwingResolver.resolveCatalogProduct(
          'catalog/$productId/image.png',
          productId: productId,
        ),
        isNull,
      );
      expect(
        unsafeResolver.resolveCatalogProduct(
          'catalog/$productId/image.png',
          productId: productId,
        ),
        isNull,
      );
    });
  });

  test(
    'uses the current client project for Development and Production-like configurations',
    () {
      const path = 'catalog/$productId/primary.webp';
      const developmentKey = 'sb_publishable_development_test_key';
      const productionKey = 'sb_publishable_production_test_key';
      final developmentResolver = PublicMediaSourceResolver.fromSupabaseClient(
        SupabaseClient(
          'https://development-project.example.supabase.co',
          developmentKey,
        ),
      );
      final productionResolver = PublicMediaSourceResolver.fromSupabaseClient(
        SupabaseClient(
          'https://production-project.example.supabase.co',
          productionKey,
        ),
      );

      final developmentUrl = developmentResolver.resolveCatalogProduct(
        path,
        productId: productId,
      );
      final productionUrl = productionResolver.resolveCatalogProduct(
        path,
        productId: productId,
      );

      expect(
        developmentUrl,
        'https://development-project.example.supabase.co/storage/v1/object/public/product-images/$path',
      );
      expect(
        productionUrl,
        'https://production-project.example.supabase.co/storage/v1/object/public/product-images/$path',
      );
      expect(developmentUrl, isNot(productionUrl));
      expect(developmentUrl, isNot(contains(developmentKey)));
      expect(productionUrl, isNot(contains(productionKey)));
    },
  );

  test('allows generated HTTP URLs only for a loopback Development client', () {
    const path = 'catalog/$categoryId/tile.png';
    final resolver = PublicMediaSourceResolver.fromSupabaseClient(
      SupabaseClient('http://127.0.0.1:54321', 'sb_publishable_local_test'),
    );

    expect(
      resolver.resolveCategory(path, categoryId: categoryId),
      'http://127.0.0.1:54321/storage/v1/object/public/category-images/$path',
    );
  });
}
