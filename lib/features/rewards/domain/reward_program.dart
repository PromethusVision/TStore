import 'package:dartz/dartz.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';

/// No monetary client mutation or payment-provider success API.
abstract interface class RewardProgramRepository implements RewardRepository {
  Future<Either<String, RewardProgramCapabilities>> capabilities();
  Future<Either<String, RewardProgramState>> readCustomer();
  Future<Either<String, MerchantRewardState>> readMerchant(String shopId);
  Future<Either<String, MerchantRewardState>> setAcceptance(
    String shopId,
    bool preferred,
    int expectedRevision,
  );
  Future<Either<String, RewardReservation>> reserve(
    String cartId, {
    bool startNew = false,
  });
  void refresh();
}

class RewardProgramCapabilities {
  const RewardProgramCapabilities({
    required this.enabled,
    required this.minimum,
    required this.contribution,
    required this.coupon,
    required this.packageFund,
    required this.packageFee,
    required this.packageSlots,
    required this.packageSeconds,
    required this.reservationSeconds,
    required this.maturitySeconds,
  });
  final bool enabled;
  final LedgerMinorUnits minimum, contribution, coupon, packageFund, packageFee;
  final int packageSlots, packageSeconds, reservationSeconds, maturitySeconds;
  int get goal => 5;
  bool get purchaseEnabled => false;
  bool get redemptionEnabled => false;
}

class ReferralPackage {
  const ReferralPackage({
    required this.id,
    required this.activatedAt,
    required this.expiresAt,
    required this.expired,
    required this.free,
    required this.held,
    required this.consumed,
    required this.refunded,
    required this.totalSlots,
    required this.fund,
    required this.fee,
  });
  final String id;
  final DateTime activatedAt, expiresAt;
  final bool expired;
  final int free, held, consumed, refunded, totalSlots;
  final LedgerMinorUnits fund, fee;
}

class MerchantRewardState {
  MerchantRewardState({
    required this.shopId,
    required this.enabled,
    required this.serverNow,
    required this.preferred,
    required this.forced,
    required this.effective,
    required this.revision,
    required List<ReferralPackage> packages,
  }) : packages = List.unmodifiable(packages);
  final String shopId;
  final bool enabled, preferred, forced, effective;
  final int revision;
  final DateTime serverNow;
  final List<ReferralPackage> packages;
}

class RewardCoupon {
  const RewardCoupon({
    required this.id,
    required this.issuedAt,
    required this.face,
    required this.remaining,
  });
  final String id;
  final DateTime issuedAt;
  final LedgerMinorUnits face, remaining;
}

class RewardEarning {
  const RewardEarning({
    required this.purchaseId,
    required this.earnedAt,
    required this.maturesAt,
    required this.valid,
    required this.issued,
  });
  final String purchaseId;
  final DateTime earnedAt, maturesAt;
  final bool valid, issued;
}

class RewardProgramState {
  RewardProgramState({
    required this.enabled,
    required this.serverNow,
    required this.pendingCount,
    required this.pending,
    required this.couponValue,
    required List<RewardCoupon> coupons,
    required List<RewardEarning> history,
    required List<RewardEligibleMerchant> merchants,
    this.checkoutEnabled = false,
    this.futureOffset,
  }) : coupons = List.unmodifiable(coupons),
       history = List.unmodifiable(history),
       merchants = List.unmodifiable(merchants);
  final bool enabled;
  final bool checkoutEnabled;
  final LedgerMinorUnits? futureOffset;
  final DateTime serverNow;
  final int pendingCount;
  final LedgerMinorUnits pending, couponValue;
  final List<RewardCoupon> coupons;
  final List<RewardEarning> history;
  final List<RewardEligibleMerchant> merchants;
  int get progressSteps => pendingCount.clamp(0, 5);
  bool get redemptionEnabled => checkoutEnabled;
}

enum RewardReservationStatus {
  disabled,
  belowThreshold,
  noCapacity,
  reserved,
  checkoutHold,
  attemptExpired,
}

class RewardReservation {
  const RewardReservation({
    required this.status,
    required this.serverNow,
    this.attemptId,
    this.expiresAt,
  });
  final RewardReservationStatus status;
  final DateTime serverNow;
  final String? attemptId;
  final DateTime? expiresAt;
  bool get holdsCapacity =>
      status == RewardReservationStatus.reserved ||
      status == RewardReservationStatus.checkoutHold;
  Duration get remainingAtRead =>
      expiresAt == null ? Duration.zero : expiresAt!.difference(serverNow);
}

String rewardMoney(LedgerMinorUnits amount) {
  final raw = amount.value.toString().padLeft(3, '0');
  return '${raw.substring(0, raw.length - 2)},${raw.substring(raw.length - 2)} TL';
}
