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
  ];
}

class CanonicalTaxonomyCapabilityDto extends Equatable {
  const CanonicalTaxonomyCapabilityDto._({
    required this.contractVersion,
    required this.taxonomyVersion,
    required this.supportedFeatures,
    required this.verifiedEvidence,
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
    return CanonicalTaxonomyCapabilityDto._(
      contractVersion: _requiredString(payload, 'contract_version'),
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
      supportedFeatures: rawFeatures.map(_readBackendFeature).toSet(),
      verifiedEvidence: rawEvidence.map(_readBackendEvidence).toSet(),
    );
  }

  final String contractVersion;
  final String taxonomyVersion;
  final Set<TaxonomyBackendFeature> supportedFeatures;
  final Set<TaxonomyBackendEvidence> verifiedEvidence;

  TaxonomyBackendContractProof toProof() {
    return TaxonomyBackendContractProof(
      contractVersion: contractVersion,
      taxonomyVersion: taxonomyVersion,
      supportedFeatures: supportedFeatures,
      verifiedEvidence: verifiedEvidence,
    );
  }

  @override
  List<Object?> get props => [
    contractVersion,
    taxonomyVersion,
    supportedFeatures,
    verifiedEvidence,
  ];
}

class CanonicalTaxonomyAliasResolutionDto extends Equatable {
  const CanonicalTaxonomyAliasResolutionDto._({
    required this.locator,
    required this.state,
    required this.targetCategoryId,
    required this.taxonomyVersion,
  });

  factory CanonicalTaxonomyAliasResolutionDto.fromRpcPayload(
    Map<String, dynamic> payload,
  ) {
    return CanonicalTaxonomyAliasResolutionDto._(
      locator: _requiredString(payload, 'alias_locator'),
      state: _readAliasState(payload['resolution_state']),
      targetCategoryId: _optionalString(payload, 'direct_target_category_id'),
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
    );
  }

  final String locator;
  final TaxonomyAliasResolutionState state;
  final String? targetCategoryId;
  final String taxonomyVersion;

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
  ];
}

class CanonicalTaxonomySearchResultDto extends Equatable {
  const CanonicalTaxonomySearchResultDto._({
    required this.matchedNode,
    required this.path,
    required this.taxonomyVersion,
    required this.aliasContext,
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

    return CanonicalTaxonomySearchResultDto._(
      matchedNode: CanonicalTaxonomyCategoryDto.fromRpcPayload(rawMatchedNode),
      path: path,
      taxonomyVersion: _requiredString(payload, 'taxonomy_version'),
      aliasContext: aliasContext,
    );
  }

  final CanonicalTaxonomyCategoryDto matchedNode;
  final List<CanonicalTaxonomyCategoryDto> path;
  final String taxonomyVersion;
  final TaxonomySearchAliasContext? aliasContext;

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
  List<Object?> get props => [matchedNode, path, taxonomyVersion, aliasContext];
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
