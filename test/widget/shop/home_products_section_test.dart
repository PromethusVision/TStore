import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_products_section.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockHomeProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockHomeWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late MockHomeProductsCubit productsCubit;
  late MockHomeWishlistCubit wishlistCubit;

  setUp(() {
    productsCubit = MockHomeProductsCubit();
    wishlistCubit = MockHomeWishlistCubit();
    when(
      () => productsCubit.getProducts(
        isFeatured: any(named: 'isFeatured'),
        sortBy: any(named: 'sortBy'),
        ascending: any(named: 'ascending'),
        refresh: any(named: 'refresh'),
      ),
    ).thenAnswer((_) async {});
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
  });

  Widget buildSubject(
    ProductsState state, {
    HomeShopProductsLoader? shopProductsLoader,
  }) {
    whenListen(
      productsCubit,
      const Stream<ProductsState>.empty(),
      initialState: state,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>.value(value: productsCubit),
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: HomeProductsSection(
            currentUserIdProvider: () => null,
            shopProductsLoader:
                shopProductsLoader ?? (_) async => const Right([]),
            destinationBuilder: (product) =>
                Scaffold(key: Key('product-detail-${product.id}')),
          ),
        ),
      ),
    );
  }

  testWidgets('yükleme durumunda sahte ürün göstermez', (tester) async {
    await tester.pumpWidget(buildSubject(ProductsLoading()));

    expect(find.byKey(const Key('home-products-loading')), findsOneWidget);
    expect(find.byKey(const Key('home-products-loaded')), findsNothing);
  });

  testWidgets('boş durumu açıkça gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(const ProductsLoaded(products: [])));

    expect(find.byKey(const Key('home-products-empty')), findsOneWidget);
    expect(find.text('Şu anda gösterilecek ürün bulunamadı'), findsOneWidget);
  });

  testWidgets('hata durumunda gerçek sorguyu yeniden dener', (tester) async {
    await tester.pumpWidget(
      buildSubject(const ProductsError('Teknik ayrıntı')),
    );

    expect(find.byKey(const Key('home-products-error')), findsOneWidget);
    expect(find.text('Teknik ayrıntı'), findsNothing);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(
      () => productsCubit.getProducts(
        isFeatured: true,
        sortBy: 'rating',
        ascending: false,
        refresh: true,
      ),
    ).called(1);
  });

  testWidgets('gerçek ürün bilgisini gösterip ürün detayını açar', (
    tester,
  ) async {
    const product = ProductEntity(
      id: 'product-1',
      name: 'Taze Domates',
      price: 29.90,
      salePrice: 24.90,
      categoryId: 'market',
      stock: 12,
      images: [],
      brandName: 'Nihat Manav',
    );

    await tester.pumpWidget(
      buildSubject(
        const ProductsLoaded(products: [product]),
        shopProductsLoader: (_) async => const Right([
          ShopProductEntity(
            id: 'listing-1',
            shopId: 'shop-1',
            productId: 'product-1',
            price: 24.90,
            shop: ShopEntity(id: 'shop-1', name: 'Nihat Manav'),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-products-loaded')), findsOneWidget);
    expect(find.byKey(const Key('home-product-product-1')), findsOneWidget);
    expect(find.text('Taze Domates'), findsOneWidget);
    expect(find.text('Nihat Manav'), findsOneWidget);
    expect(find.text('24,90 TL’den'), findsOneWidget);
    expect(find.textContaining('indirim'), findsNothing);

    await tester.tap(find.byKey(const Key('home-product-product-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-detail-product-1')), findsOneWidget);
  });

  testWidgets('yalnız ekranda gösterilen ürünleri tek sorguda ister', (
    tester,
  ) async {
    final products = List.generate(
      10,
      (index) => ProductEntity(
        id: 'product-$index',
        name: 'Ürün $index',
        price: 10,
        categoryId: 'market',
        stock: 1,
        images: const [],
      ),
    );
    List<String>? requestedProductIds;

    await tester.pumpWidget(
      buildSubject(
        ProductsLoaded(products: products),
        shopProductsLoader: (productIds) async {
          requestedProductIds = productIds;
          return const Right([]);
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(requestedProductIds, hasLength(8));
    expect(
      requestedProductIds,
      orderedEquals(products.take(8).map((e) => e.id)),
    );
    expect(find.byKey(const Key('home-product-product-8')), findsNothing);
  });

  testWidgets('en düşük satın alınabilir mağaza fiyatını gösterir', (
    tester,
  ) async {
    const product = ProductEntity(
      id: 'product-1',
      name: 'Elektrikli Bisiklet',
      price: 999,
      categoryId: 'ulaşım',
      stock: 1,
      images: [],
    );

    await tester.pumpWidget(
      buildSubject(
        const ProductsLoaded(products: [product]),
        shopProductsLoader: (_) async => const Right([
          ShopProductEntity(
            id: 'listing-expensive',
            shopId: 'shop-1',
            productId: 'product-1',
            price: 1399.99,
            shop: ShopEntity(id: 'shop-1', name: 'Birinci Mağaza'),
          ),
          ShopProductEntity(
            id: 'listing-cheap',
            shopId: 'shop-2',
            productId: 'product-1',
            price: 1299.99,
            shop: ShopEntity(id: 'shop-2', name: 'İkinci Mağaza'),
          ),
          ShopProductEntity(
            id: 'listing-inactive',
            shopId: 'shop-3',
            productId: 'product-1',
            price: 999.99,
            shop: ShopEntity(
              id: 'shop-3',
              name: 'Pasif Mağaza',
              isActive: false,
            ),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.299,99 TL’den'), findsOneWidget);
    expect(find.text('999,99 TL’den'), findsNothing);
  });

  testWidgets('fiyat yüklenemese de ürünü erişilebilir tutar', (tester) async {
    const product = ProductEntity(
      id: 'product-1',
      name: 'Taze Domates',
      price: 29.90,
      categoryId: 'market',
      stock: 1,
      images: [],
    );

    await tester.pumpWidget(
      buildSubject(
        const ProductsLoaded(products: [product]),
        shopProductsLoader: (_) async => const Left('Bağlantı hatası'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
    expect(find.byKey(const Key('home-product-product-1')), findsOneWidget);
  });

  testWidgets('mağaza fiyatı beklenirken yüklenme bilgisini gösterir', (
    tester,
  ) async {
    const product = ProductEntity(
      id: 'product-1',
      name: 'Taze Domates',
      price: 29.90,
      categoryId: 'market',
      stock: 1,
      images: [],
    );
    final priceResult = Completer<Either<String, List<ShopProductEntity>>>();

    await tester.pumpWidget(
      buildSubject(
        const ProductsLoaded(products: [product]),
        shopProductsLoader: (_) => priceResult.future,
      ),
    );

    expect(find.text('Fiyat yükleniyor'), findsOneWidget);
    expect(find.byKey(const Key('home-product-product-1')), findsOneWidget);

    priceResult.complete(const Right([]));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza fiyatını gör'), findsOneWidget);
  });
}
