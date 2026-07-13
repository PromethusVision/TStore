import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_products_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/get_product_by_id_usecase.dart';
import 'package:t_store/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

// Mocks
class MockGetProductsUsecase extends Mock implements GetProductsUsecase {}

class MockGetProductByIdUsecase extends Mock implements GetProductByIdUsecase {}

class MockSearchProductsUsecase extends Mock implements SearchProductsUsecase {}

// Fake classes for registerFallbackValue
class FakeGetProductsParams extends Fake implements GetProductsParams {}

void main() {
  late ProductsCubit productsCubit;
  late MockGetProductsUsecase mockGetProductsUsecase;
  late MockGetProductByIdUsecase mockGetProductByIdUsecase;
  late MockSearchProductsUsecase mockSearchProductsUsecase;

  // Test data
  final testProducts = [
    const ProductEntity(
      id: 'product-1',
      name: 'Test Product 1',
      description: 'Description 1',
      price: 99.99,
      salePrice: 79.99,
      categoryId: 'cat-1',
      brandId: 'brand-1',
      stock: 10,
      images: ['image1.jpg', 'image2.jpg'],
      thumbnail: 'thumb1.jpg',
      rating: 4.5,
      reviewsCount: 10,
      isFeatured: true,
    ),
    const ProductEntity(
      id: 'product-2',
      name: 'Test Product 2',
      description: 'Description 2',
      price: 149.99,
      categoryId: 'cat-2',
      stock: 5,
      images: ['image3.jpg'],
      rating: 3.8,
      reviewsCount: 5,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGetProductsParams());
  });

  setUp(() {
    mockGetProductsUsecase = MockGetProductsUsecase();
    mockGetProductByIdUsecase = MockGetProductByIdUsecase();
    mockSearchProductsUsecase = MockSearchProductsUsecase();

    productsCubit = ProductsCubit(
      getProductsUsecase: mockGetProductsUsecase,
      getProductByIdUsecase: mockGetProductByIdUsecase,
      searchProductsUsecase: mockSearchProductsUsecase,
    );
  });

  tearDown(() {
    productsCubit.close();
  });

  group('ProductsCubit', () {
    test('initial state is ProductsInitial', () {
      expect(productsCubit.state, ProductsInitial());
    });

    group('getProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsLoaded] when getProducts succeeds',
        build: () {
          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) async => Right(testProducts));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(),
        expect: () => [
          ProductsLoading(),
          ProductsLoaded(
            products: testProducts,
            hasReachedMax: true,
            currentPage: 1,
          ),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsError] when getProducts fails',
        build: () {
          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) async => const Left('Failed to fetch products'));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(),
        expect: () => [
          ProductsLoading(),
          const ProductsError('Failed to fetch products'),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsLoaded] with hasReachedMax=false when more products available',
        build: () {
          // Return exactly 20 products to indicate more may be available
          final manyProducts = List.generate(
            20,
            (i) => testProducts.first.copyWith(id: 'p$i'),
          );
          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) async => Right(manyProducts));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(),
        expect: () {
          return [
            ProductsLoading(),
            isA<ProductsLoaded>()
                .having((s) => s.products.length, 'products length', 20)
                .having((s) => s.hasReachedMax, 'hasReachedMax', false),
          ];
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'passes filter parameters to usecase',
        build: () {
          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) async => Right(testProducts));
          return productsCubit;
        },
        act: (cubit) => cubit.getProducts(
          categoryId: 'cat-1',
          brandId: 'brand-1',
          isFeatured: true,
          sortBy: 'price',
          ascending: false,
        ),
        verify: (_) {
          final captured =
              verify(() => mockGetProductsUsecase(captureAny())).captured.first
                  as GetProductsParams;
          expect(captured.categoryId, 'cat-1');
          expect(captured.brandId, 'brand-1');
          expect(captured.isFeatured, true);
          expect(captured.sortBy, 'price');
          expect(captured.ascending, false);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'resets pagination when refresh is true',
        build: () {
          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) async => Right(testProducts));
          return productsCubit;
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          currentPage: 5,
          hasReachedMax: false,
        ),
        act: (cubit) => cubit.getProducts(refresh: true),
        verify: (_) {
          final captured =
              verify(() => mockGetProductsUsecase(captureAny())).captured.first
                  as GetProductsParams;
          expect(captured.page, 0);
        },
      );
    });

    group('getProductById', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductDetailLoading, ProductDetailLoaded] when getProductById succeeds',
        build: () {
          when(
            () => mockGetProductByIdUsecase('product-1'),
          ).thenAnswer((_) async => Right(testProducts.first));
          return productsCubit;
        },
        act: (cubit) => cubit.getProductById('product-1'),
        expect: () => [
          ProductDetailLoading(),
          ProductDetailLoaded(testProducts.first),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductDetailLoading, ProductDetailError] when getProductById fails',
        build: () {
          when(
            () => mockGetProductByIdUsecase('non-existent'),
          ).thenAnswer((_) async => const Left('Product not found'));
          return productsCubit;
        },
        act: (cubit) => cubit.getProductById('non-existent'),
        expect: () => [
          ProductDetailLoading(),
          const ProductDetailError('Product not found'),
        ],
      );
    });

    group('searchProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsSearching, ProductsSearchResult] when search succeeds',
        build: () {
          when(
            () => mockSearchProductsUsecase('Test'),
          ).thenAnswer((_) async => Right(testProducts));
          return productsCubit;
        },
        act: (cubit) => cubit.searchProducts('Test'),
        expect: () => [
          ProductsSearching(),
          ProductsSearchResult(products: testProducts, query: 'Test'),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits ProductsInitial when search query is empty',
        build: () => productsCubit,
        act: (cubit) => cubit.searchProducts(''),
        expect: () => [ProductsInitial()],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsSearching, ProductsError] when search fails',
        build: () {
          when(
            () => mockSearchProductsUsecase('Test'),
          ).thenAnswer((_) async => const Left('Search failed'));
          return productsCubit;
        },
        act: (cubit) => cubit.searchProducts('Test'),
        expect: () => [
          ProductsSearching(),
          const ProductsError('Search failed'),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits empty search result when no products match',
        build: () {
          when(
            () => mockSearchProductsUsecase('NonExistent'),
          ).thenAnswer((_) async => const Right([]));
          return productsCubit;
        },
        act: (cubit) => cubit.searchProducts('NonExistent'),
        expect: () => [
          ProductsSearching(),
          const ProductsSearchResult(products: [], query: 'NonExistent'),
        ],
      );
    });

    group('request ordering and lifecycle', () {
      test(
        'does not let a delayed product load overwrite a newer search result',
        () async {
          final productsCompleter =
              Completer<Either<String, List<ProductEntity>>>();
          final searchCompleter =
              Completer<Either<String, List<ProductEntity>>>();
          final searchProducts = [testProducts.last];
          final emittedStates = <ProductsState>[];
          final subscription = productsCubit.stream.listen(emittedStates.add);

          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) => productsCompleter.future);
          when(
            () => mockSearchProductsUsecase('new search'),
          ).thenAnswer((_) => searchCompleter.future);

          final productsRequest = productsCubit.getProducts(refresh: true);
          final searchRequest = productsCubit.searchProducts('new search');

          searchCompleter.complete(Right(searchProducts));
          await searchRequest;

          productsCompleter.complete(Right(testProducts));
          await productsRequest;
          await Future<void>.delayed(Duration.zero);

          expect(
            productsCubit.state,
            ProductsSearchResult(products: searchProducts, query: 'new search'),
          );
          expect(emittedStates.whereType<ProductsLoaded>(), isEmpty);

          await subscription.cancel();
        },
      );

      test(
        'does not let a delayed old search overwrite a newer search result',
        () async {
          final oldSearchCompleter =
              Completer<Either<String, List<ProductEntity>>>();
          final newSearchCompleter =
              Completer<Either<String, List<ProductEntity>>>();
          final oldSearchProducts = [testProducts.first];
          final newSearchProducts = [testProducts.last];
          final emittedStates = <ProductsState>[];
          final subscription = productsCubit.stream.listen(emittedStates.add);

          when(
            () => mockSearchProductsUsecase('old search'),
          ).thenAnswer((_) => oldSearchCompleter.future);
          when(
            () => mockSearchProductsUsecase('new search'),
          ).thenAnswer((_) => newSearchCompleter.future);

          final oldSearchRequest = productsCubit.searchProducts('old search');
          final newSearchRequest = productsCubit.searchProducts('new search');

          newSearchCompleter.complete(Right(newSearchProducts));
          await newSearchRequest;

          oldSearchCompleter.complete(Right(oldSearchProducts));
          await oldSearchRequest;
          await Future<void>.delayed(Duration.zero);

          expect(
            productsCubit.state,
            ProductsSearchResult(
              products: newSearchProducts,
              query: 'new search',
            ),
          );
          expect(emittedStates.whereType<ProductsSearchResult>(), [
            ProductsSearchResult(
              products: newSearchProducts,
              query: 'new search',
            ),
          ]);

          await subscription.cancel();
        },
      );

      test(
        'pending product request completes without error after cubit is closed',
        () async {
          final productsCompleter =
              Completer<Either<String, List<ProductEntity>>>();

          when(
            () => mockGetProductsUsecase(any()),
          ).thenAnswer((_) => productsCompleter.future);

          final productsRequest = productsCubit.getProducts(refresh: true);
          await productsCubit.close();

          productsCompleter.complete(Right(testProducts));

          await expectLater(productsRequest, completes);
        },
      );
    });

    group('resetProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits ProductsInitial when resetProducts is called',
        build: () => productsCubit,
        seed: () => ProductsLoaded(products: testProducts, currentPage: 3),
        act: (cubit) => cubit.resetProducts(),
        expect: () => [ProductsInitial()],
      );
    });

    group('loadMoreProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'requests page 1 and appends it to existing products',
        build: () {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'first-$index'),
          );
          final secondPage = [
            testProducts.last.copyWith(id: 'second-0'),
            testProducts.last.copyWith(id: 'second-1'),
          ];
          var requestCount = 0;

          when(() => mockGetProductsUsecase(any())).thenAnswer((_) async {
            requestCount++;
            return requestCount == 1 ? Right(firstPage) : Right(secondPage);
          });

          return productsCubit;
        },
        act: (cubit) async {
          await cubit.getProducts(refresh: true);
          await cubit.loadMoreProducts();
        },
        expect: () {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'first-$index'),
          );
          final secondPage = [
            testProducts.last.copyWith(id: 'second-0'),
            testProducts.last.copyWith(id: 'second-1'),
          ];

          return [
            ProductsLoading(),
            ProductsLoaded(
              products: firstPage,
              hasReachedMax: false,
              currentPage: 1,
            ),
            ProductsLoaded(
              products: firstPage,
              hasReachedMax: false,
              currentPage: 1,
              isLoadingMore: true,
            ),
            ProductsLoaded(
              products: [...firstPage, ...secondPage],
              hasReachedMax: true,
              currentPage: 2,
            ),
          ];
        },
        verify: (_) {
          final captured = verify(
            () => mockGetProductsUsecase(captureAny()),
          ).captured.cast<GetProductsParams>();

          expect(captured.map((params) => params.page), [0, 1]);
          expect(captured.map((params) => params.limit), [20, 20]);
        },
      );

      test(
        'does not start a second load-more request while one is pending',
        () async {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'first-$index'),
          );
          final secondPage = [testProducts.last.copyWith(id: 'second-0')];
          final secondPageCompleter =
              Completer<Either<String, List<ProductEntity>>>();
          var requestCount = 0;

          when(() => mockGetProductsUsecase(any())).thenAnswer((_) {
            requestCount++;
            if (requestCount == 1) {
              return Future.value(Right(firstPage));
            }
            return secondPageCompleter.future;
          });

          await productsCubit.getProducts(refresh: true);
          final pendingLoadMore = productsCubit.loadMoreProducts();
          await Future<void>.delayed(Duration.zero);

          final loadingState = productsCubit.state as ProductsLoaded;
          expect(loadingState.isLoadingMore, true);

          await productsCubit.loadMoreProducts();
          verify(() => mockGetProductsUsecase(any())).called(2);

          secondPageCompleter.complete(Right(secondPage));
          await pendingLoadMore;

          final loadedState = productsCubit.state as ProductsLoaded;
          expect(loadedState.products, [...firstPage, ...secondPage]);
          expect(loadedState.currentPage, 2);
          expect(loadedState.isLoadingMore, false);
        },
      );

      test(
        'keeps existing products when loading the next page fails',
        () async {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'first-$index'),
          );
          var requestCount = 0;

          when(() => mockGetProductsUsecase(any())).thenAnswer((_) async {
            requestCount++;
            if (requestCount == 1) return Right(firstPage);
            return const Left('Next page failed');
          });

          await productsCubit.getProducts(refresh: true);
          await productsCubit.loadMoreProducts();

          final state = productsCubit.state as ProductsLoaded;
          expect(state.products, firstPage);
          expect(state.currentPage, 1);
          expect(state.hasReachedMax, false);
          expect(state.isLoadingMore, false);
          expect(state.loadMoreError, 'Next page failed');
        },
      );

      test(
        'retries the same page after an error and appends it on success',
        () async {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'first-$index'),
          );
          final secondPage = [
            testProducts.last.copyWith(id: 'second-0'),
            testProducts.last.copyWith(id: 'second-1'),
          ];
          var requestCount = 0;

          when(() => mockGetProductsUsecase(any())).thenAnswer((_) async {
            requestCount++;
            if (requestCount == 1) return Right(firstPage);
            if (requestCount == 2) return const Left('Temporary failure');
            return Right(secondPage);
          });

          await productsCubit.getProducts(refresh: true);
          await productsCubit.loadMoreProducts();
          await productsCubit.loadMoreProducts();

          final captured = verify(
            () => mockGetProductsUsecase(captureAny()),
          ).captured.cast<GetProductsParams>();
          final state = productsCubit.state as ProductsLoaded;

          expect(captured.map((params) => params.page), [0, 1, 1]);
          expect(state.products, [...firstPage, ...secondPage]);
          expect(state.currentPage, 2);
          expect(state.hasReachedMax, true);
          expect(state.isLoadingMore, false);
          expect(state.loadMoreError, isNull);
        },
      );

      test(
        'does not duplicate a product id returned on a later page',
        () async {
          final firstPage = List.generate(
            20,
            (index) => testProducts.first.copyWith(id: 'product-$index'),
          );
          final repeatedProduct = testProducts.last.copyWith(id: 'product-5');
          final newProduct = testProducts.last.copyWith(id: 'product-20');
          var requestCount = 0;

          when(() => mockGetProductsUsecase(any())).thenAnswer((_) async {
            requestCount++;
            return requestCount == 1
                ? Right(firstPage)
                : Right([repeatedProduct, newProduct]);
          });

          await productsCubit.getProducts(refresh: true);
          await productsCubit.loadMoreProducts();

          final state = productsCubit.state as ProductsLoaded;
          expect(state.products, hasLength(21));
          expect(
            state.products.where((product) => product.id == 'product-5'),
            hasLength(1),
          );
          expect(state.currentPage, 2);
          expect(state.hasReachedMax, true);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'does nothing when hasReachedMax is true',
        build: () => productsCubit,
        seed: () => ProductsLoaded(
          products: testProducts,
          hasReachedMax: true,
          currentPage: 1,
        ),
        act: (cubit) => cubit.loadMoreProducts(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGetProductsUsecase(any()));
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'does nothing when state is not ProductsLoaded',
        build: () => productsCubit,
        seed: () => ProductsLoading(),
        act: (cubit) => cubit.loadMoreProducts(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGetProductsUsecase(any()));
        },
      );
    });
  });
}
