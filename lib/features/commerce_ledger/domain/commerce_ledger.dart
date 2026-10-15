import 'package:dartz/dartz.dart';

/// Exact display value. It is never a client authorization to spend or withdraw.
class LedgerMinorUnits {
  LedgerMinorUnits.fromWire(Object? value) : value = _parse(value);
  final BigInt value;
  static BigInt _parse(Object? input) {
    if (input is! String ||
        input.length > 100 ||
        !RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(input)) {
      throw const FormatException('Invalid accounting amount');
    }
    return BigInt.parse(input);
  }

  @override
  String toString() => value.toString();
}

enum LedgerAccountKind {
  merchantReserve('merchant_reserve'),
  merchantCouponPending('merchant_coupon_pending'),
  merchantCouponAvailable('merchant_coupon_available'),
  merchantUnusedPending('merchant_unused_pending'),
  merchantUnusedAvailable('merchant_unused_available'),
  customerPending('customer_pending'),
  customerCoupon('customer_coupon'),
  customerFutureOffset('customer_future_offset');

  const LedgerAccountKind(this.code);
  final String code;
  bool get isMerchant => code.startsWith('merchant_');
  bool get isNonCashObligation => this == customerFutureOffset;
}

class LedgerAccountBalance {
  const LedgerAccountBalance(this.kind, this.amount);
  final LedgerAccountKind kind;
  final LedgerMinorUnits amount;
}

class CommerceLedgerCapabilities {
  const CommerceLedgerCapabilities({
    required this.enabled,
    required this.policyVersion,
  });
  final bool enabled;
  final int policyVersion;
  // H0 never advertises business activation on the basis of an accounting flag.
  bool get fundingEnabled => false;
  bool get rewardsEnabled => false;
  bool get settlementEnabled => false;
}

class CommerceLedgerSnapshot {
  CommerceLedgerSnapshot({
    required this.enabled,
    required this.shopId,
    required List<LedgerAccountBalance> accounts,
  }) : accounts = List.unmodifiable(accounts);
  final bool enabled;
  final String? shopId;
  final List<LedgerAccountBalance> accounts;
  String get currency => 'TRY';
  bool get settlementEnabled => false;
}

enum CommerceLedgerFailure {
  statementChanged,
  sessionChanged,
  unavailable,
  invalidResponse,
  invalidRequest,
}

abstract interface class CommerceLedgerRepository {
  Future<Either<CommerceLedgerFailure, CommerceLedgerCapabilities>>
  capabilities();
  Future<Either<CommerceLedgerFailure, CommerceLedgerSnapshot>>
  readOwnAccounts({String? shopId});
}
