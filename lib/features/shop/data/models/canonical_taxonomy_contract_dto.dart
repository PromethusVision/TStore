import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

class CanonicalTaxonomyCategoryDto extends Equatable {
  const CanonicalTaxonomyCategoryDto._({
    required this.id,
    required this.parentId,
    required this.name,
    required this.slug,
    required this.level,
    required this.lifecycleState,
    required this.isAssignable,
    required this.policyClass,
    required this.professionalReviewStatus,
    required this.taxonomyVersion,
    required this.hasChildren,
    required this.sortOrder,
    required this.isPublicActive,
    required this.isPilotActive,
    required this.previewContext,
  });

  factory CanonicalTaxonomyCategoryDto.fromRpcPayload(
    Map<String, dynamic> payload,
  ) {
    final hasChildren = _readNodeShape(payload);
    return CanonicalTaxonomyCategoryDto._(
      id: _requiredString(payload, 'id'),
      parentId: _optionalString(payload, 'parent_id'),
      name: _requiredString(payload, 'name'),
      slug: _requiredString(payload, 'slug'),
      level: _readLevel(payload['level']),
      lifecycleState: _readLifecycle(payload['lifecycle_state']),
      isAssignable: _requiredBool(payload, 'is_assignable'),
      policyClass: _readPolicyClass(payload['policy_class']),
      professionalReviewStatus: _readProfessionalReviewStatus(
        payload['professional_review_status'],
      ),
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
      hasChildren: hasChildren,
      sortOrder: _optionalInt(payload, 'sort_order') ?? 0,
      isPublicActive: _requiredBool(payload, 'is_public_active'),
      isPilotActive: _requiredBool(payload, 'is_pilot_active'),
      previewContext: _requiredBool(payload, 'preview_context'),
    );
  }

  final String id;
  final String? parentId;
  final String name;
  final String slug;
  final TaxonomyCategoryLevel level;
  final TaxonomyCategoryLifecycle lifecycleState;
  final bool isAssignable;
  final TaxonomyPolicyClass policyClass;
  final TaxonomyProfessionalReviewStatus professionalReviewStatus;
  final String taxonomyVersion;
  final bool hasChildren;
  final int sortOrder;
  final bool isPublicActive;
  final bool isPilotActive;
  final bool previewContext;

  TaxonomyCategoryNode toDomain() {
    return TaxonomyCategoryNode(
      id: id,
      displayName: name,
      parentId: parentId,
      slug: slug,
      level: level,
      kind: hasChildren
          ? TaxonomyCategoryKind.container
          : TaxonomyCategoryKind.leaf,
      lifecycle: lifecycleState,
      assignability: isAssignable
          ? TaxonomyCategoryAssignability.assignable
          : TaxonomyCategoryAssignability.notAssignable,
      policyClass: policyClass,
      professionalReviewStatus: professionalReviewStatus,
      taxonomyVersion: taxonomyVersion,
      sortOrder: sortOrder,
      isPreviewContext: previewContext,
    );
  }

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    slug,
    level,
    lifecycleState,
    isAssignable,
    policyClass,
    professionalReviewStatus,
    taxonomyVersion,
    hasChildren,
    sortOrder,
    isPublicActive,
    isPilotActive,
    previewContext,
  ];
}

class CanonicalTaxonomyCapabilityDto extends Equatable {
  const CanonicalTaxonomyCapabilityDto._({
    required this.contractVersion,
    required this.clientContractVersion,
    required this.taxonomyVersion,
    required this.taxonomyDataVersion,
    required this.rpcContractVersion,
    required this.rpcGeneration,
    required this.supportedFeatures,
    required this.verifiedEvidence,
    required this.previewSupport,
    required this.previewEnabled,
    required this.lifecycleMetadata,
    required this.policyMetadata,
    required this.aliasStateMetadata,
    required this.pathMetadata,
    required this.publicActiveRootCount,
    required this.pilotActiveRootCount,
    required this.previewRootCount,
    required this.productScopeContract,
    required this.productScopeRequiresAssignable,
    required this.productScopePolicyFailClosed,
  });

  factory CanonicalTaxonomyCapabilityDto.fromRpcPayload(
    Map<String, dynamic> payload,
  ) {
    final rawFeatures = payload['supported_features'];
    if (rawFeatures is! List) {
      throw const FormatException('supported_features must be a list.');
    }
    final rawEvidence = payload['verified_evidence'];
    if (rawEvidence is! List) {
      throw const FormatException('verified_evidence must be a list.');
    }
    final contractVersion = _requiredString(payload, 'contract_version');
    final clientContractVersion = _requiredString(
      payload,
      'client_contract_version',
    );
    final taxonomyVersion = _requiredString(payload, 'taxonomy_version');
    final taxonomyDataVersion = _requiredString(
      payload,
      'taxonomy_data_version',
    );
    if (contractVersion != clientContractVersion) {
      throw const FormatException('Client contract versions differ.');
    }
    if (taxonomyVersion != taxonomyDataVersion) {
      throw const FormatException('Taxonomy data versions differ.');
    }
    return CanonicalTaxonomyCapabilityDto._(
      contractVersion: contractVersion,
      clientContractVersion: clientContractVersion,
      taxonomyVersion: taxonomyVersion,
      taxonomyDataVersion: taxonomyDataVersion,
      rpcContractVersion: _requiredString(payload, 'rpc_contract_version'),
      rpcGeneration: _requiredInt(payload, 'rpc_generation'),
      supportedFeatures: rawFeatures.map(_readBackendFeature).toSet(),
      verifiedEvidence: rawEvidence.map(_readBackendEvidence).toSet(),
      previewSupport: _requiredBool(payload, 'preview_support'),
      previewEnabled: _requiredBool(payload, 'preview_enabled'),
      lifecycleMetadata: _requiredBool(payload, 'lifecycle_metadata'),
      policyMetadata: _requiredBool(payload, 'policy_metadata'),
      aliasStateMetadata: _requiredBool(payload, 'alias_state_metadata'),
      pathMetadata: _requiredBool(payload, 'path_metadata'),
      publicActiveRootCount: _requiredNonNegativeInt(
        payload,
        'public_active_root_count',
      ),
      pilotActiveRootCount: _requiredNonNegativeInt(
        payload,
        'pilot_active_root_count',
      ),
      previewRootCount: _requiredNonNegativeInt(payload, 'preview_root_count'),
      productScopeContract: _requiredString(payload, 'product_scope_contract'),
      productScopeRequiresAssignable: _requiredBool(
        payload,
        'product_scope_requires_assignable',
      ),
      productScopePolicyFailClosed: _requiredBool(
        payload,
        'product_scope_policy_fail_closed',
      ),
    );
  }

  final String contractVersion;
  final String clientContractVersion;
  final String taxonomyVersion;
  final String taxonomyDataVersion;
  final String rpcContractVersion;
  final int rpcGeneration;
  final Set<TaxonomyBackendFeature> supportedFeatures;
  final Set<TaxonomyBackendEvidence> verifiedEvidence;
  final bool previewSupport;
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

  TaxonomyBackendContractProof toProof() {
    return TaxonomyBackendContractProof(
      contractVersion: contractVersion,
      taxonomyVersion: taxonomyVersion,
      rpcContractVersion: rpcContractVersion,
      rpcGeneration: rpcGeneration,
      supportedFeatures: supportedFeatures,
      verifiedEvidence: verifiedEvidence,
      previewSupported: previewSupport,
      previewEnabled: previewEnabled,
      lifecycleMetadata: lifecycleMetadata,
      policyMetadata: policyMetadata,
      aliasStateMetadata: aliasStateMetadata,
      pathMetadata: pathMetadata,
      publicActiveRootCount: publicActiveRootCount,
      pilotActiveRootCount: pilotActiveRootCount,
      previewRootCount: previewRootCount,
      productScopeContract: productScopeContract,
      productScopeRequiresAssignable: productScopeRequiresAssignable,
      productScopePolicyFailClosed: productScopePolicyFailClosed,
    );
  }

  @override
  List<Object?> get props => [
    contractVersion,
    clientContractVersion,
    taxonomyVersion,
    taxonomyDataVersion,
    rpcContractVersion,
    rpcGeneration,
    supportedFeatures,
    verifiedEvidence,
    previewSupport,
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

class CanonicalTaxonomyAliasResolutionDto extends Equatable {
  const CanonicalTaxonomyAliasResolutionDto._({
    required this.locator,
    required this.state,
    required this.targetCategoryId,
    required this.taxonomyVersion,
    required this.aliasKind,
    required this.matchedViaAlias,
    required this.targetCount,
  });

  factory CanonicalTaxonomyAliasResolutionDto.fromRpcPayload(
    Map<String, dynamic> payload,
  ) {
    final state = _readAliasState(payload['resolution_state']);
    final targetCategoryId = _optionalString(
      payload,
      'direct_target_category_id',
    );
    final targetCount = _requiredNonNegativeInt(payload, 'target_count');
    final matchedViaAlias = _requiredBool(payload, 'matched_via_alias');
    final resolved = state == TaxonomyAliasResolutionState.resolved;
    final ambiguous = state == TaxonomyAliasResolutionState.ambiguous;
    if (resolved != (targetCategoryId != null && targetCount == 1) ||
        (!resolved && targetCategoryId != null) ||
        (ambiguous && targetCount < 2) ||
        (!resolved && !ambiguous && targetCount != 0) ||
        !matchedViaAlias) {
      throw const FormatException('Alias state and target evidence differ.');
    }
    return CanonicalTaxonomyAliasResolutionDto._(
      locator: _requiredString(payload, 'alias_locator'),
      state: state,
      targetCategoryId: targetCategoryId,
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
      aliasKind: _requiredString(payload, 'alias_kind'),
      matchedViaAlias: matchedViaAlias,
      targetCount: targetCount,
    );
  }

  final String locator;
  final TaxonomyAliasResolutionState state;
  final String? targetCategoryId;
  final String taxonomyVersion;
  final String aliasKind;
  final bool matchedViaAlias;
  final int targetCount;

  TaxonomyAliasResolution toDomain() {
    return TaxonomyAliasResolution(
      locator: locator,
      state: state,
      targetCategoryId: targetCategoryId,
      taxonomyVersion: taxonomyVersion,
    );
  }

  @override
  List<Object?> get props => [
    locator,
    state,
    targetCategoryId,
    taxonomyVersion,
    aliasKind,
    matchedViaAlias,
    targetCount,
  ];
}

class CanonicalTaxonomySearchResultDto extends Equatable {
  const CanonicalTaxonomySearchResultDto._({
    required this.matchedNode,
    required this.path,
    required this.taxonomyVersion,
    required this.aliasContext,
    required this.matchKind,
    required this.matchedViaAlias,
  });

  factory CanonicalTaxonomySearchResultDto.fromRpcPayload(
    Map<String, dynamic> payload,
  ) {
    final rawMatchedNode = payload['matched_node'];
    final rawPath = payload['path'];
    if (rawMatchedNode is! Map<String, dynamic>) {
      throw const FormatException('matched_node must be an object.');
    }
    if (rawPath is! List || rawPath.isEmpty) {
      throw const FormatException('path must be a non-empty list.');
    }
    final path = rawPath
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Every path item must be an object.');
          }
          return CanonicalTaxonomyCategoryDto.fromRpcPayload(item);
        })
        .toList(growable: false);

    final rawAlias = payload['alias_context'];
    TaxonomySearchAliasContext? aliasContext;
    if (rawAlias != null) {
      if (rawAlias is! Map<String, dynamic>) {
        throw const FormatException('alias_context must be an object.');
      }
      aliasContext = TaxonomySearchAliasContext(
        matchedText: _requiredString(rawAlias, 'matched_text'),
        locator: _requiredString(rawAlias, 'locator'),
      );
    }

    final matchedViaAlias = _requiredBool(payload, 'matched_via_alias');
    if (matchedViaAlias != (aliasContext != null)) {
      throw const FormatException('Search alias evidence is inconsistent.');
    }
    return CanonicalTaxonomySearchResultDto._(
      matchedNode: CanonicalTaxonomyCategoryDto.fromRpcPayload(rawMatchedNode),
      path: path,
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
      aliasContext: aliasContext,
      matchKind: _requiredString(payload, 'match_kind'),
      matchedViaAlias: matchedViaAlias,
    );
  }

  final CanonicalTaxonomyCategoryDto matchedNode;
  final List<CanonicalTaxonomyCategoryDto> path;
  final String taxonomyVersion;
  final TaxonomySearchAliasContext? aliasContext;
  final String matchKind;
  final bool matchedViaAlias;

  TaxonomyCategorySearchContext toDomain() {
    if (matchedNode.taxonomyVersion != taxonomyVersion ||
        path.any((node) => node.taxonomyVersion != taxonomyVersion)) {
      throw const FormatException('Search result taxonomy versions differ.');
    }
    if (path.last.id != matchedNode.id) {
      throw const FormatException('Search path must end at matched_node.');
    }
    final hierarchy = TaxonomyCategoryHierarchy.fromNodes(
      path.map((node) => node.toDomain()),
    );
    return TaxonomyCategorySearchContext.fromHierarchy(
      hierarchy: hierarchy,
      matchedCategoryId: matchedNode.id,
      aliasContext: aliasContext,
    );
  }

  @override
  List<Object?> get props => [
    matchedNode,
    path,
    taxonomyVersion,
    aliasContext,
    matchKind,
    matchedViaAlias,
  ];
}

bool _readNodeShape(Map<String, dynamic> payload) {
  final rawHasChildren = payload['has_children'];
  final rawIsLeaf = payload['is_leaf'];
  if (rawHasChildren == null && rawIsLeaf == null) {
    throw const FormatException(
      'Canonical node requires has_children or is_leaf.',
    );
  }
  if (rawHasChildren != null && rawHasChildren is! bool) {
    throw const FormatException('has_children must be a boolean.');
  }
  if (rawIsLeaf != null && rawIsLeaf is! bool) {
    throw const FormatException('is_leaf must be a boolean.');
  }
  if (rawHasChildren != null &&
      rawIsLeaf != null &&
      rawHasChildren == rawIsLeaf) {
    throw const FormatException(
      'has_children and is_leaf signals are inconsistent.',
    );
  }
  return rawHasChildren as bool? ?? !(rawIsLeaf as bool);
}

TaxonomyCategoryLevel _readLevel(Object? value) {
  return switch (value) {
    1 => TaxonomyCategoryLevel.l1,
    2 => TaxonomyCategoryLevel.l2,
    3 => TaxonomyCategoryLevel.l3,
    4 => TaxonomyCategoryLevel.l4,
    _ => throw const FormatException('level must be an integer from 1 to 4.'),
  };
}

TaxonomyCategoryLifecycle _readLifecycle(Object? value) {
  return switch (value) {
    'staged' => TaxonomyCategoryLifecycle.staged,
    'active' => TaxonomyCategoryLifecycle.active,
    'retired' => TaxonomyCategoryLifecycle.retired,
    _ => throw const FormatException('Unsupported lifecycle_state.'),
  };
}

TaxonomyPolicyClass _readPolicyClass(Object? value) {
  return switch (value) {
    'NORMAL' => TaxonomyPolicyClass.normal,
    'AGE_RESTRICTED' => TaxonomyPolicyClass.ageRestricted,
    'REGULATED' => TaxonomyPolicyClass.regulated,
    'LEGAL_REVIEW_REQUIRED' => TaxonomyPolicyClass.legalReviewRequired,
    'EXCLUDED' => TaxonomyPolicyClass.excluded,
    _ => throw const FormatException('Unsupported policy_class.'),
  };
}

TaxonomyProfessionalReviewStatus _readProfessionalReviewStatus(Object? value) {
  return switch (value) {
    'not_required' => TaxonomyProfessionalReviewStatus.notRequired,
    'pending' => TaxonomyProfessionalReviewStatus.pending,
    'approved' => TaxonomyProfessionalReviewStatus.approved,
    'rejected' => TaxonomyProfessionalReviewStatus.rejected,
    _ => throw const FormatException('Unsupported professional_review_status.'),
  };
}

TaxonomyAliasResolutionState _readAliasState(Object? value) {
  return switch (value) {
    'RESOLVED' => TaxonomyAliasResolutionState.resolved,
    'AMBIGUOUS' => TaxonomyAliasResolutionState.ambiguous,
    'TOMBSTONE' => TaxonomyAliasResolutionState.tombstone,
    'UNRESOLVED' => TaxonomyAliasResolutionState.unresolved,
    _ => throw const FormatException('Unsupported resolution_state.'),
  };
}

TaxonomyBackendFeature _readBackendFeature(Object? value) {
  return switch (value) {
    'roots' => TaxonomyBackendFeature.roots,
    'children' => TaxonomyBackendFeature.children,
    'descendants' => TaxonomyBackendFeature.descendants,
    'breadcrumb' => TaxonomyBackendFeature.breadcrumb,
    'alias_resolution' => TaxonomyBackendFeature.aliasResolution,
    'search' => TaxonomyBackendFeature.search,
    'product_scopes' => TaxonomyBackendFeature.productScopes,
    _ => throw const FormatException('Unsupported taxonomy backend feature.'),
  };
}

TaxonomyBackendEvidence _readBackendEvidence(Object? value) {
  return switch (value) {
    'authoritative_contract_version' =>
      TaxonomyBackendEvidence.authoritativeContractVersion,
    'exact_rpc_signatures' => TaxonomyBackendEvidence.exactRpcSignatures,
    'required_response_shapes' =>
      TaxonomyBackendEvidence.requiredResponseShapes,
    'lifecycle_publication_semantics' =>
      TaxonomyBackendEvidence.lifecyclePublicationSemantics,
    'hierarchy_semantics' => TaxonomyBackendEvidence.hierarchySemantics,
    'alias_outcome_semantics' => TaxonomyBackendEvidence.aliasOutcomeSemantics,
    'taxonomy_version_semantics' =>
      TaxonomyBackendEvidence.taxonomyVersionSemantics,
    _ => throw const FormatException('Unsupported taxonomy backend evidence.'),
  };
}

String _requiredString(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value.trim();
}

String? _optionalString(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be null or a non-empty string.');
  }
  return value.trim();
}

bool _requiredBool(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is! bool) throw FormatException('$key must be a boolean.');
  return value;
}

int? _optionalInt(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value == null) return null;
  if (value is! int) throw FormatException('$key must be an integer.');
  return value;
}

int _requiredInt(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is! int) throw FormatException('$key must be an integer.');
  return value;
}

int _requiredNonNegativeInt(Map<String, dynamic> payload, String key) {
  final value = _requiredInt(payload, key);
  if (value < 0) throw FormatException('$key cannot be negative.');
  return value;
}
