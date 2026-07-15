import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

void main() {
  final purchase = VerifiedPurchaseEntity(
    id: 'purchase-1',
    sourceQrSessionId: 'session-1',
    shopId: 'shop-1',
    shopName: 'Mahalle Marketi',
    itemCount: 2,
    totalAmount: 150.5,
    confirmedAt: DateTime.utc(2026, 7, 15, 10, 30),
    items: [
      VerifiedPurchaseItemEntity(
        id: 'item-1',
        shopProductId: 'shop-product-1',
        productName: 'Deneme Ürünü',
        quantity: 2,
        unitPrice: 75.25,
        lineTotal: 150.5,
      ),
    ],
  );

  late MockPurchaseHistoryCubit cubit;

  setUp(() {
    cubit = MockPurchaseHistoryCubit();
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([purchase]),
    );
    when(() => cubit.loadPurchases()).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  testWidgets('gerçek alışveriş özetini ve üç sekmeyi gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alışverişlerim'), findsNWidgets(2));
    expect(find.text('İade Taleplerim'), findsOneWidget);
    expect(find.text('İade Talebi Oluştur'), findsOneWidget);
    expect(find.text('Mahalle Marketi'), findsOneWidget);
    expect(find.text('Deneme Ürünü'), findsOneWidget);
    expect(find.text('Toplam: 150,50 TL'), findsOneWidget);
    expect(find.text('Onaylandı'), findsOneWidget);
  });

  testWidgets('iade sekmeleri güvenli hazırlık bilgisi gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('İade Taleplerim'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz iade talebin yok'), findsOneWidget);

    await tester.tap(find.text('İade Talebi Oluştur'));
    await tester.pumpAndSettle();
    expect(find.text('İade talebi oluşturma hazırlanıyor'), findsOneWidget);
    expect(find.text('Alışverişlerimi Gör'), findsOneWidget);
  });
}
