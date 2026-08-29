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

class TaxonomyBackendContractProof extends Equatable {
  TaxonomyBackendContractProof({
    required String contractVersion,
    required String taxonomyVersion,
    required Iterable<TaxonomyBackendFeature> supportedFeatures,
  }) : contractVersion = _requiredText(contractVersion, 'contractVersion'),
       taxonomyVersion = _requiredText(taxonomyVersion, 'taxonomyVersion'),
       supportedFeatures = UnmodifiableSetView(
         Set<TaxonomyBackendFeature>.of(supportedFeatures),
       );

  static const supportedClientContractVersion = 'taxonomy-client-v1';
  static const requiredCanonicalV1Features = <TaxonomyBackendFeature>{
    TaxonomyBackendFeature.roots,
    TaxonomyBackendFeature.children,
    TaxonomyBackendFeature.descendants,
    TaxonomyBackendFeature.breadcrumb,
    TaxonomyBackendFeature.aliasResolution,
    TaxonomyBackendFeature.search,
    TaxonomyBackendFeature.productScopes,
  };

  final String contractVersion;
  final String taxonomyVersion;
  final Set<TaxonomyBackendFeature> supportedFeatures;

  bool get supportsCanonicalV1 =>
      contractVersion == supportedClientContractVersion &&
      supportedFeatures.containsAll(requiredCanonicalV1Features);

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
    supportedFeatures,
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
