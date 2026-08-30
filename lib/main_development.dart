import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/shop/data/services/supabase_canonical_taxonomy_rpc_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/t_store.dart';

const appEnvironment = AppEnvironment.development;
const supabaseUrlDartDefine = SupabaseConfig.developmentUrlDartDefine;
const supabaseAnonKeyDartDefine = SupabaseConfig.developmentAnonKeyDartDefine;
const developmentCanonicalTaxonomyDartDefine =
    'ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY';

typedef DevelopmentTaxonomyProofLoader =
    Future<TaxonomyBackendContractProof> Function();

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

Future<TaxonomyDependencyConfiguration> createDevelopmentTaxonomyConfiguration({
  bool canonicalOptIn = const bool.fromEnvironment(
    developmentCanonicalTaxonomyDartDefine,
  ),
  DevelopmentTaxonomyProofLoader? proofLoader,
}) async {
  if (!canonicalOptIn) {
    return TaxonomyDependencyConfiguration.legacy(appEnvironment);
  }
  final loadProof =
      proofLoader ??
      SupabaseCanonicalTaxonomyRpcAdapter.fromSupabaseService(
        SupabaseService.instance,
        previewRequested: true,
      ).getCapabilityProof;
  return TaxonomyDependencyConfiguration.developmentCanonicalAcceptance(
    contractProof: await loadProof(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = createSupabaseConfig();
  await SupabaseService.initialize(config: supabaseConfig);
  await setupServiceLocator(
    taxonomyConfiguration: await createDevelopmentTaxonomyConfiguration(),
  );

  runApp(const TStore());
}
