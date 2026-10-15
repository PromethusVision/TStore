import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout_terms.dart';

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
    super.protocolVersion,
    super.purchaseId,
    super.manualCode,
    super.completionExpiresAt,
    super.couponCheckout,
  });

  factory QrSessionModel.fromJson(Map<String, dynamic> json) {
    final protocol = json['protocol_version'] ?? 1;
    final checkout = json['coupon_checkout'] == null
        ? null
        : CouponCheckoutTerms.fromJson(json['coupon_checkout']);
    if (checkout != null && protocol != 2) {
      throw const FormatException('Checkout protocol');
    }
    if (protocol != 1 && protocol != 2) {
      throw const FormatException('QR protokolü desteklenmiyor.');
    }
    final code = json['manual_code'] as String?;
    final completion = _toNullableDateTime(json['completion_expires_at']);
    final purchaseId = json['purchase_id'] as String?;
    if (protocol == 2 &&
        (!const {
              'active',
              'claimed',
              'used',
              'expired',
              'cancelled',
            }.contains(json['status']) ||
            (json['status'] == 'used' &&
                (_toNullableDateTime(json['used_at']) == null ||
                    purchaseId == null ||
                    purchaseId.isEmpty)) ||
            (json['status'] != 'used' && json['used_at'] != null))) {
      throw const FormatException('QR onay kanıtı eksik.');
    }
    if (protocol == 2 &&
        (code != null && !RegExp(r'^\d{6}$').hasMatch(code) ||
            json['status'] == 'claimed' && completion == null)) {
      throw const FormatException('QR durum bilgisi geçersiz.');
    }
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
      protocolVersion: protocol as int,
      purchaseId: purchaseId,
      manualCode: code,
      completionExpiresAt: completion,
      couponCheckout: checkout,
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
      if (couponCheckout != null) 'coupon_checkout': couponCheckout!.toJson(),
      if (protocolVersion == 2) ...{
        'protocol_version': protocolVersion,
        'purchase_id': purchaseId,
        'manual_code': manualCode,
        'completion_expires_at': completionExpiresAt?.toIso8601String(),
      },
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
      protocolVersion: entity.protocolVersion,
      purchaseId: entity.purchaseId,
      manualCode: entity.manualCode,
      completionExpiresAt: entity.completionExpiresAt,
      couponCheckout: entity.couponCheckout,
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
