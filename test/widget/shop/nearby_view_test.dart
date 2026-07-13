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

  Widget buildNearbyView() {
    return MaterialApp(
      home: BlocProvider<CartV2Cubit>.value(
        value: cartV2Cubit,
        child: const NearbyView(),
      ),
    );
  }

  Future<void> pumpNearbyView(
    WidgetTester tester,
    NearbyShopsState state,
  ) async {
    stubNearbyState(state);
    await tester.pumpWidget(buildNearbyView());
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

      expect(
        find.text('Yakınında gösterilebilecek mağaza bulunamadı.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Konumunu veya arama kriterlerini değiştirerek tekrar deneyebilirsin.',
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
  });
}
