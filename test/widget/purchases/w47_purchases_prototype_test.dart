import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';
import '../w47_prototype_support.dart';

class _History extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

class _Rating extends MockCubit<ShopRatingState> implements ShopRatingCubit {}

class _GetShop extends Mock implements GetShopByIdUsecase {}

final _purchases = [
  VerifiedPurchaseEntity(
    id: 'fixture-purchase-1',
    sourceQrSessionId: 'fixture-qr-1',
    shopId: 'fixture-shop-1',
    shopName: 'Mahalle Giyim',
    itemCount: 3,
    totalAmount: 1019.70,
    confirmedAt: DateTime(2026, 9, 4, 14, 30),
    items: const [
      VerifiedPurchaseItemEntity(
        id: 'fixture-item-1',
        shopProductId: 'fixture-listing-1',
        productName: 'Günlük pamuklu tişört',
        quantity: 2,
        unitPrice: 399.90,
        lineTotal: 799.80,
      ),
      VerifiedPurchaseItemEntity(
        id: 'fixture-item-2',
        shopProductId: 'fixture-listing-2',
        productName: 'Rahat ev terliği',
        quantity: 1,
        unitPrice: 219.90,
        lineTotal: 219.90,
      ),
    ],
  ),
  VerifiedPurchaseEntity(
    id: 'fixture-purchase-2',
    sourceQrSessionId: 'fixture-qr-2',
    shopId: 'fixture-shop-2',
    shopName: 'Çınar Teknoloji',
    itemCount: 1,
    totalAmount: 1499.90,
    confirmedAt: DateTime(2026, 9, 2, 11, 15),
    customerRating: 5,
    items: const [
      VerifiedPurchaseItemEntity(
        id: 'fixture-item-3',
        shopProductId: 'fixture-listing-3',
        productName: 'Kablosuz kulaklık',
        quantity: 1,
        unitPrice: 1499.90,
        lineTotal: 1499.90,
      ),
    ],
  ),
];

void main() {
  late _History history;
  late _GetShop getShop;
  late _Rating rating;
  setUpAll(loadW47Fonts);
  setUp(() async {
    await sl.reset();
    history = _History();
    getShop = _GetShop();
    rating = _Rating();
    whenListen(
      history,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded(_purchases),
    );
    when(() => history.loadPurchases()).thenAnswer((_) async {});
    when(() => history.close()).thenAnswer((_) async {});
    when(() => getShop(any())).thenAnswer(
      (_) async =>
          const Right(ShopEntity(id: 'fixture-shop-1', name: 'Mahalle Giyim')),
    );
    whenListen(
      rating,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingInitial(),
    );
    when(() => rating.close()).thenAnswer((_) async {});
    sl.registerFactory<ShopRatingCubit>(() => rating);
  });
  tearDown(() async => sl.reset());

  Widget view({bool prototype = true, String? target}) => PurchasesView(
    visualPrototype: prototype,
    purchaseHistoryCubit: history,
    getShopByIdUsecase: getShop,
    initialPurchaseId: target,
    shopProfileBuilder: (shop) => Scaffold(body: Text('Mağaza: ${shop.id}')),
  );
  Future<void> pump(
    WidgetTester tester, {
    bool prototype = true,
    String? target,
  }) async {
    setW47Viewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: RepaintBoundary(
          key: const Key('evidence'),
          child: view(prototype: prototype, target: target),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final prototype in [false, true]) {
    testWidgets('390 px ${prototype ? 'prototype' : 'before'} evidence', (
      tester,
    ) async {
      await pump(tester, prototype: prototype);
      expect(find.text('Mahalle Giyim'), findsOneWidget);
      if (prototype) {
        expect(find.text('Mağazada doğrulandı'), findsNWidgets(2));
        expect(
          find.byKey(const Key('purchase-shop-rating-open-action')),
          findsOneWidget,
        );
      }
      for (final text in [
        'Sipariş numarası',
        'Kargo',
        'Teslim edildi',
        'Ödeme',
      ]) {
        expect(find.textContaining(text), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('evidence')),
        matchesGoldenFile(
          'goldens/w47_${prototype ? 'purchases' : 'before_purchases'}_390.png',
        ),
      );
    });
  }
  testWidgets('shop handoff preserves purchase shop identifier', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(
      find.byKey(const Key('purchase-shop-profile-open-fixture-purchase-1')),
    );
    await tester.pumpAndSettle();
    verify(() => getShop('fixture-shop-1')).called(1);
    expect(find.text('Mağaza: fixture-shop-1'), findsOneWidget);
  });
  testWidgets('only unrated purchase opens the existing shop-rating sheet', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('purchase-shop-rating-open-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('purchase-shop-rating-sheet')), findsOneWidget);
    expect(find.text('Mahalle Giyim'), findsWidgets);
    await tester.tap(
      find.byKey(const Key('purchase-shop-rating-close-action')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('purchase-shop-rating-open-action')),
      findsOneWidget,
    );
    expect(find.text('Puanın 5/5'), findsOneWidget);
  });
  testWidgets('targeted purchase still moves to the top', (tester) async {
    await pump(tester, target: 'fixture-purchase-2');
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('customer-purchase-card-fixture-purchase-2')),
          )
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(
                const Key('customer-purchase-card-fixture-purchase-1'),
              ),
            )
            .dy,
      ),
    );
  });
  testWidgets('back and existing return placeholders preserve navigation', (
    tester,
  ) async {
    setW47Viewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => view())),
              child: const Text('Geçmişi aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Geçmişi aç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İade Talebi Oluştur'));
    await tester.pumpAndSettle();
    expect(find.text('İade talebi oluşturma hazırlanıyor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('customer-purchases-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Geçmişi aç'), findsOneWidget);
  });
  test('owner presentation remains default off', () {
    expect(const PurchasesView().visualPrototype, isFalse);
  });
}
