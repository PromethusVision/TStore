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
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), icons.load()]);
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

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<CartV2Cubit>.value(
        value: cart,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          home: const RepaintBoundary(
            key: Key('evidence'),
            child: CartV2View(visualPrototype: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('evidence')));
    await tester.runAsync(
      () => Future.wait([
        precacheImage(const AssetImage(_shirtImage), context),
        precacheImage(const AssetImage(_slippersImage), context),
      ]),
    );
    await tester.pumpAndSettle();
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
  test('presentation stays default off', () {
    expect(const CartV2View().visualPrototype, isFalse);
  });
}
