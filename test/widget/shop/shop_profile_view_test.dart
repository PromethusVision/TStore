import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

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
    TextScaler? textScaler,
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
        urlLauncher: urlLauncher ?? successfulLauncher,
        currentUserIdProvider: currentUserIdProvider ?? () => 'customer-1',
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

    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pump();
    expect(launchedUris.last.host, 'www.google.com');
    expect(launchedUris.last.queryParameters['query'], '41.001,29.002');
    expect(launchModes.last, LaunchMode.externalApplication);
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

    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pumpAndSettle();
    expect(find.text('Yol tarifi açılamadı'), findsOneWidget);
    expect(find.text('Telefon araması başlatılamadı'), findsNothing);
  });

  testWidgets(
    'giriş yapmayan müşteriyi mesajlaşmadan önce girişe yönlendirir',
    (tester) async {
      final authCubit = MockAuthCubit();
      whenListen(
        authCubit,
        const Stream<AuthState>.empty(),
        initialState: AuthInitial(),
      );
      when(() => authCubit.close()).thenAnswer((_) async {});
      sl.registerFactory<AuthCubit>(() => authCubit);

      await tester.pumpWidget(buildSubject(currentUserIdProvider: () => null));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('shop-profile-message-action')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
    },
  );

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

    expect(
      find.byKey(const Key('shop-profile-message-action')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
