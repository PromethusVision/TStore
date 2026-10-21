import 'dart:async';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';

/// One transaction/view lifetime. It cannot revive when an old key returns.
/// This is a local continuation fence, never server authorization.
class QrSessionGuard {
  QrSessionGuard(Object source, {this.onRetired, this.originIsCurrent})
    : _source = source,
      _key = _read(source) {
    if (source is AuthenticatedSessionEvents) {
      _subscription = source.sessionKeyChanges.listen(
        (key) {
          if (key != _key || !current) _retire();
        },
        onError: (Object _) => _retire(),
        onDone: _retire,
      );
    }
  }
  final Object _source;
  final String? _key;
  final void Function()? onRetired;
  final bool Function()? originIsCurrent;
  StreamSubscription<String?>? _subscription;
  bool _closed = false;
  bool _disposed = false;
  static String? _read(Object source) => source is AuthenticatedSessionSource
      ? source.currentSessionKey
      : source is QrSessionIdentity
      ? source.currentQrSessionIdentity
      : null;
  bool get current {
    if (!_closed &&
        (originIsCurrent?.call() == false ||
            ((_source is AuthenticatedSessionSource ||
                    _source is QrSessionIdentity) &&
                (_key == null || _read(_source) != _key)))) {
      _retire();
    }
    return !_closed;
  }

  void _retire() {
    if (_closed) return;
    _closed = true;
    scheduleMicrotask(() {
      if (!_disposed) onRetired?.call();
    });
  }

  void close() {
    _disposed = true;
    _closed = true;
    unawaited(_subscription?.cancel());
  }
}
