import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/merchant/presentation/merchant_campaigns.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/trust_commerce/domain/trust_commerce.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import 'package:t_store/features/merchant_promotions/presentation/merchant_promotion_center.dart';
import 'merchant_trust_campaigns_test.dart' as campaigns;
import 'merchant_promotion_test.dart' as promotions;
import '../w49/w49_domain_fixture.dart' show loadW49Fonts, pumpW49;

const changed = TrustFailure(TrustFailureKind.changed, 'Kampanya değişti');
const unavailable = TrustFailure(TrustFailureKind.unavailable, 'Bağlantı yok');
const uncertain = TrustFailure(TrustFailureKind.uncertain, 'Sonuç belirsiz');

class PickerMerchant extends Mock implements MerchantRepository {}

class PickerMedia extends Mock implements CatalogMediaRepository {}

class RecoveryCampaigns extends campaigns.ControlledTrust
    implements CampaignRecoveryRepository, AuthenticatedSessionSource {
  RecoveryCampaigns(super.host);
  String? key = 'one';
  @override
  String? get currentSessionKey => key;
  final offsets = <int>[];
  int detailReads = 0;
  bool throwWrite = false;
  Either<TrustFailure, Campaign?>? detail;
  Future<Either<TrustFailure, Campaign?>>? detailWait;
  @override
  Future<Either<TrustFailure, Campaign?>> readCampaign(
    String shop,
    String id,
  ) async {
    detailReads++;
    return detailWait ?? detail ?? Right(rows.first);
  }

  @override
  Future<Either<TrustFailure, CampaignPage>> campaigns(
    String shopId, {
    int offset = 0,
  }) {
    offsets.add(offset);
    return super.campaigns(shopId, offset: offset);
  }

  @override
  Future<Either<TrustFailure, CampaignReceipt>> mutate(
    CampaignCommand command,
  ) {
    if (throwWrite) {
      requests.add(command);
      throw StateError('offline');
    }
    return super.mutate(command);
  }
}

class RecoveryPromotions extends promotions.PromotionFake
    implements PromotionRecoveryRepository, AuthenticatedSessionSource {
  String? key = 'one';
  @override
  String? get currentSessionKey => key;
  int detailReads = 0;
  Either<PromotionFailure, PromotionDraft?>? detail;
  Future<Either<PromotionFailure, PromotionDraft?>>? detailWait;
  final sourceOffsets = <int>[], historyOffsets = <int>[], queries = <String>[];
  List<PromotionSource> sourceRows = const [
    PromotionSource(promotions.listing, 'Güncel kalem'),
  ];
  List<PromotionHistoryEntry> historyRows = [];
  PromotionFailure? sourceError, historyError;
  bool throwWrite = false;
  @override
  Future<Either<PromotionFailure, PromotionDraft?>> readPromotion(
    String shop,
    String id,
  ) async {
    detailReads++;
    return detailWait ?? detail ?? Right(value.items.first);
  }

  @override
  Future<Either<PromotionFailure, PromotionReceipt>> mutate(
    PromotionCommand command,
  ) {
    if (throwWrite) {
      writes.add(command);
      throw StateError('offline');
    }
    return super.mutate(command);
  }

  @override
  Future<Either<PromotionFailure, List<PromotionSource>>> sources(
    String shopId,
    String kind, {
    String query = '',
    int offset = 0,
  }) async {
    sourceOffsets.add(offset);
    queries.add(query);
    return sourceError == null ? Right(sourceRows) : Left(sourceError!);
  }

  @override
  Future<Either<PromotionFailure, List<PromotionHistoryEntry>>> history(
    String shopId,
    String draftId, {
    int offset = 0,
  }) async {
    historyOffsets.add(offset);
    return historyError == null ? Right(historyRows) : Left(historyError!);
  }
}

Campaign freshCampaign(Campaign old) => Campaign(
  id: old.id,
  shopId: old.shopId,
  revisionId: 'fresh-revision',
  status: 'paused',
  draft: CampaignDraft(
    title: 'Diğer cihazdaki başlık',
    description: 'Güncel açıklama',
    type: old.draft.type,
    scope: old.draft.scope,
    startsAt: old.draft.startsAt,
    endsAt: old.draft.endsAt,
    listingIds: old.draft.listingIds,
    imageIds: old.draft.imageIds,
    priceMinor: old.draft.priceMinor,
    percentageBasisPoints: old.draft.percentageBasisPoints,
  ),
  products: old.products,
  images: old.images,
);
PromotionDraft freshPromotion() => PromotionDraft(
  id: promotions.draftId,
  revisionId: 'fresh-revision',
  shopId: promotions.shop,
  status: 'draft',
  selection: const PromotionSelection(variant: 1),
  copy: const PromotionCopy('Güncel mağaza', 'Diğer cihazdaki seçim'),
  recordedAt: DateTime.utc(2026, 10, 17),
);

Future<void> tap(WidgetTester t, String label, {bool settle = true}) async {
  final base = find.text(label);
  if (base.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      base,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  final finder = base.last;
  await t.ensureVisible(finder);
  await t.pump();
  await t.ensureVisible(finder);
  await t.pump();
  await t.tap(finder);
  if (settle) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
  }
}

Future<void> capture(WidgetTester t, String name) async {
  if (!const bool.fromEnvironment('MANAGEMENT_CAPTURE')) return;
  await t.ensureVisible(find.text('Güncel kaydı kontrol et').last);
  await t.pumpAndSettle();
  final boundary = t.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('w49-evidence')),
  );
  await t.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final dir = Directory('docs/evidence/merchant_management');
    await dir.create(recursive: true);
    await File(
      '${dir.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void resumeApp(WidgetTester t) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    t.binding.handleAppLifecycleStateChanged(state);
  }
}

void main() {
  setUpAll(loadW49Fonts);
  late MerchantPreview host;
  late RecoveryCampaigns campaign;
  late RecoveryPromotions promo;
  late MerchantAccess access;
  setUp(() {
    host = MerchantPreview();
    campaign = RecoveryCampaigns(host);
    promo = RecoveryPromotions();
    access = MerchantAccess(user: host.user, shop: host.repository.shop);
  });
  tearDown(() async {
    if (!host.changes.isClosed) await host.changes.close();
    await host.notifications.events.close();
    if (!promo.sessions.isClosed) await promo.sessions.close();
  });
  Widget editor() => MerchantCampaignEditor(
    services: campaigns.services(host, campaign),
    access: access,
    existing: campaign.rows.first,
  );
  Widget center() => MerchantPromotionCenter(
    repository: promo,
    shopId: promotions.shop,
    ownerId: 'owner',
  );
  Future<void> openPromotion(WidgetTester t) async {
    await pumpW49(t, center());
    await t.pumpAndSettle();
    await tap(t, 'Düzenle');
  }

  Future<void> campaignConflict(WidgetTester t) async {
    campaign.nextMutation = Future.value(const Left(changed));
    await pumpW49(t, editor());
    await t.pumpAndSettle();
    await t.enterText(
      find.widgetWithText(TextField, 'Kampanya başlığı'),
      'Benim hazırladığım başlık',
    );
    await tap(t, 'Taslak olarak kaydet');
    campaign.detail = Right(freshCampaign(campaign.rows.first));
    await tap(t, 'Güncel kaydı kontrol et');
  }

  Future<void> promotionConflict(WidgetTester t) async {
    await openPromotion(t);
    await tap(t, 'Fotoğraf için ürün seç (isteğe bağlı)');
    await tap(t, 'Güncel kalem');
    await tap(t, 'Önizlemeyi yenile');
    promo.writeError = PromotionFailure.changed;
    await tap(t, 'Taslağı kaydet');
    promo.detail = Right(freshPromotion());
    await tap(t, 'Güncel kaydı kontrol et');
  }

  testWidgets(
    'campaign conflict keeps draft and uses fresh revision with a new request',
    (t) async {
      await campaignConflict(t);
      expect(find.textContaining('Diğer cihazdaki başlık'), findsOneWidget);
      await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
      campaign.nextMutation = Future.value(const Left(uncertain));
      await tap(t, 'Taslak olarak kaydet');
      expect(campaign.requests.last.expectedRevision, 'fresh-revision');
      expect(campaign.requests.last.draft!.title, 'Benim hazırladığım başlık');
      expect(
        campaign.requests.first.requestId,
        isNot(campaign.requests.last.requestId),
      );
      expect(campaign.requests.last.action, 'save');
    },
  );
  testWidgets(
    'campaign conflict can explicitly replace form with current record',
    (t) async {
      await campaignConflict(t);
      await tap(t, 'Güncel bilgileri kullan');
      final field = t.widget<TextField>(
        find.widgetWithText(TextField, 'Kampanya başlığı'),
      );
      expect(field.controller!.text, 'Diğer cihazdaki başlık');
      campaign.nextMutation = Future.value(const Left(uncertain));
      await tap(t, 'Taslak olarak kaydet');
      expect(campaign.requests.last.expectedRevision, 'fresh-revision');
    },
  );
  for (final mode in ['missing', 'disabled', 'timeout']) {
    testWidgets('campaign $mode recovery remains blocked and draft survives', (
      t,
    ) async {
      await campaignConflict(t);
      if (mode == 'missing') {
        campaign.detail = const Right(null);
      } else if (mode == 'disabled') {
        campaign.detail = const Left(unavailable);
      } else {
        campaign.detailWait =
            Completer<Either<TrustFailure, Campaign?>>().future;
      }
      await tap(t, 'Güncel kaydı kontrol et', settle: mode != 'timeout');
      if (mode == 'timeout') {
        await t.pump(const Duration(seconds: 16));
        await t.pumpAndSettle();
      }
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Taslak olarak kaydet'),
            )
            .onPressed,
        null,
      );
      expect(find.text('Taslağımı bu kayıt üzerinde düzenle'), findsNothing);
      await t.scrollUntilVisible(
        find.text('Kampanya başlığı'),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        t
            .widget<TextField>(
              find.widgetWithText(TextField, 'Kampanya başlığı'),
            )
            .controller!
            .text,
        'Benim hazırladığım başlık',
      );
      expect(campaign.requests.length, 1);
    });
  }
  testWidgets('campaign dirty back has one explicit discard prompt', (t) async {
    await pumpW49(
      t,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => editor()),
            ),
            child: const Text('Aç'),
          ),
        ),
      ),
    );
    await tap(t, 'Aç');
    await t.enterText(
      find.widgetWithText(TextField, 'Kampanya başlığı'),
      'Taslağım',
    );
    await t.pump();
    await t.pageBack();
    await t.pumpAndSettle();
    expect(find.text('Değişikliklerden vazgeçilsin mi?'), findsOneWidget);
    await tap(t, 'Düzenlemeye dön');
    expect(find.text('Taslağım'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    await tap(t, 'Vazgeç ve çık');
    expect(find.text('Aç'), findsOneWidget);
    expect(campaign.requests, isEmpty);
  });
  testWidgets(
    'campaign raw pagination and failed-page retry ignore display deduplication',
    (t) async {
      campaign.nextRead = Future.value(
        Right(
          CampaignPage(
            enabled: true,
            pricePublicationEnabled: false,
            campaigns: [campaign.rows.first, campaign.rows.first],
            total: 4,
          ),
        ),
      );
      await pumpW49(
        t,
        MerchantCampaignsView(
          services: campaigns.services(host, campaign),
          access: access,
        ),
      );
      await t.pumpAndSettle();
      campaign.nextRead = Future.value(const Left(unavailable));
      await tap(t, 'Daha fazla kampanya');
      expect(campaign.offsets, [0, 2]);
      expect(
        t
            .widget<TextButton>(find.widgetWithText(TextButton, 'Düzenle'))
            .onPressed,
        null,
      );
      campaign.nextRead = Future.value(
        Right(
          CampaignPage(
            enabled: true,
            pricePublicationEnabled: false,
            campaigns: [campaign.rows.last],
            total: 3,
          ),
        ),
      );
      // TrustRetry uses the same failed-page callback.
      await tap(t, 'Tekrar dene');
      expect(campaign.offsets, [0, 2, 2]);
      expect(find.text('Daha fazla kampanya'), findsNothing);
    },
  );
  testWidgets('campaign publish confirmation coalesces rapid taps', (t) async {
    final original = campaign.rows.first;
    campaign.rows
      ..clear()
      ..add(
        Campaign(
          id: original.id,
          shopId: original.shopId,
          revisionId: original.revisionId,
          draft: original.draft,
          status: 'draft',
        ),
      );
    await pumpW49(
      t,
      MerchantCampaignsView(
        services: campaigns.services(host, campaign),
        access: access,
      ),
    );
    await t.pumpAndSettle();
    final target = find.widgetWithText(FilledButton, 'Yayınla');
    final onPressed = t.widget<FilledButton>(target).onPressed!;
    onPressed();
    onPressed();
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(campaign.requests, isEmpty);
    await tap(t, 'Vazgeç');
    expect(campaign.requests, isEmpty);
  });
  for (final error in [false, true]) {
    testWidgets(
      'promotion running write survives resume and refresh, failure=$error',
      (t) async {
        await openPromotion(t);
        await tap(t, 'Önizlemeyi yenile');
        promo.writeWait = Completer();
        await tap(t, 'Taslağı kaydet', settle: false);
        resumeApp(t);
        promo.sessions.add('owner');
        await t.pump(const Duration(seconds: 45));
        expect(find.text('Aynı işlemi kontrol et'), findsNothing);
        expect(promo.writes.length, 1);
        expect(
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Taslağı kaydet'),
              )
              .onPressed,
          null,
        );
        if (error) {
          promo.writeWait!.completeError(StateError('lost acknowledgement'));
        } else {
          promo.writeWait!.complete(
            const Right(
              PromotionReceipt(promotions.draftId, promotions.rev, 'save'),
            ),
          );
        }
        await t.pumpAndSettle();
        if (error) {
          expect(find.text('Aynı işlemi kontrol et'), findsOneWidget);
          promo.writeWait = null;
          await tap(t, 'Aynı işlemi kontrol et');
          expect(identical(promo.writes[0], promo.writes[1]), true);
        } else {
          expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
        }
      },
    );
  }
  testWidgets(
    'promotion conflict keeps selection but requires fresh preview and revision',
    (t) async {
      await promotionConflict(t);
      await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
      expect(find.text('Ürün: Güncel kalem'), findsOneWidget);
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Taslağı kaydet'),
            )
            .onPressed,
        null,
      );
      promo.writeError = PromotionFailure.uncertain;
      await tap(t, 'Önizlemeyi yenile');
      await tap(t, 'Taslağı kaydet');
      expect(promo.writes.last.expectedRevision, 'fresh-revision');
      expect(promo.writes.last.selection!.listingId, promotions.listing);
      expect(promo.writes.last.requestId, isNot(promo.writes.first.requestId));
    },
  );
  testWidgets(
    'promotion new draft source conflict can preview again without nonexistent detail',
    (t) async {
      await pumpW49(t, center());
      await t.pumpAndSettle();
      await tap(t, 'Yeni tanıtım taslağı');
      await tap(t, 'Önizlemeyi yenile');
      promo.writeError = PromotionFailure.changed;
      await tap(t, 'Taslağı kaydet');
      expect(find.text('Güncel kaydı kontrol et'), findsNothing);
      await tap(t, 'Önizlemeyi yenile');
      promo.writeError = null;
      await tap(t, 'Taslağı kaydet');
      expect(promo.writes.length, 2);
      expect(promo.detailReads, 0);
    },
  );
  testWidgets(
    'promotion explicit use-current resets selection and still needs preview',
    (t) async {
      await promotionConflict(t);
      await tap(t, 'Güncel bilgileri kullan');
      expect(find.text('Seçenek 2'), findsOneWidget);
      expect(
        find.text('Fotoğraf için ürün seç (isteğe bağlı)'),
        findsOneWidget,
      );
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Taslağı kaydet'),
            )
            .onPressed,
        null,
      );
    },
  );
  testWidgets(
    'promotion missing recovery cannot silently create a new record',
    (t) async {
      await promotionConflict(t);
      promo.detail = const Right(null);
      await tap(t, 'Güncel kaydı kontrol et');
      expect(find.textContaining('Kayıt artık bulunamıyor'), findsOneWidget);
      expect(find.text('Taslağımı bu kayıt üzerinde düzenle'), findsNothing);
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Taslağı kaydet'),
            )
            .onPressed,
        null,
      );
      expect(promo.writes.length, 1);
    },
  );
  testWidgets(
    'promotion unsaved internal navigation preserves selection on cancel',
    (t) async {
      await openPromotion(t);
      await tap(t, 'Fotoğraf için ürün seç (isteğe bağlı)');
      await tap(t, 'Güncel kalem');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(find.text('Değişikliklerden vazgeçilsin mi?'), findsOneWidget);
      await tap(t, 'Düzenlemeye dön');
      expect(find.text('Ürün: Güncel kalem'), findsOneWidget);
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      await tap(t, 'Vazgeç ve devam et');
      expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
      expect(promo.writes, isEmpty);
    },
  );
  for (final type in ['campaign', 'promotion']) {
    testWidgets('$type late continuation expires silently replaced session', (
      t,
    ) async {
      if (type == 'campaign') {
        final pending = Completer<Either<TrustFailure, CampaignPage>>();
        campaign.nextRead = pending.future;
        await pumpW49(
          t,
          MerchantCampaignsView(
            services: campaigns.services(host, campaign),
            access: access,
          ),
        );
        campaign.key = 'replacement';
        pending.complete(
          Right(
            CampaignPage(
              enabled: true,
              pricePublicationEnabled: false,
              campaigns: campaign.rows,
            ),
          ),
        );
      } else {
        promo.readWait = Completer();
        await pumpW49(t, center());
        promo.key = 'replacement';
        promo.readWait!.complete(Right(promo.value));
      }
      await t.pumpAndSettle();
      expect(find.textContaining('Oturum değişti'), findsAtLeastNWidgets(1));
      expect(find.text('Kampanya oluştur'), findsNothing);
      expect(find.text('Yeni tanıtım taslağı'), findsNothing);
    });
    for (final event in ['replacement', 'stream error', 'stream done']) {
      testWidgets('$type route rejects $event and cannot revive', (t) async {
        if (type == 'campaign') {
          await pumpW49(t, editor());
          await t.pumpAndSettle();
          if (event == 'replacement') {
            campaign.key = 'two';
            host.changes.add(host.currentId);
          } else if (event == 'stream error') {
            host.changes.addError(StateError('lost'));
          } else {
            await t.runAsync(host.changes.close);
          }
        } else {
          await openPromotion(t);
          await tap(t, 'Önizlemeyi yenile');
          if (event == 'replacement') {
            promo.key = 'two';
            promo.sessions.add('owner');
          } else if (event == 'stream error') {
            promo.sessions.addError(StateError('lost'));
          } else {
            await t.runAsync(promo.sessions.close);
          }
        }
        await t.pumpAndSettle();
        expect(find.textContaining('Oturum değişti'), findsAtLeastNWidgets(1));
        campaign.key = 'one';
        promo.key = 'one';
        if (event != 'stream done') {
          host.changes.add(host.currentId);
          promo.sessions.add('owner');
        }
        await t.pumpAndSettle();
        expect(find.text('Taslak olarak kaydet'), findsNothing);
        expect(find.text('Taslağı kaydet'), findsNothing);
      });
    }
  }
  testWidgets(
    'promotion raw list/source/history offsets and same failed-page retries',
    (t) async {
      promo.value = PromotionPage(
        enabled: true,
        items: [promotions.draft(), promotions.draft()],
        hasMore: true,
      );
      await pumpW49(t, center());
      await t.pumpAndSettle();
      promo.readError = PromotionFailure.unavailable;
      await tap(t, 'Daha fazla taslak');
      expect(promo.offsets, [0, 2]);
      promo.readError = null;
      promo.value = const PromotionPage(
        enabled: true,
        items: [],
        hasMore: false,
      );
      await tap(t, 'Tekrar dene');
      expect(promo.offsets, [0, 2, 2]);
      await tap(t, 'Düzenle');
      promo.sourceRows = List.filled(
        20,
        const PromotionSource(promotions.listing, 'Güncel kalem'),
      );
      await tap(t, 'Fotoğraf için ürün seç (isteğe bağlı)');
      promo.sourceError = PromotionFailure.unavailable;
      await tap(t, 'Daha fazla sonuç');
      expect(promo.sourceOffsets, [0, 20]);
      await t.enterText(find.widgetWithText(TextField, 'Ara'), 'başka sorgu');
      promo.sourceError = null;
      promo.sourceRows = [];
      await tap(t, 'Tekrar dene');
      expect(promo.sourceOffsets, [0, 20, 20]);
      expect(promo.queries, ['', '', '']);
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      promo.value = PromotionPage(
        enabled: true,
        items: [promotions.draft()],
        hasMore: false,
      );
      await tap(t, 'Listeyi yenile');
      promo.historyRows = List.filled(
        20,
        PromotionHistoryEntry(
          'rev',
          'save',
          promotions.copy,
          DateTime.utc(2026),
        ),
      );
      await tap(t, 'Geçmiş');
      promo.historyError = PromotionFailure.unavailable;
      await tap(t, 'Daha fazla kayıt');
      promo.historyError = null;
      promo.historyRows = [];
      await tap(t, 'Tekrar dene');
      expect(promo.historyOffsets, [0, 20, 20]);
    },
  );
  testWidgets('promotion read deadline releases UI and ignores the late page', (
    t,
  ) async {
    promo.readWait = Completer();
    await pumpW49(t, center());
    await t.pump(const Duration(seconds: 16));
    await t.pumpAndSettle();
    expect(find.text(PromotionFailure.unavailable.message), findsOneWidget);
    final old = promo.readWait!;
    promo.readWait = null;
    await tap(t, 'Tekrar dene');
    old.complete(
      const Right(PromotionPage(enabled: false, items: [], hasMore: false)),
    );
    await t.pumpAndSettle();
    expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
  });
  testWidgets(
    'campaign transport throw preserves exact retry and live write stays locked on resume',
    (t) async {
      campaign.throwWrite = true;
      await pumpW49(t, editor());
      await t.pumpAndSettle();
      await tap(t, 'Taslak olarak kaydet');
      expect(find.text('Aynı işlemi tekrar dene'), findsOneWidget);
      final pending = Completer<Either<TrustFailure, CampaignReceipt>>();
      campaign.throwWrite = false;
      campaign.nextMutation = pending.future;
      await tap(t, 'Aynı işlemi tekrar dene', settle: false);
      resumeApp(t);
      host.changes.add(host.currentId);
      await t.pump(const Duration(seconds: 45));
      expect(campaign.requests.length, 2);
      expect(identical(campaign.requests[0], campaign.requests[1]), true);
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Aynı işlemi tekrar dene'),
            )
            .onPressed,
        null,
      );
      pending.complete(const Left(uncertain));
      await t.pumpAndSettle();
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Aynı işlemi tekrar dene'),
            )
            .onPressed,
        isNotNull,
      );
    },
  );
  testWidgets('campaign read deadline ignores late response after retry', (
    t,
  ) async {
    final pending = Completer<Either<TrustFailure, CampaignPage>>();
    campaign.nextRead = pending.future;
    await pumpW49(
      t,
      MerchantCampaignsView(
        services: campaigns.services(host, campaign),
        access: access,
      ),
    );
    await t.pump(const Duration(seconds: 16));
    await t.pumpAndSettle();
    expect(
      find.text('Henüz kampanyan yok. İlk duyurunu oluştur.'),
      findsNothing,
    );
    campaign.nextRead = null;
    await tap(t, 'Tekrar dene');
    pending.complete(
      const Right(CampaignPage(enabled: false, pricePublicationEnabled: false)),
    );
    await t.pumpAndSettle();
    expect(find.text('Kampanya oluştur'), findsOneWidget);
  });
  testWidgets(
    'campaign product page retry keeps query and selection, raw pages survive duplicates',
    (t) async {
      final merchant = PickerMerchant(),
          base = campaigns.services(host, campaign);
      final pages = <int>[], queries = <String>[];
      var fail = false;
      when(
        () => merchant.listings(
          access,
          page: any(named: 'page'),
          query: any(named: 'query'),
        ),
      ).thenAnswer((call) async {
        final page = call.namedArguments[#page] as int;
        pages.add(page);
        queries.add(call.namedArguments[#query] as String);
        if (fail) return const Left('Ürünler yüklenemedi');
        return Right(
          page == 0
              ? List.filled(merchantPageSize, host.repository.items.first)
              : [host.repository.items.last],
        );
      });
      final services = MerchantServices(
        merchants: merchant,
        credentials: base.credentials,
        notifications: base.notifications,
        qr: base.qr,
        preferences: base.preferences,
        sessionChanges: base.sessionChanges,
        currentUserId: base.currentUserId,
        trustCommerce: campaign,
      );
      await pumpW49(
        t,
        MerchantCampaignEditor(
          services: services,
          access: access,
          existing: campaign.rows.first,
        ),
      );
      await t.pumpAndSettle();
      await tap(t, 'Ürün seç (1)');
      expect(find.byType(CheckboxListTile), findsOneWidget);
      fail = true;
      await tap(t, 'Diğer ürünleri yükle');
      expect(pages, [0, 1]);
      expect(find.text('Uygun ürün bulunamadı.'), findsNothing);
      await t.enterText(
        find.widgetWithText(TextField, 'Ürün ara'),
        'başka sorgu',
      );
      fail = false;
      await tap(t, 'Tekrar dene');
      expect(pages, [0, 1, 1]);
      expect(queries, ['', '', '']);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
    },
  );
  testWidgets(
    'campaign product deadline and media deadline leave clear retryable errors',
    (t) async {
      final merchant = PickerMerchant(),
          media = PickerMedia(),
          base = campaigns.services(host, campaign);
      final pending = Completer<Either<String, List<ShopProductEntity>>>();
      when(
        () => merchant.listings(access, page: 0, query: ''),
      ).thenAnswer((_) => pending.future);
      final services = MerchantServices(
        merchants: merchant,
        credentials: base.credentials,
        notifications: base.notifications,
        qr: base.qr,
        preferences: base.preferences,
        sessionChanges: base.sessionChanges,
        currentUserId: base.currentUserId,
        trustCommerce: campaign,
        catalogMedia: media,
      );
      final old = campaign.rows.first;
      final all = Campaign(
        id: old.id,
        shopId: old.shopId,
        revisionId: old.revisionId,
        status: 'draft',
        draft: CampaignDraft(
          title: old.draft.title,
          description: '',
          type: CampaignType.announcement,
          scope: CampaignScope.all,
          startsAt: old.draft.startsAt,
          endsAt: old.draft.endsAt,
        ),
      );
      await pumpW49(
        t,
        MerchantCampaignEditor(
          services: services,
          access: access,
          existing: all,
        ),
      );
      await t.pumpAndSettle();
      await tap(t, 'Ürün fotoğraflarından seç', settle: false);
      await t.pump(const Duration(seconds: 16));
      await t.pumpAndSettle();
      expect(find.text(merchantReadTimeout), findsOneWidget);
      expect(find.text('Uygun ürün bulunamadı.'), findsNothing);
      when(
        () => merchant.listings(access, page: 0, query: ''),
      ).thenAnswer((_) async => Right(host.repository.items));
      await tap(t, 'Tekrar dene');
      pending.complete(const Right([]));
      await t.pumpAndSettle();
      final first = host.repository.items.first;
      when(
        () => media.media(access, first.id),
      ).thenAnswer((_) => Completer<Either<String, ListingMedia>>().future);
      await tap(t, first.product!.name);
      await tap(t, 'Seçimi kullan (1)', settle: false);
      await t.pump(const Duration(seconds: 16));
      await t.pumpAndSettle();
      expect(find.text(merchantReadTimeout), findsOneWidget);
      expect(
        t
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Ürün fotoğraflarından seç'),
            )
            .onPressed,
        isNotNull,
      );
      expect(campaign.requests, isEmpty);
    },
  );
  testWidgets('campaign preview coalesces callbacks until the sheet closes', (
    t,
  ) async {
    await pumpW49(t, editor());
    await t.pumpAndSettle();
    final callback = t
        .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Müşteri görünümünü önizle'),
        )
        .onPressed!;
    callback();
    callback();
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    Navigator.pop(t.element(find.byType(BottomSheet)));
    await t.pumpAndSettle();
    expect(
      t
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Müşteri görünümünü önizle'),
          )
          .onPressed,
      isNotNull,
    );
  });
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('management recovery renders at $width and 130 percent text', (
      t,
    ) async {
      campaign.nextMutation = Future.value(const Left(changed));
      await pumpW49(t, editor(), width: width, scale: 1.3);
      await t.pumpAndSettle();
      await tap(t, 'Taslak olarak kaydet');
      campaign.detail = Right(freshCampaign(campaign.rows.first));
      await tap(t, 'Güncel kaydı kontrol et');
      expect(t.takeException(), null);
      await capture(t, 'campaign_conflict_${width.toInt()}');
      await t.pumpWidget(const SizedBox());
      await pumpW49(t, center(), width: width, scale: 1.3);
      await t.pumpAndSettle();
      await tap(t, 'Düzenle');
      await tap(t, 'Önizlemeyi yenile');
      promo.writeError = PromotionFailure.changed;
      await tap(t, 'Taslağı kaydet');
      promo.detail = Right(freshPromotion());
      await tap(t, 'Güncel kaydı kontrol et');
      expect(t.takeException(), null);
      await capture(t, 'promotion_conflict_${width.toInt()}');
    });
  }
}
