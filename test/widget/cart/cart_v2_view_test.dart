import '../w48/w48_fixture.dart';
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockQrSessionCubit extends MockCubit<QrSessionState>
    implements QrSessionCubit {}

class MockShopRatingCubit extends MockCubit<ShopRatingState>
    implements ShopRatingCubit {}

class MockPurchaseHistoryCubit extends MockCubit<PurchaseHistoryState>
    implements PurchaseHistoryCubit {}

Future<void> revealCartAction(WidgetTester tester, Finder action) async {
  await tester.scrollUntilVisible(
    action,
    200,
    scrollable: find.descendant(
      of: find.byKey(const Key('customer-cart-items-list')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pump();
}

void main() {
  late MockCartV2Cubit cartV2Cubit;
  late MockQrSessionCubit qrSessionCubit;
  late MockShopRatingCubit shopRatingCubit;
  late MockPurchaseHistoryCubit purchaseHistoryCubit;

  const cartItem = CartItemV2Entity(
    id: 'item-1',
    cartId: 'cart-1',
    shopProductId: 'shop-product-1',
    quantity: 2,
    shopProduct: ShopProductEntity(
      id: 'shop-product-1',
      shopId: 'shop-1',
      productId: 'product-1',
      price: 125,
      shop: ShopEntity(
        id: 'shop-1',
        name: 'Mahalle Mağazası',
        address: 'İstanbul',
      ),
      product: ProductEntity(
        id: 'product-1',
        name: 'Test Ürünü',
        price: 125,
        categoryId: 'category-1',
        stock: 5,
        images: [],
      ),
    ),
  );

  const inactiveCartItem = CartItemV2Entity(
    id: 'item-inactive',
    cartId: 'cart-1',
    shopProductId: 'shop-product-inactive',
    quantity: 2,
    shopProduct: ShopProductEntity(
      id: 'shop-product-inactive',
      shopId: 'shop-1',
      productId: 'product-1',
      price: 125,
      shop: ShopEntity(id: 'shop-1', name: 'Kapalı Mağaza', isActive: false),
      product: ProductEntity(
        id: 'product-1',
        name: 'Test Ürünü',
        price: 125,
        categoryId: 'category-1',
        stock: 5,
        images: [],
      ),
    ),
  );

  final verifiedPurchase = VerifiedPurchaseEntity(
    id: 'purchase-1',
    sourceQrSessionId: 'session-1',
    shopId: 'shop-1',
    shopName: 'Mahalle Mağazası',
    itemCount: 2,
    totalAmount: 250,
    confirmedAt: DateTime.utc(2026, 7, 28, 10),
    items: const [
      VerifiedPurchaseItemEntity(
        id: 'verified-item-1',
        shopProductId: 'shop-product-1',
        productName: 'Test Ürünü',
        quantity: 2,
        unitPrice: 125,
        lineTotal: 250,
      ),
    ],
  );

  setUp(() async {
    await sl.reset();

    cartV2Cubit = MockCartV2Cubit();
    qrSessionCubit = MockQrSessionCubit();
    shopRatingCubit = MockShopRatingCubit();
    purchaseHistoryCubit = MockPurchaseHistoryCubit();

    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([cartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {});
    when(
      () => cartV2Cubit.getActiveCartItems(showLoading: false),
    ).thenAnswer((_) async {});
    when(() => cartV2Cubit.cancelActiveCart()).thenAnswer((_) async {});
    when(() => cartV2Cubit.removeItem(any())).thenAnswer((_) async {});
    when(
      () => cartV2Cubit.incrementItemQuantity(cartItem),
    ).thenAnswer((_) async {});
    when(
      () => cartV2Cubit.decrementItemQuantity(cartItem),
    ).thenAnswer((_) async {});

    whenListen(
      qrSessionCubit,
      const Stream<QrSessionState>.empty(),
      initialState: const QrSessionCompleted(sessionId: 'session-1'),
    );
    when(() => qrSessionCubit.createQrSession(any())).thenAnswer((_) async {});
    when(() => qrSessionCubit.close()).thenAnswer((_) async {});

    whenListen(
      shopRatingCubit,
      const Stream<ShopRatingState>.empty(),
      initialState: ShopRatingInitial(),
    );
    when(() => shopRatingCubit.close()).thenAnswer((_) async {});

    whenListen(
      purchaseHistoryCubit,
      const Stream<PurchaseHistoryState>.empty(),
      initialState: PurchaseHistoryLoaded([verifiedPurchase]),
    );
    when(() => purchaseHistoryCubit.loadPurchases()).thenAnswer((_) async {});
    when(() => purchaseHistoryCubit.close()).thenAnswer((_) async {});

    sl.registerFactory<QrSessionCubit>(() => qrSessionCubit);
    sl.registerFactory<ShopRatingCubit>(() => shopRatingCubit);
    sl.registerFactory<PurchaseHistoryCubit>(() => purchaseHistoryCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  setUpAll(w48Fonts);
  for (final width in [320.0, 390.0, 430.0]) {
    for (final action in ['remove', 'clear', 'refresh']) {
      testWidgets('W48 cart $action modal $width 130% keyboard', (
        tester,
      ) async {
        w48Viewport(tester, width);
        final fixture = W48Fixture();
        final changes = StreamController<CartV2State>.broadcast();
        addTearDown(changes.close);
        var loads = 0;
        if (action == 'refresh') {
          whenListen(
            cartV2Cubit,
            changes.stream,
            initialState: const CartV2Loaded([cartItem]),
          );
          when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {
            if (++loads == 2) {
              final updated = CartV2Loaded([
                cartItem.copyWith(
                  shopProduct: cartItem.shopProduct!.copyWith(price: 140),
                ),
              ]);
              when(() => cartV2Cubit.state).thenReturn(updated);
              changes.add(updated);
              await Future<void>.delayed(Duration.zero);
            }
          });
        }
        await tester.pumpWidget(
          fixture.host(
            BlocProvider<CartV2Cubit>.value(
              value: cartV2Cubit,
              child: const CartV2View(),
            ),
            keyboard: 280,
          ),
        );
        await tester.pumpAndSettle();
        final trigger = switch (action) {
          'remove' => find.byKey(const Key('customer-cart-item-item-1-remove')),
          'clear' => find.byKey(const Key('cart-prototype-clear')),
          _ => find.text('QR kod oluştur'),
        };
        await revealCartAction(tester, trigger);
        await tester.tap(trigger);
        // QR preparation stays pending while the customer reviews new totals.
        if (action == 'refresh') {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        } else {
          await tester.pumpAndSettle();
        }
        expect(find.byType(AlertDialog), findsOneWidget);
        await w48Accessibility(tester);
        if (width == 320 && action == 'remove') {
          await expectLater(
            find.byKey(const Key('w48-proof')),
            matchesGoldenFile(
              '../w48/goldens/w48_cart_remove_320_keyboard.png',
            ),
          );
        }
        if (width == 390 && action == 'refresh') {
          await expectLater(
            find.byKey(const Key('w48-proof')),
            matchesGoldenFile(
              '../w48/goldens/w48_cart_refresh_390_keyboard.png',
            ),
          );
        }
        verifyNever(() => qrSessionCubit.createQrSession(any()));
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
        verifyNever(() => cartV2Cubit.removeItem(any()));
        verifyNever(() => cartV2Cubit.cancelActiveCart());
      });
    }
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('W48 actual Cart to QR sheet $width 130%', (tester) async {
      w48Viewport(tester, width);
      final fixture = W48Fixture();
      whenListen(
        qrSessionCubit,
        const Stream<QrSessionState>.empty(),
        initialState: QrSessionCreated(w48Session(count: null, total: 250)),
      );
      await tester.pumpWidget(
        fixture.host(
          BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await revealCartAction(tester, find.text('QR kod oluştur'));
      await tester.tap(find.text('QR kod oluştur'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('QR bilgileri doğrulanamadı'), findsOneWidget);
      expect(
        find.byKey(const Key('purchase-verification-qr-code')),
        findsNothing,
      );
      verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
      await w48Accessibility(tester, within: find.byType(BottomSheet));
      if (width == 390) {
        await expectLater(
          find.byKey(const Key('w48-proof')),
          matchesGoldenFile('../w48/goldens/w48_actual_cart_qr_390_130.png'),
        );
      }
      await tester.tap(
        find.byKey(const Key('qr-invalid-snapshot-back-action')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
      verify(() => cartV2Cubit.getActiveCartItems()).called(3);
    });
  }

  testWidgets('boş sepet müşteriye nasıl ürün ekleyeceğini anlatır', (
    tester,
  ) async {
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(visualPrototype: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-cart-header')), findsOneWidget);
    expect(find.text('Sepetim'), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-empty-state')), findsOneWidget);
    expect(find.text('Henüz mağaza sepetinde ürün yok'), findsOneWidget);
    expect(
      find.text(
        'Ürün detayından bir mağaza seçip sepete eklediğinde '
        'ürünlerin burada görünecek.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('satın alınabilir ürünlerde normal sepet toplamını gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(visualPrototype: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-items-list')), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-item-item-1')), findsOneWidget);
    expect(
      find.byKey(const Key('customer-cart-product-thumbnail')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-cart-verification-panel')),
      findsOneWidget,
    );
    expect(find.text('Mahalle Mağazası'), findsOneWidget);
    expect(find.text('Test Ürünü'), findsOneWidget);
    expect(find.text('Sepet Toplamı'), findsOneWidget);
    expect(find.text('Alışverişi doğrula'), findsOneWidget);
    expect(find.text('Ödeme'), findsNothing);
    expect(find.text('Kargo'), findsNothing);
    expect(find.text('Siparişi tamamla'), findsNothing);
    expect(find.text('Toplam güncellenmeli'), findsNothing);
  });

  testWidgets('dar müşteri ekranında taşmadan kaydırılabilir', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(visualPrototype: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-cart-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-items-list')), findsOneWidget);
    expect(
      find.byKey(const Key('customer-cart-verification-panel')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('yükleme ve hata durumlarını müşteri tasarımıyla gösterir', (
    tester,
  ) async {
    final stateController = StreamController<CartV2State>();
    addTearDown(stateController.close);
    whenListen(
      cartV2Cubit,
      stateController.stream,
      initialState: CartV2Loading(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('customer-cart-loading-state')),
      findsOneWidget,
    );
    expect(find.text('Sepetin hazırlanıyor'), findsOneWidget);

    stateController.add(const CartV2Error('Bağlantı kurulamadı.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('customer-cart-error-state')), findsOneWidget);
    expect(find.text('Sepet bilgileri yüklenemedi'), findsOneWidget);
    expect(find.text('Bağlantı kurulamadı.'), findsWidgets);

    await tester.tap(find.byKey(const Key('customer-cart-retry-button')));
    await tester.pump();

    verify(() => cartV2Cubit.getActiveCartItems()).called(2);
  });

  testWidgets('QR penceresi kapanınca aktif sepeti yeniden yükler', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(tester, find.text('QR kod oluştur'));
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Alışveriş onaylandı'), findsOneWidget);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    verify(() => cartV2Cubit.getActiveCartItems()).called(3);
  });

  testWidgets(
    'onaylanan alışverişi sepet yenilendikten sonra geçmişte öne çıkarır',
    (tester) async {
      var loadCount = 0;
      final postVerificationRefresh = Completer<void>();
      when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) {
        loadCount++;
        if (loadCount == 3) return postVerificationRefresh.future;
        return Future<void>.value();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await revealCartAction(tester, find.text('QR kod oluştur'));
      await tester.tap(find.text('QR kod oluştur'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text('Alışverişlerimde gör'));
      await tester.tap(find.text('Alışverişlerimde gör'));
      await tester.pump();

      expect(loadCount, 3);
      expect(
        find.text('Az önce onaylanan alışveriş: Mahalle Mağazası'),
        findsNothing,
      );

      postVerificationRefresh.complete();
      await tester.pumpAndSettle();

      expect(
        find.text('Az önce onaylanan alışveriş: Mahalle Mağazası'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('highlighted-purchase-purchase-1')),
        findsOneWidget,
      );
      verify(() => purchaseHistoryCubit.loadPurchases()).called(1);
      verify(() => cartV2Cubit.getActiveCartItems()).called(3);
    },
  );

  testWidgets('fiyat değişince onay almadan QR açmaz', (tester) async {
    final stateController = StreamController<CartV2State>();
    addTearDown(stateController.close);
    final repricedItem = cartItem.copyWith(
      shopProduct: cartItem.shopProduct!.copyWith(price: 140),
    );
    var loadCount = 0;

    whenListen(
      cartV2Cubit,
      stateController.stream,
      initialState: const CartV2Loaded([cartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {
      loadCount++;
      if (loadCount != 2) return;

      when(() => cartV2Cubit.state).thenReturn(CartV2Loaded([repricedItem]));
      stateController.add(CartV2Loaded([repricedItem]));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(tester, find.text('QR kod oluştur'));
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sepet tutarı güncellendi'), findsOneWidget);
    expect(find.text('Önceki toplam'), findsOneWidget);
    expect(find.text('₺250.00'), findsOneWidget);
    expect(find.text('Güncel toplam'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('₺280.00'),
      ),
      findsOneWidget,
    );
    expect(find.text('Güncel tutarla devam et'), findsOneWidget);
    verifyNever(() => qrSessionCubit.createQrSession(any()));

    final continueAction = tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Güncel tutarla devam et'),
        )
        .onPressed!;
    continueAction();
    continueAction();
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş onaylandı'), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });

  testWidgets('güncel tutar reddedilince doğrulamayı durdurur', (tester) async {
    final stateController = StreamController<CartV2State>();
    addTearDown(stateController.close);
    final repricedItem = cartItem.copyWith(
      shopProduct: cartItem.shopProduct!.copyWith(price: 140),
    );
    var loadCount = 0;

    whenListen(
      cartV2Cubit,
      stateController.stream,
      initialState: const CartV2Loaded([cartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {
      loadCount++;
      if (loadCount != 2) return;

      when(() => cartV2Cubit.state).thenReturn(CartV2Loaded([repricedItem]));
      stateController.add(CartV2Loaded([repricedItem]));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(tester, find.text('QR kod oluştur'));
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final cancelAction = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Vazgeç'))
        .onPressed!;
    cancelAction();
    cancelAction();
    await tester.pumpAndSettle();

    expect(find.text('Sepet tutarı güncellendi'), findsNothing);
    expect(find.text('QR kod oluştur'), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
    verifyNever(() => qrSessionCubit.createQrSession(any()));
  });

  testWidgets('sepet boşaltma metinlerini ve onayını doğru gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(
      tester,
      find.byKey(const Key('cart-prototype-clear')),
    );
    expect(find.byKey(const Key('cart-prototype-clear')), findsOneWidget);
    expect(find.text('Mağaza Sepetini İptal Et'), findsNothing);

    await revealCartAction(
      tester,
      find.byKey(const Key('cart-prototype-clear')),
    );
    await tester.tap(find.byKey(const Key('cart-prototype-clear')));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza sepetini boşalt'), findsOneWidget);
    expect(find.text('Vazgeç'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Sepeti boşalt'),
      ),
      findsOneWidget,
    );
    expect(find.text('İptal Et'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Sepeti boşalt'),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => cartV2Cubit.cancelActiveCart()).called(1);
  });

  testWidgets(
    'sepet boşaltma penceresi hızlı dokunmada yalnız bir kez kapanır',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await revealCartAction(
        tester,
        find.byKey(const Key('cart-prototype-clear')),
      );
      await tester.tap(find.byKey(const Key('cart-prototype-clear')));
      await tester.pumpAndSettle();

      final cancelAction = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Vazgeç'))
          .onPressed!;
      cancelAction();
      cancelAction();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
      verifyNever(() => cartV2Cubit.cancelActiveCart());

      await revealCartAction(
        tester,
        find.byKey(const Key('cart-prototype-clear')),
      );
      await tester.tap(find.byKey(const Key('cart-prototype-clear')));
      await tester.pumpAndSettle();

      final confirmAction = tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.widgetWithText(FilledButton, 'Sepeti boşalt'),
            ),
          )
          .onPressed!;
      confirmAction();
      confirmAction();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
      verify(() => cartV2Cubit.cancelActiveCart()).called(1);
    },
  );

  testWidgets(
    'adet güncellenirken geri bildirim gösterir ve tekrar dokunmayı engeller',
    (tester) async {
      final updateRequest = Completer<void>();
      when(
        () => cartV2Cubit.incrementItemQuantity(cartItem),
      ).thenAnswer((_) => updateRequest.future);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final incrementButton = find.widgetWithIcon(IconButton, Icons.add);
      await tester.tap(incrementButton);
      await tester.tap(incrementButton);
      await tester.pump();

      expect(find.text('Güncelleniyor…'), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.add), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.remove), findsNothing);
      verify(() => cartV2Cubit.incrementItemQuantity(cartItem)).called(1);

      updateRequest.complete();
      await tester.pumpAndSettle();

      expect(find.text('Güncelleniyor…'), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.add), findsOneWidget);
    },
  );

  testWidgets('ürün kaldırılırken işlem durumunu gösterir', (tester) async {
    final removeRequest = Completer<void>();
    when(
      () => cartV2Cubit.removeItem('item-1'),
    ).thenAnswer((_) => removeRequest.future);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final removeButton = find.byKey(
      const Key('customer-cart-item-item-1-remove'),
    );
    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaldır'));
    await tester.pump();

    expect(find.text('Kaldırılıyor…'), findsOneWidget);
    expect(tester.widget<IconButton>(removeButton).onPressed, isNull);
    verify(() => cartV2Cubit.removeItem('item-1')).called(1);

    removeRequest.complete();
    await tester.pumpAndSettle();

    expect(find.text('Kaldırılıyor…'), findsNothing);
    expect(removeButton, findsOneWidget);
  });

  testWidgets(
    'ürün kaldırma penceresi hızlı dokunmada yalnız bir kez kapanır',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final removeButton = find.byKey(
        const Key('customer-cart-item-item-1-remove'),
      );
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      final cancelAction = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Vazgeç'))
          .onPressed!;
      cancelAction();
      cancelAction();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
      verifyNever(() => cartV2Cubit.removeItem(any()));

      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      final confirmAction = tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Kaldır'))
          .onPressed!;
      confirmAction();
      confirmAction();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('customer-cart-content')), findsOneWidget);
      verify(() => cartV2Cubit.removeItem('item-1')).called(1);
    },
  );

  testWidgets(
    'sepet boşaltılırken geri bildirim gösterir ve tekrarını engeller',
    (tester) async {
      final clearRequest = Completer<void>();
      when(
        () => cartV2Cubit.cancelActiveCart(),
      ).thenAnswer((_) => clearRequest.future);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await revealCartAction(
        tester,
        find.byKey(const Key('cart-prototype-clear')),
      );
      await tester.tap(find.byKey(const Key('cart-prototype-clear')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Sepeti boşalt'),
        ),
      );
      await tester.pump();

      expect(find.text('Boşaltılıyor…'), findsOneWidget);
      final clearButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Boşaltılıyor…'),
      );
      expect(clearButton.onPressed, isNull);
      verify(() => cartV2Cubit.cancelActiveCart()).called(1);

      clearRequest.complete();
      await tester.pumpAndSettle();

      expect(find.text('Boşaltılıyor…'), findsNothing);
      expect(find.byKey(const Key('cart-prototype-clear')), findsOneWidget);
    },
  );

  testWidgets('geçersiz sepet ürünü için QR oluşturmayı engeller', (
    tester,
  ) async {
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([inactiveCartItem]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(tester, find.text('QR kod oluştur'));
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('artık satışta değil veya mağaza alışverişe kapalı'),
      findsOneWidget,
    );
    verifyNever(() => qrSessionCubit.createQrSession(any()));
  });

  testWidgets('satın alınamayan ürünü açıkça işaretler ve güvenle kaldırır', (
    tester,
  ) async {
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([inactiveCartItem]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(visualPrototype: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bu mağaza şu anda alışverişe kapalı.'), findsOneWidget);
    expect(find.text('Sepetten kaldır'), findsOneWidget);
    expect(find.text('Sepet Toplamı'), findsNothing);
    expect(find.text('Toplam güncellenmeli'), findsOneWidget);
    expect(
      find.text(
        'Satın alınamayan ürünü kaldırdığınızda güncel toplam gösterilecek.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
          .onPressed,
      isNull,
    );

    await tester.ensureVisible(find.text('Sepetten kaldır'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sepetten kaldır'));
    await tester.pumpAndSettle();

    expect(find.text('Ürünü sepetten kaldır'), findsOneWidget);
    await tester.tap(find.text('Kaldır'));
    await tester.pumpAndSettle();

    verify(() => cartV2Cubit.removeItem('item-inactive')).called(1);
  });

  testWidgets('satın alınamayan ürünü sepeti kapatmadan yeniden kontrol eder', (
    tester,
  ) async {
    final refreshRequest = Completer<void>();
    when(
      () => cartV2Cubit.getActiveCartItems(showLoading: false),
    ).thenAnswer((_) => refreshRequest.future);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([inactiveCartItem]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final refreshButton = find.widgetWithText(TextButton, 'Yeniden kontrol et');
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(refreshButton);
    await tester.pump();

    expect(find.text('Kontrol ediliyor…'), findsOneWidget);
    expect(find.text('Bu mağaza şu anda alışverişe kapalı.'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Kontrol ediliyor…'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Sepetten kaldır'),
          )
          .onPressed,
      isNull,
    );

    refreshRequest.complete();
    await tester.pumpAndSettle();

    expect(find.text('Yeniden kontrol et'), findsOneWidget);
    expect(find.text('Ürün durumu henüz değişmedi.'), findsOneWidget);
    verify(() => cartV2Cubit.getActiveCartItems(showLoading: false)).called(1);
  });

  testWidgets('yeniden uygun olan ürünü normal sepete döndürür', (
    tester,
  ) async {
    final stateController = StreamController<CartV2State>();
    addTearDown(stateController.close);
    whenListen(
      cartV2Cubit,
      stateController.stream,
      initialState: const CartV2Loaded([inactiveCartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems(showLoading: false)).thenAnswer((
      _,
    ) async {
      when(() => cartV2Cubit.state).thenReturn(const CartV2Loaded([cartItem]));
      stateController.add(const CartV2Loaded([cartItem]));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Yeniden kontrol et'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Bu mağaza şu anda alışverişe kapalı.'), findsNothing);
    expect(find.text('Ürün tutarı'), findsOneWidget);
  });

  testWidgets('yenileme hatasında mevcut sepet ürününü ekranda tutar', (
    tester,
  ) async {
    final stateController = StreamController<CartV2State>();
    addTearDown(stateController.close);
    whenListen(
      cartV2Cubit,
      stateController.stream,
      initialState: const CartV2Loaded([inactiveCartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems(showLoading: false)).thenAnswer((
      _,
    ) async {
      stateController.add(const CartV2Error('Sepet yenilenemedi.'));
      await Future<void>.delayed(Duration.zero);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Yeniden kontrol et'));
    await tester.pumpAndSettle();

    expect(find.text('Bu mağaza şu anda alışverişe kapalı.'), findsOneWidget);
    expect(find.text('Sepet yenilenemedi.'), findsOneWidget);
    expect(find.text('Yeniden kontrol et'), findsOneWidget);
  });

  testWidgets('hızlı çift dokunma ikinci QR hazırlığını başlatmaz', (
    tester,
  ) async {
    var requestCount = 0;
    final verificationRequest = Completer<void>();
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) {
      requestCount++;
      if (requestCount == 1) {
        return Future<void>.value();
      }
      return verificationRequest.future;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartV2Cubit>.value(
          value: cartV2Cubit,
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await revealCartAction(tester, find.text('QR kod oluştur'));
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pump();
    expect(requestCount, 2);

    final verificationButton = find.byKey(
      const Key('customer-cart-verify-button'),
    );
    expect(verificationButton, findsOneWidget);
    await tester.tap(verificationButton);
    await tester.pump();
    expect(requestCount, 2);

    verificationRequest.complete();
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş onaylandı'), findsOneWidget);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });

  testWidgets(
    'doğrulama hazırlanırken sepet değişikliklerini engeller ve sonra yeniden açar',
    (tester) async {
      var requestCount = 0;
      final verificationRequest = Completer<void>();
      when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) {
        requestCount++;
        if (requestCount == 2) return verificationRequest.future;
        return Future<void>.value();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartV2Cubit>.value(
            value: cartV2Cubit,
            child: const CartV2View(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final incrementAction = tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
          .onPressed!;
      final removeAction = tester
          .widget<IconButton>(
            find.byKey(const Key('customer-cart-item-item-1-remove')),
          )
          .onPressed!;
      await revealCartAction(
        tester,
        find.byKey(const Key('cart-prototype-clear')),
      );
      final clearAction = tester
          .widget<TextButton>(find.byKey(const Key('cart-prototype-clear')))
          .onPressed!;

      await revealCartAction(tester, find.text('QR kod oluştur'));
      await tester.tap(find.text('QR kod oluştur'));
      await tester.pump();

      expect(find.text('Hazırlanıyor…'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('customer-cart-item-item-1-remove')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('cart-prototype-clear')))
            .onPressed,
        isNull,
      );

      incrementAction();
      removeAction();
      clearAction();
      await tester.pump();

      verifyNever(() => cartV2Cubit.incrementItemQuantity(cartItem));
      verifyNever(() => cartV2Cubit.removeItem(any()));
      verifyNever(() => cartV2Cubit.cancelActiveCart());
      expect(find.byType(AlertDialog), findsNothing);

      verificationRequest.complete();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('cart-prototype-clear')))
            .onPressed,
        isNotNull,
      );
    },
  );
}
