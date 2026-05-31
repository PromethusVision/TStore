import 'package:t_store/features/cart/domain/entities/cart_v2_entity.dart';

class CartV2Model extends CartV2Entity {
  const CartV2Model({
    required super.id,
    required super.userId,
    required super.shopId,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory CartV2Model.fromJson(Map<String, dynamic> json) {
    return CartV2Model(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      status: json['status'] as String? ?? 'active',
      createdAt: _toNullableDateTime(json['created_at']),
      updatedAt: _toNullableDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'status': status,
    };
  }

  factory CartV2Model.fromEntity(CartV2Entity entity) {
    return CartV2Model(
      id: entity.id,
      userId: entity.userId,
      shopId: entity.shopId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
