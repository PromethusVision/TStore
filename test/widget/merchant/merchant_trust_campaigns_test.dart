import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_campaigns.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/trust_commerce/preview/trust_commerce_preview.dart';
import 'package:t_store/features/trust_commerce/presentation/trust_views.dart';
import '../w49/w49_domain_fixture.dart' show loadW49Fonts, pumpW49;

class ControlledTrust extends PreviewTrustCommerceRepository {
  ControlledTrust(MerchantPreview host)
    : super(user: () => host.currentId, sessionChanges: host.changes.stream);
  final requests = <CampaignCommand>[];
  Future<Either<TrustFailure, CampaignReceipt>>? nextMutation;
  Future<Either<TrustFailure, CampaignPage>>? nextRead;
  @override
  Future<Either<TrustFailure, CampaignReceipt>> mutate(
    CampaignCommand command,
  ) {
    requests.add(command);
    return nextMutation ?? super.mutate(command);
  }

  @override
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  }) => nextRead ?? super.campaigns(shopId, offset: offset);
}

class CampaignMediaMock extends Mock implements CatalogMediaRepository {}

MerchantServices services(
  MerchantPreview host,
  TrustCommerceRepository repo, {
  CatalogMediaRepository? media,
}) {
  final base = host.services;
  return MerchantServices(
    merchants: base.merchants,
    credentials: base.credentials,
    notifications: base.notifications,
    qr: base.qr,
    preferences: base.preferences,
    sessionChanges: base.sessionChanges,
    currentUserId: base.currentUserId,
    trustCommerce: repo,
    catalogMedia: media,
  );
}

void main() {
  setUpAll(loadW49Fonts);
  testWidgets(
    'public offer disappears at server-derived expiry without a screen reload',
    (tester) async {
      final campaign = Campaign(
        id: previewCampaignId,
        shopId: previewTrustShop,
        revisionId: previewCampaignRevision,
        draft: PreviewTrustCommerceRepository.exampleDraft(),
        status: 'active',
        displayExpiresAt: DateTime.now().add(const Duration(seconds: 2)),
      );
      await pumpW49(
        tester,
        Scaffold(body: PublicCampaignCard(campaign: campaign)),
      );
      expect(find.text(campaign.draft.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text(campaign.draft.title), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  late MerchantPreview host;
  late ControlledTrust repo;
  late MerchantAccess access;
  setUp(() {
    host = MerchantPreview();
    repo = ControlledTrust(host);
    access = MerchantAccess(user: host.user, shop: host.repository.shop);
  });
  tearDown(() async {
    await host.dispose();
  });
  testWidgets(
    'campaign selects existing published product photo and preserves its ID in the draft',
    (tester) async {
      final media = CampaignMediaMock(), first = host.repository.items.first;
      when(() => media.media(access, first.id)).thenAnswer(
        (_) async => const Right(
          ListingMedia(
            [
              ListingImage(
                id: previewCampaignId,
                path: 'shops/example/photo.png',
                state: 'published',
                primary: true,
                order: 0,
              ),
            ],
            maxPhotos: 5,
            maxBytes: 1000,
          ),
        ),
      );
      final original = repo.rows.first;
      final draft = CampaignDraft(
        title: original.draft.title,
        description: '',
        type: CampaignType.announcement,
        scope: CampaignScope.all,
        startsAt: original.draft.startsAt,
        endsAt: original.draft.endsAt,
      );
      final existing = Campaign(
        id: original.id,
        shopId: original.shopId,
        revisionId: original.revisionId,
        draft: draft,
        status: 'draft',
      );
      repo.nextMutation = Future.value(
        const Left(TrustFailure(TrustFailureKind.uncertain, 'Tekrar dene')),
      );
      await pumpW49(
        tester,
        MerchantCampaignEditor(
          services: services(host, repo, media: media),
          access: access,
          existing: existing,
        ),
      );
      await tester.ensureVisible(find.text('Ürün fotoğraflarından seç'));
      await tester.tap(find.text('Ürün fotoğraflarından seç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(first.product!.name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seçimi kullan (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${first.product!.name} · Fotoğraf 1'));
      await tester.pumpAndSettle();
      expect(find.text('Fotoğraf 1'), findsOneWidget);
      await tester.ensureVisible(find.text('Taslak olarak kaydet'));
      await tester.tap(find.text('Taslak olarak kaydet'));
      await tester.pumpAndSettle();
      expect(repo.requests.single.draft!.imageIds, [previewCampaignId]);
      verify(() => media.media(access, first.id)).called(1);
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('D/F trust, campaigns, editor and customer offers at $width', (
      tester,
    ) async {
      final pages = <String, Widget>{
        'trust': TrustDetailView(
          repository: repo,
          actor: host.user.id,
          shopId: previewTrustShop,
        ),
        'campaigns': MerchantCampaignsView(
          services: services(host, repo),
          access: access,
        ),
        'editor': MerchantCampaignEditor(
          services: services(host, repo),
          access: access,
          existing: repo.rows.first,
        ),
        'customer': Scaffold(
          appBar: AppBar(title: const Text('Mahalle Market')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ShopTrustOffers(repository: repo, shopId: previewTrustShop),
          ),
        ),
      };
      for (final entry in pages.entries) {
        await tester.pumpWidget(const SizedBox());
        await pumpW49(
          tester,
          entry.value,
          width: width,
          scale: width == 320 ? 1.3 : 1,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), null, reason: entry.key);
        await expectLater(
          find.byKey(const Key('w49-evidence')),
          matchesGoldenFile('goldens/df_${entry.key}_${width.toInt()}.png'),
        );
      }
    });
  }
  testWidgets(
    'badge explanation persists and dismisses outside; highest level only',
    (tester) async {
      await pumpW49(
        tester,
        Scaffold(
          body: TrustBadgeStrip(badges: PreviewTrustCommerceRepository.badges),
        ),
      );
      await tester.tap(find.text('Güleryüzlü Esnaf'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tapAt(const Offset(3, 3));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
  testWidgets(
    'empty, error, retry and disabled center do not fabricate campaigns',
    (tester) async {
      repo.nextRead = Future.value(
        const Left(TrustFailure(TrustFailureKind.unavailable, 'Bağlantı yok.')),
      );
      await pumpW49(
        tester,
        MerchantCampaignsView(services: services(host, repo), access: access),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bağlantı yok.'), findsOneWidget);
      expect(find.text('Kampanya oluştur'), findsNothing);
      repo.nextRead = null;
      repo.rows.clear();
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(
        find.text('Henüz kampanyan yok. İlk duyurunu oluştur.'),
        findsOneWidget,
      );
      repo.enabled = false;
      await tester.tap(find.byTooltip('Yenile'));
      await tester.pumpAndSettle();
      expect(
        find.text('Kampanyalar henüz kullanıma açılmadı.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'double submit locks form; unknown result retries identical command',
    (tester) async {
      final pending = Completer<Either<TrustFailure, CampaignReceipt>>();
      repo.nextMutation = pending.future;
      await pumpW49(
        tester,
        MerchantCampaignEditor(
          services: services(host, repo),
          access: access,
          existing: repo.rows.first,
        ),
      );
      await tester.ensureVisible(find.text('Taslak olarak kaydet'));
      await tester.tap(find.text('Taslak olarak kaydet'));
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(repo.requests.length, 1);
      pending.complete(
        const Left(
          TrustFailure(TrustFailureKind.uncertain, 'Sonuç doğrulanamadı.'),
        ),
      );
      await tester.pumpAndSettle();
      final inputs = tester.widgetList<TextField>(find.byType(TextField));
      expect(inputs.every((f) => f.enabled == false), true);
      repo.nextMutation = Future.value(
        const Left(
          TrustFailure(TrustFailureKind.uncertain, 'Sonuç doğrulanamadı.'),
        ),
      );
      await tester.tap(find.text('Aynı işlemi tekrar dene'));
      await tester.pumpAndSettle();
      expect(repo.requests.length, 2);
      expect(identical(repo.requests[0], repo.requests[1]), true);
    },
  );
  testWidgets('logout clears editor and an already-open private preview', (
    tester,
  ) async {
    await pumpW49(
      tester,
      MerchantCampaignEditor(
        services: services(host, repo),
        access: access,
        existing: repo.rows.first,
      ),
    );
    await tester.ensureVisible(find.text('Müşteri görünümünü önizle'));
    await tester.tap(find.text('Müşteri görünümünü önizle'));
    await tester.pumpAndSettle();
    expect(find.text('Önizleme · Henüz yayınlanmadı'), findsOneWidget);
    host.currentId = null;
    host.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Önizleme · Henüz yayınlanmadı'), findsNothing);
    expect(find.text('Haftanın mahalle buluşması'), findsNothing);
    host.currentId = host.user.id;
    host.changes.add(host.user.id);
    await tester.pumpAndSettle();
    expect(find.text('Haftanın mahalle buluşması'), findsNothing);
  });
  testWidgets('form validates scope and dates before invoking write', (
    tester,
  ) async {
    await pumpW49(
      tester,
      MerchantCampaignEditor(services: services(host, repo), access: access),
    );
    await tester.ensureVisible(find.text('Taslak olarak kaydet'));
    await tester.tap(find.text('Taslak olarak kaydet'));
    await tester.pumpAndSettle();
    expect(repo.requests, isEmpty);
    expect(
      find.text('Başlık 1–100, açıklama en fazla 500 karakter olmalı.'),
      findsOneWidget,
    );
  });
}
