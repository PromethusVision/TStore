import 'package:equatable/equatable.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/services/deployed_canonical_taxonomy_rpc_contract.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

enum TaxonomyRuntimeRequest { legacy, canonicalV1Acceptance }

class TaxonomyDependencyConfiguration extends Equatable {
  const TaxonomyDependencyConfiguration({
    required this.environment,
    this.runtimeRequest = TaxonomyRuntimeRequest.legacy,
    this.contractInventory,
  });

  factory TaxonomyDependencyConfiguration.legacy(AppEnvironment environment) {
    return TaxonomyDependencyConfiguration(environment: environment);
  }

  factory TaxonomyDependencyConfiguration.developmentCanonicalAcceptance({
    required TaxonomyBackendContractInventory contractInventory,
  }) {
    return TaxonomyDependencyConfiguration(
      environment: AppEnvironment.development,
      runtimeRequest: TaxonomyRuntimeRequest.canonicalV1Acceptance,
      contractInventory: contractInventory,
    );
  }

  final AppEnvironment environment;
  final TaxonomyRuntimeRequest runtimeRequest;
  final TaxonomyBackendContractInventory? contractInventory;

  @override
  List<Object?> get props => [environment, runtimeRequest, contractInventory];
}

class TaxonomyDependencyPlan extends Equatable {
  const TaxonomyDependencyPlan({
    required this.environment,
    required this.capability,
    required this.contractAssessment,
    required this.registerDevelopmentRpcAdapter,
  });

  final AppEnvironment environment;
  final TaxonomyRuntimeCapability capability;
  final TaxonomyCapabilityAssessment contractAssessment;
  final bool registerDevelopmentRpcAdapter;

  bool get requiresCanonicalBindings => capability.isCanonicalV1;

  @override
  List<Object?> get props => [
    environment,
    capability,
    contractAssessment,
    registerDevelopmentRpcAdapter,
  ];
}

class TaxonomyDependencyConfigurationException implements Exception {
  const TaxonomyDependencyConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'Taxonomy dependency configuration error: $message';
}

class TaxonomyDependencyPlanner {
  const TaxonomyDependencyPlanner({
    this.capabilityVerifier = const TaxonomyBackendCapabilityVerifier(),
  });

  final TaxonomyBackendCapabilityVerifier capabilityVerifier;

  TaxonomyDependencyPlan resolve(TaxonomyDependencyConfiguration config) {
    final inventory =
        config.contractInventory ?? deployedCanonicalTaxonomyV1Inventory;
    final assessment = capabilityVerifier.assess(inventory);

    if (config.runtimeRequest == TaxonomyRuntimeRequest.legacy) {
      return TaxonomyDependencyPlan(
        environment: config.environment,
        capability: TaxonomyRuntimeCapability.currentDefault,
        contractAssessment: assessment,
        registerDevelopmentRpcAdapter:
            config.environment == AppEnvironment.development,
      );
    }

    if (config.environment != AppEnvironment.development) {
      throw const TaxonomyDependencyConfigurationException(
        'Canonical acceptance may be requested only by Development.',
      );
    }
    if (!assessment.supportsCanonicalV1 || assessment.proof == null) {
      throw const TaxonomyDependencyConfigurationException(
        'Canonical acceptance was requested without a compatible '
        'authoritative backend capability proof.',
      );
    }

    return TaxonomyDependencyPlan(
      environment: config.environment,
      capability: TaxonomyRuntimeCapability.canonicalV1(
        proof: assessment.proof!,
      ),
      contractAssessment: assessment,
      registerDevelopmentRpcAdapter: true,
    );
  }
}
