import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';

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
    if (value is num) return value.toInt();
    return int.parse(value.toString());
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
    return value.toString();
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

    return QrVerificationModel(
      sessionId: _requiredString(json, 'session_id'),
      sessionToken: _requiredString(json, 'session_token'),
      status: _requiredString(json, 'status'),
      expiresAt: _toDateTime(json['expires_at']),
      usedAt: _toNullableDateTime(json['used_at']),
      shopId: _requiredString(json, 'shop_id'),
      shopName: _requiredString(json, 'shop_name'),
      itemCount: itemCount,
      totalAmount: totalAmount,
      items: items,
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
    if (value is num) return value.toInt();
    return int.parse(value.toString());
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
    return value.toString();
  }
}
