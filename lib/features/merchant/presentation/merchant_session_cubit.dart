import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

enum MerchantSessionStatus {
  checking,
  signedOut,
  denied,
  onboarding,
  ready,
  failure,
}

class MerchantSessionState {
  const MerchantSessionState(
    this.status, {
    this.access,
    this.message,
    this.busy = false,
    this.scopeRevision = 0,
    this.canRetry = true,
  });
  final MerchantSessionStatus status;
  final MerchantAccess? access;
  final String? message;
  final bool busy;

  /// Invalidates all private routes, root overlays and transient messages, even
  /// when an A -> signed-out -> A transition occurs between rendered frames.
  final int scopeRevision;
  final bool canRetry;
}

class MerchantSessionCubit extends Cubit<MerchantSessionState> {
  MerchantSessionCubit({
    required this.repository,
    required this.credentials,
    required Stream<String?> sessionChanges,
    required this.currentUserId,
    this.beforeSignOut,
    this.accessTimeout = const Duration(seconds: 15),
  }) : super(const MerchantSessionState(MerchantSessionStatus.checking)) {
    _lastIdentity = currentUserId();
    _subscription = sessionChanges.listen(
      (id) {
        _observeIdentity(signal: id, hasSignal: true);
        // Auth callbacks can arrive while disabling a device or awaiting a
        // credential request. Only its completion may reopen the workspace.
        if (_authBusy || _recoveryActive) {
          ++_epoch;
          return;
        }
        unawaited(
          reload(
            quiet:
                id != null &&
                id == currentUserId() &&
                id == state.access?.user.id,
          ),
        );
      },
      onError: (Object _) => _sessionFailure(),
      onDone: () {
        _monitorEnded = true;
        _sessionFailure();
      },
    );
  }
  final MerchantRepository repository;
  final MerchantCredentials credentials;
  final String? Function() currentUserId;
  final Future<void> Function()? beforeSignOut;
  // Reads alone are bounded. Timing out an auth/write operation must never be
  // interpreted as cancellation or as permission to send a replacement write.
  final Duration accessTimeout;
  StreamSubscription<String?>? _subscription;
  int _epoch = 0, _scopeRevision = 0, _identityRevision = 0;
  String? _lastIdentity;
  bool _authBusy = false, _authInterrupted = false, _monitorEnded = false;
  bool _closing = false;
  bool _recoveryActive = false;
  void setRecoveryActive(bool active) {
    if (_unavailable || active == _recoveryActive) return;
    _recoveryActive = active;
    ++_epoch;
    ++_scopeRevision;
    _publish(MerchantSessionStatus.checking);
    if (!active) unawaited(reload());
  }

  bool get _unavailable => isClosed || _closing;

  void _observeIdentity({String? signal, bool hasSignal = false}) {
    final actual = currentUserId();
    if (_lastIdentity != actual || (hasSignal && signal != actual)) {
      ++_identityRevision;
      ++_scopeRevision;
    }
    _lastIdentity = actual;
  }

  void _publish(
    MerchantSessionStatus status, {
    MerchantAccess? access,
    String? message,
  }) {
    if (_unavailable) return;
    emit(
      MerchantSessionState(
        status,
        access: access,
        message: message,
        busy: _authBusy || _recoveryActive,
        scopeRevision: _scopeRevision,
        canRetry: !_monitorEnded,
      ),
    );
  }

  void _failure(String message) {
    ++_scopeRevision;
    _publish(MerchantSessionStatus.failure, message: message);
  }

  String get _sessionFailureMessage => _monitorEnded
      ? 'Oturum takibi kesildi. Uygulamayı kapatıp yeniden açın.'
      : 'Oturum doğrulanamadı. Lütfen yeniden deneyin.';

  void _sessionFailure() {
    ++_epoch;
    if (_authBusy) _authInterrupted = true;
    _failure(_sessionFailureMessage);
  }

  Future<void> reload({bool quiet = false}) async {
    if (_unavailable || _authBusy || _recoveryActive) return;
    if (_monitorEnded) {
      _failure(_sessionFailureMessage);
      return;
    }
    _observeIdentity();
    final epoch = ++_epoch;
    final id = currentUserId();
    final previous = state.access;
    final preserve = quiet && id != null && previous?.user.id == id;
    if (!preserve) ++_scopeRevision;
    if (id == null) {
      _publish(MerchantSessionStatus.signedOut);
      return;
    }
    if (!preserve) _publish(MerchantSessionStatus.checking);
    try {
      final result = await repository.loadAccess().timeout(accessTimeout);
      if (_unavailable || epoch != _epoch) return;
      if (currentUserId() != id) {
        _observeIdentity();
        _failure(merchantSessionChanged);
        return;
      }
      result.fold(_failure, (access) {
        if (access == null || access.user.id != id) {
          _failure(merchantSessionChanged);
        } else if (!access.hasRole ||
            (access.shop != null && !access.canManage)) {
          ++_scopeRevision;
          _publish(MerchantSessionStatus.denied, access: access);
        } else {
          if (previous != null &&
              (previous.shop?.id != access.shop?.id ||
                  previous.shop?.updatedAt != access.shop?.updatedAt)) {
            ++_scopeRevision;
          }
          _publish(
            access.shop == null
                ? MerchantSessionStatus.onboarding
                : MerchantSessionStatus.ready,
            access: access,
          );
        }
      });
    } catch (_) {
      if (!_unavailable && epoch == _epoch) {
        _observeIdentity();
        _failure(
          currentUserId() == id
              ? 'Bağlantı kurulamadı. Lütfen tekrar deneyin.'
              : merchantSessionChanged,
        );
      }
    }
  }

  void _beginAuth(String message, MerchantSessionStatus status) {
    _observeIdentity();
    _authBusy = true;
    _authInterrupted = false;
    ++_epoch;
    if (status != MerchantSessionStatus.signedOut ||
        state.status != MerchantSessionStatus.signedOut) {
      ++_scopeRevision;
    }
    _publish(status, message: message);
  }

  Future<void> signIn(String email, String password) async {
    if (_authBusy || _unavailable || _monitorEnded || _recoveryActive) return;
    _beginAuth('Giriş yapılıyor…', MerchantSessionStatus.signedOut);
    final identity = _identityRevision;
    String? failure;
    try {
      final result = await credentials.signIn(email, password);
      result.fold((error) => failure = error, (_) {});
    } catch (_) {
      failure = 'Giriş yapılamadı. Lütfen yeniden deneyin.';
    } finally {
      _authBusy = false;
    }
    if (_unavailable) return;
    _observeIdentity();
    if (_authInterrupted || _monitorEnded) {
      _failure(_sessionFailureMessage);
    } else if (currentUserId() != null || identity != _identityRevision) {
      // The live identity wins over the late credential response, including a
      // successful login followed by a failed profile lookup or another logout.
      await reload();
    } else {
      _publish(MerchantSessionStatus.signedOut, message: failure);
    }
  }

  Future<void> signOut() async {
    if (_authBusy || _unavailable || _recoveryActive) return;
    _beginAuth('Güvenli çıkış yapılıyor…', MerchantSessionStatus.checking);
    final id = currentUserId();
    final identity = _identityRevision;
    String? failure;
    bool sameIdentity() =>
        currentUserId() == id && identity == _identityRevision;
    try {
      if (id != null) {
        // Preserve the shared revoke-before-logout contract. An account change
        // during revocation must not dispatch the old exit against the new user.
        await beforeSignOut?.call();
        _observeIdentity();
        if (!_unavailable && !_authInterrupted && sameIdentity()) {
          final result = await credentials.signOut();
          result.fold((error) => failure = error, (_) {});
        }
      }
    } catch (_) {
      failure = 'Güvenli çıkış tamamlanamadı. Yeniden deneyin.';
    } finally {
      _authBusy = false;
    }
    if (_unavailable) return;
    _observeIdentity();
    if (_authInterrupted || _monitorEnded) {
      _failure(_sessionFailureMessage);
    } else if (failure != null && sameIdentity()) {
      _failure(failure!);
    } else {
      await reload();
    }
  }

  @override
  Future<void> close() async {
    _closing = true;
    ++_epoch;
    await _subscription?.cancel();
    return super.close();
  }
}
