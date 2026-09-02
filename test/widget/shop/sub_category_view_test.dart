import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/sale_tag.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late MockProductsCubit productsCubit;
  late MockWishlistCubit wishlistCubit;

  const product = ProductEntity(
    id: 'product-0',
    name: 'Mahalle Ürünü',
    price: 150,
    salePrice: 100,
    categoryId: 'category-1',
    stock: 5,
    images: [],
  );

  setUp(() async {
    await sl.reset();
    productsCubit = MockProductsCubit();
    wishlistCubit = MockWishlistCubit();

    when(
      () => productsCubit.getProducts(categoryId: 'category-1', refresh: true),
    ).thenAnswer((_) async {});
    when(() => productsCubit.close()).thenAnswer((_) async {});
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
    when(() => wishlistCubit.toggleWishlist(any())).thenAnswer((_) async {});

    sl.registerFactory<ProductsCubit>(() => productsCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  void stubProductsState(ProductsState state) {
    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: state,
    );
  }

  Widget buildSubject({
    required CategoryShopProductsLoader shopProductsLoader,
    CategoryProductDestinationBuilder? productDestinationBuilder,
    String? Function()? currentUserIdProvider,
    bool visualPrototype = false,
  }) {
    return BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: MaterialApp(
        home: SubCategoryView(
          title: 'Market',
          categoryId: 'category-1',
          currentUserIdProvider: currentUserIdProvider ?? () => null,
          shopProductsLoader: shopProductsLoader,
          visualPrototype: visualPrototype,
          productDestinationBuilder:
              productDestinationBuilder ??
              (selectedProduct) => Scaffold(
                body: Center(child: Text('Detay: ${selectedProduct.id}')),
              ),
        ),
      ),
    );
  }

  List<ProductEntity> createProducts(int count) {
    return List.generate(
      count,
      (index) => product.copyWith(id: 'product-$index', name: 'Product $index'),
    );
  }

  testWidgets(
    'kategori en fazla yirmi ürünü sorgular ve gerçek başlangıç fiyatını gösterir',
    (tester) async {
      final products = createProducts(21);
      List<String>? requestedProductIds;
      stubProductsState(
        ProductsLoaded(
          products: products,
          hasReachedMax: false,
          currentPage: 1,
        ),
      );

      await tester.pumpWidget(
        buildSubject(
          shopProductsLoader: (productIds) async {
            requestedProductIds = [...productIds];
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

      verify(
        () =>
            productsCubit.getProducts(categoryId: 'category-1', refresh: true),
      ).called(1);
      expect(requestedProductIds, hasLength(20));
      expect(
        requestedProductIds,
        orderedEquals(products.take(20).map((item) => item.id)),
      );
      expect(find.text('1.299,99 TL’den'), findsOneWidget);
      expect(find.text('999,99 TL’den'), findsNothing);
      expect(find.byType(SaleTag), findsNothing);
      expect(find.byKey(const Key('category-summary')), findsOneWidget);
      expect(find.text('21 ürün gösteriliyor'), findsOneWidget);
      expect(find.byKey(const Key('category-products-grid')), findsOneWidget);
      expect(
        find.byKey(const Key('category-product-product-0')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('ürün kartının tamamı ürün detayına gider', (tester) async {
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        visualPrototype: true,
        shopProductsLoader: (_) async => const Right([]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category-product-product-0')));
    await tester.pumpAndSettle();

    expect(find.text('Detay: product-0'), findsOneWidget);
  });

  testWidgets(
    'visual prototype uzun içerikle kayar ve yerel esnaf bağlamını gösterir',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final products = createProducts(8);
      products[0] = products[0].copyWith(
        name: 'Çok Uzun Türkçe Ürün Adı Ç Ğ İ Ö Ş Ü 256 GB Çift SIM',
        brandName: 'Çok Uzun Mahalle Teknoloji ve İletişim Markası',
      );
      stubProductsState(
        ProductsLoaded(products: products, hasReachedMax: true, currentPage: 1),
      );

      await tester.pumpWidget(
        buildSubject(
          visualPrototype: true,
          shopProductsLoader: (_) async => const Right([
            ShopProductEntity(
              id: 'listing-local-1',
              shopId: 'shop-1',
              productId: 'product-0',
              price: 123456.78,
              shop: ShopEntity(id: 'shop-1', name: 'Uzun Mahalle Esnafı'),
            ),
            ShopProductEntity(
              id: 'listing-local-2',
              shopId: 'shop-2',
              productId: 'product-0',
              price: 124999,
              shop: ShopEntity(id: 'shop-2', name: 'Komşu Esnaf'),
            ),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('2 esnafta var'), findsOneWidget);
      expect(find.text('123.456,78 TL’den'), findsOneWidget);
      expect(find.byKey(const Key('category-sort-button')), findsOneWidget);

      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scrollable.position.pixels, 0);
      await tester.drag(
        find.byKey(const Key('category-products-scroll')),
        const Offset(0, -360),
      );
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('visual prototype desteklenen puan sıralamasını çalıştırır', (
    tester,
  ) async {
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );
    when(
      () => productsCubit.getProducts(
        categoryId: 'category-1',
        sortBy: 'rating',
        ascending: false,
        refresh: true,
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      buildSubject(
        visualPrototype: true,
        shopProductsLoader: (_) async => const Right([]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puana göre'));
    await tester.pumpAndSettle();

    verify(
      () => productsCubit.getProducts(
        categoryId: 'category-1',
        sortBy: 'rating',
        ascending: false,
        refresh: true,
      ),
    ).called(1);
  });

  testWidgets('visual prototype favori aksiyonu kart navigasyonundan ayrıdır', (
    tester,
  ) async {
    var detailOpenCount = 0;
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        visualPrototype: true,
        currentUserIdProvider: () => 'customer-1',
        shopProductsLoader: (_) async => const Right([]),
        productDestinationBuilder: (_) {
          detailOpenCount++;
          return const Scaffold();
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('category-product-favorite-product-0-action')),
    );
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.toggleWishlist('product-0')).called(1);
    expect(detailOpenCount, 0);
  });

  testWidgets('visual prototype geri aksiyonu önceki ekrana döner', (
    tester,
  ) async {
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      BlocProvider<WishlistCubit>.value(
        value: wishlistCubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  key: const Key('open-product-listing'),
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => SubCategoryView(
                        title: 'Market',
                        categoryId: 'category-1',
                        currentUserIdProvider: () => null,
                        shopProductsLoader: (_) async => const Right([]),
                        visualPrototype: true,
                      ),
                    ),
                  ),
                  child: const Text('Listeyi aç'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-product-listing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-listing-header')), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-product-listing')), findsOneWidget);
  });

  testWidgets('kimliği eksik ürün kartı bozuk detay sayfası açmaz', (
    tester,
  ) async {
    var openCount = 0;
    final invalidProduct = product.copyWith(id: '', name: 'Eksik Ürün');
    stubProductsState(
      ProductsLoaded(
        products: [invalidProduct],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        shopProductsLoader: (_) async => const Right([]),
        productDestinationBuilder: (_) {
          openCount++;
          return const Scaffold();
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('category-product-link-')),
    );
    expect(productLink.onTap, isNull);
    expect(find.text('Eksik Ürün'), findsOneWidget);
    expect(openCount, 0);
  });

  testWidgets('ürün kartına hızlı çift dokunma yalnız bir detay açar', (
    tester,
  ) async {
    var openCount = 0;
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        shopProductsLoader: (_) async => const Right([]),
        productDestinationBuilder: (_) {
          openCount++;
          return const Scaffold(
            body: SizedBox(key: Key('category-product-destination')),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('category-product-link-product-0')),
    );
    productLink.onTap!();
    productLink.onTap!();
    await tester.pumpAndSettle();

    expect(openCount, 1);
    expect(
      find.byKey(const Key('category-product-destination')),
      findsOneWidget,
    );

    Navigator.of(
      tester.element(find.byKey(const Key('category-product-destination'))),
    ).pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-product-destination')), findsNothing);
    expect(find.text('Mahalle Ürünü'), findsOneWidget);
  });

  testWidgets('yükleme durumu profesyonel iskelet görünümünü gösterir', (
    tester,
  ) async {
    stubProductsState(ProductsLoading());

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) async => const Right([])),
    );
    await tester.pump();

    expect(find.byKey(const Key('category-products-loading')), findsOneWidget);
    expect(find.text('Market'), findsWidgets);
  });

  testWidgets('boş kategori açıklayıcı boş durumu gösterir', (tester) async {
    stubProductsState(
      const ProductsLoaded(products: [], hasReachedMax: true, currentPage: 1),
    );

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) async => const Right([])),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-products-empty')), findsOneWidget);
    expect(find.text('Bu kategoride ürün bulunamadı'), findsOneWidget);
  });

  testWidgets('hata durumu yeniden deneme seçeneği sunar', (tester) async {
    stubProductsState(const ProductsError('Bağlantı hatası'));

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) async => const Right([])),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-products-error')), findsOneWidget);
    expect(find.text('Kategori ürünleri yüklenemedi'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(
      () => productsCubit.getProducts(categoryId: 'category-1', refresh: true),
    ).called(2);
  });

  testWidgets('ürünler fiyat yüklenirken veya hata olduğunda görünür kalır', (
    tester,
  ) async {
    final priceResult = Completer<Either<String, List<ShopProductEntity>>>();
    stubProductsState(
      const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(shopProductsLoader: (_) => priceResult.future),
    );
    await tester.pump();

    expect(find.text('Fiyat yükleniyor'), findsOneWidget);
    expect(find.text('Mahalle Ürünü'), findsOneWidget);

    priceResult.complete(const Left('Bağlantı hatası'));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
    expect(find.text('Mahalle Ürünü'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('geciken eski kategori fiyatı yeni sonucu değiştirmez', (
    tester,
  ) async {
    const newProduct = ProductEntity(
      id: 'new-product',
      name: 'Yeni Ürün',
      price: 250,
      categoryId: 'category-1',
      stock: 5,
      images: [],
    );
    final states = StreamController<ProductsState>();
    final oldPrice = Completer<Either<String, List<ShopProductEntity>>>();
    final newPrice = Completer<Either<String, List<ShopProductEntity>>>();
    whenListen(
      productsCubit,
      states.stream,
      initialState: const ProductsLoaded(
        products: [product],
        hasReachedMax: true,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      buildSubject(
        shopProductsLoader: (productIds) =>
            productIds.single == product.id ? oldPrice.future : newPrice.future,
      ),
    );
    await tester.pump();

    states.add(
      const ProductsLoaded(
        products: [newProduct],
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
          productId: 'new-product',
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
  });
}
