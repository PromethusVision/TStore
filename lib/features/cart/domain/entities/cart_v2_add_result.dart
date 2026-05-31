abstract class CartV2AddResult {
  const CartV2AddResult();
}

class CartV2AddSuccess extends CartV2AddResult {
  final String cartId;
  final String shopId;
  final String shopProductId;
  final int quantity;

  const CartV2AddSuccess({
    required this.cartId,
    required this.shopId,
    required this.shopProductId,
    required this.quantity,
  });
}

class CartV2ShopConflict extends CartV2AddResult {
  final String existingCartId;
  final String existingShopId;
  final String newShopId;
  final String shopProductId;
  final int quantity;

  const CartV2ShopConflict({
    required this.existingCartId,
    required this.existingShopId,
    required this.newShopId,
    required this.shopProductId,
    required this.quantity,
  });
}
