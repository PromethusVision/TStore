import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/usecases/add_shop_product_to_cart_v2_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_active_cart_items_v2_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CartV2Cubit extends Cubit<CartV2State> {
  final GetActiveCartItemsV2Usecase getActiveCartItemsV2Usecase;
  final AddShopProductToCartV2Usecase addShopProductToCartV2Usecase;

  CartV2Cubit(
    this.getActiveCartItemsV2Usecase,
    this.addShopProductToCartV2Usecase,
  ) : super(CartV2Initial());

  Future<void> getActiveCartItems() async {
    emit(CartV2Loading());

    final result = await getActiveCartItemsV2Usecase(const NoParams());

    result.fold(
      (error) => emit(CartV2Error(error)),
      (items) => emit(CartV2Loaded(items)),
    );
  }

  Future<void> addShopProductToCart({
    required String shopProductId,
    required int quantity,
  }) async {
    final result = await addShopProductToCartV2Usecase(
      AddShopProductToCartV2Params(
        shopProductId: shopProductId,
        quantity: quantity,
      ),
    );

    await result.fold(
      (error) async => emit(CartV2Error(error)),
      (addResult) async {
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
      },
    );
  }
}
