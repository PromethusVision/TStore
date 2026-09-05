import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
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
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

class MockShopRatingCubit extends MockCubit<ShopRatingState>
    implements ShopRatingCubit {}

class MockGetShopByIdUsecase extends Mock implements GetShopByIdUsecase {}

void main() {
  const shop = ShopEntity(
    id: 'shop-1',
    name: 'Mahalle Marketi',
    address: 'Esenler, İstanbul',
  );

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
  late MockGetShopByIdUsecase getShopByIdUsecase;
  late int shopRatingCubitResolveCount;

  setUp(() async {
    await sl.reset();
    cubit = MockPurchaseHistoryCubit();
    shopRatingCubit = MockShopRatingCubit();
    getShopByIdUsecase = MockGetShopByIdUsecase();
    shopRatingCubitResolveCount = 0;
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
    when(
      () => getShopByIdUsecase(any()),
    ).thenAnswer((_) async => const Right(shop));

    sl.registerFactory<ShopRatingCubit>(() {
      shopRatingCubitResolveCount++;
      return shopRatingCubit;
    });
    sl.registerLazySingleton<GetShopByIdUsecase>(() => getShopByIdUsecase);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
    'gerçek alışveriş özetini, iki sekme ve ayrı iade eylemini gösterir',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('customer-purchases-content')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-purchases-header')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-purchases-tab-bar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-purchase-card-purchase-1')),
        findsOneWidget,
      );
      expect(find.text('Alışverişlerim'), findsNWidgets(2));
      expect(find.text('İade Taleplerim'), findsOneWidget);
      expect(find.text('İade Talebi Oluştur'), findsOneWidget);
      expect(find.text('Mahalle Marketi'), findsOneWidget);
      expect(find.text('Deneme Ürünü'), findsOneWidget);
      expect(find.text('Alışveriş tutarı'), findsOneWidget);
      expect(find.text('150,50 TL'), findsNWidgets(2));
      expect(find.text('Mağazada doğrulandı'), findsOneWidget);
      expect(tester.widget<TabBar>(find.byType(TabBar)).tabs, hasLength(2));
      expect(
        find.byKey(const Key('purchase-create-return-action')),
        findsOneWidget,
      );
      expect(find.text('Mağazayı Gör'), findsOneWidget);
      expect(find.text('Esnafa Puan Ver'), findsOneWidget);
    },
  );

  testWidgets('yükleniyor durumunu müşteri kabuğunda gösterir', (tester) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoading(),
    );
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('customer-purchases-loading-state')),
      findsOneWidget,
    );
  });

  testWidgets('hata durumunda yeniden deneme sunar', (tester) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryError(
        'Alışverişlerin şu anda yüklenemedi.',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer-purchases-state')), findsOneWidget);
    expect(find.text('Alışverişlerin yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar Dene'), findsOneWidget);
  });

  testWidgets('boş alışveriş durumunu müşteri kabuğunda gösterir', (
    tester,
  ) async {
    whenListen(
      cubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: const PurchaseHistoryLoaded([]),
    );
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer-purchases-state')), findsOneWidget);
    expect(find.text('Henüz doğrulanmış alışverişin yok'), findsOneWidget);
  });

  testWidgets('320 piksel genişlikte taşma yapmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-purchase-card-purchase-1')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const Key('purchase-shop-rating-open-action')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('mağazayı gör bağlantısı doğru mağaza profilini açar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          shopProfileBuilder: (selectedShop) =>
              Scaffold(body: Text('Profil: ${selectedShop.name}')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('purchase-shop-profile-open-purchase-1')),
    );
    await tester.pumpAndSettle();

    verify(() => getShopByIdUsecase('shop-1')).called(1);
    expect(find.text('Profil: Mahalle Marketi'), findsOneWidget);
  });

  testWidgets('mağaza yüklenirken art arda dokunmayı engeller', (tester) async {
    final completer = Completer<Either<String, ShopEntity?>>();
    when(() => getShopByIdUsecase(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      MaterialApp(
        home: PurchasesView(
          purchaseHistoryCubit: cubit,
          shopProfileBuilder: (_) =>
              const Scaffold(body: Text('Mağaza profili')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(
      const Key('purchase-shop-profile-open-purchase-1'),
    );
    await tester.tap(action);
    await tester.pump();
    await tester.tap(action);
    await tester.pump();

    verify(() => getShopByIdUsecase('shop-1')).called(1);
    expect(find.text('Açılıyor…'), findsOneWidget);

    completer.complete(const Right(shop));
    await tester.pump();
  });

  testWidgets('görüntülenemeyen mağaza için anlaşılır uyarı gösterir', (
    tester,
  ) async {
    when(
      () => getShopByIdUsecase(any()),
    ).thenAnswer((_) async => const Right(null));

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('purchase-shop-profile-open-purchase-1')),
    );
    await tester.pump();

    expect(find.text('Bu mağaza şu anda görüntülenemiyor.'), findsOneWidget);
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

    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsOneWidget);
    expect(find.byKey(const Key('purchase-rating-header')), findsOneWidget);
    expect(find.byKey(const Key('purchase-rating-stars-card')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('purchase-shop-rating-submit-action')),
          )
          .onPressed,
      isNull,
    );

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

  testWidgets('puan penceresini çift dokunmada bir kez açar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();

    final ratingAction = tester.widget<FilledButton>(
      find.byKey(const Key('purchase-shop-rating-open-action')),
    );
    ratingAction.onPressed?.call();
    ratingAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsOneWidget);
    expect(shopRatingCubitResolveCount, 1);

    await tester.tap(
      find.byKey(const Key('purchase-shop-rating-close-action')),
    );
    await tester.pumpAndSettle();

    final reopenedRatingAction = tester.widget<FilledButton>(
      find.byKey(const Key('purchase-shop-rating-open-action')),
    );
    expect(reopenedRatingAction.onPressed, isNotNull);
    reopenedRatingAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsOneWidget);
    expect(shopRatingCubitResolveCount, 2);
  });

  testWidgets('puanlama hatasını güvenli biçimde gösterir', (tester) async {
    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: const ShopRatingFailure('Puan şu anda gönderilemedi.'),
    );

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchase-rating-error')), findsOneWidget);
    expect(find.text('Puan şu anda gönderilemedi.'), findsOneWidget);
    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsOneWidget);
  });

  testWidgets('puan gönderilirken ikinci işlem ve kapatmayı engeller', (
    tester,
  ) async {
    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingSubmitting(),
    );

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pump();

    expect(find.byKey(const Key('purchase-rating-progress')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('purchase-shop-rating-submit-action')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('purchase-shop-rating-close-action')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const Key('purchase-shop-rating-cancel-action')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('puan penceresini göndermeden kapatır', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('purchase-shop-rating-close-action')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsNothing);
    verifyNever(
      () => shopRatingCubit.submitRating(
        qrSessionId: any(named: 'qrSessionId'),
        rating: any(named: 'rating'),
      ),
    );
  });

  testWidgets('puan penceresi 320 piksel genişlikte taşma yapmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(home: PurchasesView(purchaseHistoryCubit: cubit)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('purchase-shop-rating-cancel-action')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('purchase-rating-header')), findsOneWidget);
    expect(tester.takeException(), isNull);
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

    expect(find.text('Puanın 5/5'), findsOneWidget);
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

    expect(
      find.byKey(const Key('purchase-rating-success-content')),
      findsOneWidget,
    );
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
    await tester.tap(find.text('Alışverişlerimi Gör'));
    await tester.pumpAndSettle();
    expect(find.text('İade talebi oluşturma hazırlanıyor'), findsNothing);
    expect(
      find.byKey(const Key('customer-purchase-card-purchase-1')),
      findsOneWidget,
    );
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller, isNull);
    final tabContext = tester.element(find.byType(TabBar));
    expect(DefaultTabController.of(tabContext).index, 0);
  });
}
