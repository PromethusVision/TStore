import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MemoryPendingProductChatStorage implements PendingProductChatStorage {
  PendingProductChatIntent? pending;
  int saveCount = 0;
  int clearCount = 0;
  bool throwOnSave = false;

  @override
  Future<void> clear() async {
    clearCount++;
    pending = null;
  }

  @override
  Future<PendingProductChatIntent?> getPending() async => pending;

  @override
  Future<void> save(PendingProductChatIntent intent) async {
    saveCount++;
    if (throwOnSave) {
      throw StateError('Yerel kayıt kullanılamıyor');
    }
    pending = intent;
  }
}

void main() {
  late MockShopRepository shopRepository;
  late MockCustomerLocationService customerLocationService;
  late MockCartV2Cubit cartV2Cubit;
  late MemoryPendingProductChatStorage pendingChatStorage;
  CustomerCoordinates? cachedCoordinates;

  ShopProductEntity seller({
    required String id,
    required String name,
    double? latitude,
    double? longitude,
    String? address,
    double price = 99,
    double rating = 0,
    bool shopIsActive = true,
    String? ownerUserId = 'owner-1',
  }) {
    return ShopProductEntity(
      id: id,
      shopId: 'shop-$id',
      productId: 'product-1',
      price: price,
      shop: ShopEntity(
        id: 'shop-$id',
        ownerUserId: ownerUserId,
        name: name,
        latitude: latitude,
        longitude: longitude,
        address: address,
        rating: rating,
        isActive: shopIsActive,
      ),
    );
  }

  setUp(() async {
    await sl.reset();

    shopRepository = MockShopRepository();
    customerLocationService = MockCustomerLocationService();
    cartV2Cubit = MockCartV2Cubit();
    pendingChatStorage = MemoryPendingProductChatStorage();
    cachedCoordinates = null;

    when(
      () => customerLocationService.cachedCoordinates,
    ).thenAnswer((_) => cachedCoordinates);
    when(
      () => customerLocationService.getPreferredLocation(),
    ).thenAnswer((_) async => null);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {});
    when(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(
      () => customerLocationService,
    );
    sl.registerLazySingleton<PendingProductChatStorage>(
      () => pendingChatStorage,
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    TextScaler? textScaler,
    Future<void> Function()? onChangeLocationRequested,
    VoidCallback? onBrowseOtherProducts,
    ProductSellerPriceSummaryChanged? onPriceSummaryChanged,
    ProductSellerCurrentUserIdProvider? currentUserIdProvider,
    ProductSellerChatDestinationBuilder? chatDestinationBuilder,
  }) {
    return BlocProvider<CartV2Cubit>.value(
      value: cartV2Cubit,
      child: MaterialApp(
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductSellersSection(
              productId: 'product-1',
              productName: 'Deneme Ürünü',
              onChangeLocationRequested: onChangeLocationRequested,
              onBrowseOtherProducts: onBrowseOtherProducts,
              onPriceSummaryChanged: onPriceSummaryChanged,
              currentUserIdProvider:
                  currentUserIdProvider ?? () => 'customer-1',
              chatDestinationBuilder: chatDestinationBuilder,
            ),
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

  Future<void> selectSort(WidgetTester tester, String optionKey) async {
    await tester.tap(find.byKey(const Key('product-seller-sort-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(optionKey)));
    await tester.pumpAndSettle();
  }

  testWidgets('ana konumla satıcıları izin istemeden yakından uzağa sıralar', (
    tester,
  ) async {
    const preferredLocation = CustomerPreferredLocation(
      name: 'Ev',
      coordinates: CustomerCoordinates(latitude: 41, longitude: 29),
    );
    when(
      () => customerLocationService.getPreferredLocation(),
    ).thenAnswer((_) async => preferredLocation);
    final sellers = [
      seller(id: 'far', name: 'Uzak Esnaf', latitude: 41.02, longitude: 29),
      seller(id: 'near', name: 'Yakın Esnaf', latitude: 41.001, longitude: 29),
    ];
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => Right(sellers));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      displayedSellerIds(tester),
      orderedEquals(const ['product-seller-near', 'product-seller-far']),
    );
    expect(
      find.text('Ev konumuna göre mesafeler gösteriliyor'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('product-seller-sort-button')),
        matching: find.text('En yakın'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('product-seller-change-location')),
      findsOneWidget,
    );
    verify(() => customerLocationService.getPreferredLocation()).called(1);
    verifyNever(() => customerLocationService.getCurrentLocation());
  });

  testWidgets(
    'konum değişikliğinden dönünce etiketi ve satıcı sırasını yeniler',
    (tester) async {
      const home = CustomerPreferredLocation(
        name: 'Ev',
        coordinates: CustomerCoordinates(latitude: 41, longitude: 29),
      );
      const work = CustomerPreferredLocation(
        name: 'İş',
        coordinates: CustomerCoordinates(latitude: 41.02, longitude: 29),
      );
      CustomerPreferredLocation? activeLocation = home;
      var changeCount = 0;
      when(
        () => customerLocationService.getPreferredLocation(),
      ).thenAnswer((_) async => activeLocation);
      final sellers = [
        seller(
          id: 'home',
          name: 'Eve Yakın Esnaf',
          latitude: 41.001,
          longitude: 29,
        ),
        seller(
          id: 'work',
          name: 'İşe Yakın Esnaf',
          latitude: 41.019,
          longitude: 29,
        ),
      ];
      when(
        () => shopRepository.getShopProductsByProduct('product-1'),
      ).thenAnswer((_) async => Right(sellers));

      await tester.pumpWidget(
        buildSubject(
          onChangeLocationRequested: () async {
            changeCount++;
            activeLocation = changeCount == 1 ? work : null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        displayedSellerIds(tester),
        orderedEquals(const ['product-seller-home', 'product-seller-work']),
      );
      expect(
        find.text('Ev konumuna göre mesafeler gösteriliyor'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('product-seller-change-location')));
      await tester.pumpAndSettle();

      expect(
        displayedSellerIds(tester),
        orderedEquals(const ['product-seller-work', 'product-seller-home']),
      );
      expect(
        find.text('İş konumuna göre mesafeler gösteriliyor'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('product-seller-change-location')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('product-seller-change-location')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('product-seller-sort-button')),
          matching: find.text('Sırala'),
        ),
        findsOneWidget,
      );
      verify(() => customerLocationService.getPreferredLocation()).called(3);
      verifyNever(() => customerLocationService.getCurrentLocation());
    },
  );

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
    expect(
      find.descendant(
        of: find.byKey(const Key('product-seller-sort-button')),
        matching: find.text('En yakın'),
      ),
      findsOneWidget,
    );
    verifyNever(() => customerLocationService.getCurrentLocation());
  });

  testWidgets('sıralama menüsünü sektör standardı seçeneklerle açar', (
    tester,
  ) async {
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'one', name: 'Birinci Esnaf')]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('product-seller-sort-button')),
        matching: find.text('Sırala'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('product-seller-sort-button')));
    await tester.pumpAndSettle();

    expect(find.text('Fiyata göre en ucuz'), findsOneWidget);
    expect(find.text('Fiyata göre en pahalı'), findsOneWidget);
    expect(find.text('En yüksek puan'), findsOneWidget);
    expect(find.text('En yakın'), findsOneWidget);
    expect(find.text('Konum gerekli'), findsOneWidget);
    expect(
      tester
          .widget<MenuItemButton>(
            find.byKey(const Key('product-seller-sort-nearest')),
          )
          .onPressed,
      isNull,
    );
    verifyNever(() => customerLocationService.getCurrentLocation());
  });

  testWidgets('fiyat ve puan seçenekleri satıcıları kararlı biçimde sıralar', (
    tester,
  ) async {
    final sellers = [
      seller(id: 'middle', name: 'Orta Fiyat', price: 20, rating: 4.5),
      seller(id: 'cheap', name: 'En Ucuz', price: 10, rating: 4),
      seller(id: 'top', name: 'Yüksek Puan', price: 20, rating: 4.9),
    ];
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => Right(sellers));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await selectSort(tester, 'product-seller-sort-cheapest');
    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-cheap',
        'product-seller-middle',
        'product-seller-top',
      ]),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('product-seller-sort-button')),
        matching: find.text('En ucuz'),
      ),
      findsOneWidget,
    );

    await selectSort(tester, 'product-seller-sort-most-expensive');
    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-middle',
        'product-seller-top',
        'product-seller-cheap',
      ]),
    );

    await selectSort(tester, 'product-seller-sort-highest-rated');
    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-top',
        'product-seller-middle',
        'product-seller-cheap',
      ]),
    );
  });

  testWidgets(
    'yalnız satın alınabilir mağazaların gerçek fiyat aralığını iletir',
    (tester) async {
      final summaries = <ProductSellerPriceSummary>[];
      when(
        () => shopRepository.getShopProductsByProduct('product-1'),
      ).thenAnswer(
        (_) async => Right([
          seller(id: 'expensive', name: 'Pahalı Mağaza', price: 1399.99),
          seller(id: 'cheap', name: 'Uygun Mağaza', price: 1299.99),
          seller(
            id: 'inactive',
            name: 'Pasif Mağaza',
            price: 999.99,
            shopIsActive: false,
          ),
        ]),
      );

      await tester.pumpWidget(
        buildSubject(onPriceSummaryChanged: summaries.add),
      );
      await tester.pumpAndSettle();

      expect(summaries, isNotEmpty);
      expect(
        summaries.last,
        const ProductSellerPriceSummary.available(
          minimumPrice: 1299.99,
          maximumPrice: 1399.99,
        ),
      );
    },
  );

  testWidgets('konum hazırken başka sıralamadan en yakına döner', (
    tester,
  ) async {
    cachedCoordinates = const CustomerCoordinates(latitude: 41, longitude: 29);
    final sellers = [
      seller(
        id: 'near-expensive',
        name: 'Yakın Esnaf',
        latitude: 41.001,
        longitude: 29,
        price: 100,
      ),
      seller(
        id: 'far-cheap',
        name: 'Uzak Esnaf',
        latitude: 41.02,
        longitude: 29,
        price: 50,
      ),
    ];
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => Right(sellers));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await selectSort(tester, 'product-seller-sort-cheapest');
    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-far-cheap',
        'product-seller-near-expensive',
      ]),
    );

    await selectSort(tester, 'product-seller-sort-nearest');
    expect(
      displayedSellerIds(tester),
      orderedEquals(const [
        'product-seller-near-expensive',
        'product-seller-far-cheap',
      ]),
    );
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
    var browseRequestCount = 0;
    when(
      () => shopRepository.getShopProductsByProduct('product-1'),
    ).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      buildSubject(onBrowseOtherProducts: () => browseRequestCount++),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Bu ürün şu anda aktif mağazalarda bulunamadı'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('product-sellers-empty')), findsOneWidget);
    expect(
      find.byKey(const Key('product-sellers-browse-products')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('product-sellers-browse-products')));
    expect(browseRequestCount, 1);

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
      find.text('Satıcı bilgileri yüklenemedi. Lütfen tekrar deneyin.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('product-sellers-retry')), findsOneWidget);
  });

  testWidgets('eksik veya pasif mağazaları müşteriye satıcı olarak göstermez', (
    tester,
  ) async {
    final missingShop = ShopProductEntity(
      id: 'missing-shop',
      shopId: 'shop-missing',
      productId: 'product-1',
      price: 79,
    );
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([
        seller(id: 'active', name: 'Aktif Esnaf'),
        seller(id: 'inactive', name: 'Pasif Esnaf', shopIsActive: false),
        missingShop,
      ]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      displayedSellerIds(tester),
      orderedEquals(const ['product-seller-active']),
    );
    expect(find.text('Aktif Esnaf'), findsOneWidget);
    expect(find.text('Pasif Esnaf'), findsNothing);
    expect(find.text('Bilinmeyen esnaf'), findsNothing);
    expect(find.text('Bu Esnaftan Sepete Ekle'), findsOneWidget);
  });

  testWidgets(
    'sepet ekleme sürerken geri bildirim gösterir ve tekrar dokunmayı engeller',
    (tester) async {
      final addRequest = Completer<void>();
      when(
        () => cartV2Cubit.addShopProductToCart(
          shopProductId: 'active',
          quantity: 1,
        ),
      ).thenAnswer((_) => addRequest.future);
      when(
        () => shopRepository.getShopProductsByProduct('product-1'),
      ).thenAnswer(
        (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final addButton = find.byKey(const ValueKey('product-seller-add-active'));
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('Sepete ekleniyor…'), findsOneWidget);
      expect(
        find.byKey(const Key('product-seller-add-progress')),
        findsOneWidget,
      );
      expect(tester.widget<OutlinedButton>(addButton).onPressed, isNull);
      verify(
        () => cartV2Cubit.addShopProductToCart(
          shopProductId: 'active',
          quantity: 1,
        ),
      ).called(1);

      addRequest.complete();
      await tester.pumpAndSettle();

      expect(find.text('Bu Esnaftan Sepete Ekle'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(addButton).onPressed, isNotNull);
    },
  );

  testWidgets('giriş yapmayan müşteriyi sepetten önce girişe yönlendirir', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(buildSubject(currentUserIdProvider: () => null));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('product-seller-add-active')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(
      tester
          .widget<LoginView>(find.byType(LoginView))
          .returnToCallerAfterCustomerLogin,
      isTrue,
    );
    expect(find.text('Sepete ekleniyor…'), findsNothing);
    verifyNever(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(
      find.byKey(const ValueKey('product-seller-add-active')),
      findsOneWidget,
    );
    verifyNever(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    );
  });

  testWidgets(
    'başarılı girişten sonra seçilen satıcının ürününü sepete ekler',
    (tester) async {
      final authCubit = MockAuthCubit();
      final authStates = StreamController<AuthState>();
      addTearDown(authStates.close);
      var currentUserId = '';

      whenListen(authCubit, authStates.stream, initialState: AuthInitial());
      when(() => authCubit.close()).thenAnswer((_) async {});
      sl.registerFactory<AuthCubit>(() => authCubit);
      when(
        () => shopRepository.getShopProductsByProduct('product-1'),
      ).thenAnswer(
        (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
      );

      await tester.pumpWidget(
        buildSubject(
          currentUserIdProvider: () =>
              currentUserId.isEmpty ? null : currentUserId,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('product-seller-add-active')));
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);

      currentUserId = 'customer-1';
      authStates.add(
        const AuthAuthenticated(
          UserEntity(id: 'customer-1', email: 'customer@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      verify(
        () => cartV2Cubit.addShopProductToCart(
          shopProductId: 'active',
          quantity: 1,
        ),
      ).called(1);
      expect(find.text('Sepete ekleniyor…'), findsNothing);
      expect(
        find.byKey(const ValueKey('product-seller-add-active')),
        findsOneWidget,
      );
    },
  );

  testWidgets('satıcıya ürün adıyla düzenlenebilir mesaj taslağı açar', (
    tester,
  ) async {
    String? receiverId;
    String? receiverName;
    String? initialDraft;
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(
      buildSubject(
        chatDestinationBuilder: (id, name, draft) {
          receiverId = id;
          receiverName = name;
          initialDraft = draft;
          return const Scaffold(body: Text('Mesaj ekranı'));
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-seller-message-active')));
    await tester.pumpAndSettle();

    expect(find.text('Mesaj ekranı'), findsOneWidget);
    expect(receiverId, 'owner-1');
    expect(receiverName, 'Mahalle Marketi');
    expect(initialDraft, 'Merhaba, "Deneme Ürünü" mağazanızda mevcut mu?');
  });

  testWidgets('giriş yapmayan müşteriyi mesajdan önce girişe yönlendirir', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(buildSubject(currentUserIdProvider: () => null));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-seller-message-active')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(
      tester
          .widget<LoginView>(find.byType(LoginView))
          .returnToCallerAfterCustomerLogin,
      isTrue,
    );
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.pending?.receiverId, 'owner-1');
    expect(pendingChatStorage.pending?.receiverName, 'Mahalle Marketi');
    expect(
      pendingChatStorage.pending?.initialDraft,
      'Merhaba, "Deneme Ürünü" mağazanızda mevcut mu?',
    );
  });

  testWidgets(
    'giriş sonrası aynı satıcının mesajına taslağı koruyarak devam eder',
    (tester) async {
      final authCubit = MockAuthCubit();
      final authStates = StreamController<AuthState>();
      addTearDown(authStates.close);
      var currentUserId = '';
      String? receiverId;
      String? initialDraft;

      whenListen(authCubit, authStates.stream, initialState: AuthInitial());
      when(() => authCubit.close()).thenAnswer((_) async {});
      sl.registerFactory<AuthCubit>(() => authCubit);
      when(
        () => shopRepository.getShopProductsByProduct('product-1'),
      ).thenAnswer(
        (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
      );

      await tester.pumpWidget(
        buildSubject(
          currentUserIdProvider: () =>
              currentUserId.isEmpty ? null : currentUserId,
          chatDestinationBuilder: (id, name, draft) {
            receiverId = id;
            initialDraft = draft;
            return const Scaffold(body: Text('Mesaj ekranı'));
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('product-seller-message-active')));
      await tester.pumpAndSettle();

      currentUserId = 'customer-1';
      authStates.add(
        const AuthAuthenticated(
          UserEntity(id: 'customer-1', email: 'customer@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mesaj ekranı'), findsOneWidget);
      expect(receiverId, 'owner-1');
      expect(initialDraft, 'Merhaba, "Deneme Ürünü" mağazanızda mevcut mu?');
      expect(pendingChatStorage.saveCount, 1);
      expect(pendingChatStorage.clearCount, 1);
      expect(pendingChatStorage.pending, isNull);
      verify(() => cartV2Cubit.getActiveCartItems()).called(1);
    },
  );

  testWidgets('girişten vazgeçilirse ürün ekranında kalır', (tester) async {
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(
      buildSubject(
        currentUserIdProvider: () => null,
        chatDestinationBuilder: (_, _, _) =>
            const Scaffold(body: Text('Mesaj ekranı')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-seller-message-active')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(find.text('Mesaj ekranı'), findsNothing);
    expect(
      find.byKey(const Key('product-seller-message-active')),
      findsOneWidget,
    );
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.clearCount, 1);
    expect(pendingChatStorage.pending, isNull);
  });

  testWidgets('girişte mağaza sahibi hesabı seçilirse kendi mesajını açmaz', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    final authStates = StreamController<AuthState>();
    addTearDown(authStates.close);
    var currentUserId = '';

    whenListen(authCubit, authStates.stream, initialState: AuthInitial());
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(
      buildSubject(
        currentUserIdProvider: () =>
            currentUserId.isEmpty ? null : currentUserId,
        chatDestinationBuilder: (_, _, _) =>
            const Scaffold(body: Text('Mesaj ekranı')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-seller-message-active')));
    await tester.pumpAndSettle();

    currentUserId = 'owner-1';
    authStates.add(
      const AuthAuthenticated(
        UserEntity(
          id: 'owner-1',
          email: 'owner@example.com',
          role: UserEntity.merchantRole,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mesaj ekranı'), findsNothing);
    expect(
      find.text('Bu mağazaya kendi hesabınızla mesaj gönderemezsiniz.'),
      findsOneWidget,
    );
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.clearCount, 1);
    expect(pendingChatStorage.pending, isNull);
  });

  testWidgets('yerel kayıt başarısız olsa da giriş ekranını açar', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
    pendingChatStorage.throwOnSave = true;
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(buildSubject(currentUserIdProvider: () => null));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-seller-message-active')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.pending, isNull);
  });

  testWidgets('mağaza sahibine kendi mağazasına mesaj butonu göstermez', (
    tester,
  ) async {
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([seller(id: 'active', name: 'Mahalle Marketi')]),
    );

    await tester.pumpWidget(
      buildSubject(currentUserIdProvider: () => 'owner-1'),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('product-seller-message-active')),
      findsNothing,
    );
    expect(find.text('Bu Esnaftan Sepete Ekle'), findsOneWidget);
  });

  testWidgets('tüm satıcı kayıtları geçersizse güvenli boş durumu gösterir', (
    tester,
  ) async {
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) async => Right([
        seller(id: 'inactive', name: 'Pasif Esnaf', shopIsActive: false),
        const ShopProductEntity(
          id: 'missing-shop',
          shopId: 'shop-missing',
          productId: 'product-1',
          price: 79,
        ),
      ]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.text('Bu ürün şu anda aktif mağazalarda bulunamadı'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('product-seller-sort-button')), findsNothing);
    expect(find.text('Bu Esnaftan Sepete Ekle'), findsNothing);
  });

  testWidgets('hata sonrası tekrar deneyince satıcıları yükler', (
    tester,
  ) async {
    var requestCount = 0;
    final retryResult = Completer<Either<String, List<ShopProductEntity>>>();
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) {
        requestCount++;
        if (requestCount == 1) {
          return Future.value(const Left('Bağlantı hatası'));
        }
        return retryResult.future;
      },
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.text('Satıcı bilgileri yüklenemedi. Lütfen tekrar deneyin.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('product-sellers-retry')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    retryResult.complete(
      Right([
        seller(
          id: 'recovered',
          name: 'Yeniden Yüklenen Esnaf',
          latitude: 41.001,
          longitude: 29,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product-seller-recovered')),
      findsOneWidget,
    );
    expect(find.text('Yeniden Yüklenen Esnaf'), findsOneWidget);
    expect(requestCount, 2);
  });

  testWidgets('hızlı tekrar dokunma ikinci bir satıcı sorgusu başlatmaz', (
    tester,
  ) async {
    var requestCount = 0;
    final retryResult = Completer<Either<String, List<ShopProductEntity>>>();
    when(() => shopRepository.getShopProductsByProduct('product-1')).thenAnswer(
      (_) {
        requestCount++;
        if (requestCount == 1) {
          return Future.value(const Left('Bağlantı hatası'));
        }
        return retryResult.future;
      },
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final retryButton = find.byKey(const Key('product-sellers-retry'));
    await tester.tap(retryButton);
    await tester.tap(retryButton);
    await tester.pump();

    expect(requestCount, 2);

    retryResult.complete(const Right([]));
    await tester.pumpAndSettle();
    expect(
      find.text('Bu ürün şu anda aktif mağazalarda bulunamadı'),
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
    when(() => customerLocationService.getPreferredLocation()).thenAnswer(
      (_) async => const CustomerPreferredLocation(
        name: 'Çok Uzun Kayıtlı Ana Konum Adı',
        coordinates: CustomerCoordinates(latitude: 41, longitude: 29),
      ),
    );

    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('product-seller-long')), findsOneWidget);
    expect(
      find.byKey(const Key('product-seller-change-location')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
