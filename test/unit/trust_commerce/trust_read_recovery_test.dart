import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/trust_commerce/data/supabase_trust_commerce_repository.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';

void main() {
  late SupabaseClient client;
  late SupabaseTrustCommerceRepository repo;
  late Future<Object> Function() response;
  var requests = 0;
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  Future<void> session({
    String? key = 'S1',
    int token = 0,
  }) => client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.${segment({'sub': previewTrustActor, if (key != null) 'session_id': key, 'nonce': token, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
      'token_type': 'bearer',
      'refresh_token': 'synthetic-only',
      'user': {
        'id': previewTrustActor,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
  Map<String, dynamic> wire({List<int> ids = const [], int? next}) => {
    'enabled': true,
    'kind': 'merchant',
    'badges': [],
    'history': [
      for (final id in ids)
        {
          'id': id,
          'code': 'friendliness',
          'event': 'awarded',
          'reason': 'qualification_changed',
          'recorded_at': '2026-10-15T10:00:00Z',
        },
    ],
    'next_before': next,
  };
  setUp(() async {
    requests = 0;
    client = SupabaseClient(
      'https://trust-fixture.invalid',
      'synthetic-only',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        requests++;
        final value = await response();
        return http.Response(
          jsonEncode(value),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await session();
    response = () async => wire();
    repo = SupabaseTrustCommerceRepository(client);
  });
  tearDown(() => client.dispose());
  test(
    'campaign mutation fences intervening session without claiming acknowledgement',
    () async {
      response = () async {
        await Future.wait([session(key: 'S2'), session(token: 3)]);
        await pumpEventQueue();
        return {
          'id': previewCampaignId,
          'shop_id': previewTrustShop,
          'revision_id': previewCampaignRevision,
          'action': 'save',
        };
      };
      final result = await repo.mutate(
        CampaignCommand(
          shopId: previewTrustShop,
          requestId: previewCampaignId,
          action: 'save',
          draft: PreviewTrustCommerceRepository.exampleDraft(),
        ),
      );
      expect(result.fold((e) => e.kind, (_) => null), TrustFailureKind.auth);
      expect(requests, 1);
    },
  );
  for (final event in ['closed', 'error']) {
    test(
      'private read fences $event key observation and releases owned listeners',
      () async {
        final actors = StreamController<String?>.broadcast(),
            keys = StreamController<String?>.broadcast();
        addTearDown(actors.close);
        addTearDown(keys.close);
        final pending = Completer<dynamic>();
        repo = SupabaseTrustCommerceRepository(
          client,
          sessionChanges: actors.stream,
          sessionKeyChanges: keys.stream,
          rpc: (_, _) => pending.future,
        );
        final read = repo.trust(shopId: previewTrustShop);
        if (event == 'closed') {
          await keys.close();
        } else {
          keys.addError(StateError('observer stopped'));
          await pumpEventQueue();
        }
        pending.complete(wire());
        expect(
          (await read).fold((e) => e.kind, (_) => null),
          TrustFailureKind.auth,
        );
        expect(actors.hasListener, false);
        expect(keys.hasListener, false);
      },
    );
  }
  test('trust rejects a response for the wrong subject kind', () async {
    response = () async => {...wire(), 'kind': 'customer'};
    expect((await repo.trust(shopId: previewTrustShop)).isLeft(), true);
  });
  for (final surface in ['merchant', 'customer', 'campaign']) {
    Future<TrustFailureKind?> read() async {
      if (surface == 'campaign') {
        return (await repo.campaigns(
          previewTrustShop,
        )).fold((e) => e.kind, (_) => null);
      }
      return (await repo.trust(
        shopId: surface == 'merchant' ? previewTrustShop : null,
      )).fold((e) => e.kind, (_) => null);
    }

    Object valid() => surface == 'campaign'
        ? {
            'enabled': true,
            'price_publication_enabled': false,
            'total': 0,
            'campaigns': [],
          }
        : {...wire(), 'kind': surface};
    test('$surface accepts SDK initial replay and normal renewal', () async {
      response = () async {
        await session(token: 2);
        await pumpEventQueue();
        return valid();
      };
      expect(await read(), isNull);
    });
    test('$surface fences captured S1-S2-S1 SDK events', () async {
      response = () async {
        // Queue both states before letting the broadcast listeners run.
        final replaced = session(key: 'S2');
        final restored = session(token: 3);
        await Future.wait([replaced, restored]);
        await pumpEventQueue();
        return valid();
      };
      expect(await read(), TrustFailureKind.auth);
    });
    test(
      '$surface fences late invalid response after intervening session',
      () async {
        response = () async {
          final replaced = session(key: 'S2');
          final restored = session(token: 4);
          await Future.wait([replaced, restored]);
          await pumpEventQueue();
          return {'malformed': true};
        };
        expect(await read(), TrustFailureKind.auth);
      },
    );
    test('$surface refuses missing session provenance without HTTP', () async {
      await session(key: null);
      expect(await read(), TrustFailureKind.auth);
      expect(requests, 0);
    });
  }
  for (final bad in [
    'duplicate',
    'ascending',
    'outside-cursor',
    'wrong-next',
    'too-many',
    'unknown-event',
  ]) {
    test(
      'trust rejects $bad history without inventing cursor progress',
      () async {
        final data = switch (bad) {
          'duplicate' => wire(ids: [3, 3]),
          'ascending' => wire(ids: [2, 3]),
          'outside-cursor' => wire(ids: [101]),
          'wrong-next' => wire(ids: List.generate(30, (i) => 90 - i), next: 90),
          'too-many' => wire(ids: List.generate(31, (i) => 90 - i)),
          _ => wire(ids: [3]),
        };
        if (bad == 'unknown-event') {
          (data['history'] as List).first['event'] = 'invented';
        }
        response = () async => data;
        expect(
          (await repo.trust(shopId: previewTrustShop, before: 100)).isLeft(),
          true,
        );
      },
    );
  }
  test(
    'valid full history page and exhausted following page preserve server cursor',
    () async {
      response = () async =>
          wire(ids: List.generate(30, (i) => 90 - i), next: 61);
      final first = (await repo.trust(
        shopId: previewTrustShop,
      )).getOrElse(() => throw StateError('page'));
      expect(first.nextBefore, 61);
      response = () async => wire();
      expect(
        (await repo.trust(shopId: previewTrustShop, before: 61)).isRight(),
        true,
      );
    },
  );
}
