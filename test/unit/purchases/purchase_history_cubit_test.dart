import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/domain/usecases/get_verified_purchases_usecase.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';

class MockGetVerifiedPurchasesUsecase extends Mock
    implements GetVerifiedPurchasesUsecase {}

void main() {
  final purchase = VerifiedPurchaseEntity(
    id: 'purchase-1',
    sourceQrSessionId: 'session-1',
    shopId: 'shop-1',
    shopName: 'Mahalle Marketi',
    itemCount: 1,
    totalAmount: 75,
    confirmedAt: DateTime.utc(2026, 7, 15, 10, 30),
    items: [],
  );

  late MockGetVerifiedPurchasesUsecase usecase;

  setUp(() {
    usecase = MockGetVerifiedPurchasesUsecase();
  });

  blocTest<PurchaseHistoryCubit, PurchaseHistoryState>(
    'doğrulanmış alışverişleri yükler',
    setUp: () {
      when(
        () => usecase(const NoParams()),
      ).thenAnswer((_) async => Right([purchase]));
    },
    build: () => PurchaseHistoryCubit(getVerifiedPurchasesUsecase: usecase),
    act: (cubit) => cubit.loadPurchases(),
    expect: () => [
      isA<PurchaseHistoryLoading>(),
      PurchaseHistoryLoaded([purchase]),
    ],
  );

  blocTest<PurchaseHistoryCubit, PurchaseHistoryState>(
    'yükleme hatasını sade biçimde gösterir',
    setUp: () {
      when(
        () => usecase(const NoParams()),
      ).thenAnswer((_) async => const Left('Alışverişler yüklenemedi.'));
    },
    build: () => PurchaseHistoryCubit(getVerifiedPurchasesUsecase: usecase),
    act: (cubit) => cubit.loadPurchases(),
    expect: () => [
      isA<PurchaseHistoryLoading>(),
      const PurchaseHistoryError('Alışverişler yüklenemedi.'),
    ],
  );

  test('yükleme sürerken ikinci isteği başlatmaz', () async {
    final request = Completer<Either<String, List<VerifiedPurchaseEntity>>>();
    when(() => usecase(const NoParams())).thenAnswer((_) => request.future);
    final cubit = PurchaseHistoryCubit(getVerifiedPurchasesUsecase: usecase);
    addTearDown(cubit.close);

    final firstLoad = cubit.loadPurchases();
    final secondLoad = cubit.loadPurchases();

    verify(() => usecase(const NoParams())).called(1);
    request.complete(Right([purchase]));
    await Future.wait([firstLoad, secondLoad]);

    expect(cubit.state, PurchaseHistoryLoaded([purchase]));
  });

  test(
    'sessiz yenilemede yükleme ekranına geçmeden listeyi günceller',
    () async {
      when(
        () => usecase(const NoParams()),
      ).thenAnswer((_) async => Right([purchase]));
      final cubit = PurchaseHistoryCubit(getVerifiedPurchasesUsecase: usecase);
      addTearDown(cubit.close);
      final emittedStates = <PurchaseHistoryState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await cubit.refreshPurchasesSilently();
      await Future<void>.delayed(Duration.zero);

      expect(emittedStates, [
        PurchaseHistoryLoaded([purchase]),
      ]);
      expect(emittedStates.whereType<PurchaseHistoryLoading>(), isEmpty);
    },
  );

  test(
    'sessiz yenileme hatasında mevcut alışverişleri ekranda korur',
    () async {
      var requestCount = 0;
      when(() => usecase(const NoParams())).thenAnswer((_) async {
        requestCount++;
        if (requestCount == 1) return Right([purchase]);
        return const Left('Geçici bağlantı sorunu.');
      });
      final cubit = PurchaseHistoryCubit(getVerifiedPurchasesUsecase: usecase);
      addTearDown(cubit.close);

      await cubit.loadPurchases();
      final emittedStates = <PurchaseHistoryState>[];
      final subscription = cubit.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await cubit.refreshPurchasesSilently();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, PurchaseHistoryLoaded([purchase]));
      expect(emittedStates, isEmpty);
    },
  );
}
