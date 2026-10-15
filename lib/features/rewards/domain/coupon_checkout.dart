import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';

class CouponCheckoutPreview {
  const CouponCheckoutPreview({
    required this.cartId,
    required this.shopId,
    required this.enabled,
    required this.fingerprint,
    required this.sale,
    required this.available,
    required this.maximum,
    required this.eligibility,
    this.existingSession,
  });
  final String cartId, shopId, fingerprint, eligibility;
  final bool enabled;
  final LedgerMinorUnits sale, available, maximum;
  final QrSessionEntity? existingSession;
  CouponCheckoutPreview withExistingSession(QrSessionEntity session) =>
      CouponCheckoutPreview(
        cartId: cartId,
        shopId: shopId,
        enabled: enabled,
        fingerprint: fingerprint,
        sale: sale,
        available: available,
        maximum: maximum,
        eligibility: eligibility,
        existingSession: session,
      );

  factory CouponCheckoutPreview.fromJson(Map<String, dynamic> row) {
    final uuid = RegExp(
      r'^[a-fA-F0-9]{8}-(?:[a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}$',
    );
    if (row['version'] != 1 ||
        row['currency'] != 'TRY' ||
        row['enabled'] is! bool ||
        row['cart_id'] is! String ||
        !uuid.hasMatch(row['cart_id'] as String) ||
        row['shop_id'] is! String ||
        !uuid.hasMatch(row['shop_id'] as String) ||
        row['fingerprint'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(row['fingerprint'] as String) ||
        !const {
          'eligible',
          'classification_unavailable',
          'merchant_not_accepting',
        }.contains(row['eligibility'])) {
      throw const FormatException('Checkout preview');
    }
    final sale = LedgerMinorUnits.fromWire(row['sale_minor']);
    final available = LedgerMinorUnits.fromWire(row['coupon_available_minor']);
    final maximum = LedgerMinorUnits.fromWire(row['maximum_coupon_minor']);
    if (maximum.value > sale.value ||
        maximum.value > available.value ||
        (row['enabled'] == false || row['eligibility'] != 'eligible') &&
            maximum.value != BigInt.zero) {
      throw const FormatException('Checkout limits');
    }
    return CouponCheckoutPreview(
      cartId: row['cart_id'] as String,
      shopId: row['shop_id'] as String,
      enabled: row['enabled'] as bool,
      fingerprint: row['fingerprint'] as String,
      sale: sale,
      available: available,
      maximum: maximum,
      eligibility: row['eligibility'] as String,
    );
  }
}

abstract interface class CouponCheckoutRepository {
  Stream<void> get sessionChanges;
  Future<Either<String, CouponCheckoutPreview>> preview(String cartId);
  Future<Either<String, QrSessionEntity>> approve(
    CouponCheckoutPreview preview,
    String requestId,
    LedgerMinorUnits coupon,
  );
}
