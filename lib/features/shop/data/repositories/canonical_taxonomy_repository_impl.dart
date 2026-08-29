import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/data/models/canonical_taxonomy_contract_dto.dart';
import 'package:t_store/features/shop/data/services/canonical_taxonomy_contract_adapter.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';

class CanonicalTaxonomyRepositoryImpl implements CanonicalTaxonomyRepository {
  const CanonicalTaxonomyRepositoryImpl({required this.adapter});

  final CanonicalTaxonomyContractAdapter adapter;

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getRoots() async {
    return _mapNodes(
      adapter.getRootsPayload,
      fallback: 'Canonical kategori kökleri okunamadı.',
    );
  }

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getChildren(
    String categoryId,
  ) async {
    final normalizedId = _normalizedId(categoryId);
    if (normalizedId == null) {
      return const Left('Canonical kategori kimliği geçersiz.');
    }
    return _mapNodes(
      () => adapter.getChildrenPayload(normalizedId),
      fallback: 'Canonical alt kategoriler okunamadı.',
    );
  }

  @override
  Future<Either<String, List<TaxonomyCategoryNode>>> getDescendants(
    String categoryId,
  ) async {
    final normalizedId = _normalizedId(categoryId);
    if (normalizedId == null) {
      return const Left('Canonical kategori kimliği geçersiz.');
    }
    return _mapNodes(
      () => adapter.getDescendantsPayload(normalizedId),
      fallback: 'Canonical kategori alt ağacı okunamadı.',
    );
  }

  @override
  Future<Either<String, TaxonomyBreadcrumb>> getBreadcrumb(
    String categoryId,
  ) async {
    final normalizedId = _normalizedId(categoryId);
    if (normalizedId == null) {
      return const Left('Canonical kategori kimliği geçersiz.');
    }
    try {
      final payload = await adapter.getBreadcrumbPayload(normalizedId);
      final nodes = _nodesFromPayload(payload);
      final hierarchy = TaxonomyCategoryHierarchy.fromNodes(nodes);
      final breadcrumb = hierarchy.breadcrumbFor(normalizedId);
      if (breadcrumb.current.categoryId != normalizedId) {
        throw const FormatException('Breadcrumb endpoint returned wrong node.');
      }
      return Right(breadcrumb);
    } on Object {
      return const Left('Canonical kategori yolu okunamadı.');
    }
  }

  @override
  Future<Either<String, TaxonomyAliasResolution>> resolveAlias(
    TaxonomyAliasLookup lookup,
  ) async {
    try {
      final payload = await adapter.resolveAliasPayload(lookup);
      return Right(
        CanonicalTaxonomyAliasResolutionDto.fromRpcPayload(payload).toDomain(),
      );
    } on Object {
      return const Left('Canonical kategori yönlendirmesi çözümlenemedi.');
    }
  }

  @override
  Future<Either<String, List<TaxonomyCategorySearchContext>>> searchTaxonomy(
    TaxonomySearchRequest request,
  ) async {
    try {
      final payload = await adapter.searchTaxonomyPayload(request);
      final results = payload
          .map(
            (item) => CanonicalTaxonomySearchResultDto.fromRpcPayload(
              item,
            ).toDomain(),
          )
          .toList(growable: false);
      return Right(results);
    } on Object {
      return const Left('Canonical kategori araması tamamlanamadı.');
    }
  }

  Future<Either<String, List<TaxonomyCategoryNode>>> _mapNodes(
    Future<List<Map<String, dynamic>>> Function() load, {
    required String fallback,
  }) async {
    try {
      return Right(_nodesFromPayload(await load()));
    } on Object {
      return Left(fallback);
    }
  }

  List<TaxonomyCategoryNode> _nodesFromPayload(
    List<Map<String, dynamic>> payload,
  ) {
    final ids = <String>{};
    return payload
        .map((item) {
          final node = CanonicalTaxonomyCategoryDto.fromRpcPayload(
            item,
          ).toDomain();
          if (!ids.add(node.id)) {
            throw const FormatException('Duplicate canonical category id.');
          }
          return node;
        })
        .toList(growable: false);
  }

  String? _normalizedId(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
