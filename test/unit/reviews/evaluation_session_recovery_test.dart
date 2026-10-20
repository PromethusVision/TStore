import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/reviews/data/repositories/supabase_purchase_evaluation_repository.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import '../../helpers/evaluation_auth_fixture.dart';
import '../../helpers/fake_evaluation_repository.dart';

void main() {
  late SupabaseClient client;
  late SupabasePurchaseEvaluationRepository repository;
  late Completer<dynamic> response;
  setUp(() async {
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await installEvaluationSession(client, 'S1');
    await pumpEventQueue();
    response = Completer<dynamic>();
    repository = SupabasePurchaseEvaluationRepository(
      client,
      rpc: (_, _) => response.future,
    );
  });
  tearDown(() => client.dispose());

  for (final fail in [false, true]) {
    test(
      'same-account replacement fences stale ${fail ? 'error' : 'success'}',
      () async {
        final pending = repository.enabled();
        await installEvaluationSession(client, 'S2');
        await pumpEventQueue();
        if (fail) {
          response.completeError(TimeoutException('synthetic'));
        } else {
          response.complete({'version': 2, 'enabled': true});
        }
        expect(
          (await pending).fold((e) => e.kind, (_) => null),
          ReviewFailureKind.authRequired,
        );
      },
    );
  }
  test('queued S1 S2 S1 does not revive the first request', () async {
    final pending = repository.enabled();
    await installEvaluationSession(client, 'S2');
    await installEvaluationSession(client, 'S1');
    await pumpEventQueue();
    response.complete({'version': 2, 'enabled': true});
    expect(
      (await pending).fold((e) => e.kind, (_) => null),
      ReviewFailureKind.authRequired,
    );
  });
  test('same session token renewal preserves the request', () async {
    final pending = repository.enabled();
    await installEvaluationSession(client, 'S1', tokenRevision: 1);
    await pumpEventQueue();
    response.complete({'version': 2, 'enabled': true});
    expect((await pending).getOrElse(() => false), true);
  });

  test(
    'queued event keys fence S2 even when live state already returned to S1',
    () async {
      final actors = StreamController<String?>.broadcast();
      final keys = StreamController<String?>.broadcast();
      final scoped = SupabasePurchaseEvaluationRepository(
        client,
        currentUserId: () => evaluationActor,
        currentSessionKey: () => 'S1',
        sessionChanges: actors.stream,
        sessionKeyChanges: keys.stream,
        rpc: (_, _) => response.future,
      );
      final pending = scoped.enabled();
      keys.add('S2');
      keys.add('S1');
      await pumpEventQueue();
      response.complete({'version': 2, 'enabled': true});
      expect(
        (await pending).fold((e) => e.kind, (_) => null),
        ReviewFailureKind.authRequired,
      );
      await actors.close();
      await keys.close();
    },
  );

  test('missing session provenance refuses authenticated RPC', () async {
    var calls = 0;
    final scoped = SupabasePurchaseEvaluationRepository(
      client,
      currentSessionKey: () => null,
      rpc: (_, _) async {
        calls++;
        return {'version': 2, 'enabled': true};
      },
    );
    expect(
      (await scoped.enabled()).fold((e) => e.kind, (_) => null),
      ReviewFailureKind.authRequired,
    );
    expect(calls, 0);
  });

  test('bounded read times out without accepting a late response', () async {
    final scoped = SupabasePurchaseEvaluationRepository(
      client,
      requestTimeout: const Duration(milliseconds: 5),
      rpc: (_, _) => response.future,
    );
    expect(
      (await scoped.enabled()).fold((e) => e.kind, (_) => null),
      ReviewFailureKind.network,
    );
    response.complete({'version': 2, 'enabled': true});
    await pumpEventQueue();
  });
}
