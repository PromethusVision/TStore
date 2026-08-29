import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_taxonomy_scope_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUsecase getProductsUsecase;
  final GetProductByIdUsecase getProductByIdUsecase;
  final SearchProductsUsecase searchProductsUsecase;
  final GetProductsByTaxonomyScopeUsecase? getProductsByTaxonomyScopeUsecase;

  ProductsCubit({
    required this.getProductsUsecase,
    required this.getProductByIdUsecase,
    required this.searchProductsUsecase,
    this.getProductsByTaxonomyScopeUsecase,
  }) : super(ProductsInitial());

  List<ProductEntity> _allProducts = [];
  int _currentPage = 0;
  int _activeRequestId = 0;
  static const int _limit = 20;

  Future<void> getProducts({
    String? categoryId,
    TaxonomyProductQueryScope? taxonomyQueryScope,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
    bool refresh = false,
  }) async {
    final requestId = _startRequest();

    if (refresh) {
      _currentPage = 0;
      _allProducts = [];
    }

    if (_currentPage == 0) {
      emit(ProductsLoading());
    }

    final result = await _loadProductsPage(
      categoryId: categoryId,
      taxonomyQueryScope: taxonomyQueryScope,
      brandId: brandId,
      isFeatured: isFeatured,
      sortBy: sortBy,
      ascending: ascending,
    );

    if (!_canHandle(requestId)) return;

    result.fold((error) => emit(ProductsError(error)), (products) {
      _mergeProducts(products);
      _currentPage++;
      emit(
        ProductsLoaded(
          products: _allProducts,
          hasReachedMax: products.length < _limit,
          currentPage: _currentPage,
        ),
      );
    });
  }

  Future<void> loadMoreProducts({
    String? categoryId,
    TaxonomyProductQueryScope? taxonomyQueryScope,
    String? brandId,
    bool? isFeatured,
    String? sortBy,
    bool ascending = true,
  }) async {
    final currentState = state;
    if (currentState is! ProductsLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    final requestId = _startRequest();
    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreError: true));

    final result = await _loadProductsPage(
      categoryId: categoryId,
      taxonomyQueryScope: taxonomyQueryScope,
      brandId: brandId,
      isFeatured: isFeatured,
      sortBy: sortBy,
      ascending: ascending,
    );

    if (!_canHandle(requestId)) return;

    result.fold(
      (error) => emit(
        currentState.copyWith(isLoadingMore: false, loadMoreError: error),
      ),
      (products) {
        _mergeProducts(products);
        _currentPage++;
        emit(
          ProductsLoaded(
            products: _allProducts,
            hasReachedMax: products.length < _limit,
            currentPage: _currentPage,
          ),
        );
      },
    );
  }

  Future<void> getProductById(String id) async {
    final requestId = _startRequest();
    emit(ProductDetailLoading());

    final result = await getProductByIdUsecase(id);

    if (!_canHandle(requestId)) return;

    result.fold(
      (error) => emit(ProductDetailError(error)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> searchProducts(String query) async {
    final requestId = _startRequest();

    if (query.isEmpty) {
      if (!isClosed) emit(ProductsInitial());
      return;
    }

    emit(ProductsSearching());

    final result = await searchProductsUsecase(query);

    if (!_canHandle(requestId)) return;

    result.fold(
      (error) => emit(ProductsError(error)),
      (products) =>
          emit(ProductsSearchResult(products: products, query: query)),
    );
  }

  void resetProducts() {
    _startRequest();
    _currentPage = 0;
    _allProducts = [];
    if (!isClosed) emit(ProductsInitial());
  }

  int _startRequest() => ++_activeRequestId;

  bool _canHandle(int requestId) {
    return !isClosed && requestId == _activeRequestId;
  }

  Future<Either<String, List<ProductEntity>>> _loadProductsPage({
    required String? categoryId,
    required TaxonomyProductQueryScope? taxonomyQueryScope,
    required String? brandId,
    required bool? isFeatured,
    required String? sortBy,
    required bool ascending,
  }) {
    final scope = taxonomyQueryScope;
    if (scope != null) {
      if (categoryId != null && categoryId.trim() != scope.categoryId) {
        return Future.value(
          const Left('Kategori kimliği ve taxonomy sorgu kapsamı uyuşmuyor.'),
        );
      }
      if (!scope.hasCanonicalHierarchyEvidence) {
        return getProductsUsecase(
          GetProductsParams(
            page: _currentPage,
            limit: _limit,
            categoryId: scope.categoryId,
            brandId: brandId,
            isFeatured: isFeatured,
            sortBy: sortBy,
            ascending: ascending,
          ),
        );
      }

      final canonicalUsecase = getProductsByTaxonomyScopeUsecase;
      if (canonicalUsecase == null) {
        return Future.value(
          const Left(
            'Canonical ürün kapsamı backend adapterı bu build için etkin değil.',
          ),
        );
      }
      return canonicalUsecase(
        GetProductsByTaxonomyScopeParams(
          scope: scope,
          page: _currentPage,
          limit: _limit,
          brandId: brandId,
          isFeatured: isFeatured,
          sortBy: sortBy,
          ascending: ascending,
        ),
      );
    }

    return getProductsUsecase(
      GetProductsParams(
        page: _currentPage,
        limit: _limit,
        categoryId: categoryId,
        brandId: brandId,
        isFeatured: isFeatured,
        sortBy: sortBy,
        ascending: ascending,
      ),
    );
  }

  void _mergeProducts(List<ProductEntity> products) {
    _allProducts = <String, ProductEntity>{
      for (final product in _allProducts) product.id: product,
      for (final product in products) product.id: product,
    }.values.toList();
  }
}
