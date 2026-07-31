import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

class MockCustomerSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class InMemoryRecentProductSearchesStorage
    implements RecentProductSearchesStorage {
  InMemoryRecentProductSearchesStorage([List<String> initialQueries = const []])
    : queries = [...initialQueries];

  final List<String> queries;

  @override
  Future<void> clear() async => queries.clear();

  @override
  Future<List<String>> getQueries() async => List.unmodifiable(queries);

  @override
  Future<void> recordQuery(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    queries
      ..removeWhere(
        (item) => item.toLowerCase() == normalizedQuery.toLowerCase(),
      )
      ..insert(0, normalizedQuery);
    if (queries.length > RecentProductSearchesStorage.maximumQueryCount) {
      queries.removeRange(
        RecentProductSearchesStorage.maximumQueryCount,
        queries.length,
      );
    }
  }

  @override
  Future<void> removeQuery(String query) async {
    queries.removeWhere(
      (item) => item.toLowerCase() == query.trim().toLowerCase(),
    );
  }
}

void main() {
  late MockProductsCubit parentProductsCubit;
  late MockProductsCubit localProductsCubit;
  late MockCustomerSearchCubit customerSearchCubit;
  late MockWishlistCubit wishlistCubit;
  late InMemoryRecentProductSearchesStorage recentSearchesStorage;
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
    customerSearchCubit = MockCustomerSearchCubit();
    wishlistCubit = MockWishlistCubit();
    recentSearchesStorage = InMemoryRecentProductSearchesStorage();
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
      customerSearchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: CustomerSearchInitial(),
    );
    when(() => customerSearchCubit.search(any())).thenAnswer((_) async {});
    when(() => customerSearchCubit.reset()).thenReturn(null);
    when(() => customerSearchCubit.close()).thenAnswer((_) async {});
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

  Widget buildSubject({bool isSearchMode = false, String initialQuery = ''}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductsCubit>.value(value: parentProductsCubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
        ],
        child: AllProductsView(
          currentUserIdProvider: () => null,
          isSearchMode: isSearchMode,
          initialQuery: initialQuery,
          recentSearchesStorage: recentSearchesStorage,
          customerSearchCubit: customerSearchCubit,
          categoryDestinationBuilder: (category) => Scaffold(
            appBar: AppBar(),
            body: Text('Kategori: ${category.name}'),
          ),
          shopDestinationBuilder: (shop) =>
              Scaffold(appBar: AppBar(), body: Text('Mağaza: ${shop.name}')),
        ),
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

  void stubCustomerSearchState(CustomerSearchState state) {
    whenListen(
      customerSearchCubit,
      const Stream<CustomerSearchState>.empty(),
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
    'searches after the debounce with the local cubit without changing the parent product state',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'kahve');
      await tester.pump(const Duration(milliseconds: 349));

      verifyNever(() => localProductsCubit.searchProducts(any()));

      await tester.pump(const Duration(milliseconds: 1));

      verify(() => localProductsCubit.searchProducts('kahve')).called(1);
      verifyNever(() => parentProductsCubit.searchProducts(any()));
      expect(parentProductsCubit.state, same(parentFeaturedState));

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('shows the most recent searches in search mode', (tester) async {
    recentSearchesStorage.queries.addAll(['kahve', 'ekmek']);

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();

    expect(
      find.byKey(const Key('recent-product-searches-section')),
      findsOneWidget,
    );
    expect(find.text('Son Aramalar'), findsOneWidget);
    expect(find.text('kahve'), findsOneWidget);
    expect(find.text('ekmek'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('starts a unified search with the query received from home', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(isSearchMode: true, initialQuery: 'elektronik'),
    );
    await tester.pump();

    expect(find.widgetWithText(TextFormField, 'elektronik'), findsOneWidget);
    verify(() => customerSearchCubit.search('elektronik')).called(1);
    verifyNever(() => localProductsCubit.getProducts(refresh: true));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('runs a recent search immediately when it is selected', (
    tester,
  ) async {
    recentSearchesStorage.queries.add('kahve');

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();
    await tester.tap(find.text('kahve'));
    await tester.pump();

    expect(find.widgetWithText(TextFormField, 'kahve'), findsOneWidget);
    verify(() => customerSearchCubit.search('kahve')).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('removes one recent search and clears the remaining history', (
    tester,
  ) async {
    recentSearchesStorage.queries.addAll(['kahve', 'ekmek']);

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();

    await tester.tap(find.byTooltip('kahve aramasını sil'));
    await tester.pump();

    expect(find.text('kahve'), findsNothing);
    expect(find.text('ekmek'), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-recent-product-searches')));
    await tester.pump();

    expect(
      find.byKey(const Key('recent-product-searches-section')),
      findsNothing,
    );
    expect(recentSearchesStorage.queries, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'stores a completed search and shows it after clearing the field',
    (tester) async {
      final states = StreamController<CustomerSearchState>();
      whenListen(
        customerSearchCubit,
        states.stream,
        initialState: CustomerSearchInitial(),
      );
      when(() => customerSearchCubit.search('kahve')).thenAnswer((_) async {
        states.add(
          const CustomerSearchLoaded(
            query: 'kahve',
            products: [],
            categories: [],
            shops: [],
          ),
        );
      });

      await tester.pumpWidget(buildSubject(isSearchMode: true));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'kahve');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(recentSearchesStorage.queries, ['kahve']);

      await tester.tap(find.byTooltip('Aramayı temizle'));
      await tester.pump();

      expect(find.text('Son Aramalar'), findsOneWidget);
      expect(find.text('kahve'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await states.close();
    },
  );

  testWidgets('offers search editing and all products after an empty result', (
    tester,
  ) async {
    final states = StreamController<CustomerSearchState>();
    whenListen(
      customerSearchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => customerSearchCubit.search('olmayan')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'olmayan',
          products: [],
          categories: [],
          shops: [],
        ),
      );
    });

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'olmayan');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('"olmayan" için sonuç bulamadık.'), findsOneWidget);
    expect(
      find.text('Ürün, kategori veya mağaza adıyla yeniden arayabilirsiniz.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('edit-empty-product-search')), findsOneWidget);
    expect(
      find.byKey(const Key('show-all-products-after-empty-search')),
      findsOneWidget,
    );

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    editableText.focusNode.unfocus();
    await tester.pump();

    await tester.tap(find.byKey(const Key('edit-empty-product-search')));
    await tester.pump();

    expect(editableText.focusNode.hasFocus, isTrue);
    expect(editableText.controller.selection.start, 0);
    expect(editableText.controller.selection.end, 'olmayan'.length);
    verify(() => customerSearchCubit.search('olmayan')).called(1);

    await tester.tap(
      find.byKey(const Key('show-all-products-after-empty-search')),
    );
    await tester.pump();

    expect(editableText.controller.text, isEmpty);
    verify(() => localProductsCubit.getProducts(refresh: true)).called(2);

    await tester.pumpWidget(const SizedBox.shrink());
    await states.close();
  });

  testWidgets(
    'shows category shop and product sections and opens their destinations',
    (tester) async {
      const category = CategoryEntity(id: 'market', name: 'Grocery');
      const shop = ShopEntity(
        id: 'shop-1',
        name: 'Mahalle Market',
        address: 'Esenler, İstanbul',
        rating: 4.8,
        ratingCount: 24,
      );
      stubCustomerSearchState(
        const CustomerSearchLoaded(
          query: 'market',
          products: [featuredProduct],
          categories: [category],
          shops: [shop],
        ),
      );

      await tester.pumpWidget(buildSubject(isSearchMode: true));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'market');
      await tester.pump();

      expect(
        find.byKey(const Key('customer-search-category-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-search-shop-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-search-product-section')),
        findsOneWidget,
      );
      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Mahalle Market'), findsOneWidget);
      expect(find.text('Populer Urun'), findsOneWidget);
      expect(find.textContaining('km'), findsNothing);

      await tester.tap(
        find.byKey(const Key('customer-search-category-market')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kategori: Grocery'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('customer-search-shop-shop-1')));
      await tester.pumpAndSettle();
      expect(find.text('Mağaza: Mahalle Market'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('keeps successful sections visible after a partial error', (
    tester,
  ) async {
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [featuredProduct],
        categories: [],
        shops: [],
        warningMessage:
            'Bazı sonuçlar yüklenemedi. Diğer sonuçlar gösteriliyor.',
      ),
    );

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pump();

    expect(find.byKey(const Key('customer-search-warning')), findsOneWidget);
    expect(find.text('Populer Urun'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('does not submit the same search twice while it is loading', (
    tester,
  ) async {
    final states = StreamController<CustomerSearchState>();
    final pendingSearch = Completer<void>();
    whenListen(
      customerSearchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => customerSearchCubit.search('kahve')).thenAnswer((_) {
      states.add(const CustomerSearchLoading('kahve'));
      return pendingSearch.future;
    });

    await tester.pumpWidget(buildSubject(isSearchMode: true));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'kahve');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    verify(() => customerSearchCubit.search('kahve')).called(1);

    pendingSearch.complete();
    await tester.pumpWidget(const SizedBox.shrink());
    await states.close();
  });

  testWidgets('rapid typing sends only the latest search query', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), 'k');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextFormField), 'ka');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextFormField), 'kahve');
    await tester.pump(const Duration(milliseconds: 349));

    verifyNever(() => localProductsCubit.searchProducts(any()));

    await tester.pump(const Duration(milliseconds: 1));

    verify(() => localProductsCubit.searchProducts('kahve')).called(1);
    verifyNever(() => localProductsCubit.searchProducts('k'));
    verifyNever(() => localProductsCubit.searchProducts('ka'));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'clearing search cancels the pending query and reloads products',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'kahve');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byTooltip('Aramayı temizle'));
      await tester.pump(const Duration(milliseconds: 350));

      verifyNever(() => localProductsCubit.searchProducts(any()));
      verify(() => localProductsCubit.getProducts(refresh: true)).called(2);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('leaving the screen cancels the pending search query', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), 'kahve');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 350));

    verifyNever(() => localProductsCubit.searchProducts(any()));
    expect(tester.takeException(), isNull);
  });

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
