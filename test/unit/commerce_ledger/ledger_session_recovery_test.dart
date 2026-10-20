import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/commerce_ledger/data/supabase_commerce_ledger_repository.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import '../../support/statement_fixtures.dart';

void main() {
  late SupabaseClient client;
  late SupabaseCommerceLedgerRepository repo;
  late Future<http.Response> Function(http.Request) respond;
  final requests = <http.Request>[];
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> session({
    String? key = 'S1',
    String user = statementUser,
    int token = 0,
  }) => client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.${segment({'sub': user, if (key != null) 'session_id': key, 'nonce': token, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
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
  );
  http.Response json(Object value) => http.Response(
    jsonEncode(value),
    200,
    headers: {'content-type': 'application/json'},
  );
  setUp(() async {
    requests.clear();
    client = SupabaseClient(
      'https://ledger-fixture.invalid',
      'synthetic-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests.add(request);
        final result = await respond(request);
        return http.Response.bytes(
          result.bodyBytes,
          result.statusCode,
          headers: result.headers,
          request: request,
        );
      }),
    );
    await session();
    repo = SupabaseCommerceLedgerRepository(client);
    respond = (request) async {
      if (request.url.path.endsWith('/read_merchant_statement_v1')) {
        return json(statementWire());
      }
      final shop = (jsonDecode(request.body) as Map)['p_shop_id'];
      return json({
        'enabled': true,
        'currency': 'TRY',
        'shop_id': shop,
        'settlement_enabled': false,
        'accounts': [
          {
            'code': shop == null ? 'customer_pending' : 'merchant_reserve',
            'amount_minor': '100000',
          },
        ],
      });
    };
  });
  tearDown(() async => client.dispose());
  Future<CommerceLedgerFailure?> read(String surface) async {
    if (surface == 'statement') {
      return (await repo.readStatement(
        shopId: statementShop,
      )).fold((e) => e, (_) => null);
    }
    return (await repo.readOwnAccounts(
      shopId: surface == 'merchant-accounts' ? statementShop : null,
    )).fold((e) => e, (_) => null);
  }

  for (final surface in [
    'statement',
    'merchant-accounts',
    'customer-accounts',
  ]) {
    test(
      '$surface accepts an existing authenticated session and its replayed initial event',
      () async {
        expect(await read(surface), isNull);
        expect(requests, hasLength(1));
      },
    );
    test('$surface keeps reads valid during normal token renewal', () async {
      final normal = respond;
      respond = (request) async {
        final result = await normal(request);
        await session(token: 2);
        await pumpEventQueue();
        return result;
      };
      expect(await read(surface), isNull);
    });
    for (final transition in ['replacement', 'S1-S2-S1', 'account']) {
      test('$surface fences $transition during HTTP', () async {
        final normal = respond;
        respond = (request) async {
          final result = await normal(request);
          await session(
            key: 'S2',
            user: transition == 'account' ? statementShop : statementUser,
          );
          if (transition == 'S1-S2-S1') await session(token: 3);
          await pumpEventQueue();
          return result;
        };
        expect(await read(surface), CommerceLedgerFailure.sessionChanged);
      });
    }
    test(
      '$surface refuses a session without a stable key before HTTP',
      () async {
        await session(key: null);
        expect(await read(surface), CommerceLedgerFailure.sessionChanged);
        expect(requests, isEmpty);
      },
    );
    for (final failure in ['malformed', 'server', 'transport']) {
      test(
        '$surface fences a late $failure failure after session replacement',
        () async {
          respond = (_) async {
            await session(key: 'S2');
            await session(token: 3);
            await pumpEventQueue();
            if (failure == 'transport') {
              throw StateError('synthetic transport failure');
            }
            if (failure == 'server') {
              return http.Response(
                '{"message":"synthetic private diagnostic","code":"40001"}',
                400,
                headers: {'content-type': 'application/json'},
              );
            }
            return json({'malformed': true});
          };
          expect(await read(surface), CommerceLedgerFailure.sessionChanged);
          expect(requests, hasLength(1));
        },
      );
    }
  }
  test(
    'public capability read remains available without an Auth session',
    () async {
      // A missing stable key refuses private reads, but does not gate public policy.
      await session(key: null);
      respond = (_) async => json({
        'version': 1,
        'enabled': false,
        'policy_version': 1,
        'currency': 'TRY',
        'funding_enabled': false,
        'rewards_enabled': false,
        'settlement_enabled': false,
      });
      final publicRepo = SupabaseCommerceLedgerRepository(
        client,
        currentUserId: () => null,
      );
      final result = (await publicRepo.capabilities()).getOrElse(
        () => throw StateError('Expected capabilities'),
      );
      expect(result.enabled, isFalse);
      expect(result.settlementEnabled, isFalse);
      expect(
        requests.single.url.path,
        endsWith('/commerce_ledger_capabilities_v1'),
      );
    },
  );
  for (final observation in ['actors', 'keys']) {
    for (final failure in ['error', 'done']) {
      test(
        '$observation observer $failure fences and releases private read listeners',
        () async {
          final actors = StreamController<String?>.broadcast(sync: true);
          final keys = StreamController<String?>.broadcast(sync: true);
          final gate = Completer<dynamic>();
          final scoped = SupabaseCommerceLedgerRepository(
            client,
            currentUserId: () => statementUser,
            currentSessionKey: () => 'S1',
            sessionChanges: actors.stream,
            sessionKeyChanges: keys.stream,
            rpc: (_, _) => gate.future,
          );
          final pending = scoped.readStatement(shopId: statementShop);
          final broken = observation == 'actors' ? actors : keys;
          if (failure == 'error') {
            broken.addError(StateError('synthetic observer error'));
          } else {
            await broken.close();
          }
          gate.complete(statementWire());
          expect(
            (await pending).fold((e) => e, (_) => null),
            CommerceLedgerFailure.sessionChanged,
          );
          expect(actors.hasListener, isFalse);
          expect(keys.hasListener, isFalse);
          await actors.close();
          await keys.close();
        },
      );
    }
  }
  test(
    'same-session read timeout releases listeners and cannot alter a later read',
    () async {
      final actors = StreamController<String?>.broadcast(sync: true);
      final keys = StreamController<String?>.broadcast(sync: true);
      final gate = Completer<dynamic>();
      var calls = 0;
      final scoped = SupabaseCommerceLedgerRepository(
        client,
        currentUserId: () => statementUser,
        currentSessionKey: () => 'S1',
        sessionChanges: actors.stream,
        sessionKeyChanges: keys.stream,
        timeout: const Duration(milliseconds: 10),
        rpc: (_, _) => ++calls == 1
            ? gate.future
            : Future.value(statementWire(enabled: false)),
      );
      expect(
        (await scoped.readStatement(
          shopId: statementShop,
        )).fold((e) => e, (_) => null),
        CommerceLedgerFailure.unavailable,
      );
      expect(actors.hasListener || keys.hasListener, isFalse);
      final fresh = (await scoped.readStatement(
        shopId: statementShop,
      )).getOrElse(() => throw StateError('Expected new read'));
      gate.complete(statementWire());
      await pumpEventQueue();
      expect(fresh.enabled, isFalse);
      expect(calls, 2);
      await actors.close();
      await keys.close();
    },
  );
}
