import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/merchant_promotions/domain/merchant_promotion.dart';
import 'package:t_store/features/merchant_promotions/presentation/merchant_promotion_center.dart';
import 'package:t_store/features/merchant_promotions/presentation/merchant_promotion_entry.dart';
import 'merchant_promotion_test.dart' as fixture;

class EventPromotions extends fixture.PromotionFake
    implements AuthenticatedSessionEvents {
  String? key = 'S1';
  final keys = StreamController<String?>.broadcast();
  @override
  String? get currentSessionKey => key;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
}

void main() {
  late EventPromotions repo;
  setUp(() => repo = EventPromotions());
  tearDown(() async {
    await repo.sessions.close();
    await repo.keys.close();
  });
  Future<void> host(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });
    await t.pumpWidget(
      MaterialApp(
        home: MerchantPromotionCenter(
          repository: repo,
          shopId: fixture.shop,
          ownerId: 'owner',
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String label) async {
    final f = find.text(label).last;
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  for (final surface in ['list', 'editor', 'history', 'sources']) {
    testWidgets('$surface retires queued replacement before live key returns', (
      t,
    ) async {
      await host(t);
      if (surface == 'history') await tap(t, 'Geçmiş');
      if (surface == 'editor' || surface == 'sources') {
        await tap(t, 'Yeni tanıtım taslağı');
        if (surface == 'sources') {
          await tap(t, 'Fotoğraf için ürün seç (isteğe bağlı)');
        }
      }
      repo.keys.add('S2');
      repo.keys.add('S1');
      await t.pumpAndSettle();
      expect(find.textContaining('Oturum değişti'), findsOneWidget);
      expect(find.text('Taslağı kaydet'), findsNothing);
      expect(find.text(fixture.copy.title), findsNothing);
    });
  }
  testWidgets('discard overlay loses old controls after logout', (t) async {
    await host(t);
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    await t.tap(find.byTooltip('Geri'));
    await t.pumpAndSettle();
    expect(find.text('Vazgeç ve devam et'), findsOneWidget);
    repo.user = null;
    repo.sessions.add(null);
    await t.pumpAndSettle();
    expect(find.text('Vazgeç ve devam et'), findsNothing);
    expect(find.text('Değişikliklerden vazgeçilsin mi?'), findsNothing);
  });
  testWidgets('normal renewal preserves editor and outstanding save', (
    t,
  ) async {
    await host(t);
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    final wait = Completer<Either<PromotionFailure, PromotionReceipt>>();
    repo.writeWait = wait;
    await t.tap(find.text('Taslağı kaydet'));
    await t.pump();
    repo.keys.add('S1');
    repo.sessions.add('owner');
    await t.pump();
    expect(repo.writes.length, 1);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Taslağı kaydet'),
          )
          .onPressed,
      isNull,
    );
    wait.complete(
      const Right(PromotionReceipt(fixture.draftId, fixture.rev, 'save')),
    );
    await t.pumpAndSettle();
    expect(find.text('Yeni tanıtım taslağı'), findsOneWidget);
  });

  for (final event in ['error', 'done', 'logout-return']) {
    testWidgets('$event clears private list and disables old actions', (
      t,
    ) async {
      await host(t);
      if (event == 'error') repo.keys.addError(StateError('lost observation'));
      if (event == 'done') await t.runAsync(repo.keys.close);
      if (event == 'logout-return') {
        repo.sessions.add(null);
        repo.sessions.add('owner');
      }
      await t.pumpAndSettle();
      expect(find.textContaining('Oturum değişti'), findsOneWidget);
      expect(find.text(fixture.copy.title), findsNothing);
      expect(find.text('Yeni tanıtım taslağı'), findsNothing);
    });
  }
  for (final failed in [false, true]) {
    testWidgets('late preview after replacement is hidden, failure=$failed', (
      t,
    ) async {
      await host(t);
      await tap(t, 'Yeni tanıtım taslağı');
      final wait = Completer<Either<PromotionFailure, PromotionPreview>>();
      repo.previewWait = wait;
      await t.tap(find.text('Önizlemeyi yenile'));
      await t.pump();
      repo.keys.add('S2');
      repo.keys.add('S1');
      await t.pump();
      wait.complete(
        failed
            ? const Left(PromotionFailure.unavailable)
            : const Right(
                PromotionPreview(
                  enabled: true,
                  ready: true,
                  copy: fixture.copy,
                  fingerprint: 'fixture',
                ),
              ),
      );
      await t.pumpAndSettle();
      expect(find.textContaining('Oturum değişti'), findsOneWidget);
      expect(find.text('Güncel önizleme'), findsNothing);
      expect(find.text(PromotionFailure.unavailable.message), findsNothing);
    });
  }
  testWidgets('discard first mount cannot acquire a replacement session', (
    t,
  ) async {
    await host(t);
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    await t.tap(find.byTooltip('Geri'));
    repo.keys.add('S2');
    repo.keys.add('S1');
    await t.pumpAndSettle();
    expect(find.text('Vazgeç ve devam et'), findsNothing);
    expect(find.text('Kapat'), findsOneWidget);
  });
  testWidgets('resume during discard preserves a usable cancel path', (
    t,
  ) async {
    await host(t);
    await tap(t, 'Yeni tanıtım taslağı');
    await tap(t, 'Önizlemeyi yenile');
    await t.tap(find.byTooltip('Geri'));
    await t.pumpAndSettle();
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    await t.tap(find.text('Düzenlemeye dön'));
    await t.pumpAndSettle();
    expect(
      t
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Önizlemeyi yenile'),
          )
          .onPressed,
      isNotNull,
    );
  });
  testWidgets('entry coalesces rapid taps and retains exact opener', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MerchantPromotionEntry(
            repository: repo,
            ownerId: 'owner',
            shopId: fixture.shop,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final open = t.widget<ListTile>(find.byType(ListTile)).onTap!;
    open();
    open();
    repo.keys.add('S2');
    repo.keys.add('S1');
    await t.pumpAndSettle();
    expect(
      find.byType(MerchantPromotionCenter, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.textContaining('Oturum değişti'), findsOneWidget);
    expect(repo.offsets, isEmpty);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('repository replacement cannot apply a previous late list', (
    t,
  ) async {
    await host(t);
    final wait = Completer<Either<PromotionFailure, PromotionPage>>();
    repo.readWait = wait;
    await t.tap(find.text('Listeyi yenile'));
    await t.pump();
    final next = EventPromotions()
      ..value = const PromotionPage(enabled: false, items: [], hasMore: false);
    addTearDown(() async {
      await next.sessions.close();
      await next.keys.close();
    });
    await t.pumpWidget(
      MaterialApp(
        home: MerchantPromotionCenter(
          repository: next,
          shopId: fixture.shop,
          ownerId: 'owner',
        ),
      ),
    );
    await t.pumpAndSettle();
    wait.complete(Right(repo.value));
    await t.pumpAndSettle();
    expect(find.text(fixture.copy.title), findsNothing);
    expect(
      find.text('Tanıtım hazırlama bu ortamda henüz açılmadı.'),
      findsOneWidget,
    );
  });
}
