import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MemoryPendingProductChatStorage implements PendingProductChatStorage {
  PendingProductChatIntent? pending;
  int saveCount = 0;
  int clearCount = 0;

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
    pending = intent;
  }
}

void main() {
  late MockShopRepository shopRepository;
  late List<Uri> launchedUris;
  late List<LaunchMode> launchModes;

  const completeShop = ShopEntity(
    id: 'shop-1',
    ownerUserId: 'owner-1',
    name: 'Mahalle Teknoloji Mağazası',
    description: 'Yerel ürünler ve hızlı destek',
    address: 'Esenler, İstanbul',
    latitude: 41.001,
    longitude: 29.002,
    phone: '+90 (555) 111 22 33',
    openingHours: {'Pazartesi': '09:00 - 18:00'},
    rating: 4.8,
  );

  const sampleProduct = ProductEntity(
    id: 'product-1',
    name: 'Kablosuz Kulaklık',
    price: 149.90,
    categoryId: 'electronics',
    stock: 8,
    images: [],
  );

  const sampleShopProduct = ShopProductEntity(
    id: 'shop-product-1',
    shopId: 'shop-1',
    productId: 'product-1',
    price: 129.90,
    product: sampleProduct,
    shop: completeShop,
  );

  setUp(() async {
    await sl.reset();

    shopRepository = MockShopRepository();
    launchedUris = [];
    launchModes = [];

    when(
      () => shopRepository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => const Right([]));
    sl.registerLazySingleton<GetShopProductsByShopUsecase>(
      () => GetShopProductsByShopUsecase(shopRepository),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<bool> successfulLauncher(Uri uri, LaunchMode mode) async {
    launchedUris.add(uri);
    launchModes.add(mode);
    return true;
  }

  Widget buildSubject({
    ShopEntity shop = completeShop,
    ShopProfileUrlLauncher? urlLauncher,
    ShopProfileCurrentUserIdProvider? currentUserIdProvider,
    ShopProfileChatDestinationBuilder? chatDestinationBuilder,
    ShopProfileProductDestinationBuilder? productDestinationBuilder,
    PendingProductChatStorage? pendingProductChatStorage,
    TextScaler? textScaler,
    bool visualPrototype = true,
  }) {
    return MaterialApp(
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
      home: ShopProfileView(
        shop: shop,
        visualPrototype: visualPrototype,
        urlLauncher: urlLauncher ?? successfulLauncher,
        currentUserIdProvider: currentUserIdProvider ?? () => 'customer-1',
        chatDestinationBuilder: chatDestinationBuilder,
        productDestinationBuilder: productDestinationBuilder,
        pendingProductChatStorage: pendingProductChatStorage,
      ),
    );
  }

  testWidgets('geçerli bilgilerde yazma arama ve yol tarifi sunar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('shop-profile-message-action')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('shop-profile-call-action')), findsOneWidget);
    expect(
      find.byKey(const Key('shop-profile-directions-action')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('shop-profile-call-action')));
    await tester.pump();
    expect(launchedUris.single.toString(), 'tel:+905551112233');
    expect(launchModes.single, LaunchMode.platformDefault);

    await tester.ensureVisible(
      find.byKey(const Key('shop-profile-directions-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pump();
    expect(launchedUris.last.host, 'www.google.com');
    expect(launchedUris.last.queryParameters['query'], '41.001,29.002');
    expect(launchModes.last, LaunchMode.externalApplication);
  });

  testWidgets('müşteri UI kabuğunu ve marka kartlarını kullanır', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(visualPrototype: false));
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final content = tester.widget<ConstrainedBox>(
      find.byKey(const Key('shop-profile-customer-content')),
    );

    expect(scaffold.backgroundColor, CustomerHomeV1Tokens.cream);
    expect(content.constraints.maxWidth, 430);
    expect(find.byKey(const Key('shop-profile-header')), findsOneWidget);
    expect(find.byKey(const Key('shop-profile-hero')), findsOneWidget);
    expect(find.byKey(const Key('shop-profile-info-card')), findsOneWidget);
    expect(find.byKey(const Key('shop-profile-actions-card')), findsOneWidget);
    expect(
      find.byKey(const Key('shop-profile-products-empty')),
      findsOneWidget,
    );
  });

  testWidgets('mağazanın gerçek ürün ve fiyatını marka kartında gösterir', (
    tester,
  ) async {
    when(
      () => shopRepository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => const Right([sampleShopProduct]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('shop-profile-product-link-shop-product-1')),
      findsOneWidget,
    );
    expect(find.text('Kablosuz Kulaklık'), findsOneWidget);
    expect(find.text('129,90 TL'), findsOneWidget);
    expect(find.text('Mağazada mevcut'), findsOneWidget);
  });

  testWidgets('mağaza ürününden doğru ürün detayına gider', (tester) async {
    ProductEntity? openedProduct;
    when(
      () => shopRepository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => const Right([sampleShopProduct]));

    await tester.pumpWidget(
      buildSubject(
        productDestinationBuilder: (product) {
          openedProduct = product;
          return const Scaffold(
            body: SizedBox(key: Key('product-details-destination')),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = find.byKey(
      const Key('shop-profile-product-link-shop-product-1'),
    );
    await tester.ensureVisible(productLink);
    await tester.pumpAndSettle();
    await tester.tap(productLink);
    await tester.pumpAndSettle();

    expect(openedProduct?.id, 'product-1');
    expect(openedProduct?.name, 'Kablosuz Kulaklık');
    expect(
      find.byKey(const Key('product-details-destination')),
      findsOneWidget,
    );
  });

  testWidgets('ürün bilgisi eksik mağaza kaydı detay sayfası açmaz', (
    tester,
  ) async {
    var openCount = 0;
    const missingProduct = ShopProductEntity(
      id: 'missing-product',
      shopId: 'shop-1',
      productId: 'product-missing',
      price: 99,
      shop: completeShop,
    );
    when(
      () => shopRepository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => const Right([missingProduct]));

    await tester.pumpWidget(
      buildSubject(
        productDestinationBuilder: (_) {
          openCount++;
          return const Scaffold();
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('shop-profile-product-link-missing-product')),
    );
    expect(productLink.onTap, isNull);
    expect(find.text('Ürün bilgisi yok'), findsOneWidget);
    expect(openCount, 0);
  });

  testWidgets('ürün kartına hızlı çift dokunma yalnız bir detay açar', (
    tester,
  ) async {
    var openCount = 0;
    when(
      () => shopRepository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => const Right([sampleShopProduct]));

    await tester.pumpWidget(
      buildSubject(
        productDestinationBuilder: (_) {
          openCount++;
          return const Scaffold(
            body: SizedBox(key: Key('product-details-destination')),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('shop-profile-product-link-shop-product-1')),
    );
    productLink.onTap!();
    productLink.onTap!();
    await tester.pumpAndSettle();

    expect(openCount, 1);
    expect(
      find.byKey(const Key('product-details-destination')),
      findsOneWidget,
    );

    Navigator.of(
      tester.element(find.byKey(const Key('product-details-destination'))),
    ).pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-details-destination')), findsNothing);
    expect(find.text('Kablosuz Kulaklık'), findsOneWidget);
  });

  testWidgets('geçersiz koordinat yerine mağaza adresini kullanır', (
    tester,
  ) async {
    const shop = ShopEntity(
      id: 'shop-1',
      name: 'Adresli Mağaza',
      address: 'Bağcılar, İstanbul',
      latitude: 100,
      longitude: 29,
    );

    await tester.pumpWidget(buildSubject(shop: shop));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('shop-profile-directions-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pump();

    expect(launchedUris.single.queryParameters['query'], 'Bağcılar, İstanbul');
  });

  testWidgets('kullanılamayan iletişim bilgileri için hatalı eylem göstermez', (
    tester,
  ) async {
    const shop = ShopEntity(
      id: 'shop-1',
      name: 'Eksik Bilgili Mağaza',
      phone: 'telefon bilgisi yok',
      address: '   ',
      latitude: double.nan,
      longitude: 29,
    );

    await tester.pumpWidget(buildSubject(shop: shop));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shop-profile-message-action')), findsNothing);
    expect(find.byKey(const Key('shop-profile-call-action')), findsNothing);
    expect(
      find.byKey(const Key('shop-profile-directions-action')),
      findsNothing,
    );
    expect(launchedUris, isEmpty);
  });

  testWidgets('telefon veya harita açılamazsa anlaşılır uyarı gösterir', (
    tester,
  ) async {
    Future<bool> failingLauncher(Uri uri, LaunchMode mode) async {
      if (uri.scheme == 'tel') return false;
      throw StateError('Harita uygulaması yok');
    }

    await tester.pumpWidget(buildSubject(urlLauncher: failingLauncher));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shop-profile-call-action')));
    await tester.pumpAndSettle();
    expect(find.text('Telefon araması başlatılamadı'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('shop-profile-directions-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pumpAndSettle();
    expect(find.text('Yol tarifi açılamadı'), findsOneWidget);
    expect(find.text('Telefon araması başlatılamadı'), findsNothing);
  });

  testWidgets(
    'giriş yapmayan müşteriyi mesajlaşmadan önce girişe yönlendirir',
    (tester) async {
      final pendingChatStorage = MemoryPendingProductChatStorage();
      final authCubit = MockAuthCubit();
      whenListen(
        authCubit,
        const Stream<AuthState>.empty(),
        initialState: AuthInitial(),
      );
      when(() => authCubit.close()).thenAnswer((_) async {});
      sl.registerFactory<AuthCubit>(() => authCubit);

      await tester.pumpWidget(
        buildSubject(
          currentUserIdProvider: () => null,
          pendingProductChatStorage: pendingChatStorage,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('shop-profile-message-action')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(
        tester
            .widget<LoginView>(find.byType(LoginView))
            .returnToCallerAfterCustomerLogin,
        isTrue,
      );
      expect(pendingChatStorage.pending?.receiverId, 'owner-1');
      expect(
        pendingChatStorage.pending?.receiverName,
        'Mahalle Teknoloji Mağazası',
      );
      expect(pendingChatStorage.pending?.initialDraft, isEmpty);
    },
  );

  testWidgets('giriş sonrası doğru mağazanın boş sohbet ekranına devam eder', (
    tester,
  ) async {
    final pendingChatStorage = MemoryPendingProductChatStorage();
    final authCubit = MockAuthCubit();
    var currentUserId = '';
    String? openedReceiverId;
    String? openedReceiverName;

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);

    await tester.pumpWidget(
      buildSubject(
        currentUserIdProvider: () =>
            currentUserId.isEmpty ? null : currentUserId,
        pendingProductChatStorage: pendingChatStorage,
        chatDestinationBuilder: (receiverId, receiverName) {
          openedReceiverId = receiverId;
          openedReceiverName = receiverName;
          return const Scaffold(body: Text('Boş sohbet ekranı'));
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shop-profile-message-action')));
    await tester.pumpAndSettle();

    currentUserId = 'customer-1';
    Navigator.of(tester.element(find.byType(LoginView))).pop(true);
    await tester.pumpAndSettle();

    expect(find.text('Boş sohbet ekranı'), findsOneWidget);
    expect(openedReceiverId, 'owner-1');
    expect(openedReceiverName, 'Mahalle Teknoloji Mağazası');
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.clearCount, 1);
    expect(pendingChatStorage.pending, isNull);
  });

  testWidgets('girişten vazgeçilirse bekleyen mağaza sohbetini temizler', (
    tester,
  ) async {
    final pendingChatStorage = MemoryPendingProductChatStorage();
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);

    await tester.pumpWidget(
      buildSubject(
        currentUserIdProvider: () => null,
        pendingProductChatStorage: pendingChatStorage,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shop-profile-message-action')));
    await tester.pumpAndSettle();

    Navigator.of(tester.element(find.byType(LoginView))).pop(false);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsNothing);
    expect(pendingChatStorage.saveCount, 1);
    expect(pendingChatStorage.clearCount, 1);
    expect(pendingChatStorage.pending, isNull);
  });

  testWidgets('mağaza sahibine kendi mağazasına mesaj butonu göstermez', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(currentUserIdProvider: () => 'owner-1'),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shop-profile-message-action')), findsNothing);
    expect(find.byKey(const Key('shop-profile-call-action')), findsOneWidget);
    expect(
      find.byKey(const Key('shop-profile-directions-action')),
      findsOneWidget,
    );
  });

  testWidgets('dar ekranda ve büyük yazıda müşteri eylemleri taşmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('shop-profile-message-action')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('shop-profile-message-action')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
