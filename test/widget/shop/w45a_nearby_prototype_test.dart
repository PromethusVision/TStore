import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';

class _Nearby extends MockCubit<NearbyShopsState> implements NearbyShopsCubit {}

class _Cart extends MockCubit<CartV2State> implements CartV2Cubit {}

// Synthetic fixture coordinates; never queried from a device or remote account.
const _origin = CustomerCoordinates(latitude: 40.99, longitude: 29.03);
const _shops = [
  ShopEntity(
    id: 'fixture-shop-1',
    name: 'Çınar Teknoloji',
    address: 'Caferağa Mahallesi, Kadıköy',
    latitude: 40.992,
    longitude: 29.03,
    description: 'Telefon, kulaklık ve günlük teknoloji.',
    rating: 4.8,
  ),
  ShopEntity(
    id: 'fixture-shop-2',
    name: 'Mahalle Giyim',
    address: 'Osmanağa Mahallesi, Kadıköy',
    latitude: 40.996,
    longitude: 29.031,
    description: 'Günlük giyim ve rahat ayakkabılar.',
    rating: 4.6,
  ),
  ShopEntity(
    id: 'fixture-shop-3',
    name: 'Moda Ev & Yaşam',
    address: 'Moda, Kadıköy',
    description: 'Evine küçük dokunuşlar.',
    rating: 4.7,
  ),
];

void main() {
  late _Nearby nearby;
  late _Cart cart;
  setUpAll(() async {
    final poppins = FontLoader('Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      poppins.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), icons.load()]);
  });
  setUp(() async {
    await sl.reset();
    nearby = _Nearby();
    cart = _Cart();
    whenListen(
      cart,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    when(() => nearby.loadShops()).thenAnswer((_) async {});
    when(() => nearby.useCurrentLocation()).thenAnswer((_) async {});
    when(() => nearby.openAppSettings()).thenAnswer((_) async => true);
    when(() => nearby.openLocationSettings()).thenAnswer((_) async => true);
    when(() => nearby.close()).thenAnswer((_) async {});
    sl.registerFactory<NearbyShopsCubit>(() => nearby);
  });
  tearDown(() async => sl.reset());

  NearbyShopsLoaded ready() => NearbyShopsLoaded(
    _shops,
    locationStatus: NearbyLocationStatus.ready,
    locationSource: NearbyLocationSource.savedLocation,
    locationLabel: 'Ev',
    distanceMetersByShopId: {
      for (final shop in _shops.take(2))
        shop.id: CustomerProximityHelper.distanceInMeters(
          from: _origin,
          latitude: shop.latitude,
          longitude: shop.longitude,
        )!,
    },
  );

  Future<void> pump(
    WidgetTester tester, {
    NearbyShopsLoaded? state,
    Future<void> Function()? changeLocation,
    NearbyShopDestinationBuilder? destination,
  }) async {
    whenListen(
      nearby,
      const Stream<NearbyShopsState>.empty(),
      initialState: state ?? ready(),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<CartV2Cubit>.value(
        value: cart,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          home: RepaintBoundary(
            key: const Key('evidence'),
            child: NearbyView(
              visualPrototype: true,
              currentUserIdProvider: () => 'fixture-customer',
              onChangeLocationRequested: changeLocation,
              shopDestinationBuilder: destination,
              cartDestinationBuilder: (_) =>
                  const Scaffold(body: Text('Sepet hedefi')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    '390 px local discovery evidence with truthful unknown distance',
    (tester) async {
      await pump(tester);
      expect(find.text('Ev'), findsOneWidget);
      expect(find.text('Yaklaşık 220 m'), findsOneWidget);
      expect(find.text('Mesafe bilgisi yok'), findsOneWidget);
      verifyNever(() => nearby.useCurrentLocation());
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('evidence')),
        matchesGoldenFile('goldens/w45a_nearby_location_390.png'),
      );
    },
  );
  testWidgets('shop and cart open existing destinations', (tester) async {
    ShopEntity? selected;
    await pump(
      tester,
      destination: (shop) {
        selected = shop;
        return const Scaffold(body: Text('Mağaza hedefi'));
      },
    );
    await tester.tap(find.byKey(const Key('nearby-shop-open-fixture-shop-1')));
    await tester.pumpAndSettle();
    expect(selected, _shops.first);
    expect(find.text('Mağaza hedefi'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nearby-prototype-cart')));
    await tester.pumpAndSettle();
    expect(find.text('Sepet hedefi'), findsOneWidget);
  });
  testWidgets('saved selector reloads the same list after returning', (
    tester,
  ) async {
    var opened = 0;
    await pump(
      tester,
      changeLocation: () async {
        opened++;
      },
    );
    await tester.tap(find.byKey(const Key('nearby-change-location')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    verify(() => nearby.loadShops()).called(2);
    verifyNever(() => nearby.useCurrentLocation());
  });
  testWidgets('current location still waits for explicit consent', (
    tester,
  ) async {
    await pump(tester, state: const NearbyShopsLoaded(_shops));
    await tester.tap(find.byKey(const Key('nearby-location-action')));
    await tester.pumpAndSettle();
    verifyNever(() => nearby.useCurrentLocation());
    await tester.tap(find.byKey(const Key('nearby-location-confirm')));
    await tester.pumpAndSettle();
    verify(() => nearby.useCurrentLocation()).called(1);
  });
  testWidgets('denied permission keeps discovery and no distance claim', (
    tester,
  ) async {
    await pump(
      tester,
      state: const NearbyShopsLoaded(
        _shops,
        locationStatus: NearbyLocationStatus.permissionDenied,
      ),
    );
    expect(find.text('Konum izni verilmedi'), findsOneWidget);
    expect(find.text('Mağazaları keşfet'), findsOneWidget);
    expect(find.textContaining('Yaklaşık'), findsNothing);
    expect(
      find.byKey(const Key('nearby-shop-open-fixture-shop-1')),
      findsOneWidget,
    );
  });
  testWidgets('disabled location still opens location settings', (
    tester,
  ) async {
    await pump(
      tester,
      state: const NearbyShopsLoaded(
        _shops,
        locationStatus: NearbyLocationStatus.servicesDisabled,
      ),
    );
    await tester.tap(find.byKey(const Key('nearby-location-action')));
    await tester.pumpAndSettle();
    verify(() => nearby.openLocationSettings()).called(1);
    verifyNever(() => nearby.openAppSettings());
  });
  test('presentation stays default off', () {
    expect(const NearbyView().visualPrototype, isFalse);
  });
}
