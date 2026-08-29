import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_alias_resolution.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';

class TaxonomyCategorySearchContext extends Equatable {
  const TaxonomyCategorySearchContext._({
    required this.matchedCategory,
    required this.breadcrumb,
    required this.navigationDecision,
    this.aliasContext,
  });

  factory TaxonomyCategorySearchContext.fromHierarchy({
    required TaxonomyCategoryHierarchy hierarchy,
    required String matchedCategoryId,
    TaxonomySearchAliasContext? aliasContext,
  }) {
    final category = hierarchy.nodeById(matchedCategoryId);
    if (category == null) {
      throw ArgumentError.value(
        matchedCategoryId,
        'matchedCategoryId',
        'Unknown category id.',
      );
    }
    return TaxonomyCategorySearchContext._(
      matchedCategory: category,
      breadcrumb: hierarchy.breadcrumbFor(category.id),
      navigationDecision: TaxonomyCategoryNavigationDecision.forCanonicalNode(
        category,
      ),
      aliasContext: aliasContext,
    );
  }

  final TaxonomyCategoryNode matchedCategory;
  final TaxonomyBreadcrumb breadcrumb;
  final TaxonomyCategoryNavigationDecision navigationDecision;
  final TaxonomySearchAliasContext? aliasContext;

  String get canonicalPathLabel => breadcrumb.fullLabel;
  String? get taxonomyVersion => matchedCategory.taxonomyVersion;
  bool get isLeaf => matchedCategory.isLeaf;
  bool get isContainer => matchedCategory.isContainer;

  @override
  List<Object?> get props => [
    matchedCategory,
    breadcrumb,
    navigationDecision,
    aliasContext,
  ];
}
