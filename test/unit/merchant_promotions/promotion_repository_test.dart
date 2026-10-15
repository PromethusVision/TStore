import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';

const shop = '00000000-0000-4000-8000-000000000001';
const listing = '00000000-0000-4000-8000-000000000002';
const photo = '00000000-0000-4000-8000-000000000003';
const draft = '00000000-0000-4000-8000-000000000004';
const revision = '00000000-0000-4000-8000-000000000005';
const fingerprint =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const selection = PromotionSelection(
  family: PromotionFamily.product,
  listingId: listing,
);
Map<String, dynamic> copy() => {
  'title': 'Kalem',
  'body': 'Güncel ürün fiyatı: 123,45 TL.',
  'image': null,
  'facts': {'template_version': 1},
};
Map<String, dynamic> preview({List<dynamic> images = const []}) => {
  'enabled': true,
  'ready': true,
  'fingerprint': fingerprint,
  'snapshot': copy(),
  'images': images,
};
Map<String, dynamic> page() => {
  'enabled': true,
  'shop_id': shop,
  'has_more': false,
  'items': [
    {
      'id': draft,
      'revision_id': revision,
      'shop_id': shop,
      'status': 'draft',
      'selection': selection.toJson(),
      'snapshot': copy(),
      'recorded_at': '2026-10-15T12:00:00Z',
    },
  ],
};
Map<String, dynamic> image() => {
  'id': photo,
  'listing_id': listing,
  'bucket_id': 'listing-media',
  'object_path': 'shops/$shop/$listing/v20261015120000/$photo.png',
};
void main() {
  late SupabaseClient client;
  late StreamController<String?> sessions;
  String? user;
  late Future<dynamic> Function(String, Map<String, dynamic>) rpc;
  late Future<String> Function(String) sign;
  SupabaseMerchantPromotionRepository repository({Duration? timeout}) =>
      SupabaseMerchantPromotionRepository(
        client,
        rpc: (n, p) => rpc(n, p),
        sign: (p) => sign(p),
        currentUserId: () => user,
        sessionChanges: sessions.stream,
        timeout: timeout ?? const Duration(seconds: 1),
      );
  setUp(() {
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'local-test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    sessions = StreamController<String?>.broadcast(sync: true);
    user = 'owner';
    rpc = (_, _) async => page();
    sign = (_) async =>
        'http://127.0.0.1:55431/storage/v1/object/sign/test?token=local';
  });
  tearDown(() async {
    await sessions.close();
    await client.dispose();
  });
  test('disabled source/history responses hide historical items', () async {
    rpc = (_, _) async => {'enabled': false, 'items': []};
    expect(
      (await repository().sources(
        shop,
        'listing',
      )).swap().getOrElse(() => throw StateError('failure')),
      PromotionFailure.unavailable,
    );
    expect(
      (await repository().history(
        shop,
        draft,
      )).swap().getOrElse(() => throw StateError('failure')),
      PromotionFailure.unavailable,
    );
  });
  test('owner list decodes and freezes containers', () async {
    final result = (await repository().read(
      shop,
    )).getOrElse(() => throw StateError('read'));
    expect(result.items.single.copy.body, contains('123,45'));
    expect(result.items.single.statusLabel, 'Taslak');
    expect(() => result.items.clear(), throwsUnsupportedError);
  });
  test('no actor makes no request', () async {
    user = null;
    var calls = 0;
    rpc = (_, _) async {
      calls++;
      return page();
    };
    expect(
      (await repository().read(
        shop,
      )).swap().getOrElse(() => throw StateError('failure')),
      PromotionFailure.session,
    );
    expect(calls, 0);
  });
  for (final mode in [
    'foreign_shop',
    'unknown_status',
    'missing_revision',
    'disabled_data',
    'oversize',
  ]) {
    test('rejects malformed/private response: $mode', () async {
      final wire = page(), row = wire['items'][0] as Map<String, dynamic>;
      switch (mode) {
        case 'foreign_shop':
          row['shop_id'] = listing;
        case 'unknown_status':
          row['status'] = 'published';
        case 'missing_revision':
          row.remove('revision_id');
        case 'disabled_data':
          wire['enabled'] = false;
        case 'oversize':
          wire['items'] = List.filled(21, row);
      }
      rpc = (_, _) async => wire;
      expect((await repository().read(shop)).isLeft(), true);
    });
  }
  for (final mode in ['same_actor', 'account_switch', 'aba', 'stream_error']) {
    test('discards late private read after $mode', () async {
      final pending = Completer<dynamic>();
      rpc = (_, _) => pending.future;
      final future = repository().read(shop);
      switch (mode) {
        case 'same_actor':
          sessions.add(user);
        case 'account_switch':
          user = 'other';
          sessions.add(user);
        case 'aba':
          user = 'other';
          sessions.add(user);
          user = 'owner';
          sessions.add(user);
        case 'stream_error':
          sessions.addError(StateError('session'));
      }
      pending.complete(page());
      expect(
        (await future).swap().getOrElse(() => throw StateError('failure')),
        PromotionFailure.session,
      );
    });
  }
  test('session event while image signing cannot leak preview', () async {
    rpc = (_, _) async => preview(images: [image()]);
    final signing = Completer<String>(), started = Completer<void>();
    sign = (_) {
      started.complete();
      return signing.future;
    };
    final future = repository().preview(shop, selection);
    await started.future;
    sessions.add('owner');
    signing.complete('https://local.invalid/photo');
    expect((await future).isLeft(), true);
  });
  for (final change in [
    'foreign_bucket',
    'foreign_path',
    'foreign_listing',
    'invalid_id',
  ]) {
    test('does not sign untrusted media descriptor $change', () async {
      var calls = 0;
      sign = (_) async {
        calls++;
        return 'https://local.invalid/photo';
      };
      final row = image();
      switch (change) {
        case 'foreign_bucket':
          row['bucket_id'] = 'avatars';
        case 'foreign_path':
          row['object_path'] =
              'shops/$listing/$listing/v20261015120000/$photo.png';
        case 'foreign_listing':
          row['listing_id'] = shop;
        case 'invalid_id':
          row['id'] = '../escape';
      }
      rpc = (_, _) async => preview(images: [row]);
      expect((await repository().preview(shop, selection)).isLeft(), true);
      expect(calls, 0);
    });
  }
  test(
    'sign failure preserves usable grounded text without broken URL',
    () async {
      rpc = (_, _) async => preview(images: [image()]);
      sign = (_) async => throw StateError('offline');
      final result = (await repository().preview(
        shop,
        selection,
      )).getOrElse(() => throw StateError('preview'));
      expect(result.ready, true);
      expect(result.images.single.url, null);
      expect(result.copy!.title, 'Kalem');
    },
  );
  test('mutation retains exact JSON and ID across uncertain retries', () async {
    final command = PromotionCommand(
      shopId: shop,
      action: 'save',
      selection: selection,
      fingerprint: fingerprint,
    );
    final requests = <Map<String, dynamic>>[];
    rpc = (_, args) async {
      requests.add(args);
      if (requests.length == 1) throw TimeoutException('lost');
      return {'id': draft, 'revision_id': revision, 'action': 'save'};
    };
    final repo = repository();
    expect(
      (await repo.mutate(
        command,
      )).swap().getOrElse(() => throw StateError('failure')),
      PromotionFailure.uncertain,
    );
    expect((await repo.mutate(command)).isRight(), true);
    expect(requests[0], requests[1]);
    expect(command.selection, selection);
  });
  test(
    'same actor refresh during write is uncertain, not an invitation to create again',
    () async {
      final pending = Completer<dynamic>();
      rpc = (_, _) => pending.future;
      final future = repository().mutate(
        PromotionCommand(
          shopId: shop,
          action: 'save',
          selection: selection,
          fingerprint: fingerprint,
        ),
      );
      sessions.add('owner');
      pending.complete({
        'id': draft,
        'revision_id': revision,
        'action': 'save',
      });
      expect(
        (await future).swap().getOrElse(() => throw StateError('failure')),
        PromotionFailure.uncertain,
      );
    },
  );
  for (final code in ['40001', '42501', '28000', '22023', '55000']) {
    test('maps server rejection $code without leaking server detail', () async {
      rpc = (_, _) async => throw PostgrestException(
        message: 'PRIVATE server detail',
        code: code,
      );
      final result = (await repository().read(
        shop,
      )).swap().getOrElse(() => throw StateError('failure'));
      expect(result.message, isNot(contains('PRIVATE')));
      expect(result, switch (code) {
        '40001' => PromotionFailure.changed,
        '42501' || '28000' => PromotionFailure.session,
        '22023' => PromotionFailure.invalid,
        _ => PromotionFailure.unavailable,
      });
    });
  }
  test('malformed success receipt remains uncertain', () async {
    rpc = (_, _) async => {
      'id': draft,
      'revision_id': revision,
      'action': 'publish',
    };
    final result = await repository().mutate(
      PromotionCommand(shopId: shop, action: 'save'),
    );
    expect(
      result.swap().getOrElse(() => throw StateError('failure')),
      PromotionFailure.uncertain,
    );
  });
  test(
    'real PostgREST contract feeds list, preview and history decoders',
    () async {
      final wire =
          jsonDecode(
                File(
                  'docs/data/merchant_promotion_g_contract.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final shopId = wire['shop_id'] as String;
      rpc = (name, _) async => switch (name) {
        'read_merchant_promotions_v1' => wire['list'],
        'preview_merchant_promotion_v1' => wire['preview'],
        _ => wire['history'],
      };
      final repo = repository();
      final list = (await repo.read(
        shopId,
      )).getOrElse(() => throw StateError('list'));
      final p = (await repo.preview(
        shopId,
        list.items.first.selection,
      )).getOrElse(() => throw StateError('preview'));
      expect(list.items.length, 20);
      expect(p.ready, true);
      expect((await repo.history(shopId, list.items.first.id)).isRight(), true);
    },
  );
}
