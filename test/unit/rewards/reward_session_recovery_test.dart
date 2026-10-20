import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import '../../support/reward_fixtures.dart';

void main() {
  late SupabaseClient client;
  late SupabaseRewardProgramRepository repo;
  late Future<Object> Function(String) respond;
  final calls = <String>[];
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> session({
    String? key = 'S1',
    int token = 0,
  }) => client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.${segment({'sub': rewardUser, if (key != null) 'session_id': key, 'nonce': token, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
      'refresh_token': 'synthetic-only',
      'token_type': 'bearer',
      'user': {
        'id': rewardUser,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
  setUp(() async {
    calls.clear();
    client = SupabaseClient(
      'https://reward-fixture.invalid',
      'synthetic-only',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        final name = request.url.pathSegments.last;
        calls.add(name);
        final data = await respond(name);
        return http.Response(
          jsonEncode(data),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await session();
    respond = (_) async => rewardCustomer();
    repo = SupabaseRewardProgramRepository(
      client,
      pollInterval: const Duration(hours: 1),
    );
  });
  tearDown(() => client.dispose());
  for (final operation in [
    'customer',
    'merchant',
    'acceptance',
    'reservation',
  ]) {
    for (final malformed in [false, true]) {
      test(
        '$operation rejects queued replacement even after return to original session${malformed ? ' with malformed response' : ''}',
        () async {
          respond = (_) async {
            await Future.wait([session(key: 'S2'), session(token: 3)]);
            await pumpEventQueue();
            if (malformed) return {'untrusted': 'response'};
            return switch (operation) {
              'customer' => rewardCustomer(),
              'merchant' || 'acceptance' => rewardMerchant(),
              _ => {'status': 'no_capacity', 'server_now': rewardNow},
            };
          };
          final result = await switch (operation) {
            'customer' => repo.readCustomer(),
            'merchant' => repo.readMerchant(rewardShop),
            'acceptance' => repo.setAcceptance(rewardShop, true, 7),
            _ => repo.reserve(rewardId),
          };
          expect(result.fold((e) => e, (_) => ''), contains('Oturum'));
          expect(calls.length, 1);
        },
      );
    }
  }
  test('ordinary token renewal keeps private read valid', () async {
    respond = (_) async {
      await session(token: 2);
      return rewardCustomer();
    };
    expect((await repo.readCustomer()).isRight(), true);
  });
  test(
    'reservation waits for transport and rejects overlap across carts',
    () async {
      final pending = Completer<dynamic>();
      var requests = 0;
      repo = SupabaseRewardProgramRepository(
        client,
        timeout: const Duration(milliseconds: 10),
        rpc: (_, _) {
          requests++;
          return pending.future;
        },
      );
      var settled = false;
      final first = repo.reserve(rewardId)..then((_) => settled = true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(settled, false);
      expect((await repo.reserve(rewardShop, startNew: true)).isLeft(), true);
      expect(requests, 1);
      pending.complete({'status': 'no_capacity', 'server_now': rewardNow});
      expect((await first).isRight(), true);
      expect((await repo.reserve(rewardId)).isRight(), true);
      expect(requests, 2);
    },
  );
  test(
    'queued owner read is cancelled on replacement before write settles',
    () async {
      final pending = Completer<dynamic>();
      final invoked = <String>[];
      repo = SupabaseRewardProgramRepository(
        client,
        rpc: (name, _) {
          invoked.add(name);
          return pending.future;
        },
      );
      final write = repo.setAcceptance(rewardShop, true, 7);
      await pumpEventQueue();
      final read = repo.readMerchant(rewardShop);
      await session(key: 'S2');
      await pumpEventQueue();
      pending.complete({
        ...rewardMerchant(),
        'preferred_acceptance': true,
        'preference_revision': 8,
      });
      expect((await write).isLeft(), true);
      expect((await read).isLeft(), true);
      expect(invoked, ['set_merchant_reward_preference_v1']);
    },
  );
  test(
    'closed key observation fences response and cleanup removes observers',
    () async {
      final keys = StreamController<String?>.broadcast();
      final pending = Completer<dynamic>();
      repo = SupabaseRewardProgramRepository(
        client,
        sessionKeyChanges: keys.stream,
        rpc: (_, _) => pending.future,
      );
      final read = repo.readCustomer();
      await pumpEventQueue();
      await keys.close();
      pending.complete(rewardCustomer());
      expect((await read).fold((e) => e, (_) => ''), contains('Oturum'));
      expect(keys.hasListener, false);
    },
  );
  test('closed actor observation rejects an in-flight response', () async {
    final actors = StreamController<String?>.broadcast();
    final pending = Completer<dynamic>();
    repo = SupabaseRewardProgramRepository(
      client,
      sessionChanges: actors.stream,
      rpc: (_, _) => pending.future,
    );
    final read = repo.readCustomer();
    await actors.close();
    pending.complete(rewardCustomer());
    expect((await read).fold((e) => e, (_) => ''), contains('Oturum'));
    expect(actors.hasListener, false);
  });
  test(
    'late structured server rejection is fenced before error classification',
    () async {
      repo = SupabaseRewardProgramRepository(
        client,
        rpc: (_, _) async {
          await Future.wait([session(key: 'S2'), session(token: 5)]);
          await pumpEventQueue();
          throw const PostgrestException(
            message: 'REWARD_ACCEPTANCE_LOCKED',
            code: '55000',
          );
        },
      );
      expect(
        (await repo.setAcceptance(
          rewardShop,
          false,
          7,
        )).fold((e) => e, (_) => ''),
        contains('Oturum'),
      );
    },
  );
  test(
    'acceptance waits for actual transport; reopened reads cannot race it',
    () async {
      final pending = Completer<dynamic>();
      final invoked = <String>[];
      repo = SupabaseRewardProgramRepository(
        client,
        timeout: const Duration(milliseconds: 10),
        rpc: (name, _) async {
          invoked.add(name);
          return name.startsWith('set_') ? pending.future : rewardMerchant();
        },
      );
      var settled = false;
      final write = repo.setAcceptance(rewardShop, true, 7)
        ..then((_) {
          settled = true;
        });
      await Future<void>.delayed(const Duration(milliseconds: 35));
      expect(settled, false);
      final read = repo.readMerchant(rewardShop);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(invoked, ['set_merchant_reward_preference_v1']);
      pending.complete({
        ...rewardMerchant(),
        'preferred_acceptance': true,
        'preference_revision': 8,
      });
      await write;
      await read;
      await pumpEventQueue();
      expect(invoked, [
        'set_merchant_reward_preference_v1',
      ], reason: 'A timed out queued read must not dispatch later.');
    },
  );
  test(
    'concurrent acceptance calls cannot send conflicting revisions',
    () async {
      final pending = Completer<dynamic>();
      var writes = 0;
      repo = SupabaseRewardProgramRepository(
        client,
        rpc: (_, _) {
          writes++;
          return pending.future;
        },
      );
      final first = repo.setAcceptance(rewardShop, true, 7);
      final second = repo.setAcceptance(rewardShop, false, 7);
      pending.complete({
        ...rewardMerchant(),
        'preferred_acceptance': true,
        'preference_revision': 8,
      });
      await first;
      expect((await second).isLeft(), true);
      expect(writes, 1);
    },
  );
  test(
    'mutation receipt must acknowledge preferred value and revision',
    () async {
      respond = (_) async => rewardMerchant();
      expect((await repo.setAcceptance(rewardShop, true, 7)).isLeft(), true);
    },
  );
  test(
    'closed progress observation clears data and stops polling or refresh',
    () async {
      final actors = StreamController<String?>.broadcast();
      repo = SupabaseRewardProgramRepository(
        client,
        sessionChanges: actors.stream,
        pollInterval: const Duration(hours: 1),
      );
      final seen = <RewardProgress>[];
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await pumpEventQueue();
      expect(seen.last.program, isNotNull);
      await actors.close();
      await pumpEventQueue();
      expect(seen.last.program, isNull);
      expect(seen.last.error, isNotNull);
      final count = calls.length;
      repo.refresh();
      await pumpEventQueue();
      expect(calls.length, count);
      await sub.cancel();
    },
  );
  test(
    'queued same-account replacement refreshes home subscription without old data',
    () async {
      final stale = Completer<Object>();
      respond = (_) => stale.future;
      final seen = <RewardProgress>[];
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await pumpEventQueue();
      respond = (_) async => {
        ...rewardCustomer(),
        'pending_count': 2,
        'pending_minor': '10000',
      };
      await Future.wait([session(key: 'S2'), session(token: 4)]);
      await pumpEventQueue();
      stale.complete(rewardCustomer());
      await pumpEventQueue();
      expect(seen.last.program?.pendingCount, 2);
      expect(seen.where((p) => p.program?.pendingCount == 1), isEmpty);
      await sub.cancel();
    },
  );
}
