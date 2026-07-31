import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_search_bar.dart';

class MockHomeSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

void main() {
  late MockHomeSearchCubit searchCubit;
  late List<String> submittedQueries;
  late List<ProductEntity> selectedProducts;
  late List<CategoryEntity> selectedCategories;
  late List<ShopEntity> selectedShops;

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

    whenListen(
      searchCubit,
      const Stream<CustomerSearchState>.empty(),
      initialState: CustomerSearchInitial(),
    );
    when(() => searchCubit.search(any())).thenAnswer((_) async {});
    when(() => searchCubit.reset()).thenReturn(null);
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: HomeSearchBar(
            searchCubit: searchCubit,
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

  testWidgets('arama tuşu mevcut ifadeyi tam sonuçlara bir kez gönderir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.byKey(const Key('home-search-input')));
    await tester.enterText(find.byType(TextField), 'kahve');

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.testTextInput.receiveAction(TextInputAction.search);

    expect(submittedQueries, ['kahve']);
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
