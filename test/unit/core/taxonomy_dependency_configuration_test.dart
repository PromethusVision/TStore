import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

void main() {
  const planner = TaxonomyDependencyPlanner();

  test(
    'Development legacy default registers only the raw read adapter seam',
    () {
      final plan = planner.resolve(
        TaxonomyDependencyConfiguration.legacy(AppEnvironment.development),
      );

      expect(plan.capability.isLegacy, isTrue);
      expect(plan.registerDevelopmentRpcAdapter, isTrue);
      expect(plan.requiresCanonicalBindings, isFalse);
    },
  );

  test(
    'Production default remains legacy and does not register preview adapter',
    () {
      final plan = planner.resolve(
        TaxonomyDependencyConfiguration.legacy(AppEnvironment.production),
      );

      expect(plan.capability.isLegacy, isTrue);
      expect(plan.registerDevelopmentRpcAdapter, isFalse);
    },
  );

  test(
    'explicit canonical request rejects compatible preview-off proof, no fallback',
    () {
      expect(
        () => planner.resolve(
          TaxonomyDependencyConfiguration.developmentCanonicalAcceptance(
            contractProof: _proof(previewEnabled: false, previewRootCount: 0),
          ),
        ),
        throwsA(isA<TaxonomyDependencyConfigurationException>()),
      );
    },
  );

  test('Production cannot request canonical acceptance', () {
    expect(
      () => planner.resolve(
        TaxonomyDependencyConfiguration(
          environment: AppEnvironment.production,
          runtimeRequest: TaxonomyRuntimeRequest.canonicalV1Acceptance,
          contractProof: _proof(previewEnabled: true, previewRootCount: 24),
        ),
      ),
      throwsA(isA<TaxonomyDependencyConfigurationException>()),
    );
  });

  test(
    'verified Development contract prepares canonical bindings explicitly',
    () {
      final plan = planner.resolve(
        TaxonomyDependencyConfiguration.developmentCanonicalAcceptance(
          contractProof: _proof(previewEnabled: true, previewRootCount: 24),
        ),
      );

      expect(plan.capability.isCanonicalV1, isTrue);
      expect(plan.requiresCanonicalBindings, isTrue);
      expect(plan.registerDevelopmentRpcAdapter, isTrue);
    },
  );
}

TaxonomyBackendContractProof _proof({
  required bool previewEnabled,
  required int previewRootCount,
}) {
  return TaxonomyBackendContractProof(
    contractVersion:
        TaxonomyBackendContractProof.supportedClientContractVersion,
    taxonomyVersion: TaxonomyBackendContractProof.supportedTaxonomyVersion,
    rpcContractVersion:
        TaxonomyBackendContractProof.supportedRpcContractVersion,
    rpcGeneration: TaxonomyBackendContractProof.supportedRpcGeneration,
    supportedFeatures: TaxonomyBackendContractProof.requiredCanonicalV1Features,
    verifiedEvidence: TaxonomyBackendContractProof.requiredCanonicalV1Evidence,
    previewSupported: true,
    previewEnabled: previewEnabled,
    lifecycleMetadata: true,
    policyMetadata: true,
    aliasStateMetadata: true,
    pathMetadata: true,
    publicActiveRootCount: 0,
    pilotActiveRootCount: 0,
    previewRootCount: previewRootCount,
    productScopeContract:
        TaxonomyBackendContractProof.supportedProductScopeContract,
    productScopeRequiresAssignable: true,
    productScopePolicyFailClosed: true,
  );
}
