import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/commerce_ledger/data/merchant_statement_decoder.dart';
import 'package:t_store/features/commerce_ledger/data/supabase_commerce_ledger_repository.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/commerce_ledger/domain/merchant_statement.dart';
import '../../support/statement_fixtures.dart';

void main() {
  test(
    'real local PostgREST statement pages decode without a hand-written wire substitute',
    () {
      final captured =
          jsonDecode(
                File(
                  'docs/data/merchant_statement_h1_contract.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(
        captured['evidence_class'],
        'synthetic-local-postgrest-read-projection',
      );
      final firstWire = captured['first'] as Map<String, dynamic>;
      final nextWire = captured['next'] as Map<String, dynamic>;
      final shop = firstWire['shop_id'] as String;
      final first = decodeMerchantStatement(firstWire, shop, 2, null, null);
      final next = decodeMerchantStatement(
        nextWire,
        shop,
        2,
        first.nextBefore,
        first.revision,
      );
      expect(next.accounts, first.accounts);
      expect(next.revision, first.revision);
      expect(first.entries.length, 2);
      expect(
        next.entries.any((e) => first.entries.any((old) => old.id == e.id)),
        false,
      );
      expect(first.settlementEnabled, false);
    },
  );
  MerchantStatement decode(
    Map<String, dynamic> value, {
    int limit = 20,
    String? before,
    String? revision,
  }) => decodeMerchantStatement(value, statementShop, limit, before, revision);
  test('exact signed money formatting never uses binary floating point', () {
    expect(
      statementMoney(BigInt.parse('9007199254740993')),
      '90.071.992.547.409,93 TL',
    );
    expect(statementMoney(BigInt.from(-1), signed: true), '−0,01 TL');
    expect(statementMoney(BigInt.zero, signed: true), '0,00 TL');
    expect(statementMoney(BigInt.from(100000), signed: true), '+1.000,00 TL');
  });
  test(
    'complete source-specific balances are immutable and never payout permission',
    () {
      final value = decode(
        statementWire(
          amounts: {
            'merchant_coupon_pending': '50000',
            'merchant_unused_pending': '25000',
            'merchant_coupon_available': '3000',
            'merchant_unused_available': '2000',
          },
        ),
      );
      expect(value.pending, BigInt.from(75000));
      expect(value.released, BigInt.from(5000));
      expect(value.settlementEnabled, false);
      expect(value.reserveCap, BigInt.from(100000));
      expect(() => value.accounts.clear(), throwsUnsupportedError);
      expect(() => value.entries.clear(), throwsUnsupportedError);
      expect(
        () => value.entries.single.movements.clear(),
        throwsUnsupportedError,
      );
    },
  );
  test('OFF is unavailable rather than a fabricated zero statement', () {
    final value = decode(statementWire(enabled: false));
    expect(value.enabled, false);
    expect(value.accounts, isEmpty);
    expect(value.entries, isEmpty);
    expect(value.reserveCap, isNull);
    expect(value.revision, isNull);
  });
  test('zero-net internal release retains both signed source movements', () {
    final row = statementEntry(kind: 'receivable_release', amount: '0');
    row['movements'] = [
      {'code': 'merchant_coupon_pending', 'amount_minor': '-50000'},
      {'code': 'merchant_coupon_available', 'amount_minor': '50000'},
    ];
    final entry = decode(statementWire(entries: [row])).entries.single;
    expect(entry.net, BigInt.zero);
    expect(entry.movements.length, 2);
  });
  test(
    'compensating entries preserve negative signs and original reference',
    () {
      final row = statementEntry(
        kind: 'admin_reversal',
        amount: '-1000',
        reverses: statementOlderId,
      );
      final value = decode(statementWire(entries: [row]));
      expect(value.entries.single.reverses, statementOlderId);
      expect(value.entries.single.net, BigInt.from(-1000));
    },
  );
  test('valid pages have deterministic order including equal timestamps', () {
    final newer = statementEntry(id: statementOlderId);
    final older = statementEntry();
    final page = decode(
      statementWire(entries: [newer, older], revision: '3', next: statementId),
      limit: 2,
    );
    expect(page.nextBefore, statementId);
    expect(
      () => decode(statementWire(entries: [older, newer], revision: '2')),
      throwsFormatException,
    );
  });
  test(
    'foreign scope, unsupported capability, extra private fields and malformed top-level data fail closed',
    () {
      for (final delta in <Map<String, dynamic>>[
        {'shop_id': statementUser},
        {'version': 2},
        {'enabled': 'true'},
        {'currency': 'USD'},
        {'settlement_enabled': true},
        {'settlement_status': 'paid'},
        {'source_id': statementId},
        {'revision': '-1'},
        {'revision': 1},
        {'revision': '01'},
        {'revision': '1'.padRight(21, '0')},
        {'reserve_cap_minor': 100000},
        {'reserve_cap_minor': '-1'},
        {'accounts': null},
        {'entries': null},
      ]) {
        expect(
          () => decode({...statementWire(), ...delta}),
          throwsFormatException,
          reason: delta.toString(),
        );
      }
      expect(
        () => decode({...statementWire(enabled: false), 'revision': '0'}),
        throwsFormatException,
      );
      expect(
        () => decode({...statementWire(), 'enabled': false}),
        throwsFormatException,
      );
    },
  );
  test(
    'missing, duplicated, cross-party and fractional account rows fail closed',
    () {
      final accounts = statementWire()['accounts'] as List;
      for (final rows in [
        accounts.sublist(1),
        [...accounts, accounts.first],
        [
          for (var i = 0; i < accounts.length; i++)
            i == 0
                ? {'code': 'customer_coupon', 'amount_minor': '1'}
                : accounts[i],
        ],
        [
          for (var i = 0; i < accounts.length; i++)
            i == 0
                ? {'code': 'merchant_reserve', 'amount_minor': '1.00'}
                : accounts[i],
        ],
        [
          for (var i = 0; i < accounts.length; i++)
            i == 0
                ? {'code': 'merchant_reserve', 'amount_minor': '-1'}
                : accounts[i],
        ],
      ]) {
        expect(
          () => decode({...statementWire(), 'accounts': rows}),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'unknown movements, wrong sums, identity leaks, invalid dates and unknown source kinds fail closed',
    () {
      for (final delta in <Map<String, dynamic>>[
        {'id': 'bad'},
        {'recorded_at': 'yesterday'},
        {'recorded_at': '2026-10-15T10:00:00'},
        {'kind': 'unreviewed_source'},
        {'reverses': statementId},
        {'reverses': 'bad'},
        {'net_minor': '2'},
        {'net_minor': '-0'},
        {'net_minor': 150000},
        {'source_id': statementId},
        {'movements': []},
        {
          'movements': [
            {'code': 'platform_service', 'amount_minor': '150000'},
          ],
        },
        {
          'movements': [
            {'code': 'merchant_reserve', 'amount_minor': '0'},
          ],
        },
        {
          'movements': [
            {
              'code': 'merchant_reserve',
              'amount_minor': '150000',
              'customer_id': statementUser,
            },
          ],
        },
      ]) {
        expect(
          () => decode(
            statementWire(
              entries: [
                {...statementEntry(), ...delta},
              ],
            ),
          ),
          throwsFormatException,
          reason: delta.toString(),
        );
      }
    },
  );
  test(
    'revision drift, overlong pages, repeated entries and impossible next cursors fail closed',
    () {
      final valid = statementWire();
      expect(() => decode(valid, revision: '2'), throwsFormatException);
      expect(
        () => decode(valid, before: statementId, revision: '1'),
        throwsFormatException,
      );
      expect(
        () => decode(
          statementWire(
            entries: [statementEntry(), statementEntry()],
            revision: '2',
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => decode(statementWire(entries: [statementEntry()], revision: '0')),
        throwsFormatException,
      );
      expect(
        () => decode(statementWire(entries: [], revision: '1')),
        throwsFormatException,
      );
      expect(
        () => decode({...valid, 'next_before': statementOlderId}, limit: 1),
        throwsFormatException,
      );
      expect(
        () => decode({...valid, 'next_before': statementId}, limit: 1),
        throwsFormatException,
      );
      expect(() => decode(valid, limit: 0), throwsFormatException);
    },
  );

  group('transport', () {
    late SupabaseClient client;
    late SupabaseCommerceLedgerRepository repo;
    late StreamController<String?> sessions;
    String? actor;
    dynamic response;
    final calls = <Map<String, dynamic>>[];
    setUp(() {
      client = SupabaseClient('http://127.0.0.1:55431', 'synthetic-anon');
      sessions = StreamController<String?>.broadcast(sync: true);
      actor = statementUser;
      calls.clear();
      response = statementWire();
      repo = SupabaseCommerceLedgerRepository(
        client,
        currentUserId: () => actor,
        sessionChanges: sessions.stream,
        timeout: const Duration(milliseconds: 30),
        rpc: (name, args) async {
          expect(name, 'read_merchant_statement_v1');
          calls.add(args);
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
      'exact owner and cursor parameters use existing read-only adapter',
      () async {
        response = statementWire(entries: [statementEntry()], revision: '3');
        final result = await repo.readStatement(
          shopId: statementShop,
          limit: 2,
          before: statementOlderId,
          revision: '3',
        );
        expect(result.isRight(), true);
        expect(calls.single, {
          'p_shop_id': statementShop,
          'p_limit': 2,
          'p_before': statementOlderId,
          'p_revision': '3',
        });
      },
    );
    test('guests and malformed arguments do not send RPCs', () async {
      actor = null;
      expect((await repo.readStatement(shopId: statementShop)).isLeft(), true);
      actor = statementUser;
      for (final limit in [0, 51]) {
        expect(
          (await repo.readStatement(
            shopId: statementShop,
            limit: limit,
          )).isLeft(),
          true,
        );
      }
      expect((await repo.readStatement(shopId: 'bad')).isLeft(), true);
      expect(
        (await repo.readStatement(
          shopId: statementShop,
          before: statementId,
        )).isLeft(),
        true,
      );
      expect(
        (await repo.readStatement(
          shopId: statementShop,
          revision: '1',
        )).isLeft(),
        true,
      );
      expect(
        (await repo.readStatement(
          shopId: statementShop,
          before: 'bad',
          revision: '1',
        )).isLeft(),
        true,
      );
      expect(
        (await repo.readStatement(
          shopId: statementShop,
          before: statementId,
          revision: '01',
        )).isLeft(),
        true,
      );
      expect(calls, isEmpty);
    });
    test(
      'server snapshot change and revoked session have distinct safe failure types',
      () async {
        for (final pair in {
          '40001': CommerceLedgerFailure.statementChanged,
          '28000': CommerceLedgerFailure.sessionChanged,
          '42501': CommerceLedgerFailure.sessionChanged,
          'XX000': CommerceLedgerFailure.unavailable,
        }.entries) {
          response = PostgrestException(
            message: 'PRIVATE RAW DATA',
            code: pair.key,
          );
          expect(
            (await repo.readStatement(
              shopId: statementShop,
            )).fold((e) => e, (_) => null),
            pair.value,
          );
        }
      },
    );
    test(
      'timeout and malformed wire never become zero or a successful statement',
      () async {
        response = Completer<dynamic>().future;
        expect(
          (await repo.readStatement(
            shopId: statementShop,
          )).fold((e) => e, (_) => null),
          CommerceLedgerFailure.unavailable,
        );
        response = {'amount': 0};
        expect(
          (await repo.readStatement(
            shopId: statementShop,
          )).fold((e) => e, (_) => null),
          CommerceLedgerFailure.invalidResponse,
        );
      },
    );
    for (final transition in [
      'logout',
      'away-back',
      'same-user-session',
      'stream-error',
    ]) {
      test('$transition invalidates delayed financial response', () async {
        final pending = Completer<dynamic>();
        response = pending.future;
        final future = repo.readStatement(shopId: statementShop);
        if (transition == 'stream-error') {
          sessions.addError(StateError('session unavailable'));
        } else if (transition == 'same-user-session') {
          sessions.add(statementUser);
        } else {
          actor = null;
          sessions.add(null);
          if (transition == 'away-back') {
            actor = statementUser;
            sessions.add(actor);
          }
        }
        pending.complete(statementWire());
        expect(
          (await future).fold((e) => e, (_) => null),
          CommerceLedgerFailure.sessionChanged,
        );
      });
    }
  });
}
