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
    this.contractProof,
  });

  factory TaxonomyDependencyConfiguration.legacy(AppEnvironment environment) {
    return TaxonomyDependencyConfiguration(environment: environment);
  }

  factory TaxonomyDependencyConfiguration.developmentCanonicalAcceptance({
    required TaxonomyBackendContractProof contractProof,
  }) {
    return TaxonomyDependencyConfiguration(
      environment: AppEnvironment.development,
      runtimeRequest: TaxonomyRuntimeRequest.canonicalV1Acceptance,
      contractProof: contractProof,
    );
  }

  final AppEnvironment environment;
  final TaxonomyRuntimeRequest runtimeRequest;
  final TaxonomyBackendContractInventory? contractInventory;
  final TaxonomyBackendContractProof? contractProof;

  @override
  List<Object?> get props => [
    environment,
    runtimeRequest,
    contractInventory,
    contractProof,
  ];
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
        config.contractInventory ?? deployedCanonicalTaxonomyV2Inventory;
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
    final proof = config.contractProof;
    if (proof == null || !proof.supportsCanonicalV1) {
      throw const TaxonomyDependencyConfigurationException(
        'Canonical acceptance was requested without a compatible '
        'authoritative backend capability proof.',
      );
    }

    try {
      return TaxonomyDependencyPlan(
        environment: config.environment,
        capability: TaxonomyRuntimeCapability.canonicalV1(proof: proof),
        contractAssessment: TaxonomyCapabilityAssessment(
          compatibility: TaxonomyContractCompatibility.match,
          blockers: const [],
          adapterDifferences: const [],
          proof: proof,
        ),
        registerDevelopmentRpcAdapter: true,
      );
    } on ArgumentError {
      throw const TaxonomyDependencyConfigurationException(
        'Canonical acceptance contract is compatible, but no customer-visible '
        'root projection is currently available.',
      );
    }
  }
}
