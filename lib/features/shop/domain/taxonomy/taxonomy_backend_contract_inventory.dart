import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

enum TaxonomyContractCompatibility {
  match,
  backwardCompatibleAdapterDifference,
  blockingContractMismatch,
}

enum TaxonomyRpcSecurityMode { invoker, definer }

class TaxonomyRpcEndpointInventory extends Equatable {
  TaxonomyRpcEndpointInventory({
    required this.functionName,
    required Iterable<String> argumentNames,
    required Iterable<String> returnFields,
    required this.securityMode,
    required this.isStable,
    required this.searchPathPinnedToPublic,
    required this.anonExecute,
    required this.authenticatedExecute,
  }) : argumentNames = UnmodifiableListView(argumentNames.toList()),
       returnFields = UnmodifiableSetView(returnFields.toSet());

  final String functionName;
  final List<String> argumentNames;
  final Set<String> returnFields;
  final TaxonomyRpcSecurityMode securityMode;
  final bool isStable;
  final bool searchPathPinnedToPublic;
  final bool anonExecute;
  final bool authenticatedExecute;

  @override
  List<Object?> get props => [
    functionName,
    argumentNames,
    returnFields,
    securityMode,
    isStable,
    searchPathPinnedToPublic,
    anonExecute,
    authenticatedExecute,
  ];
}

class TaxonomyBackendContractInventory extends Equatable {
  TaxonomyBackendContractInventory({
    required String taxonomyVersion,
    required Map<String, TaxonomyRpcEndpointInventory> endpoints,
    required this.hasAuthoritativeCapabilityResponse,
    this.declaredClientContractVersion,
  }) : taxonomyVersion = _requiredText(taxonomyVersion, 'taxonomyVersion'),
       endpoints = UnmodifiableMapView(Map.of(endpoints));

  final String taxonomyVersion;
  final String? declaredClientContractVersion;
  final bool hasAuthoritativeCapabilityResponse;
  final Map<String, TaxonomyRpcEndpointInventory> endpoints;

  @override
  List<Object?> get props => [
    taxonomyVersion,
    declaredClientContractVersion,
    hasAuthoritativeCapabilityResponse,
    endpoints,
  ];
}

class TaxonomyCapabilityAssessment extends Equatable {
  TaxonomyCapabilityAssessment({
    required this.compatibility,
    required Iterable<String> blockers,
    required Iterable<String> adapterDifferences,
    this.proof,
  }) : blockers = UnmodifiableListView(blockers.toList()),
       adapterDifferences = UnmodifiableListView(adapterDifferences.toList());

  final TaxonomyContractCompatibility compatibility;
  final List<String> blockers;
  final List<String> adapterDifferences;
  final TaxonomyBackendContractProof? proof;

  bool get supportsCanonicalV1 =>
      compatibility != TaxonomyContractCompatibility.blockingContractMismatch &&
      blockers.isEmpty &&
      proof?.supportsCanonicalV1 == true;

  @override
  List<Object?> get props => [
    compatibility,
    blockers,
    adapterDifferences,
    proof,
  ];
}

class TaxonomyBackendCapabilityVerifier {
  const TaxonomyBackendCapabilityVerifier();

  static const requiredEndpointArguments = <String, List<String>>{
    'taxonomy_roots_v1': ['p_taxonomy_version'],
    'taxonomy_children_v1': ['p_parent_id', 'p_taxonomy_version'],
    'taxonomy_descendants_v1': ['p_category_id', 'p_taxonomy_version'],
    'taxonomy_exact_leaf_v1': ['p_category_id', 'p_taxonomy_version'],
    'taxonomy_breadcrumb_v1': ['p_category_id', 'p_taxonomy_version'],
    'taxonomy_resolve_alias_v1': ['p_alias_slug', 'p_taxonomy_version'],
    'taxonomy_search_context_v1': ['p_term', 'p_taxonomy_version'],
  };

  static const strictNodeFields = <String>{
    'id',
    'parent_id',
    'name',
    'slug',
    'level',
    'lifecycle_state',
    'is_assignable',
    'policy_class',
    'professional_review_status',
    'taxonomy_version',
    'has_children',
  };

  static const requiredResponseFields = <String, Set<String>>{
    'taxonomy_roots_v1': strictNodeFields,
    'taxonomy_children_v1': strictNodeFields,
    'taxonomy_descendants_v1': strictNodeFields,
    'taxonomy_breadcrumb_v1': strictNodeFields,
    'taxonomy_exact_leaf_v1': {'id', 'name', 'slug', 'taxonomy_version'},
    'taxonomy_resolve_alias_v1': {
      'alias_locator',
      'resolution_state',
      'direct_target_category_id',
      'taxonomy_version',
    },
    'taxonomy_search_context_v1': {
      'matched_node',
      'path',
      'alias_context',
      'taxonomy_version',
    },
  };

  TaxonomyCapabilityAssessment assess(
    TaxonomyBackendContractInventory inventory,
  ) {
    final blockers = <String>[];
    final adapterDifferences = <String>[];

    if (!inventory.hasAuthoritativeCapabilityResponse ||
        inventory.declaredClientContractVersion !=
            TaxonomyBackendContractProof.supportedClientContractVersion) {
      blockers.add(
        'Backend does not publish an authoritative taxonomy-client-v1 '
        'capability response.',
      );
    }

    for (final entry in requiredEndpointArguments.entries) {
      final endpoint = inventory.endpoints[entry.key];
      if (endpoint == null) {
        blockers.add('Missing required RPC ${entry.key}.');
        continue;
      }
      if (!_orderedEquals(endpoint.argumentNames, entry.value)) {
        blockers.add('${entry.key} has an incompatible argument signature.');
      }
      if (!endpoint.isStable ||
          !endpoint.searchPathPinnedToPublic ||
          !endpoint.anonExecute ||
          !endpoint.authenticatedExecute) {
        blockers.add('${entry.key} does not satisfy execution safety gates.');
      }

      final requiredFields = requiredResponseFields[entry.key]!;
      final missingFields = requiredFields.difference(endpoint.returnFields);
      if (missingFields.isNotEmpty) {
        blockers.add(
          '${entry.key} omits required response fields: '
          '${missingFields.toList()..sort()}.',
        );
      }
    }

    if (inventory
            .endpoints['taxonomy_children_v1']
            ?.argumentNames
            .firstOrNull ==
        'p_parent_id') {
      adapterDifferences.add(
        'Repository categoryId maps explicitly to p_parent_id.',
      );
    }
    if (inventory.endpoints.containsKey('taxonomy_exact_leaf_v1') &&
        inventory.endpoints.containsKey('taxonomy_descendants_v1')) {
      adapterDifferences.add(
        'Product scope qualification is split across exact-leaf and '
        'descendant-ID RPCs.',
      );
    }

    if (blockers.isNotEmpty) {
      return TaxonomyCapabilityAssessment(
        compatibility: TaxonomyContractCompatibility.blockingContractMismatch,
        blockers: blockers,
        adapterDifferences: adapterDifferences,
      );
    }

    final proof = TaxonomyBackendContractProof(
      contractVersion: inventory.declaredClientContractVersion!,
      taxonomyVersion: inventory.taxonomyVersion,
      supportedFeatures:
          TaxonomyBackendContractProof.requiredCanonicalV1Features,
      verifiedEvidence:
          TaxonomyBackendContractProof.requiredCanonicalV1Evidence,
    );
    return TaxonomyCapabilityAssessment(
      compatibility: adapterDifferences.isEmpty
          ? TaxonomyContractCompatibility.match
          : TaxonomyContractCompatibility.backwardCompatibleAdapterDifference,
      blockers: const [],
      adapterDifferences: adapterDifferences,
      proof: proof,
    );
  }

  bool _orderedEquals(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}

String _requiredText(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'Value cannot be empty.');
  }
  return normalized;
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
