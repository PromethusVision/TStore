import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_entity.dart';

abstract class CartV2Repository {
  Future<Either<String, CartV2Entity?>> getActiveCart();

  Future<Either<String, List<CartItemV2Entity>>> getCartItems(
    String cartId,
  );

  Future<Either<String, List<CartItemV2Entity>>> getActiveCartItems();

  Future<Either<String, CartV2AddResult>> addShopProductToCart({
    required String shopProductId,
    required int quantity,
  });
}
