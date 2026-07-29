import 'dart:async';

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
    when(() => cubit.refreshPurchasesSilently()).thenAnswer((_) async {});
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

  testWidgets('bildirimdeki alışverişi listenin başında belirginleştirir', (
    tester,
  ) async {
    final targetedPurchase = VerifiedPurchaseEntity(
      id: 'purchase-2',
      sourceQrSessionId: 'session-2',
      shopId: 'shop-2',
      shopName: 'Semt Kırtasiyesi',
      itemCount: 1,
      totalAmount: 45,
      confirmedAt: DateTime.utc(2026, 7, 16, 11),
      items: const [
        VerifiedPurchaseItemEntity(
          id: 'item-2',
          shopProductId: 'shop-product-2',
          productName: 'Defter',
          quantity: 1,
          unitPrice: 45,
          lineTotal: 45,
        ),
      ],
    );
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([purchase, targetedPurchase]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialPurchaseId: 'purchase-2',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('highlighted-purchase-purchase-2')),
      findsOneWidget,
    );
    expect(
      find.text('Bildirimdeki alışveriş: Semt Kırtasiyesi'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('missing-notification-purchase-message')),
      findsNothing,
    );
  });

  testWidgets(
    'QR ile yeni onaylanan alışverişi oturum kimliğiyle öne çıkarır',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PurchasesView(
            purchaseHistoryCubit: cubit,
            initialQrSessionId: 'session-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('highlighted-purchase-purchase-1')),
        findsOneWidget,
      );
      expect(
        find.text('Az önce onaylanan alışveriş: Mahalle Marketi'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('missing-notification-purchase-message')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'QR alışverişi henüz yoksa doğru açıklamayı ve yeniden kontrolü gösterir',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PurchasesView(
            purchaseHistoryCubit: cubit,
            initialQrSessionId: 'missing-session',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('missing-recent-qr-purchase-message')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Az önce onaylanan alışveriş kontrol ediliyor.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('automatic-purchase-check-progress')),
        findsOneWidget,
      );
      expect(find.text('Yeniden kontrol et'), findsOneWidget);
      expect(
        find.byKey(const Key('missing-notification-purchase-message')),
        findsNothing,
      );
      expect(find.text('Mahalle Marketi'), findsOneWidget);
    },
  );

  testWidgets('boş listede de QR alışverişi için kurtarma seçeneğini korur', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryLoaded([]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialQrSessionId: 'missing-session',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('missing-recent-qr-purchase-message')),
      findsOneWidget,
    );
    expect(find.text('Henüz doğrulanmış alışverişin yok'), findsNothing);
  });

  testWidgets(
    'eksik QR alışverişini kısa süre sonra otomatik yenileyip öne çıkarır',
    (tester) async {
      final stateController = StreamController<PurchaseHistoryState>();
      addTearDown(stateController.close);
      final recentPurchase = VerifiedPurchaseEntity(
        id: 'purchase-automatic',
        sourceQrSessionId: 'session-automatic',
        shopId: 'shop-2',
        shopName: 'Semt Kırtasiyesi',
        itemCount: 1,
        totalAmount: 45,
        confirmedAt: DateTime.utc(2026, 7, 29, 10),
        items: const [
          VerifiedPurchaseItemEntity(
            id: 'item-automatic',
            shopProductId: 'shop-product-2',
            productName: 'Defter',
            quantity: 1,
            unitPrice: 45,
            lineTotal: 45,
          ),
        ],
      );
      whenListen(
        cubit,
        stateController.stream,
        initialState: PurchaseHistoryLoaded([purchase]),
      );
      when(() => cubit.refreshPurchasesSilently()).thenAnswer((_) async {
        stateController.add(PurchaseHistoryLoaded([purchase, recentPurchase]));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: PurchasesView(
            purchaseHistoryCubit: cubit,
            initialQrSessionId: 'session-automatic',
          ),
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      verify(() => cubit.refreshPurchasesSilently()).called(1);
      expect(
        find.byKey(const Key('highlighted-purchase-purchase-automatic')),
        findsOneWidget,
      );
      expect(
        find.text('Az önce onaylanan alışveriş: Semt Kırtasiyesi'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('missing-recent-qr-purchase-message')),
        findsNothing,
      );
    },
  );

  testWidgets('eksik QR alışverişini en fazla üç kez otomatik kontrol eder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialQrSessionId: 'missing-session',
        ),
      ),
    );
    await tester.pump();

    for (var attempt = 0; attempt < 4; attempt++) {
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    }

    verify(() => cubit.refreshPurchasesSilently()).called(3);
    expect(
      find.byKey(const Key('missing-recent-qr-purchase-message')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Alışveriş kaydı henüz görünmüyor.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('automatic-purchase-check-progress')),
      findsNothing,
    );
    expect(find.text('Yeniden kontrol et'), findsOneWidget);
  });

  testWidgets('bildirim hedefi için otomatik kontrol başlatmaz', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialPurchaseId: 'missing-purchase',
        ),
      ),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 8));
    await tester.pump();

    verifyNever(() => cubit.refreshPurchasesSilently());
    expect(
      find.byKey(const Key('missing-notification-purchase-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('automatic-purchase-check-progress')),
      findsNothing,
    );
  });

  testWidgets('ekran kapanınca bekleyen otomatik kontrolü iptal eder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialQrSessionId: 'missing-session',
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 3));

    verifyNever(() => cubit.refreshPurchasesSilently());
  });

  testWidgets('yeniden kontrolde gelen QR alışverişini otomatik öne çıkarır', (
    tester,
  ) async {
    final stateController = StreamController<PurchaseHistoryState>();
    addTearDown(stateController.close);
    final recentPurchase = VerifiedPurchaseEntity(
      id: 'purchase-recent',
      sourceQrSessionId: 'session-recent',
      shopId: 'shop-2',
      shopName: 'Semt Kırtasiyesi',
      itemCount: 1,
      totalAmount: 45,
      confirmedAt: DateTime.utc(2026, 7, 29, 10),
      items: const [
        VerifiedPurchaseItemEntity(
          id: 'item-recent',
          shopProductId: 'shop-product-2',
          productName: 'Defter',
          quantity: 1,
          unitPrice: 45,
          lineTotal: 45,
        ),
      ],
    );
    var loadCount = 0;
    whenListen(
      cubit,
      stateController.stream,
      initialState: PurchaseHistoryLoaded([purchase]),
    );
    when(() => cubit.loadPurchases()).thenAnswer((_) async {
      loadCount++;
      if (loadCount != 2) return;
      stateController.add(PurchaseHistoryLoaded([purchase, recentPurchase]));
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialQrSessionId: 'session-recent',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('retry-recent-qr-purchase-action')));
    await tester.pumpAndSettle();

    expect(loadCount, 2);
    expect(
      find.byKey(const Key('highlighted-purchase-purchase-recent')),
      findsOneWidget,
    );
    expect(
      find.text('Az önce onaylanan alışveriş: Semt Kırtasiyesi'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('missing-recent-qr-purchase-message')),
      findsNothing,
    );
  });

  testWidgets('bulunamayan bildirim alışverişinde diğer kayıtları korur', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          initialPurchaseId: 'missing-purchase',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('missing-notification-purchase-message')),
      findsOneWidget,
    );
    expect(find.text('Mahalle Marketi'), findsOneWidget);
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
