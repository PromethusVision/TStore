import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shops_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';

class MockGetShopsUsecase extends Mock implements GetShopsUsecase {}

class MockShopRepository extends Mock implements ShopRepository {}

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

    setUp(() {
      getShopsUsecase = MockGetShopsUsecase();
    });

    test('başlangıç durumu NearbyShopsInitial olur', () async {
      final cubit = NearbyShopsCubit(getShopsUsecase: getShopsUsecase);

      expect(cubit.state, const NearbyShopsInitial());

      await cubit.close();
    });

    blocTest<NearbyShopsCubit, NearbyShopsState>(
      'başarılı sonuçta yükleniyor ve mağaza listesi durumlarını yayınlar',
      build: () {
        when(
          () => getShopsUsecase(const NoParams()),
        ).thenAnswer((_) async => const Right(shops));
        return NearbyShopsCubit(getShopsUsecase: getShopsUsecase);
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
        return NearbyShopsCubit(getShopsUsecase: getShopsUsecase);
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
        return NearbyShopsCubit(getShopsUsecase: getShopsUsecase);
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
        return NearbyShopsCubit(getShopsUsecase: getShopsUsecase);
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
      final cubit = NearbyShopsCubit(getShopsUsecase: getShopsUsecase);

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
      final cubit = NearbyShopsCubit(getShopsUsecase: getShopsUsecase);

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
  });
}
