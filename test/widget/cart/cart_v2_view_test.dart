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

void main() {
  late MockCartV2Cubit cartV2Cubit;
  late MockQrSessionCubit qrSessionCubit;
  late MockShopRatingCubit shopRatingCubit;

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

  setUp(() async {
    await sl.reset();

    cartV2Cubit = MockCartV2Cubit();
    qrSessionCubit = MockQrSessionCubit();
    shopRatingCubit = MockShopRatingCubit();

    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: const CartV2Loaded([cartItem]),
    );
    when(() => cartV2Cubit.getActiveCartItems()).thenAnswer((_) async {});

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

    sl.registerFactory<QrSessionCubit>(() => qrSessionCubit);
    sl.registerFactory<ShopRatingCubit>(() => shopRatingCubit);
  });

  tearDown(() async {
    await sl.reset();
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

    await tester.tap(find.text('Mağazada Göster'));
    await tester.pumpAndSettle();
    expect(find.text('Alışveriş onaylandı'), findsOneWidget);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    verify(() => cartV2Cubit.getActiveCartItems()).called(2);
  });
}
