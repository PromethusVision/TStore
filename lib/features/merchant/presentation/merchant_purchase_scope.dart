import 'package:t_store/features/cart/domain/qr_session_guard.dart';

/// Bound to one UI lifetime. Host authority loss still disposes private routes.
class MerchantPurchaseScope extends QrSessionGuard {
  MerchantPurchaseScope(
    super.repository, {
    super.onRetired,
    super.originIsCurrent,
  });
}
