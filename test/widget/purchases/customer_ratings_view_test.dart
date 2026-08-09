import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/customer_ratings_view.dart';

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

void main() {
  late MockPurchaseHistoryCubit cubit;

  setUp(() {
    cubit = MockPurchaseHistoryCubit();
    when(() => cubit.loadPurchases()).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  VerifiedPurchaseEntity purchase({
    required String id,
    required String shopName,
    required DateTime confirmedAt,
    int? rating,
    DateTime? ratedAt,
  }) {
    return VerifiedPurchaseEntity(
      id: id,
      sourceQrSessionId: 'session-$id',
      shopId: 'shop-$id',
      shopName: shopName,
      itemCount: 2,
      totalAmount: 150.5,
      confirmedAt: confirmedAt,
      items: const [],
      customerRating: rating,
      customerRatedAt: ratedAt,
    );
  }

  testWidgets(
    'gerçek puanları en yeni değerlendirme üstte olacak şekilde gösterir',
    (tester) async {
      final older = purchase(
        id: 'older',
        shopName: 'Eski Değerlendirme',
        confirmedAt: DateTime.utc(2026, 7, 10, 10),
        rating: 3,
        ratedAt: DateTime.utc(2026, 7, 11, 10),
      );
      final newer = purchase(
        id: 'newer',
        shopName: 'Yeni Değerlendirme',
        confirmedAt: DateTime.utc(2026, 7, 14, 10),
        rating: 5,
        ratedAt: DateTime.utc(2026, 7, 16, 10),
      );
      final unrated = purchase(
        id: 'unrated',
        shopName: 'Puanlanmamış Mağaza',
        confirmedAt: DateTime.utc(2026, 7, 15, 10),
      );
      whenListen(
        cubit,
        const Stream<PurchaseHistoryState>.empty(),
        initialState: PurchaseHistoryLoaded([older, unrated, newer]),
      );

      await tester.pumpWidget(
        MaterialApp(home: CustomerRatingsView(purchaseHistoryCubit: cubit)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-ratings-content')), findsOneWidget);
      expect(find.byKey(const Key('customer-ratings-header')), findsOneWidget);
      expect(find.byKey(const Key('customer-ratings-list')), findsOneWidget);
      expect(find.text('Değerlendirmelerim'), findsOneWidget);
      expect(find.text('Yeni Değerlendirme'), findsOneWidget);
      expect(find.text('Eski Değerlendirme'), findsOneWidget);
      expect(find.text('Puanlanmamış Mağaza'), findsNothing);
      expect(find.byKey(const Key('customer-rating-newer')), findsOneWidget);
      expect(find.byKey(const Key('customer-rating-older')), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
      expect(find.text('3/5'), findsOneWidget);
      expect(find.text('2 ürün • 150,50 TL'), findsNWidgets(2));
      expect(
        tester.getTopLeft(find.text('Yeni Değerlendirme')).dy,
        lessThan(tester.getTopLeft(find.text('Eski Değerlendirme')).dy),
      );
    },
  );

  testWidgets('puan yoksa açıklama ve alışveriş bağlantısı gösterir', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryLoaded([]),
    );

    await tester.pumpWidget(
      MaterialApp(home: CustomerRatingsView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-ratings-state')), findsOneWidget);
    expect(find.text('Henüz değerlendirme yapmadınız'), findsOneWidget);
    expect(find.text('Alışverişlerime Git'), findsOneWidget);
  });

  testWidgets(
    'alışveriş bağlantısını çift dokunmada bir kez açar ve dönüşte yeniden kullanır',
    (tester) async {
      whenListen(
        cubit,
        const Stream<PurchaseHistoryState>.empty(),
        initialState: const PurchaseHistoryLoaded([]),
      );
      var destinationBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: CustomerRatingsView(
            purchaseHistoryCubit: cubit,
            purchasesDestinationBuilder: (destinationContext) {
              destinationBuildCount++;
              return Scaffold(
                body: TextButton(
                  key: const Key('ratings-purchases-destination-back'),
                  onPressed: () => Navigator.of(destinationContext).pop(),
                  child: const Text('Geri dön'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final action = tester.widget<OutlinedButton>(
        find.byKey(const Key('customer-ratings-state-action')),
      );
      action.onPressed?.call();
      action.onPressed?.call();
      await tester.pumpAndSettle();

      expect(destinationBuildCount, 1);
      expect(
        find.byKey(const Key('ratings-purchases-destination-back')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('ratings-purchases-destination-back')),
      );
      await tester.pumpAndSettle();

      final reopenedAction = tester.widget<OutlinedButton>(
        find.byKey(const Key('customer-ratings-state-action')),
      );
      expect(reopenedAction.onPressed, isNotNull);
      reopenedAction.onPressed?.call();
      await tester.pumpAndSettle();

      expect(destinationBuildCount, 2);
    },
  );

  testWidgets('yüklenirken markalı bekleme durumunu gösterir', (tester) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoading(),
    );

    await tester.pumpWidget(
      MaterialApp(home: CustomerRatingsView(purchaseHistoryCubit: cubit)),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('customer-ratings-loading-state')),
      findsOneWidget,
    );
    expect(find.text('Değerlendirmelerin yükleniyor'), findsOneWidget);
  });

  testWidgets('hata durumunda yeniden deneme seçeneğini gösterir', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryError('Bağlantını kontrol et.'),
    );

    await tester.pumpWidget(
      MaterialApp(home: CustomerRatingsView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    clearInteractions(cubit);

    expect(find.byKey(const Key('customer-ratings-state')), findsOneWidget);
    expect(find.text('Değerlendirmelerin yüklenemedi'), findsOneWidget);
    expect(find.text('Bağlantını kontrol et.'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => cubit.loadPurchases()).called(1);
  });

  testWidgets('dar ekranda taşma olmadan değerlendirmeyi gösterir', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 720);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final ratedPurchase = purchase(
      id: 'responsive',
      shopName: 'Mahalle Esnafı ve Uzun Mağaza Adı',
      confirmedAt: DateTime.utc(2026, 7, 18, 10),
      rating: 4,
      ratedAt: DateTime.utc(2026, 7, 19, 10),
    );
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([ratedPurchase]),
    );

    await tester.pumpWidget(
      MaterialApp(home: CustomerRatingsView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-rating-responsive')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
