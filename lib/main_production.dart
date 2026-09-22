import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/production_preview_bootstrap.dart';
import 'package:t_store/core/dependency_injection/production_public_bootstrap.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/t_store.dart';

const appEnvironment = AppEnvironment.production;
const supabaseUrlDartDefine = SupabaseConfig.productionUrlDartDefine;
const supabaseAnonKeyDartDefine = SupabaseConfig.productionAnonKeyDartDefine;
const productionCanonicalPreviewDartDefine =
    'ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW';
const productionCanonicalPreview = bool.fromEnvironment(
  productionCanonicalPreviewDartDefine,
);
const productionCanonicalPublicDartDefine =
    'ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC';
const productionCanonicalPublic = bool.fromEnvironment(
  productionCanonicalPublicDartDefine,
);

enum ProductionRuntimeSelection { legacy, privatePreview, publicCanonical }

ProductionRuntimeSelection selectProductionRuntime({
  bool publicCanonical = productionCanonicalPublic,
  bool privatePreview = productionCanonicalPreview,
}) {
  if (publicCanonical && privatePreview) {
    throw StateError(
      'Public and private preview modes are mutually exclusive.',
    );
  }
  return publicCanonical
      ? ProductionRuntimeSelection.publicCanonical
      : privatePreview
      ? ProductionRuntimeSelection.privatePreview
      : ProductionRuntimeSelection.legacy;
}

SupabaseConfig createSupabaseConfig({
  String supabaseUrl = const String.fromEnvironment(supabaseUrlDartDefine),
  String supabaseAnonKey = const String.fromEnvironment(
    supabaseAnonKeyDartDefine,
  ),
}) {
  return SupabaseConfig.forEnvironment(
    environment: appEnvironment,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = createSupabaseConfig();
  final runtime = selectProductionRuntime();
  if (runtime == ProductionRuntimeSelection.publicCanonical) {
    validateProductionPublicConfig(supabaseConfig);
  }
  if (runtime == ProductionRuntimeSelection.privatePreview) {
    validateProductionPreviewConfig(supabaseConfig);
  }
  await SupabaseService.initialize(config: supabaseConfig);
  if (runtime == ProductionRuntimeSelection.publicCanonical) {
    runApp(productionPublicApplication(supabaseConfig));
    return;
  }
  if (runtime == ProductionRuntimeSelection.privatePreview) {
    runApp(productionPreviewApplication(supabaseConfig));
    return;
  }
  await setupServiceLocator(
    taxonomyConfiguration: TaxonomyDependencyConfiguration.legacy(
      appEnvironment,
    ),
  );

  runApp(const TStore());
}
