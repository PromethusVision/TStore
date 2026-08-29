import 'package:flutter/widgets.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';
import 'package:t_store/features/shop/presentation/views/taxonomy_browse_view.dart';

Widget? buildCanonicalTaxonomyDestination({
  required TaxonomyCategoryNode category,
  required CanonicalTaxonomyRepository? repository,
  required TaxonomyRuntimeCapability capability,
  TaxonomyBreadcrumb? breadcrumb,
  TaxonomyLeafDestinationBuilder? leafDestinationBuilder,
}) {
  if (!capability.isCanonicalV1 || repository == null) return null;
  try {
    capability.requireCanonicalVersion(category.taxonomyVersion);
  } on Object {
    return null;
  }

  final decision = TaxonomyCategoryNavigationDecision.forCanonicalNode(
    category,
  );
  if (decision.action == TaxonomyCategoryNavigationAction.openProductListing &&
      breadcrumb == null) {
    return null;
  }
  return switch (decision.action) {
    TaxonomyCategoryNavigationAction.navigateDeeper => TaxonomyBrowseView(
      category: category,
      repository: repository,
      capability: capability,
      leafDestinationBuilder: leafDestinationBuilder,
    ),
    TaxonomyCategoryNavigationAction.openProductListing =>
      leafDestinationBuilder?.call(
            category,
            breadcrumb!,
            decision.productQueryScope!,
          ) ??
          SubCategoryView(
            title: category.displayName,
            categoryId: category.id,
            taxonomyQueryScope: decision.productQueryScope,
          ),
    TaxonomyCategoryNavigationAction.unavailable => null,
  };
}
