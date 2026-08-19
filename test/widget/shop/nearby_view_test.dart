import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';

class MockNearbyShopsCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockNavigationMenuCubit extends MockCubit<NavigationMenuState>
    implements NavigationMenuCubit {}

class MockChatUnreadCubit extends MockCubit<ChatUnreadState>
    implements ChatUnreadCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockNearbyShopsCubit nearbyShopsCubit;
  late MockCartV2Cubit cartV2Cubit;
  late MockAuthCubit loginAuthCubit;

  const completeShop = ShopEntity(
    id: 'shop-1',
    name: 'Mahalle Kahvecisi',
    description: 'Taze kahve ve yerel ürünler',
    address: 'Fevzi Çakmak Mahallesi, Esenler',
    latitude: 41.042,
    longitude: 28.876,
    phone: '0212 555 44 33',
    openingHours: {'Pazartesi': '09:00 - 18:00'},
    rating: 4.6,
  );

  setUp(() async {
    await sl.reset();

    nearbyShopsCubit = MockNearbyShopsCubit();
    cartV2Cubit = MockCartV2Cubit();
    loginAuthCubit = MockAuthCubit();

    when(() => nearbyShopsCubit.loadShops()).thenAnswer((_) async {});
    when(() => nearbyShopsCubit.useCurrentLocation()).thenAnswer((_) async {});
    when(
      () => nearbyShopsCubit.openAppSettings(),
    ).thenAnswer((_) async => true);
    when(
      () => nearbyShopsCubit.openLocationSettings(),
    ).thenAnswer((_) async => true);
    when(() => nearbyShopsCubit.close()).thenAnswer((_) async {});
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    sl.registerFactory<NearbyShopsCubit>(() => nearbyShopsCubit);
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  void stubNearbyState(NearbyShopsState state) {
    whenListen(
      nearbyShopsCubit,
      const Stream<NearbyShopsState>.empty(),
      initialState: state,
    );
  }

  Widget buildNearbyView({
    TextScaler? textScaler,
    Future<void> Function()? onChangeLocationRequested,
    NearbyCurrentUserIdProvider? currentUserIdProvider,
    NearbyCartDestinationBuilder? cartDestinationBuilder,
    NearbyShopDestinationBuilder? shopDestinationBuilder,
  }) {
    return MaterialApp(
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
      home: BlocProvider<CartV2Cubit>.value(
        value: cartV2Cubit,
        child: NearbyView(
          onChangeLocationRequested: onChangeLocationRequested,
          currentUserIdProvider: currentUserIdProvider ?? () => null,
          cartDestinationBuilder:
              cartDestinationBuilder ??
              (_) => const Scaffold(
                key: Key('nearby-cart-destination'),
                body: SizedBox.shrink(),
              ),
          shopDestinationBuilder: shopDestinationBuilder,
        ),
      ),
    );
  }

  Future<void> pumpNearbyView(
    WidgetTester tester,
    NearbyShopsState state, {
    TextScaler? textScaler,
    Future<void> Function()? onChangeLocationRequested,
    NearbyCurrentUserIdProvider? currentUserIdProvider,
    NearbyCartDestinationBuilder? cartDestinationBuilder,
    NearbyShopDestinationBuilder? shopDestinationBuilder,
  }) async {
    stubNearbyState(state);
    await tester.pumpWidget(
      buildNearbyView(
        textScaler: textScaler,
        onChangeLocationRequested: onChangeLocationRequested,
        currentUserIdProvider: currentUserIdProvider,
        cartDestinationBuilder: cartDestinationBuilder,
        shopDestinationBuilder: shopDestinationBuilder,
      ),
    );
    await tester.pump();
  }

  group('customer navigation', () {
    testWidgets(
      'keeps the five customer labels in order and opens nearby at index 1',
      (tester) async {
        final navigationCubit = MockNavigationMenuCubit();
        final chatUnreadCubit = MockChatUnreadCubit();
        whenListen(
          navigationCubit,
          const Stream<NavigationMenuState>.empty(),
          initialState: NavigationMenuInitial(),
        );
        when(() => navigationCubit.selectedIndex).thenReturn(0);
        when(
          () => navigationCubit.getScreen(),
        ).thenReturn(const SizedBox(key: Key('navigation-body')));
        when(() => navigationCubit.changeIndex(any())).thenAnswer((_) {});
        whenListen(
          chatUnreadCubit,
          const Stream<ChatUnreadState>.empty(),
          initialState: const ChatUnreadLoaded(0),
        );
        when(
          () => chatUnreadCubit.refreshUnreadCountSilently(),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<NavigationMenuCubit>.value(value: navigationCubit),
              BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
            ],
            child: MaterialApp(
              home: NavigationMenu(
                chatUnreadCubit: chatUnreadCubit,
                currentUserIdProvider: () => null,
              ),
            ),
          ),
        );
        await tester.pump();

        const labels = [
          'Ana Sayfa',
          'Yakındakiler',
          'Sepet',
          'Favoriler',
          'Profil',
        ];
        final horizontalPositions = <double>[];
        for (final label in labels) {
          final finder = find.text(label);
          expect(finder, findsOneWidget);
          horizontalPositions.add(tester.getCenter(finder).dx);
        }
        expect(
          horizontalPositions,
          orderedEquals(horizontalPositions.toList()..sort()),
        );
        expect(find.text('Esnaf'), findsNothing);

        await tester.tap(find.byKey(const Key('customer-nav-nearby')));
        await tester.pump();

        verify(() => navigationCubit.changeIndex(1)).called(1);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });

  group('NearbyView', () {
    testWidgets('misafir giristen sonra sepete devam eder', (tester) async {
      String? currentUserId;
      await pumpNearbyView(
        tester,
        const NearbyShopsEmpty(),
        currentUserIdProvider: () => currentUserId,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(CartCounterIcon),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();

      final loginView = tester.widget<LoginView>(find.byType(LoginView));
      expect(loginView.returnToCallerAfterCustomerLogin, isTrue);
      expect(find.byKey(const Key('nearby-cart-destination')), findsNothing);

      currentUserId = 'customer-1';
      Navigator.of(tester.element(find.byType(LoginView))).pop(true);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      expect(find.byKey(const Key('nearby-cart-destination')), findsOneWidget);
    });

    testWidgets('misafir giristen vazgecerse yakindakilerde kalir', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsEmpty(),
        currentUserIdProvider: () => null,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(CartCounterIcon),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(LoginView))).pop(false);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      expect(find.byKey(const Key('nearby-cart-destination')), findsNothing);
      expect(find.byKey(const Key('nearby-customer-content')), findsOneWidget);
    });

    testWidgets('giris yapmis kullanici sepeti dogrudan acar', (tester) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsEmpty(),
        currentUserIdProvider: () => 'customer-1',
      );

      await tester.tap(
        find.descendant(
          of: find.byType(CartCounterIcon),
          matching: find.byType(IconButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      expect(find.byKey(const Key('nearby-cart-destination')), findsOneWidget);
    });

    testWidgets('hizli iki dokunmada tek giris ekrani acar', (tester) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsEmpty(),
        currentUserIdProvider: () => null,
      );

      final cartButton = tester.widget<IconButton>(
        find.descendant(
          of: find.byType(CartCounterIcon),
          matching: find.byType(IconButton),
        ),
      );
      cartButton.onPressed!();
      cartButton.onPressed!();
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);

      Navigator.of(tester.element(find.byType(LoginView))).pop(false);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsNothing);
      expect(find.byKey(const Key('nearby-cart-destination')), findsNothing);
    });

    testWidgets('shows a loading indicator while shops are loading', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoading());

      expect(find.text('Yakındakiler'), findsOneWidget);
      expect(
        find.text('Çevrendeki mağazaları ve ürünleri keşfet.'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CartCounterIcon), findsOneWidget);
      verify(() => nearbyShopsCubit.loadShops()).called(1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows the customer-friendly empty state', (tester) async {
      await pumpNearbyView(tester, const NearbyShopsEmpty());

      expect(find.text('Gösterilebilecek mağaza bulunamadı.'), findsOneWidget);
      expect(
        find.text(
          'Şu anda aktif bir mağaza görünmüyor. Daha sonra tekrar deneyebilirsin.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows a safe error and retries the real shop request', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsError('Database connection details'),
      );

      expect(find.text('Mağazalar yüklenemedi.'), findsOneWidget);
      expect(
        find.text('Lütfen bağlantını kontrol edip tekrar dene.'),
        findsOneWidget,
      );
      expect(find.text('Database connection details'), findsNothing);
      verify(() => nearbyShopsCubit.loadShops()).called(1);

      await tester.tap(find.text('Tekrar Dene'));
      await tester.pump();

      verify(() => nearbyShopsCubit.loadShops()).called(1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('renders the real fields supplied by the shop record', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      expect(find.byKey(const ValueKey('nearby-shop-shop-1')), findsOneWidget);
      expect(find.text('Mahalle Kahvecisi'), findsOneWidget);
      expect(find.text('Taze kahve ve yerel ürünler'), findsOneWidget);
      expect(find.text('Fevzi Çakmak Mahallesi, Esenler'), findsOneWidget);
      expect(find.text('0212 555 44 33'), findsOneWidget);
      expect(find.text('Pazartesi: 09:00 - 18:00'), findsOneWidget);
      expect(find.text('Puan 4.6'), findsOneWidget);
      expect(find.text('Mağazayı Gör'), findsOneWidget);
      expect(find.byType(CartCounterIcon), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('opens the correct active shop profile', (tester) async {
      ShopEntity? openedShop;
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([completeShop]),
        shopDestinationBuilder: (shop) {
          openedShop = shop;
          return const Scaffold(
            body: SizedBox(key: Key('nearby-shop-profile-destination')),
          );
        },
      );

      final openButton = find.byKey(const Key('nearby-shop-open-shop-1'));
      await tester.ensureVisible(openButton);
      await tester.pumpAndSettle();
      await tester.tap(openButton);
      await tester.pumpAndSettle();

      expect(openedShop?.id, 'shop-1');
      expect(openedShop?.name, 'Mahalle Kahvecisi');
      expect(
        find.byKey(const Key('nearby-shop-profile-destination')),
        findsOneWidget,
      );
    });

    testWidgets('does not open inactive or invalid shop profiles', (
      tester,
    ) async {
      var openCount = 0;
      const state = NearbyShopsLoaded([
        ShopEntity(id: 'inactive', name: 'Pasif Mağaza', isActive: false),
        ShopEntity(id: '', name: 'Eksik Mağaza'),
      ]);
      await pumpNearbyView(
        tester,
        state,
        shopDestinationBuilder: (_) {
          openCount++;
          return const Scaffold();
        },
      );

      final inactiveButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('nearby-shop-open-inactive')),
      );
      final invalidButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('nearby-shop-open-')),
      );

      expect(inactiveButton.onPressed, isNull);
      expect(invalidButton.onPressed, isNull);
      expect(openCount, 0);
    });

    testWidgets('rapid double tap opens only one shop profile', (tester) async {
      var openCount = 0;
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([completeShop]),
        shopDestinationBuilder: (_) {
          openCount++;
          return const Scaffold(
            body: SizedBox(key: Key('nearby-shop-profile-destination')),
          );
        },
      );

      final openButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('nearby-shop-open-shop-1')),
      );
      openButton.onPressed!();
      openButton.onPressed!();
      await tester.pumpAndSettle();

      expect(openCount, 1);
      expect(
        find.byKey(const Key('nearby-shop-profile-destination')),
        findsOneWidget,
      );

      Navigator.of(
        tester.element(
          find.byKey(const Key('nearby-shop-profile-destination')),
        ),
      ).pop();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('nearby-shop-profile-destination')),
        findsNothing,
      );
      expect(find.text('Mahalle Kahvecisi'), findsOneWidget);
    });

    testWidgets('uses the customer UI shell and branded content cards', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final content = tester.widget<ConstrainedBox>(
        find.byKey(const Key('nearby-customer-content')),
      );

      expect(scaffold.backgroundColor, CustomerHomeV1Tokens.cream);
      expect(content.constraints.maxWidth, 430);
      expect(find.byKey(const Key('nearby-header')), findsOneWidget);
      expect(find.byKey(const Key('nearby-location-card')), findsOneWidget);
      expect(find.byKey(const ValueKey('nearby-shop-shop-1')), findsOneWidget);
      expect(find.text('1 mağaza'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('does not request location when the nearby tab opens', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      expect(find.text('En yakın mağazaları öne çıkar'), findsOneWidget);
      expect(find.text('Konumunu kullanalım mı?'), findsNothing);
      verifyNever(() => nearbyShopsCubit.useCurrentLocation());

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows a concise explanation before asking for location', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      await tester.tap(find.byKey(const Key('nearby-location-action')));
      await tester.pumpAndSettle();

      expect(find.text('Konumunu kullan'), findsOneWidget);
      expect(
        find.text(
          'Sana en yakın mağazaları gösterebilmemiz için konum izni ver.',
        ),
        findsOneWidget,
      );
      expect(find.text('İzin Ver'), findsOneWidget);
      verifyNever(() => nearbyShopsCubit.useCurrentLocation());

      await tester.tap(find.byKey(const Key('nearby-location-cancel')));
      await tester.pumpAndSettle();

      verifyNever(() => nearbyShopsCubit.useCurrentLocation());
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('rapid double tap opens only one location explanation', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      final locationAction = tester.widget<FilledButton>(
        find.byKey(const Key('nearby-location-action')),
      );
      locationAction.onPressed!();
      locationAction.onPressed!();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('nearby-location-confirm')), findsOneWidget);
      verifyNever(() => nearbyShopsCubit.useCurrentLocation());

      await tester.tap(find.byKey(const Key('nearby-location-cancel')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('nearby-location-confirm')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('requests location only after the user confirms', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      await tester.tap(find.byKey(const Key('nearby-location-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nearby-location-confirm')));
      await tester.pumpAndSettle();

      verify(() => nearbyShopsCubit.useCurrentLocation()).called(1);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('keeps the shop visible while location is being requested', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.requesting),
      );

      expect(find.text('Konumun alınıyor'), findsOneWidget);
      expect(find.byKey(const Key('nearby-location-progress')), findsOneWidget);
      expect(find.text('Mahalle Kahvecisi'), findsOneWidget);
      expect(find.byKey(const Key('nearby-location-action')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows only a real supplied distance after location succeeds', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded(
          [completeShop],
          locationStatus: NearbyLocationStatus.ready,
          distanceMetersByShopId: {'shop-1': 1250},
        ),
      );

      expect(find.text('Yakına göre sıralandı'), findsOneWidget);
      expect(find.text('Yaklaşık 1,3 km'), findsOneWidget);
      expect(find.text('Konum bilgisi mevcut'), findsNothing);
      expect(find.byKey(const Key('nearby-location-action')), findsNothing);
      expect(find.byKey(const Key('nearby-change-location')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ana konumla sıralandığını adıyla açıkça gösterir', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded(
          [completeShop],
          locationStatus: NearbyLocationStatus.ready,
          distanceMetersByShopId: {'shop-1': 1250},
          locationSource: NearbyLocationSource.savedLocation,
          locationLabel: 'Ev',
        ),
      );

      expect(find.text('Ev konumuna göre sıralandı'), findsOneWidget);
      expect(find.textContaining('Ana konumunu mağazaları'), findsOneWidget);
      expect(find.textContaining('mağazalarla paylaşmadık'), findsOneWidget);
      expect(find.byKey(const Key('nearby-location-action')), findsNothing);
      expect(find.text('Konumu Değiştir'), findsOneWidget);
      expect(find.byKey(const Key('nearby-change-location')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'reloads nearby shops after the customer changes the saved location',
      (tester) async {
        var locationChangeCompleted = false;

        await pumpNearbyView(
          tester,
          const NearbyShopsLoaded(
            [completeShop],
            locationStatus: NearbyLocationStatus.ready,
            distanceMetersByShopId: {'shop-1': 1250},
            locationSource: NearbyLocationSource.savedLocation,
            locationLabel: 'Ev',
          ),
          onChangeLocationRequested: () async {
            locationChangeCompleted = true;
          },
        );

        clearInteractions(nearbyShopsCubit);
        when(() => nearbyShopsCubit.loadShops()).thenAnswer((_) async {
          expect(locationChangeCompleted, isTrue);
        });

        await tester.tap(find.byKey(const Key('nearby-change-location')));
        await tester.pumpAndSettle();

        expect(locationChangeCompleted, isTrue);
        verify(() => nearbyShopsCubit.loadShops()).called(1);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('rapid double tap starts one saved location flow', (
      tester,
    ) async {
      final locationChange = Completer<void>();
      var locationChangeCount = 0;
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded(
          [completeShop],
          locationStatus: NearbyLocationStatus.ready,
          distanceMetersByShopId: {'shop-1': 1250},
          locationSource: NearbyLocationSource.savedLocation,
          locationLabel: 'Ev',
        ),
        onChangeLocationRequested: () {
          locationChangeCount++;
          return locationChange.future;
        },
      );
      clearInteractions(nearbyShopsCubit);

      final changeLocationButton = tester.widget<TextButton>(
        find.byKey(const Key('nearby-change-location')),
      );
      changeLocationButton.onPressed!();
      changeLocationButton.onPressed!();
      await tester.pump();

      expect(locationChangeCount, 1);
      verifyNever(() => nearbyShopsCubit.loadShops());

      locationChange.complete();
      await tester.pumpAndSettle();

      verify(() => nearbyShopsCubit.loadShops()).called(1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposed view ignores slow saved location completion', (
      tester,
    ) async {
      final locationChange = Completer<void>();
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded(
          [completeShop],
          locationStatus: NearbyLocationStatus.ready,
          distanceMetersByShopId: {'shop-1': 1250},
          locationSource: NearbyLocationSource.savedLocation,
          locationLabel: 'Ev',
        ),
        onChangeLocationRequested: () => locationChange.future,
      );
      clearInteractions(nearbyShopsCubit);

      await tester.tap(find.byKey(const Key('nearby-change-location')));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());

      locationChange.complete();
      await tester.pump();

      verifyNever(() => nearbyShopsCubit.loadShops());
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not invent a minimum distance for the same location', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded(
          [completeShop],
          locationStatus: NearbyLocationStatus.ready,
          distanceMetersByShopId: {'shop-1': 0},
        ),
      );

      expect(find.text("10 m'den az"), findsOneWidget);
      expect(find.text('Yaklaşık 10 m'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'labels a shop without coordinates instead of guessing distance',
      (tester) async {
        const shopWithoutCoordinates = ShopEntity(
          id: 'shop-without-coordinates',
          name: 'Mahalle Manavı',
          address: 'Esenler, İstanbul',
        );

        await pumpNearbyView(
          tester,
          const NearbyShopsLoaded([
            shopWithoutCoordinates,
          ], locationStatus: NearbyLocationStatus.ready),
        );

        expect(find.text('Konumun alındı'), findsOneWidget);
        expect(find.text('Mesafe bilgisi yok'), findsOneWidget);
        expect(find.textContaining('Yaklaşık '), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('keeps shops available after location permission is denied', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.permissionDenied),
      );

      expect(find.text('Konum izni verilmedi'), findsOneWidget);
      expect(find.text('Mahalle Kahvecisi'), findsOneWidget);
      expect(find.text('Tekrar Kontrol Et'), findsOneWidget);
      expect(
        find.textContaining('Android konum izni ekranını'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('kalıcı izin reddinde uygulama ayarlarını açar', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.permissionDeniedForever),
      );

      expect(find.text('Uygulama Ayarlarını Aç'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nearby-location-action')));
      await tester.pump();

      verify(() => nearbyShopsCubit.openAppSettings()).called(1);
      verifyNever(() => nearbyShopsCubit.openLocationSettings());
    });

    testWidgets('kapalı cihaz servisinde konum ayarlarını açar', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.servicesDisabled),
      );

      expect(find.text('Konum Ayarlarını Aç'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nearby-location-action')));
      await tester.pump();

      verify(() => nearbyShopsCubit.openLocationSettings()).called(1);
      verifyNever(() => nearbyShopsCubit.openAppSettings());
    });

    testWidgets('ayar dönüşünde servis ve izin durumunu yeniden kontrol eder', (
      tester,
    ) async {
      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.servicesDisabled),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      verify(() => nearbyShopsCubit.useCurrentLocation()).called(1);
    });

    testWidgets(
      'uses only available location data and shows no fabricated or merchant content',
      (tester) async {
        const coordinateOnlyShop = ShopEntity(
          id: 'shop-coordinate',
          name: 'Koordinatlı Mağaza',
          latitude: 41.01,
          longitude: 28.98,
        );

        await pumpNearbyView(
          tester,
          const NearbyShopsLoaded([coordinateOnlyShop]),
        );

        expect(find.text('Koordinatlı Mağaza'), findsOneWidget);
        expect(find.text('Konum bilgisi mevcut'), findsOneWidget);
        expect(find.textContaining('Puan '), findsNothing);

        const forbiddenTexts = [
          '500 metre',
          '1,2 km',
          '5 dakika uzaklıkta',
          'Açık',
          'Kapalı',
          'Mağazam',
          'Mağaza oluştur',
          'Mağazayı düzenle',
          'Ürün ekle',
          'Reklam oluştur',
          'Abonelik',
          'Esnaf QR doğrulama',
          'Yönetim paneli',
        ];

        for (final text in forbiddenTexts) {
          expect(
            find.text(text),
            findsNothing,
            reason: 'Unexpected text: $text',
          );
        }

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('does not overflow on narrow or wide customer screens', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      const longShop = ShopEntity(
        id: 'shop-long',
        name: 'Mahallenin Çok Uzun İsimli Yerel Ürünler ve Kahve Mağazası',
        description:
            'Müşterilerin çevresindeki ürünleri keşfetmesini sağlayan uzun mağaza açıklaması.',
        address:
            'Fevzi Çakmak Mahallesi, Çok Uzun Cadde Adı, No: 123, Esenler, İstanbul',
        phone: '0212 555 44 33',
        openingHours: {'Pazartesi - Cumartesi': '09:00 - 18:00'},
        rating: 4.8,
      );

      await pumpNearbyView(tester, const NearbyShopsLoaded([longShop]));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1280, 800);
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('keeps long location guidance scrollable with large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await pumpNearbyView(
        tester,
        const NearbyShopsLoaded([
          completeShop,
        ], locationStatus: NearbyLocationStatus.permissionDenied),
        textScaler: const TextScaler.linear(2),
      );

      expect(find.text('Konum izni verilmedi'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const Key('nearby-shop-list')),
        const Offset(0, -250),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'keeps the saved location shortcut usable on a narrow large-text screen',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 568);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await pumpNearbyView(
          tester,
          const NearbyShopsLoaded(
            [completeShop],
            locationStatus: NearbyLocationStatus.ready,
            distanceMetersByShopId: {'shop-1': 1250},
            locationSource: NearbyLocationSource.savedLocation,
            locationLabel: 'Çok Uzun İsimli Ana Konumum',
          ),
          textScaler: const TextScaler.linear(2),
        );

        expect(find.text('Konumu Değiştir'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(
          find.byKey(const Key('nearby-change-location')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });
}
