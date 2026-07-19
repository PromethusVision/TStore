import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late MockProductsCubit parentProductsCubit;
  late MockProductsCubit localProductsCubit;
  late MockWishlistCubit wishlistCubit;
  late ProductsLoaded parentFeaturedState;

  const featuredProduct = ProductEntity(
    id: 'featured-product',
    name: 'Populer Urun',
    price: 100,
    categoryId: 'category-1',
    stock: 1,
    images: [],
    isFeatured: true,
  );

  setUp(() async {
    await sl.reset();

    parentProductsCubit = MockProductsCubit();
    localProductsCubit = MockProductsCubit();
    wishlistCubit = MockWishlistCubit();
    parentFeaturedState = const ProductsLoaded(
      products: [featuredProduct],
      hasReachedMax: true,
      currentPage: 1,
    );

    whenListen(
      parentProductsCubit,
      const Stream<ProductsState>.empty(),
      initialState: parentFeaturedState,
    );
    whenListen(
      localProductsCubit,
      const Stream<ProductsState>.empty(),
      initialState: ProductsInitial(),
    );
    when(
      () => localProductsCubit.getProducts(refresh: true),
    ).thenAnswer((_) async {});
    when(
      () => localProductsCubit.searchProducts(any()),
    ).thenAnswer((_) async {});
    when(() => localProductsCubit.loadMoreProducts()).thenAnswer((_) async {});
    when(() => localProductsCubit.close()).thenAnswer((_) async {});
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);

    sl.registerFactory<ProductsCubit>(() => localProductsCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductsCubit>.value(value: parentProductsCubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
        ],
        child: AllProductsView(currentUserIdProvider: () => null),
      ),
    );
  }

  void stubLocalState(ProductsState state) {
    whenListen(
      localProductsCubit,
      const Stream<ProductsState>.empty(),
      initialState: state,
    );
  }

  List<ProductEntity> createProducts(int count) {
    return List.generate(
      count,
      (index) => featuredProduct.copyWith(
        id: 'product-$index',
        name: 'Product $index',
      ),
    );
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'opens with an independent cubit and requests the unfiltered product list',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      verify(() => localProductsCubit.getProducts(refresh: true)).called(1);
      verifyNever(() => parentProductsCubit.getProducts(refresh: true));
      expect(parentProductsCubit.state, same(parentFeaturedState));

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'searches with the local cubit without changing the parent product state',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'kahve');
      await tester.pump();

      verify(() => localProductsCubit.searchProducts('kahve')).called(1);
      verifyNever(() => parentProductsCubit.searchProducts(any()));
      expect(parentProductsCubit.state, same(parentFeaturedState));

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'loads the next page when a loaded product list approaches the end',
    (tester) async {
      final loadMoreCompleter = Completer<void>();
      stubLocalState(
        ProductsLoaded(
          products: createProducts(12),
          hasReachedMax: false,
          currentPage: 1,
        ),
      );
      when(
        () => localProductsCubit.loadMoreProducts(),
      ).thenAnswer((_) => loadMoreCompleter.future);

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await scrollToEnd(tester);

      verify(() => localProductsCubit.loadMoreProducts()).called(1);

      loadMoreCompleter.complete();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'does not start another page request while the first one is unfinished',
    (tester) async {
      final loadMoreCompleter = Completer<void>();
      final loadedState = ProductsLoaded(
        products: createProducts(12),
        hasReachedMax: false,
        currentPage: 1,
      );
      stubLocalState(loadedState);
      when(() => localProductsCubit.loadMoreProducts()).thenAnswer((_) {
        when(
          () => localProductsCubit.state,
        ).thenReturn(loadedState.copyWith(isLoadingMore: true));
        return loadMoreCompleter.future;
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await scrollToEnd(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pump();
      await scrollToEnd(tester);

      verify(() => localProductsCubit.loadMoreProducts()).called(1);

      loadMoreCompleter.complete();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'does not load another page after the product list reaches its end',
    (tester) async {
      stubLocalState(
        ProductsLoaded(
          products: createProducts(12),
          hasReachedMax: true,
          currentPage: 1,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await scrollToEnd(tester);

      verifyNever(() => localProductsCubit.loadMoreProducts());

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('does not paginate search results', (tester) async {
    stubLocalState(
      ProductsSearchResult(products: createProducts(12), query: 'kahve'),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await scrollToEnd(tester);

    verifyNever(() => localProductsCubit.loadMoreProducts());

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'keeps products visible and retries after loading the next page fails',
    (tester) async {
      stubLocalState(
        ProductsLoaded(
          products: createProducts(12),
          hasReachedMax: false,
          currentPage: 1,
          loadMoreError: 'More products could not be loaded',
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Product 0'), findsOneWidget);
      await scrollToEnd(tester);
      expect(find.text('Tekrar Dene'), findsOneWidget);

      await tester.tap(find.text('Tekrar Dene'));
      await tester.pump();

      verify(() => localProductsCubit.loadMoreProducts()).called(1);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
