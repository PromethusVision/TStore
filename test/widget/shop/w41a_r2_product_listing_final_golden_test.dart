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

enum _R2Scenario { loaded, stress, loading, empty, error, sortOpen }

class _R2GoldenCase {
  const _R2GoldenCase({
    required this.name,
    required this.scenario,
    required this.width,
    this.textScale = 1,
  });

  final String name;
  final _R2Scenario scenario;
  final double width;
  final double textScale;
}

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

  const evidenceCases = <_R2GoldenCase>[
    _R2GoldenCase(
      name: 'w41a_r2_loaded_390',
      scenario: _R2Scenario.loaded,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_loaded_320',
      scenario: _R2Scenario.loaded,
      width: 320,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_loaded_430',
      scenario: _R2Scenario.loaded,
      width: 430,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_text_scale_130_390',
      scenario: _R2Scenario.loaded,
      width: 390,
      textScale: 1.3,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_long_content_image_stress_390',
      scenario: _R2Scenario.stress,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_loading_390',
      scenario: _R2Scenario.loading,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_empty_390',
      scenario: _R2Scenario.empty,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_error_390',
      scenario: _R2Scenario.error,
      width: 390,
    ),
    _R2GoldenCase(
      name: 'w41a_r2_sort_open_390',
      scenario: _R2Scenario.sortOpen,
      width: 390,
    ),
  ];

  for (final evidence in evidenceCases) {
    testWidgets('${evidence.name} final visual evidence', (tester) async {
      tester.view.physicalSize = Size(evidence.width, 844);
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
      when(
        () => productsCubit.getProducts(
          categoryId: _leafCategoryId,
          taxonomyQueryScope: _leafScope,
          sortBy: 'created_at',
          ascending: false,
          refresh: true,
        ),
      ).thenAnswer((_) async {});
      when(() => productsCubit.close()).thenAnswer((_) async {});
      whenListen(
        productsCubit,
        const Stream<ProductsState>.empty(),
        initialState: _stateFor(evidence.scenario),
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
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(evidence.textScale)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: const Key('w41a-r2-product-listing-visual-evidence'),
              child: SubCategoryView(
                title: 'Akıllı Telefonlar',
                categoryId: _leafCategoryId,
                taxonomyQueryScope: _leafScope,
                categoryPathLabel:
                    'Elektronik › Telefon & Aksesuarları › Cep Telefonları › Akıllı Telefonlar',
                currentUserIdProvider: () => null,
                shopProductsLoader: (_) async => Right(
                  evidence.scenario == _R2Scenario.stress
                      ? _stressShopProducts
                      : _shopProducts,
                ),
                visualPrototype: true,
              ),
            ),
          ),
        ),
      );
      if (evidence.scenario == _R2Scenario.loading) {
        await tester.pump();
      } else {
        await tester.pumpAndSettle();
      }

      final boundaryFinder = find.byKey(
        const Key('w41a-r2-product-listing-visual-evidence'),
      );
      final fixtureProducts = evidence.scenario == _R2Scenario.stress
          ? _stressProducts
          : _products;
      if (evidence.scenario == _R2Scenario.loaded ||
          evidence.scenario == _R2Scenario.stress ||
          evidence.scenario == _R2Scenario.sortOpen) {
        final imageContext = tester.element(boundaryFinder);
        await tester.runAsync(() async {
          for (final product in fixtureProducts) {
            for (final imagePath in product.images) {
              await precacheImage(AssetImage(imagePath), imageContext);
            }
          }
        });
        await tester.pumpAndSettle();
      }

      if (evidence.scenario == _R2Scenario.sortOpen) {
        await tester.tap(find.byKey(const Key('category-sort-button')));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      final headerFinder = find.byKey(const Key('product-listing-header'));
      expect(headerFinder, findsOneWidget);
      expect(tester.getTopLeft(headerFinder).dy, 0);
      _expectScenario(evidence.scenario);
      final productScroll = find.byKey(const Key('category-products-scroll'));
      if (productScroll.evaluate().isNotEmpty) {
        tester
            .state<ScrollableState>(
              find
                  .descendant(
                    of: productScroll,
                    matching: find.byType(Scrollable),
                  )
                  .first,
            )
            .position
            .jumpTo(0);
        await tester.pump();
      }
      expect(tester.getSize(boundaryFinder), Size(evidence.width, 844));
      expect(tester.getTopLeft(boundaryFinder), Offset.zero);
      final screenFinder = find.byType(Scaffold).first;
      expect(tester.getSize(screenFinder), Size(evidence.width, 844));
      final evidenceFinder = evidence.scenario == _R2Scenario.sortOpen
          ? find.byType(Overlay).first
          : screenFinder;
      await expectLater(
        evidenceFinder,
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

void _expectScenario(_R2Scenario scenario) {
  switch (scenario) {
    case _R2Scenario.loaded:
      expect(find.byKey(const Key('product-listing-overview')), findsOneWidget);
      expect(find.text('3 esnafta var'), findsOneWidget);
      expect(find.text('Mağaza: Yıldız Mahallesi Teknoloji'), findsOneWidget);
      expect(find.text('28.999,00 TL’den'), findsOneWidget);
    case _R2Scenario.stress:
      expect(find.text(_longProductName), findsOneWidget);
      expect(find.text('123.456,78 TL’den'), findsOneWidget);
      expect(find.textContaining('Mağaza: Yıldız'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    case _R2Scenario.loading:
      expect(
        find.byKey(const Key('category-products-loading')),
        findsOneWidget,
      );
    case _R2Scenario.empty:
      expect(find.byKey(const Key('category-products-empty')), findsOneWidget);
    case _R2Scenario.error:
      expect(find.byKey(const Key('category-products-error')), findsOneWidget);
      expect(find.text('Tekrar Dene'), findsOneWidget);
    case _R2Scenario.sortOpen:
      expect(find.text('Varsayılan sıra'), findsOneWidget);
      expect(find.text('En yeniler'), findsOneWidget);
      expect(find.text('Puana göre'), findsOneWidget);
  }
}

ProductsState _stateFor(_R2Scenario scenario) => switch (scenario) {
  _R2Scenario.loaded || _R2Scenario.sortOpen => const ProductsLoaded(
    products: _products,
    hasReachedMax: true,
    currentPage: 1,
  ),
  _R2Scenario.stress => const ProductsLoaded(
    products: _stressProducts,
    hasReachedMax: true,
    currentPage: 1,
  ),
  _R2Scenario.loading => ProductsLoading(),
  _R2Scenario.empty => const ProductsLoaded(
    products: [],
    hasReachedMax: true,
    currentPage: 1,
  ),
  _R2Scenario.error => const ProductsError('Bağlantı hatası'),
};

const _leafCategoryId = 'b7cee2cf-3005-4e9d-95ff-5dfe106f1da3';

final _leafScope = TaxonomyProductQueryScope.exactLeaf(
  categoryId: _leafCategoryId,
);

const _longProductName =
    'Samsung Galaxy S9 256 GB Çift SIM Türkiye Garantili Gece Siyahı';

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
    name: _longProductName,
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

const _stressProducts = <ProductEntity>[
  ProductEntity(
    id: 'stress-square',
    name: 'Kare Görselli Akıllı Telefon',
    price: 19999,
    categoryId: _leafCategoryId,
    stock: 5,
    images: ['assets/images/products/product-slippers.png'],
    brandName: 'Kare görsel testi',
  ),
  ProductEntity(
    id: 'stress-portrait',
    name: 'Portre Görselli Telefon 256 GB',
    price: 28490,
    categoryId: _leafCategoryId,
    stock: 5,
    images: ['assets/images/products/samsung_s9_mobile_back.png'],
    brandName: 'Portre görsel testi',
  ),
  ProductEntity(
    id: 'stress-wide',
    name: _longProductName,
    price: 123456.78,
    categoryId: _leafCategoryId,
    stock: 2,
    images: ['assets/images/products/promo-banner-1.png'],
    brandName: 'Geniş görsel testi',
  ),
  ProductEntity(
    id: 'stress-transparent',
    name: 'Şeffaf Arka Planlı Ürün Görseli',
    price: 16499,
    categoryId: _leafCategoryId,
    stock: 5,
    images: ['assets/images/products/product-shirt_blue_2.png'],
    brandName: 'Şeffaf görsel testi',
  ),
  ProductEntity(
    id: 'stress-whitespace',
    name: 'Geniş İç Boşluklu Ürün',
    price: 22499,
    categoryId: _leafCategoryId,
    stock: 5,
    images: ['assets/images/products/samsung_s9_mobile_withback.png'],
    brandName: 'İç boşluk testi',
  ),
  ProductEntity(
    id: 'stress-fallback',
    name: 'Görseli Hazırlanan Ürün',
    price: 18490,
    categoryId: _leafCategoryId,
    stock: 5,
    images: [],
    brandName: 'EsnaftaVar',
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
    shop: ShopEntity(id: 'shop-4', name: 'Yıldız Mahallesi Teknoloji'),
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

const _stressShopProducts = <ShopProductEntity>[
  ShopProductEntity(
    id: 'stress-listing-square',
    shopId: 'stress-shop-1',
    productId: 'stress-square',
    price: 19999,
    shop: ShopEntity(id: 'stress-shop-1', name: 'Kare Teknoloji'),
  ),
  ShopProductEntity(
    id: 'stress-listing-portrait',
    shopId: 'stress-shop-2',
    productId: 'stress-portrait',
    price: 28490,
    shop: ShopEntity(id: 'stress-shop-2', name: 'Portre İletişim'),
  ),
  ShopProductEntity(
    id: 'stress-listing-wide',
    shopId: 'stress-shop-3',
    productId: 'stress-wide',
    price: 123456.78,
    shop: ShopEntity(
      id: 'stress-shop-3',
      name: 'Yıldız Mahallesi Teknoloji ve İletişim',
    ),
  ),
  ShopProductEntity(
    id: 'stress-listing-transparent',
    shopId: 'stress-shop-4',
    productId: 'stress-transparent',
    price: 16499,
    shop: ShopEntity(id: 'stress-shop-4', name: 'Şeffaf Teknoloji'),
  ),
  ShopProductEntity(
    id: 'stress-listing-whitespace',
    shopId: 'stress-shop-5',
    productId: 'stress-whitespace',
    price: 22499,
    shop: ShopEntity(id: 'stress-shop-5', name: 'Mahalle İletişim'),
  ),
  ShopProductEntity(
    id: 'stress-listing-fallback',
    shopId: 'stress-shop-6',
    productId: 'stress-fallback',
    price: 18490,
    shop: ShopEntity(id: 'stress-shop-6', name: 'Komşu Esnaf'),
  ),
];
