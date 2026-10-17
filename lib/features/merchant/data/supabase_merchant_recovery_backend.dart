import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/auth_callback_contract.dart';
import '../../../core/supabase/authenticated_session_key.dart';
import '../domain/merchant_account_recovery.dart';

class SupabaseMerchantRecoveryBackend implements MerchantRecoveryBackend {
  SupabaseMerchantRecoveryBackend(this.client, this.contract, this.storage);
  final SupabaseClient client;
  final AuthCallbackContract contract;
  final SharedPreferences storage;
  static const pendingKey = 'merchant.pilot.auth.recovery_pending';
  bool get hasPending => storage.getBool(pendingKey) ?? false;
  @override
  String? get sessionKey => authenticatedSessionKey(client);
  @override
  Stream<void> get sessionChanges => client.auth.onAuthStateChange.map((_) {});
  @override
  Future<void> setPending(bool pending) async {
    if (!await storage.setBool(pendingKey, pending)) {
      throw StateError('Recovery marker unavailable');
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
    Session? session;
    bool recovery;
    if (uri.queryParameters.containsKey('code')) {
      final result = await client.auth.exchangeCodeForSession(
        uri.queryParameters['code']!,
      );
      session = result.session;
      recovery = result.redirectType == AuthChangeEvent.passwordRecovery.name;
    } else {
      final result = await client.auth.verifyOTP(
        tokenHash: uri.queryParameters['token_hash']!,
        type: OtpType.recovery,
      );
      session = result.session;
      recovery = session != null;
    }
    return MerchantRecoveryGrant(_key(session), recovery: recovery);
  }

  String? _key(Session? session) {
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
      return id is String && id.isNotEmpty ? '${session.user.id}:$id' : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updatePassword(String password) async {
    final expected = sessionKey;
    final userId = client.auth.currentUser?.id;
    if (expected == null || userId == null) {
      throw StateError('Recovery session missing');
    }
    final result = await client.auth.updateUser(
      UserAttributes(password: password),
    );
    if (sessionKey != expected || result.user?.id != userId) {
      throw StateError('Recovery session changed');
    }
  }

  @override
  Future<void> clearLocalSession() =>
      client.auth.signOut(scope: SignOutScope.local);
}
