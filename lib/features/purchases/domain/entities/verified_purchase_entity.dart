import 'package:equatable/equatable.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';

class VerifiedPurchaseItemEntity extends Equatable {
  final String id;
  final String shopProductId;
  final String? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const VerifiedPurchaseItemEntity({
    required this.id,
    required this.shopProductId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
    id,
    shopProductId,
    productId,
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
  final int? customerRating;
  final DateTime? customerRatedAt;
  final PurchaseServiceEvaluation? serviceEvaluation;

  const VerifiedPurchaseEntity({
    required this.id,
    required this.sourceQrSessionId,
    required this.shopId,
    required this.shopName,
    required this.itemCount,
    required this.totalAmount,
    required this.confirmedAt,
    required this.items,
    this.customerRating,
    this.customerRatedAt,
    this.serviceEvaluation,
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
    customerRating,
    customerRatedAt,
    serviceEvaluation,
  ];
}
