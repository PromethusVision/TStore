import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';

class MockNearbyShopsCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockNavigationMenuCubit extends MockCubit<NavigationMenuState>
    implements NavigationMenuCubit {}

void main() {
  late MockNearbyShopsCubit nearbyShopsCubit;
  late MockCartV2Cubit cartV2Cubit;

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

    when(() => nearbyShopsCubit.loadShops()).thenAnswer((_) async {});
    when(() => nearbyShopsCubit.useCurrentLocation()).thenAnswer((_) async {});
    when(() => nearbyShopsCubit.close()).thenAnswer((_) async {});
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );

    sl.registerFactory<NearbyShopsCubit>(() => nearbyShopsCubit);
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

  Widget buildNearbyView({TextScaler? textScaler}) {
    return MaterialApp(
      builder: textScaler == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
      home: BlocProvider<CartV2Cubit>.value(
        value: cartV2Cubit,
        child: const NearbyView(),
      ),
    );
  }

  Future<void> pumpNearbyView(
    WidgetTester tester,
    NearbyShopsState state, {
    TextScaler? textScaler,
  }) async {
    stubNearbyState(state);
    await tester.pumpWidget(buildNearbyView(textScaler: textScaler));
    await tester.pump();
  }

  group('customer navigation', () {
    testWidgets(
      'keeps the four customer labels in order and opens nearby at index 1',
      (tester) async {
        final navigationCubit = MockNavigationMenuCubit();
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

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<NavigationMenuCubit>.value(
              value: navigationCubit,
              child: const NavigationMenu(),
            ),
          ),
        );
        await tester.pump();

        final destinations = tester
            .widgetList<NavigationDestination>(
              find.byType(NavigationDestination),
            )
            .toList();

        expect(
          destinations.map((destination) => destination.label),
          orderedEquals(const [
            'Ana Sayfa',
            'Yakındakiler',
            'Favoriler',
            'Profil',
          ]),
        );
        expect(find.text('Esnaf'), findsNothing);

        await tester.tap(find.text('Yakındakiler'));
        await tester.pump();

        verify(() => navigationCubit.changeIndex(1)).called(1);

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });

  group('NearbyView', () {
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

    testWidgets('does not request location when the nearby tab opens', (
      tester,
    ) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      expect(find.text('En yakın mağazaları öne çıkar'), findsOneWidget);
      expect(find.text('Konumunu kullanalım mı?'), findsNothing);
      verifyNever(() => nearbyShopsCubit.useCurrentLocation());

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('explains privacy before asking for location', (tester) async {
      await pumpNearbyView(tester, const NearbyShopsLoaded([completeShop]));

      await tester.tap(find.byKey(const Key('nearby-location-action')));
      await tester.pumpAndSettle();

      expect(find.text('Konumunu kullanalım mı?'), findsOneWidget);
      expect(
        find.textContaining('konumunu bir kez kullanırız'),
        findsOneWidget,
      );
      expect(find.textContaining('hesabına kaydetmeyiz'), findsOneWidget);
      expect(find.textContaining('arka planda takip etmeyiz'), findsOneWidget);
      verifyNever(() => nearbyShopsCubit.useCurrentLocation());

      await tester.tap(find.byKey(const Key('nearby-location-cancel')));
      await tester.pumpAndSettle();

      verifyNever(() => nearbyShopsCubit.useCurrentLocation());
      await tester.pumpWidget(const SizedBox.shrink());
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

      await tester.pumpWidget(const SizedBox.shrink());
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
      expect(find.textContaining('site ayarlarından konumu'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
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
  });
}
