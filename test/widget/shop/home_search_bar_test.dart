import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_search_bar.dart';

class MockHomeSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class InMemoryRecentProductSearchesStorage
    implements RecentProductSearchesStorage {
  InMemoryRecentProductSearchesStorage({
    List<String> initialQueries = const [],
    this.pendingQueries,
  }) : queries = List<String>.from(initialQueries);

  final List<String> queries;
  final Future<List<String>>? pendingQueries;

  @override
  Future<List<String>> getQueries() async {
    if (pendingQueries != null) return pendingQueries!;
    return List<String>.from(queries);
  }

  @override
  Future<void> recordQuery(String query) async {
    queries
      ..removeWhere((item) => item.toLowerCase() == query.toLowerCase())
      ..insert(0, query);
    if (queries.length > RecentProductSearchesStorage.maximumQueryCount) {
      queries.removeRange(
        RecentProductSearchesStorage.maximumQueryCount,
        queries.length,
      );
    }
  }

  @override
  Future<void> removeQuery(String query) async {
    queries.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
  }

  @override
  Future<void> clear() async => queries.clear();
}

void main() {
  late MockHomeSearchCubit searchCubit;
  late List<String> submittedQueries;
  late List<ProductEntity> selectedProducts;
  late List<CategoryEntity> selectedCategories;
  late List<ShopEntity> selectedShops;
  late InMemoryRecentProductSearchesStorage recentSearchesStorage;

  const product = ProductEntity(
    id: 'product-1',
    name: 'Kablosuz Kulaklık',
    price: 119.99,
    categoryId: 'category-1',
    stock: 8,
    images: [],
  );
  const category = CategoryEntity(id: 'category-1', name: 'Electronics');
  const shop = ShopEntity(
    id: 'shop-1',
    name: 'Esnafta Var Elektronik',
    address: 'Kadıköy, İstanbul',
  );

  setUp(() {
    searchCubit = MockHomeSearchCubit();
    submittedQueries = [];
    selectedProducts = [];
    selectedCategories = [];
    selectedShops = [];
    recentSearchesStorage = InMemoryRecentProductSearchesStorage();

    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search(any())).thenAnswer((_) async {});
    when(() => searchCubit.reset()).thenReturn(null);
  });

  Widget buildSubject({
    RecentProductSearchesStorage? storage,
    HomeSearchShopProductsLoader? shopProductsLoader,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: HomeSearchBar(
            searchCubit: searchCubit,
            recentSearchesStorage: storage ?? recentSearchesStorage,
            shopProductsLoader:
                shopProductsLoader ?? (_) async => const Right([]),
            debounceDuration: const Duration(milliseconds: 350),
            onQuerySubmitted: submittedQueries.add,
            onProductSelected: selectedProducts.add,
            onCategorySelected: selectedCategories.add,
            onShopSelected: selectedShops.add,
          ),
        ),
      ),
    );
  }

  testWidgets('boş alana dokununca son aramaları gösterir', (tester) async {
    recentSearchesStorage = InMemoryRecentProductSearchesStorage(
      initialQueries: ['elektronik', 'kahve'],
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-recent-searches')), findsOneWidget);
    expect(find.text('Son Aramalar'), findsOneWidget);
    expect(find.text('elektronik'), findsOneWidget);
    expect(find.text('kahve'), findsOneWidget);
  });

  testWidgets('son aramayı seçince alanı doldurup önerileri arar', (
    tester,
  ) async {
    recentSearchesStorage = InMemoryRecentProductSearchesStorage(
      initialQueries: ['elektronik'],
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('elektronik'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'elektronik',
    );
    verify(() => searchCubit.search('elektronik')).called(1);
    expect(find.byKey(const Key('home-recent-searches')), findsNothing);
  });

  testWidgets('son aramalar yüklenirken bekleme durumunu gösterir', (
    tester,
  ) async {
    final queriesCompleter = Completer<List<String>>();
    recentSearchesStorage = InMemoryRecentProductSearchesStorage(
      pendingQueries: queriesCompleter.future,
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.pump();

    expect(
      find.byKey(const Key('home-recent-searches-loading')),
      findsOneWidget,
    );

    queriesCompleter.complete(['ekmek']);
    await tester.pumpAndSettle();
    expect(find.text('ekmek'), findsOneWidget);
  });

  testWidgets('tek son aramayı ve tüm geçmişi silebilir', (tester) async {
    recentSearchesStorage = InMemoryRecentProductSearchesStorage(
      initialQueries: ['elektronik', 'kahve'],
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('remove-home-recent-search-0')));
    await tester.pumpAndSettle();
    expect(find.text('elektronik'), findsNothing);
    expect(recentSearchesStorage.queries, ['kahve']);

    await tester.tap(find.byKey(const Key('clear-home-recent-searches')));
    await tester.pumpAndSettle();
    expect(recentSearchesStorage.queries, isEmpty);
    expect(find.byKey(const Key('home-recent-searches')), findsNothing);
  });

  testWidgets('dokununca aynı ekranda yazı alanını etkinleştirir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue);
    expect(submittedQueries, isEmpty);
  });

  testWidgets('iki karakterden sonra kısa beklemeyle öneri araması yapar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));

    await tester.enterText(find.byType(TextField), 'e');
    await tester.pump(const Duration(milliseconds: 400));
    verifyNever(() => searchCubit.search(any()));

    await tester.enterText(find.byType(TextField), 'el');
    await tester.pump(const Duration(milliseconds: 349));
    verifyNever(() => searchCubit.search(any()));
    expect(
      find.byKey(const Key('home-search-suggestions-loading')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1));
    verify(() => searchCubit.search('el')).called(1);
  });

  testWidgets('boş öneri durumundan tam sonuçlara geçiş sunar', (tester) async {
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'yok',
        products: [],
        categories: [],
        shops: [],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'yok');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-search-suggestions-empty')),
      findsOneWidget,
    );
    await tester.tap(find.text('Tüm sonuçları gör'));
    expect(submittedQueries, ['yok']);
  });

  testWidgets('öneri hatasında aramayı yeniden deneyebilir', (tester) async {
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchError('Arama tamamlanamadı'),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'el');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-search-suggestions-error')),
      findsOneWidget,
    );
    await tester.tap(find.text('Tekrar Dene'));
    verify(() => searchCubit.search('el')).called(2);
  });

  testWidgets('ürün kategori ve mağaza önerilerini bölümlü gösterir', (
    tester,
  ) async {
    final states = StreamController<CustomerSearchState>();
    whenListen(
      searchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search('elektronik')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'elektronik',
          products: [product],
          categories: [category],
          shops: [shop],
        ),
      );
    });

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'elektronik');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Kategoriler'), findsOneWidget);
    expect(find.text('Ürünler'), findsOneWidget);
    expect(find.text('Mağazalar'), findsOneWidget);
    expect(find.text('Elektronik'), findsOneWidget);
    expect(find.text('Kablosuz Kulaklık'), findsOneWidget);
    expect(find.text('Esnafta Var Elektronik'), findsOneWidget);
    expect(
      find.byKey(const Key('view-all-home-search-results')),
      findsOneWidget,
    );

    await states.close();
  });

  testWidgets('geçersiz ve pasif önerileri kullanıcıya göstermez', (
    tester,
  ) async {
    const invalidProduct = ProductEntity(
      id: '   ',
      name: 'Geçersiz Ürün',
      price: 10,
      categoryId: 'category-1',
      stock: 1,
      images: [],
    );
    const invalidCategory = CategoryEntity(id: '   ', name: 'Geçersiz');
    const missingShop = ShopEntity(id: '   ', name: 'Eksik Mağaza');
    const inactiveShop = ShopEntity(
      id: 'inactive-shop',
      name: 'Pasif Mağaza',
      isActive: false,
    );
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'geçersiz',
        products: [invalidProduct],
        categories: [invalidCategory],
        shops: [missingShop, inactiveShop],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'geçersiz');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-search-suggestions-empty')),
      findsOneWidget,
    );
    expect(find.text('Geçersiz Ürün'), findsNothing);
    expect(find.text('Geçersiz'), findsNothing);
    expect(find.text('Eksik Mağaza'), findsNothing);
    expect(find.text('Pasif Mağaza'), findsNothing);
    expect(selectedProducts, isEmpty);
    expect(selectedCategories, isEmpty);
    expect(selectedShops, isEmpty);
  });

  testWidgets('kategori önerisini temiz kimlikle seçer', (tester) async {
    const paddedCategory = CategoryEntity(
      id: ' category-1 ',
      name: 'Electronics',
    );
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'elektronik',
        products: [],
        categories: [paddedCategory],
        shops: [],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'elektronik');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('home-category-suggestion- category-1 ')),
    );
    await tester.pump();

    expect(selectedCategories, hasLength(1));
    expect(selectedCategories.single.id, 'category-1');
    expect(selectedProducts, isEmpty);
    expect(selectedShops, isEmpty);
  });

  testWidgets('en fazla üç ürün için gerçek mağaza başlangıç fiyatını ister', (
    tester,
  ) async {
    final products = List.generate(
      4,
      (index) =>
          product.copyWith(id: 'product-$index', name: 'Kulaklık $index'),
    );
    final states = StreamController<CustomerSearchState>();
    List<String>? requestedProductIds;
    whenListen(
      searchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search('kulaklık')).thenAnswer((_) async {
      states.add(
        CustomerSearchLoaded(
          query: 'kulaklık',
          products: products,
          categories: const [],
          shops: const [],
        ),
      );
    });

    await tester.pumpWidget(
      buildSubject(
        shopProductsLoader: (productIds) async {
          requestedProductIds = productIds;
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
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kulaklık');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(
      requestedProductIds,
      orderedEquals(['product-0', 'product-1', 'product-2']),
    );
    expect(find.text('1.299,99 TL’den'), findsOneWidget);
    expect(find.text('999,99 TL’den'), findsNothing);
    expect(
      find.byKey(const Key('home-product-suggestion-product-3')),
      findsNothing,
    );

    await states.close();
  });

  testWidgets('fiyat sorgusu beklerken ve hata alınca öneriyi korur', (
    tester,
  ) async {
    final priceResult = Completer<Either<String, List<ShopProductEntity>>>();
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'kulaklık',
        products: [product],
        categories: [],
        shops: [],
      ),
    );

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) => priceResult.future),
    );
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kulaklık');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(find.text('Fiyat yükleniyor'), findsOneWidget);
    expect(
      find.byKey(const Key('home-product-suggestion-product-1')),
      findsOneWidget,
    );

    priceResult.complete(const Left('Bağlantı hatası'));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
    expect(
      find.byKey(const Key('home-product-suggestion-product-1')),
      findsOneWidget,
    );
  });

  testWidgets('eski aramanın geç gelen fiyatını yeni öneriye taşımaz', (
    tester,
  ) async {
    const newProduct = ProductEntity(
      id: 'product-2',
      name: 'Yeni Kulaklık',
      price: 250,
      categoryId: 'category-1',
      stock: 4,
      images: [],
    );
    final states = StreamController<CustomerSearchState>();
    final oldPrice = Completer<Either<String, List<ShopProductEntity>>>();
    final newPrice = Completer<Either<String, List<ShopProductEntity>>>();
    whenListen(
      searchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search('eski')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'eski',
          products: [product],
          categories: [],
          shops: [],
        ),
      );
    });
    when(() => searchCubit.search('yeni')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'yeni',
          products: [newProduct],
          categories: [],
          shops: [],
        ),
      );
    });

    await tester.pumpWidget(
      buildSubject(
        shopProductsLoader: (productIds) =>
            productIds.single == product.id ? oldPrice.future : newPrice.future,
      ),
    );
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'eski');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'yeni');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    newPrice.complete(
      const Right([
        ShopProductEntity(
          id: 'new-listing',
          shopId: 'shop-2',
          productId: 'product-2',
          price: 200,
          shop: ShopEntity(id: 'shop-2', name: 'Yeni Mağaza'),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('200,00 TL’den'), findsOneWidget);
    expect(find.text('Yeni Kulaklık'), findsOneWidget);

    oldPrice.complete(
      const Right([
        ShopProductEntity(
          id: 'old-listing',
          shopId: 'shop-1',
          productId: 'product-1',
          price: 100,
          shop: ShopEntity(id: 'shop-1', name: 'Eski Mağaza'),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('200,00 TL’den'), findsOneWidget);
    expect(find.text('100,00 TL’den'), findsNothing);
    await states.close();
  });

  testWidgets('ürün önerisini seçince ürün eylemini tek kez çağırır', (
    tester,
  ) async {
    final states = StreamController<CustomerSearchState>();
    whenListen(
      searchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search('kulaklık')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'kulaklık',
          products: [product],
          categories: [],
          shops: [],
        ),
      );
    });

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kulaklık');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('home-product-suggestion-product-1')),
    );
    await tester.pump();

    expect(selectedProducts, [product]);
    expect(submittedQueries, isEmpty);
    expect(find.byKey(const Key('home-search-suggestions')), findsNothing);

    await states.close();
  });

  testWidgets('mağaza önerisini seçince mağaza eylemini çağırır', (
    tester,
  ) async {
    final states = StreamController<CustomerSearchState>();
    whenListen(
      searchCubit,
      states.stream,
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search('esnafta')).thenAnswer((_) async {
      states.add(
        const CustomerSearchLoaded(
          query: 'esnafta',
          products: [],
          categories: [],
          shops: [shop],
        ),
      );
    });

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'esnafta');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-shop-suggestion-shop-1')));
    await tester.pump();

    expect(selectedShops, [shop]);
    await states.close();
  });

  testWidgets('ürün önerisine hızlı çift dokunma tek eylem üretir', (
    tester,
  ) async {
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'kulaklık',
        products: [product],
        categories: [],
        shops: [],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kulaklık');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    final productAction = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('home-product-suggestion-product-1')),
        matching: find.byType(InkWell),
      ),
    );
    productAction.onTap!();
    productAction.onTap!();
    await tester.pump();

    expect(selectedProducts, [product]);
  });

  testWidgets('mağaza önerisine hızlı çift dokunma tek eylem üretir', (
    tester,
  ) async {
    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: const CustomerSearchLoaded(
        query: 'esnafta',
        products: [],
        categories: [],
        shops: [shop],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'esnafta');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    final shopAction = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('home-shop-suggestion-shop-1')),
        matching: find.byType(InkWell),
      ),
    );
    shopAction.onTap!();
    shopAction.onTap!();
    await tester.pump();

    expect(selectedShops, [shop]);
  });

  testWidgets('arama tuşu mevcut ifadeyi tam sonuçlara bir kez gönderir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kahve');

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submittedQueries, ['kahve']);
    expect(recentSearchesStorage.queries, ['kahve']);
  });

  testWidgets('temizleme düğmesi sorguyu ve önerileri kapatır', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kahve');
    await tester.pump();

    expect(find.byKey(const Key('home-search-suggestions')), findsOneWidget);
    await tester.tap(find.byKey(const Key('clear-home-search')));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(find.byKey(const Key('home-search-suggestions')), findsNothing);
    verify(() => searchCubit.reset()).called(greaterThanOrEqualTo(1));
  });
}
