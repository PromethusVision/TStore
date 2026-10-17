import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/trust_commerce/data/supabase_trust_commerce_repository.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';
import 'package:t_store/features/merchant_promotions/data/supabase_merchant_promotion_repository.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import '../merchant_promotions/promotion_repository_test.dart' as promotion;

class Transport {
  Transport(this.isCampaign) {
    campaign = SupabaseTrustCommerceRepository(
      client,
      currentUserId: () => user,
      currentSessionKey: () => key,
      sessionChanges: sessions.stream,
      readTimeout: const Duration(milliseconds: 25),
      rpc: (n, a) {
        calls.add(n);
        return rpc(n, a);
      },
      imageSigner: (p) {
        signed.add(p);
        return sign(p);
      },
    );
    promo = SupabaseMerchantPromotionRepository(
      client,
      currentUserId: () => user,
      currentSessionKey: () => key,
      sessionChanges: sessions.stream,
      timeout: const Duration(milliseconds: 25),
      rpc: (n, a) {
        calls.add(n);
        return rpc(n, a);
      },
      sign: (p) {
        signed.add(p);
        return sign(p);
      },
    );
  }
  final bool isCampaign;
  final client = SupabaseClient(
    'http://127.0.0.1:55431',
    'synthetic',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  final sessions = StreamController<String?>.broadcast(sync: true);
  String? user = 'owner', key = 'session-one';
  final calls = <String>[], signed = <String>[];
  late SupabaseTrustCommerceRepository campaign;
  late SupabaseMerchantPromotionRepository promo;
  late Future<dynamic> Function(String, Map<String, dynamic>) rpc;
  Future<String> Function(String) sign = (_) async =>
      'https://local.invalid/image';
  String get shop => isCampaign ? previewTrustShop : promotion.shop;
  String get id => isCampaign ? previewCampaignId : promotion.draft;
  Map<String, dynamic> campaignWire({int photos = 0}) => {
    ...PreviewTrustCommerceRepository.exampleDraft().toJson(),
    'id': previewCampaignId,
    'shop_id': previewTrustShop,
    'revision_id': previewCampaignRevision,
    'status': 'draft',
    'products': [],
    'images': List.generate(
      photos,
      (i) => {
        'id': '00000000-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        'listing_id': previewCampaignListing,
        'bucket_id': 'listing-media',
        'object_path':
            'shops/$previewTrustShop/$previewCampaignListing/v1/$i.png',
      },
    ),
  };
  Map<String, dynamic> page() => isCampaign
      ? {
          'enabled': true,
          'price_publication_enabled': false,
          'total': 1,
          'campaigns': [campaignWire()],
        }
      : promotion.page();
  Map<String, dynamic> receipt() => isCampaign
      ? {
          'id': id,
          'shop_id': shop,
          'revision_id': previewCampaignRevision,
          'action': 'save',
        }
      : {'id': id, 'revision_id': promotion.revision, 'action': 'save'};
  Map<String, dynamic> detail() => {
    'enabled': true,
    'shop_id': shop,
    if (isCampaign)
      'campaign': campaignWire()
    else
      'draft': promotion.page()['items'][0],
  };
  Future<dynamic> read() =>
      isCampaign ? campaign.campaigns(shop) : promo.read(shop);
  Future<dynamic> exact() => isCampaign
      ? campaign.readCampaign(shop, id)
      : promo.readPromotion(shop, id);
  Future<dynamic> write() => isCampaign
      ? campaign.mutate(
          CampaignCommand(
            shopId: shop,
            requestId: promotion.photo,
            action: 'save',
            draft: PreviewTrustCommerceRepository.exampleDraft(),
          ),
        )
      : promo.mutate(
          PromotionCommand(
            shopId: shop,
            action: 'save',
            selection: promotion.selection,
            fingerprint: promotion.fingerprint,
          ),
        );
  Future<void> close() async {
    await sessions.close();
    await client.dispose();
  }
}

void main() {
  for (final campaign in [true, false]) {
    final label = campaign ? 'campaign' : 'promotion';
    late Transport t;
    setUp(() {
      t = Transport(campaign);
      t.rpc = (_, _) async => t.page();
    });
    tearDown(() => t.close());
    test(
      '$label missing stable provenance makes zero private requests',
      () async {
        t.key = null;
        expect((await t.read()).isLeft(), true);
        expect((await t.write()).isLeft(), true);
        expect(t.calls, isEmpty);
      },
    );
    for (final event in [
      'replacement',
      'silent replacement',
      'stream error',
      'stream done',
    ]) {
      test('$label fences late success and errors after $event', () async {
        for (final rejects in [false, true]) {
          final pending = Completer<dynamic>();
          t.rpc = (_, _) => pending.future;
          final future = t.read();
          switch (event) {
            case 'replacement':
              t.key = 'next-${t.key}';
              t.sessions.add(t.user);
            case 'silent replacement':
              t.key = 'next-${t.key}';
            case 'stream error':
              t.sessions.addError(StateError('lost'));
            case 'stream done':
              await t.sessions.close();
          }
          if (rejects) {
            pending.completeError(StateError('private payload'));
          } else {
            pending.complete(t.page());
          }
          final result = await future;
          expect(result.isLeft(), true);
          expect(
            result.fold(
              (dynamic e) => e is TrustFailure
                  ? e.kind == TrustFailureKind.auth
                  : e == PromotionFailure.session,
              (_) => false,
            ),
            true,
          );
        }
      });
    }
    test('$label token refresh keeps a pending read', () async {
      final pending = Completer<dynamic>();
      t.rpc = (_, _) => pending.future;
      final future = t.read();
      t.sessions.add(t.user);
      pending.complete(t.page());
      expect((await future).isRight(), true);
    });
    test('$label read deadline does not become a write deadline', () async {
      final pending = Completer<dynamic>();
      t.rpc = (_, _) => pending.future;
      var completed = false;
      final future = t.write().then((v) {
        completed = true;
        return v;
      });
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(completed, false);
      expect(t.calls.length, 1);
      t.sessions.add(t.user);
      pending.complete(t.receipt());
      expect((await future).isRight(), true);
    });
    test('$label timed-out read never signs a late RPC response', () async {
      final pending = Completer<dynamic>();
      t.rpc = (_, _) => pending.future;
      final future = campaign
          ? t.read()
          : t.promo.preview(t.shop, promotion.selection);
      expect((await future).isLeft(), true);
      pending.complete(
        campaign
            ? {
                ...t.page(),
                'campaigns': [t.campaignWire(photos: 2)],
              }
            : promotion.preview(images: [promotion.image()]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(t.signed, isEmpty);
    });
    test(
      '$label abandoned signing does not enqueue additional image calls',
      () async {
        final pending = Completer<String>();
        t.sign = (_) => pending.future;
        t.rpc = (_, _) async => campaign
            ? {
                ...t.page(),
                'campaigns': [t.campaignWire(photos: 5)],
              }
            : promotion.preview(images: [promotion.image(), promotion.image()]);
        final future = campaign
            ? t.read()
            : t.promo.preview(t.shop, promotion.selection);
        expect((await future).isLeft(), true);
        final started = t.signed.length;
        expect(started, campaign ? 4 : 1);
        pending.complete('https://local.invalid/image');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(t.signed.length, started);
      },
    );
    for (final mode in [
      'valid',
      'missing',
      'foreign shop',
      'foreign record',
      'disabled',
      'missing RPC',
    ]) {
      test('$label exact detail validates $mode', () async {
        final value = t.detail(), field = campaign ? 'campaign' : 'draft';
        switch (mode) {
          case 'missing':
            value[field] = null;
          case 'foreign shop':
            value['shop_id'] = promotion.photo;
          case 'foreign record':
            (value[field] as Map)['id'] = promotion.photo;
          case 'disabled':
            value['enabled'] = false;
        }
        t.rpc = (name, args) async {
          expect(
            name,
            campaign
                ? 'read_merchant_campaign_detail_v1'
                : 'read_merchant_promotion_detail_v1',
          );
          expect(args['p_shop_id'], t.shop);
          if (mode == 'missing RPC') {
            throw const PostgrestException(
              message: 'missing',
              code: 'PGRST202',
            );
          }
          return value;
        };
        final result = await t.exact();
        expect(result.isRight(), ['valid', 'missing'].contains(mode));
        if (mode == 'missing') {
          expect(result.getOrElse(() => throw StateError('missing')), null);
        }
        expect(t.calls.length, 1); // no fallback scan of all records
      });
    }
  }
}
