import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';

class QrSessionModel extends QrSessionEntity {
  const QrSessionModel({
    required super.id,
    required super.sessionToken,
    required super.userId,
    required super.cartId,
    required super.shopId,
    required super.status,
    required super.expiresAt,
    super.usedAt,
    required super.createdAt,
    required super.updatedAt,
    super.itemCount,
    super.totalAmount,
  });

  factory QrSessionModel.fromJson(Map<String, dynamic> json) {
    return QrSessionModel(
      id: json['id'] as String,
      sessionToken: json['session_token'] as String,
      userId: json['user_id'] as String,
      cartId: json['cart_id'] as String,
      shopId: json['shop_id'] as String,
      status: json['status'] as String? ?? 'active',
      expiresAt: _toDateTime(json['expires_at']),
      usedAt: _toNullableDateTime(json['used_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      itemCount: _toNullableInt(json['item_count']),
      totalAmount: _toNullableDouble(json['total_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_token': sessionToken,
      'user_id': userId,
      'cart_id': cartId,
      'shop_id': shopId,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'item_count': itemCount,
      'total_amount': totalAmount,
    };
  }

  factory QrSessionModel.fromEntity(QrSessionEntity entity) {
    return QrSessionModel(
      id: entity.id,
      sessionToken: entity.sessionToken,
      userId: entity.userId,
      cartId: entity.cartId,
      shopId: entity.shopId,
      status: entity.status,
      expiresAt: entity.expiresAt,
      usedAt: entity.usedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      itemCount: entity.itemCount,
      totalAmount: entity.totalAmount,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value.toString());
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
