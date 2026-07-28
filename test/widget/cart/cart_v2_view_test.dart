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
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
          child: const CartV2View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sepet Toplamı'), findsOneWidget);
    expect(find.text('Toplam güncellenmeli'), findsNothing);
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

    await tester.tap(find.text('Alışverişi doğrula'));
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

      await tester.tap(find.text('Alışverişi doğrula'));
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

    await tester.tap(find.text('Alışverişi doğrula'));
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

    await tester.tap(find.text('Güncel tutarla devam et'));
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş onaylandı'), findsOneWidget);
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

    await tester.tap(find.text('Alışverişi doğrula'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(find.text('Sepet tutarı güncellendi'), findsNothing);
    expect(find.text('Alışverişi doğrula'), findsOneWidget);
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

    expect(find.text('Mağaza sepetini boşalt'), findsOneWidget);
    expect(find.text('Mağaza Sepetini İptal Et'), findsNothing);

    await tester.tap(find.text('Mağaza sepetini boşalt'));
    await tester.pumpAndSettle();

    expect(find.text('Mağaza sepetini boşalt'), findsNWidgets(2));
    expect(find.text('Vazgeç'), findsOneWidget);
    expect(find.text('Sepeti boşalt'), findsOneWidget);
    expect(find.text('İptal Et'), findsNothing);

    await tester.tap(find.text('Sepeti boşalt'));
    await tester.pumpAndSettle();

    verify(() => cartV2Cubit.cancelActiveCart()).called(1);
  });

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

    await tester.tap(find.text('Alışverişi doğrula'));
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
          child: const CartV2View(),
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
    expect(find.text('Sepet Toplamı'), findsOneWidget);
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

    await tester.tap(find.text('Alışverişi doğrula'));
    await tester.pump();
    expect(requestCount, 2);

    final verificationButton = find.byType(ElevatedButton);
    expect(verificationButton, findsOneWidget);
    await tester.tap(verificationButton);
    await tester.pump();
    expect(requestCount, 2);

    verificationRequest.complete();
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş onaylandı'), findsOneWidget);
    verify(() => qrSessionCubit.createQrSession('cart-1')).called(1);
  });
}
