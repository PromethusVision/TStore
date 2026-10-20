import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/commerce_ledger/data/supabase_commerce_ledger_repository.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';

void main() {
  const user = '11111111-1111-4111-8111-111111111111',
      shop = '22222222-2222-4222-8222-222222222222';
  late SupabaseClient client;
  late StreamController<String?> sessions;
  late SupabaseCommerceLedgerRepository repo;
  late String? actor;
  dynamic response;
  final calls = <String>[];
  Map<String, dynamic> snapshot({
    String? forShop = shop,
    Object amount = '100000',
  }) => {
    'enabled': true,
    'currency': 'TRY',
    'shop_id': forShop,
    'settlement_enabled': false,
    'accounts': [
      {
        'code': forShop == null ? 'customer_pending' : 'merchant_reserve',
        'amount_minor': amount,
      },
    ],
  };
  setUp(() {
    client = SupabaseClient('http://127.0.0.1:55431', 'synthetic-anon');
    actor = user;
    sessions = StreamController<String?>.broadcast(sync: true);
    calls.clear();
    repo = SupabaseCommerceLedgerRepository(
      client,
      currentUserId: () => actor,
      sessionChanges: sessions.stream,
      currentSessionKey: () => actor == null ? null : '$actor:fixture',
      sessionKeyChanges: sessions.stream.map(
        (id) => id == null ? null : '$id:fixture',
      ),
      timeout: const Duration(milliseconds: 100),
      rpc: (name, args) async {
        calls.add(name);
        if (response is Exception) throw response as Exception;
        return await Future<dynamic>.value(response);
      },
    );
  });
  tearDown(() async {
    await sessions.close();
    await client.dispose();
  });
  test(
    'exact integer strings preserve amounts beyond JavaScript safe integers',
    () {
      expect(
        LedgerMinorUnits.fromWire('9007199254740993').value,
        BigInt.parse('9007199254740993'),
      );
      for (final value in [
        null,
        100,
        1.5,
        '-1',
        '01',
        '1.0',
        '1e3',
        '',
        true,
      ]) {
        expect(() => LedgerMinorUnits.fromWire(value), throwsFormatException);
      }
      expect(LedgerMinorUnits.fromWire('0').value, BigInt.zero);
    },
  );
  test(
    'H0 capabilities never imply funding, rewards or settlement availability',
    () async {
      actor = null;
      response = {
        'version': 1,
        'enabled': true,
        'policy_version': 1,
        'currency': 'TRY',
        'funding_enabled': false,
        'rewards_enabled': false,
        'settlement_enabled': false,
      };
      final caps = (await repo.capabilities()).getOrElse(
        () => throw StateError('Expected capabilities'),
      );
      expect(caps.enabled, true);
      expect(caps.fundingEnabled, false);
      expect(caps.rewardsEnabled, false);
      expect(caps.settlementEnabled, false);
      response = {
        ...response as Map<String, dynamic>,
        'settlement_enabled': true,
      };
      expect(
        (await repo.capabilities()).fold((e) => e, (_) => null),
        CommerceLedgerFailure.invalidResponse,
      );
    },
  );
  test('guest and malformed shop requests never invoke private RPC', () async {
    actor = null;
    expect((await repo.readOwnAccounts(shopId: shop)).isLeft(), true);
    actor = user;
    expect((await repo.readOwnAccounts(shopId: 'wrong')).isLeft(), true);
    expect(calls, isEmpty);
  });
  test(
    'own projection is immutable and distinguishes noncash offsets',
    () async {
      response = snapshot(amount: '9007199254740993');
      final data = (await repo.readOwnAccounts(
        shopId: shop,
      )).getOrElse(() => throw StateError('Expected accounts'));
      expect(data.accounts.single.amount.toString(), '9007199254740993');
      expect(data.settlementEnabled, false);
      expect(() => data.accounts.clear(), throwsUnsupportedError);
      response = {
        ...snapshot(forShop: null),
        'accounts': [
          {'code': 'customer_future_offset', 'amount_minor': '5000'},
        ],
      };
      final personal = (await repo.readOwnAccounts()).getOrElse(
        () => throw StateError('Expected own accounts'),
      );
      expect(personal.accounts.single.kind.isNonCashObligation, true);
    },
  );
  test(
    'foreign scope, duplicate accounts, numeric amounts and OFF data fail closed',
    () async {
      final valid = snapshot();
      for (final bad in [
        snapshot(forShop: user),
        snapshot(amount: 100),
        {
          ...valid,
          'accounts': [
            ...(valid['accounts'] as List),
            ...(valid['accounts'] as List),
          ],
        },
        {...valid, 'enabled': false},
        {...valid, 'currency': 'USD'},
        snapshot(forShop: null),
        {
          ...valid,
          'accounts': [
            {'code': 'platform_clearing', 'amount_minor': '1'},
          ],
        },
      ]) {
        response = bad;
        expect(
          (await repo.readOwnAccounts(
            shopId: shop,
          )).fold((e) => e, (_) => null),
          CommerceLedgerFailure.invalidResponse,
        );
      }
      response = {
        'enabled': false,
        'currency': 'TRY',
        'settlement_enabled': false,
        'accounts': [],
      };
      expect(
        (await repo.readOwnAccounts(
          shopId: shop,
        )).getOrElse(() => throw StateError('Expected disabled')).enabled,
        false,
      );
    },
  );
  test(
    'logout and away-back transitions discard delayed private responses',
    () async {
      final pending = Completer<dynamic>();
      response = pending.future;
      final request = repo.readOwnAccounts(shopId: shop);
      actor = null;
      sessions.add(null);
      actor = user;
      sessions.add(user);
      pending.complete(snapshot());
      expect(
        (await request).fold((e) => e, (_) => null),
        CommerceLedgerFailure.sessionChanged,
      );
    },
  );
  test(
    'timeouts and server errors expose no raw accounting data or false success',
    () async {
      response = const PostgrestException(
        message: 'sensitive internal audit details',
        code: 'XX000',
      );
      expect(
        (await repo.readOwnAccounts(shopId: shop)).fold((e) => e, (_) => null),
        CommerceLedgerFailure.unavailable,
      );
      response = const PostgrestException(message: 'revoked', code: '28000');
      expect(
        (await repo.readOwnAccounts(shopId: shop)).fold((e) => e, (_) => null),
        CommerceLedgerFailure.sessionChanged,
      );
      response = Completer<dynamic>().future;
      expect(
        (await repo.readOwnAccounts(shopId: shop)).fold((e) => e, (_) => null),
        CommerceLedgerFailure.unavailable,
      );
    },
  );
}
