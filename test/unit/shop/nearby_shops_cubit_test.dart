import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';

class MockGetShopsUsecase extends Mock implements GetShopsUsecase {}

class MockShopRepository extends Mock implements ShopRepository {}

class MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

void main() {
  const shops = <ShopEntity>[
    ShopEntity(
      id: 'shop-1',
      ownerUserId: 'owner-1',
      name: 'Mahalle Marketi',
      description: 'Günlük ihtiyaçlar',
      address: 'Esenler, İstanbul',
      latitude: 41.043,
      longitude: 28.876,
      phone: '02125550000',
      openingHours: {'mon_fri': '09:00-20:00'},
      rating: 4.6,
    ),
    ShopEntity(
      id: 'shop-2',
      name: 'Semt Kırtasiyesi',
      address: 'Esenler, İstanbul',
    ),
  ];

  group('GetShopsUsecase', () {
    late MockShopRepository repository;
    late GetShopsUsecase usecase;

    setUp(() {
      repository = MockShopRepository();
      usecase = GetShopsUsecase(repository);
    });

    test('mağaza listesini repositoryden değiştirmeden döndürür', () async {
      when(repository.getShops).thenAnswer((_) async => const Right(shops));

      final result = await usecase(const NoParams());

      expect(result, const Right<String, List<ShopEntity>>(shops));
      verify(repository.getShops).called(1);
    });

    test('repository hatasını değiştirmeden döndürür', () async {
      when(
        repository.getShops,
      ).thenAnswer((_) async => const Left('Mağazalar alınamadı'));

      final result = await usecase(const NoParams());

      expect(
        result,
        const Left<String, List<ShopEntity>>('Mağazalar alınamadı'),
      );
      verify(repository.getShops).called(1);
    });
  });

  group('NearbyShopsCubit', () {
    late MockGetShopsUsecase getShopsUsecase;
    late MockCustomerLocationService customerLocationService;

    setUp(() {
      getShopsUsecase = MockGetShopsUsecase();
      customerLocationService = MockCustomerLocationService();
      when(() => customerLocationService.cachedCoordinates).thenReturn(null);
      when(
        () => customerLocationService.getPreferredLocation(),
      ).thenAnswer((_) async => null);
    });

    test('başlangıç durumu NearbyShopsInitial olur', () async {
      final cubit = NearbyShopsCubit(
        getShopsUsecase: getShopsUsecase,
        customerLocationService: customerLocationService,
      );

      expect(cubit.state, const NearbyShopsInitial());

      await cubit.close();
    });

    test(
      'ana konum varsa izin istemeden mağazaları bu konuma göre sıralar',
      () async {
        const preferredLocation = CustomerPreferredLocation(
          name: 'Ev',
          coordinates: CustomerCoordinates(latitude: 41, longitude: 29),
        );
        const distanceShops = <ShopEntity>[
          ShopEntity(
            id: 'far-shop',
            name: 'Uzak Mağaza',
            latitude: 41.1,
            longitude: 29,
          ),
          ShopEntity(
            id: 'near-shop',
            name: 'Yakın Mağaza',
            latitude: 41.001,
            longitude: 29,
          ),
        ];
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(distanceShops));
        when(
          () => customerLocationService.getPreferredLocation(),
        ).thenAnswer((_) async => preferredLocation);
        final cubit = NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );

        await cubit.loadShops();

        final state = cubit.state as NearbyShopsLoaded;
        expect(state.locationStatus, NearbyLocationStatus.ready);
        expect(state.locationSource, NearbyLocationSource.savedLocation);
        expect(state.locationLabel, 'Ev');
        expect(
          state.shops.map((shop) => shop.id),
          orderedEquals(const ['near-shop', 'far-shop']),
        );
        verifyNever(() => customerLocationService.getCurrentLocation());
        await cubit.close();
      },
    );

    blocTest<NearbyShopsCubit, NearbyShopsState>(
      'başarılı sonuçta yükleniyor ve mağaza listesi durumlarını yayınlar',
      build: () {
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(shops));
        return NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );
      },
      act: (cubit) => cubit.loadShops(),
      expect: () => const <NearbyShopsState>[
        NearbyShopsLoading(),
        NearbyShopsLoaded(shops),
      ],
      verify: (_) {
        verify(() => getShopsUsecase(const NoParams())).called(1);
      },
    );

    blocTest<NearbyShopsCubit, NearbyShopsState>(
      'sonuç yoksa boş durumunu yayınlar',
      build: () {
        when(() => getShopsUsecase(const NoParams())).thenAnswer(
          (_) async => const Right<String, List<ShopEntity>>(<ShopEntity>[]),
        );
        return NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );
      },
      act: (cubit) => cubit.loadShops(),
      expect: () => const <NearbyShopsState>[
        NearbyShopsLoading(),
        NearbyShopsEmpty(),
      ],
    );

    blocTest<NearbyShopsCubit, NearbyShopsState>(
      'hata sonucunda yükleniyor ve hata durumlarını yayınlar',
      build: () {
        when(() => getShopsUsecase(const NoParams())).thenAnswer(
          (_) async =>
              const Left<String, List<ShopEntity>>('Mağazalar alınamadı'),
        );
        return NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );
      },
      act: (cubit) => cubit.loadShops(),
      expect: () => const <NearbyShopsState>[
        NearbyShopsLoading(),
        NearbyShopsError('Mağazalar alınamadı'),
      ],
    );

    blocTest<NearbyShopsCubit, NearbyShopsState>(
      'hata sonrası yeniden denemede mağazaları yükler',
      build: () {
        var attempt = 0;
        when(() => getShopsUsecase(const NoParams())).thenAnswer((_) async {
          attempt++;
          if (attempt == 1) {
            return const Left<String, List<ShopEntity>>(
              'Geçici bağlantı hatası',
            );
          }
          return const Right<String, List<ShopEntity>>(shops);
        });
        return NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );
      },
      act: (cubit) async {
        await cubit.loadShops();
        await cubit.loadShops();
      },
      expect: () => const <NearbyShopsState>[
        NearbyShopsLoading(),
        NearbyShopsError('Geçici bağlantı hatası'),
        NearbyShopsLoading(),
        NearbyShopsLoaded(shops),
      ],
      verify: (_) {
        verify(() => getShopsUsecase(const NoParams())).called(2);
      },
    );

    test('kapanıştan sonra gelen geç sonuç yeni durum yayınlamaz', () async {
      final completer = Completer<Either<String, List<ShopEntity>>>();
      when(
        () => getShopsUsecase(const NoParams()),
      ).thenAnswer((_) => completer.future);
      final cubit = NearbyShopsCubit(
        getShopsUsecase: getShopsUsecase,
        customerLocationService: customerLocationService,
      );

      final loadFuture = cubit.loadShops();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, const NearbyShopsLoading());

      await cubit.close();
      completer.complete(const Right(shops));

      await expectLater(loadFuture, completes);
      expect(cubit.state, const NearbyShopsLoading());
      verify(() => getShopsUsecase(const NoParams())).called(1);
    });

    test('eski isteğin geç sonucu yeni isteğin sonucunu ezmez', () async {
      final firstRequest = Completer<Either<String, List<ShopEntity>>>();
      final secondRequest = Completer<Either<String, List<ShopEntity>>>();
      var invocation = 0;
      when(() => getShopsUsecase(const NoParams())).thenAnswer((_) {
        invocation++;
        return invocation == 1 ? firstRequest.future : secondRequest.future;
      });
      final cubit = NearbyShopsCubit(
        getShopsUsecase: getShopsUsecase,
        customerLocationService: customerLocationService,
      );

      final firstLoad = cubit.loadShops();
      await Future<void>.delayed(Duration.zero);
      final secondLoad = cubit.loadShops();
      secondRequest.complete(const Right(shops));
      await secondLoad;

      firstRequest.complete(
        const Left<String, List<ShopEntity>>('Eski istek hatası'),
      );
      await firstLoad;

      expect(cubit.state, const NearbyShopsLoaded(shops));
      verify(() => getShopsUsecase(const NoParams())).called(2);
      await cubit.close();
    });

    test(
      'konum alındığında gerçek mesafeye göre sıralar ve eksik konumları sona bırakır',
      () async {
        const distanceShops = <ShopEntity>[
          ShopEntity(id: 'without-location', name: 'Konumsuz Mağaza'),
          ShopEntity(
            id: 'far-shop',
            name: 'Uzak Mağaza',
            latitude: 41.1,
            longitude: 29,
          ),
          ShopEntity(
            id: 'invalid-shop',
            name: 'Geçersiz Konumlu Mağaza',
            latitude: 95,
            longitude: 29,
          ),
          ShopEntity(
            id: 'near-shop',
            name: 'Yakın Mağaza',
            latitude: 41.001,
            longitude: 29,
          ),
        ];
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(distanceShops));
        when(() => customerLocationService.getCurrentLocation()).thenAnswer(
          (_) async => const CustomerLocationResult.success(
            CustomerCoordinates(latitude: 41, longitude: 29),
          ),
        );
        final cubit = NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );

        await cubit.loadShops();
        await cubit.useCurrentLocation();

        final state = cubit.state as NearbyShopsLoaded;
        expect(state.locationStatus, NearbyLocationStatus.ready);
        expect(
          state.shops.map((shop) => shop.id),
          orderedEquals(const [
            'near-shop',
            'far-shop',
            'without-location',
            'invalid-shop',
          ]),
        );
        expect(state.distanceForShop('near-shop'), closeTo(111.2, 1));
        expect(state.distanceForShop('far-shop'), greaterThan(11000));
        expect(state.distanceForShop('without-location'), isNull);
        expect(state.distanceForShop('invalid-shop'), isNull);
        verify(() => customerLocationService.getCurrentLocation()).called(1);

        await cubit.close();
      },
    );

    const failureCases = <CustomerLocationFailure, NearbyLocationStatus>{
      CustomerLocationFailure.permissionDenied:
          NearbyLocationStatus.permissionDenied,
      CustomerLocationFailure.servicesDisabled:
          NearbyLocationStatus.servicesDisabled,
      CustomerLocationFailure.timedOut: NearbyLocationStatus.timedOut,
      CustomerLocationFailure.unavailable: NearbyLocationStatus.unavailable,
    };

    for (final failureCase in failureCases.entries) {
      test(
        '${failureCase.key.name} durumunda mağaza listesini kullanılabilir tutar',
        () async {
          when(
            () => getShopsUsecase(const NoParams()),
          ).thenAnswer((_) async => const Right(shops));
          when(() => customerLocationService.getCurrentLocation()).thenAnswer(
            (_) async => CustomerLocationResult.failed(failureCase.key),
          );
          final cubit = NearbyShopsCubit(
            getShopsUsecase: getShopsUsecase,
            customerLocationService: customerLocationService,
          );

          await cubit.loadShops();
          await cubit.useCurrentLocation();

          expect(
            cubit.state,
            NearbyShopsLoaded(shops, locationStatus: failureCase.value),
          );
          verify(() => customerLocationService.getCurrentLocation()).called(1);
          await cubit.close();
        },
      );
    }

    test('hızlı tekrar isteğinde konumu yalnızca bir kez alır', () async {
      final locationRequest = Completer<CustomerLocationResult>();
      when(
        () => getShopsUsecase(const NoParams()),
      ).thenAnswer((_) async => const Right(shops));
      when(
        () => customerLocationService.getCurrentLocation(),
      ).thenAnswer((_) => locationRequest.future);
      final cubit = NearbyShopsCubit(
        getShopsUsecase: getShopsUsecase,
        customerLocationService: customerLocationService,
      );
      await cubit.loadShops();

      final firstRequest = cubit.useCurrentLocation();
      final secondRequest = cubit.useCurrentLocation();

      expect(
        (cubit.state as NearbyShopsLoaded).locationStatus,
        NearbyLocationStatus.requesting,
      );
      await secondRequest;
      verify(() => customerLocationService.getCurrentLocation()).called(1);

      locationRequest.complete(
        const CustomerLocationResult.success(
          CustomerCoordinates(latitude: 41, longitude: 29),
        ),
      );
      await firstRequest;
      await cubit.useCurrentLocation();

      expect(
        (cubit.state as NearbyShopsLoaded).locationStatus,
        NearbyLocationStatus.ready,
      );
      verifyNever(() => customerLocationService.getCurrentLocation());
      await cubit.close();
    });

    test('konum alınırken mağaza yenileme ikinci istek başlatmaz', () async {
      final locationRequest = Completer<CustomerLocationResult>();
      when(
        () => getShopsUsecase(const NoParams()),
      ).thenAnswer((_) async => const Right(shops));
      when(
        () => customerLocationService.getCurrentLocation(),
      ).thenAnswer((_) => locationRequest.future);
      final cubit = NearbyShopsCubit(
        getShopsUsecase: getShopsUsecase,
        customerLocationService: customerLocationService,
      );
      await cubit.loadShops();

      final pendingLocation = cubit.useCurrentLocation();
      await cubit.loadShops();

      expect(
        (cubit.state as NearbyShopsLoaded).locationStatus,
        NearbyLocationStatus.requesting,
      );
      verify(() => getShopsUsecase(const NoParams())).called(1);
      verify(() => customerLocationService.getCurrentLocation()).called(1);

      locationRequest.complete(
        const CustomerLocationResult.success(
          CustomerCoordinates(latitude: 41, longitude: 29),
        ),
      );
      await pendingLocation;

      expect(
        (cubit.state as NearbyShopsLoaded).locationStatus,
        NearbyLocationStatus.ready,
      );
      verifyNever(() => customerLocationService.getCurrentLocation());
      await cubit.close();
    });

    test(
      'aynı oturumdaki bellekteki konumu yeniden izin istemeden kullanır',
      () async {
        const cachedCoordinates = CustomerCoordinates(
          latitude: 41,
          longitude: 29,
        );
        when(
          () => customerLocationService.cachedCoordinates,
        ).thenReturn(cachedCoordinates);
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(shops));
        final cubit = NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );

        await cubit.loadShops();

        final state = cubit.state as NearbyShopsLoaded;
        expect(state.locationStatus, NearbyLocationStatus.ready);
        expect(state.distanceForShop('shop-1'), isNotNull);
        verifyNever(() => customerLocationService.getCurrentLocation());
        await cubit.close();
      },
    );

    test(
      'mağazalar yenilendiğinde bellekteki konumla tekrar sıralar',
      () async {
        const refreshShops = <ShopEntity>[
          ShopEntity(
            id: 'far-shop',
            name: 'Uzak Mağaza',
            latitude: 41.1,
            longitude: 29,
          ),
          ShopEntity(
            id: 'near-shop',
            name: 'Yakın Mağaza',
            latitude: 41.001,
            longitude: 29,
          ),
        ];
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(refreshShops));
        when(() => customerLocationService.getCurrentLocation()).thenAnswer(
          (_) async => const CustomerLocationResult.success(
            CustomerCoordinates(latitude: 41, longitude: 29),
          ),
        );
        final cubit = NearbyShopsCubit(
          getShopsUsecase: getShopsUsecase,
          customerLocationService: customerLocationService,
        );

        await cubit.loadShops();
        await cubit.useCurrentLocation();
        await cubit.loadShops();

        final state = cubit.state as NearbyShopsLoaded;
        expect(state.locationStatus, NearbyLocationStatus.ready);
        expect(
          state.shops.map((shop) => shop.id),
          orderedEquals(const ['near-shop', 'far-shop']),
        );
        verify(() => getShopsUsecase(const NoParams())).called(2);
        verify(() => customerLocationService.getCurrentLocation()).called(1);
        await cubit.close();
      },
    );
  });
}
