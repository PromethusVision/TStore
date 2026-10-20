import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';

import 'merchant_repository_test.dart' show access, user;

class _Repository extends Mock implements MerchantRepository {}

class _ClientCredentials implements MerchantCredentials {
  _ClientCredentials(this.client);

  final SupabaseClient client;
  final logoutTargets = <String?>[];

  @override
  Future<Either<String, void>> signIn(String email, String password) =>
      throw UnsupportedError('This test installs only synthetic sessions.');

  @override
  Future<Either<String, void>> signOut() async {
    logoutTargets.add(authenticatedSessionKey(client));
    await client.auth.signOut();
    return const Right(null);
  }
}

String _segment(Object value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

Map<String, dynamic> _syntheticSession(String sessionId, {int revision = 0}) {
  final expires = DateTime.now().add(const Duration(days: 1));
  return {
    'access_token':
        '${_segment({'alg': 'none'})}.'
        '${_segment({'sub': user.id, 'session_id': sessionId, 'nonce': revision, 'exp': expires.millisecondsSinceEpoch ~/ 1000})}.'
        'synthetic',
    'token_type': 'bearer',
    'refresh_token': 'synthetic-only-$sessionId',
    'user': {
      'id': user.id,
      'email': user.email,
      'app_metadata': {},
      'user_metadata': {},
      'aud': 'authenticated',
      'created_at': '2026-01-01T00:00:00Z',
    },
  };
}

Future<void> _installSession(SupabaseClient client, String sessionId) async {
  // Unlike recoverSession, this public SDK import emits an event even when
  // the subject stays the same. The app's recovery adapter also uses this API.
  await client.auth.setInitialSession(jsonEncode(_syntheticSession(sessionId)));
}

void main() {
  test(
    'T1 delayed logout must preserve same-user replacement S2 without sign-out event',
    () async {
      final client = SupabaseClient(
        'https://merchant-t1.invalid',
        'synthetic-test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/auth/v1/logout') {
            return http.Response('', 204, request: request);
          }
          throw StateError('Unexpected request in isolated T1 test');
        }),
      );
      final credentials = _ClientCredentials(client);
      final repository = _Repository();
      when(repository.loadAccess).thenAnswer((_) async => Right(access));
      final revocationStarted = Completer<void>();
      final revocation = Completer<void>();
      final observedUsers = <String?>[];
      final observedKeys = <String?>[];
      MerchantSessionCubit? cubit;
      Future<void>? exit;
      addTearDown(() async {
        if (!revocation.isCompleted) revocation.complete();
        await exit;
        await cubit?.close();
        await client.dispose();
      });

      await _installSession(client, 'S1');
      await pumpEventQueue();
      final session = cubit = MerchantSessionCubit(
        repository: repository,
        credentials: credentials,
        // Retain the original T1 reproduction through the user-ID stream;
        // production composition additionally supplies event session identities.
        sessionChanges: client.auth.onAuthStateChange.map((event) {
          observedUsers.add(event.session?.user.id);
          observedKeys.add(authenticatedSessionKey(client));
          return event.session?.user.id;
        }),
        currentUserId: () => client.auth.currentUser?.id,
        currentSessionKey: () => authenticatedSessionKey(client),
        beforeSignOut: () {
          revocationStarted.complete();
          return revocation.future;
        },
      );
      await session.reload();
      // The SDK also schedules its initial-session event for new listeners.
      await pumpEventQueue();
      expect(session.state.status, MerchantSessionStatus.ready);
      expect(authenticatedSessionKey(client), '${user.id}:S1');

      exit = session.signOut();
      await revocationStarted.future;
      await pumpEventQueue();
      observedUsers.clear();
      observedKeys.clear();
      expect(credentials.logoutTargets, isEmpty);
      expect(session.state.busy, isTrue);

      // Same subject, genuinely different SDK session; never clear S1 first.
      await _installSession(client, 'S2');
      await pumpEventQueue();
      expect(client.auth.currentUser?.id, user.id);
      expect(authenticatedSessionKey(client), '${user.id}:S2');
      expect(observedUsers, isNotEmpty);
      expect(observedUsers, everyElement(user.id));
      expect(observedKeys, everyElement('${user.id}:S2'));
      expect(credentials.logoutTargets, isEmpty);

      revocation.complete();
      await exit;
      await pumpEventQueue();

      expect(
        {
          'logoutTargets': credentials.logoutTargets,
          'sessionKey': authenticatedSessionKey(client),
          'userId': client.auth.currentUser?.id,
          'status': session.state.status,
        },
        {
          'logoutTargets': <String?>[],
          'sessionKey': '${user.id}:S2',
          'userId': user.id,
          'status': MerchantSessionStatus.ready,
        },
        reason:
            'The exit started in S1 must not dispatch against replacement S2.',
      );
    },
  );

  test(
    'same-session token refresh still completes the requested logout',
    () async {
      final client = SupabaseClient(
        'https://merchant-t1.invalid',
        'synthetic-test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/auth/v1/token') {
            expect(request.url.queryParameters['grant_type'], 'refresh_token');
            return http.Response(
              jsonEncode(_syntheticSession('S1', revision: 1)),
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.method == 'POST' &&
              request.url.path == '/auth/v1/logout') {
            return http.Response('', 204, request: request);
          }
          throw StateError('Unexpected request in isolated refresh test');
        }),
      );
      final credentials = _ClientCredentials(client);
      final repository = _Repository();
      when(repository.loadAccess).thenAnswer((_) async => Right(access));
      final revocationStarted = Completer<void>();
      final revocation = Completer<void>();
      final events = <AuthChangeEvent>[];
      MerchantSessionCubit? cubit;
      Future<void>? exit;
      addTearDown(() async {
        if (!revocation.isCompleted) revocation.complete();
        await exit;
        await cubit?.close();
        await client.dispose();
      });

      await _installSession(client, 'S1');
      await pumpEventQueue();
      final session = cubit = MerchantSessionCubit(
        repository: repository,
        credentials: credentials,
        sessionChanges: client.auth.onAuthStateChange.map((event) {
          events.add(event.event);
          return event.session?.user.id;
        }),
        currentUserId: () => client.auth.currentUser?.id,
        currentSessionKey: () => authenticatedSessionKey(client),
        beforeSignOut: () {
          revocationStarted.complete();
          return revocation.future;
        },
      );
      await session.reload();
      await pumpEventQueue();
      expect(session.state.status, MerchantSessionStatus.ready);
      final oldToken = client.auth.currentSession!.accessToken;

      exit = session.signOut();
      await revocationStarted.future;
      await pumpEventQueue();
      events.clear();
      await client.auth.refreshSession();
      await pumpEventQueue();
      expect(events, [AuthChangeEvent.tokenRefreshed]);
      expect(client.auth.currentSession!.accessToken, isNot(oldToken));
      expect(authenticatedSessionKey(client), '${user.id}:S1');
      expect(credentials.logoutTargets, isEmpty);

      revocation.complete();
      await exit;
      await pumpEventQueue();
      expect(credentials.logoutTargets, ['${user.id}:S1']);
      expect(client.auth.currentSession, isNull);
      expect(session.state.status, MerchantSessionStatus.signedOut);
    },
  );
}
