import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/usecases/add_shop_product_to_cart_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/cancel_active_cart_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_active_cart_items_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/remove_cart_item_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/replace_active_cart_with_shop_product_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/update_cart_item_quantity_v2_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CartV2Cubit extends Cubit<CartV2State> {
  final GetActiveCartItemsV2Usecase getActiveCartItemsV2Usecase;
  final AddShopProductToCartV2Usecase addShopProductToCartV2Usecase;
  final ReplaceActiveCartWithShopProductV2Usecase
  replaceActiveCartWithShopProductV2Usecase;
  final UpdateCartItemQuantityV2Usecase updateCartItemQuantityV2Usecase;
  final RemoveCartItemV2Usecase removeCartItemV2Usecase;
  final CancelActiveCartV2Usecase cancelActiveCartV2Usecase;
  int _dataGeneration = 0;

  CartV2Cubit(
    this.getActiveCartItemsV2Usecase,
    this.addShopProductToCartV2Usecase,
    this.replaceActiveCartWithShopProductV2Usecase,
    this.updateCartItemQuantityV2Usecase,
    this.removeCartItemV2Usecase,
    this.cancelActiveCartV2Usecase,
  ) : super(CartV2Initial());

  Future<void> getActiveCartItems() async {
    final dataGeneration = _dataGeneration;
    emit(CartV2Loading());

    final result = await getActiveCartItemsV2Usecase(const NoParams());
    if (!_canApply(dataGeneration)) return;

    result.fold(
      (error) => emit(CartV2Error(error)),
      (items) => emit(CartV2Loaded(items)),
    );
  }

  Future<void> addShopProductToCart({
    required String shopProductId,
    required int quantity,
  }) async {
    final dataGeneration = _dataGeneration;
    final result = await addShopProductToCartV2Usecase(
      AddShopProductToCartV2Params(
        shopProductId: shopProductId,
        quantity: quantity,
      ),
    );
    if (!_canApply(dataGeneration)) return;

    await result.fold((error) async => emit(CartV2Error(error)), (
      addResult,
    ) async {
      if (addResult is CartV2AddSuccess) {
        emit(
          CartV2ItemAdded(
            cartId: addResult.cartId,
            shopId: addResult.shopId,
            shopProductId: addResult.shopProductId,
            quantity: addResult.quantity,
          ),
        );
        await getActiveCartItems();
        return;
      }

      if (addResult is CartV2ShopConflict) {
        emit(CartV2ShopConflictState(addResult));
        return;
      }

      emit(const CartV2Error('Beklenmeyen sepet sonucu'));
    });
  }

  Future<void> replaceActiveCartWithShopProduct({
    required String shopProductId,
    required int quantity,
  }) async {
    final dataGeneration = _dataGeneration;
    final result = await replaceActiveCartWithShopProductV2Usecase(
      ReplaceActiveCartWithShopProductV2Params(
        shopProductId: shopProductId,
        quantity: quantity,
      ),
    );
    if (!_canApply(dataGeneration)) return;

    await result.fold((error) async => emit(CartV2Error(error)), (
      replaceResult,
    ) async {
      if (replaceResult is CartV2AddSuccess) {
        emit(
          CartV2ItemAdded(
            cartId: replaceResult.cartId,
            shopId: replaceResult.shopId,
            shopProductId: replaceResult.shopProductId,
            quantity: replaceResult.quantity,
          ),
        );
        await getActiveCartItems();
        return;
      }

      if (replaceResult is CartV2ShopConflict) {
        emit(CartV2ShopConflictState(replaceResult));
        return;
      }

      emit(const CartV2Error('Beklenmeyen sepet sonucu'));
    });
  }

  Future<void> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final dataGeneration = _dataGeneration;
    final result = await updateCartItemQuantityV2Usecase(
      UpdateCartItemQuantityV2Params(
        cartItemId: cartItemId,
        quantity: quantity,
      ),
    );
    if (!_canApply(dataGeneration)) return;

    await result.fold(
      (error) async => emit(CartV2Error(error)),
      (_) async => getActiveCartItems(),
    );
  }

  Future<void> incrementItemQuantity(CartItemV2Entity item) async {
    await updateItemQuantity(cartItemId: item.id, quantity: item.quantity + 1);
  }

  Future<void> decrementItemQuantity(CartItemV2Entity item) async {
    if (item.quantity <= 1) {
      emit(const CartV2Error('Adet 1 veya daha buyuk olmali'));
      return;
    }

    await updateItemQuantity(cartItemId: item.id, quantity: item.quantity - 1);
  }

  Future<void> removeItem(String cartItemId) async {
    final dataGeneration = _dataGeneration;
    final result = await removeCartItemV2Usecase(
      RemoveCartItemV2Params(cartItemId: cartItemId),
    );
    if (!_canApply(dataGeneration)) return;

    await result.fold(
      (error) async => emit(CartV2Error(error)),
      (_) async => getActiveCartItems(),
    );
  }

  Future<void> cancelActiveCart() async {
    final dataGeneration = _dataGeneration;
    final result = await cancelActiveCartV2Usecase(const NoParams());
    if (!_canApply(dataGeneration)) return;

    await result.fold(
      (error) async => emit(CartV2Error(error)),
      (_) async => getActiveCartItems(),
    );
  }

  void clearLocalCart() {
    _dataGeneration += 1;
    emit(const CartV2Loaded([]));
  }

  bool _canApply(int dataGeneration) {
    return !isClosed && dataGeneration == _dataGeneration;
  }
}
