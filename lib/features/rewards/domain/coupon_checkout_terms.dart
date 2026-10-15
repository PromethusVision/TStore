import 'package:equatable/equatable.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';

/// Customer-approved physical sale. Decimal strings remain exact across hosts.
class CouponCheckoutTerms extends Equatable {
  const CouponCheckoutTerms({
    required this.sale,
    required this.coupon,
    required this.payment,
    required this.fingerprint,
    required this.approvedAt,
  });
  final LedgerMinorUnits sale, coupon, payment;
  final String fingerprint;
  final DateTime approvedAt;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'sale_minor': sale.value.toString(),
    'coupon_minor': coupon.value.toString(),
    'payment_minor': payment.value.toString(),
    'fingerprint': fingerprint,
    'approved_at': approvedAt.toIso8601String(),
  };

  factory CouponCheckoutTerms.fromJson(Object? value) {
    if (value is! Map ||
        value['version'] != 1 ||
        value['fingerprint'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(value['fingerprint'] as String) ||
        value['approved_at'] is! String) {
      throw const FormatException('Checkout terms');
    }
    final sale = LedgerMinorUnits.fromWire(value['sale_minor']);
    final coupon = LedgerMinorUnits.fromWire(value['coupon_minor']);
    final payment = LedgerMinorUnits.fromWire(value['payment_minor']);
    if (coupon.value <= BigInt.zero ||
        sale.value != coupon.value + payment.value) {
      throw const FormatException('Checkout amounts');
    }
    return CouponCheckoutTerms(
      sale: sale,
      coupon: coupon,
      payment: payment,
      fingerprint: value['fingerprint'] as String,
      approvedAt: DateTime.parse(value['approved_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
    sale.value,
    coupon.value,
    payment.value,
    fingerprint,
    approvedAt,
  ];
}
