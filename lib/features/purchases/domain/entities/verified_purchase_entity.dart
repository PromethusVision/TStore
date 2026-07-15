import 'package:equatable/equatable.dart';

class VerifiedPurchaseItemEntity extends Equatable {
  final String id;
  final String shopProductId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const VerifiedPurchaseItemEntity({
    required this.id,
    required this.shopProductId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
    id,
    shopProductId,
    productName,
    quantity,
    unitPrice,
    lineTotal,
  ];
}

class VerifiedPurchaseEntity extends Equatable {
  final String id;
  final String sourceQrSessionId;
  final String shopId;
  final String shopName;
  final int itemCount;
  final double totalAmount;
  final DateTime confirmedAt;
  final List<VerifiedPurchaseItemEntity> items;

  const VerifiedPurchaseEntity({
    required this.id,
    required this.sourceQrSessionId,
    required this.shopId,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.confirmedAt,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id,
    sourceQrSessionId,
    shopId,
    shopName,
    itemCount,
    totalAmount,
    confirmedAt,
    items,
  ];
}
