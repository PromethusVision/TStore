import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_by_taxonomy_scope_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class _MockGetProductsUsecase extends Mock implements GetProductsUsecase {}

class _MockGetProductsByTaxonomyScopeUsecase extends Mock
    implements GetProductsByTaxonomyScopeUsecase {}

class _MockGetProductByIdUsecase extends Mock
    implements GetProductByIdUsecase {}

class _MockSearchProductsUsecase extends Mock
    implements SearchProductsUsecase {}

void main() {
  late _MockGetProductsUsecase legacyUsecase;
  late _MockGetProductsByTaxonomyScopeUsecase canonicalUsecase;
  late _MockGetProductByIdUsecase getProductByIdUsecase;
  late _MockSearchProductsUsecase searchProductsUsecase;

  setUpAll(() {
    registerFallbackValue(GetProductsParams());
    registerFallbackValue(
      GetProductsByTaxonomyScopeParams(
        scope: TaxonomyProductQueryScope.exactLeaf(categoryId: 'fallback'),
      ),
    );
  });

  setUp(() {
    legacyUsecase = _MockGetProductsUsecase();
    canonicalUsecase = _MockGetProductsByTaxonomyScopeUsecase();
    getProductByIdUsecase = _MockGetProductByIdUsecase();
    searchProductsUsecase = _MockSearchProductsUsecase();
  });

  ProductsCubit buildCubit({bool includeCanonicalUsecase = true}) {
    return ProductsCubit(
      getProductsUsecase: legacyUsecase,
      getProductByIdUsecase: getProductByIdUsecase,
      searchProductsUsecase: searchProductsUsecase,
      getProductsByTaxonomyScopeUsecase: includeCanonicalUsecase
          ? canonicalUsecase
          : null,
    );
  }

  blocTest<ProductsCubit, ProductsState>(
    'DESCENDANTS goes only through the canonical scope usecase',
    setUp: () {
      when(
        () => canonicalUsecase(any()),
      ).thenAnswer((_) async => const Right([]));
    },
    build: buildCubit,
    act: (cubit) => cubit.getProducts(
      taxonomyQueryScope: TaxonomyProductQueryScope.descendants(
        categoryId: 'container',
      ),
      refresh: true,
    ),
    expect: () => [
      ProductsLoading(),
      isA<ProductsLoaded>().having(
        (state) => state.products,
        'products',
        isEmpty,
      ),
    ],
    verify: (_) {
      final params =
          verify(() => canonicalUsecase(captureAny())).captured.single
              as GetProductsByTaxonomyScopeParams;
      expect(params.scope.kind, TaxonomyProductQueryScopeKind.descendants);
      expect(params.scope.categoryId, 'container');
      verifyNever(() => legacyUsecase(any()));
    },
  );

  blocTest<ProductsCubit, ProductsState>(
    'canonical scope without backend adapter fails before any legacy query',
    build: () => buildCubit(includeCanonicalUsecase: false),
    act: (cubit) => cubit.getProducts(
      taxonomyQueryScope: TaxonomyProductQueryScope.exactLeaf(
        categoryId: 'leaf',
      ),
      refresh: true,
    ),
    expect: () => [ProductsLoading(), isA<ProductsError>()],
    verify: (_) => verifyNever(() => legacyUsecase(any())),
  );

  blocTest<ProductsCubit, ProductsState>(
    'explicit current-runtime scope preserves the legacy exact-ID query',
    setUp: () {
      when(() => legacyUsecase(any())).thenAnswer((_) async => const Right([]));
    },
    build: buildCubit,
    act: (cubit) => cubit.getProducts(
      taxonomyQueryScope: TaxonomyProductQueryScope.exactLeaf(
        categoryId: 'legacy-category',
        hasCanonicalHierarchyEvidence: false,
      ),
      refresh: true,
    ),
    expect: () => [ProductsLoading(), isA<ProductsLoaded>()],
    verify: (_) {
      final params =
          verify(() => legacyUsecase(captureAny())).captured.single
              as GetProductsParams;
      expect(params.categoryId, 'legacy-category');
      verifyNever(() => canonicalUsecase(any()));
    },
  );
}
