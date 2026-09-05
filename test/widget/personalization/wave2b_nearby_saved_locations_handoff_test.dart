import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/domain/repositories/customer_saved_location_repository.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/data/services/geolocator_customer_location_service.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';

import 'w46_account_fixture.dart' show loadAccountFonts, accountViewport;

class _Locations extends Mock implements CustomerSavedLocationRepository {}

class _Shops extends Mock implements GetShopsUsecase {}

class _Cart extends MockCubit<CartV2State> implements CartV2Cubit {}

// Offline fixtures only; no saved location, GPS or merchant request reaches a
// remote service. Views, Cubits and preferred-location validation are real.
const _home = CustomerSavedLocationEntity(
  id: 'wave2b-home',
  userId: 'wave2b-customer',
  name: 'Ev',
  addressText: 'Test ev konumu',
  latitude: 41,
  longitude: 29,
  isDefault: true,
);
const _work = CustomerSavedLocationEntity(
  id: 'wave2b-work',
  userId: 'wave2b-customer',
  name: 'İş',
  addressText: 'Test iş konumu',
  latitude: 42,
  longitude: 29,
);
const _shops = [
  ShopEntity(
    id: 'wave2b-shop-home',
    name: 'Ev Yakını Test Mağazası',
    latitude: 41,
    longitude: 29,
  ),
  ShopEntity(
    id: 'wave2b-shop-work',
    name: 'İş Yakını Test Mağazası',
    latitude: 42,
    longitude: 29,
  ),
];

void main() {
  setUpAll(() async {
    registerFallbackValue(NoParams());
    await loadAccountFonts();
  });
  setUp(() async => sl.reset());
  tearDown(() async => sl.reset());

  for (final deleteLast in [false, true]) {
    testWidgets(
      deleteLast
          ? 'W2B real Nearby handoff clears stale location after deleting the last saved location'
          : 'W2B real Nearby handoff reloads the selected default and merchant order',
      (tester) async {
        accountViewport(tester, 390);
        final repository = _Locations();
        final getShops = _Shops();
        final cart = _Cart();
        var locations = deleteLast ? [_home] : [_home, _work];
        var gpsRequests = 0;
        var permissionRequests = 0;

        when(
          () => repository.getLocations(),
        ).thenAnswer((_) async => Right(List.of(locations)));
        when(() => repository.getDefaultLocation()).thenAnswer((_) async {
          final defaults = locations.where((location) => location.isDefault);
          return Right(defaults.isEmpty ? null : defaults.first);
        });
        when(() => repository.setDefaultLocation(any())).thenAnswer((
          invocation,
        ) async {
          final id = invocation.positionalArguments.single as String;
          locations = [
            for (final location in locations)
              location.copyWith(isDefault: location.id == id),
          ];
          return const Right(null);
        });
        when(() => repository.deleteLocation(any())).thenAnswer((
          invocation,
        ) async {
          final id = invocation.positionalArguments.single as String;
          locations = locations.where((location) => location.id != id).toList();
          return const Right(null);
        });
        when(
          () => getShops(any()),
        ).thenAnswer((_) async => const Right(_shops));
        whenListen(
          cart,
          const Stream<CartV2State>.empty(),
          initialState: const CartV2Loaded([]),
        );

        final service = GeolocatorCustomerLocationService(
          // Same repository-to-preferred-location contract as service_locator.
          preferredLocationLoader: () async {
            final result = await repository.getDefaultLocation();
            return result.fold(
              (_) => null,
              (location) => location == null
                  ? null
                  : CustomerPreferredLocation(
                      name: location.name,
                      coordinates: CustomerCoordinates(
                        latitude: location.latitude,
                        longitude: location.longitude,
                      ),
                    ),
            );
          },
          coordinatesLoader: () async {
            gpsRequests++;
            throw StateError('This saved-location flow must not request GPS');
          },
          permissionRequester: () async {
            permissionRequests++;
            throw StateError('This flow must not request device permission');
          },
        );
        final nearby = NearbyShopsCubit(
          getShopsUsecase: getShops,
          customerLocationService: service,
        );
        sl.registerFactory<NearbyShopsCubit>(() => nearby);
        sl.registerFactory<CustomerSavedLocationsCubit>(
          () => CustomerSavedLocationsCubit(
            repository: repository,
            customerLocationService: service,
          ),
        );

        await tester.pumpWidget(
          BlocProvider<CartV2Cubit>.value(
            value: cart,
            child: MaterialApp(
              theme: EsnaftaVarTheme.light,
              home: NearbyView(currentUserIdProvider: () => 'wave2b-customer'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Ev'), findsOneWidget);
        expect(
          (nearby.state as NearbyShopsLoaded).shops.first.id,
          'wave2b-shop-home',
        );

        await tester.tap(find.byKey(const Key('nearby-change-location')));
        await tester.pumpAndSettle();
        expect(find.byType(CustomerSavedLocationsView), findsOneWidget);
        expect(find.text('Kayıtlı Konumlarım'), findsOneWidget);

        if (deleteLast) {
          await tester.tap(
            find.byKey(const Key('saved-location-delete-wave2b-home')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('saved-location-delete-dialog')),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(const Key('saved-location-delete-confirm')),
          );
          await tester.pumpAndSettle();
          expect(find.text('Henüz kayıtlı konumun yok'), findsOneWidget);
          verify(() => repository.deleteLocation('wave2b-home')).called(1);
          verifyNever(() => repository.setDefaultLocation(any()));
        } else {
          await tester.tap(
            find.byKey(const Key('saved-location-default-wave2b-work')),
          );
          await tester.pumpAndSettle();
          verify(() => repository.setDefaultLocation('wave2b-work')).called(1);
          verifyNever(() => repository.deleteLocation(any()));
        }

        await tester.tap(
          find.byKey(const Key('customer-saved-locations-back-button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomerSavedLocationsView), findsNothing);
        final returned = nearby.state as NearbyShopsLoaded;
        if (deleteLast) {
          expect(returned.locationSource, isNull);
          expect(returned.locationLabel, isNull);
          expect(returned.distanceMetersByShopId, isEmpty);
          expect(find.text('Konum seçilmedi'), findsNWidgets(_shops.length));
          expect(find.text('Yakından uzağa sıralandı'), findsNothing);
          expect(find.text('Ev'), findsNothing);
        } else {
          expect(returned.locationSource, NearbyLocationSource.savedLocation);
          expect(returned.locationLabel, 'İş');
          expect(returned.shops.first.id, 'wave2b-shop-work');
          expect(returned.distanceForShop('wave2b-shop-work'), 0);
          expect(find.text('İş'), findsOneWidget);
          expect(find.text('Konumun mağazalarla paylaşılmaz.'), findsOneWidget);
        }
        expect(gpsRequests, 0);
        expect(permissionRequests, 0);
        verify(() => repository.getDefaultLocation()).called(2);
        verify(() => getShops(any())).called(2);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await cart.close();
      },
    );
  }
}
