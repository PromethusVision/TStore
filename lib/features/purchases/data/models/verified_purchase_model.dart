import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';

class VerifiedPurchaseItemModel extends VerifiedPurchaseItemEntity {
  const VerifiedPurchaseItemModel({
    required super.id,
    required super.shopProductId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.lineTotal,
  });

  factory VerifiedPurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return VerifiedPurchaseItemModel(
      id: _requiredString(json, 'id'),
      shopProductId: _requiredString(json, 'shop_product_id'),
      productName: _requiredString(json, 'product_name'),
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      lineTotal: _toDouble(json['line_total']),
    );
  }
}

class VerifiedPurchaseModel extends VerifiedPurchaseEntity {
  const VerifiedPurchaseModel({
    required super.id,
    required super.sourceQrSessionId,
    required super.shopId,
    required super.shopName,
    required super.itemCount,
    required super.totalAmount,
    required super.confirmedAt,
    required super.items,
    super.customerRating,
    super.customerRatedAt,
  });

  factory VerifiedPurchaseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['verified_transaction_items'];
    if (rawItems is! List) {
      throw const FormatException('Alışveriş ürünleri okunamadı.');
    }

    final items = rawItems
        .map<VerifiedPurchaseItemModel>((item) {
          if (item is Map<String, dynamic>) {
            return VerifiedPurchaseItemModel.fromJson(item);
          }
          if (item is Map) {
            return VerifiedPurchaseItemModel.fromJson(
              Map<String, dynamic>.from(item),
            );
          }
          throw const FormatException('Alışveriş ürünü okunamadı.');
        })
        .toList(growable: false);

    final ratingJson = _customerRatingJson(json['shop_ratings']);

    return VerifiedPurchaseModel(
      id: _requiredString(json, 'id'),
      sourceQrSessionId: _requiredString(json, 'source_qr_session_id'),
      shopId: _requiredString(json, 'shop_id'),
      shopName: _requiredString(json, 'shop_name'),
      itemCount: _toInt(json['item_count']),
      totalAmount: _toDouble(json['total_amount']),
      confirmedAt: _toDateTime(json['confirmed_at']),
      items: items,
      customerRating: _toCustomerRating(ratingJson),
      customerRatedAt: _toCustomerRatedAt(ratingJson),
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key]?.toString().trim() ?? '';
  if (value.isEmpty) throw FormatException('$key alanı eksik.');
  return value;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.parse(value.toString());
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}

DateTime _toDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.parse(value.toString());
}

Map<String, dynamic>? _customerRatingJson(dynamic value) {
  dynamic ratingJson;
  if (value is List && value.isNotEmpty) ratingJson = value.first;
  if (value is Map) ratingJson = value;
  if (ratingJson is! Map) return null;
  return Map<String, dynamic>.from(ratingJson);
}

int? _toCustomerRating(Map<String, dynamic>? ratingJson) {
  final rating = ratingJson?['rating'];
  if (rating == null) return null;
  final parsed = _toInt(rating);
  return parsed >= 1 && parsed <= 5 ? parsed : null;
}

DateTime? _toCustomerRatedAt(Map<String, dynamic>? ratingJson) {
  final value = ratingJson?['created_at'];
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
