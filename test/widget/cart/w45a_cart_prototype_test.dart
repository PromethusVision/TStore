import 'dart:async';
import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';

class _Cart extends MockCubit<CartV2State> implements CartV2Cubit {}

class _Qr extends MockCubit<QrSessionState> implements QrSessionCubit {}

const _shop = ShopEntity(
  id: 'fixture-shop',
  name: 'Mahalle Giyim',
  address: 'Caferağa Mahallesi, Kadıköy',
);
const _shirtImage = 'assets/images/products/product-shirt.png';
const _slippersImage = 'assets/images/products/product-slippers.png';
const _shirt = CartItemV2Entity(
  id: 'fixture-shirt',
  cartId: 'fixture-cart',
  shopProductId: 'fixture-shirt-listing',
  quantity: 2,
  shopProduct: ShopProductEntity(
    id: 'fixture-shirt-listing',
    shopId: 'fixture-shop',
    productId: 'fixture-product-shirt',
    price: 399.90,
    shop: _shop,
    product: ProductEntity(
      id: 'fixture-product-shirt',
      name: 'Günlük pamuklu tişört',
      price: 399.90,
      categoryId: 'fixture-category',
      stock: 8,
      images: [_shirtImage],
    ),
  ),
);
const _slippers = CartItemV2Entity(
  id: 'fixture-slippers',
  cartId: 'fixture-cart',
  shopProductId: 'fixture-slippers-listing',
  quantity: 1,
  shopProduct: ShopProductEntity(
    id: 'fixture-slippers-listing',
    shopId: 'fixture-shop',
    productId: 'fixture-product-slippers',
    price: 219.90,
    shop: _shop,
    product: ProductEntity(
      id: 'fixture-product-slippers',
      name: 'Rahat ev terliği',
      price: 219.90,
      categoryId: 'fixture-category',
      stock: 3,
      images: [_slippersImage],
    ),
  ),
);

void main() {
  late _Cart cart;
  late _Qr qr;
  setUpAll(() async {
    final poppins = FontLoader('Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      poppins.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
      ..addFont(
        rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
      );
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), icons.load(), iconsax.load()]);
  });
  setUp(() async {
    await sl.reset();
    cart = _Cart();
    qr = _Qr();
    whenListen(
      cart,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([_shirt, _slippers]),
    );
    when(() => cart.getActiveCartItems()).thenAnswer((_) async {});
    when(() => cart.incrementItemQuantity(_shirt)).thenAnswer((_) async {});
    when(() => cart.decrementItemQuantity(_shirt)).thenAnswer((_) async {});
    when(() => cart.removeItem(any())).thenAnswer((_) async {});
    when(() => cart.cancelActiveCart()).thenAnswer((_) async {});
    whenListen(
      qr,
      const Stream<QrSessionState>.empty(),
      initialState: const QrSessionFailure('Test durumu'),
    );
    when(() => qr.createQrSession(any())).thenAnswer((_) async {});
    when(() => qr.close()).thenAnswer((_) async {});
    sl.registerFactory<QrSessionCubit>(() => qr);
  });
  tearDown(() async => sl.reset());

  Future<void> pump(
    WidgetTester tester, {
    double width = 390,
    double textScale = 1,
    bool settle = true,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<CartV2Cubit>.value(
        value: cart,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const RepaintBoundary(
            key: Key('evidence'),
            child: CartV2View(),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 200));
    }
    final context = tester.element(find.byKey(const Key('evidence')));
    await tester.runAsync(
      () => Future.wait([
        precacheImage(const AssetImage(_shirtImage), context),
        precacheImage(const AssetImage(_slippersImage), context),
      ]),
    );
    if (settle) await tester.pumpAndSettle();
  }

  testWidgets('390 px physical preparation owner evidence', (tester) async {
    await pump(tester);
    expect(find.text('Sepet'), findsOneWidget);
    expect(
      find.text('Mağazadan almak için\nhazırladığın ürünler'),
      findsOneWidget,
    );
    expect(find.text(_shop.name), findsOneWidget);
    expect(find.text('1.019,70 TL'), findsOneWidget);
    expect(find.text('QR kod oluştur'), findsOneWidget);
    expect(find.text('Mağazada göster'), findsNothing);
    for (final word in ['Ödeme', 'Sipariş', 'Kargo', 'Teslimat']) {
      expect(find.textContaining(word), findsNothing);
    }
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('evidence')),
      matchesGoldenFile('../shop/goldens/w45a_cart_v2_390.png'),
    );
  });
  testWidgets('quantity and removal keep exact item with confirmation', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Artır').first);
    await tester.pumpAndSettle();
    verify(() => cart.incrementItemQuantity(_shirt)).called(1);
    await tester.tap(find.byTooltip('Azalt').first);
    await tester.pumpAndSettle();
    verify(() => cart.decrementItemQuantity(_shirt)).called(1);
    await tester.tap(
      find.byKey(const Key('customer-cart-item-fixture-shirt-remove')),
    );
    await tester.pumpAndSettle();
    verifyNever(() => cart.removeItem(any()));
    await tester.tap(find.widgetWithText(TextButton, 'Kaldır'));
    await tester.pumpAndSettle();
    verify(() => cart.removeItem(_shirt.id)).called(1);
  });
  testWidgets('pending quantity action blocks repeat mutation', (tester) async {
    final pending = Completer<void>();
    when(
      () => cart.incrementItemQuantity(_shirt),
    ).thenAnswer((_) => pending.future);
    await pump(tester);
    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add).first,
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pump();
    verify(() => cart.incrementItemQuantity(_shirt)).called(1);
    pending.complete();
    await tester.pumpAndSettle();
  });
  testWidgets('QR kod oluştur refreshes and opens existing QR for exact cart', (
    tester,
  ) async {
    await pump(tester);
    final button = find.byKey(const Key('customer-cart-verify-button'));
    expect(
      find.descendant(of: button, matching: find.text('QR kod oluştur')),
      findsOneWidget,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    verify(() => cart.getActiveCartItems()).called(2);
    verify(() => qr.createQrSession(_shirt.cartId)).called(1);
    final sheet = tester.widget<CartQrSessionBottomSheet>(
      find.byType(CartQrSessionBottomSheet),
    );
    expect(sheet.itemCount, 3);
    expect(sheet.totalAmount, closeTo(1019.70, 0.001));
    expect(sheet.shopName, _shop.name);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('clear retains confirmation', (tester) async {
    await pump(tester);
    final clear = find.byKey(const Key('cart-prototype-clear'));
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(find.text('Mağaza sepetini boşalt'), findsOneWidget);
    verifyNever(() => cart.cancelActiveCart());
    await tester.tap(find.widgetWithText(TextButton, 'Vazgeç'));
    await tester.pumpAndSettle();
  });
  test(
    'Final UI is default and explicit legacy comparison remains available',
    () {
      expect(const CartV2View().visualPrototype, isTrue);
      expect(const CartV2View(visualPrototype: false).visualPrototype, isFalse);
    },
  );

  Future<void> evidence(WidgetTester tester, String name) => expectLater(
    find.byKey(const Key('evidence')),
    matchesGoldenFile('../shop/goldens/w45a_r2_cart_$name.png'),
  );

  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('loaded ${width.toInt()} scale $scale with exact QR CTA', (
        tester,
      ) async {
        await pump(tester, width: width, textScale: scale);
        expect(tester.takeException(), isNull);
        await evidence(
          tester,
          'loaded_${width.toInt()}_scale_${(scale * 100).round()}',
        );
        final qrButton = find.byKey(const Key('customer-cart-verify-button'));
        await tester.scrollUntilVisible(
          qrButton.hitTestable(),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(
          find.descendant(of: qrButton, matching: find.text('QR kod oluştur')),
          findsOneWidget,
        );
        expect(tester.widget<OutlinedButton>(qrButton).onPressed, isNotNull);
        expect(find.text('Mağazada göster'), findsNothing);
        expect(tester.takeException(), isNull);
        if (width == 320 && scale == 1.3) {
          await evidence(tester, 'qr_320_scale_130');
        }
      });

      testWidgets(
        'large quantity, price and long product ${width.toInt()} scale $scale',
        (tester) async {
          final item = _shirt.copyWith(
            quantity: 99999,
            shopProduct: _shirt.shopProduct!.copyWith(
              price: 9999999.99,
              shop: _shop.copyWith(
                name: 'Mahalle Giyim ve Ev Tekstili Uzun Mağaza Adı',
                address:
                    'Örnek Mahallesi Uzun Çarşı Caddesi Deneme İş Merkezi, Kadıköy / İstanbul',
              ),
              product: _shirt.shopProduct!.product!.copyWith(
                name:
                    'Uzun ürün adı: günlük pamuklu tişört ve mevsimlik giyim aksesuar seti',
              ),
            ),
          );
          when(() => cart.state).thenReturn(CartV2Loaded([item]));
          await pump(tester, width: width, textScale: scale);
          expect(find.text('99999'), findsOneWidget);
          expect(find.text('999.989.999.000,01 TL'), findsWidgets);
          final quantityText = tester.renderObject<RenderBox>(
            find.text('99999'),
          );
          expect(quantityText.size.width, greaterThan(24));
          expect(tester.takeException(), isNull);
          await evidence(
            tester,
            'stress_${width.toInt()}_scale_${(scale * 100).round()}',
          );
          await tester.scrollUntilVisible(
            find.text('QR kod oluştur').hitTestable(),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final scenario in ['empty', 'initial', 'loading', 'error']) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('$scenario ${width.toInt()} scale 1.3', (tester) async {
        final CartV2State state = switch (scenario) {
          'empty' => const CartV2Loaded([]),
          'initial' => CartV2Initial(),
          'loading' => CartV2Loading(),
          _ => const CartV2Error('Bağlantı kurulamadı. Lütfen tekrar dene.'),
        };
        when(() => cart.state).thenReturn(state);
        await pump(
          tester,
          width: width,
          textScale: 1.3,
          settle: scenario != 'initial' && scenario != 'loading',
        );
        expect(find.text('QR kod oluştur'), findsNothing);
        expect(tester.takeException(), isNull);
        if (width == 390) await evidence(tester, '${scenario}_390_scale_130');
        if (scenario == 'empty') {
          expect(find.text('Henüz mağaza sepetinde ürün yok'), findsOneWidget);
        }
        if (scenario == 'error') {
          await tester.tap(find.byKey(const Key('customer-cart-retry-button')));
          await tester.pump();
          verify(() => cart.getActiveCartItems()).called(2);
        }
      });
    }
  }

  testWidgets('one item cannot decrement below one', (tester) async {
    when(() => cart.state).thenReturn(const CartV2Loaded([_slippers]));
    await pump(tester);
    expect(find.text('1 ürün · 1 adet'), findsOneWidget);
    final decrease = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove),
    );
    expect(decrease.onPressed, isNull);
    await evidence(tester, 'one_item_390');
  });

  testWidgets('many items can reach exact last remove and QR', (tester) async {
    final items = List.generate(
      24,
      (index) => _shirt.copyWith(id: 'fixture-item-$index'),
    );
    when(() => cart.state).thenReturn(CartV2Loaded(items));
    await pump(tester, width: 320, textScale: 1.3);
    final lastRemove = find.byKey(
      const Key('customer-cart-item-fixture-item-23-remove'),
    );
    await tester.scrollUntilVisible(
      lastRemove.hitTestable(),
      400,
      maxScrolls: 40,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(lastRemove);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Kaldır'));
    await tester.pumpAndSettle();
    verify(() => cart.removeItem('fixture-item-23')).called(1);
    await tester.scrollUntilVisible(
      find.text('QR kod oluştur').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('QR kod oluştur').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear confirm empties cart and prevents double clear', (
    tester,
  ) async {
    final states = StreamController<CartV2State>();
    whenListen(cart, states.stream, initialState: const CartV2Loaded([_shirt]));
    final pending = Completer<void>();
    when(() => cart.cancelActiveCart()).thenAnswer((_) => pending.future);
    await pump(tester, width: 320, textScale: 1.3);
    final clear = find.byKey(const Key('cart-prototype-clear'));
    await tester.scrollUntilVisible(
      clear.hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(clear);
    await tester.pumpAndSettle();
    final confirm = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Sepeti boşalt').last,
    );
    confirm.onPressed!();
    confirm.onPressed!();
    await tester.pumpAndSettle();
    verify(() => cart.cancelActiveCart()).called(1);
    expect(find.text('Boşaltılıyor…'), findsOneWidget);
    states.add(const CartV2Loaded([]));
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer-cart-empty-state')), findsOneWidget);
    expect(find.text('QR kod oluştur'), findsNothing);
    await states.close();
  });

  testWidgets(
    'QR double tap keeps one refresh and restores exact CTA on failure',
    (tester) async {
      await pump(tester);
      final pending = Completer<void>();
      when(() => cart.getActiveCartItems()).thenAnswer((_) => pending.future);
      final qrFinder = find.byKey(const Key('customer-cart-verify-button'));
      await tester.scrollUntilVisible(
        qrFinder.hitTestable(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final action = tester.widget<OutlinedButton>(qrFinder).onPressed!;
      action();
      action();
      await tester.pump();
      expect(find.text('Hazırlanıyor…'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(qrFinder).onPressed, isNull);
      verify(() => cart.getActiveCartItems()).called(2);
      when(
        () => cart.state,
      ).thenReturn(const CartV2Error('Bağlantı kurulamadı'));
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('QR kod oluştur'), findsOneWidget);
      verifyNever(() => qr.createQrSession(any()));
    },
  );

  testWidgets('mutation error keeps loaded items visible', (tester) async {
    final states = StreamController<CartV2State>();
    whenListen(cart, states.stream, initialState: const CartV2Loaded([_shirt]));
    await pump(tester);
    states.add(const CartV2Error('Bağlantı kurulamadı'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(_shirt.shopProduct!.product!.name), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byKey(const Key('customer-cart-error-state')), findsNothing);
    await states.close();
  });

  testWidgets('unavailable item preserves refresh, removal and QR block', (
    tester,
  ) async {
    final unavailable = _shirt.copyWith(
      shopProduct: _shirt.shopProduct!.copyWith(
        isAvailable: false,
        product: _shirt.shopProduct!.product!.copyWith(images: const []),
      ),
    );
    when(() => cart.state).thenReturn(CartV2Loaded([unavailable]));
    await pump(tester, width: 320, textScale: 1.3);
    expect(
      find.text('Bu ürün artık bu mağazada satışta değil.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Artır'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.add))
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
    await evidence(tester, 'unavailable_320_scale_130');
    await tester.scrollUntilVisible(
      find.text('QR kod oluştur').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('QR kod oluştur'));
    await tester.pumpAndSettle();
    verifyNever(() => qr.createQrSession(any()));
    expect(find.textContaining('Sepetteki ürünlerden biri'), findsOneWidget);
  });

  testWidgets('44 px targets and accessible labels remain usable', (
    tester,
  ) async {
    await pump(tester, width: 320, textScale: 1.3);
    final semantics = tester.ensureSemantics();
    await tester.pump();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    semantics.dispose();
  });
}
