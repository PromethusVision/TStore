import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/common/widgets/sale_tag.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
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

class DelayedSnapshotRecentProductSearchesStorage
    extends InMemoryRecentProductSearchesStorage {
  DelayedSnapshotRecentProductSearchesStorage(super.initialQueries);

  bool delayNextRead = false;
  Completer<void>? _pendingRead;

  bool get hasPendingRead => _pendingRead != null;

  void releasePendingRead() {
    _pendingRead?.complete();
    _pendingRead = null;
  }

  @override
  Future<List<String>> getQueries() async {
    final snapshot = List<String>.unmodifiable(queries);
    if (!delayNextRead) return snapshot;

    delayNextRead = false;
    final pendingRead = Completer<void>();
    _pendingRead = pendingRead;
    await pendingRead.future;
    return snapshot;
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
  const invalidProduct = ProductEntity(
    id: '',
    name: 'Kimliksiz Ürün',
    price: 75,
    categoryId: 'category-1',
    stock: 1,
    images: [],
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

  Widget buildSubject({
    bool isSearchMode = false,
    String initialQuery = '',
    RecentProductSearchesStorage? recentSearchesStorageOverride,
    SearchResultsShopProductsLoader? shopProductsLoader,
    CustomerProductDestinationBuilder? productDestinationBuilder,
    CustomerShopDestinationBuilder? shopDestinationBuilder,
    CustomerCategoryDestinationBuilder? categoryDestinationBuilder,
  }) {
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
          recentSearchesStorage:
              recentSearchesStorageOverride ?? recentSearchesStorage,
          customerSearchCubit: customerSearchCubit,
          shopProductsLoader:
              shopProductsLoader ?? (_) async => const Right([]),
          categoryDestinationBuilder:
              categoryDestinationBuilder ??
              (category) => Scaffold(
                appBar: AppBar(),
                body: Text('Kategori: ${category.name}'),
              ),
          shopDestinationBuilder:
              shopDestinationBuilder ??
              (shop) => Scaffold(
                appBar: AppBar(),
                body: Text('Mağaza: ${shop.name}'),
              ),
          productDestinationBuilder:
              productDestinationBuilder ??
              (product) => Scaffold(
                appBar: AppBar(),
                body: Text('Ürün: ${product.name}'),
              ),
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
      expect(
        find.byKey(const Key('all-products-search-field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('all-products-loading')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('empty product list shows the branded empty state', (
    tester,
  ) async {
    stubLocalState(
      const ProductsLoaded(products: [], hasReachedMax: true, currentPage: 1),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('all-products-empty')), findsOneWidget);
    expect(find.text('Henüz ürün bulunmuyor'), findsOneWidget);
  });

  testWidgets('product load error offers a retry action', (tester) async {
    stubLocalState(const ProductsError('Bağlantı hatası'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('all-products-error')), findsOneWidget);
    expect(find.text('Ürünler yüklenemedi'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => localProductsCubit.getProducts(refresh: true)).called(2);
  });

  testWidgets('mobile width keeps the product grid free of overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    stubLocalState(
      ProductsLoaded(
        products: createProducts(4),
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('all-products-grid')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('late recent search snapshot cannot undo a newer clear', (
    tester,
  ) async {
    final storage = DelayedSnapshotRecentProductSearchesStorage(['eski']);
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

    await tester.pumpWidget(
      buildSubject(isSearchMode: true, recentSearchesStorageOverride: storage),
    );
    await tester.pump();

    storage.delayNextRead = true;
    await tester.enterText(find.byType(TextFormField), 'kahve');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(storage.hasPendingRead, isTrue);
    expect(storage.queries, ['kahve', 'eski']);

    await tester.tap(find.byTooltip('Aramayı temizle'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('clear-recent-product-searches')));
    await tester.pump();

    expect(storage.queries, isEmpty);
    expect(
      find.byKey(const Key('recent-product-searches-section')),
      findsNothing,
    );

    storage.releasePendingRead();
    await tester.pump();

    expect(
      find.byKey(const Key('recent-product-searches-section')),
      findsNothing,
    );
    expect(find.text('kahve'), findsNothing);
    expect(find.text('eski'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await states.close();
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

  testWidgets(
    'unified search requests at most thirty products and shows the real starting price',
    (tester) async {
      final searchProducts = List.generate(
        31,
        (index) => ProductEntity(
          id: 'search-product-$index',
          name: 'Search Product $index',
          price: 150,
          salePrice: 100,
          categoryId: 'category-1',
          stock: 1,
          images: const [],
        ),
      );
      List<String>? requestedProductIds;
      stubCustomerSearchState(
        CustomerSearchLoaded(
          query: 'market',
          products: searchProducts,
          categories: const [],
          shops: const [],
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          isSearchMode: true,
          shopProductsLoader: (productIds) async {
            requestedProductIds = productIds;
            return const Right([
              ShopProductEntity(
                id: 'listing-expensive',
                shopId: 'shop-1',
                productId: 'search-product-0',
                price: 1399.99,
                shop: ShopEntity(id: 'shop-1', name: 'Birinci Mağaza'),
              ),
              ShopProductEntity(
                id: 'listing-cheap',
                shopId: 'shop-2',
                productId: 'search-product-0',
                price: 1299.99,
                shop: ShopEntity(id: 'shop-2', name: 'İkinci Mağaza'),
              ),
              ShopProductEntity(
                id: 'listing-inactive',
                shopId: 'shop-3',
                productId: 'search-product-0',
                price: 999.99,
                shop: ShopEntity(
                  id: 'shop-3',
                  name: 'Pasif Mağaza',
                  isActive: false,
                ),
              ),
            ]);
          },
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'market');
      await tester.pumpAndSettle();

      expect(requestedProductIds, hasLength(30));
      expect(
        requestedProductIds,
        orderedEquals(searchProducts.take(30).map((product) => product.id)),
      );
      expect(find.text('1.299,99 TL’den'), findsOneWidget);
      expect(find.text('999,99 TL’den'), findsNothing);
      expect(find.byType(SaleTag), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'keeps unified search products visible while prices load or fail',
    (tester) async {
      final priceResult = Completer<Either<String, List<ShopProductEntity>>>();
      stubCustomerSearchState(
        const CustomerSearchLoaded(
          query: 'market',
          products: [featuredProduct],
          categories: [],
          shops: [],
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          isSearchMode: true,
          shopProductsLoader: (_) => priceResult.future,
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'market');
      await tester.pump();

      expect(find.text('Fiyat yükleniyor'), findsOneWidget);
      expect(find.text('Populer Urun'), findsOneWidget);

      priceResult.complete(const Left('Bağlantı hatası'));
      await tester.pumpAndSettle();

      expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
      expect(find.text('Populer Urun'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'does not carry a late price response into newer unified search results',
    (tester) async {
      const newerProduct = ProductEntity(
        id: 'new-product',
        name: 'Yeni Ürün',
        price: 250,
        categoryId: 'category-1',
        stock: 1,
        images: [],
      );
      final states = StreamController<CustomerSearchState>();
      final oldPrice = Completer<Either<String, List<ShopProductEntity>>>();
      final newPrice = Completer<Either<String, List<ShopProductEntity>>>();
      whenListen(
        customerSearchCubit,
        states.stream,
        initialState: CustomerSearchInitial(),
      );
      when(() => customerSearchCubit.search('eski')).thenAnswer((_) async {
        states.add(
          const CustomerSearchLoaded(
            query: 'eski',
            products: [featuredProduct],
            categories: [],
            shops: [],
          ),
        );
      });
      when(() => customerSearchCubit.search('yeni')).thenAnswer((_) async {
        states.add(
          const CustomerSearchLoaded(
            query: 'yeni',
            products: [newerProduct],
            categories: [],
            shops: [],
          ),
        );
      });

      await tester.pumpWidget(
        buildSubject(
          isSearchMode: true,
          shopProductsLoader: (productIds) =>
              productIds.single == featuredProduct.id
              ? oldPrice.future
              : newPrice.future,
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'eski');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'yeni');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      newPrice.complete(
        const Right([
          ShopProductEntity(
            id: 'new-listing',
            shopId: 'shop-2',
            productId: 'new-product',
            price: 200,
            shop: ShopEntity(id: 'shop-2', name: 'Yeni Mağaza'),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('200,00 TL’den'), findsOneWidget);
      expect(find.text('Yeni Ürün'), findsOneWidget);

      oldPrice.complete(
        const Right([
          ShopProductEntity(
            id: 'old-listing',
            shopId: 'shop-1',
            productId: 'featured-product',
            price: 100,
            shop: ShopEntity(id: 'shop-1', name: 'Eski Mağaza'),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('200,00 TL’den'), findsOneWidget);
      expect(find.text('100,00 TL’den'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await states.close();
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
    'normal product list requests one page and shows the real starting price',
    (tester) async {
      final products = createProducts(20);
      products[0] = products[0].copyWith(price: 150, salePrice: 100);
      final requestedPages = <List<String>>[];
      stubLocalState(
        ProductsLoaded(
          products: products,
          hasReachedMax: false,
          currentPage: 1,
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          shopProductsLoader: (productIds) async {
            requestedPages.add([...productIds]);
            return const Right([
              ShopProductEntity(
                id: 'listing-expensive',
                shopId: 'shop-1',
                productId: 'product-0',
                price: 1399.99,
                shop: ShopEntity(id: 'shop-1', name: 'Birinci Mağaza'),
              ),
              ShopProductEntity(
                id: 'listing-cheap',
                shopId: 'shop-2',
                productId: 'product-0',
                price: 1299.99,
                shop: ShopEntity(id: 'shop-2', name: 'İkinci Mağaza'),
              ),
              ShopProductEntity(
                id: 'listing-inactive',
                shopId: 'shop-3',
                productId: 'product-0',
                price: 999.99,
                shop: ShopEntity(
                  id: 'shop-3',
                  name: 'Pasif Mağaza',
                  isActive: false,
                ),
              ),
            ]);
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(requestedPages, hasLength(1));
      expect(
        requestedPages.single,
        orderedEquals(products.map((product) => product.id)),
      );
      expect(find.text('1.299,99 TL’den'), findsOneWidget);
      expect(find.text('999,99 TL’den'), findsNothing);
      expect(find.byType(SaleTag), findsNothing);
      expect(find.byKey(const Key('all-products-summary')), findsOneWidget);
      expect(find.text('20 ürün gösteriliyor'), findsOneWidget);
      expect(find.byKey(const Key('all-products-grid')), findsOneWidget);
      expect(
        find.byKey(const Key('all-products-product-product-0')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'normal product list requests only new products after pagination',
    (tester) async {
      final states = StreamController<ProductsState>();
      final firstPage = createProducts(20);
      final secondPage = List.generate(
        20,
        (index) => featuredProduct.copyWith(
          id: 'product-${index + 20}',
          name: 'Product ${index + 20}',
        ),
      );
      final requestedPages = <List<String>>[];
      final firstState = ProductsLoaded(
        products: firstPage,
        hasReachedMax: false,
        currentPage: 1,
      );
      whenListen(localProductsCubit, states.stream, initialState: firstState);

      await tester.pumpWidget(
        buildSubject(
          shopProductsLoader: (productIds) async {
            requestedPages.add([...productIds]);
            return Right([
              ShopProductEntity(
                id: 'listing-${productIds.first}',
                shopId: 'shop-1',
                productId: productIds.first,
                price: productIds.first == 'product-0' ? 120 : 220,
                shop: const ShopEntity(id: 'shop-1', name: 'Mahalle Mağazası'),
              ),
            ]);
          },
        ),
      );
      await tester.pumpAndSettle();

      states.add(
        ProductsLoaded(
          products: [...firstPage, ...secondPage],
          hasReachedMax: true,
          currentPage: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(requestedPages, hasLength(2));
      expect(
        requestedPages.first,
        orderedEquals(firstPage.map((product) => product.id)),
      );
      expect(
        requestedPages.last,
        orderedEquals(secondPage.map((product) => product.id)),
      );
      expect(find.text('120,00 TL’den'), findsOneWidget);

      states.add(
        ProductsLoaded(
          products: [...firstPage, ...secondPage],
          hasReachedMax: true,
          currentPage: 2,
          isLoadingMore: true,
        ),
      );
      await tester.pump();
      expect(requestedPages, hasLength(2));

      await tester.pumpWidget(const SizedBox.shrink());
      await states.close();
    },
  );

  testWidgets('normal products stay visible while seller prices load or fail', (
    tester,
  ) async {
    final priceResult = Completer<Either<String, List<ShopProductEntity>>>();
    stubLocalState(
      const ProductsLoaded(
        products: [featuredProduct],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) => priceResult.future),
    );
    await tester.pump();

    expect(find.text('Fiyat yükleniyor'), findsOneWidget);
    expect(find.text('Populer Urun'), findsOneWidget);

    priceResult.complete(const Left('Bağlantı hatası'));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
    expect(find.text('Populer Urun'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'late normal-list price response cannot overwrite a reordered result',
    (tester) async {
      final states = StreamController<ProductsState>();
      final products = createProducts(2);
      final oldPrice = Completer<Either<String, List<ShopProductEntity>>>();
      final newPrice = Completer<Either<String, List<ShopProductEntity>>>();
      whenListen(
        localProductsCubit,
        states.stream,
        initialState: ProductsLoaded(
          products: products,
          hasReachedMax: true,
          currentPage: 1,
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          shopProductsLoader: (productIds) => productIds.first == 'product-0'
              ? oldPrice.future
              : newPrice.future,
        ),
      );
      await tester.pump();

      states.add(
        ProductsLoaded(
          products: products.reversed.toList(growable: false),
          hasReachedMax: true,
          currentPage: 1,
        ),
      );
      await tester.pump();

      newPrice.complete(
        const Right([
          ShopProductEntity(
            id: 'new-listing',
            shopId: 'shop-2',
            productId: 'product-0',
            price: 200,
            shop: ShopEntity(id: 'shop-2', name: 'Yeni Mağaza'),
          ),
        ]),
      );
      await tester.pumpAndSettle();
      expect(find.text('200,00 TL’den'), findsOneWidget);

      oldPrice.complete(
        const Right([
          ShopProductEntity(
            id: 'old-listing',
            shopId: 'shop-1',
            productId: 'product-0',
            price: 100,
            shop: ShopEntity(id: 'shop-1', name: 'Eski Mağaza'),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('200,00 TL’den'), findsOneWidget);
      expect(find.text('100,00 TL’den'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await states.close();
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

  testWidgets('kimliği eksik tüm ürün kartı bozuk detay sayfası açmaz', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubLocalState(
      const ProductsLoaded(
        products: [invalidProduct],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        productDestinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Açılmamalı'));
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('all-products-product-link-')),
    );

    expect(productLink.onTap, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Açılmamalı'), findsNothing);
  });

  testWidgets('tüm ürün kartına hızlı çift dokunma yalnız bir detay açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubLocalState(
      const ProductsLoaded(
        products: [featuredProduct],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        productDestinationBuilder: (_) {
          destinationBuildCount++;
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Tek tüm ürün detay hedefi'),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('all-products-product-link-featured-product')),
    );
    productLink.onTap!();
    productLink.onTap!();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Tek tüm ürün detay hedefi'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Populer Urun'), findsOneWidget);
  });

  testWidgets('kimliği eksik arama ürünü bozuk detay sayfası açmaz', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [invalidProduct],
        categories: [],
        shops: [],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        productDestinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Arama sonucu açılmamalı'));
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('all-products-product-link-')),
    );

    expect(productLink.onTap, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Arama sonucu açılmamalı'), findsNothing);
  });

  testWidgets('arama ürününe hızlı çift dokunma yalnız bir detay açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [featuredProduct],
        categories: [],
        shops: [],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        productDestinationBuilder: (_) {
          destinationBuildCount++;
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Tek arama ürün detay hedefi'),
          );
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('all-products-product-link-featured-product')),
    );
    productLink.onTap!();
    productLink.onTap!();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Tek arama ürün detay hedefi'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Populer Urun'), findsOneWidget);
  });

  testWidgets('pasif veya kimliği eksik arama mağazası profil açmaz', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [],
        categories: [],
        shops: [
          ShopEntity(id: '', name: 'Kimliksiz Mağaza'),
          ShopEntity(
            id: 'inactive-shop',
            name: 'Kapalı Mağaza',
            isActive: false,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        shopDestinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Açılmamalı'));
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final missingIdLink = tester.widget<InkWell>(
      find.byKey(const Key('customer-search-shop-link-')),
    );
    final inactiveLink = tester.widget<InkWell>(
      find.byKey(const Key('customer-search-shop-link-inactive-shop')),
    );

    expect(missingIdLink.onTap, isNull);
    expect(inactiveLink.onTap, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Açılmamalı'), findsNothing);
  });

  testWidgets('arama mağazasına hızlı çift dokunma yalnız bir profil açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [],
        categories: [],
        shops: [ShopEntity(id: 'shop-1', name: 'Mahalle Market')],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        shopDestinationBuilder: (_) {
          destinationBuildCount++;
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Tek arama mağaza hedefi'),
          );
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final shopLink = tester.widget<InkWell>(
      find.byKey(const Key('customer-search-shop-link-shop-1')),
    );
    shopLink.onTap!();
    shopLink.onTap!();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Tek arama mağaza hedefi'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Mahalle Market'), findsOneWidget);
  });

  testWidgets('kimliği eksik arama kategorisi bozuk sayfa açmaz', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [],
        categories: [CategoryEntity(id: '', name: 'Grocery')],
        shops: [],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        categoryDestinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Kategori açılmamalı'));
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final categoryChip = tester.widget<ActionChip>(
      find.byKey(const Key('customer-search-category-')),
    );

    expect(categoryChip.onPressed, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Kategori açılmamalı'), findsNothing);
  });

  testWidgets('arama kategorisine hızlı çift dokunma yalnız bir sayfa açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    stubCustomerSearchState(
      const CustomerSearchLoaded(
        query: 'market',
        products: [],
        categories: [CategoryEntity(id: 'market', name: 'Grocery')],
        shops: [],
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        isSearchMode: true,
        categoryDestinationBuilder: (_) {
          destinationBuildCount++;
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Tek arama kategori hedefi'),
          );
        },
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'market');
    await tester.pumpAndSettle();

    final categoryChip = tester.widget<ActionChip>(
      find.byKey(const Key('customer-search-category-market')),
    );
    categoryChip.onPressed!();
    categoryChip.onPressed!();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Tek arama kategori hedefi'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Market'), findsOneWidget);
  });
}
