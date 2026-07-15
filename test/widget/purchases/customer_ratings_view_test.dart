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

      expect(find.text('Değerlendirmelerim'), findsOneWidget);
      expect(find.text('Yeni Değerlendirme'), findsOneWidget);
      expect(find.text('Eski Değerlendirme'), findsOneWidget);
      expect(find.text('Puanlanmamış Mağaza'), findsNothing);
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

    expect(find.text('Henüz değerlendirme yapmadınız'), findsOneWidget);
    expect(find.text('Alışverişlerime Git'), findsOneWidget);
  });
}
