import 'package:dartz/dartz.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';

enum StatementKind {
  couponRedemption('coupon_redemption'),
  unusedPackageFund('unused_package_fund'),
  platformService('platform_service'),
  receivableRelease('receivable_release'),
  packageFunding('package_funding'),
  rewardIssue('reward_issue'),
  returnEntry('return'),
  reversal('admin_reversal'),
  offsetCreated('offset_created'),
  offsetRecovered('offset_recovered'),
  rewardFunding('reward_funding'),
  rewardCapacity('reward_capacity'),
  rewardCompensation('reward_compensation');

  const StatementKind(this.code);
  final String code;
}

class MerchantStatementEntry {
  MerchantStatementEntry({
    required this.id,
    required this.recordedAt,
    required this.kind,
    required this.reverses,
    required this.net,
    required Map<LedgerAccountKind, BigInt> movements,
  }) : movements = Map.unmodifiable(movements);
  final String id;
  final DateTime recordedAt;
  final StatementKind kind;
  final String? reverses;
  final BigInt net;
  final Map<LedgerAccountKind, BigInt> movements;
}

class MerchantStatement {
  MerchantStatement({
    required this.enabled,
    required this.shopId,
    required this.revision,
    required this.nextBefore,
    required this.reserveCap,
    required Map<LedgerAccountKind, BigInt> accounts,
    required List<MerchantStatementEntry> entries,
  }) : accounts = Map.unmodifiable(accounts),
       entries = List.unmodifiable(entries);
  final bool enabled;
  final String shopId;
  final String? revision, nextBefore;
  final BigInt? reserveCap;
  final Map<LedgerAccountKind, BigInt> accounts;
  final List<MerchantStatementEntry> entries;
  bool get settlementEnabled => false;
  BigInt balance(LedgerAccountKind kind) => accounts[kind] ?? BigInt.zero;
  BigInt get pending =>
      balance(LedgerAccountKind.merchantCouponPending) +
      balance(LedgerAccountKind.merchantUnusedPending);
  BigInt get released =>
      balance(LedgerAccountKind.merchantCouponAvailable) +
      balance(LedgerAccountKind.merchantUnusedAvailable);
}

abstract interface class MerchantStatementRepository {
  Future<Either<CommerceLedgerFailure, MerchantStatement>> readStatement({
    required String shopId,
    int limit = 20,
    String? before,
    String? revision,
  });
}

/// Exact formatting, including totals greater than JS's safe integer boundary.
String statementMoney(BigInt minor, {bool signed = false}) {
  final absolute = minor.abs().toString().padLeft(3, '0');
  final whole = absolute
      .substring(0, absolute.length - 2)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  final sign = minor.isNegative
      ? '−'
      : signed && minor > BigInt.zero
      ? '+'
      : '';
  return '$sign$whole,${absolute.substring(absolute.length - 2)} TL';
}
