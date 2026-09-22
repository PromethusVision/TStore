import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/repositories/production_public_product_repository.dart';
import 'package:t_store/features/shop/data/repositories/production_public_shop_repository.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import '../../helpers/production_public_test_support.dart';

class _Owner extends Mock implements ShopRepository {}

void main() {
  tearDown(() => sl.reset());
  ProductionPublicTaxonomyAdapter adapter() => ProductionPublicTaxonomyAdapter(
    config: previewTestConfig(),
    rpcCaller: (name, _) async => publicHandshakeFixture(name),
  );
  test(
    'public DI rejects missing authorization and Development request',
    () async {
      final a = adapter(), auth = await a.authorize();
      for (final config in [
        TaxonomyDependencyConfiguration(
          environment: AppEnvironment.production,
          runtimeRequest: TaxonomyRuntimeRequest.productionPublicCanonical,
          contractProof: auth.contractProof,
        ),
        TaxonomyDependencyConfiguration(
          environment: AppEnvironment.development,
          runtimeRequest: TaxonomyRuntimeRequest.productionPublicCanonical,
          contractProof: auth.contractProof,
          productionPublicAuthorization: auth,
        ),
      ]) {
        expect(
          () => const TaxonomyDependencyPlanner().resolve(config),
          throwsA(isA<TaxonomyDependencyConfigurationException>()),
        );
      }
    },
  );
  test(
    'public DI requires all repositories from same currently verified adapter',
    () async {
      final a = adapter(), auth = await a.authorize(), b = adapter();
      await b.authorize();
      final config = TaxonomyDependencyConfiguration.productionPublicCanonical(
        auth,
      );
      for (final call in [
        () => setupServiceLocator(taxonomyConfiguration: config),
        () => setupServiceLocator(
          taxonomyConfiguration: config,
          productionPublicAdapter: a,
          productionPublicProducts: ProductionPublicProductRepository(
            adapter: b,
          ),
          productionPublicShops: ProductionPublicShopRepository(
            adapter: a,
            ownerRepository: _Owner(),
          ),
        ),
      ]) {
        await expectLater(
          call(),
          throwsA(isA<TaxonomyDependencyConfigurationException>()),
        );
        expect(sl.isRegistered<ProductRepository>(), false);
      }
      final products = ProductionPublicProductRepository(adapter: a),
          shops = ProductionPublicShopRepository(
            adapter: a,
            ownerRepository: _Owner(),
          );
      await setupServiceLocator(
        taxonomyConfiguration: config,
        productionPublicAdapter: a,
        productionPublicProducts: products,
        productionPublicShops: shops,
      );
      expect(sl<ProductRepository>(), same(products));
      expect(sl<ShopRepository>(), same(shops));
      await sl.reset();
      a.invalidate();
      await expectLater(
        setupServiceLocator(
          taxonomyConfiguration: config,
          productionPublicAdapter: a,
          productionPublicProducts: products,
          productionPublicShops: shops,
        ),
        throwsA(isA<TaxonomyDependencyConfigurationException>()),
      );
    },
  );
  test('public adapter cannot be injected into default legacy mode', () async {
    final a = adapter();
    await a.authorize();
    await expectLater(
      setupServiceLocator(productionPublicAdapter: a),
      throwsA(isA<TaxonomyDependencyConfigurationException>()),
    );
    expect(sl.isRegistered<ProductRepository>(), false);
  });
}
