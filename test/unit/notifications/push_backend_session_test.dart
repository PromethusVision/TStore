import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/notifications/data/repositories/push_backend_adapter.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';

void main() {
  const owner = PushIdentity('fixture-user', NotificationAppRole.merchant);
  late SupabaseClient client;
  late SupabasePushBackend backend;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) response;
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> authenticate({
    String user = 'fixture-user',
    String? session = 's1',
    int refresh = 0,
  }) => client.auth
      // Same-account recoverSession does not publish an Auth event in this SDK.
      // The app's recovery adapter uses this event-emitting import as well.
      .setInitialSession(
        jsonEncode({
          'access_token':
              '${segment({'alg': 'none', 'typ': 'JWT'})}.${segment({'sub': user, if (session != null) 'session_id': session, 'nonce': refresh, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
          'token_type': 'bearer',
          'refresh_token': 'synthetic-only',
          'user': {
            'id': user,
            'app_metadata': {},
            'user_metadata': {},
            'aud': 'authenticated',
            'created_at': '2026-01-01T00:00:00Z',
          },
        }),
      )
      .then((_) {});
  http.Response json(Object? body) => http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
  setUp(() async {
    requests = [];
    response = (request) async => json(
      request.url.path.endsWith('/notifications')
          ? {
              'id': 'notice',
              'user_id': owner.userId,
              'title': 'Fixture',
              'body': 'Fixture',
              'type': 'system',
              'data': {'app_role': 'merchant'},
            }
          : request.method == 'GET'
          ? {'service_enabled': false, 'marketing_enabled': false}
          : null,
    );
    client = SupabaseClient(
      'https://push-fixture.invalid',
      'synthetic-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        final result = await response(request);
        return http.Response.bytes(
          result.bodyBytes,
          result.statusCode,
          headers: result.headers,
          request: request,
        );
      }),
    );
    await authenticate();
    backend = SupabasePushBackend(client, deployed: true);
  });
  tearDown(() async => client.dispose());
  Future<Object?> operation(String name) => switch (name) {
    'register' => backend.register(
      const PushDeviceRegistration(
        identity: owner,
        installationId: 'installation',
        token: 'synthetic-token',
        platform: PushPlatform.android,
      ),
    ),
    'disable' => backend.disable(owner, 'installation'),
    'read' => backend.read(owner),
    'save' => backend.save(owner, const NotificationPreferences()),
    _ => backend.lookup('notice'),
  };
  test(
    'session key survives token refresh and changes on same-user replacement',
    () async {
      final key = authenticatedSessionKey(client);
      await authenticate(refresh: 1);
      expect(authenticatedSessionKey(client), key);
      await authenticate(session: 's2');
      expect(authenticatedSessionKey(client), isNot(key));
      await authenticate(session: null);
      expect(authenticatedSessionKey(client), isNull);
    },
  );
  test('captured session keeps its identity after live replacement', () async {
    final captured = client.auth.currentSession;
    await authenticate(session: 's2');

    expect(authenticatedSessionKeyFromSession(captured), 'fixture-user:s1');
    expect(authenticatedSessionKey(client), 'fixture-user:s2');
    expect(authenticatedSessionKeyFromSession(null), isNull);
  });
  for (final name in ['register', 'disable', 'read', 'save', 'lookup']) {
    test(
      '$name rejects a new Auth session arriving during HTTP response',
      () async {
        final normal = response;
        response = (request) async {
          final result = await normal(request);
          await authenticate(session: 's2');
          return result;
        };
        if (name == 'lookup') {
          expect(await operation(name), isNull);
        } else {
          await expectLater(operation(name), throwsStateError);
        }
        expect(requests, hasLength(1));
      },
    );
    test('$name permits refresh within same session', () async {
      final normal = response;
      response = (request) async {
        final result = await normal(request);
        await authenticate(refresh: 2);
        return result;
      };
      await operation(name);
      expect(requests, hasLength(1));
    });
    test('$name rejects an intervening S1-S2-S1 session replacement', () async {
      final normal = response;
      response = (request) async {
        final result = await normal(request);
        await authenticate(session: 's2');
        await authenticate(session: 's1', refresh: 3);
        await pumpEventQueue();
        return result;
      };
      if (name == 'lookup') {
        expect(await operation(name), isNull);
      } else {
        await expectLater(operation(name), throwsStateError);
      }
      expect(requests, hasLength(1));
    });
    test('$name pending schema performs no HTTP', () async {
      backend = SupabasePushBackend(client);
      if (name == 'lookup') {
        expect(await operation(name), isNull);
      } else {
        await expectLater(operation(name), throwsStateError);
      }
      expect(requests, isEmpty);
    });
  }
  for (final field in ['service_enabled', 'marketing_enabled']) {
    test('existing preference row with missing $field is rejected', () async {
      response = (_) async => json({
        if (field != 'service_enabled') 'service_enabled': true,
        if (field != 'marketing_enabled') 'marketing_enabled': false,
      });
      await expectLater(backend.read(owner), throwsFormatException);
    });
  }
  test(
    'absent preference row retains service on and marketing off defaults',
    () async {
      response = (_) async => json(null);
      final preferences = await backend.read(owner);
      expect(preferences.service, isTrue);
      expect(preferences.marketing, isFalse);
    },
  );
  for (final failure in [false, true]) {
    test(
      'reopened backend waits for pending write, then reads after ${failure ? 'lost acknowledgement' : 'success'}',
      () async {
        final gate = Completer<http.Response>();
        response = (request) => request.method == 'POST'
            ? gate.future
            : Future.value(
                json({'service_enabled': true, 'marketing_enabled': true}),
              );
        final saving = backend.save(
          owner,
          const NotificationPreferences(marketing: true),
        );
        final saved = failure
            ? expectLater(saving, throwsA(isA<PostgrestException>()))
            : saving;
        await pumpEventQueue();
        final reopened = SupabasePushBackend(client, deployed: true);
        final reading = reopened.read(owner);
        await expectLater(
          reopened.save(owner, const NotificationPreferences()),
          throwsStateError,
        );
        await pumpEventQueue();
        expect(requests, hasLength(1));
        gate.complete(
          failure
              ? http.Response(
                  '{"message":"synthetic lost acknowledgement"}',
                  503,
                )
              : json(null),
        );
        await saved;
        expect((await reading).marketing, isTrue);
        expect(requests.map((r) => r.method), ['POST', 'GET']);
      },
    );
  }
  test(
    'session change while read waits for old write prevents a new HTTP read',
    () async {
      final gate = Completer<http.Response>();
      response = (_) => gate.future;
      final saved = expectLater(
        backend.save(owner, const NotificationPreferences()),
        throwsStateError,
      );
      await pumpEventQueue();
      final read = expectLater(backend.read(owner), throwsStateError);
      await authenticate(session: 's2');
      await pumpEventQueue();
      gate.complete(json(null));
      await saved;
      await read;
      expect(requests, hasLength(1));
    },
  );
  test(
    'queued session events fence a late transport failure as well',
    () async {
      response = (_) async {
        await authenticate(session: 's2');
        await authenticate(session: 's1');
        await pumpEventQueue();
        return http.Response('{"message":"synthetic"}', 503);
      };
      await expectLater(
        backend.save(owner, const NotificationPreferences()),
        throwsStateError,
      );
    },
  );
  test(
    'lookup rejects a foreign recipient even if transport returns a row',
    () async {
      response = (_) async => json({
        'id': 'notice',
        'user_id': 'other',
        'title': 'Fixture',
        'body': 'Fixture',
        'type': 'system',
      });
      expect(await backend.lookup('notice'), isNull);
    },
  );
  test(
    'adapter sends existing role-bound RPC contract, not arbitrary account selection',
    () async {
      await operation('register');
      final body = jsonDecode(requests.single.body) as Map;
      expect(
        requests.single.url.path,
        endsWith('/rpc/register_push_device_v1'),
      );
      expect(body.keys.toSet(), {
        'p_installation_id',
        'p_app_role',
        'p_push_token',
        'p_platform',
      });
      expect(body['p_app_role'], 'merchant');
      requests.clear();
      await operation('read');
      expect(requests.single.url.queryParameters['user_id'], 'eq.fixture-user');
      expect(requests.single.url.queryParameters['app_role'], 'eq.merchant');
    },
  );
  test(
    'different account or missing live-session key fails before RPC',
    () async {
      await authenticate(user: 'other-user');
      await expectLater(operation('register'), throwsStateError);
      await authenticate(session: null);
      await expectLater(operation('register'), throwsStateError);
      expect(requests, isEmpty);
    },
  );
}
