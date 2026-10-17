import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/supabase/auth_callback_contract.dart';

enum MerchantRecoveryStage {
  idle,
  request,
  sending,
  sent,
  verifying,
  password,
  updating,
  invalid,
  complete,
  cleanupFailed,
}

class MerchantRecoveryGrant {
  const MerchantRecoveryGrant(this.sessionKey, {required this.recovery});
  final String? sessionKey;
  final bool recovery;
}

/// Auth stays in the shared provider. This port contains no role/shop authority.
abstract interface class MerchantRecoveryBackend {
  String? get sessionKey;
  bool get sessionConsistent;

  /// Snapshot identity at the event, not the possibly newer current getter.
  Stream<String?> get sessionChanges;
  Future<void> sendReset(String email);

  /// True only for a verified recovery exchange, never a query-marker alone.
  Future<MerchantRecoveryGrant> verifyRecovery(Uri uri);
  Future<void> updatePassword(String password);
  Future<void> clearLocalSession();
  Future<void> setPending(bool pending);
  void dispose();
}

/// Owns one recovery operation and blocks private navigation until it is settled.
/// No passwords, callback tokens or email addresses enter notifier state.
class MerchantAccountRecovery extends ChangeNotifier {
  MerchantAccountRecovery({required this.backend, required this.contract}) {
    _observedIdentity = backend.sessionKey;
    _sessions = backend.sessionChanges.listen(
      (key) {
        if (key != _observedIdentity) {
          _observedIdentity = key;
          _identityRevision++;
        }
        if (_recoverySession != null && key != _recoverySession) {
          _grantInterrupted = true;
        }
        if (stage == MerchantRecoveryStage.password && !_sameSession) {
          _invalid();
        }
      },
      onError: (Object _) {
        _monitorBroken = true;
        if (blocksWorkspace && !busy) _invalid();
      },
      onDone: () {
        _monitorBroken = true;
        if (blocksWorkspace && !busy) _invalid();
      },
    );
  }
  final MerchantRecoveryBackend backend;
  final AuthCallbackContract contract;
  late final StreamSubscription<String?> _sessions;
  MerchantRecoveryStage stage = MerchantRecoveryStage.idle;
  String? message;
  String? _recoverySession;
  bool _disposed = false, _monitorBroken = false, _ambiguousSession = false;
  bool _grantInterrupted = false;
  String? _observedIdentity;
  int _identityRevision = 0;
  int revision = 0;
  // Only retained in memory to coalesce app_links initial/stream duplicates.
  final _seen = <String>{};
  bool get blocksWorkspace => stage != MerchantRecoveryStage.idle;
  bool get canDismiss =>
      !busy && !_ambiguousSession && backend.sessionConsistent;
  bool get busy => [
    MerchantRecoveryStage.sending,
    MerchantRecoveryStage.verifying,
    MerchantRecoveryStage.updating,
  ].contains(stage);
  bool get _sameSession =>
      !_monitorBroken &&
      !_grantInterrupted &&
      backend.sessionConsistent &&
      _recoverySession != null &&
      backend.sessionKey == _recoverySession;
  void restorePending() {
    if (busy) {
      _monitorBroken = true;
      return;
    }
    _recoverySession = backend.sessionKey;
    _ambiguousSession = false;
    _invalid();
  }

  void _set(MerchantRecoveryStage value, [String? text]) {
    if (_disposed) return;
    stage = value;
    message = text;
    notifyListeners();
  }

  void _invalid() {
    revision++;
    _set(
      MerchantRecoveryStage.invalid,
      _ambiguousSession || _monitorBroken || !backend.sessionConsistent
          ? 'Oturum güvenle doğrulanamadı. Uygulamayı kapatıp yeniden açın.'
          : 'Bağlantı veya oturum doğrulanamadı. Yeni bir şifre yenileme bağlantısı isteyin.',
    );
  }

  void request() {
    if (busy || _disposed || blocksWorkspace) return;
    revision++;
    _set(MerchantRecoveryStage.request);
  }

  Future<void> send(String email) async {
    if (stage != MerchantRecoveryStage.request || busy || _disposed) return;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      _set(MerchantRecoveryStage.request, 'Geçerli e-posta girin.');
      return;
    }
    _set(MerchantRecoveryStage.sending);
    try {
      await backend.sendReset(email.trim());
      _set(
        MerchantRecoveryStage.sent,
        'Hesabınız uygunsa şifre yenileme e-postası gönderilir. Bağlantıyı bu telefonda açın.',
      );
    } catch (_) {
      _set(
        MerchantRecoveryStage.request,
        'Gönderim doğrulanamadı. E-postanızı kontrol edin veya yeniden deneyin.',
      );
    }
  }

  Future<void> receive(Uri uri) async {
    if (_disposed ||
        !contract.acceptsCallbackBase(uri: uri, appUri: Uri(), isWeb: false)) {
      return;
    }
    if (busy || _seen.contains(uri.toString())) return;
    if (_seen.length == 16) _seen.remove(_seen.first);
    _seen.add(uri.toString());
    revision++;
    final params = uri.queryParametersAll;
    final code = uri.queryParameters['code'];
    final token = uri.queryParameters['token_hash'];
    final action = uri.queryParameters['auth_action'];
    final valid =
        uri.toString().length <= 8192 &&
        params.values.every((v) => v.length == 1) &&
        params.keys.every(
          ['code', 'token_hash', 'type', 'auth_action'].contains,
        ) &&
        (action == null ||
            action == AuthCallbackContract.passwordRecoveryAction) &&
        ((code != null &&
                code.trim().isNotEmpty &&
                token == null &&
                !params.containsKey('type')) ||
            (token != null &&
                token.trim().isNotEmpty &&
                code == null &&
                action == AuthCallbackContract.passwordRecoveryAction &&
                uri.queryParameters['type'] == 'recovery'));
    if (!valid) {
      _invalid();
      return;
    }
    final priorGrant = _recoverySession;
    final beforeExchange = backend.sessionKey;
    // The SDK changes its live value before its asynchronous event arrives.
    // Synchronize the baseline so that already-completed normal login is not
    // mistaken for a change during the following pending-marker write.
    if (_observedIdentity != beforeExchange) {
      _observedIdentity = beforeExchange;
      _identityRevision++;
    }
    final beforeRevision = _identityRevision;
    var dispatched = false;
    _recoverySession = null;
    _grantInterrupted = false;
    _ambiguousSession = false;
    _set(MerchantRecoveryStage.verifying);
    try {
      await backend.setPending(true);
      if (_disposed) return;
      // A login can settle while the durable marker is being written, before
      // the SDK adapter gets a chance to capture its own session lease.
      if (_identityRevision != beforeRevision ||
          backend.sessionKey != beforeExchange ||
          !backend.sessionConsistent) {
        throw StateError('Session changed before recovery dispatch');
      }
      dispatched = true;
      final grant = await backend.verifyRecovery(uri);
      if (_disposed) return;
      // A rejected staged link may intentionally leave shared Auth untouched.
      // Retain the previous verified recovery identity for explicit cleanup.
      _recoverySession = grant.recovery
          ? grant.sessionKey
          : (grant.sessionKey ?? priorGrant);
      if (!grant.recovery || !_sameSession) {
        _invalid();
        return;
      }
      _set(MerchantRecoveryStage.password);
    } catch (_) {
      // A failed exchange is not proof that the current session belongs to it.
      // Preserve only an already verified grant. If the identity changed and
      // no result identifies it, restart recovery instead of logging it out or
      // exposing a potentially half-completed recovery session.
      _recoverySession = priorGrant;
      _ambiguousSession =
          dispatched &&
          backend.sessionKey != beforeExchange &&
          backend.sessionKey != priorGrant;
      _invalid();
    }
  }

  Future<void> update(String password) async {
    if (_disposed || busy || stage != MerchantRecoveryStage.password) return;
    if (!_sameSession) {
      _invalid();
      return;
    }
    if (password.length < 8) {
      _set(MerchantRecoveryStage.password, 'En az 8 karakter kullanın.');
      return;
    }
    _set(MerchantRecoveryStage.updating);
    try {
      await backend.updatePassword(password);
      if (_disposed) return;
      if (!_sameSession) {
        _invalid();
        return;
      }
      await backend.clearLocalSession();
      if (_disposed) return;
      if (backend.sessionKey != null) {
        _invalid();
        return;
      }
      await backend.setPending(false);
      if (_disposed) return;
      _recoverySession = null;
      _set(
        MerchantRecoveryStage.complete,
        'Şifreniz yenilendi. Yeni şifrenizle giriş yapın.',
      );
    } catch (_) {
      // A missing acknowledgement does not prove that the password stayed old.
      // Require a new link/fresh login, never auto-repeat the update.
      _set(
        MerchantRecoveryStage.invalid,
        'İşlemin sonucu doğrulanamadı. Yeni şifrenizle giriş yapmayı deneyin; gerekirse yeni bağlantı isteyin.',
      );
    }
  }

  Future<void> dismiss() async {
    if (_disposed || busy) return;
    if (_ambiguousSession || !backend.sessionConsistent) {
      _invalid();
      return;
    }
    _set(MerchantRecoveryStage.updating);
    if (_recoverySession != null && backend.sessionKey == _recoverySession) {
      _set(MerchantRecoveryStage.updating);
      try {
        await backend.clearLocalSession();
        if (_disposed) return;
        if (backend.sessionKey != null) throw StateError('Session not cleared');
      } catch (_) {
        _set(
          MerchantRecoveryStage.cleanupFailed,
          'Şifre yenileme oturumu kapatılamadı. Yeniden deneyin.',
        );
        return;
      }
    }
    try {
      await backend.setPending(false);
      if (_disposed) return;
      _recoverySession = null;
      revision++;
      _set(MerchantRecoveryStage.idle);
    } catch (_) {
      _set(
        MerchantRecoveryStage.cleanupFailed,
        'Güvenli çıkış tamamlanamadı. Yeniden deneyin.',
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_sessions.cancel());
    backend.dispose();
    _seen.clear();
    super.dispose();
  }
}
