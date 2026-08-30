import 'dart:collection';

import 'package:equatable/equatable.dart';

enum TaxonomyRuntimeMode { legacyRuntime, canonicalV1Runtime }

enum TaxonomyBackendFeature {
  roots,
  children,
  descendants,
  breadcrumb,
  aliasResolution,
  search,
  productScopes,
}

enum TaxonomyBackendEvidence {
  authoritativeContractVersion,
  exactRpcSignatures,
  requiredResponseShapes,
  lifecyclePublicationSemantics,
  hierarchySemantics,
  aliasOutcomeSemantics,
  taxonomyVersionSemantics,
}

enum TaxonomyBackendRuntimeReadiness {
  unsupported,
  supportedPreviewOff,
  supportedPreviewOn,
}

class TaxonomyBackendContractProof extends Equatable {
  TaxonomyBackendContractProof({
    required String contractVersion,
    required String taxonomyVersion,
    required String rpcContractVersion,
    required this.rpcGeneration,
    required Iterable<TaxonomyBackendFeature> supportedFeatures,
    required Iterable<TaxonomyBackendEvidence> verifiedEvidence,
    required this.previewSupported,
    required this.previewEnabled,
    required this.lifecycleMetadata,
    required this.policyMetadata,
    required this.aliasStateMetadata,
    required this.pathMetadata,
    required this.publicActiveRootCount,
    required this.pilotActiveRootCount,
    required this.previewRootCount,
    required String productScopeContract,
    required this.productScopeRequiresAssignable,
    required this.productScopePolicyFailClosed,
  }) : contractVersion = _requiredText(contractVersion, 'contractVersion'),
       taxonomyVersion = _requiredText(taxonomyVersion, 'taxonomyVersion'),
       rpcContractVersion = _requiredText(
         rpcContractVersion,
         'rpcContractVersion',
       ),
       productScopeContract = _requiredText(
         productScopeContract,
         'productScopeContract',
       ),
       supportedFeatures = UnmodifiableSetView(
         Set<TaxonomyBackendFeature>.of(supportedFeatures),
       ),
       verifiedEvidence = UnmodifiableSetView(
         Set<TaxonomyBackendEvidence>.of(verifiedEvidence),
       );

  static const supportedClientContractVersion = 'taxonomy-client-v1';
  static const supportedTaxonomyVersion = 'canonical-v1.0.0';
  static const supportedRpcContractVersion = 'taxonomy-rpc-v2';
  static const supportedRpcGeneration = 2;
  static const supportedProductScopeContract =
      'exact-leaf-visible-assignable-policy-eligible';
  static const requiredCanonicalV1Features = <TaxonomyBackendFeature>{
    TaxonomyBackendFeature.roots,
    TaxonomyBackendFeature.children,
    TaxonomyBackendFeature.descendants,
    TaxonomyBackendFeature.breadcrumb,
    TaxonomyBackendFeature.aliasResolution,
    TaxonomyBackendFeature.search,
    TaxonomyBackendFeature.productScopes,
  };
  static const requiredCanonicalV1Evidence = <TaxonomyBackendEvidence>{
    TaxonomyBackendEvidence.authoritativeContractVersion,
    TaxonomyBackendEvidence.exactRpcSignatures,
    TaxonomyBackendEvidence.requiredResponseShapes,
    TaxonomyBackendEvidence.lifecyclePublicationSemantics,
    TaxonomyBackendEvidence.hierarchySemantics,
    TaxonomyBackendEvidence.aliasOutcomeSemantics,
    TaxonomyBackendEvidence.taxonomyVersionSemantics,
  };

  final String contractVersion;
  final String taxonomyVersion;
  final String rpcContractVersion;
  final int rpcGeneration;
  final Set<TaxonomyBackendFeature> supportedFeatures;
  final Set<TaxonomyBackendEvidence> verifiedEvidence;
  final bool previewSupported;
  final bool previewEnabled;
  final bool lifecycleMetadata;
  final bool policyMetadata;
  final bool aliasStateMetadata;
  final bool pathMetadata;
  final int publicActiveRootCount;
  final int pilotActiveRootCount;
  final int previewRootCount;
  final String productScopeContract;
  final bool productScopeRequiresAssignable;
  final bool productScopePolicyFailClosed;

  bool get supportsCanonicalV1 =>
      contractVersion == supportedClientContractVersion &&
      taxonomyVersion == supportedTaxonomyVersion &&
      rpcContractVersion == supportedRpcContractVersion &&
      rpcGeneration == supportedRpcGeneration &&
      supportedFeatures.containsAll(requiredCanonicalV1Features) &&
      verifiedEvidence.containsAll(requiredCanonicalV1Evidence) &&
      previewSupported &&
      lifecycleMetadata &&
      policyMetadata &&
      aliasStateMetadata &&
      pathMetadata &&
      productScopeContract == supportedProductScopeContract &&
      productScopeRequiresAssignable &&
      productScopePolicyFailClosed &&
      publicActiveRootCount >= 0 &&
      pilotActiveRootCount >= 0 &&
      previewRootCount >= 0;

  TaxonomyBackendRuntimeReadiness get runtimeReadiness {
    if (!supportsCanonicalV1) {
      return TaxonomyBackendRuntimeReadiness.unsupported;
    }
    return previewEnabled
        ? TaxonomyBackendRuntimeReadiness.supportedPreviewOn
        : TaxonomyBackendRuntimeReadiness.supportedPreviewOff;
  }

  bool get hasCustomerVisibleRoots =>
      publicActiveRootCount > 0 || (previewEnabled && previewRootCount > 0);

  bool get canStartDevelopmentAcceptance =>
      supportsCanonicalV1 && hasCustomerVisibleRoots;

  static String _requiredText(String value, String fieldName) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'Value cannot be empty.');
    }
    return normalized;
  }

  @override
  List<Object?> get props => [
    contractVersion,
    taxonomyVersion,
    rpcContractVersion,
    rpcGeneration,
    supportedFeatures,
    verifiedEvidence,
    previewSupported,
    previewEnabled,
    lifecycleMetadata,
    policyMetadata,
    aliasStateMetadata,
    pathMetadata,
    publicActiveRootCount,
    pilotActiveRootCount,
    previewRootCount,
    productScopeContract,
    productScopeRequiresAssignable,
    productScopePolicyFailClosed,
  ];
}

class TaxonomyRuntimeCapability extends Equatable {
  const TaxonomyRuntimeCapability.legacy()
    : mode = TaxonomyRuntimeMode.legacyRuntime,
      proof = null;

  factory TaxonomyRuntimeCapability.canonicalV1({
    required TaxonomyBackendContractProof proof,
  }) {
    if (!proof.supportsCanonicalV1) {
      throw ArgumentError.value(
        proof,
        'proof',
        'Canonical V1 requires an exact compatible backend contract proof.',
      );
    }
    if (!proof.hasCustomerVisibleRoots) {
      throw ArgumentError.value(
        proof,
        'proof',
        'Canonical V1 acceptance requires public roots or an enabled preview '
            'projection with roots.',
      );
    }
    return TaxonomyRuntimeCapability._(
      mode: TaxonomyRuntimeMode.canonicalV1Runtime,
      proof: proof,
    );
  }

  const TaxonomyRuntimeCapability._({required this.mode, required this.proof});

  static const currentDefault = TaxonomyRuntimeCapability.legacy();

  final TaxonomyRuntimeMode mode;
  final TaxonomyBackendContractProof? proof;

  bool get isLegacy => mode == TaxonomyRuntimeMode.legacyRuntime;
  bool get isCanonicalV1 => mode == TaxonomyRuntimeMode.canonicalV1Runtime;
  String? get taxonomyVersion => proof?.taxonomyVersion;

  void requireCanonicalVersion(String? value) {
    if (!isCanonicalV1 || proof == null) {
      throw StateError('Canonical taxonomy capability is not active.');
    }
    final normalized = value?.trim();
    if (normalized == null || normalized != proof!.taxonomyVersion) {
      throw StateError('Taxonomy version does not match capability proof.');
    }
  }

  @override
  List<Object?> get props => [mode, proof];
}
