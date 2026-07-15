import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/reviews/domain/entities/shop_rating_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

class MockShopRatingCubit extends MockCubit<ShopRatingState>
    implements ShopRatingCubit {}

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
  late MockShopRatingCubit shopRatingCubit;

  setUp(() async {
    await sl.reset();
    cubit = MockPurchaseHistoryCubit();
    shopRatingCubit = MockShopRatingCubit();
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([purchase]),
    );
    when(() => cubit.loadPurchases()).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});

    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingInitial(),
    );
    when(
      () => shopRatingCubit.submitRating(
        qrSessionId: any(named: 'qrSessionId'),
        rating: any(named: 'rating'),
      ),
    ).thenAnswer((_) async {});
    when(() => shopRatingCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<ShopRatingCubit>(() => shopRatingCubit);
  });

  tearDown(() async {
    await sl.reset();
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
    expect(find.text('Esnafa Puan Ver'), findsOneWidget);
  });

  testWidgets('puan seçimini doğrulanmış alışveriş kimliğiyle gönderir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('purchase-shop-rating-star-4')));
    await tester.pump();

    expect(find.text('İyi'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('purchase-shop-rating-submit-action')),
    );
    await tester.pump();

    verify(
      () => shopRatingCubit.submitRating(qrSessionId: 'session-1', rating: 4),
    ).called(1);
  });

  testWidgets('puanlanmış alışverişte puanı gösterir ve bağlantıyı gizler', (
    tester,
  ) async {
    final ratedPurchase = VerifiedPurchaseEntity(
      id: 'purchase-1',
      sourceQrSessionId: 'session-1',
      shopId: 'shop-1',
      shopName: 'Mahalle Marketi',
      itemCount: 2,
      totalAmount: 150.5,
      confirmedAt: DateTime.utc(2026, 7, 15, 10, 30),
      items: purchase.items,
      customerRating: 5,
    );
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([ratedPurchase]),
    );

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(find.text('5/5 puan verdiniz'), findsOneWidget);
    expect(
      find.byKey(const Key('purchase-shop-rating-open-action')),
      findsNothing,
    );
  });

  testWidgets('başarılı puan sonrasında alışveriş kartını yeniler', (
    tester,
  ) async {
    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: const ShopRatingSuccess(
        ShopRatingEntity(
          id: 'rating-1',
          shopId: 'shop-1',
          rating: 4,
          averageRating: 4.5,
          ratingCount: 10,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    verify(() => cubit.loadPurchases()).called(1);

    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();

    expect(find.text('Puanınız kaydedildi'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('purchase-shop-rating-success-close')),
    );
    await tester.pumpAndSettle();

    verify(() => cubit.loadPurchases()).called(1);
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
