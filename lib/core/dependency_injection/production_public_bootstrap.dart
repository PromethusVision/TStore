import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/production_public_gate.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/shop/data/repositories/production_public_product_repository.dart';
import 'package:t_store/features/shop/data/repositories/production_public_shop_repository.dart';
import 'package:t_store/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/t_store.dart';

Widget productionPublicApplication(SupabaseConfig config) {
  validateProductionPublicConfig(config);
  final service = SupabaseService.instance;
  ProductionPublicTaxonomyAdapter? active;
  return ProductionPublicGate(
    changes: service.authStateChanges.map((_) {}),
    invalidate: () => active?.invalidate(),
    configure: (unavailable) async {
      active?.invalidate();
      await sl.reset();
      final adapter = ProductionPublicTaxonomyAdapter(
        config: config,
        rpcCaller: (name, args) => service.client.rpc(name, params: args),
        onUnavailable: unavailable,
      );
      active = adapter;
      final authorization = await adapter.authorize();
      final media = PublicMediaSourceResolver.fromSupabaseClient(
        service.client,
      );
      await setupServiceLocator(
        taxonomyConfiguration:
            TaxonomyDependencyConfiguration.productionPublicCanonical(
              authorization,
            ),
        productionPublicAdapter: adapter,
        productionPublicProducts: ProductionPublicProductRepository(
          adapter: adapter,
          mediaResolver: media,
        ),
        productionPublicShops: ProductionPublicShopRepository(
          adapter: adapter,
          mediaResolver: media,
          ownerRepository: ShopRepositoryImpl(
            supabaseService: service,
            mediaResolver: media,
          ),
        ),
      );
    },
    applicationBuilder: (_) => const TStore(),
  );
}
