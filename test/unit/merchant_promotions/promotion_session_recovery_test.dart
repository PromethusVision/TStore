import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import 'promotion_repository_test.dart' as wire;

void main() {
  late SupabaseClient client;
  late SupabaseMerchantPromotionRepository repo;
  late Future<dynamic> Function(String, Map<String, dynamic>) respond;
  final calls = <String>[];
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> session({
    String key = 'S1',
    int token = 0,
  }) => client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.${segment({'sub': wire.photo, 'session_id': key, 'nonce': token, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
      'refresh_token': 'synthetic-only',
      'token_type': 'bearer',
      'user': {
        'id': wire.photo,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
  Map<String, dynamic> receipt() => {
    'id': wire.draft,
    'revision_id': wire.revision,
    'action': 'save',
  };
  PromotionCommand command() => PromotionCommand(
    shopId: wire.shop,
    action: 'save',
    selection: wire.selection,
    fingerprint: wire.fingerprint,
  );
  Map<String, dynamic> response(String op) => switch (op) {
    'list' => wire.page(),
    'detail' => {
      'enabled': true,
      'shop_id': wire.shop,
      'draft': wire.page()['items'][0],
    },
    'preview' => wire.preview(),
    'write' => receipt(),
    _ => {'enabled': true, 'items': []},
  };
  Future<dynamic> invoke(String op) => switch (op) {
    'list' => repo.read(wire.shop),
    'detail' => repo.readPromotion(wire.shop, wire.draft),
    'sources' => repo.sources(wire.shop, 'listing'),
    'history' => repo.history(wire.shop, wire.draft),
    'preview' => repo.preview(wire.shop, wire.selection),
    _ => repo.mutate(command()),
  };
  setUp(() async {
    calls.clear();
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-only',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await session();
    repo = SupabaseMerchantPromotionRepository(
      client,
      rpc: (name, args) {
        calls.add(name);
        return respond(name, args);
      },
    );
  });
  tearDown(() => client.dispose());
  for (final op in [
    'list',
    'detail',
    'sources',
    'history',
    'preview',
    'write',
  ]) {
    for (final outcome in ['success', 'malformed', 'conflict']) {
      test('$op fences queued S1 S2 S1 with $outcome', () async {
        respond = (_, _) async {
          await Future.wait([session(key: 'S2'), session(token: 2)]);
          await pumpEventQueue();
          if (outcome == 'conflict') {
            throw const PostgrestException(message: 'changed', code: '40001');
          }
          return outcome == 'malformed' ? {'invalid': true} : response(op);
        };
        final result = await invoke(op);
        expect(
          result.fold((dynamic e) => e, (_) => null),
          PromotionFailure.session,
        );
        expect(calls.length, 1);
      });
    }
    test('$op survives normal token renewal', () async {
      respond = (_, _) async {
        await session(token: 4);
        return response(op);
      };
      expect((await invoke(op)).isRight(), true);
    });
  }
  test('identical in-flight command shares one transport operation', () async {
    final wait = Completer<dynamic>();
    respond = (_, _) => wait.future;
    final value = command();
    final first = repo.mutate(value), second = repo.mutate(value);
    await pumpEventQueue();
    expect(calls.length, 1);
    wait.complete(receipt());
    expect((await first).isRight(), true);
    expect((await second).isRight(), true);
  });
  test('different command cannot overlap a pending shop mutation', () async {
    final wait = Completer<dynamic>();
    respond = (_, _) =>
        calls.length == 1 ? wait.future : Future.value(receipt());
    final first = repo.mutate(command());
    await pumpEventQueue();
    expect((await repo.mutate(command())).isLeft(), true);
    expect(calls.length, 1);
    wait.complete(receipt());
    expect((await first).isRight(), true);
  });

  for (final failure in ['lost response', 'malformed receipt']) {
    test(
      '$failure retains only the immutable command for explicit retry',
      () async {
        final original = command();
        respond = (_, _) async {
          if (failure == 'lost response') throw StateError('offline');
          return {'id': wire.draft, 'action': 'save'};
        };
        expect(
          (await repo.mutate(original)).fold((e) => e, (_) => null),
          PromotionFailure.uncertain,
        );
        expect(repo.pendingCommand(wire.shop), same(original));
        expect((await repo.mutate(command())).isLeft(), true);
        expect(calls.length, 1);
        await session(token: 7);
        expect(repo.pendingCommand(wire.shop), same(original));
        respond = (_, args) async {
          expect(args, original.toJson());
          return receipt();
        };
        expect((await repo.mutate(original)).isRight(), true);
        expect(repo.pendingCommand(wire.shop), isNull);
        expect(calls.length, 2);
      },
    );
  }
  test(
    'same request id with a changed payload cannot replace uncertain command',
    () async {
      final original = command();
      respond = (_, _) async => throw StateError('lost');
      await repo.mutate(original);
      final changed = PromotionCommand(
        shopId: original.shopId,
        requestId: original.requestId,
        action: 'save',
        selection: const PromotionSelection(variant: 1),
        fingerprint: wire.fingerprint,
      );
      expect((await repo.mutate(changed)).isLeft(), true);
      expect(repo.pendingCommand(wire.shop), same(original));
      expect(calls.length, 1);
    },
  );
  test(
    'replacement cannot inherit an uncertain command even after key returns',
    () async {
      respond = (_, _) async => throw StateError('lost');
      await repo.mutate(command());
      await Future.wait([session(key: 'S2'), session(token: 3)]);
      await pumpEventQueue();
      expect(repo.pendingCommand(wire.shop), isNull);
      expect(calls.length, 1);
    },
  );
  test(
    'new session cannot overlap a dispatched old-session mutation',
    () async {
      final wait = Completer<dynamic>();
      respond = (_, _) => wait.future;
      final first = repo.mutate(command());
      await session(key: 'S2');
      expect(repo.pendingCommand(wire.shop), isNull);
      expect((await repo.mutate(command())).isLeft(), true);
      expect(calls.length, 1);
      wait.complete(receipt());
      expect(
        (await first).fold((e) => e, (_) => null),
        PromotionFailure.session,
      );
      respond = (_, _) async => receipt();
      expect((await repo.mutate(command())).isRight(), true);
    },
  );
  for (final code in ['22023', '40001', '42501', '55000']) {
    test('definitive server failure $code releases pending command', () async {
      respond = (_, _) async =>
          throw PostgrestException(message: 'synthetic', code: code);
      expect((await repo.mutate(command())).isLeft(), true);
      expect(repo.pendingCommand(wire.shop), isNull);
      respond = (_, _) async => receipt();
      expect((await repo.mutate(command())).isRight(), true);
    });
  }
  test(
    'replacement while signing hides preview and never signs remaining photos',
    () async {
      var signed = 0;
      repo = SupabaseMerchantPromotionRepository(
        client,
        rpc: (_, _) async => wire.preview(images: [wire.image(), wire.image()]),
        sign: (_) async {
          signed++;
          await Future.wait([session(key: 'S2'), session(token: 4)]);
          await pumpEventQueue();
          return 'https://fixture.invalid/photo';
        },
      );
      expect(
        (await repo.preview(
          wire.shop,
          wire.selection,
        )).fold((e) => e, (_) => null),
        PromotionFailure.session,
      );
      expect(signed, 1);
    },
  );
  for (final broken in ['error', 'done']) {
    test(
      'key stream $broken retires pending read and uncertain recovery',
      () async {
        final keys = StreamController<String?>.broadcast();
        addTearDown(keys.close);
        repo = SupabaseMerchantPromotionRepository(
          client,
          sessionKeyChanges: keys.stream,
          rpc: (n, a) => respond(n, a),
        );
        respond = (_, _) async => throw StateError('lost');
        await repo.mutate(command());
        final wait = Completer<dynamic>();
        respond = (_, _) => wait.future;
        final reading = repo.read(wire.shop);
        if (broken == 'error') {
          keys.addError(StateError('lost observation'));
        } else {
          await keys.close();
        }
        await pumpEventQueue();
        wait.complete(wire.page());
        expect(
          (await reading).fold((e) => e, (_) => null),
          PromotionFailure.session,
        );
        expect(repo.pendingCommand(wire.shop), isNull);
        await pumpEventQueue();
        expect(keys.hasListener, false);
      },
    );
  }
}
