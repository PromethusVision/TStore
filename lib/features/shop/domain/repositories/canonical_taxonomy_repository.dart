import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';

class TaxonomySearchRequest extends Equatable {
  TaxonomySearchRequest({
    required String query,
    this.limit = 20,
    String locale = 'tr-TR',
  }) : query = _requiredText(query, 'query'),
       locale = _requiredText(locale, 'locale') {
    if (limit < 1 || limit > 50) {
      throw ArgumentError.value(limit, 'limit', 'Limit must be 1 through 50.');
    }
  }

  final String query;
  final int limit;
  final String locale;

  @override
  List<Object?> get props => [query, limit, locale];
}

abstract class CanonicalTaxonomyRepository {
  Future<Either<String, List<TaxonomyCategoryNode>>> getRoots();

  Future<Either<String, List<TaxonomyCategoryNode>>> getChildren(
    String categoryId,
  );

  Future<Either<String, List<TaxonomyCategoryNode>>> getDescendants(
    String categoryId,
  );

  Future<Either<String, TaxonomyBreadcrumb>> getBreadcrumb(String categoryId);

  Future<Either<String, TaxonomyAliasResolution>> resolveAlias(
    TaxonomyAliasLookup lookup,
  );

  Future<Either<String, List<TaxonomyCategorySearchContext>>> searchTaxonomy(
    TaxonomySearchRequest request,
  );
}

String _requiredText(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'Value cannot be empty.');
  }
  return normalized;
}
