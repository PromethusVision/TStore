import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_nearby_shops_section.dart';

class MockNearbyShopsCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

void main() {
  late MockNearbyShopsCubit nearbyCubit;

  setUp(() {
    nearbyCubit = MockNearbyShopsCubit();
    when(() => nearbyCubit.loadShops()).thenAnswer((_) async {});
  });

  Widget buildSubject(
    NearbyShopsState state, {
    HomeShopDestinationBuilder? destinationBuilder,
  }) {
    whenListen(
      nearbyCubit,
      const Stream<NearbyShopsState>.empty(),
      initialState: state,
    );

    return BlocProvider<NearbyShopsCubit>.value(
      value: nearbyCubit,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeNearbyShopsSection(
              onViewAll: () {},
              shopDestinationBuilder:
                  destinationBuilder ??
                  (shop) => Scaffold(key: Key('shop-profile-${shop.id}')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('yükleme durumunu gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(const NearbyShopsLoading()));

    expect(find.byKey(const Key('home-nearby-loading')), findsOneWidget);
    expect(find.text('Yakındaki Mağazalar'), findsOneWidget);
  });

  testWidgets('boş durumu sahte mağaza oluşturmadan gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(const NearbyShopsEmpty()));

    expect(find.byKey(const Key('home-nearby-empty')), findsOneWidget);
    expect(find.text('Yakında aktif mağaza bulunamadı'), findsOneWidget);
  });

  testWidgets('hata durumundan yeniden yüklemeyi dener', (tester) async {
    await tester.pumpWidget(
      buildSubject(const NearbyShopsError('Bağlantı hatası')),
    );

    expect(find.byKey(const Key('home-nearby-error')), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => nearbyCubit.loadShops()).called(1);
  });

  testWidgets('gerçek mağaza, konum ve mesafe verisini gösterip profili açar', (
    tester,
  ) async {
    const shop = ShopEntity(
      id: 'shop-1',
      name: 'Nihat Manav',
      address: 'Fevzi Çakmak Mahallesi',
      rating: 4.8,
      ratingCount: 120,
    );
    const state = NearbyShopsLoaded(
      [shop],
      locationStatus: NearbyLocationStatus.ready,
      locationSource: NearbyLocationSource.savedLocation,
      locationLabel: 'Ev',
      distanceMetersByShopId: {'shop-1': 200},
    );

    await tester.pumpWidget(buildSubject(state));

    expect(find.byKey(const Key('home-nearby-loaded')), findsOneWidget);
    expect(find.text('Ev konumuna göre'), findsOneWidget);
    expect(find.text('Nihat Manav'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('≈ 200 m'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('home-shop-shop-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shop-profile-shop-1')), findsOneWidget);
  });

  testWidgets('pasif veya kimliği eksik mağaza profil açmaz', (tester) async {
    var openCount = 0;
    const state = NearbyShopsLoaded([
      ShopEntity(id: 'inactive', name: 'Pasif Mağaza', isActive: false),
      ShopEntity(id: '', name: 'Eksik Mağaza'),
    ]);

    await tester.pumpWidget(
      buildSubject(
        state,
        destinationBuilder: (_) {
          openCount++;
          return const Scaffold();
        },
      ),
    );

    final inactiveLink = tester.widget<InkWell>(
      find.byKey(const Key('home-shop-link-inactive')),
    );
    final invalidLink = tester.widget<InkWell>(
      find.byKey(const Key('home-shop-link-')),
    );

    expect(inactiveLink.onTap, isNull);
    expect(invalidLink.onTap, isNull);
    expect(openCount, 0);
  });

  testWidgets('mağaza kartına hızlı çift dokunma yalnız bir profil açar', (
    tester,
  ) async {
    var openCount = 0;
    const state = NearbyShopsLoaded([
      ShopEntity(id: 'shop-1', name: 'Nihat Manav'),
    ]);

    await tester.pumpWidget(
      buildSubject(
        state,
        destinationBuilder: (_) {
          openCount++;
          return const Scaffold(
            body: SizedBox(key: Key('shop-profile-destination')),
          );
        },
      ),
    );

    final shopLink = tester.widget<InkWell>(
      find.byKey(const Key('home-shop-link-shop-1')),
    );
    shopLink.onTap!();
    shopLink.onTap!();
    await tester.pumpAndSettle();

    expect(openCount, 1);
    expect(find.byKey(const Key('shop-profile-destination')), findsOneWidget);

    Navigator.of(
      tester.element(find.byKey(const Key('shop-profile-destination'))),
    ).pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shop-profile-destination')), findsNothing);
    expect(find.text('Nihat Manav'), findsOneWidget);
  });

  testWidgets('uzun Türkçe mağaza adı mobil kartta iki satırda güvenli kalır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const longShopName =
        'ÇĞİÖŞÜ Esenler Mahalle Dayanışma ve Yerel Ürünler Mağazası';
    const state = NearbyShopsLoaded([
      ShopEntity(
        id: 'long-shop',
        name: longShopName,
        address: 'Esenler, İstanbul',
        rating: 4.7,
        ratingCount: 82,
      ),
    ]);

    await tester.pumpWidget(buildSubject(state));

    final shopLabel = tester.widget<Text>(find.text(longShopName));
    expect(shopLabel.maxLines, 2);
    expect(tester.takeException(), isNull);
  });
}
