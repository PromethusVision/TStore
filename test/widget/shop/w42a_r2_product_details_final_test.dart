import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
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
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class _MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class _MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late _MockShopRepository shopRepository;
  late _MockCustomerLocationService locationService;
  late _MockCartV2Cubit cartV2Cubit;
  late _MockWishlistCubit wishlistCubit;

  setUp(() async {
    await sl.reset();
    shopRepository = _MockShopRepository();
    locationService = _MockCustomerLocationService();
    cartV2Cubit = _MockCartV2Cubit();
    wishlistCubit = _MockWishlistCubit();

    when(() => locationService.cachedCoordinates).thenReturn(null);
    when(
      () => locationService.getPreferredLocation(),
    ).thenAnswer((_) async => null);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    when(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
    when(() => wishlistCubit.toggleWishlist(any())).thenAnswer((_) async {});

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(() => locationService);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    ProductEntity product = _product,
    double width = 390,
    double textScale = 1,
    ProductReviewsDestinationBuilder? reviewsDestinationBuilder,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      ],
      child: MaterialApp(
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: SizedBox(
          width: width,
          child: ProductDetailsView(
            product: product,
            currentUserIdProvider: () => 'customer-1',
            reviewsDestinationBuilder: reviewsDestinationBuilder,
            visualPrototype: true,
          ),
        ),
      ),
    );
  }

  void stubSellers(
    Future<Either<String, List<ShopProductEntity>>> Function() loader, {
    ProductEntity product = _product,
  }) {
    when(
      () => shopRepository.getShopProductsByProduct(product.id),
    ).thenAnswer((_) => loader());
  }

  testWidgets(
    'onaylı ilk görünüm çoklu esnaf fiyatını ve karşılaştırmayı öne çıkarır',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      stubSellers(() async => const Right(_multipleSellers));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('3 esnafta var'), findsOneWidget);
      expect(find.text('28.999,00 TL’den'), findsOneWidget);
      expect(find.text('Esnafları karşılaştır'), findsOneWidget);
      expect(find.byKey(const Key('product-details-media')), findsOneWidget);
      expect(find.text(_product.name), findsOneWidget);

      final compare = find.byKey(const Key('product-details-compare-sellers'));
      expect(tester.getBottomLeft(compare).dy, lessThanOrEqualTo(844));
      expect(tester.getSize(compare).height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSize(find.byKey(const Key('product-details-back-button')))
            .height,
        greaterThanOrEqualTo(44),
      );
      expect(
        tester
            .getSize(find.byKey(const Key('product-details-favorite-action')))
            .height,
        greaterThanOrEqualTo(44),
      );
      expect(
        find.textContaining(RegExp('kargo', caseSensitive: false)),
        findsNothing,
      );
      expect(
        find.textContaining(
          RegExp('teslimat|ödeme|hemen al|checkout', caseSensitive: false),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tek esnaf doğrudan fiyat ve tekil eylem gösterir', (
    tester,
  ) async {
    stubSellers(() async => const Right([_singleSeller]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('1 esnafta var'), findsOneWidget);
    expect(find.text('29.999,90 TL'), findsOneWidget);
    expect(find.textContaining('TL’den'), findsNothing);
    expect(find.text('Esnafı gör'), findsOneWidget);
    expect(find.text('Esnafları karşılaştır'), findsNothing);

    await tester.tap(find.byKey(const Key('product-details-compare-sellers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('product-seller-single')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sıfır esnaf sahte fiyat veya karşılaştırma çağrısı üretmez', (
    tester,
  ) async {
    stubSellers(() async => const Right([]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Şu anda aktif esnaf yok'), findsOneWidget);
    expect(
      find.byKey(const Key('product-details-minimum-price')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('product-details-compare-sellers')),
      findsNothing,
    );
    expect(find.byKey(const Key('product-sellers-empty')), findsOneWidget);
  });

  testWidgets('yükleme esnasında yalnız gerçek yükleme durumu gösterilir', (
    tester,
  ) async {
    final pending = Completer<Either<String, List<ShopProductEntity>>>();
    stubSellers(() => pending.future);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Esnaf seçenekleri hazırlanıyor'), findsOneWidget);
    expect(
      find.byKey(const Key('product-details-compare-sellers')),
      findsNothing,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('esnaf hatası fiyatı gizler ve mevcut tekrar denemeyi korur', (
    tester,
  ) async {
    stubSellers(() async => const Left('Bağlantı hatası'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Esnaf bilgileri alınamadı'), findsOneWidget);
    expect(
      find.byKey(const Key('product-details-minimum-price')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('product-details-compare-sellers')),
      findsNothing,
    );
    expect(find.byKey(const Key('product-sellers-retry')), findsOneWidget);
  });

  testWidgets('pasif ürün mevcut domain alanıyla güvenli unavailable olur', (
    tester,
  ) async {
    const unavailableProduct = ProductEntity(
      id: 'inactive-product',
      name: 'Geçici Olarak Pasif Ürün',
      description: 'Ürün bilgisi korunur.',
      price: 149,
      categoryId: 'market',
      categoryName: 'Market',
      stock: 0,
      images: [],
      isActive: false,
    );

    await tester.pumpWidget(buildSubject(product: unavailableProduct));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('product-details-unavailable')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('product-details-local-availability')),
      findsNothing,
    );
    expect(find.byKey(const Key('product-details-sellers-card')), findsNothing);
    verifyNever(
      () => shopRepository.getShopProductsByProduct(unavailableProduct.id),
    );
  });

  for (final responsiveCase in const [
    (name: '320', width: 320.0, textScale: 1.0),
    (name: '390', width: 390.0, textScale: 1.0),
    (name: '430', width: 430.0, textScale: 1.0),
    (name: '390 yüzde 130', width: 390.0, textScale: 1.3),
  ]) {
    testWidgets(
      '${responsiveCase.name} genişlik/yazı ölçeğinde uzun Türkçe içerik taşmaz',
      (tester) async {
        tester.view.physicalSize = Size(responsiveCase.width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        stubSellers(
          () async => const Right(_largePriceSellers),
          product: _stressProduct,
        );

        await tester.pumpWidget(
          buildSubject(
            product: _stressProduct,
            width: responsiveCase.width,
            textScale: responsiveCase.textScale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(_stressProduct.name), findsOneWidget);
        expect(find.text('123.456.789,87 TL’den'), findsOneWidget);
        expect(find.text('2 esnafta var'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('ürün bilgileri ve değerlendirme özeti veri uydurmadan korunur', (
    tester,
  ) async {
    ProductEntity? openedProduct;
    stubSellers(() async => const Right(_multipleSellers));

    await tester.pumpWidget(
      buildSubject(
        reviewsDestinationBuilder: (product) {
          openedProduct = product;
          return const Scaffold(body: Text('Değerlendirme hedefi'));
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ürün bilgileri'), findsOneWidget);
    expect(find.text('Marka: Samsung'), findsOneWidget);
    expect(find.text('Kategori: Akıllı Telefonlar'), findsOneWidget);
    expect(find.text('Değerlendirmeler'), findsOneWidget);
    expect(find.text('4.8 · 128 değerlendirme'), findsOneWidget);
    expect(find.text('Doğrulanmış Alışveriş'), findsNothing);

    final reviewsAction = find.byKey(const Key('product-reviews-action'));
    await tester.ensureVisible(reviewsAction);
    await tester.tap(reviewsAction);
    await tester.pumpAndSettle();

    expect(openedProduct?.id, _product.id);
    expect(find.text('Değerlendirme hedefi'), findsOneWidget);
  });

  testWidgets('değerlendirme olmayan ürün doğru boş özeti gösterir', (
    tester,
  ) async {
    final productWithoutReviews = _product.copyWith(rating: 0, reviewsCount: 0);
    stubSellers(
      () async => const Right(_multipleSellers),
      product: productWithoutReviews,
    );

    await tester.pumpWidget(buildSubject(product: productWithoutReviews));
    await tester.pumpAndSettle();

    expect(find.text('Henüz değerlendirme yok'), findsOneWidget);
    expect(find.text('İlk değerlendirmeler burada görünecek'), findsOneWidget);
    expect(find.text('Doğrulanmış Alışveriş'), findsNothing);
  });

  testWidgets('Cart V2 satıcı kaydı ve fiziksel hazırlık anlamını korur', (
    tester,
  ) async {
    stubSellers(() async => const Right([_singleSeller]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-details-compare-sellers')));
    await tester.pumpAndSettle();

    final cartAction = find.byKey(const ValueKey('product-seller-add-single'));
    await tester.ensureVisible(cartAction);
    await tester.tap(cartAction);
    await tester.pump();

    verify(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: 'single',
        quantity: 1,
      ),
    ).called(1);
    expect(
      find.textContaining(
        RegExp('ödeme|sipariş|checkout', caseSensitive: false),
      ),
      findsNothing,
    );
  });

  testWidgets('opt-in hero tüm görsel oranlarında contain kullanır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final image in _imageStressAssets) {
      final imageProduct = _product.copyWith(images: [image]);
      await tester.pumpWidget(
        MaterialApp(
          theme: EsnaftaVarTheme.light,
          home: ProductImageSlider(
            product: imageProduct,
            visualPrototype: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final media = find.byKey(const Key('product-details-media'));
      expect(tester.widget<Container>(media).constraints?.maxHeight, 224);
      expect(
        tester
            .widget<RoundedImage>(find.byType(RoundedImage))
            .roundedImageModel
            .fit,
        BoxFit.contain,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('çoklu görsel ipucu ve eski galeri sunumu birlikte korunur', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const galleryProduct = ProductEntity(
      id: 'gallery-product',
      name: 'Çok Görselli Ürün',
      price: 100,
      categoryId: 'market',
      stock: 1,
      images: [
        'assets/images/products/samsung_s9_mobile.png',
        'assets/images/products/samsung_s9_mobile_back.png',
        'assets/images/products/samsung_s9_mobile_withback.png',
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: const ProductImageSlider(
          product: galleryProduct,
          visualPrototype: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 görsel'), findsOneWidget);
    expect(
      tester
          .widget<Container>(find.byKey(const Key('product-details-media')))
          .constraints
          ?.maxHeight,
      224,
    );

    await tester.pumpWidget(
      BlocProvider<WishlistCubit>.value(
        value: wishlistCubit,
        child: MaterialApp(
          home: ProductImageSlider(
            product: galleryProduct,
            currentUserIdProvider: () => 'customer-1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OtherSameProductsList), findsOneWidget);
    expect(
      tester
          .widget<Container>(find.byKey(const Key('product-details-media')))
          .constraints
          ?.maxHeight,
      340,
    );
  });
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
      ownerUserId: 'large-owner-1',
      name: 'Çok Uzun İsimli Mahalle Teknoloji Esnafı',
      address: 'Şişli, İstanbul',
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
      ownerUserId: 'large-owner-2',
      name: 'Güven Çarşısı Elektronik ve İletişim',
      address: 'Üsküdar, İstanbul',
      rating: 4.8,
    ),
  ),
];

const _imageStressAssets = <String>[
  'assets/images/products/product-slippers.png',
  'assets/images/products/samsung_s9_mobile_back.png',
  'assets/images/products/promo-banner-1.png',
  'assets/images/products/product-shirt_blue_2.png',
  'assets/images/products/samsung_s9_mobile_withback.png',
];
