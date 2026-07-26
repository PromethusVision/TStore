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

  Widget buildSubject(NearbyShopsState state) {
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
              shopDestinationBuilder: (shop) =>
                  Scaffold(key: Key('shop-profile-${shop.id}')),
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
}
