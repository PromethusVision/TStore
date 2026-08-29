import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

const canonicalTaxonomyVersion = 'v1.0.0';

const canonicalRootNames = [
  'Gıda & İçecek',
  'Giyim & Moda',
  'Ayakkabı',
  'Çanta & Aksesuar',
  'Elektronik',
  'Bilgisayar & Tablet',
  'Beyaz Eşya & Ev Aletleri',
  'Ev & Yaşam',
  'Züccaciye & Mutfak',
  'Yapı, Hırdavat & Tesisat',
  'Otomotiv & Motosiklet',
  'Kozmetik & Kişisel Bakım',
  'Anne & Bebek',
  'Oyuncak & Hobi',
  'Müzik & Enstrüman',
  'Spor & Outdoor',
  'Kitap',
  'Kırtasiye & Ofis',
  'Evcil Hayvan Ürünleri',
  'Gözlük & Optik',
  'Saat & Takı',
  'Sağlık & Medikal',
  'Çiçek & Bahçe',
  'Hediyelik & Parti',
];

TaxonomyRuntimeCapability canonicalCapability({
  String taxonomyVersion = canonicalTaxonomyVersion,
}) {
  return TaxonomyRuntimeCapability.canonicalV1(
    proof: TaxonomyBackendContractProof(
      contractVersion:
          TaxonomyBackendContractProof.supportedClientContractVersion,
      taxonomyVersion: taxonomyVersion,
      supportedFeatures:
          TaxonomyBackendContractProof.requiredCanonicalV1Features,
    ),
  );
}

List<TaxonomyCategoryNode> canonicalRoots({
  String taxonomyVersion = canonicalTaxonomyVersion,
}) {
  return [
    for (var index = 0; index < canonicalRootNames.length; index++)
      canonicalNode(
        id: 'root-${index + 1}',
        name: canonicalRootNames[index],
        level: TaxonomyCategoryLevel.l1,
        kind: TaxonomyCategoryKind.container,
        sortOrder: index + 1,
        taxonomyVersion: taxonomyVersion,
      ),
  ];
}

TaxonomyCategoryNode canonicalNode({
  required String id,
  required String name,
  required TaxonomyCategoryLevel level,
  required TaxonomyCategoryKind kind,
  String? parentId,
  int sortOrder = 0,
  bool assignable = false,
  String taxonomyVersion = canonicalTaxonomyVersion,
  TaxonomyCategoryLifecycle lifecycle = TaxonomyCategoryLifecycle.active,
  TaxonomyPolicyClass policyClass = TaxonomyPolicyClass.normal,
  TaxonomyProfessionalReviewStatus professionalReviewStatus =
      TaxonomyProfessionalReviewStatus.notRequired,
}) {
  return TaxonomyCategoryNode(
    id: id,
    displayName: name,
    slug: id,
    parentId: parentId,
    level: level,
    kind: kind,
    lifecycle: lifecycle,
    assignability: assignable
        ? TaxonomyCategoryAssignability.assignable
        : TaxonomyCategoryAssignability.notAssignable,
    sortOrder: sortOrder,
    taxonomyVersion: taxonomyVersion,
    policyClass: policyClass,
    professionalReviewStatus: professionalReviewStatus,
  );
}

class FakeCanonicalTaxonomyRepository implements CanonicalTaxonomyRepository {
  Either<String, List<TaxonomyCategoryNode>> rootsResult = const Right([]);
  final Map<String, Either<String, List<TaxonomyCategoryNode>>>
  childrenResults = {};
  final Map<String, Either<String, List<TaxonomyCategoryNode>>>
  descendantsResults = {};
  final Map<String, Either<String, TaxonomyBreadcrumb>> breadcrumbResults = {};
  Either<String, TaxonomyAliasResolution> aliasResult = const Left(
    'Alias fixture not configured.',
  );
  Either<String, List<TaxonomyCategorySearchContext>> searchResult =
      const Right([]);

  int rootsCallCount = 0;
  int searchCallCount = 0;
  final List<String> childrenCalls = [];
  final List<String> breadcrumbCalls = [];

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getRoots() async {
    rootsCallCount++;
    return rootsResult;
  }

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getChildren(
    String categoryId,
  ) async {
    childrenCalls.add(categoryId);
    return childrenResults[categoryId] ?? const Right([]);
  }

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getDescendants(
    String categoryId,
  ) async {
    return descendantsResults[categoryId] ?? const Right([]);
  }

  @override
  Future<Either<String, TaxonomyBreadcrumb>> getBreadcrumb(
    String categoryId,
  ) async {
    breadcrumbCalls.add(categoryId);
    return breadcrumbResults[categoryId] ??
        const Left('Breadcrumb fixture not configured.');
  }

  @override
  Future<Either<String, TaxonomyAliasResolution>> resolveAlias(
    TaxonomyAliasLookup lookup,
  ) async {
    return aliasResult;
  }

  @override
  Future<Either<String, List<TaxonomyCategorySearchContext>>> searchTaxonomy(
    TaxonomySearchRequest request,
  ) async {
    searchCallCount++;
    return searchResult;
  }
}
