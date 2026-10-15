import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';

const rewardUser = '11111111-1111-4111-8111-111111111111';
const rewardShop = '22222222-2222-4222-8222-222222222222';
const rewardId = '33333333-3333-4333-8333-333333333333';
const rewardNow = '2026-10-15T12:00:00Z';
Map<String, dynamic> earningQuote() => {
  'item_count': 1,
  'total_amount': 500,
  'items': [
    {
      'id': 'item',
      'shop_product_id': 'listing',
      'product_id': 'product',
      'product_name': 'Örnek ürün',
      'quantity': 1,
      'unit_price': 500,
      'line_total': 500,
    },
  ],
};
Map<String, dynamic> rewardCaps() => {
  'version': 1,
  'goal': 5,
  'currency': 'TRY',
  'enabled': true,
  'package_purchase_enabled': false,
  'redemption_enabled': false,
  'settlement_enabled': false,
  'minimum_minor': '50000',
  'contribution_minor': '5000',
  'coupon_minor': '25000',
  'package_fund_minor': '500000',
  'package_fee_minor': '75000',
  'package_slots': 100,
  'package_seconds': 7776000,
  'reservation_seconds': 1800,
  'minimum_maturity_seconds': 86400,
};
Map<String, dynamic> rewardCustomer() => {
  'goal': 5,
  'currency': 'TRY',
  'enabled': true,
  'redemption_enabled': false,
  'server_now': rewardNow,
  'pending_count': 1,
  'pending_minor': '5000',
  'coupon_minor': '25000',
  'coupons': [
    {
      'id': rewardId,
      'issued_at': rewardNow,
      'expires_at': null,
      'face_minor': '25000',
      'remaining_minor': '25000',
    },
  ],
  'history': [
    {
      'purchase_id': rewardId,
      'earned_at': rewardNow,
      'matures_at': '2026-10-16T12:00:00Z',
      'valid': true,
      'issued': false,
    },
  ],
  'merchants': [
    {'id': rewardShop, 'name': 'Örnek Esnaf'},
  ],
};
Map<String, dynamic> rewardMerchant() => {
  'shop_id': rewardShop,
  'enabled': true,
  'server_now': rewardNow,
  'package_purchase_enabled': false,
  'redemption_enabled': false,
  'preferred_acceptance': false,
  'forced_acceptance': true,
  'effective_acceptance': true,
  'preference_revision': 0,
  'packages': [
    {
      'id': rewardId,
      'activated_at': rewardNow,
      'expires_at': '2027-01-13T12:00:00Z',
      'expired': false,
      'capacity': {'free': 94, 'held': 1, 'consumed': 5, 'expired': 0},
      'total_slots': 100,
      'fund_minor': '500000',
      'service_fee_minor': '75000',
    },
  ],
};
LedgerMinorUnits minor(String n) => LedgerMinorUnits.fromWire(n);
MerchantRewardState merchantState({
  bool forced = true,
  bool preferred = false,
  bool enabled = true,
  bool packages = true,
}) => MerchantRewardState(
  shopId: rewardShop,
  enabled: enabled,
  serverNow: DateTime.parse(rewardNow),
  preferred: preferred,
  forced: forced,
  effective: forced || preferred,
  revision: 7,
  packages: packages
      ? [
          ReferralPackage(
            id: rewardId,
            activatedAt: DateTime.parse(rewardNow),
            expiresAt: DateTime.utc(2027, 1, 13),
            expired: false,
            free: 94,
            held: 1,
            consumed: 5,
            refunded: 0,
            totalSlots: 100,
            fund: minor('500000'),
            fee: minor('75000'),
          ),
        ]
      : [],
);
RewardProgramState customerState({int count = 5, bool enabled = true}) =>
    RewardProgramState(
      enabled: enabled,
      serverNow: DateTime.parse(rewardNow),
      pendingCount: count,
      pending: minor('${count * 5000}'),
      couponValue: minor('25000'),
      coupons: [
        RewardCoupon(
          id: rewardId,
          issuedAt: DateTime.parse(rewardNow),
          face: minor('25000'),
          remaining: minor('25000'),
        ),
      ],
      history: [
        RewardEarning(
          purchaseId: rewardId,
          earnedAt: DateTime.parse(rewardNow),
          maturesAt: DateTime.utc(2026, 10, 16, 12),
          valid: true,
          issued: false,
        ),
      ],
      merchants: const [],
    );
RewardReservation reservation({
  RewardReservationStatus status = RewardReservationStatus.reserved,
  int seconds = 1800,
}) => RewardReservation(
  status: status,
  serverNow: DateTime.parse(rewardNow),
  attemptId: rewardId,
  expiresAt: DateTime.parse(rewardNow).add(Duration(seconds: seconds)),
);

class RewardFake extends Fake implements RewardProgramRepository {
  MerchantRewardState merchant = merchantState();
  RewardReservation held = reservation();
  String? error;
  int reads = 0, writes = 0, refreshes = 0;
  final reservations = <bool>[];
  final revisions = <int>[];
  Completer<Either<String, MerchantRewardState>>? merchantWait, writeWait;
  Completer<Either<String, RewardReservation>>? reserveWait;
  final progress = StreamController<RewardProgress>.broadcast(sync: true);
  @override
  Future<Either<String, RewardProgramCapabilities>> capabilities() async =>
      Right(
        RewardProgramCapabilities(
          enabled: true,
          minimum: minor('50000'),
          contribution: minor('5000'),
          coupon: minor('25000'),
          packageFund: minor('500000'),
          packageFee: minor('75000'),
          packageSlots: 100,
          packageSeconds: 7776000,
          reservationSeconds: 1800,
          maturitySeconds: 86400,
        ),
      );
  @override
  Future<Either<String, MerchantRewardState>> readMerchant(
    String shopId,
  ) async {
    reads++;
    return merchantWait?.future ??
        (error == null ? Right(merchant) : Left(error!));
  }

  @override
  Future<Either<String, MerchantRewardState>> setAcceptance(
    String shopId,
    bool preferred,
    int expectedRevision,
  ) async {
    writes++;
    revisions.add(expectedRevision);
    return writeWait?.future ??
        Right(merchantState(forced: false, preferred: preferred));
  }

  @override
  Future<Either<String, RewardReservation>> reserve(
    String cartId, {
    bool startNew = false,
  }) async {
    reservations.add(startNew);
    return reserveWait?.future ?? (error == null ? Right(held) : Left(error!));
  }

  @override
  Stream<RewardProgress> watchProgress(String? customerId) => progress.stream;
  @override
  void refresh() {
    refreshes++;
  }
}
