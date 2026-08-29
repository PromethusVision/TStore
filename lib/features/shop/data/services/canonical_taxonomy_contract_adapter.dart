import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';

abstract class CanonicalTaxonomyContractAdapter {
  Future<List<Map<String, dynamic>>> getRootsPayload();

  Future<List<Map<String, dynamic>>> getChildrenPayload(String categoryId);

  Future<List<Map<String, dynamic>>> getDescendantsPayload(String categoryId);

  Future<List<Map<String, dynamic>>> getBreadcrumbPayload(String categoryId);

  Future<Map<String, dynamic>> resolveAliasPayload(TaxonomyAliasLookup lookup);

  Future<List<Map<String, dynamic>>> searchTaxonomyPayload(
    TaxonomySearchRequest request,
  );
}
