import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_shop_usecase.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

class _Nearby extends MockCubit<NearbyShopsState> implements NearbyShopsCubit {}

class _Cart extends MockCubit<CartV2State> implements CartV2Cubit {}

class _Repository extends Mock implements ShopRepository {}

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
    NearbyShopsState? state,
    Future<void> Function()? changeLocation,
    NearbyShopDestinationBuilder? destination,
    double width = 390,
    double textScale = 1,
    Stream<NearbyShopsState> states = const Stream.empty(),
    bool settle = true,
  }) async {
    whenListen(nearby, states, initialState: state ?? ready());
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<CartV2Cubit>.value(
        value: cart,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: const Key('evidence'),
            child: NearbyView(
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
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 200));
    }
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
  test(
    'Final UI is default and explicit legacy comparison remains available',
    () {
      expect(const NearbyView().visualPrototype, isTrue);
      expect(const NearbyView(visualPrototype: false).visualPrototype, isFalse);
    },
  );

  Future<void> evidence(WidgetTester tester, String name) => expectLater(
    find.byKey(const Key('evidence')),
    matchesGoldenFile('goldens/w45a_r2_nearby_$name.png'),
  );

  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('loaded ${width.toInt()} scale $scale', (tester) async {
        await pump(tester, width: width, textScale: scale);
        expect(find.text('Yakınındakiler'), findsOneWidget);
        expect(find.text('Konumun mağazalarla paylaşılmaz.'), findsOneWidget);
        expect(find.text('Yaklaşık 220 m'), findsOneWidget);
        verifyNever(() => nearby.useCurrentLocation());
        expect(tester.takeException(), isNull);
        await evidence(
          tester,
          'loaded_${width.toInt()}_scale_${(scale * 100).round()}',
        );
        await tester.scrollUntilVisible(
          find
              .byKey(const Key('nearby-shop-open-fixture-shop-3'))
              .hitTestable(),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Mesafe bilgisi yok'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    for (final status in NearbyLocationStatus.values) {
      testWidgets('location ${status.name} ${width.toInt()} scale 1.3', (
        tester,
      ) async {
        await pump(
          tester,
          width: width,
          textScale: 1.3,
          state: NearbyShopsLoaded(
            _shops,
            locationStatus: status,
            locationSource: status == NearbyLocationStatus.ready
                ? NearbyLocationSource.device
                : null,
          ),
          settle: status != NearbyLocationStatus.requesting,
        );
        expect(
          find.byKey(const Key('nearby-shop-open-fixture-shop-1')),
          findsOneWidget,
        );
        expect(find.textContaining('Yaklaşık'), findsNothing);
        expect(tester.takeException(), isNull);
        verifyNever(() => nearby.useCurrentLocation());
        if (width == 390) {
          await evidence(tester, 'location_${status.name}_390_scale_130');
        }
        if (status == NearbyLocationStatus.ready) {
          expect(find.text('Mevcut konumun'), findsOneWidget);
          expect(find.text('Mesafe bilgisi henüz yok'), findsOneWidget);
          expect(
            find.text('Konumunu bu sıralama için kullandık; kaydetmedik.'),
            findsOneWidget,
          );
          expect(
            tester
                .widget<InkWell>(
                  find.byKey(const Key('nearby-change-location')),
                )
                .onTap,
            isNull,
          );
        } else if (status == NearbyLocationStatus.requesting) {
          expect(
            find.byKey(const Key('nearby-location-progress')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('nearby-location-action')), findsNothing);
        } else {
          final semantics = tester.ensureSemantics();
          await tester.pump();
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          semantics.dispose();
          await tester.tap(find.byKey(const Key('nearby-location-action')));
          await tester.pumpAndSettle();
          if (status == NearbyLocationStatus.permissionDeniedForever) {
            verify(() => nearby.openAppSettings()).called(1);
            verifyNever(() => nearby.openLocationSettings());
          } else if (status == NearbyLocationStatus.servicesDisabled) {
            verify(() => nearby.openLocationSettings()).called(1);
            verifyNever(() => nearby.openAppSettings());
          } else {
            expect(
              find.byKey(const Key('nearby-location-confirm')),
              findsOneWidget,
            );
            verifyNever(() => nearby.useCurrentLocation());
            expect(tester.takeException(), isNull);
            await tester.tap(find.byKey(const Key('nearby-location-cancel')));
            await tester.pumpAndSettle();
            verifyNever(() => nearby.useCurrentLocation());
          }
        }
      });
    }

    for (final scenario in ['empty', 'initial', 'loading', 'error']) {
      testWidgets('$scenario ${width.toInt()} scale 1.3', (tester) async {
        final NearbyShopsState state = switch (scenario) {
          'empty' => const NearbyShopsEmpty(),
          'initial' => const NearbyShopsInitial(),
          'loading' => const NearbyShopsLoading(),
          _ => const NearbyShopsError('fixture private error'),
        };
        await pump(
          tester,
          width: width,
          textScale: 1.3,
          state: state,
          settle: scenario != 'initial' && scenario != 'loading',
        );
        expect(find.text('fixture private error'), findsNothing);
        expect(find.text('Mağazayı gör'), findsNothing);
        expect(tester.takeException(), isNull);
        verifyNever(() => nearby.useCurrentLocation());
        if (width == 390) await evidence(tester, '${scenario}_390_scale_130');
        if (scenario == 'error') {
          await tester.tap(find.text('Tekrar Dene'));
          await tester.pump();
          verify(() => nearby.loadShops()).called(2);
        }
      });
    }

    testWidgets('long merchant and locality with large distance ${width.toInt()}', (
      tester,
    ) async {
      final shop = _shops.first.copyWith(
        name: 'İstanbul Mahalle Esnafı Dayanışma ve Teknoloji Kooperatifi',
        address:
            'Örnek Mahallesi Uzun Çarşı Caddesi Deneme İş Merkezi, Kadıköy / İstanbul',
        description:
            'Mağazada inceleyebileceğin günlük teknoloji ürünleri ve elektronik aksesuarlar.',
        rating: 0,
      );
      await pump(
        tester,
        width: width,
        textScale: 1.3,
        state: ready().copyWith(
          shops: [shop],
          locationLabel: 'Uzun kayıtlı konum adı: çalışma alanım ve mahallem',
          distanceMetersByShopId: {shop.id: 12345678},
        ),
      );
      expect(find.text('Yaklaşık 12345,7 km'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(tester.takeException(), isNull);
      await evidence(tester, 'stress_${width.toInt()}_scale_130');
    });
  }

  testWidgets('invalid or unrelated distance never claims proximity', (
    tester,
  ) async {
    await pump(
      tester,
      state: ready().copyWith(
        distanceMetersByShopId: {
          _shops[0].id: double.nan,
          _shops[1].id: -1,
          _shops[2].id: double.infinity,
          'fixture-unrelated-shop': 20,
        },
      ),
    );
    expect(find.text('Yakından uzağa sıralandı'), findsNothing);
    expect(find.text('Yakınındaki esnaf'), findsNothing);
    expect(find.text('Mağazaları keşfet'), findsOneWidget);
    expect(find.textContaining('Yaklaşık'), findsNothing);
    expect(find.text('Mesafe bilgisi yok'), findsNWidgets(3));
    await evidence(tester, 'no_distance_390');
  });

  testWidgets('non-ready state does not display stale distances', (
    tester,
  ) async {
    await pump(
      tester,
      state: ready().copyWith(locationStatus: NearbyLocationStatus.unavailable),
    );
    expect(find.textContaining('Yaklaşık'), findsNothing);
    expect(find.text('Yakınındaki esnaf'), findsNothing);
    expect(find.text('Konum seçilmedi'), findsWidgets);
  });

  testWidgets('many merchants reach last handoff and return to same list', (
    tester,
  ) async {
    final shops = List.generate(
      30,
      (index) => _shops.first.copyWith(
        id: 'fixture-many-$index',
        name: 'Mahalle mağazası $index',
      ),
    );
    ShopEntity? selected;
    await pump(
      tester,
      width: 320,
      textScale: 1.3,
      state: ready().copyWith(shops: shops, distanceMetersByShopId: {}),
      destination: (shop) {
        selected = shop;
        return const Scaffold(body: Text('Son mağaza'));
      },
    );
    final last = find.byKey(const Key('nearby-shop-open-fixture-many-29'));
    await tester.scrollUntilVisible(
      last.hitTestable(),
      400,
      maxScrolls: 70,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final action = tester.widget<TextButton>(last).onPressed!;
    action();
    action();
    await tester.pumpAndSettle();
    expect(selected?.id, 'fixture-many-29');
    expect(find.text('Son mağaza'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(last.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'default shop handoff uses actual ShopProfileView and original entity',
    (tester) async {
      final repository = _Repository();
      when(
        () => repository.getShopProductsByShop(any()),
      ).thenAnswer((_) async => const Right([]));
      sl.registerSingleton(GetShopProductsByShopUsecase(repository));
      // Same offline auth bootstrap as widget_test.dart; no session or remote data.
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        await SupabaseService.initialize(
          config: SupabaseConfig.forEnvironment(
            environment: AppEnvironment.development,
            supabaseUrl: 'https://widget-test.supabase.co',
            supabaseAnonKey: 'sb_publishable_widget_test_public_key',
          ),
        );
      });
      await pump(tester);
      await tester.tap(
        find.byKey(const Key('nearby-shop-open-fixture-shop-1')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ShopProfileView>(find.byType(ShopProfileView)).shop,
        _shops.first,
      );
      expect(
        tester
            .widget<ShopProfileView>(find.byType(ShopProfileView))
            .visualPrototype,
        isTrue,
      );
      expect(find.text('Mağazayı keşfet'), findsOneWidget);
      verify(() => repository.getShopProductsByShop(_shops.first.id)).called(1);
      await tester.tap(find.byKey(const Key('shop-profile-back')));
      await tester.pumpAndSettle();
      expect(find.text('Yakınındakiler'), findsOneWidget);
    },
  );

  testWidgets('inactive and invalid shops cannot navigate', (tester) async {
    var opened = 0;
    await pump(
      tester,
      state: ready().copyWith(
        shops: [
          _shops.first.copyWith(isActive: false),
          _shops[1].copyWith(id: ' '),
        ],
      ),
      destination: (_) {
        opened++;
        return const SizedBox();
      },
    );
    for (final button in tester.widgetList<TextButton>(
      find.widgetWithText(TextButton, 'Mağazayı gör'),
    )) {
      expect(button.onPressed, isNull);
    }
    expect(opened, 0);
  });

  testWidgets('requesting to denied keeps merchants and retry consent', (
    tester,
  ) async {
    final states = StreamController<NearbyShopsState>();
    await pump(
      tester,
      states: states.stream,
      state: const NearbyShopsLoaded(_shops),
    );
    states.add(
      const NearbyShopsLoaded(
        _shops,
        locationStatus: NearbyLocationStatus.requesting,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('nearby-location-progress')), findsOneWidget);
    states.add(
      const NearbyShopsLoaded(
        _shops,
        locationStatus: NearbyLocationStatus.permissionDenied,
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Konum izni verilmedi'), findsOneWidget);
    expect(
      find.byKey(const Key('nearby-shop-open-fixture-shop-1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('nearby-location-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nearby-location-confirm')));
    await tester.pumpAndSettle();
    verify(() => nearby.useCurrentLocation()).called(1);
    await states.close();
  });

  testWidgets('saved location selector has label and 44 px target', (
    tester,
  ) async {
    await pump(tester, width: 320, textScale: 1.3);
    final semantics = tester.ensureSemantics();
    await tester.pump();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    semantics.dispose();
  });
}
