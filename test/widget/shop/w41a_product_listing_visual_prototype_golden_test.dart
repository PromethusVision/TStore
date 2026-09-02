import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class _MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class _MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
      ..addFont(
        rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
      );
    final flutterArtifacts = File(
      Platform.resolvedExecutable,
    ).parent.parent.parent;
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${flutterArtifacts.path}${Platform.pathSeparator}material_fonts'
          '${Platform.pathSeparator}MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), iconsax.load(), materialIcons.load()]);
  });

  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  for (final evidence in const [
    (name: 'w41a_before_product_listing_390', visualPrototype: false),
    (name: 'w41a_product_listing_prototype_390', visualPrototype: true),
  ]) {
    testWidgets('${evidence.name} visual evidence', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final productsCubit = _MockProductsCubit();
      final wishlistCubit = _MockWishlistCubit();
      when(
        () => productsCubit.getProducts(
          categoryId: _leafCategoryId,
          taxonomyQueryScope: _leafScope,
          refresh: true,
        ),
      ).thenAnswer((_) async {});
      when(() => productsCubit.close()).thenAnswer((_) async {});
      whenListen(
        productsCubit,
        const Stream<ProductsState>.empty(),
        initialState: const ProductsLoaded(
          products: _products,
          hasReachedMax: true,
          currentPage: 1,
        ),
      );
      whenListen(
        wishlistCubit,
        const Stream<WishlistState>.empty(),
        initialState: WishlistLoaded(const []),
      );
      when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
      sl.registerFactory<ProductsCubit>(() => productsCubit);

      await tester.pumpWidget(
        BlocProvider<WishlistCubit>.value(
          value: wishlistCubit,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: EsnaftaVarTheme.light,
            home: RepaintBoundary(
              key: const Key('w41a-product-listing-visual-evidence'),
              child: SubCategoryView(
                title: 'Akıllı Telefonlar',
                categoryId: _leafCategoryId,
                taxonomyQueryScope: _leafScope,
                categoryPathLabel:
                    'Elektronik › Telefon & Aksesuarları › Cep Telefonları',
                currentUserIdProvider: () => null,
                shopProductsLoader: (_) async => const Right(_shopProducts),
                visualPrototype: evidence.visualPrototype,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('category-products-scroll')), findsOneWidget);
      expect(find.byKey(const Key('category-products-grid')), findsOneWidget);
      expect(find.text('28.999,00 TL’den'), findsOneWidget);
      if (evidence.visualPrototype) {
        expect(find.byKey(const Key('product-listing-header')), findsOneWidget);
        expect(
          find.byKey(const Key('product-listing-overview')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('category-sort-button')), findsOneWidget);
        expect(find.text('3 esnafta var'), findsOneWidget);
        expect(
          find.text('Yıldız Mahallesi Teknoloji ve İletişim'),
          findsOneWidget,
        );
      }
      await expectLater(
        find.byKey(const Key('w41a-product-listing-visual-evidence')),
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

const _leafCategoryId = 'b7cee2cf-3005-4e9d-95ff-5dfe106f1da3';

final _leafScope = TaxonomyProductQueryScope.exactLeaf(
  categoryId: _leafCategoryId,
);

const _products = <ProductEntity>[
  ProductEntity(
    id: 'phone-1',
    name: 'Samsung Galaxy S9 128 GB',
    price: 31999,
    categoryId: _leafCategoryId,
    stock: 8,
    images: ['assets/images/products/samsung_s9_mobile.png'],
    brandName: 'Samsung',
  ),
  ProductEntity(
    id: 'phone-2',
    name: 'Samsung Galaxy S9+ Gece Siyahı',
    price: 34999,
    categoryId: _leafCategoryId,
    stock: 4,
    images: ['assets/images/products/samsung_s9_mobile_withback.png'],
    brandName: 'Samsung',
  ),
  ProductEntity(
    id: 'phone-3',
    name: 'Samsung Galaxy S9 256 GB Çift SIM Çok Uzun Ürün Adı',
    price: 123456.78,
    categoryId: _leafCategoryId,
    stock: 2,
    images: ['assets/images/products/samsung_s9_mobile_back.png'],
    brandName: 'Samsung Türkiye Garantili',
  ),
  ProductEntity(
    id: 'phone-4',
    name: 'Samsung Galaxy S9 Gümüş',
    price: 30499,
    categoryId: _leafCategoryId,
    stock: 7,
    images: ['assets/images/products/samsung_s9_mobile.png'],
    brandName: 'Samsung',
  ),
  ProductEntity(
    id: 'phone-5',
    name: 'Galaxy S9 Yenilenmiş Telefon',
    price: 26750,
    categoryId: _leafCategoryId,
    stock: 3,
    images: ['assets/images/products/samsung_s9_mobile_withback.png'],
    brandName: 'Samsung',
  ),
  ProductEntity(
    id: 'phone-6',
    name: 'Samsung Galaxy S9 64 GB',
    price: 29490,
    categoryId: _leafCategoryId,
    stock: 6,
    images: ['assets/images/products/samsung_s9_mobile_back.png'],
    brandName: 'Samsung',
  ),
];

const _shopProducts = <ShopProductEntity>[
  ShopProductEntity(
    id: 'listing-1-a',
    shopId: 'shop-1',
    productId: 'phone-1',
    price: 28999,
    shop: ShopEntity(id: 'shop-1', name: 'Çınar Teknoloji'),
  ),
  ShopProductEntity(
    id: 'listing-1-b',
    shopId: 'shop-2',
    productId: 'phone-1',
    price: 29949,
    shop: ShopEntity(id: 'shop-2', name: 'Mahalle İletişim'),
  ),
  ShopProductEntity(
    id: 'listing-1-c',
    shopId: 'shop-3',
    productId: 'phone-1',
    price: 30490,
    shop: ShopEntity(id: 'shop-3', name: 'Umut Elektronik'),
  ),
  ShopProductEntity(
    id: 'listing-2-a',
    shopId: 'shop-4',
    productId: 'phone-2',
    price: 32499.90,
    shop: ShopEntity(
      id: 'shop-4',
      name: 'Yıldız Mahallesi Teknoloji ve İletişim',
    ),
  ),
  ShopProductEntity(
    id: 'listing-3-a',
    shopId: 'shop-1',
    productId: 'phone-3',
    price: 123456.78,
    shop: ShopEntity(id: 'shop-1', name: 'Çınar Teknoloji'),
  ),
  ShopProductEntity(
    id: 'listing-3-b',
    shopId: 'shop-5',
    productId: 'phone-3',
    price: 124999,
    shop: ShopEntity(id: 'shop-5', name: 'Güven Mobil'),
  ),
  ShopProductEntity(
    id: 'listing-4-a',
    shopId: 'shop-6',
    productId: 'phone-4',
    price: 30499,
    shop: ShopEntity(id: 'shop-6', name: 'Semt Telefon'),
  ),
  ShopProductEntity(
    id: 'listing-5-a',
    shopId: 'shop-7',
    productId: 'phone-5',
    price: 26750,
    shop: ShopEntity(id: 'shop-7', name: 'Komşu Teknoloji'),
  ),
  ShopProductEntity(
    id: 'listing-6-a',
    shopId: 'shop-8',
    productId: 'phone-6',
    price: 29490,
    shop: ShopEntity(id: 'shop-8', name: 'Merkez İletişim'),
  ),
];
