import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import 'package:t_store/features/merchant_promotions/presentation/merchant_promotion_center.dart';

const shop = '00000000-0000-4000-8000-000000000001',
    draftId = '00000000-0000-4000-8000-000000000002';
const rev = '00000000-0000-4000-8000-000000000003',
    listing = '00000000-0000-4000-8000-000000000004';
const copy = PromotionCopy(
  'Mahalle Kırtasiyesi',
  'Mağazamızı ve ürünlerimizi EsnaftaVar’da inceleyin.',
);
PromotionDraft draft({String status = 'draft'}) => PromotionDraft(
  id: draftId,
  revisionId: rev,
  shopId: shop,
  status: status,
  selection: const PromotionSelection(),
  copy: copy,
  recordedAt: DateTime.utc(2026, 10, 15),
);

class PromotionFake implements MerchantPromotionRepository {
  String? user = 'owner';
  final sessions = StreamController<String?>.broadcast(sync: true);
  PromotionPage value = PromotionPage(
    enabled: true,
    items: [draft()],
    hasMore: false,
  );
  PromotionFailure? readError, writeError;
  Completer<Either<PromotionFailure, PromotionPage>>? readWait;
  Completer<Either<PromotionFailure, PromotionPreview>>? previewWait;
  Completer<Either<PromotionFailure, PromotionReceipt>>? writeWait;
  final writes = <PromotionCommand>[],
      offsets = <int>[],
      selections = <PromotionSelection>[];
  @override
  String? get currentUserId => user;
  @override
  Stream<String?> get sessionChanges => sessions.stream;
  @override
  Future<Either<PromotionFailure, PromotionPage>> read(
    String shopId, {
    int offset = 0,
  }) async {
    offsets.add(offset);
    return readWait?.future ??
        (readError != null ? Left(readError!) : Right(value));
  }

  @override
  Future<Either<PromotionFailure, PromotionPreview>> preview(
    String shopId,
    PromotionSelection selection,
  ) async {
    selections.add(selection);
    return previewWait?.future ??
        const Right(
          PromotionPreview(
            enabled: true,
            ready: true,
            copy: copy,
            fingerprint: 'fingerprint',
          ),
        );
  }

  @override
  Future<Either<PromotionFailure, PromotionReceipt>> mutate(
    PromotionCommand command,
  ) async {
    writes.add(command);
    return writeWait?.future ??
        (writeError != null
            ? Left(writeError!)
            : Right(PromotionReceipt(draftId, rev, command.action)));
  }

  @override
  Future<Either<PromotionFailure, List<PromotionSource>>> sources(
    String shopId,
    String kind, {
    String query = '',
    int offset = 0,
  }) async => const Right([PromotionSource(listing, 'Güncel kalem')]);
  @override
  Future<Either<PromotionFailure, List<PromotionHistoryEntry>>> history(
    String shopId,
    String draftId, {
    int offset = 0,
  }) async => Right([
    PromotionHistoryEntry(rev, 'save', copy, DateTime.utc(2026, 10, 15, 12)),
  ]);
}

void main() {
  testWidgets(
    'server feature stop while loading another page removes old drafts',
    (t) async {
      final fake = PromotionFake();
      addTearDown(fake.sessions.close);
      fake.value = PromotionPage(
        enabled: true,
        items: [draft()],
        hasMore: true,
      );
      await t.pumpWidget(
        MaterialApp(
          home: MerchantPromotionCenter(
            repository: fake,
            shopId: shop,
            ownerId: 'owner',
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text(copy.title), findsOneWidget);
      fake.value = const PromotionPage(
        enabled: false,
        items: [],
        hasMore: false,
      );
      await t.scrollUntilVisible(find.text('Daha fazla taslak'), 250);
      await t.tap(find.text('Daha fazla taslak'));
      await t.pumpAndSettle();
      expect(find.text(copy.title), findsNothing);
      expect(find.text('Yeni tanıtım taslağı'), findsNothing);
    },
  );
  testWidgets('server role denial on later page clears private copies', (
    t,
  ) async {
    final fake = PromotionFake();
    addTearDown(fake.sessions.close);
    fake.value = PromotionPage(enabled: true, items: [draft()], hasMore: true);
    await t.pumpWidget(
      MaterialApp(
        home: MerchantPromotionCenter(
          repository: fake,
          shopId: shop,
          ownerId: 'owner',
        ),
      ),
    );
    await t.pumpAndSettle();
    fake.readError = PromotionFailure.session;
    await t.scrollUntilVisible(find.text('Daha fazla taslak'), 250);
    await t.tap(find.text('Daha fazla taslak'));
    await t.pumpAndSettle();
    expect(find.text(copy.title), findsNothing);
    expect(find.textContaining('Oturum değişti'), findsOneWidget);
  });
  setUpAll(() async {
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final root = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${root.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  late PromotionFake repo;
  const boundary = Key('promotion-screen');
  setUp(() => repo = PromotionFake());
  tearDown(() async {
    await repo.sessions.close();
  });
  Future<void> host(WidgetTester t, {double width = 390}) async {
    t.view.physicalSize = Size(width, 1000);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
      t.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await t.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          theme: EsnaftaVarTheme.light,
          debugShowCheckedModeBanner: false,
          home: MerchantPromotionCenter(
            repository: repo,
            shopId: shop,
            ownerId: 'owner',
          ),
        ),
      ),
    );
    await t.pump();
  }

  Future<void> tap(WidgetTester t, String text) async {
    final finder = find.text(text).last;
    await t.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await t.ensureVisible(finder);
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('PROMOTION_CAPTURE')) return;
    await t.pumpAndSettle();
    final render = t.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
    await t.runAsync(() async {
      final picture = await render.toImage(),
          bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final dir = Directory('docs/evidence/promotion_g');
      await dir.create(recursive: true);
      await File(
        '${dir.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('center and editor fit $width at text scale 1.3', (t) async {
      await host(t, width: width);
      await t.pumpAndSettle();
      await capture(t, 'center-${width.toInt()}');
      await tap(t, 'Yeni tanıtım taslağı');
      await tap(t, 'Önizlemeyi yenile');
      await capture(t, 'preview-${width.toInt()}');
      expect(t.takeException(), null);
      expect(find.text('Güncel önizleme'), findsOneWidget);
      await tap(t, 'Taslağı kaydet');
      expect(repo.writes.length, 1);
      expect(repo.writes.single.action, 'save');
    });
  }
  testWidgets(
    'off, empty and error states never fabricate publication or metrics',
    (t) async {
      repo.value = const PromotionPage(
        enabled: false,
        items: [],
        hasMore: false,
      );
      await host(t);
      await t.pumpAndSettle();
      expect(find.text('Yeni tanıtım taslağı'), findsNothing);
      await capture(t, 'disabled');
      repo.value = const PromotionPage(
        enabled: true,
        items: [],
        hasMore: false,
      );
      await tap(t, 'Listeyi yenile');
      expect(find.text('Henüz tanıtım taslağın yok.'), findsOneWidget);
      await capture(t, 'empty');
      repo.readError = PromotionFailure.unavailable;
      await tap(t, 'Listeyi yenile');
      expect(find.text(PromotionFailure.unavailable.message), findsOneWidget);
      expect(find.text('Yayında'), findsNothing);
    },
  );
  testWidgets('loading is visible and late logout result discarded', (t) async {
    repo.readWait = Completer();
    await host(t);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    repo.user = null;
    repo.sessions.add(null);
    await t.pump();
    repo.readWait!.complete(Right(repo.value));
    await t.pumpAndSettle();
    expect(find.textContaining('Oturum değişti'), findsOneWidget);
    expect(find.text(copy.title), findsNothing);
  });
  testWidgets('uncertain write freezes editing and retries identical command', (
    t,
  ) async {
    await host(t);
    await t.pumpAndSettle();
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    repo.writeError = PromotionFailure.uncertain;
    await tap(t, 'Taslağı kaydet');
    expect(find.text(PromotionFailure.uncertain.message), findsOneWidget);
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Taslağı kaydet'),
    );
    expect(button.onPressed, null);
    await capture(t, 'uncertain');
    repo.writeError = null;
    await tap(t, 'Aynı işlemi kontrol et');
    expect(repo.writes.length, 2);
    expect(identical(repo.writes[0], repo.writes[1]), true);
  });
  testWidgets('double tap in-flight save makes one request', (t) async {
    await host(t);
    await t.pumpAndSettle();
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    repo.writeWait = Completer();
    final target = find.text('Taslağı kaydet');
    await t.ensureVisible(target);
    await t.tap(target);
    await t.pump();
    await t.tap(target);
    await t.pump();
    expect(repo.writes.length, 1);
    repo.writeWait!.complete(
      const Right(PromotionReceipt(draftId, rev, 'save')),
    );
    await t.pumpAndSettle();
  });
  testWidgets('changed source requires new preview before saving', (t) async {
    await host(t);
    await t.pumpAndSettle();
    await tap(t, 'Düzenle');
    await tap(t, 'Önizlemeyi yenile');
    repo.writeError = PromotionFailure.changed;
    await tap(t, 'Taslağı kaydet');
    expect(find.text(PromotionFailure.changed.message), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Taslağı kaydet'),
          )
          .onPressed,
      null,
    );
    expect(find.text('Güncel önizleme'), findsNothing);
  });
  testWidgets('archive and restore each require explicit action', (t) async {
    await host(t);
    await t.pumpAndSettle();
    await tap(t, 'Düzenle');
    await tap(t, 'Arşivle');
    expect(repo.writes.single.action, 'archive');
    expect(repo.writes.single.selection, null);
    repo.value = PromotionPage(
      enabled: true,
      items: [draft(status: 'archived')],
      hasMore: false,
    );
    await tap(t, 'Listeyi yenile');
    await tap(t, 'Taslak olarak geri al');
    expect(find.text('Arşivle'), findsNothing);
    await tap(t, 'Önizlemeyi yenile');
    await tap(t, 'Taslağı kaydet');
    expect(repo.writes.last.action, 'save');
  });
  testWidgets('stale draft and historical copy are clearly labeled', (t) async {
    repo.value = PromotionPage(
      enabled: true,
      items: [draft(status: 'needs_update')],
      hasMore: false,
    );
    await host(t);
    await t.pumpAndSettle();
    expect(find.text('Güncellenmeli'), findsOneWidget);
    await capture(t, 'stale');
    await tap(t, 'Geçmiş');
    expect(find.textContaining('yayın kanıtı değildir'), findsOneWidget);
    await capture(t, 'history');
  });
  testWidgets('product selector does not allow saving without fresh preview', (
    t,
  ) async {
    await host(t);
    await t.pumpAndSettle();
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Fotoğraf için ürün seç (isteğe bağlı)');
    expect(find.text('Uygun ürünler'), findsOneWidget);
    await tap(t, 'Güncel kalem');
    expect(find.text('Ürün: Güncel kalem'), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Taslağı kaydet'),
          )
          .onPressed,
      null,
    );
    await tap(t, 'Önizlemeyi yenile');
    expect(repo.selections.last.listingId, listing);
  });
  testWidgets(
    'same-owner refresh during write keeps the exact pending request',
    (t) async {
      await host(t);
      await t.pumpAndSettle();
      await tap(t, 'Yeni tanıtım taslağı');
      await tap(t, 'Önizlemeyi yenile');
      repo.writeWait = Completer();
      final target = find.text('Taslağı kaydet');
      await t.ensureVisible(target);
      await t.tap(target);
      await t.pump();
      repo.sessions.add('owner');
      await t.pump();
      repo.writeWait!.complete(
        const Right(PromotionReceipt(draftId, rev, 'save')),
      );
      await t.pumpAndSettle();
      expect(find.text('Aynı işlemi kontrol et'), findsNothing);
      expect(repo.writes.length, 1);
      expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
    },
  );
  testWidgets(
    'resume invalidates preview and session stream error removes private state',
    (t) async {
      await host(t);
      await t.pumpAndSettle();
      await tap(t, 'Düzenle');
      await tap(t, 'Önizlemeyi yenile');
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pumpAndSettle();
      expect(find.text('Güncel önizleme'), findsNothing);
      repo.sessions.addError(StateError('lost'));
      await t.pumpAndSettle();
      expect(find.text(copy.title), findsNothing);
      expect(find.textContaining('Oturum değişti'), findsOneWidget);
    },
  );
}
