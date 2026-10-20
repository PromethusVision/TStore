import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/rewards/data/supabase_reward_program_repository.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import '../../support/reward_fixtures.dart';

void main() {
  late SupabaseClient client;
  late SupabaseRewardProgramRepository repo;
  late StreamController<String?> sessions;
  String? user, identity;
  dynamic response;
  final calls = <String>[];
  final arguments = <Map<String, dynamic>>[];
  setUp(() {
    client = SupabaseClient('http://127.0.0.1:55431', 'synthetic-anon');
    sessions = StreamController<String?>.broadcast(sync: true);
    user = rewardUser;
    identity = 'session-one';
    calls.clear();
    arguments.clear();
    response = rewardCustomer();
    repo = SupabaseRewardProgramRepository(
      client,
      currentUserId: () => user,
      sessionIdentity: () => identity,
      sessionChanges: sessions.stream,
      sessionKeyChanges: sessions.stream.map((_) => identity),
      timeout: const Duration(milliseconds: 30),
      pollInterval: const Duration(hours: 1),
      rpc: (name, args) async {
        calls.add(name);
        arguments.add(args);
        if (response is Exception) throw response as Exception;
        return Future<dynamic>.value(response);
      },
    );
  });
  tearDown(() async {
    await sessions.close();
    await client.dispose();
  });
  test(
    'guest may read public terms but cannot read or mutate private state',
    () async {
      user = null;
      identity = null;
      response = rewardCaps();
      expect((await repo.capabilities()).isRight(), true);
      expect((await repo.readCustomer()).isLeft(), true);
      expect((await repo.readMerchant(rewardShop)).isLeft(), true);
      expect((await repo.reserve(rewardId)).isLeft(), true);
      expect(calls, ['reward_capabilities_v1']);
    },
  );
  test(
    'frozen capabilities carry exact amounts without opening payment or redemption',
    () async {
      response = rewardCaps();
      final c = (await repo.capabilities()).getOrElse(
        () => throw StateError('missing'),
      );
      expect(rewardMoney(c.minimum), '500,00 TL');
      expect(c.purchaseEnabled, false);
      expect(c.redemptionEnabled, false);
      expect(c.packageSlots, 100);
      expect(c.maturitySeconds, 86400);
    },
  );
  for (final field in [
    'package_purchase_enabled',
    'redemption_enabled',
    'settlement_enabled',
  ]) {
    test('unknown authority $field fails closed', () async {
      response = {...rewardCaps(), field: true};
      expect((await repo.capabilities()).isLeft(), true);
    });
  }
  for (final amount in [null, 5000, 5.0, '-1', '01', '1e3', '5000.0', '']) {
    test(
      'malformed money $amount never becomes a visible zero balance',
      () async {
        response = {...rewardCustomer(), 'pending_minor': amount};
        expect((await repo.readCustomer()).isLeft(), true);
      },
    );
  }
  test('customer history and amounts stay immutable and exact', () async {
    response = {...rewardCustomer(), 'coupon_minor': '9007199254740993'};
    final s = (await repo.readCustomer()).getOrElse(
      () => throw StateError('missing'),
    );
    expect(s.couponValue.value, BigInt.parse('9007199254740993'));
    expect(() => s.coupons.clear(), throwsUnsupportedError);
    expect(() => s.history.clear(), throwsUnsupportedError);
    expect(s.redemptionEnabled, false);
    expect(s.progressSteps, 1);
  });
  test(
    'duplicate coupons, expiry and future redemption protocol are rejected',
    () async {
      for (final change in [1, 2, 3]) {
        final m = rewardCustomer();
        if (change == 1) {
          (m['coupons'] as List).add((m['coupons'] as List).first);
        }
        if (change == 2) m['coupons'][0]['expires_at'] = rewardNow;
        if (change == 3) m['redemption_enabled'] = true;
        response = m;
        expect((await repo.readCustomer()).isLeft(), true);
      }
    },
  );
  test(
    'merchant rejects foreign shop, inconsistent capacity and false effective acceptance',
    () async {
      response = rewardMerchant();
      expect((await repo.readMerchant(rewardShop)).isRight(), true);
      for (final change in [1, 2, 3]) {
        final m = rewardMerchant();
        if (change == 1) m['shop_id'] = rewardId;
        if (change == 2) m['packages'][0]['capacity']['free'] = 100;
        if (change == 3) m['effective_acceptance'] = false;
        response = m;
        expect((await repo.readMerchant(rewardShop)).isLeft(), true);
      }
    },
  );
  test(
    'invalid identifiers and revision never reach a server mutation',
    () async {
      expect((await repo.reserve('wrong')).isLeft(), true);
      expect((await repo.setAcceptance(rewardShop, true, -1)).isLeft(), true);
      expect((await repo.readMerchant('wrong')).isLeft(), true);
      expect(calls, isEmpty);
    },
  );
  test(
    'acceptance uses expected revision and does not invent a successful result',
    () async {
      response = rewardMerchant();
      await repo.setAcceptance(rewardShop, true, 7);
      expect(arguments.single, {
        'p_shop': rewardShop,
        'p_preferred': true,
        'p_expected_revision': 7,
      });
      response = const PostgrestException(
        message: 'REWARD_ACCEPTANCE_LOCKED',
        code: '55000',
      );
      expect(
        (await repo.setAcceptance(
          rewardShop,
          false,
          8,
        )).fold((e) => e, (_) => ''),
        contains('kapatılamaz'),
      );
    },
  );
  test(
    'reservation requires deadline and known status; no automatic renewal flag',
    () async {
      response = {
        'status': 'reserved',
        'server_now': rewardNow,
        'attempt_id': rewardId,
        'expires_at': '2026-10-15T12:30:00Z',
      };
      final r = (await repo.reserve(
        rewardId,
      )).getOrElse(() => throw StateError('missing'));
      expect(r.remainingAtRead, const Duration(minutes: 30));
      expect(arguments.last['p_start_new'], false);
      await repo.reserve(rewardId, startNew: true);
      expect(arguments.last['p_start_new'], true);
      response = {...response as Map<String, dynamic>, 'expires_at': null};
      expect((await repo.reserve(rewardId)).isLeft(), true);
      response = {'status': 'future', 'server_now': rewardNow};
      expect((await repo.reserve(rewardId)).isLeft(), true);
    },
  );
  test(
    'away-and-back session change discards old response even for the same user',
    () async {
      final pending = Completer<dynamic>();
      response = pending.future;
      final result = repo.readCustomer();
      identity = null;
      user = null;
      sessions.add(null);
      user = rewardUser;
      identity = 'session-one';
      sessions.add(user);
      pending.complete(rewardCustomer());
      expect((await result).isLeft(), true);
    },
  );
  test('same user new login invalidates in-flight acceptance', () async {
    final pending = Completer<dynamic>();
    response = pending.future;
    final result = repo.setAcceptance(rewardShop, true, 7);
    identity = 'session-two';
    sessions.add(user);
    pending.complete(rewardMerchant());
    expect((await result).isLeft(), true);
  });
  test('timeout and server errors expose no raw internals', () async {
    response = Completer<dynamic>().future;
    expect((await repo.readCustomer()).isLeft(), true);
    response = const PostgrestException(
      message: 'private-secret-parameter',
      code: '23514',
    );
    expect(
      (await repo.readCustomer()).fold((e) => e, (_) => ''),
      isNot(contains('private-secret')),
    );
  });
  test(
    'stream clears private data on logout, ignores late reply, and cancels polling',
    () async {
      final seen = <RewardProgress>[];
      final pending = Completer<dynamic>();
      response = pending.future;
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen.single.loading, true);
      user = null;
      identity = null;
      sessions.add(null);
      pending.complete(rewardCustomer());
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.error, isNotNull);
      expect(seen.every((e) => e.program == null), true);
      await sub.cancel();
      final n = calls.length;
      repo.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(calls.length, n);
    },
  );
  test(
    'disabled program preserves history and refresh retrieves authoritative state',
    () async {
      response = {...rewardCustomer(), 'enabled': false};
      final seen = <RewardProgress>[];
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.available, false);
      expect(seen.last.program?.pendingCount, 1);
      repo.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(calls.length, 2);
      await sub.cancel();
    },
  );
  test(
    'transient auth stream error clears data and permits a fresh explicit read',
    () async {
      final seen = <RewardProgress>[];
      final stale = Completer<dynamic>();
      response = stale.future;
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sessions.addError(StateError('synthetic auth interruption'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.error, isNotNull);
      response = rewardCustomer();
      repo.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.program?.pendingCount, 1);
      stale.complete({
        ...rewardCustomer(),
        'pending_count': 2,
        'pending_minor': '10000',
      });
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.program?.pendingCount, 1);
      await sub.cancel();
    },
  );
  test(
    'same customer new login resumes stream and discards the previous in-flight response',
    () async {
      final seen = <RewardProgress>[];
      final stale = Completer<dynamic>();
      response = stale.future;
      final sub = repo.watchProgress(rewardUser).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      response = {
        ...rewardCustomer(),
        'pending_count': 2,
        'pending_minor': '10000',
      };
      identity = 'session-two';
      sessions.add(user);
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.program?.pendingCount, 2);
      stale.complete(rewardCustomer());
      await Future<void>.delayed(Duration.zero);
      expect(seen.last.program?.pendingCount, 2);
      expect(seen.where((p) => p.program?.pendingCount == 1), isEmpty);
      await sub.cancel();
    },
  );
}
