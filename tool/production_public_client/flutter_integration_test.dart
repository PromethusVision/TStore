// Explicitly run by rehearse.mjs; not a skipped test in the regular suite.
// Real Flutter repositories + Supabase/PostgREST client against the isolated
// restored Production copy. The transport override never changes host guards.
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/repositories/production_public_product_repository.dart';
import 'package:t_store/features/shop/data/repositories/production_public_shop_repository.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/repositories/taxonomy_scoped_product_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import '../../test/helpers/production_public_test_support.dart';

class _NoOwnerReads extends Mock implements ShopRepository {}

T right<T>(Either<String, T> result) => result.fold(
  (_) => throw StateError('Public integration read failed safely'),
  (r) => r,
);

void main() {
  final fixture =
      jsonDecode(
            File(
              Platform.environment['W52LB_FLUTTER_FIXTURE']!,
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final endpoint = Uri.parse(fixture['endpoint'] as String);
  if (endpoint.scheme != 'http' ||
      endpoint.host != '127.0.0.1' ||
      fixture['isolated'] != true) {
    throw StateError('Local integration only');
  }
  final adapters = <ProductionPublicTaxonomyAdapter>[],
      clients = <SupabaseClient>[];
  tearDown(() => sl.reset());
  tearDownAll(() async {
    for (final c in clients) {
      await c.dispose();
    }
  });
  for (final role in ['anon', 'authenticated']) {
    test(
      'real public $role: taxonomy, all product/seller/shop flows and policy gates',
      () async {
        final client = SupabaseClient(
          endpoint.toString(),
          'isolated-test-only',
          headers: {
            'X-W52LB-Role': role,
            'X-W52LB-Control': fixture['control'] as String,
          },
        );
        clients.add(client);
        final adapter = ProductionPublicTaxonomyAdapter(
          config: previewTestConfig(),
          rpcCaller: (name, args) => client.rpc(name, params: args),
        );
        adapters.add(adapter);
        final authorization = await adapter.authorize();
        expect(authorization.contractProof.supportsProductionPublic, true);
        final products = ProductionPublicProductRepository(adapter: adapter);
        final owner = _NoOwnerReads();
        final shops = ProductionPublicShopRepository(
          adapter: adapter,
          ownerRepository: owner,
        );
        await setupServiceLocator(
          taxonomyConfiguration:
              TaxonomyDependencyConfiguration.productionPublicCanonical(
                authorization,
              ),
          productionPublicAdapter: adapter,
          productionPublicProducts: products,
          productionPublicShops: shops,
        );
        expect(sl<ProductRepository>(), same(products));
        expect(sl<ShopRepository>(), same(shops));
        expect(sl<TaxonomyScopedProductRepository>(), same(products));
        final tree = sl<CanonicalTaxonomyRepository>();
        final roots = right(await tree.getRoots());
        expect(roots.length, 24);
        final path = (fixture['path'] as List).cast<String>();
        for (var level = 1; level < 4; level++) {
          final children = right(await tree.getChildren(path[level - 1]));
          expect(children.any((c) => c.id == path[level]), true);
          expect((await adapter.getBreadcrumb(path[level])).length, level + 1);
          right(await tree.getBreadcrumb(path[level]));
        }
        expect((await adapter.qualifyExactLeaf(path.last)).length, 1);
        expect(
          right(
            await tree.getDescendants(path.first),
          ).any((n) => n.id == path.last),
          true,
        );
        expect(
          right(
            await tree.resolveAlias(TaxonomyAliasLookup(locator: 'powerbank')),
          ).state,
          TaxonomyAliasResolutionState.resolved,
        );
        expect(
          right(
            await tree.searchTaxonomy(
              TaxonomySearchRequest(query: 'Defterler'),
            ),
          ),
          isNotEmpty,
        );
        final all = right(
          await products.getProducts(limit: 100, sortBy: 'name'),
        );
        expect(all.length, 14);
        final eligible = Set<String>.from(fixture['eligible'] as List),
            gated = Set<String>.from(fixture['gated'] as List);
        expect(all.map((p) => p.id), unorderedEquals(eligible));
        expect(gated.length, 6);
        final paged = <String>[];
        for (var page = 0; page < 4; page++) {
          paged.addAll(
            right(
              await products.getProducts(page: page, limit: 4, sortBy: 'name'),
            ).map((p) => p.id),
          );
        }
        expect(paged, all.map((p) => p.id).toList());
        expect(paged.toSet().length, 14);
        final fromRoots = <String>{};
        for (final root in roots) {
          fromRoots.addAll(
            right(
              await products.getProductsByTaxonomyScope(
                scope: TaxonomyProductQueryScope.descendants(
                  categoryId: root.id,
                ),
                limit: 100,
              ),
            ).map((p) => p.id),
          );
        }
        expect(fromRoots, unorderedEquals(eligible));
        for (final p in all) {
          expect(right(await products.getProductById(p.id)).id, p.id);
          final scoped = right(
            await products.getProductsByTaxonomyScope(
              scope: TaxonomyProductQueryScope.exactLeaf(
                categoryId: p.categoryId,
              ),
              limit: 100,
            ),
          );
          expect(scoped.any((r) => r.id == p.id), true);
          final sellers = right(await shops.getShopProductsByProduct(p.id));
          expect(sellers, isNotEmpty);
          expect(
            sellers.every(
              (s) =>
                  s.productId == p.id &&
                  s.product?.categoryId == p.categoryId &&
                  s.shop != null,
            ),
            true,
          );
        }
        for (final id in gated) {
          expect((await products.getProductById(id)).isLeft(), true);
          expect(right(await shops.getShopProductsByProduct(id)), isEmpty);
        }
        final sellers = right(await shops.getShopProducts());
        expect(sellers.length, greaterThan(100));
        expect(sellers.every((s) => eligible.contains(s.productId)), true);
        final shopId = sellers.first.shopId;
        expect(right(await shops.getShopById(shopId))?.id, shopId);
        final shopProducts = right(await shops.getShopProductsByShop(shopId));
        expect(shopProducts, isNotEmpty);
        expect(
          shopProducts.every(
            (s) => s.shopId == shopId && eligible.contains(s.productId),
          ),
          true,
        );
        final allShops = right(await shops.getShops());
        expect(allShops, isNotEmpty);
        final byIds = right(
          await shops.getShopProductsByProductIds([...eligible, ...gated]),
        );
        expect(byIds.every((s) => eligible.contains(s.productId)), true);
        expect(
          right(
            await products.searchProducts(all.first.name),
          ).any((p) => p.id == all.first.id),
          true,
        );
        expect(
          right(
            await products.getFeaturedProducts(),
          ).every((p) => eligible.contains(p.id) && p.isFeatured),
          true,
        );
        // The frozen backup has no assigned product brands. Exercise the
        // filter with a non-existing UUID without seeding or guessing.
        final branded = all.where((p) => p.brandId != null);
        final brand = branded.isEmpty
            ? '00000000-0000-4000-8000-000000009999'
            : branded.first.brandId!;
        final byBrand = right(await products.getProductsByBrand(brand));
        if (branded.isEmpty) {
          expect(byBrand, isEmpty);
        }
        expect(
          byBrand.every((p) => p.brandId == brand && eligible.contains(p.id)),
          true,
        );
        verifyZeroInteractions(owner);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  }
  test(
    'real rollback invalidates cached and fresh public runtime without any fallback',
    () async {
      final http = HttpClient();
      try {
        final request = await http.postUrl(
          endpoint.resolve('/control/rollback'),
        );
        request.headers.set('X-W52LB-Control', fixture['control'] as String);
        final response = await request.close();
        await response.drain<void>();
        expect(response.statusCode, 200);
      } finally {
        http.close();
      }
      for (final adapter in adapters) {
        expect(adapter.isVerified, true);
        await expectLater(adapter.getRoots(), throwsA(isA<Object>()));
        expect(adapter.isVerified, false);
        expect(
          (await ProductionPublicProductRepository(
            adapter: adapter,
          ).getProducts()).isLeft(),
          true,
        );
        await expectLater(adapter.authorize(), throwsA(isA<Object>()));
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
