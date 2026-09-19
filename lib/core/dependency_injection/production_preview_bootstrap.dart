import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/core/common/widgets/production_preview_gate.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/data/repositories/production_preview_product_repository.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/t_store.dart';

Widget productionPreviewApplication(SupabaseConfig config) {
  validateProductionPreviewConfig(config);
  final service = SupabaseService.instance;
  ProductionPreviewTaxonomyAdapter? activeAdapter;
  return ProductionPreviewGate(
    currentSubject: () => service.currentSession?.user.id,
    sessionChanges: service.authStateChanges.map((_) {
      // Invalidate even when a new session belongs to the same Auth UID.
      activeAdapter?.invalidateAuthorization();
    }),
    configure: (subject) async {
      // The gate has removed the previous app and its Bloc providers first.
      activeAdapter?.invalidateAuthorization();
      await sl.reset();
      if (subject == null) {
        // Auth form dependencies only. The gate never renders the legacy app.
        await setupServiceLocator(
          taxonomyConfiguration: TaxonomyDependencyConfiguration.legacy(
            AppEnvironment.production,
          ),
        );
        return;
      }
      final adapter = ProductionPreviewTaxonomyAdapter(
        config: config,
        rpcCaller: (name, args) => service.client.rpc(name, params: args),
        currentUserId: () => service.currentSession?.user.id,
      );
      activeAdapter = adapter;
      final authorization = await adapter.authorize();
      await setupServiceLocator(
        taxonomyConfiguration:
            TaxonomyDependencyConfiguration.productionPrivatePreview(
              authorization,
            ),
        productionPreviewAdapter: adapter,
        productionPreviewProducts: ProductionPreviewProductRepository(
          adapter: adapter,
          mediaResolver: PublicMediaSourceResolver.fromSupabaseClient(
            service.client,
          ),
        ),
      );
    },
    applicationBuilder: (_) => const TStore(),
    loginBuilder: (_) => BlocProvider<CartV2Cubit>(
      create: (_) => sl<CartV2Cubit>(),
      child: const LoginView(returnToCallerAfterCustomerLogin: true),
    ),
    signOut: service.signOut,
  );
}
