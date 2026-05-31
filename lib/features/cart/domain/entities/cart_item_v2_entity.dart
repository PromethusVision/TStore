import 'package:equatable/equatable.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class CartItemV2Entity extends Equatable {
  final String id;
  final String cartId;
  final String shopProductId;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ShopProductEntity? shopProduct;

  const CartItemV2Entity({
    required this.id,
    required this.cartId,
    required this.shopProductId,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
    this.shopProduct,
  });

  double get totalPrice {
    if (shopProduct == null) return 0;
    return shopProduct!.price * quantity;
  }

  @override
  List<Object?> get props => [
        id,
        cartId,
        shopProductId,
        quantity,
        createdAt,
        updatedAt,
        shopProduct,
      ];

  CartItemV2Entity copyWith({
    String? id,
    String? cartId,
    String? shopProductId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShopProductEntity? shopProduct,
  }) {
    return CartItemV2Entity(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      shopProductId: shopProductId ?? this.shopProductId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopProduct: shopProduct ?? this.shopProduct,
    );
  }
}
