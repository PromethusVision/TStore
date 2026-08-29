import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_navigation.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';

abstract class CustomerSearchState extends Equatable {
  const CustomerSearchState();

  @override
  List<Object?> get props => [];
}

class CustomerSearchInitial extends CustomerSearchState {}

class CustomerSearchLoading extends CustomerSearchState {
  const CustomerSearchLoading(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CustomerSearchLoaded extends CustomerSearchState {
  const CustomerSearchLoaded({
    required this.query,
    required this.products,
    required this.categories,
    required this.shops,
    this.runtimeMode = TaxonomyRuntimeMode.legacyRuntime,
    this.canonicalCategoryResults = const [],
    this.warningMessage,
  });

  final String query;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final List<ShopEntity> shops;
  final TaxonomyRuntimeMode runtimeMode;
  final List<TaxonomyCategorySearchContext> canonicalCategoryResults;
  final String? warningMessage;

  TaxonomyCategorySearchContext? canonicalResultFor(String categoryId) {
    final normalizedId = categoryId.trim();
    for (final result in canonicalCategoryResults) {
      if (result.matchedCategory.id == normalizedId) return result;
    }
    return null;
  }

  bool canOpenCategory(String categoryId) {
    final canonicalResult = canonicalResultFor(categoryId);
    return canonicalResult == null ||
        canonicalResult.navigationDecision.action !=
            TaxonomyCategoryNavigationAction.unavailable;
  }

  bool get isEmpty => products.isEmpty && categories.isEmpty && shops.isEmpty;

  @override
  List<Object?> get props => [
    query,
    products,
    categories,
    shops,
    runtimeMode,
    canonicalCategoryResults,
    warningMessage,
  ];
}

class CustomerSearchError extends CustomerSearchState {
  const CustomerSearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
