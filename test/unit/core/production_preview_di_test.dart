import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/features/shop/data/repositories/product_repository_impl.dart';
import 'package:t_store/features/shop/data/repositories/production_preview_product_repository.dart';
import 'package:t_store/features/shop/data/repositories/canonical_taxonomy_repository_impl.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/repositories/taxonomy_scoped_product_repository.dart';
import '../../helpers/production_preview_test_support.dart';

class _LocalService extends Mock implements SupabaseService {}

void main() {
  tearDown(() => sl.reset());
  test(
    'public default keeps legacy product repository and no canonical binding',
    () async {
      await setupServiceLocator();
      final client = SupabaseClient('https://local.invalid', 'unit-test-key');
      addTearDown(client.dispose);
      final service = _LocalService();
      when(() => service.client).thenReturn(client);
      await sl.unregister<SupabaseService>();
      sl.registerSingleton<SupabaseService>(service);
      expect(sl<ProductRepository>(), isA<ProductRepositoryImpl>());
      expect(sl.isRegistered<CanonicalTaxonomyRepository>(), isFalse);
    },
  );
  test(
    'authorized preview binds the same product adapter for listing and details',
    () async {
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: previewTestConfig(),
        currentUserId: () => previewTestSubject,
        rpcCaller: (_, _) async => [previewCapabilityFixture()],
      );
      final auth = await adapter.authorize();
      final products = ProductionPreviewProductRepository(adapter: adapter);
      final config = TaxonomyDependencyConfiguration.productionPrivatePreview(
        auth,
      );
      await expectLater(
        setupServiceLocator(taxonomyConfiguration: config),
        throwsA(isA<TaxonomyDependencyConfigurationException>()),
      );
      await setupServiceLocator(
        taxonomyConfiguration: config,
        productionPreviewAdapter: adapter,
        productionPreviewProducts: products,
      );
      expect(sl<ProductRepository>(), same(products));
      expect(sl<TaxonomyScopedProductRepository>(), same(products));
      expect(
        (sl<CanonicalTaxonomyRepository>() as CanonicalTaxonomyRepositoryImpl)
            .adapter,
        same(adapter),
      );
    },
  );
}
