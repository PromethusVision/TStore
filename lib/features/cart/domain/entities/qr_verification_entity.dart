import 'package:equatable/equatable.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout_terms.dart';

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
  final int protocolVersion;
  final String? claimId;
  final String? purchaseId;
  final DateTime? completionExpiresAt;
  final bool rewardConfirmationRequired;
  final String? rewardSaleMinor;
  final CouponCheckoutTerms? couponCheckout;

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
    this.protocolVersion = 1,
    this.claimId,
    this.purchaseId,
    this.completionExpiresAt,
    this.rewardConfirmationRequired = false,
    this.rewardSaleMinor,
    this.couponCheckout,
  });

  DateTime get confirmationDeadline => completionExpiresAt ?? expiresAt;
  bool canConfirmAt(DateTime now) => protocolVersion == 2
      ? status == 'claimed' &&
            claimId != null &&
            completionExpiresAt != null &&
            completionExpiresAt!.isAfter(now)
      : status == 'active' && expiresAt.isAfter(now);
  bool get canBeConfirmed => canConfirmAt(DateTime.now());

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
    protocolVersion,
    claimId,
    purchaseId,
    completionExpiresAt,
    rewardConfirmationRequired,
    rewardSaleMinor,
    couponCheckout,
  ];
}
