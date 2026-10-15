import 'package:equatable/equatable.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout_terms.dart';

class QrSessionEntity extends Equatable {
  final String id;
  final String sessionToken;
  final String userId;
  final String cartId;
  final String shopId;
  final String status;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? itemCount;
  final double? totalAmount;
  final int protocolVersion;
  final String? purchaseId;
  final String? manualCode;
  final DateTime? completionExpiresAt;
  final CouponCheckoutTerms? couponCheckout;

  const QrSessionEntity({
    required this.id,
    required this.sessionToken,
    required this.userId,
    required this.cartId,
    required this.shopId,
    required this.status,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount,
    this.totalAmount,
    this.protocolVersion = 1,
    this.purchaseId,
    this.manualCode,
    this.completionExpiresAt,
    this.couponCheckout,
  });

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
    id,
    sessionToken,
    userId,
    cartId,
    shopId,
    status,
    expiresAt,
    usedAt,
    createdAt,
    updatedAt,
    itemCount,
    totalAmount,
    protocolVersion,
    purchaseId,
    manualCode,
    completionExpiresAt,
    couponCheckout,
  ];
}
