import 'dart:async';
import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockShopRepository shopRepository;
  late _MockCustomerLocationService locationService;
  late _MockCartV2Cubit cartV2Cubit;

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
    shopRepository = _MockShopRepository();
    locationService = _MockCustomerLocationService();
    cartV2Cubit = _MockCartV2Cubit();

    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_sellers));
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
    when(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(() => locationService);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget subject({TextScaler? textScaler}) {
    return BlocProvider<CartV2Cubit>.value(
      value: cartV2Cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
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
    );
  }

  Widget navigationSubject() {
    return BlocProvider<CartV2Cubit>.value(
      value: cartV2Cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-seller-comparison'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => SellerComparisonView(
                      product: _product,
                      currentUserIdProvider: () => 'customer-1',
                      shopDestinationBuilder: (shop) => Scaffold(
                        body: Center(
                          child: Text('Mağaza ayrıntısı: ${shop.id}'),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Karşılaştırmayı aç'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('390 px local seller comparison renders the visual gate', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('Esnafları karşılaştır'), findsOneWidget);
    expect(find.text('3 esnaf • 28.999,00 TL’den'), findsOneWidget);
    expect(find.text('En uygun fiyat'), findsOneWidget);
    expect(find.byKey(const Key('product-seller-listing-1')), findsOneWidget);
    expect(find.byKey(const Key('product-seller-listing-2')), findsOneWidget);
    expect(find.byKey(const Key('product-seller-listing-3')), findsOneWidget);
    expect(find.textContaining('Kargo'), findsNothing);
    expect(find.textContaining('Ödeme'), findsNothing);
    expect(find.textContaining('Teslimat'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back and Shop Details handoff preserve navigation', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(navigationSubject());
    await tester.tap(find.byKey(const Key('open-seller-comparison')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('product-seller-shop-profile-listing-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mağaza ayrıntısı: shop-1'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('seller-comparison-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-seller-comparison')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cart V2 action keeps the exact listing identifier', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-seller-add-listing-1')));
    await tester.pump();

    verify(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: 'listing-1',
        quantity: 1,
      ),
    ).called(1);
  });

  testWidgets('seller list scrolls and keeps 48 px actions', (tester) async {
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    final shopAction = find.byKey(
      const Key('product-seller-shop-profile-listing-1'),
    );
    final cartAction = find.byKey(const Key('product-seller-add-listing-1'));
    expect(tester.getSize(shopAction).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(cartAction).height, greaterThanOrEqualTo(44));

    await tester.drag(
      find.byKey(const Key('seller-comparison-scroll')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    expect(find.text('Yıldız Mahallesi Teknoloji'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long merchant name and large price remain overflow safe', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_stressSellers));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('1.234.567,89 TL'), findsOneWidget);
    expect(find.textContaining('Kooperatifi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero sellers keep product context without fake commerce', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(<ShopProductEntity>[]));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('seller-comparison-product-context')),
      findsOne,
    );
    expect(find.text('Henüz yerel satıcı yok'), findsOne);
    expect(find.text('Bu ürün için aktif teklif yok'), findsOne);
    expect(find.text('En uygun fiyat'), findsNothing);
    expect(find.text('Mağazayı gör'), findsNothing);
    expect(find.text('Sepete ekle'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one seller uses singular copy and no comparison badge', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_singleSeller));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('1 esnaf • 28.999,00 TL'), findsOne);
    expect(find.text('Yerel esnaf'), findsOne);
    expect(
      find.text('Bu mağazanın fiyatını, puanını ve konumunu incele.'),
      findsOne,
    );
    expect(find.text('En uygun fiyat'), findsNothing);
    expect(find.byKey(const Key('product-seller-sort-button')), findsNothing);
    expect(find.text('Mağazayı gör'), findsOne);
    expect(find.text('Sepete ekle'), findsOne);
  });

  testWidgets('equal lowest prices mark exactly one deterministic offer', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_equalLowestSellers));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('En uygun fiyat'), findsOneWidget);
    final firstCard = find.byKey(const Key('product-seller-equal-1'));
    expect(
      find.descendant(of: firstCard, matching: find.text('En uygun fiyat')),
      findsOneWidget,
    );
  });

  testWidgets('unavailable and unknown listings fail closed', (tester) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_unavailableAndUnknownSellers));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-sellers-empty')), findsOneWidget);
    expect(find.text('Rafta var'), findsNothing);
    expect(find.text('En uygun fiyat'), findsNothing);
    expect(find.text('Sepete ekle'), findsNothing);
  });

  testWidgets('missing rating and distance do not create fake metadata', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_addressOnlySeller));
    when(() => locationService.cachedCoordinates).thenReturn(null);
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('Moda, Kadıköy, İstanbul'), findsOne);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.textContaining('km'), findsNothing);
    expect(find.textContaining('metreden'), findsNothing);
    expect(find.text('Konum bilgisi mevcut'), findsNothing);
    expect(find.text('Adres bilgisi mevcut'), findsNothing);
  });

  testWidgets('supported sort changes only the current deterministic order', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-seller-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('product-seller-sort-most-expensive')),
    );
    await tester.pumpAndSettle();

    expect(find.text('En pahalı'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('product-seller-listing-3'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('product-seller-listing-1'))).dy,
      ),
    );
  });

  testWidgets('loading transitions to the Final UI error and retry state', (
    tester,
  ) async {
    final request = Completer<Either<String, List<ShopProductEntity>>>();
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) => request.future);
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pump();

    expect(find.byKey(const Key('product-sellers-loading')), findsOneWidget);
    expect(find.text('Esnaf teklifleri yükleniyor'), findsOneWidget);

    request.complete(const Left('Bağlantı hatası'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-sellers-error')), findsOneWidget);
    expect(find.byKey(const Key('product-sellers-retry')), findsOneWidget);
    expect(find.text('Esnaf teklifleri yüklenemedi'), findsOneWidget);
  });

  testWidgets('320, 390 and 430 widths preserve the approved hierarchy', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in const [320.0, 390.0, 430.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.text('Esnafları karşılaştır'), findsOneWidget);
      expect(find.text('En uygun fiyat'), findsOneWidget);
      expect(find.text('Mağazayı gör'), findsNWidgets(3));
      expect(find.text('Sepete ekle'), findsNWidgets(3));
      expect(tester.takeException(), isNull, reason: '$width px overflow');
    }
  });

  testWidgets('130 percent text and Turkish content remain accessible', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(subject(textScaler: const TextScaler.linear(1.3)));
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(find.byTooltip('Geri'), findsOneWidget);
    expect(find.byTooltip('Satıcıları sırala: En yakın'), findsOneWidget);
    final shopAction = find.bySemanticsLabel('Çınar Teknoloji mağazasını gör');
    final cartAction = find.bySemanticsLabel(
      'Çınar Teknoloji için fiziksel alışveriş listesine ekle',
    );
    expect(shopAction, findsOneWidget);
    expect(cartAction, findsOneWidget);
    expect(
      tester
          .getSemantics(shopAction)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(cartAction)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('a realistic larger seller set keeps scrolling stable', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => Right(_fifteenSellers));
    await _set390Surface(tester);
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('15 esnaf • 28.999,00 TL’den'), findsOneWidget);
    expect(find.text('En uygun fiyat'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('seller-comparison-scroll')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-seller-listing-15')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('captures the single 390 px product-owner visual gate', (
    tester,
  ) async {
    await _set390Surface(tester);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('w43a-seller-comparison-visual-evidence'),
        child: subject(),
      ),
    );
    await tester.pumpAndSettle();

    final imageContext = tester.element(
      find.byKey(const Key('w43a-seller-comparison-visual-evidence')),
    );
    await tester.runAsync(() async {
      await precacheImage(const AssetImage(_productImage), imageContext);
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byKey(const Key('w43a-seller-comparison-visual-evidence')),
      matchesGoldenFile(
        'goldens/w43a_seller_comparison_visual_prototype_390.png',
      ),
    );
  });
  for (final width in [320.0, 390.0, 430.0]) {
    for (final accept in [false, true]) {
      testWidgets(
        'W45R2 single-shop conflict ${width.toInt()} accept $accept',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final states = StreamController<CartV2State>();
          whenListen(cartV2Cubit, states.stream, initialState: CartV2Initial());
          when(
            () => cartV2Cubit.replaceActiveCartWithShopProduct(
              shopProductId: any(named: 'shopProductId'),
              quantity: any(named: 'quantity'),
            ),
          ).thenAnswer((_) async {});
          await tester.pumpWidget(
            subject(textScaler: const TextScaler.linear(1.3)),
          );
          await tester.pumpAndSettle();
          expect(find.text('Sepete ekle'), findsWidgets);
          states.add(
            const CartV2ShopConflictState(
              CartV2ShopConflict(
                existingCartId: 'fixture-existing-cart',
                existingShopId: 'fixture-existing-shop',
                newShopId: 'shop-1',
                shopProductId: 'listing-1',
                quantity: 3,
              ),
            ),
          );
          await tester.pump();
          await tester.pumpAndSettle();
          expect(
            find.text('Sepetinizde başka bir esnafa ait ürünler var'),
            findsOneWidget,
          );
          expect(find.byType(AlertDialog), findsOneWidget);
          verifyNever(
            () => cartV2Cubit.replaceActiveCartWithShopProduct(
              shopProductId: any(named: 'shopProductId'),
              quantity: any(named: 'quantity'),
            ),
          );
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.text(
              accept ? 'Mevcut mağaza sepetini iptal et ve devam et' : 'Vazgeç',
            ),
          );
          await tester.pumpAndSettle();
          if (accept) {
            verify(
              () => cartV2Cubit.replaceActiveCartWithShopProduct(
                shopProductId: 'listing-1',
                quantity: 3,
              ),
            ).called(1);
          } else {
            verifyNever(
              () => cartV2Cubit.replaceActiveCartWithShopProduct(
                shopProductId: any(named: 'shopProductId'),
                quantity: any(named: 'quantity'),
              ),
            );
          }
          expect(find.byType(AlertDialog), findsNothing);
          await states.close();
        },
      );
    }
  }
}

Future<void> _set390Surface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
      ratingCount: 184,
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
      ratingCount: 96,
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
      ratingCount: 121,
    ),
  ),
];

const _singleSeller = <ShopProductEntity>[
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
      ratingCount: 184,
    ),
  ),
];

const _equalLowestSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'equal-1',
    shopId: 'shop-equal-1',
    productId: 'phone-1',
    price: 28999.90,
    shop: ShopEntity(
      id: 'shop-equal-1',
      name: 'Moda Teknoloji',
      address: 'Kadıköy, İstanbul',
      latitude: 40.9912,
      longitude: 29.0284,
      rating: 4.8,
    ),
  ),
  ShopProductEntity(
    id: 'equal-2',
    shopId: 'shop-equal-2',
    productId: 'phone-1',
    price: 28999.90,
    shop: ShopEntity(
      id: 'shop-equal-2',
      name: 'Semt İletişim',
      address: 'Kadıköy, İstanbul',
      latitude: 40.994,
      longitude: 29.029,
      rating: 4.7,
    ),
  ),
  ShopProductEntity(
    id: 'equal-3',
    shopId: 'shop-equal-3',
    productId: 'phone-1',
    price: 30249.50,
    shop: ShopEntity(
      id: 'shop-equal-3',
      name: 'Çarşı Elektronik',
      address: 'Üsküdar, İstanbul',
      latitude: 41.0258,
      longitude: 29.0159,
      rating: 4.5,
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

const _addressOnlySeller = <ShopProductEntity>[
  ShopProductEntity(
    id: 'address-only',
    shopId: 'shop-address-only',
    productId: 'phone-1',
    price: 30125.75,
    shop: ShopEntity(
      id: 'shop-address-only',
      name: 'ÇĞİÖŞÜ Mahalle Teknoloji',
      address: 'Moda, Kadıköy, İstanbul',
      rating: 0,
    ),
  ),
];

final _fifteenSellers = List<ShopProductEntity>.generate(15, (index) {
  final number = index + 1;
  return ShopProductEntity(
    id: 'listing-$number',
    shopId: 'shop-$number',
    productId: 'phone-1',
    price: 28999 + (index * 125.50),
    shop: ShopEntity(
      id: 'shop-$number',
      name: 'Mahalle Teknoloji $number',
      address: 'İstanbul, Semt $number',
      latitude: 40.9912 + (index * 0.002),
      longitude: 29.0284 + (index * 0.001),
      rating: 4 + ((index % 9) / 10),
    ),
  );
});

const _stressSellers = <ShopProductEntity>[
  ShopProductEntity(
    id: 'listing-stress',
    shopId: 'shop-stress',
    productId: 'phone-1',
    price: 1234567.89,
    shop: ShopEntity(
      id: 'shop-stress',
      name: 'İstanbul Mahalle Esnafı Dayanışma ve Teknoloji Kooperatifi',
      address: 'Caferağa Mahallesi, Kadıköy, İstanbul',
      latitude: 40.9912,
      longitude: 29.0284,
      rating: 4.9,
    ),
  ),
];
