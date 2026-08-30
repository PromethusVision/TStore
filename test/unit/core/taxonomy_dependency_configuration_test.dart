import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/services/deployed_canonical_taxonomy_rpc_contract.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';
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
    'explicit canonical request rejects current deployed contract, no fallback',
    () {
      expect(
        () => planner.resolve(
          TaxonomyDependencyConfiguration.developmentCanonicalAcceptance(
            contractInventory: deployedCanonicalTaxonomyV1Inventory,
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
          contractInventory: _compatibleInventory(),
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
          contractInventory: _compatibleInventory(),
        ),
      );

      expect(plan.capability.isCanonicalV1, isTrue);
      expect(plan.requiresCanonicalBindings, isTrue);
      expect(plan.registerDevelopmentRpcAdapter, isTrue);
    },
  );
}

TaxonomyBackendContractInventory _compatibleInventory() {
  return TaxonomyBackendContractInventory(
    taxonomyVersion: 'canonical-v1.0.0',
    declaredClientContractVersion:
        TaxonomyBackendContractProof.supportedClientContractVersion,
    hasAuthoritativeCapabilityResponse: true,
    endpoints: {
      for (final entry
          in TaxonomyBackendCapabilityVerifier
              .requiredEndpointArguments
              .entries)
        entry.key: TaxonomyRpcEndpointInventory(
          functionName: entry.key,
          argumentNames: entry.value,
          returnFields: TaxonomyBackendCapabilityVerifier
              .requiredResponseFields[entry.key]!,
          securityMode: TaxonomyRpcSecurityMode.invoker,
          isStable: true,
          searchPathPinnedToPublic: true,
          anonExecute: true,
          authenticatedExecute: true,
        ),
    },
  );
}
