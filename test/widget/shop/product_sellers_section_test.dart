import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

void main() {
  late MockShopRepository shopRepository;
  late MockCustomerLocationService customerLocationService;
  late MockCartV2Cubit cartV2Cubit;
  CustomerCoordinates? cachedCoordinates;

  ShopProductEntity seller({
    required String id,
    required String name,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return ShopProductEntity(
      id: id,
      shopId: 'shop-$id',
      productId: 'product-1',
      price: 99,
      shop: ShopEntity(
        id: 'shop-$id',
        name: name,
        latitude: latitude,
        longitude: longitude,
        address: address,
      ),
    );
  }

  setUp(() async {
    await sl.reset();

    shopRepository = MockShopRepository();
    customerLocationService = MockCustomerLocationService();
    cartV2Cubit = MockCartV2Cubit();
    cachedCoordinates = null;

    when(
      () => customerLocationService.cachedCoordinates,
    ).thenAnswer((_) => cachedCoordinates);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(
      () => customerLocationService,
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({TextScaler? textScaler}) {
    return MaterialApp(
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const ProductSellersSection(productId: 'product-1'),
          ),
        ),
      ),
    );
  }

  List<String> displayedSellerIds(WidgetTester tester) {
    return tester
        .widgetList<Card>(find.byType(Card))
        .map((card) => card.key)
        .whereType<ValueKey<String>>()
        .map((key) => key.value)
        .where((value) => value.startsWith('product-seller-'))
        .toList(growable: false);
  }

  testWidgets('konum yokken satıcı sırasını ve mevcut ipuçlarını korur', (
    tester,
  ) async {
    final sellers = [
      seller(id: 'far', name: 'Uzak Esnaf', latitude: 41.02, longitude: 29),
      seller(id: 'near', name: 'Yakın Esnaf', latitude: 41.001, longitude: 29),
      seller(id: 'address', name: 'Adresli Esnaf', address: 'Esenler'),
    ];
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => Right(sellers));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-far',
        'product-seller-near',
        'product-seller-address',
      ]),
    );
    expect(find.text('Konum bilgisi mevcut'), findsNWidgets(2));
    expect(find.text('Adres bilgisi mevcut'), findsOneWidget);
    expect(find.textContaining('Yaklaşık'), findsNothing);
    verifyNever(() => customerLocationService.getCurrentLocation());
  });

  testWidgets('hazır konumla satıcıları yakından uzağa sıralar', (
    tester,
  ) async {
    cachedCoordinates = const CustomerCoordinates(latitude: 41, longitude: 29);
    final sellers = [
      seller(id: 'missing', name: 'Konumsuz Esnaf', address: 'Bağcılar'),
      seller(id: 'far', name: 'Uzak Esnaf', latitude: 41.01, longitude: 29),
      seller(
        id: 'invalid',
        name: 'Geçersiz Konum',
        latitude: 100,
        longitude: 29,
      ),
      seller(id: 'near', name: 'Yakın Esnaf', latitude: 41.001, longitude: 29),
    ];
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => Right(sellers));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-near',
        'product-seller-far',
        'product-seller-missing',
        'product-seller-invalid',
      ]),
    );
    expect(find.text('Yaklaşık 110 m'), findsOneWidget);
    expect(find.text('Yaklaşık 1,1 km'), findsOneWidget);
    expect(find.text('Mesafe bilgisi yok'), findsNWidgets(2));
    verifyNever(() => customerLocationService.getCurrentLocation());
  });

  testWidgets('satıcılar yüklenirken hazır olan oturum konumunu kullanır', (
    tester,
  ) async {
    final result = Completer<Either<String, List<ShopProductEntity>>>();
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) => result.future);

    await tester.pumpWidget(buildSubject());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    cachedCoordinates = const CustomerCoordinates(latitude: 41, longitude: 29);
    result.complete(
      Right([
        seller(id: 'far', name: 'Uzak Esnaf', latitude: 41.01, longitude: 29),
        seller(
          id: 'near',
          name: 'Yakın Esnaf',
          latitude: 41.001,
          longitude: 29,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      displayedSellerIds(tester),
      orderedEquals(const ['product-seller-near', 'product-seller-far']),
    );
  });

  testWidgets('boş ve hatalı satıcı sonuçlarını güvenli biçimde gösterir', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(
      find.text('Bu ürünü satan esnaf henüz listelenmiyor.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await sl.reset();
    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(
      () => customerLocationService,
    );
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => const Left('Bağlantı hatası'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Satıcı bilgileri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('dar ekranda ve büyük yazıda taşma yapmaz', (tester) async {
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([
        seller(
          id: 'long',
          name: 'Çok Uzun İsimli Mahalle Esnafı ve Yerel Ürünler Mağazası',
          latitude: 41.001,
          longitude: 29,
          address: 'Çok uzun bir mahalle ve cadde adresi, İstanbul',
        ),
      ]),
    );
    cachedCoordinates = const CustomerCoordinates(latitude: 41, longitude: 29);

    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('product-seller-long')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
