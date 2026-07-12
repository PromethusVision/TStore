import 'package:equatable/equatable.dart';

class QrVerificationItemEntity extends Equatable {
  final String id;
  final String shopProductId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const QrVerificationItemEntity({
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

class QrVerificationEntity extends Equatable {
  final String sessionId;
  final String sessionToken;
  final String status;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String shopId;
  final String shopName;
  final int itemCount;
  final double totalAmount;
  final List<QrVerificationItemEntity> items;

  const QrVerificationEntity({
    required this.sessionId,
    required this.sessionToken,
    required this.status,
    required this.expiresAt,
    this.usedAt,
    required this.shopId,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.items,
  });

  bool get canBeConfirmed =>
      status == 'active' && expiresAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
    sessionId,
    sessionToken,
    status,
    expiresAt,
    usedAt,
    shopId,
    shopName,
    itemCount,
    totalAmount,
    items,
  ];
}
