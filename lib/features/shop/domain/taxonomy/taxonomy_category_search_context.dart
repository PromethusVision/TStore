import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';

class TaxonomyCategorySearchContext extends Equatable {
  const TaxonomyCategorySearchContext._({
    required this.matchedCategory,
    required this.breadcrumb,
    required this.navigationDecision,
  });

  factory TaxonomyCategorySearchContext.fromHierarchy({
    required TaxonomyCategoryHierarchy hierarchy,
    required String matchedCategoryId,
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
    );
  }

  final TaxonomyCategoryNode matchedCategory;
  final TaxonomyBreadcrumb breadcrumb;
  final TaxonomyCategoryNavigationDecision navigationDecision;

  String get canonicalPathLabel => breadcrumb.fullLabel;
  bool get isLeaf => matchedCategory.isLeaf;
  bool get isContainer => matchedCategory.isContainer;

  @override
  List<Object?> get props => [matchedCategory, breadcrumb, navigationDecision];
}
