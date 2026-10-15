import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout_terms.dart';

class QrVerificationItemModel extends QrVerificationItemEntity {
  const QrVerificationItemModel({
    required super.id,
    required super.shopProductId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.lineTotal,
  });

  factory QrVerificationItemModel.fromJson(Map<String, dynamic> json) {
    final quantity = _toInt(json['quantity']);
    final unitPrice = _toDouble(json['unit_price']);
    final lineTotal = _toDouble(json['line_total']);

    if (quantity <= 0 ||
        !unitPrice.isFinite ||
        !lineTotal.isFinite ||
        unitPrice < 0 ||
        lineTotal < 0 ||
        (lineTotal - (unitPrice * quantity)).abs() > 0.005) {
      throw const FormatException('QR urun tutari gecersiz.');
    }

    return QrVerificationItemModel(
      id: _requiredString(json, 'id'),
      shopProductId: _requiredString(json, 'shop_product_id'),
      productName: _requiredString(json, 'product_name'),
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_product_id': shopProductId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'line_total': lineTotal,
    };
  }

  static int _toInt(dynamic value) {
    final parsed = value is num
        ? value.toDouble()
        : double.parse(value.toString());
    if (!parsed.isFinite || parsed != parsed.truncateToDouble()) {
      throw const FormatException('QR urun adedi gecersiz.');
    }
    return parsed.toInt();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException('$key alani eksik.');
    }
    return value.toString().trim();
  }
}

class QrVerificationModel extends QrVerificationEntity {
  const QrVerificationModel({
    required super.sessionId,
    required super.sessionToken,
    required super.status,
    required super.expiresAt,
    super.usedAt,
    required super.shopId,
    required super.shopName,
    required super.itemCount,
    required super.totalAmount,
    required super.items,
    super.protocolVersion,
    super.claimId,
    super.purchaseId,
    super.completionExpiresAt,
    super.rewardConfirmationRequired,
    super.rewardSaleMinor,
    super.couponCheckout,
  });

  factory QrVerificationModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('QR urun listesi gecersiz.');
    }

    final items = rawItems
        .map<QrVerificationItemModel>((item) {
          if (item is Map<String, dynamic>) {
            return QrVerificationItemModel.fromJson(item);
          }
          if (item is Map) {
            return QrVerificationItemModel.fromJson(
              Map<String, dynamic>.from(item),
            );
          }
          throw const FormatException('QR urun bilgisi gecersiz.');
        })
        .toList(growable: false);

    if (items.isEmpty) {
      throw const FormatException('QR urun listesi bos.');
    }

    final itemCount = _toInt(json['item_count']);
    final totalAmount = _toDouble(json['total_amount']);
    final status = _requiredString(json, 'status');
    final protocol = json['protocol_version'] ?? 1;
    if (protocol != 1 && protocol != 2) {
      throw const FormatException('QR protokolü desteklenmiyor.');
    }
    if (!(protocol == 2
            ? const {'claimed', 'used', 'expired', 'cancelled'}
            : const {'active', 'used', 'expired', 'cancelled'})
        .contains(status)) {
      throw const FormatException('QR durumu gecersiz.');
    }

    final expiresAt = _toDateTime(json['expires_at']);
    final usedAt = _toNullableDateTime(json['used_at']);
    final completion = _toNullableDateTime(json['completion_expires_at']);
    final claimId = json['claim_id'] as String?;
    final purchaseId = json['purchase_id'] as String?;
    final rewardRequired = json['reward_confirmation_required'] ?? false;
    final rewardSale = json['reward_sale_minor'];
    if (rewardRequired is! bool ||
        (rewardRequired &&
            (protocol != 2 ||
                rewardSale is! String ||
                !RegExp(r'^(0|[1-9][0-9]{0,18})$').hasMatch(rewardSale)))) {
      throw const FormatException('Ödüllü satış onayı doğrulanamadı.');
    }
    if (protocol == 2 &&
        (claimId == null ||
            claimId.isEmpty ||
            completion == null ||
            (status == 'used' && (purchaseId == null || purchaseId.isEmpty)))) {
      throw const FormatException('QR işlem kanıtı eksik.');
    }
    if ((status == 'used' && usedAt == null) ||
        (status != 'used' && usedAt != null) ||
        !totalAmount.isFinite) {
      throw const FormatException('QR zaman veya durum bilgisi gecersiz.');
    }
    final calculatedItemCount = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final calculatedTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    if (itemCount != calculatedItemCount ||
        (totalAmount - calculatedTotal).abs() > 0.005) {
      throw const FormatException('QR toplam bilgisi gecersiz.');
    }
    // Compatibility check against B's displayed quote only. Server minor-unit
    // text remains the amount sent for attestation; no client calculation funds it.
    if (rewardRequired &&
        BigInt.parse(rewardSale as String) !=
            BigInt.from((totalAmount * 100).round())) {
      throw const FormatException('Ödüllü satış tutarı QR ile uyuşmuyor.');
    }

    final checkout = json['coupon_checkout'] == null
        ? null
        : CouponCheckoutTerms.fromJson(json['coupon_checkout']);
    if (checkout != null &&
        (!rewardRequired || checkout.sale.value.toString() != rewardSale)) {
      throw const FormatException('Checkout attestation mismatch');
    }
    return QrVerificationModel(
      sessionId: _requiredString(json, 'session_id'),
      sessionToken: _requiredString(json, 'session_token'),
      status: status,
      expiresAt: expiresAt,
      usedAt: usedAt,
      shopId: _requiredString(json, 'shop_id'),
      shopName: _requiredString(json, 'shop_name'),
      itemCount: itemCount,
      totalAmount: totalAmount,
      items: items,
      protocolVersion: protocol as int,
      claimId: claimId,
      purchaseId: purchaseId,
      completionExpiresAt: completion,
      rewardConfirmationRequired: rewardRequired,
      rewardSaleMinor: rewardRequired ? rewardSale as String : null,
      couponCheckout: checkout,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'session_token': sessionToken,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'shop_id': shopId,
      'shop_name': shopName,
      'item_count': itemCount,
      'total_amount': totalAmount,
      if (couponCheckout != null) 'coupon_checkout': couponCheckout!.toJson(),
      'items': items
          .map(
            (item) => QrVerificationItemModel(
              id: item.id,
              shopProductId: item.shopProductId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              lineTotal: item.lineTotal,
            ).toJson(),
          )
          .toList(growable: false),
      if (protocolVersion == 2) ...{
        'protocol_version': protocolVersion,
        'claim_id': claimId,
        'purchase_id': purchaseId,
        'completion_expires_at': completionExpiresAt?.toIso8601String(),
        if (rewardConfirmationRequired) ...{
          'reward_confirmation_required': true,
          'reward_sale_minor': rewardSaleMinor,
        },
      },
    };
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

  static int _toInt(dynamic value) {
    final parsed = value is num
        ? value.toDouble()
        : double.parse(value.toString());
    if (!parsed.isFinite || parsed != parsed.truncateToDouble()) {
      throw const FormatException('QR urun adedi gecersiz.');
    }
    return parsed.toInt();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException('$key alani eksik.');
    }
    return value.toString().trim();
  }
}
