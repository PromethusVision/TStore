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
      expect(node.taxonomyVersion, 'v1.0.0');
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
  });

  test('capability DTO requires the complete exact client-v1 feature set', () {
    final dto = CanonicalTaxonomyCapabilityDto.fromRpcPayload({
      'contract_version': 'taxonomy-client-v1',
      'taxonomy_version': 'v1.0.0',
      'supported_features': [
        'roots',
        'children',
        'descendants',
        'breadcrumb',
        'alias_resolution',
        'search',
        'product_scopes',
      ],
    });
    final capability = TaxonomyRuntimeCapability.canonicalV1(
      proof: dto.toProof(),
    );

    expect(capability.isCanonicalV1, isTrue);
    expect(capability.taxonomyVersion, 'v1.0.0');
  });

  test('incomplete or wrong capability proof cannot enable canonical mode', () {
    final incomplete = TaxonomyBackendContractProof(
      contractVersion: 'taxonomy-client-v1',
      taxonomyVersion: 'v1.0.0',
      supportedFeatures: const [TaxonomyBackendFeature.roots],
    );
    final wrongVersion = TaxonomyBackendContractProof(
      contractVersion: 'taxonomy-client-v2',
      taxonomyVersion: 'v1.0.0',
      supportedFeatures:
          TaxonomyBackendContractProof.requiredCanonicalV1Features,
    );

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
      'taxonomy_version': 'v1.0.0',
    });

    expect(dto.toDomain().state, TaxonomyAliasResolutionState.tombstone);
    expect(dto.toDomain().canRedirect, isFalse);
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
      'taxonomy_version': 'v1.0.0',
      'alias_context': {
        'matched_text': 'saç cihazı',
        'locator': 'search/sac-cihazi',
      },
    }).toDomain();

    expect(result.matchedCategory.id, 'leaf');
    expect(result.breadcrumb.items, hasLength(3));
    expect(result.aliasContext?.matchedText, 'saç cihazı');
    expect(result.taxonomyVersion, 'v1.0.0');
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
    'taxonomy_version': 'v1.0.0',
    'has_children': hasChildren,
    'sort_order': sortOrder,
  };
}
