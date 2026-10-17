import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';

/// Bound to one UI lifetime. Host authority loss still disposes private routes.
class MerchantPurchaseScope {
  MerchantPurchaseScope(Object repository)
    : _source = repository is QrSessionIdentity ? repository : null,
      _identity = repository is QrSessionIdentity
          ? repository.currentQrSessionIdentity
          : null;
  final QrSessionIdentity? _source;
  final String? _identity;
  bool _closed = false;
  bool get current =>
      !_closed &&
      (_source == null ||
          (_identity != null && _source.currentQrSessionIdentity == _identity));
  void close() => _closed = true;
}
