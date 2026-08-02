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
  }) {
    return BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: MaterialApp(
        home: SubCategoryView(
          title: 'Market',
          categoryId: 'category-1',
          currentUserIdProvider: () => null,
          shopProductsLoader: shopProductsLoader,
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

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

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
