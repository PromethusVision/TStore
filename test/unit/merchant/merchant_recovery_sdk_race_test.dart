// Integration regression scenarios; only fixture wiring supplies the production staging factory.
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/features/merchant/data/supabase_merchant_recovery_backend.dart';
import 'package:t_store/features/merchant/domain/merchant_account_recovery.dart';

Map<String, dynamic> user(String id) => {
  'id': id,
  'email': '$id@fixture.invalid',
  'aud': 'authenticated',
  'role': 'authenticated',
  'created_at': '2026-01-01T00:00:00Z',
};
Map<String, dynamic> session(String id) => {
  'access_token':
      'e30.${base64Url.encode(utf8.encode(jsonEncode({'sub': id, 'session_id': '$id-session', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600}))).replaceAll('=', '')}.synthetic',
  'refresh_token': 'synthetic-$id-refresh',
  'token_type': 'bearer',
  'expires_in': 3600,
  'user': user(id),
};
http.Response response(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json'},
);
final callback = Uri.parse(
  'com.esnaftavar.app.merchant.pilot://login-callback/'
  '?token_hash=synthetic&type=recovery&auth_action=password_recovery',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  additionalRaces();
  test(
    'late recovery password response must preserve replacement account identity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final putEntered = Completer<void>(), releasePut = Completer<void>();
      final loginEntered = Completer<void>(), releaseLogin = Completer<void>();
      late http.Client transport;
      final client = SupabaseClient(
        'https://integration-fixture.invalid',
        'synthetic-client',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: transport = MockClient((r) async {
          if (r.url.path.endsWith('/verify')) {
            return response(session('merchant-a'));
          }
          if (r.url.path.endsWith('/token')) {
            loginEntered.complete();
            await releaseLogin.future;
            return response(session('merchant-b'));
          }
          if (r.method == 'PUT' && r.url.path.endsWith('/user')) {
            putEntered.complete();
            await releasePut.future;
            return response(user('merchant-a'));
          }
          return response({});
        }),
      );
      final backend = SupabaseMerchantRecoveryBackend(
        client,
        AuthCallbackContract.merchantPilot(),
        await SharedPreferences.getInstance(),
        createRecoveryClient: () => GoTrueClient(
          url: 'https://integration-fixture.invalid/auth/v1',
          httpClient: transport,
          autoRefreshToken: false,
        ),
      );
      final recovery = MerchantAccountRecovery(
        backend: backend,
        contract: AuthCallbackContract.merchantPilot(),
      );
      addTearDown(() async {
        recovery.dispose();
        await client.dispose();
      });
      // Login starts while the login screen is still available, before recovery.
      final login = client.auth.signInWithPassword(
        email: 'merchant-b@fixture.invalid',
        password: 'synthetic',
      );
      await loginEntered.future;
      await recovery.receive(callback);
      expect(recovery.stage, MerchantRecoveryStage.password);
      final update = recovery.update('synthetic-password');
      await putEntered.future;
      releaseLogin.complete();
      await login;
      expect(client.auth.currentUser!.id, 'merchant-b');
      expect(backend.sessionKey, 'merchant-b:merchant-b-session');
      releasePut.complete();
      await update;
      expect(recovery.stage, MerchantRecoveryStage.invalid);
      final tokenSub =
          (jsonDecode(
                utf8.decode(
                  base64Url.decode(
                    base64Url.normalize(
                      client.auth.currentSession!.accessToken.split('.')[1],
                    ),
                  ),
                ),
              )
              as Map)['sub'];
      expect(tokenSub, 'merchant-b');
      await recovery.dismiss();
      expect(recovery.stage, MerchantRecoveryStage.idle);
      expect(backend.hasPending, isFalse);
      expect(
        client.auth.currentUser!.id,
        'merchant-b',
        reason:
            'A delayed A password response must not replace B user metadata',
      );
      expect(backend.sessionKey, 'merchant-b:merchant-b-session');
    },
  );

  test(
    'late recovery exchange must not overwrite replacement sign-in',
    () async {
      SharedPreferences.setMockInitialValues({});
      final verifyEntered = Completer<void>(),
          releaseVerify = Completer<void>();
      final loginEntered = Completer<void>(), releaseLogin = Completer<void>();
      late http.Client transport;
      final client = SupabaseClient(
        'https://integration-fixture.invalid',
        'synthetic-client',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: transport = MockClient((r) async {
          if (r.url.path.endsWith('/verify')) {
            verifyEntered.complete();
            await releaseVerify.future;
            return response(session('merchant-a'));
          }
          if (r.url.path.endsWith('/token')) {
            loginEntered.complete();
            await releaseLogin.future;
            return response(session('merchant-b'));
          }
          return response({});
        }),
      );
      final backend = SupabaseMerchantRecoveryBackend(
        client,
        AuthCallbackContract.merchantPilot(),
        await SharedPreferences.getInstance(),
        createRecoveryClient: () => GoTrueClient(
          url: 'https://integration-fixture.invalid/auth/v1',
          httpClient: transport,
          autoRefreshToken: false,
        ),
      );
      final recovery = MerchantAccountRecovery(
        backend: backend,
        contract: AuthCallbackContract.merchantPilot(),
      );
      addTearDown(() async {
        recovery.dispose();
        await client.dispose();
      });
      final login = client.auth.signInWithPassword(
        email: 'merchant-b@fixture.invalid',
        password: 'synthetic',
      );
      await loginEntered.future;
      final exchange = recovery.receive(callback);
      await verifyEntered.future;
      releaseLogin.complete();
      await login;
      expect(client.auth.currentUser!.id, 'merchant-b');
      releaseVerify.complete();
      await exchange;
      expect(
        client.auth.currentUser!.id,
        'merchant-b',
        reason:
            'A recovery response must not silently replace a newer B sign-in',
      );
      expect(recovery.stage, MerchantRecoveryStage.invalid);
    },
  );
}

// The shared Supabase client and transient response clients use the identical
// HTTP fixture and PKCE storage, matching main_merchant_pilot composition.
class RaceStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  Completer<void>? removeEntered, removeGate;
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    if (removeGate != null) {
      removeEntered!.complete();
      await removeGate!.future;
    }
    values.remove(key);
  }
}

Map<String, dynamic> sessionWithId(String id, String sid, {int? expires}) {
  final data = session(id);
  data['access_token'] =
      'e30.${base64Url.encode(utf8.encode(jsonEncode({'sub': id, 'session_id': sid, 'exp': expires ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600}))).replaceAll('=', '')}.synthetic';
  if (expires != null) data['expires_in'] = 0;
  return data;
}

class RaceFixture {
  final pkce = RaceStorage();
  late final SupabaseClient client;
  late final SupabaseMerchantRecoveryBackend backend;
  late final MerchantAccountRecovery recovery;
  late final http.Client transport;
  Completer<void>? verifyGate, updateGate, logoutGate;
  final verifyEntered = Completer<void>(),
      updateEntered = Completer<void>(),
      logoutEntered = Completer<void>();
  String nextUser = 'merchant-a', nextSid = 'original';
  String updateUser = 'merchant-a';
  Map<String, dynamic> recoverySession = sessionWithId(
    'merchant-a',
    'recovery',
  );
  bool loseVerify = false, loseUpdate = false, loseLogout = false;
  int updates = 0, logouts = 0, creates = 0;

  Future<void> initialize() async {
    SharedPreferences.setMockInitialValues({});
    transport = MockClient((request) async {
      if (request.url.path.endsWith('/verify') ||
          request.url.queryParameters['grant_type'] == 'pkce') {
        if (!verifyEntered.isCompleted) verifyEntered.complete();
        await verifyGate?.future;
        if (loseVerify) {
          throw http.ClientException('Synthetic missing acknowledgement');
        }
        return response(recoverySession);
      }
      if (request.url.path.endsWith('/token')) {
        return response(sessionWithId(nextUser, nextSid));
      }
      if (request.method == 'PUT' && request.url.path.endsWith('/user')) {
        updates++;
        updateEntered.complete();
        await updateGate?.future;
        if (loseUpdate) {
          throw http.ClientException('Synthetic missing acknowledgement');
        }
        return response(user(updateUser));
      }
      if (request.url.path.endsWith('/logout')) {
        logouts++;
        logoutEntered.complete();
        await logoutGate?.future;
        if (loseLogout) {
          throw http.ClientException('Synthetic missing acknowledgement');
        }
      }
      return response({});
    });
    client = SupabaseClient(
      'https://recovery-race.invalid',
      'synthetic-client',
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: pkce,
      ),
      httpClient: transport,
    );
    backend = SupabaseMerchantRecoveryBackend(
      client,
      AuthCallbackContract.merchantPilot(),
      await SharedPreferences.getInstance(),
      createRecoveryClient: () {
        creates++;
        return GoTrueClient(
          url: 'https://recovery-race.invalid/auth/v1',
          headers: {'apikey': 'synthetic-client'},
          httpClient: transport,
          autoRefreshToken: false,
          asyncStorage: pkce,
        );
      },
    );
    recovery = MerchantAccountRecovery(
      backend: backend,
      contract: AuthCallbackContract.merchantPilot(),
    );
  }

  Future<void> login(String id, String sid) async {
    nextUser = id;
    nextSid = sid;
    await client.auth.signInWithPassword(
      email: '$id@fixture.invalid',
      password: 'synthetic',
    );
  }

  Future<void> transition(String kind) async {
    switch (kind) {
      case 'other-account':
        await login('merchant-b', 'replacement');
      case 'same-account':
        await login('merchant-a', 'replacement');
      case 'logout':
        await client.auth.signOut(scope: SignOutScope.local);
      case 'away-and-back':
        final original = client.auth.currentSession!.toJson();
        // Do not let a live-getter-only listener hide the middle identity.
        final out = client.auth.setInitialSession(
          jsonEncode(sessionWithId('merchant-b', 'middle')),
        );
        final back = client.auth.setInitialSession(jsonEncode(original));
        await Future.wait([out, back]);
    }
  }

  void expectIntegrity(String? expected) {
    expect(backend.sessionKey, expected);
    expect(backend.sessionConsistent, isTrue);
    final current = client.auth.currentSession;
    if (current != null) {
      final payload =
          jsonDecode(
                utf8.decode(
                  base64Url.decode(
                    base64Url.normalize(current.accessToken.split('.')[1]),
                  ),
                ),
              )
              as Map;
      expect(current.user.id, payload['sub']);
    }
  }

  Future<void> dispose() async {
    recovery.dispose();
    await client.dispose();
    transport.close();
  }
}

void additionalRaces() {
  late RaceFixture f;
  setUp(() async {
    f = RaceFixture();
    await f.initialize();
  });
  tearDown(() async {
    await f.dispose();
  });

  for (final pkce in [false, true]) {
    for (final transition in [
      'other-account',
      'same-account',
      'logout',
      'away-and-back',
    ]) {
      test(
        'staged ${pkce ? "PKCE" : "hash"} exchange rejects $transition',
        () async {
          await f.login('merchant-a', 'original');
          if (pkce) await f.backend.sendReset('merchant-a@fixture.invalid');
          f.verifyGate = Completer<void>();
          final operation = f.recovery.receive(
            pkce
                ? callback.replace(queryParameters: {'code': 'synthetic'})
                : callback,
          );
          await f.verifyEntered.future;
          await f.transition(transition);
          final expected = f.backend.sessionKey;
          final sessionBeforeResponse = f.client.auth.currentSession;
          f.verifyGate!.complete();
          await operation;
          f.expectIntegrity(expected);
          expect(f.client.auth.currentSession, same(sessionBeforeResponse));
          expect(f.recovery.stage, MerchantRecoveryStage.invalid);
          await f.recovery.update('synthetic-password');
          expect(f.updates, 0);
        },
      );
    }
  }

  for (final lost in [false, true]) {
    for (final transition in [
      'other-account',
      'same-account',
      'logout',
      'away-and-back',
    ]) {
      test(
        'staged update ${lost ? "lost" : "success"} response preserves $transition',
        () async {
          await f.recovery.receive(callback);
          f.updateGate = Completer<void>();
          f.loseUpdate = lost;
          final operation = f.recovery.update('synthetic-password');
          await f.updateEntered.future;
          await f.transition(transition);
          final expected = f.backend.sessionKey;
          final sessionBeforeResponse = f.client.auth.currentSession;
          f.updateGate!.complete();
          await operation;
          f.expectIntegrity(expected);
          expect(f.client.auth.currentSession, same(sessionBeforeResponse));
          expect(f.recovery.stage, MerchantRecoveryStage.invalid);
          await f.recovery.update('synthetic-password');
          expect(f.updates, 1);
          if (transition != 'away-and-back') {
            await f.recovery.dismiss();
            f.expectIntegrity(expected);
          }
        },
      );
    }
  }

  test(
    'account replacement during PKCE storage cleanup cannot commit',
    () async {
      await f.backend.sendReset('merchant-a@fixture.invalid');
      f.pkce.removeGate = Completer<void>();
      f.pkce.removeEntered = Completer<void>();
      final operation = f.recovery.receive(
        callback.replace(queryParameters: {'code': 'synthetic'}),
      );
      await f.pkce.removeEntered!.future;
      await f.login('merchant-b', 'replacement');
      f.pkce.removeGate!.complete();
      await operation;
      f.expectIntegrity('merchant-b:replacement');
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
    },
  );

  test(
    'lost exchange after replacement does not mutate or clear the new session',
    () async {
      f.verifyGate = Completer<void>();
      f.loseVerify = true;
      final operation = f.recovery.receive(callback);
      await f.verifyEntered.future;
      await f.login('merchant-b', 'replacement');
      f.verifyGate!.complete();
      await operation;
      await f.recovery.dismiss();
      f.expectIntegrity('merchant-b:replacement');
      expect(f.backend.hasPending, isTrue);
      expect(f.recovery.canDismiss, isFalse);
      expect(f.logouts, 0);
    },
  );

  test('mixed provider response never reaches shared Auth', () async {
    await f.login('merchant-b', 'original');
    f.recoverySession['user'] = user('merchant-b');
    await f.recovery.receive(callback);
    f.expectIntegrity('merchant-b:original');
    expect(f.recovery.stage, MerchantRecoveryStage.invalid);
    await f.recovery.dismiss();
    expect(f.logouts, 0);
  });

  test(
    'preexisting mixed shared session cannot silently clear pending',
    () async {
      final mixed = sessionWithId('merchant-b', 'replacement')
        ..['user'] = user('merchant-a');
      await f.client.auth.setInitialSession(jsonEncode(mixed));
      await f.backend.setPending(true);
      f.recovery.restorePending();
      await f.recovery.dismiss();
      expect(f.backend.sessionConsistent, isFalse);
      expect(f.backend.hasPending, isTrue);
      expect(f.recovery.blocksWorkspace, isTrue);
      expect(f.recovery.canDismiss, isFalse);
    },
  );

  test(
    'mismatched update stays isolated and cannot contaminate grant',
    () async {
      await f.recovery.receive(callback);
      f.updateUser = 'merchant-b';
      await f.recovery.update('synthetic-password');
      f.expectIntegrity('merchant-a:recovery');
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
      await f.recovery.dismiss();
      f.expectIntegrity(null);
      expect(f.backend.hasPending, isFalse);
    },
  );

  test(
    'same-session token refresh permits pending update and fresh login',
    () async {
      await f.recovery.receive(callback);
      f.updateGate = Completer<void>();
      final operation = f.recovery.update('synthetic-password');
      await f.updateEntered.future;
      f.nextUser = 'merchant-a';
      f.nextSid = 'recovery';
      await f.client.auth.refreshSession();
      f.updateGate!.complete();
      await operation;
      expect(f.recovery.stage, MerchantRecoveryStage.complete);
      f.expectIntegrity(null);
      expect(f.backend.hasPending, isFalse);
    },
  );

  test('replacement while logout response is pending remains intact', () async {
    await f.recovery.receive(callback);
    f.logoutGate = Completer<void>();
    final operation = f.recovery.update('synthetic-password');
    await f.logoutEntered.future;
    await f.login('merchant-b', 'replacement');
    f.logoutGate!.complete();
    await operation;
    f.expectIntegrity('merchant-b:replacement');
    expect(f.recovery.stage, MerchantRecoveryStage.invalid);
    expect(f.backend.hasPending, isTrue);
    await f.recovery.dismiss();
    f.expectIntegrity('merchant-b:replacement');
    expect(f.logouts, 1);
  });

  test(
    'lost cleanup acknowledgement stays gated until explicit safe retry',
    () async {
      await f.recovery.receive(callback);
      f.loseLogout = true;
      await f.recovery.update('synthetic-password');
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
      expect(f.backend.hasPending, isTrue);
      f.expectIntegrity(null);
      await f.recovery.dismiss();
      expect(f.backend.hasPending, isFalse);
      expect(f.updates, 1);
      expect(f.logouts, 1);
    },
  );

  test(
    'disposing a pending verification cannot later publish its session',
    () async {
      f.verifyGate = Completer<void>();
      final operation = f.recovery.receive(callback);
      await f.verifyEntered.future;
      f.backend.dispose();
      f.verifyGate!.complete();
      await operation;
      f.expectIntegrity(null);
      expect(f.backend.hasPending, isTrue);
    },
  );

  test(
    'expired staged recovery never invokes shared refresh or import',
    () async {
      f.recoverySession = sessionWithId('merchant-a', 'expired', expires: 1);
      await f.recovery.receive(callback);
      f.expectIntegrity(null);
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
    },
  );
  test(
    'returning to an old session cannot revive the verified grant',
    () async {
      await f.recovery.receive(callback);
      await f.transition('away-and-back');
      await f.recovery.update('synthetic-password');
      await expectLater(
        f.backend.updatePassword('synthetic-password'),
        throwsStateError,
      );
      expect(f.updates, 0);
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
      f.expectIntegrity('merchant-a:recovery');
    },
  );
  test(
    'ordinary second PKCE link preserves the old recovery session for cleanup',
    () async {
      await f.recovery.receive(callback);
      f.pkce.values['supabase.auth.token-code-verifier'] = 'synthetic/signedIn';
      await f.recovery.receive(
        callback.replace(queryParameters: {'code': 'second'}),
      );
      expect(f.recovery.stage, MerchantRecoveryStage.invalid);
      f.expectIntegrity('merchant-a:recovery');
      await f.recovery.dismiss();
      f.expectIntegrity(null);
      expect(f.logouts, 1);
      expect(f.backend.hasPending, isFalse);
    },
  );
}
