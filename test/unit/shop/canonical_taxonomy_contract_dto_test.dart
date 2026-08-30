import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/models/canonical_taxonomy_contract_dto.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

void main() {
  group('CanonicalTaxonomyCategoryDto', () {
    test('maps every versioned canonical field into the domain node', () {
      final dto = CanonicalTaxonomyCategoryDto.fromRpcPayload(
        _categoryPayload(
          id: 'leaf',
          parentId: 'parent',
          level: 3,
          hasChildren: false,
          isAssignable: true,
          sortOrder: 7,
        ),
      );
      final node = dto.toDomain();

      expect(node.id, 'leaf');
      expect(node.parentId, 'parent');
      expect(node.displayName, 'Canonical kategori');
      expect(node.slug, 'canonical-kategori');
      expect(node.level, TaxonomyCategoryLevel.l3);
      expect(node.kind, TaxonomyCategoryKind.leaf);
      expect(node.lifecycle, TaxonomyCategoryLifecycle.active);
      expect(node.assignability, TaxonomyCategoryAssignability.assignable);
      expect(node.policyClass, TaxonomyPolicyClass.normal);
      expect(
        node.professionalReviewStatus,
        TaxonomyProfessionalReviewStatus.notRequired,
      );
      expect(node.taxonomyVersion, 'canonical-v1.0.0');
      expect(node.sortOrder, 7);
      expect(node.canAssignProducts, isTrue);
    });

    test('accepts an explicit is_leaf signal without inferring from depth', () {
      final payload =
          _categoryPayload(
              id: 'container',
              parentId: 'root',
              level: 2,
              hasChildren: true,
              isAssignable: false,
            )
            ..remove('has_children')
            ..['is_leaf'] = false;

      expect(
        CanonicalTaxonomyCategoryDto.fromRpcPayload(
          payload,
        ).toDomain().isContainer,
        isTrue,
      );
    });

    test('rejects missing or contradictory leaf signals', () {
      final missing = _categoryPayload(
        id: 'leaf',
        parentId: 'root',
        level: 2,
        hasChildren: false,
        isAssignable: true,
      )..remove('has_children');
      final contradictory = _categoryPayload(
        id: 'leaf',
        parentId: 'root',
        level: 2,
        hasChildren: false,
        isAssignable: true,
      )..['is_leaf'] = false;

      expect(
        () => CanonicalTaxonomyCategoryDto.fromRpcPayload(missing),
        throwsFormatException,
      );
      expect(
        () => CanonicalTaxonomyCategoryDto.fromRpcPayload(contradictory),
        throwsFormatException,
      );
    });

    test('policy and professional review gates remain fail-closed', () {
      final regulated = CanonicalTaxonomyCategoryDto.fromRpcPayload(
        _categoryPayload(
          id: 'regulated',
          parentId: 'root',
          level: 2,
          hasChildren: false,
          isAssignable: true,
          policyClass: 'REGULATED',
          reviewStatus: 'pending',
        ),
      ).toDomain();
      final retired = CanonicalTaxonomyCategoryDto.fromRpcPayload(
        _categoryPayload(
          id: 'retired',
          parentId: 'root',
          level: 2,
          hasChildren: false,
          isAssignable: false,
          lifecycle: 'retired',
        ),
      ).toDomain();

      expect(regulated.isDiscoverable, isTrue);
      expect(regulated.canAssignProducts, isFalse);
      expect(
        TaxonomyCategoryNavigationDecision.forCanonicalNode(
          regulated,
        ).blockReason,
        TaxonomyCategoryBlockReason.policyBlocked,
      );
      expect(retired.isDiscoverable, isFalse);
      expect(
        TaxonomyCategoryNavigationDecision.forCanonicalNode(retired).action,
        TaxonomyCategoryNavigationAction.unavailable,
      );
    });

    test('staged nodes are navigable only in explicit preview context', () {
      final previewPayload = _categoryPayload(
        id: 'preview-root',
        level: 1,
        hasChildren: true,
        isAssignable: false,
        lifecycle: 'staged',
      )..['preview_context'] = true;
      final hiddenPayload = Map<String, dynamic>.from(previewPayload)
        ..['preview_context'] = false;

      final previewNode = CanonicalTaxonomyCategoryDto.fromRpcPayload(
        previewPayload,
      ).toDomain();
      final hiddenNode = CanonicalTaxonomyCategoryDto.fromRpcPayload(
        hiddenPayload,
      ).toDomain();

      expect(previewNode.isDiscoverable, isTrue);
      expect(
        TaxonomyCategoryNavigationDecision.forCanonicalNode(previewNode).action,
        TaxonomyCategoryNavigationAction.navigateDeeper,
      );
      expect(hiddenNode.isDiscoverable, isFalse);
    });
  });

  test('capability DTO requires the complete exact V2 evidence', () {
    final dto = CanonicalTaxonomyCapabilityDto.fromRpcPayload(
      _capabilityPayload(previewEnabled: true, previewRootCount: 24),
    );
    final capability = TaxonomyRuntimeCapability.canonicalV1(
      proof: dto.toProof(),
    );

    expect(capability.isCanonicalV1, isTrue);
    expect(capability.taxonomyVersion, 'canonical-v1.0.0');
  });

  test(
    'compatible preview-off proof stays distinct from runtime eligibility',
    () {
      final proof = CanonicalTaxonomyCapabilityDto.fromRpcPayload(
        _capabilityPayload(previewEnabled: false, previewRootCount: 0),
      ).toProof();

      expect(proof.supportsCanonicalV1, isTrue);
      expect(
        proof.runtimeReadiness,
        TaxonomyBackendRuntimeReadiness.supportedPreviewOff,
      );
      expect(proof.canStartDevelopmentAcceptance, isFalse);
      expect(
        () => TaxonomyRuntimeCapability.canonicalV1(proof: proof),
        throwsArgumentError,
      );
    },
  );

  test('version, generation, and evidence mismatches fail compatibility', () {
    for (final mutation in <void Function(Map<String, dynamic>)>[
      (payload) => payload['taxonomy_data_version'] = 'other',
      (payload) => payload['rpc_contract_version'] = 'taxonomy-rpc-v3',
      (payload) => payload['rpc_generation'] = 3,
      (payload) => (payload['verified_evidence'] as List).removeLast(),
      (payload) => payload['lifecycle_metadata'] = false,
      (payload) => payload['policy_metadata'] = false,
      (payload) => payload['product_scope_requires_assignable'] = false,
      (payload) => payload['product_scope_policy_fail_closed'] = false,
    ]) {
      final payload = _capabilityPayload(
        previewEnabled: true,
        previewRootCount: 24,
      );
      mutation(payload);
      try {
        final proof = CanonicalTaxonomyCapabilityDto.fromRpcPayload(
          payload,
        ).toProof();
        expect(proof.supportsCanonicalV1, isFalse);
      } on FormatException {
        // Cross-field version disagreement is rejected while decoding.
      }
    }
  });

  test('incomplete or wrong capability proof cannot enable canonical mode', () {
    final incomplete = _proof(
      supportedFeatures: const [TaxonomyBackendFeature.roots],
    );
    final wrongVersion = _proof(contractVersion: 'taxonomy-client-v2');

    expect(
      () => TaxonomyRuntimeCapability.canonicalV1(proof: incomplete),
      throwsArgumentError,
    );
    expect(
      () => TaxonomyRuntimeCapability.canonicalV1(proof: wrongVersion),
      throwsArgumentError,
    );
    expect(TaxonomyRuntimeCapability.currentDefault.isLegacy, isTrue);
  });

  test('alias DTO preserves tombstone and refuses a target', () {
    final dto = CanonicalTaxonomyAliasResolutionDto.fromRpcPayload({
      'alias_locator': 'legacy/kategori',
      'resolution_state': 'TOMBSTONE',
      'direct_target_category_id': null,
      'taxonomy_version': 'canonical-v1.0.0',
      'alias_kind': 'LEGACY',
      'matched_via_alias': true,
      'target_count': 0,
    });

    expect(dto.toDomain().state, TaxonomyAliasResolutionState.tombstone);
    expect(dto.toDomain().canRedirect, isFalse);
  });

  test('alias DTO rejects target evidence that contradicts its state', () {
    expect(
      () => CanonicalTaxonomyAliasResolutionDto.fromRpcPayload({
        'alias_locator': 'legacy/ambiguous',
        'resolution_state': 'AMBIGUOUS',
        'direct_target_category_id': 'unexpected-target',
        'taxonomy_version': 'canonical-v1.0.0',
        'alias_kind': 'LEGACY',
        'matched_via_alias': true,
        'target_count': 2,
      }),
      throwsFormatException,
    );
  });

  test('search DTO carries path, alias context, and one taxonomy version', () {
    final root = _categoryPayload(
      id: 'root',
      level: 1,
      hasChildren: true,
      isAssignable: false,
      name: 'Beyaz Eşya & Ev Aletleri',
      slug: 'beyaz-esya-ev-aletleri',
    );
    final parent = _categoryPayload(
      id: 'parent',
      parentId: 'root',
      level: 2,
      hasChildren: true,
      isAssignable: false,
      name: 'Elektrikli Kişisel Bakım Cihazları',
      slug: 'elektrikli-kisisel-bakim-cihazlari',
    );
    final leaf = _categoryPayload(
      id: 'leaf',
      parentId: 'parent',
      level: 3,
      hasChildren: false,
      isAssignable: true,
      name: 'Saç Bakım Cihazları',
      slug: 'sac-bakim-cihazlari',
    );
    final result = CanonicalTaxonomySearchResultDto.fromRpcPayload({
      'matched_node': leaf,
      'path': [root, parent, leaf],
      'taxonomy_version': 'canonical-v1.0.0',
      'alias_context': {
        'matched_text': 'saç cihazı',
        'locator': 'search/sac-cihazi',
      },
      'match_kind': 'LEGACY',
      'matched_via_alias': true,
    }).toDomain();

    expect(result.matchedCategory.id, 'leaf');
    expect(result.breadcrumb.items, hasLength(3));
    expect(result.aliasContext?.matchedText, 'saç cihazı');
    expect(result.taxonomyVersion, 'canonical-v1.0.0');
  });
}

Map<String, dynamic> _categoryPayload({
  required String id,
  required int level,
  required bool hasChildren,
  required bool isAssignable,
  String? parentId,
  String name = 'Canonical kategori',
  String slug = 'canonical-kategori',
  String lifecycle = 'active',
  String policyClass = 'NORMAL',
  String reviewStatus = 'not_required',
  int sortOrder = 0,
}) {
  return {
    'id': id,
    'parent_id': parentId,
    'name': name,
    'slug': slug,
    'level': level,
    'lifecycle_state': lifecycle,
    'is_assignable': isAssignable,
    'policy_class': policyClass,
    'professional_review_status': reviewStatus,
    'taxonomy_version': 'canonical-v1.0.0',
    'has_children': hasChildren,
    'sort_order': sortOrder,
    'is_public_active': true,
    'is_pilot_active': false,
    'preview_context': false,
  };
}

Map<String, dynamic> _capabilityPayload({
  required bool previewEnabled,
  required int previewRootCount,
}) {
  return {
    'contract_version': 'taxonomy-client-v1',
    'client_contract_version': 'taxonomy-client-v1',
    'taxonomy_version': 'canonical-v1.0.0',
    'taxonomy_data_version': 'canonical-v1.0.0',
    'rpc_contract_version': 'taxonomy-rpc-v2',
    'rpc_generation': 2,
    'supported_features': [
      'roots',
      'children',
      'descendants',
      'breadcrumb',
      'alias_resolution',
      'search',
      'product_scopes',
    ],
    'verified_evidence': [
      'authoritative_contract_version',
      'exact_rpc_signatures',
      'required_response_shapes',
      'lifecycle_publication_semantics',
      'hierarchy_semantics',
      'alias_outcome_semantics',
      'taxonomy_version_semantics',
    ],
    'preview_support': true,
    'preview_enabled': previewEnabled,
    'lifecycle_metadata': true,
    'policy_metadata': true,
    'alias_state_metadata': true,
    'path_metadata': true,
    'public_active_root_count': 0,
    'pilot_active_root_count': 0,
    'preview_root_count': previewRootCount,
    'product_scope_contract': 'exact-leaf-visible-assignable-policy-eligible',
    'product_scope_requires_assignable': true,
    'product_scope_policy_fail_closed': true,
  };
}

TaxonomyBackendContractProof _proof({
  String contractVersion = 'taxonomy-client-v1',
  Iterable<TaxonomyBackendFeature> supportedFeatures =
      TaxonomyBackendContractProof.requiredCanonicalV1Features,
}) {
  return TaxonomyBackendContractProof(
    contractVersion: contractVersion,
    taxonomyVersion: 'canonical-v1.0.0',
    rpcContractVersion: 'taxonomy-rpc-v2',
    rpcGeneration: 2,
    supportedFeatures: supportedFeatures,
    verifiedEvidence: TaxonomyBackendContractProof.requiredCanonicalV1Evidence,
    previewSupported: true,
    previewEnabled: true,
    lifecycleMetadata: true,
    policyMetadata: true,
    aliasStateMetadata: true,
    pathMetadata: true,
    publicActiveRootCount: 0,
    pilotActiveRootCount: 0,
    previewRootCount: 24,
    productScopeContract:
        TaxonomyBackendContractProof.supportedProductScopeContract,
    productScopeRequiresAssignable: true,
    productScopePolicyFailClosed: true,
  );
}
