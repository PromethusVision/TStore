import 'package:equatable/equatable.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/shop/data/services/deployed_canonical_taxonomy_rpc_contract.dart';
import 'package:t_store/features/shop/data/services/production_preview_taxonomy_adapter.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_backend_contract_inventory.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

enum TaxonomyRuntimeRequest {
  legacy,
  canonicalV1Acceptance,
  productionPrivatePreview,
  productionPublicCanonical,
}

class TaxonomyDependencyConfiguration extends Equatable {
  const TaxonomyDependencyConfiguration({
    required this.environment,
    this.runtimeRequest = TaxonomyRuntimeRequest.legacy,
    this.contractInventory,
    this.contractProof,
    this.productionPreviewAuthorization,
    this.productionPublicAuthorization,
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
  final ProductionPreviewAuthorization? productionPreviewAuthorization;
  final ProductionPublicAuthorization? productionPublicAuthorization;

  factory TaxonomyDependencyConfiguration.productionPublicCanonical(
    ProductionPublicAuthorization authorization,
  ) => TaxonomyDependencyConfiguration(
    environment: AppEnvironment.production,
    runtimeRequest: TaxonomyRuntimeRequest.productionPublicCanonical,
    contractProof: authorization.contractProof,
    productionPublicAuthorization: authorization,
  );

  factory TaxonomyDependencyConfiguration.productionPrivatePreview(
    ProductionPreviewAuthorization authorization,
  ) => TaxonomyDependencyConfiguration(
    environment: AppEnvironment.production,
    runtimeRequest: TaxonomyRuntimeRequest.productionPrivatePreview,
    contractProof: authorization.contractProof,
    productionPreviewAuthorization: authorization,
  );

  @override
  List<Object?> get props => [
    environment,
    runtimeRequest,
    contractInventory,
    contractProof,
    productionPreviewAuthorization,
    productionPublicAuthorization,
  ];
}

class TaxonomyDependencyPlan extends Equatable {
  const TaxonomyDependencyPlan({
    required this.environment,
    required this.capability,
    required this.contractAssessment,
    required this.registerDevelopmentRpcAdapter,
    this.registerProductionPreviewAdapter = false,
    this.registerProductionPublicAdapter = false,
  });

  final AppEnvironment environment;
  final TaxonomyRuntimeCapability capability;
  final TaxonomyCapabilityAssessment contractAssessment;
  final bool registerDevelopmentRpcAdapter;
  final bool registerProductionPreviewAdapter;
  final bool registerProductionPublicAdapter;

  bool get requiresCanonicalBindings => capability.isCanonicalV1;

  @override
  List<Object?> get props => [
    environment,
    capability,
    contractAssessment,
    registerDevelopmentRpcAdapter,
    registerProductionPreviewAdapter,
    registerProductionPublicAdapter,
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

    if (config.runtimeRequest ==
        TaxonomyRuntimeRequest.productionPublicCanonical) {
      final authorization = config.productionPublicAuthorization;
      if (config.environment != AppEnvironment.production ||
          authorization == null ||
          authorization.contractProof != config.contractProof ||
          !authorization.contractProof.supportsProductionPublic) {
        throw const TaxonomyDependencyConfigurationException(
          'Verified Production public publication is required.',
        );
      }
      return TaxonomyDependencyPlan(
        environment: config.environment,
        capability: TaxonomyRuntimeCapability.productionPublic(
          proof: authorization.contractProof,
        ),
        contractAssessment: TaxonomyCapabilityAssessment(
          compatibility: TaxonomyContractCompatibility.match,
          blockers: const [],
          adapterDifferences: const [],
          proof: authorization.contractProof,
        ),
        registerDevelopmentRpcAdapter: false,
        registerProductionPublicAdapter: true,
      );
    }
    if (config.runtimeRequest ==
        TaxonomyRuntimeRequest.productionPrivatePreview) {
      final authorization = config.productionPreviewAuthorization;
      if (config.environment != AppEnvironment.production ||
          authorization == null ||
          authorization.contractProof != config.contractProof) {
        throw const TaxonomyDependencyConfigurationException(
          'Verified Production preview authorization is required.',
        );
      }
      return TaxonomyDependencyPlan(
        environment: config.environment,
        capability: TaxonomyRuntimeCapability.canonicalV1(
          proof: authorization.contractProof,
        ),
        contractAssessment: TaxonomyCapabilityAssessment(
          compatibility: TaxonomyContractCompatibility.match,
          blockers: const [],
          adapterDifferences: const [],
          proof: authorization.contractProof,
        ),
        registerDevelopmentRpcAdapter: false,
        registerProductionPreviewAdapter: true,
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
