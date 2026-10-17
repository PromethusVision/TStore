import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/auth_callback_contract.dart';
import '../domain/merchant_account_recovery.dart';

class SupabaseMerchantRecoveryBackend implements MerchantRecoveryBackend {
  SupabaseMerchantRecoveryBackend(
    this.client,
    this.contract,
    this.storage, {
    required this.createRecoveryClient,
  });
  final SupabaseClient client;
  final AuthCallbackContract contract;
  final SharedPreferences storage;

  /// A disposable SDK response buffer against the SAME Auth provider/PKCE store.
  /// No auto-refresh, session persistence, listeners or application services.
  /// Never pass the shared auth client: GoTrue mutates it before returning.
  final GoTrueClient Function() createRecoveryClient;
  _RecoverySessionLease? _grantLease;
  bool _disposed = false;
  static const pendingKey = 'merchant.pilot.auth.recovery_pending';
  bool get hasPending => storage.getBool(pendingKey) ?? false;
  @override
  String? get sessionKey => _key(client.auth.currentSession);
  @override
  bool get sessionConsistent =>
      client.auth.currentSession == null || sessionKey != null;
  @override
  Stream<String?> get sessionChanges =>
      client.auth.onAuthStateChange.map((event) => _key(event.session));
  @override
  Future<void> setPending(bool pending) async {
    if (_disposed || (!pending && !sessionConsistent)) {
      throw StateError('Recovery session integrity unavailable');
    }
    if (!await storage.setBool(pendingKey, pending)) {
      throw StateError('Recovery marker unavailable');
    }
    if (!pending && !sessionConsistent) {
      await storage.setBool(pendingKey, true);
      throw StateError('Recovery session integrity changed');
    }
  }

  @override
  Future<void> sendReset(String email) => client.auth.resetPasswordForEmail(
    email,
    redirectTo: contract.emailRedirectFor(
      appUri: Uri(),
      isWeb: false,
      action: AuthEmailRedirectAction.passwordRecovery,
    ),
  );
  @override
  Future<MerchantRecoveryGrant> verifyRecovery(Uri uri) async {
    if (_disposed) throw StateError('Recovery disposed');
    final lease = _RecoverySessionLease(client.auth);
    GoTrueClient? staged;
    var retained = false;
    try {
      staged = _createStagingClient();
      lease.check();
      Session? session;
      bool recovery;
      if (uri.queryParameters.containsKey('code')) {
        final result = await staged.exchangeCodeForSession(
          uri.queryParameters['code']!,
        );
        session = result.session;
        recovery = result.redirectType == AuthChangeEvent.passwordRecovery.name;
      } else {
        final result = await staged.verifyOTP(
          tokenHash: uri.queryParameters['token_hash']!,
          type: OtpType.recovery,
        );
        session = result.session;
        recovery = session != null;
      }
      // Include the SDK's asynchronous PKCE storage removal in the lease.
      // No provider response has touched the shared session at this point.
      lease.check();
      if (_disposed) throw StateError('Recovery disposed');
      if (!recovery) return const MerchantRecoveryGrant(null, recovery: false);
      final key = _key(session);
      final expires = session?.expiresAt;
      if (key == null ||
          expires == null ||
          expires <= DateTime.now().millisecondsSinceEpoch ~/ 1000 + 30) {
        throw StateError(
          'Recovery returned an inconsistent or expired session',
        );
      }
      // This public SDK import applies a validated session synchronously before
      // its Future yields. Unlike recoverSession/setSession, it cannot dispatch
      // a refresh request. The shared SDK still owns persistence and events.
      lease.expectCommit(key);
      await client.auth.setInitialSession(jsonEncode(session!.toJson()));
      lease.check();
      if (_disposed) throw StateError('Recovery disposed');
      _grantLease?.dispose();
      _grantLease = lease;
      retained = true;
      return MerchantRecoveryGrant(key, recovery: true);
    } finally {
      staged?.dispose();
      if (!retained) lease.dispose();
    }
  }

  static String? _key(Session? session) {
    if (session == null) return null;
    try {
      final payload =
          jsonDecode(
                utf8.decode(
                  base64Url.decode(
                    base64Url.normalize(session.accessToken.split('.')[1]),
                  ),
                ),
              )
              as Map;
      final id = payload['session_id'];
      return id is String && id.isNotEmpty && payload['sub'] == session.user.id
          ? '${session.user.id}:$id'
          : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updatePassword(String password) async {
    final lease = _grantLease;
    final snapshot = client.auth.currentSession;
    if (_disposed || lease == null || snapshot == null) {
      throw StateError('Recovery session missing');
    }
    lease.check();
    final staged = _createStagingClient();
    try {
      await staged.setInitialSession(jsonEncode(snapshot.toJson()));
      lease.check();
      if (_disposed) throw StateError('Recovery disposed');
      final result = await staged.updateUser(
        UserAttributes(password: password),
      );
      lease.check();
      if (_disposed ||
          result.user?.id != snapshot.user.id ||
          _key(staged.currentSession) != lease.expectedKey) {
        throw StateError('Recovery session changed');
      }
      // Deliberately do not copy user metadata back. The next step is logout;
      // late responses must never rewrite any shared session object.
    } finally {
      staged.dispose();
    }
  }

  @override
  Future<void> clearLocalSession() async {
    if (_disposed || !sessionConsistent) throw StateError('Unsafe cleanup');
    if (client.auth.currentSession != null) _grantLease?.check();
    await client.auth.signOut(scope: SignOutScope.local);
    if (client.auth.currentSession != null) {
      throw StateError('Session replaced during cleanup');
    }
    _grantLease?.dispose();
    _grantLease = null;
  }

  GoTrueClient _createStagingClient() {
    final staged = createRecoveryClient();
    if (identical(staged, client.auth)) {
      throw StateError(
        'Recovery must not mutate the shared SDK response target',
      );
    }
    return staged;
  }

  @override
  void dispose() {
    _disposed = true;
    _grantLease?.dispose();
  }
}

/// Monotonic invalidation: a switch away and back cannot revive an operation.
/// Event snapshots matter: the live getter alone loses intermediate accounts.
class _RecoverySessionLease {
  _RecoverySessionLease(this.auth) : expectedKey = _key(auth.currentSession) {
    _subscription = auth.onAuthStateChange.listen(
      (event) {
        if (!_consistent(event.session) || _key(event.session) != expectedKey) {
          _invalid = true;
        }
      },
      onError: (Object _) => _invalid = true,
      onDone: () => _invalid = true,
    );
  }
  final GoTrueClient auth;
  String? expectedKey;
  bool _invalid = false;
  late final StreamSubscription<AuthState> _subscription;
  static String? _key(Session? session) =>
      SupabaseMerchantRecoveryBackend._key(session);
  static bool _consistent(Session? session) =>
      session == null || _key(session) != null;
  void check() {
    if (_invalid ||
        !_consistent(auth.currentSession) ||
        _key(auth.currentSession) != expectedKey) {
      _invalid = true;
      throw StateError('Recovery session was replaced');
    }
  }

  void expectCommit(String key) {
    check();
    expectedKey = key;
  }

  void dispose() {
    _invalid = true;
    unawaited(_subscription.cancel());
  }
}
