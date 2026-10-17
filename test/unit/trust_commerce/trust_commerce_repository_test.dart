import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/data/supabase_trust_commerce_repository.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';

void main() {
  late SupabaseClient client;
  late SupabaseTrustCommerceRepository repo;
  late StreamController<String?> sessions;
  String? actor;
  dynamic response;
  final calls = <Map<String, dynamic>>[], signed = <String>[];
  setUp(() {
    client = SupabaseClient('http://127.0.0.1:55431', 'synthetic-anon');
    sessions = StreamController<String?>.broadcast(sync: true);
    actor = previewTrustActor;
    calls.clear();
    signed.clear();
    repo = SupabaseTrustCommerceRepository(
      client,
      currentUserId: () => actor,
      currentSessionKey: () => actor == null ? null : "test-session",
      sessionChanges: sessions.stream,
      rpc: (name, args) async {
        calls.add({'name': name, ...args});
        if (response is Exception) throw response as Exception;
        return response;
      },
      imageSigner: (path) async {
        signed.add(path);
        return 'http://127.0.0.1/signed';
      },
    );
  });
  tearDown(() async {
    await client.dispose();
    await sessions.close();
  });
  CampaignCommand command({CampaignDraft? draft}) => CampaignCommand(
    shopId: previewTrustShop,
    requestId: '88888888-8888-4888-8888-888888888888',
    action: 'save',
    draft: draft ?? PreviewTrustCommerceRepository.exampleDraft(),
  );
  Map<String, dynamic> receipt() => {
    'id': previewCampaignId,
    'shop_id': previewTrustShop,
    'revision_id': previewCampaignRevision,
    'action': 'save',
  };
  Map<String, dynamic> campaign() => {
    ...PreviewTrustCommerceRepository.exampleDraft().toJson(),
    'id': previewCampaignId,
    'shop_id': previewTrustShop,
    'revision_id': previewCampaignRevision,
    'status': 'active',
    'products': [
      {'listing_id': previewCampaignListing, 'name': 'Kahve'},
    ],
    'images': [],
  };
  test(
    'invalid inputs and signed-out private reads never call backend; anonymous public reads work',
    () async {
      expect((await repo.trust(shopId: 'bad')).isLeft(), true);
      actor = null;
      expect((await repo.trust()).isLeft(), true);
      expect((await repo.mutate(command())).isLeft(), true);
      expect(calls, isEmpty);
      response = {'enabled': false, 'shops': []};
      expect(
        (await repo.shopBadges(
          previewTrustShop,
        )).getOrElse(() => throw StateError('public')),
        isEmpty,
      );
      response = {
        'enabled': true,
        'campaigns': [campaign()],
        'server_time': DateTime.utc(2026, 10, 15).toIso8601String(),
      };
      expect(
        (await repo.shopCampaigns(
          previewTrustShop,
        )).getOrElse(() => throw StateError('public')).single.draft.title,
        isNotEmpty,
      );
    },
  );
  test(
    'command copies selections; unknown outcomes retry exact payload and safe errors',
    () async {
      final ids = [previewCampaignListing];
      final draft = CampaignDraft(
        title: 'Test',
        description: '',
        type: CampaignType.announcement,
        scope: CampaignScope.single,
        startsAt: DateTime.utc(2026, 10, 15),
        endsAt: DateTime.utc(2026, 10, 16),
        listingIds: ids,
      );
      final request = command(draft: draft);
      ids.clear();
      expect(request.draft!.listingIds, [previewCampaignListing]);
      response = TimeoutException('SECRET');
      final failed = await repo.mutate(request);
      expect(failed.fold((e) => e.retrySameRequest, (_) => false), true);
      expect(
        failed.fold((e) => e.message, (_) => ''),
        isNot(contains('SECRET')),
      );
      response = receipt();
      expect((await repo.mutate(request)).isRight(), true);
      expect(calls[0], calls[1]);
      expect(
        calls.singleWhere((c) => c == calls.first)['p_draft'],
        isNot(contains('actor_id')),
      );
    },
  );
  test(
    'concurrent change and monetary gate are definitive while malformed receipts remain uncertain',
    () async {
      response = const PostgrestException(
        message: '[CAMPAIGN_CHANGED]',
        code: '40001',
      );
      expect(
        (await repo.mutate(command())).fold((e) => e.kind, (_) => null),
        TrustFailureKind.changed,
      );
      response = const PostgrestException(
        message: '[CAMPAIGN_BLOCKED:price_publication_pending]',
        code: '55000',
      );
      expect(
        (await repo.mutate(command())).fold((e) => e.kind, (_) => null),
        TrustFailureKind.unavailable,
      );
      response = receipt()..['shop_id'] = previewCampaignListing;
      expect(
        (await repo.mutate(
          command(),
        )).fold((e) => e.retrySameRequest, (_) => false),
        true,
      );
    },
  );
  test(
    'logout and return to the same account discards a pending response',
    () async {
      final pending = Completer<dynamic>();
      response = pending.future;
      final read = repo.trust();
      actor = null;
      sessions.add(null);
      actor = previewTrustActor;
      sessions.add(actor);
      pending.complete({'enabled': true, 'badges': [], 'history': []});
      expect(
        (await read).fold((e) => e.kind, (_) => null),
        TrustFailureKind.auth,
      );
    },
  );
  test(
    'foreign or arbitrary image paths never get signed; owned images decode safely',
    () async {
      final row = campaign();
      row['images'] = [
        {
          'id': previewCampaignId,
          'listing_id': previewCampaignListing,
          'bucket_id': 'listing-media',
          'object_path': 'https://attacker.invalid/key',
        },
      ];
      response = {
        'enabled': true,
        'campaigns': [row],
        'server_time': DateTime.utc(2026, 10, 15).toIso8601String(),
      };
      expect((await repo.shopCampaigns(previewTrustShop)).isLeft(), true);
      expect(signed, isEmpty);
      (row['images'] as List).single['object_path'] =
          'shops/$previewTrustShop/$previewCampaignListing/v1/$previewCampaignId.png';
      final result = (await repo.shopCampaigns(
        previewTrustShop,
      )).getOrElse(() => throw StateError('decode'));
      expect(result.single.images.single.url, 'http://127.0.0.1/signed');
      expect(result.single.products.single.name, 'Kahve');
      row['shop_id'] = previewCampaignListing;
      expect((await repo.shopCampaigns(previewTrustShop)).isLeft(), true);
    },
  );
  test(
    'milestone strip selects highest eligible level per family; strict draft limits',
    () {
      final badges = highestTrustBadges(
        PreviewTrustCommerceRepository.customerBadges,
      );
      expect(badges.length, 2);
      expect(badges.every((b) => b.level == 1), true);
      final valid = PreviewTrustCommerceRepository.exampleDraft();
      expect(valid.error, null);
      final invalid = CampaignDraft(
        title: 'X',
        description: '',
        type: CampaignType.percentage,
        scope: CampaignScope.all,
        startsAt: valid.startsAt,
        endsAt: valid.endsAt,
        percentageBasisPoints: 10001,
      );
      expect(invalid.error, isNotNull);
      expect(
        newCampaignRequestId(),
        matches(RegExp(r'^[a-f0-9-]{14}4[a-f0-9-]{21}$')),
      );
    },
  );
}
