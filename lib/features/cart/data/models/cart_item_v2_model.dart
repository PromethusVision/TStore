import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class CartItemV2Model extends CartItemV2Entity {
  const CartItemV2Model({
    required super.id,
    required super.cartId,
    required super.shopProductId,
    required super.quantity,
    super.createdAt,
    super.updatedAt,
    super.shopProduct,
  });

  factory CartItemV2Model.fromJson(Map<String, dynamic> json) {
    return CartItemV2Model(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      shopProductId: json['shop_product_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: _toNullableDateTime(json['created_at']),
      updatedAt: _toNullableDateTime(json['updated_at']),
      shopProduct: _parseShopProduct(
        json['shop_products'] ?? json['shopProduct'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'shop_product_id': shopProductId,
      'quantity': quantity,
    };
  }

  factory CartItemV2Model.fromEntity(CartItemV2Entity entity) {
    return CartItemV2Model(
      id: entity.id,
      cartId: entity.cartId,
      shopProductId: entity.shopProductId,
      quantity: entity.quantity,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      shopProduct: entity.shopProduct,
    );
  }

  static ShopProductEntity? _parseShopProduct(dynamic value) {
    if (value is Map<String, dynamic>) return ShopProductModel.fromJson(value);
    if (value is Map) {
      return ShopProductModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
