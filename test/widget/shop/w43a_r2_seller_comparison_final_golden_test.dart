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
import 'package:t_store/features/shop/presentation/views/seller_comparison_view.dart';

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class _MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

enum _EvidenceState { loaded, loading, error }

class _EvidenceCase {
  const _EvidenceCase({
    required this.name,
    required this.sellers,
    this.width = 390,
    this.textScale = 1,
    this.state = _EvidenceState.loaded,
  });

  final String name;
  final List<ShopProductEntity> sellers;
  final double width;
  final double textScale;
  final _EvidenceState state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
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
    await Future.wait([poppins.load(), materialIcons.load()]);
  });

  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  for (final evidence in const <_EvidenceCase>[
    _EvidenceCase(name: 'w43a_r2_many_sellers_390', sellers: _sellers),
    _EvidenceCase(name: 'w43a_r2_one_seller_390', sellers: _singleSeller),
    _EvidenceCase(
      name: 'w43a_r2_zero_sellers_390',
      sellers: <ShopProductEntity>[],
    ),
    _EvidenceCase(name: 'w43a_r2_loaded_320', sellers: _sellers, width: 320),
    _EvidenceCase(name: 'w43a_r2_loaded_430', sellers: _sellers, width: 430),
    _EvidenceCase(
      name: 'w43a_r2_text_scale_130_390',
      sellers: _sellers,
      textScale: 1.3,
    ),
    _EvidenceCase(
      name: 'w43a_r2_long_merchant_large_price_390',
      sellers: _stressSellers,
    ),
    _EvidenceCase(
      name: 'w43a_r2_loading_390',
      sellers: <ShopProductEntity>[],
      state: _EvidenceState.loading,
    ),
    _EvidenceCase(name: 'w43a_r2_empty_390', sellers: <ShopProductEntity>[]),
    _EvidenceCase(
      name: 'w43a_r2_error_390',
      sellers: <ShopProductEntity>[],
      state: _EvidenceState.error,
    ),
    _EvidenceCase(
      name: 'w43a_r2_equal_lowest_390',
      sellers: _equalLowestSellers,
    ),
    _EvidenceCase(
      name: 'w43a_r2_unavailable_unknown_390',
      sellers: _unavailableAndUnknownSellers,
    ),
  ]) {
    testWidgets('${evidence.name} visual evidence', (tester) async {
      tester.view.physicalSize = Size(evidence.width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _MockShopRepository();
      final locationService = _MockCustomerLocationService();
      final cartV2Cubit = _MockCartV2Cubit();
      final loadingRequest =
          Completer<Either<String, List<ShopProductEntity>>>();

      when(() => repository.getShopProductsByProduct(_product.id)).thenAnswer((
        _,
      ) {
        return switch (evidence.state) {
          _EvidenceState.loaded => Future.value(
            Right<String, List<ShopProductEntity>>(evidence.sellers),
          ),
          _EvidenceState.loading => loadingRequest.future,
          _EvidenceState.error => Future.value(
            const Left<String, List<ShopProductEntity>>('Bağlantı hatası'),
          ),
        };
      });
      when(() => locationService.cachedCoordinates).thenReturn(
        const CustomerCoordinates(latitude: 40.9912, longitude: 29.0284),
      );
      when(
        () => locationService.getPreferredLocation(),
      ).thenAnswer((_) async => null);
      whenListen(
        cartV2Cubit,
        const Stream<CartV2State>.empty(),
        initialState: CartV2Initial(),
      );

      sl.registerLazySingleton<GetShopProductsByProductUsecase>(
        () => GetShopProductsByProductUsecase(repository),
      );
      sl.registerLazySingleton<CustomerLocationService>(() => locationService);

      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('w43a-r2-seller-comparison-evidence'),
          child: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: EsnaftaVarTheme.light,
              builder: evidence.textScale == 1
                  ? null
                  : (context, child) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(evidence.textScale),
                      ),
                      child: child!,
                    ),
              home: SellerComparisonView(
                product: _product,
                currentUserIdProvider: () => 'customer-1',
                shopDestinationBuilder: (shop) => Scaffold(
                  body: Center(child: Text('Mağaza ayrıntısı: ${shop.id}')),
                ),
              ),
            ),
          ),
        ),
      );

      final imageContext = tester.element(
        find.byKey(const Key('w43a-r2-seller-comparison-evidence')),
      );
      await tester.runAsync(() async {
        await precacheImage(const AssetImage(_productImage), imageContext);
      });
      if (evidence.state == _EvidenceState.loading) {
        await tester.pump(const Duration(milliseconds: 100));
      } else {
        await tester.pumpAndSettle();
      }

      if (evidence.name == 'w43a_r2_one_seller_390') {
        expect(find.text('En uygun fiyat'), findsNothing);
        expect(find.text('Yerel esnaf'), findsOneWidget);
      }
      if (evidence.name == 'w43a_r2_equal_lowest_390') {
        expect(find.text('En uygun fiyat'), findsOneWidget);
      }
      if (evidence.name == 'w43a_r2_unavailable_unknown_390') {
        expect(find.byKey(const Key('product-sellers-empty')), findsOneWidget);
        expect(find.text('Rafta var'), findsNothing);
      }
      expect(tester.takeException(), isNull);

      await expectLater(
        find.byKey(const Key('w43a-r2-seller-comparison-evidence')),
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

const _productImage = 'assets/images/products/samsung_s9_mobile_withback.png';

const _product = ProductEntity(
  id: 'phone-1',
  name: 'Samsung Galaxy S9 256 GB Çift SIM Türkiye Garantili Gece Siyahı',
  price: 31999,
  categoryId: 'smartphones',
  categoryName: 'Akıllı Telefonlar',
  brandName: 'Samsung',
  stock: 8,
  images: [_productImage],
  rating: 4.8,
  reviewsCount: 128,
);

const _sellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'listing-1',
    shopId: 'shop-1',
    productId: 'phone-1',
    price: 28999,
    shop: ShopEntity(
      id: 'shop-1',
      name: 'Çınar Teknoloji',
      address: 'Kadıköy, İstanbul',
      latitude: 40.9912,
      longitude: 29.0284,
      rating: 4.8,
    ),
  ),
  ShopProductEntity(
    id: 'listing-2',
    shopId: 'shop-2',
    productId: 'phone-1',
    price: 29949,
    shop: ShopEntity(
      id: 'shop-2',
      name: 'Mahalle İletişim',
      address: 'Üsküdar, İstanbul',
      latitude: 41.0258,
      longitude: 29.0159,
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
      name: 'Yıldız Mahallesi Teknoloji',
      address: 'Beşiktaş, İstanbul',
      latitude: 41.0496,
      longitude: 29.0122,
      rating: 4.7,
    ),
  ),
];

const _singleSeller = <ShopProductEntity>[
  ShopProductEntity(
    id: 'single-listing',
    shopId: 'single-shop',
    productId: 'phone-1',
    price: 30125.75,
    shop: ShopEntity(
      id: 'single-shop',
      name: 'Çınar Teknoloji',
      address: 'Kadıköy, İstanbul',
      latitude: 40.9912,
      longitude: 29.0284,
      rating: 4.8,
    ),
  ),
];

const _equalLowestSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'equal-1',
    shopId: 'equal-shop-1',
    productId: 'phone-1',
    price: 28999.90,
    shop: ShopEntity(
      id: 'equal-shop-1',
      name: 'Moda Teknoloji',
      address: 'Kadıköy, İstanbul',
      latitude: 40.9912,
      longitude: 29.0284,
      rating: 4.8,
    ),
  ),
  ShopProductEntity(
    id: 'equal-2',
    shopId: 'equal-shop-2',
    productId: 'phone-1',
    price: 28999.90,
    shop: ShopEntity(
      id: 'equal-shop-2',
      name: 'Semt İletişim',
      address: 'Kadıköy, İstanbul',
      latitude: 40.994,
      longitude: 29.029,
      rating: 4.7,
    ),
  ),
  ShopProductEntity(
    id: 'equal-3',
    shopId: 'equal-shop-3',
    productId: 'phone-1',
    price: 30249.50,
    shop: ShopEntity(
      id: 'equal-shop-3',
      name: 'Çarşı Elektronik',
      address: 'Üsküdar, İstanbul',
      latitude: 41.0258,
      longitude: 29.0159,
      rating: 4.5,
    ),
  ),
];

const _stressSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'stress-listing',
    shopId: 'stress-shop',
    productId: 'phone-1',
    price: 123456789.87,
    shop: ShopEntity(
      id: 'stress-shop',
      name: 'ÇĞİÖŞÜ Mahalle Esnafı Dayanışma ve Teknoloji Kooperatifi',
      address: 'Caferağa Mahallesi ve Çevresi, Kadıköy, İstanbul',
      rating: 4.9,
    ),
  ),
];

const _unavailableAndUnknownSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'unavailable',
    shopId: 'shop-unavailable',
    productId: 'phone-1',
    price: 27999,
    isAvailable: false,
    shop: ShopEntity(
      id: 'shop-unavailable',
      name: 'Rafta Olmayan Mağaza',
      address: 'Kadıköy, İstanbul',
    ),
  ),
  ShopProductEntity(
    id: 'unknown-shop',
    shopId: 'shop-unknown',
    productId: 'phone-1',
    price: 26999,
  ),
];
