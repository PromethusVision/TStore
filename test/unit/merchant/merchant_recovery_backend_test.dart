import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_recovery_backend.dart';

class _Storage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

Map<String, dynamic> _user([String id = 'merchant-a']) => {
  'id': id,
  'email': 'merchant@fixture.invalid',
  'aud': 'authenticated',
  'role': 'authenticated',
  'created_at': '2026-01-01T00:00:00Z',
};
Map<String, dynamic> _session() => {
  'access_token':
      'e30.${base64Url.encode(utf8.encode(jsonEncode({'sub': 'merchant-a', 'session_id': 'session-a', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600}))).replaceAll('=', '')}.signature',
  'refresh_token': 'synthetic-refresh',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': _user(),
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SupabaseClient client;
  late SupabaseMerchantRecoveryBackend backend;
  late _Storage pkce;
  late List<http.Request> calls;
  late String updateId;
  late int updateStatus;
  setUp(() async {
    calls = [];
    pkce = _Storage();
    updateId = 'merchant-a';
    updateStatus = 200;
    SharedPreferences.setMockInitialValues({});
    client = SupabaseClient(
      'https://merchant-recovery.invalid',
      'synthetic-client',
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: pkce,
      ),
      httpClient: MockClient((r) async {
        calls.add(r);
        final path = r.url.pathSegments.last;
        Object body = {};
        var status = 200;
        if (path == 'verify' || path == 'token') body = _session();
        if (path == 'user') {
          body = _user(updateId);
          status = updateStatus;
        }
        return http.Response(
          jsonEncode(body),
          status,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    backend = SupabaseMerchantRecoveryBackend(
      client,
      AuthCallbackContract.merchantPilot(),
      await SharedPreferences.getInstance(),
    );
  });
  tearDown(() async {
    await client.dispose();
  });
  test(
    'reset request uses the Merchant callback and PKCE, not Customer redirect',
    () async {
      await backend.sendReset('merchant@fixture.invalid');
      final call = calls.single;
      expect(call.url.path, '/auth/v1/recover');
      expect(
        call.url.queryParameters['redirect_to'],
        'com.esnaftavar.app.merchant.pilot://login-callback/?auth_action=password_recovery',
      );
      final body = jsonDecode(call.body) as Map;
      expect(body['code_challenge'], isNotEmpty);
      expect(body['code_challenge_method'], 's256');
      expect(pkce.values.values.single, endsWith('/passwordRecovery'));
    },
  );
  test(
    'recovery PKCE proof is derived from provider storage, not supplied type',
    () async {
      await backend.sendReset('merchant@fixture.invalid');
      final grant = await backend.verifyRecovery(
        Uri.parse(
          'com.esnaftavar.app.merchant.pilot://login-callback/?code=synthetic',
        ),
      );
      expect(grant.recovery, isTrue);
      expect(grant.sessionKey, 'merchant-a:session-a');
      expect(backend.sessionKey, grant.sessionKey);
      final exchange = calls.last;
      expect(exchange.url.queryParameters['grant_type'], 'pkce');
      expect((jsonDecode(exchange.body) as Map)['auth_code'], 'synthetic');
      expect(pkce.values, isEmpty);
    },
  );
  test('ordinary PKCE is not a password-recovery grant', () async {
    pkce.values['supabase.auth.token-code-verifier'] =
        'synthetic-verifier/signedIn';
    final grant = await backend.verifyRecovery(
      Uri.parse(
        'com.esnaftavar.app.merchant.pilot://login-callback/?code=synthetic&auth_action=password_recovery',
      ),
    );
    expect(grant.recovery, isFalse);
  });
  test('missing PKCE verifier sends no exchange request', () async {
    await expectLater(
      backend.verifyRecovery(
        Uri.parse(
          'com.esnaftavar.app.merchant.pilot://login-callback/?code=synthetic',
        ),
      ),
      throwsA(isA<AuthException>()),
    );
    expect(calls, isEmpty);
  });
  test('direct token hash is submitted as recovery only', () async {
    final grant = await backend.verifyRecovery(
      Uri.parse(
        'com.esnaftavar.app.merchant.pilot://login-callback/?token_hash=synthetic&type=recovery',
      ),
    );
    expect(grant.recovery, isTrue);
    expect(grant.sessionKey, 'merchant-a:session-a');
    expect(jsonDecode(calls.single.body), containsPair('type', 'recovery'));
  });
  test(
    'password update requires a session and cleanup is explicitly local',
    () async {
      await expectLater(
        backend.updatePassword('synthetic-password'),
        throwsStateError,
      );
      expect(calls, isEmpty);
      await backend.verifyRecovery(
        Uri.parse(
          'com.esnaftavar.app.merchant.pilot://login-callback/?token_hash=synthetic&type=recovery',
        ),
      );
      await backend.updatePassword('synthetic-password');
      final update = calls.last;
      expect(update.method, 'PUT');
      expect(
        jsonDecode(update.body),
        containsPair('password', 'synthetic-password'),
      );
      await backend.clearLocalSession();
      expect(calls.last.url.queryParameters['scope'], 'local');
      expect(backend.sessionKey, isNull);
    },
  );
  test('mismatched update identity never claims success', () async {
    await backend.verifyRecovery(
      Uri.parse(
        'com.esnaftavar.app.merchant.pilot://login-callback/?token_hash=synthetic&type=recovery',
      ),
    );
    updateId = 'merchant-b';
    await expectLater(
      backend.updatePassword('synthetic-password'),
      throwsStateError,
    );
  });
  test(
    'durable marker stores only a boolean and survives adapter reconstruction',
    () async {
      await backend.setPending(true);
      final storage = await SharedPreferences.getInstance();
      expect(storage.getKeys(), {SupabaseMerchantRecoveryBackend.pendingKey});
      final restored = SupabaseMerchantRecoveryBackend(
        client,
        AuthCallbackContract.merchantPilot(),
        storage,
      );
      expect(restored.hasPending, isTrue);
      await restored.setPending(false);
      expect(restored.hasPending, isFalse);
    },
  );
}
