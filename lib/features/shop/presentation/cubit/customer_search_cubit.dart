import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/canonical_taxonomy_repository.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_search_context.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_runtime_capability.dart';
import 'package:t_store/features/shop/domain/usecases/get_categories_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_category_presentation_helper.dart';

class CustomerSearchCubit extends Cubit<CustomerSearchState> {
  CustomerSearchCubit({
    required this.searchProductsUsecase,
    required this.getProductsUsecase,
    required this.getCategoriesUsecase,
    required this.getShopsUsecase,
    this.taxonomyCapability = TaxonomyRuntimeCapability.currentDefault,
    this.canonicalTaxonomyRepository,
  }) : super(CustomerSearchInitial());

  static const int _maximumProductCount = 30;
  static const int _maximumCategoryCount = 6;
  static const int _maximumShopCount = 8;

  final SearchProductsUsecase searchProductsUsecase;
  final GetProductsUsecase getProductsUsecase;
  final GetCategoriesUsecase getCategoriesUsecase;
  final GetShopsUsecase getShopsUsecase;
  final TaxonomyRuntimeCapability taxonomyCapability;
  final CanonicalTaxonomyRepository? canonicalTaxonomyRepository;

  CanonicalTaxonomyRepository? get activeCanonicalRepository =>
      taxonomyCapability.isCanonicalV1 ? canonicalTaxonomyRepository : null;

  TaxonomyCategorySearchContext? canonicalResultFor(String categoryId) {
    final currentState = state;
    return currentState is CustomerSearchLoaded
        ? currentState.canonicalResultFor(categoryId)
        : null;
  }

  List<CategoryEntity>? _categoriesCache;
  List<ShopEntity>? _shopsCache;
  int _activeRequestId = 0;

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();
    final requestId = ++_activeRequestId;

    if (normalizedQuery.isEmpty) {
      emit(CustomerSearchInitial());
      return;
    }

    emit(CustomerSearchLoading(normalizedQuery));

    final productsFuture = searchProductsUsecase(normalizedQuery);
    final categoriesFuture = _loadCategoryMatches(normalizedQuery);
    final shopsFuture = _shopsCache == null
        ? getShopsUsecase(const NoParams())
        : Future.value(Right<String, List<ShopEntity>>(_shopsCache!));

    final productsResult = await productsFuture;
    final categoriesResult = await categoriesFuture;
    final shopsResult = await shopsFuture;

    if (isClosed || requestId != _activeRequestId) return;

    var productsFailed = false;
    var categoriesFailed = false;
    var shopsFailed = false;
    var products = <ProductEntity>[];
    var categories = <CategoryEntity>[];
    var canonicalCategoryResults = <TaxonomyCategorySearchContext>[];
    var shops = <ShopEntity>[];

    productsResult.fold(
      (_) => productsFailed = true,
      (items) => products = _ranked(
        items,
        query: normalizedQuery,
        nameOf: (item) => item.name,
        limit: _maximumProductCount,
      ),
    );
    categoriesResult.fold((_) => categoriesFailed = true, (matches) {
      categories = matches.categories;
      canonicalCategoryResults = matches.canonicalResults;
    });
    shopsResult.fold((_) => shopsFailed = true, (items) {
      _shopsCache = items;
      shops = _ranked(
        items.where(
          (item) => item.isActive && _shopMatches(item, normalizedQuery),
        ),
        query: normalizedQuery,
        nameOf: (item) => item.name,
        limit: _maximumShopCount,
      );
    });

    if (categories.isNotEmpty && taxonomyCapability.isLegacy) {
      final categoryProductsResult = await getProductsUsecase(
        GetProductsParams(
          categoryId: categories.first.id,
          limit: _maximumProductCount,
          sortBy: 'created_at',
          ascending: false,
        ),
      );

      if (isClosed || requestId != _activeRequestId) return;

      categoryProductsResult.fold((_) {}, (items) {
        productsFailed = false;
        products = _mergeProducts(products, items);
      });
    }

    final failedSectionCount = [
      productsFailed,
      categoriesFailed,
      shopsFailed,
    ].where((failed) => failed).length;

    if (failedSectionCount == 3) {
      emit(
        const CustomerSearchError(
          'Arama tamamlanamadı. Lütfen tekrar deneyin.',
        ),
      );
      return;
    }

    emit(
      CustomerSearchLoaded(
        query: normalizedQuery,
        products: products,
        categories: categories,
        shops: shops,
        runtimeMode: taxonomyCapability.mode,
        canonicalCategoryResults: canonicalCategoryResults,
        warningMessage: failedSectionCount > 0
            ? 'Bazı sonuçlar yüklenemedi. Diğer sonuçlar gösteriliyor.'
            : null,
      ),
    );
  }

  Future<Either<String, _CategorySearchMatches>> _loadCategoryMatches(
    String query,
  ) async {
    if (taxonomyCapability.isLegacy) {
      final result = _categoriesCache == null
          ? await getCategoriesUsecase(const NoParams())
          : Right<String, List<CategoryEntity>>(_categoriesCache!);
      return result.map((items) {
        _categoriesCache = items;
        return _CategorySearchMatches(
          categories: _ranked(
            items.where(
              (item) =>
                  item.isActive &&
                  CustomerCategoryPresentationHelper.matchesSearch(item, query),
            ),
            query: query,
            nameOf: (item) =>
                CustomerCategoryPresentationHelper.localizedTitle(item.name),
            limit: _maximumCategoryCount,
          ),
        );
      });
    }

    final repository = canonicalTaxonomyRepository;
    if (repository == null) {
      return const Left(
        'Canonical taxonomy arama sözleşmesi bu build için etkin değil.',
      );
    }

    final result = await repository.searchTaxonomy(
      TaxonomySearchRequest(query: query, limit: _maximumCategoryCount),
    );
    return result.bind((items) {
      try {
        final canonicalResults = items
            .take(_maximumCategoryCount)
            .toList(growable: false);
        for (final item in canonicalResults) {
          taxonomyCapability.requireCanonicalVersion(item.taxonomyVersion);
          if (!item.matchedCategory.isDiscoverable) {
            throw const FormatException(
              'Canonical search returned a non-discoverable category.',
            );
          }
        }
        return Right(
          _CategorySearchMatches(
            categories: canonicalResults
                .map(
                  (item) => CategoryEntity(
                    id: item.matchedCategory.id,
                    name: item.matchedCategory.displayName,
                    parentId: item.matchedCategory.parentId,
                    sortOrder: item.matchedCategory.sortOrder,
                    isActive: item.matchedCategory.isDiscoverable,
                  ),
                )
                .toList(growable: false),
            canonicalResults: canonicalResults,
          ),
        );
      } on Object {
        return const Left('Canonical taxonomy arama sonucu doğrulanamadı.');
      }
    });
  }

  List<ProductEntity> _mergeProducts(
    List<ProductEntity> directMatches,
    List<ProductEntity> categoryMatches,
  ) {
    final productsById = <String, ProductEntity>{};
    for (final product in directMatches) {
      productsById[product.id] = product;
    }
    for (final product in categoryMatches) {
      productsById.putIfAbsent(product.id, () => product);
    }
    return productsById.values
        .take(_maximumProductCount)
        .toList(growable: false);
  }

  void reset() {
    _activeRequestId++;
    if (state is! CustomerSearchInitial) {
      emit(CustomerSearchInitial());
    }
  }

  bool _shopMatches(ShopEntity shop, String query) {
    final normalizedQuery = query.toLowerCase();
    return [
      shop.name,
      shop.description ?? '',
      shop.address ?? '',
    ].any((value) => value.toLowerCase().contains(normalizedQuery));
  }

  List<T> _ranked<T>(
    Iterable<T> items, {
    required String query,
    required String Function(T item) nameOf,
    required int limit,
  }) {
    final normalizedQuery = query.toLowerCase();
    final rankedItems = items.toList();
    rankedItems.sort((first, second) {
      final firstName = nameOf(first).trim().toLowerCase();
      final secondName = nameOf(second).trim().toLowerCase();
      final scoreComparison = _matchScore(
        firstName,
        normalizedQuery,
      ).compareTo(_matchScore(secondName, normalizedQuery));
      if (scoreComparison != 0) return scoreComparison;
      return firstName.compareTo(secondName);
    });
    return rankedItems.take(limit).toList(growable: false);
  }

  int _matchScore(String value, String query) {
    if (value == query) return 0;
    if (value.startsWith(query)) return 1;
    return 2;
  }
}

class _CategorySearchMatches {
  const _CategorySearchMatches({
    required this.categories,
    this.canonicalResults = const [],
  });

  final List<CategoryEntity> categories;
  final List<TaxonomyCategorySearchContext> canonicalResults;
}
