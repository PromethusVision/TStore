import 'dart:async';
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
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class _MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class _MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

enum _GoldenScenario {
  multiple,
  single,
  zero,
  loading,
  error,
  unavailable,
  reviewsEmpty,
  stress,
  gallery,
  heroSquare,
  heroPortrait,
  heroWide,
  heroTransparent,
  heroWhitespace,
}

enum _GoldenFocus { top, information, reviews }

class _GoldenCase {
  const _GoldenCase({
    required this.name,
    required this.scenario,
    this.width = 390,
    this.height = 844,
    this.textScale = 1,
    this.focus = _GoldenFocus.top,
  });

  final String name;
  final _GoldenScenario scenario;
  final double width;
  final double height;
  final double textScale;
  final _GoldenFocus focus;
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

  const evidenceCases = <_GoldenCase>[
    _GoldenCase(
      name: 'w42a_r2_loaded_multiple_sellers_390',
      scenario: _GoldenScenario.multiple,
    ),
    _GoldenCase(
      name: 'w42a_r2_loaded_320',
      scenario: _GoldenScenario.multiple,
      width: 320,
    ),
    _GoldenCase(
      name: 'w42a_r2_loaded_430',
      scenario: _GoldenScenario.multiple,
      width: 430,
    ),
    _GoldenCase(
      name: 'w42a_r2_text_scale_130_390',
      scenario: _GoldenScenario.multiple,
      textScale: 1.3,
    ),
    _GoldenCase(
      name: 'w42a_r2_long_title_large_price_390',
      scenario: _GoldenScenario.stress,
    ),
    _GoldenCase(
      name: 'w42a_r2_single_seller_390',
      scenario: _GoldenScenario.single,
    ),
    _GoldenCase(
      name: 'w42a_r2_zero_sellers_390',
      scenario: _GoldenScenario.zero,
    ),
    _GoldenCase(
      name: 'w42a_r2_product_information_390',
      scenario: _GoldenScenario.multiple,
      focus: _GoldenFocus.information,
    ),
    _GoldenCase(
      name: 'w42a_r2_reviews_present_390',
      scenario: _GoldenScenario.multiple,
      height: 1180,
    ),
    _GoldenCase(
      name: 'w42a_r2_reviews_empty_390',
      scenario: _GoldenScenario.reviewsEmpty,
      height: 1180,
    ),
    _GoldenCase(name: 'w42a_r2_loading_390', scenario: _GoldenScenario.loading),
    _GoldenCase(name: 'w42a_r2_error_390', scenario: _GoldenScenario.error),
    _GoldenCase(
      name: 'w42a_r2_unavailable_390',
      scenario: _GoldenScenario.unavailable,
    ),
    _GoldenCase(
      name: 'w42a_r2_multiple_images_390',
      scenario: _GoldenScenario.gallery,
    ),
    _GoldenCase(
      name: 'w42a_r2_hero_square_390',
      scenario: _GoldenScenario.heroSquare,
    ),
    _GoldenCase(
      name: 'w42a_r2_hero_portrait_390',
      scenario: _GoldenScenario.heroPortrait,
    ),
    _GoldenCase(
      name: 'w42a_r2_hero_wide_390',
      scenario: _GoldenScenario.heroWide,
    ),
    _GoldenCase(
      name: 'w42a_r2_hero_transparent_390',
      scenario: _GoldenScenario.heroTransparent,
    ),
    _GoldenCase(
      name: 'w42a_r2_hero_whitespace_390',
      scenario: _GoldenScenario.heroWhitespace,
    ),
  ];

  for (final evidence in evidenceCases) {
    testWidgets('${evidence.name} final visual evidence', (tester) async {
      tester.view.physicalSize = Size(evidence.width, evidence.height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final product = _productFor(evidence.scenario);
      final sellerResponse = _sellerResponseFor(evidence.scenario);
      final shopRepository = _MockShopRepository();
      final locationService = _MockCustomerLocationService();
      final cartV2Cubit = _MockCartV2Cubit();
      final wishlistCubit = _MockWishlistCubit();

      if (product.isActive) {
        when(
          () => shopRepository.getShopProductsByProduct(product.id),
        ).thenAnswer((_) => sellerResponse);
      }
      when(() => locationService.cachedCoordinates).thenReturn(null);
      when(
        () => locationService.getPreferredLocation(),
      ).thenAnswer((_) async => null);
      whenListen(
        cartV2Cubit,
        const Stream<CartV2State>.empty(),
        initialState: CartV2Initial(),
      );
      whenListen(
        wishlistCubit,
        const Stream<WishlistState>.empty(),
        initialState: WishlistLoaded(const []),
      );
      when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);

      sl.registerLazySingleton<GetShopProductsByProductUsecase>(
        () => GetShopProductsByProductUsecase(shopRepository),
      );
      sl.registerLazySingleton<CustomerLocationService>(() => locationService);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
            BlocProvider<WishlistCubit>.value(value: wishlistCubit),
          ],
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
              key: const Key('w42a-r2-product-details-visual-evidence'),
              child: ProductDetailsView(
                product: product,
                currentUserIdProvider: () => 'customer-1',
                visualPrototype: true,
              ),
            ),
          ),
        ),
      );

      if (evidence.scenario == _GoldenScenario.loading) {
        await tester.pump(const Duration(milliseconds: 100));
      } else {
        await tester.pumpAndSettle();
      }

      final evidenceFinder = find.byKey(
        const Key('w42a-r2-product-details-visual-evidence'),
      );
      final imageContext = tester.element(evidenceFinder);
      await tester.runAsync(() async {
        for (final imagePath in product.images) {
          await precacheImage(AssetImage(imagePath), imageContext);
        }
      });
      await tester.pump(const Duration(milliseconds: 100));

      final focusFinder = switch (evidence.focus) {
        _GoldenFocus.top => null,
        _GoldenFocus.information => find.byKey(
          const Key('product-details-facts-card'),
        ),
        _GoldenFocus.reviews => find.byKey(
          const Key('product-details-reviews-preview'),
        ),
      };
      if (focusFinder != null) {
        final scrollView = tester.widget<SingleChildScrollView>(
          find.byKey(const Key('product-details-scroll')),
        );
        final position = scrollView.controller!.position;
        final targetOffset =
            (position.pixels + tester.getTopLeft(focusFinder).dy - 85).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            );
        position.jumpTo(targetOffset);
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(evidenceFinder),
        Size(evidence.width, evidence.height),
      );
      _expectScenario(evidence.scenario);
      await expectLater(
        evidenceFinder,
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

void _expectScenario(_GoldenScenario scenario) {
  switch (scenario) {
    case _GoldenScenario.multiple ||
        _GoldenScenario.heroSquare ||
        _GoldenScenario.heroPortrait ||
        _GoldenScenario.heroWide ||
        _GoldenScenario.heroTransparent ||
        _GoldenScenario.heroWhitespace:
      expect(find.text('3 esnafta var'), findsOneWidget);
      expect(find.text('28.999,00 TL’den'), findsOneWidget);
      expect(find.text('Esnafları karşılaştır'), findsOneWidget);
    case _GoldenScenario.single:
      expect(find.text('1 esnafta var'), findsOneWidget);
      expect(find.text('29.999,90 TL'), findsOneWidget);
      expect(find.text('Esnafı gör'), findsOneWidget);
    case _GoldenScenario.zero:
      expect(find.text('Şu anda aktif esnaf yok'), findsOneWidget);
      expect(
        find.byKey(const Key('product-details-compare-sellers')),
        findsNothing,
      );
    case _GoldenScenario.loading:
      expect(find.text('Esnaf seçenekleri hazırlanıyor'), findsOneWidget);
    case _GoldenScenario.error:
      expect(find.text('Esnaf bilgileri alınamadı'), findsOneWidget);
    case _GoldenScenario.unavailable:
      expect(
        find.byKey(const Key('product-details-unavailable')),
        findsOneWidget,
      );
    case _GoldenScenario.reviewsEmpty:
      expect(find.text('Henüz değerlendirme yok'), findsOneWidget);
    case _GoldenScenario.stress:
      expect(find.text('2 esnafta var'), findsOneWidget);
      expect(find.text('123.456.789,87 TL’den'), findsOneWidget);
    case _GoldenScenario.gallery:
      expect(find.text('3 görsel'), findsOneWidget);
      expect(find.text('3 esnafta var'), findsOneWidget);
  }
}

ProductEntity _productFor(_GoldenScenario scenario) {
  return switch (scenario) {
    _GoldenScenario.stress => _stressProduct,
    _GoldenScenario.unavailable => _product.copyWith(
      id: 'inactive-product',
      name: 'Geçici Olarak Pasif Ürün',
      isActive: false,
    ),
    _GoldenScenario.reviewsEmpty => _product.copyWith(
      id: 'reviews-empty-product',
      rating: 0,
      reviewsCount: 0,
    ),
    _GoldenScenario.gallery => _product.copyWith(
      id: 'gallery-product',
      images: const [
        'assets/images/products/samsung_s9_mobile.png',
        'assets/images/products/samsung_s9_mobile_back.png',
        'assets/images/products/samsung_s9_mobile_withback.png',
      ],
    ),
    _GoldenScenario.heroSquare => _product.copyWith(
      id: 'hero-square',
      images: const ['assets/images/products/product-slippers.png'],
    ),
    _GoldenScenario.heroPortrait => _product.copyWith(
      id: 'hero-portrait',
      images: const ['assets/images/products/samsung_s9_mobile_back.png'],
    ),
    _GoldenScenario.heroWide => _product.copyWith(
      id: 'hero-wide',
      images: const ['assets/images/products/promo-banner-1.png'],
    ),
    _GoldenScenario.heroTransparent => _product.copyWith(
      id: 'hero-transparent',
      images: const ['assets/images/products/product-shirt_blue_2.png'],
    ),
    _GoldenScenario.heroWhitespace => _product.copyWith(
      id: 'hero-whitespace',
      images: const ['assets/images/products/samsung_s9_mobile_withback.png'],
    ),
    _ => _product,
  };
}

Future<Either<String, List<ShopProductEntity>>> _sellerResponseFor(
  _GoldenScenario scenario,
) {
  return switch (scenario) {
    _GoldenScenario.single => Future.value(const Right([_singleSeller])),
    _GoldenScenario.zero => Future.value(const Right([])),
    _GoldenScenario.loading =>
      Completer<Either<String, List<ShopProductEntity>>>().future,
    _GoldenScenario.error => Future.value(const Left('Bağlantı hatası')),
    _GoldenScenario.stress => Future.value(const Right(_largePriceSellers)),
    _ => Future.value(const Right(_multipleSellers)),
  };
}

const _product = ProductEntity(
  id: 'phone-1',
  name: 'Samsung Galaxy S9 256 GB Çift SIM Türkiye Garantili Gece Siyahı',
  description:
      'Canlı ekranı, kompakt yapısı ve güçlü kamerasıyla günlük kullanım için dengeli bir akıllı telefon.',
  price: 31999,
  categoryId: 'smartphones',
  categoryName: 'Akıllı Telefonlar',
  brandName: 'Samsung',
  stock: 8,
  images: ['assets/images/products/samsung_s9_mobile_withback.png'],
  rating: 4.8,
  reviewsCount: 128,
);

const _stressProduct = ProductEntity(
  id: 'stress-phone',
  name:
      'Çok Uzun İsimli Samsung Galaxy Profesyonel 512 GB Çift SIM Türkiye Garantili Özel Üretim Akıllı Telefon',
  description:
      'Ç Ğ İ Ö Ş Ü karakterlerini, uzun açıklama alanını ve fiziksel esnaftan edinilen güncel yerel ürün bilgisini güvenli biçimde sınayan içerik.',
  price: 199999999,
  categoryId: 'smartphones',
  categoryName:
      'Elektronik ve Teknoloji Ürünleri Telefon Aksesuarları Akıllı Cihazlar',
  brandName: 'Çok Uzun Markalı Teknoloji Ürünleri Türkiye',
  stock: 2,
  images: ['assets/images/products/samsung_s9_mobile_back.png'],
  rating: 4.7,
  reviewsCount: 9876,
);

const _singleSeller = ShopProductEntity(
  id: 'single',
  shopId: 'shop-single',
  productId: 'phone-1',
  price: 29999.90,
  shop: ShopEntity(
    id: 'shop-single',
    ownerUserId: 'owner-single',
    name: 'Çınar Teknoloji',
    address: 'Kadıköy, İstanbul',
    rating: 4.8,
  ),
);

const _multipleSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'listing-1',
    shopId: 'shop-1',
    productId: 'phone-1',
    price: 28999,
    shop: ShopEntity(
      id: 'shop-1',
      ownerUserId: 'owner-1',
      name: 'Çınar Teknoloji',
      address: 'Kadıköy, İstanbul',
      rating: 4.8,
    ),
  ),
  ShopProductEntity(
    id: 'listing-2',
    shopId: 'shop-2',
    productId: 'phone-1',
    price: 29949.55,
    shop: ShopEntity(
      id: 'shop-2',
      ownerUserId: 'owner-2',
      name: 'Mahalle İletişim',
      address: 'Üsküdar, İstanbul',
      rating: 4.6,
    ),
  ),
  ShopProductEntity(
    id: 'listing-3',
    shopId: 'shop-3',
    productId: 'phone-1',
    price: 30490,
    shop: ShopEntity(
      id: 'shop-3',
      ownerUserId: 'owner-3',
      name: 'Yıldız Mahallesi Teknoloji',
      address: 'Beşiktaş, İstanbul',
      rating: 4.7,
    ),
  ),
];

const _largePriceSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'large-1',
    shopId: 'large-shop-1',
    productId: 'stress-phone',
    price: 123456789.87,
    shop: ShopEntity(
      id: 'large-shop-1',
      name: 'Çok Uzun İsimli Mahalle Teknoloji Esnafı',
      rating: 4.9,
    ),
  ),
  ShopProductEntity(
    id: 'large-2',
    shopId: 'large-shop-2',
    productId: 'stress-phone',
    price: 199999999.99,
    shop: ShopEntity(
      id: 'large-shop-2',
      name: 'Güven Çarşısı Elektronik ve İletişim',
      rating: 4.8,
    ),
  ),
];
