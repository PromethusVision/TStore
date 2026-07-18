import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/usecases/add_shop_product_to_cart_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/cancel_active_cart_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_active_cart_items_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/remove_cart_item_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/replace_active_cart_with_shop_product_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/update_cart_item_quantity_v2_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class MockGetActiveCartItemsV2Usecase extends Mock
    implements GetActiveCartItemsV2Usecase {}

class MockAddShopProductToCartV2Usecase extends Mock
    implements AddShopProductToCartV2Usecase {}

class MockReplaceActiveCartWithShopProductV2Usecase extends Mock
    implements ReplaceActiveCartWithShopProductV2Usecase {}

class MockUpdateCartItemQuantityV2Usecase extends Mock
    implements UpdateCartItemQuantityV2Usecase {}

class MockRemoveCartItemV2Usecase extends Mock
    implements RemoveCartItemV2Usecase {}

class MockCancelActiveCartV2Usecase extends Mock
    implements CancelActiveCartV2Usecase {}

class FakeNoParams extends Fake implements NoParams {}

class FakeAddShopProductToCartV2Params extends Fake
    implements AddShopProductToCartV2Params {}

void main() {
  late MockGetActiveCartItemsV2Usecase getActiveCartItemsUsecase;
  late MockAddShopProductToCartV2Usecase addShopProductUsecase;
  late MockReplaceActiveCartWithShopProductV2Usecase replaceCartUsecase;
  late MockUpdateCartItemQuantityV2Usecase updateQuantityUsecase;
  late MockRemoveCartItemV2Usecase removeCartItemUsecase;
  late MockCancelActiveCartV2Usecase cancelActiveCartUsecase;
  late CartV2Cubit cartCubit;

  const oldCartItem = CartItemV2Entity(
    id: 'old-item',
    cartId: 'old-cart',
    shopProductId: 'old-shop-product',
    quantity: 2,
  );

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeAddShopProductToCartV2Params());
  });

  setUp(() {
    getActiveCartItemsUsecase = MockGetActiveCartItemsV2Usecase();
    addShopProductUsecase = MockAddShopProductToCartV2Usecase();
    replaceCartUsecase = MockReplaceActiveCartWithShopProductV2Usecase();
    updateQuantityUsecase = MockUpdateCartItemQuantityV2Usecase();
    removeCartItemUsecase = MockRemoveCartItemV2Usecase();
    cancelActiveCartUsecase = MockCancelActiveCartV2Usecase();

    cartCubit = CartV2Cubit(
      getActiveCartItemsUsecase,
      addShopProductUsecase,
      replaceCartUsecase,
      updateQuantityUsecase,
      removeCartItemUsecase,
      cancelActiveCartUsecase,
    );
  });

  tearDown(() => cartCubit.close());

  test(
    'ignores an old cart load after local customer data is cleared',
    () async {
      final result = Completer<Either<String, List<CartItemV2Entity>>>();
      when(
        () => getActiveCartItemsUsecase(any()),
      ).thenAnswer((_) => result.future);

      final loadRequest = cartCubit.getActiveCartItems();
      cartCubit.clearLocalCart();
      result.complete(const Right([oldCartItem]));
      await loadRequest;

      expect(cartCubit.state, const CartV2Loaded([]));
    },
  );

  test(
    'ignores an old cart mutation after local customer data is cleared',
    () async {
      final result = Completer<Either<String, CartV2AddResult>>();
      when(() => addShopProductUsecase(any())).thenAnswer((_) => result.future);

      final addRequest = cartCubit.addShopProductToCart(
        shopProductId: 'old-shop-product',
        quantity: 1,
      );
      cartCubit.clearLocalCart();
      result.complete(
        const Right(
          CartV2AddSuccess(
            cartId: 'old-cart',
            shopId: 'old-shop',
            shopProductId: 'old-shop-product',
            quantity: 1,
          ),
        ),
      );
      await addRequest;

      expect(cartCubit.state, const CartV2Loaded([]));
      verifyNever(() => getActiveCartItemsUsecase(any()));
    },
  );
}
