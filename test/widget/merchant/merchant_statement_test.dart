import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/merchant/presentation/merchant_statement.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import '../../support/statement_fixtures.dart';

void main() {
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
  late StatementFake repo;
  late StreamController<String?> sessions;
  String? user;
  const boundary = Key('statement-screen');
  setUp(() {
    repo = StatementFake();
    sessions = StreamController<String?>.broadcast(sync: true);
    user = statementUser;
  });
  tearDown(() async {
    await sessions.close();
  });
  Widget screen() => MerchantStatementView(
    repository: repo,
    shopId: statementShop,
    ownerId: statementUser,
    currentUserId: () => user,
    sessionChanges: sessions.stream,
  );
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
          home: screen(),
        ),
      ),
    );
    await t.pump();
  }

  Future<void> capture(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('STATEMENT_CAPTURE')) return;
    await t.pumpAndSettle();
    final render = t.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
    await t.runAsync(() async {
      final picture = await render.toImage();
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final dir = Directory('docs/evidence/statement_h1');
      await dir.create(recursive: true);
      await File(
        '${dir.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  Future<void> bottom(WidgetTester t, Finder target) async {
    await t.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.pumpAndSettle();
  }

  testWidgets(
    'dashboard gate, statement navigation and logout retain the Merchant workspace boundary',
    (t) async {
      final preview = MerchantPreview();
      final original = preview.services;
      addTearDown(() async {
        await t.pumpWidget(const SizedBox());
        await preview.dispose();
      });
      await t.pumpWidget(MerchantApp(services: original));
      await t.pumpAndSettle();
      expect(find.text('Hesap Bakiyesi'), findsNothing);
      final services = MerchantServices(
        merchants: original.merchants,
        credentials: original.credentials,
        notifications: original.notifications,
        qr: original.qr,
        preferences: original.preferences,
        sessionChanges: original.sessionChanges,
        currentUserId: original.currentUserId,
        preview: true,
        statement: repo,
      );
      await t.pumpWidget(MerchantApp(services: services));
      await t.pumpAndSettle();
      await t.tap(find.text('Hesap Bakiyesi'));
      await t.pumpAndSettle();
      expect(find.byType(MerchantStatementView), findsOneWidget);
      expect(repo.requests.single.shop, statementShop);
      await t.pageBack();
      await t.pumpAndSettle();
      expect(find.text('Mağaza özeti'), findsOneWidget);
      await t.tap(find.text('Hesap Bakiyesi'));
      await t.pumpAndSettle();
      preview.currentId = null;
      preview.changes.add(null);
      await t.pumpAndSettle();
      expect(find.byType(MerchantStatementView), findsNothing);
      expect(find.text('Giriş yap'), findsOneWidget);
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'source-specific balances render at $width and 130% scale without overflow',
      (t) async {
        await host(t, width: width);
        await t.pumpAndSettle();
        expect(find.text('750,00 TL'), findsOneWidget);
        expect(find.text('Zorunlu mahsup rezervi'), findsOneWidget);
        expect(find.text('1.000,00 TL'), findsOneWidget);
        expect(find.text('Para çek'), findsNothing);
        expect(t.takeException(), isNull);
        await capture(t, 'summary-${width.toInt()}');
        await bottom(t, find.text('Ödeme durumu'));
        expect(
          find.textContaining('Para çekme henüz açık değil'),
          findsOneWidget,
        );
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'empty and disabled states are distinct with no invented financial figures',
    (t) async {
      repo.value = statementValue(enabled: false);
      await host(t);
      await t.pumpAndSettle();
      expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      expect(find.text('0,00 TL'), findsNothing);
      await capture(t, 'disabled');
      repo.value = statementValue(entries: [], revision: '0');
      await t.tap(find.byTooltip('Hesabı yenile'));
      await t.pumpAndSettle();
      await bottom(t, find.text('Henüz hesap hareketin yok.'));
      expect(find.text('Henüz hesap hareketin yok.'), findsOneWidget);
    },
  );
  testWidgets(
    'slow and failed initial read show neither stale totals nor false empty history',
    (t) async {
      repo.wait = Completer();
      await host(t);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('0,00 TL'), findsNothing);
      await t.tap(find.byTooltip('Hesabı yenile'));
      expect(repo.requests.length, 1);
      repo.wait!.complete(const Left(CommerceLedgerFailure.unavailable));
      await t.pumpAndSettle();
      expect(
        find.textContaining('Hesap bilgileri yüklenemedi'),
        findsOneWidget,
      );
      expect(find.text('Henüz hesap hareketin yok.'), findsNothing);
      await capture(t, 'connection-error');
      repo.wait = null;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(find.text('750,00 TL'), findsOneWidget);
    },
  );
  testWidgets(
    'pagination keeps revision, suppresses double tap and preserves zero-net release',
    (t) async {
      repo.value = statementValue(next: statementId, revision: '2');
      await host(t);
      await t.pumpAndSettle();
      await bottom(t, find.text('Önceki hareketleri yükle'));
      repo.wait = Completer();
      await t.tap(find.text('Önceki hareketleri yükle'));
      await t.tap(find.text('Önceki hareketleri yükle'));
      await t.pump();
      expect(repo.requests.length, 2);
      expect(repo.requests.last.before, statementId);
      expect(repo.requests.last.revision, '2');
      final row = statementEntry(
        id: statementOlderId,
        stamp: '2026-10-14T10:00:00Z',
        kind: 'receivable_release',
        amount: '0',
      );
      row['movements'] = [
        {'code': 'merchant_coupon_pending', 'amount_minor': '-50000'},
        {'code': 'merchant_coupon_available', 'amount_minor': '50000'},
      ];
      repo.wait!.complete(Right(statementValue(entries: [row], revision: '2')));
      await t.pumpAndSettle();
      await bottom(t, find.text('Dağılım değişikliği'));
      expect(find.text('Dağılım değişikliği'), findsOneWidget);
      expect(find.text('Önceki hareketleri yükle'), findsNothing);
      await capture(t, 'history-release');
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'new commit during pagination discards old totals and refreshes from first page',
    (t) async {
      repo.value = statementValue(next: statementId, revision: '2');
      await host(t);
      await t.pumpAndSettle();
      await bottom(t, find.text('Önceki hareketleri yükle'));
      repo.error = CommerceLedgerFailure.statementChanged;
      await t.tap(find.text('Önceki hareketleri yükle'));
      await t.pumpAndSettle();
      expect(find.textContaining('yeni hareketler'), findsOneWidget);
      expect(find.byKey(const ValueKey(statementId)), findsNothing);
      expect(find.text('Bekleyen alacak'), findsNothing);
      await capture(t, 'changed-history');
      repo.error = null;
      repo.value = statementValue();
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(repo.requests.last.before, isNull);
      expect(repo.requests.last.revision, isNull);
    },
  );
  testWidgets(
    'transient page error retries same cursor; feature stop removes all old rows',
    (t) async {
      repo.value = statementValue(next: statementId, revision: '2');
      await host(t);
      await t.pumpAndSettle();
      await bottom(t, find.text('Önceki hareketleri yükle'));
      repo.error = CommerceLedgerFailure.unavailable;
      await t.tap(find.text('Önceki hareketleri yükle'));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey(statementId)), findsOneWidget);
      repo.error = null;
      repo.value = statementValue(enabled: false);
      await t.scrollUntilVisible(find.text('Tekrar dene'), -500);
      await t.pumpAndSettle();
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(repo.requests.last.before, statementId);
      expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
      expect(find.byKey(const ValueKey(statementId)), findsNothing);
    },
  );
  testWidgets('logout and away-back clear data and discard late response', (
    t,
  ) async {
    repo.wait = Completer();
    final old = repo.wait!;
    await host(t);
    user = null;
    sessions.add(null);
    await t.pump();
    expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
    repo.wait = Completer();
    user = statementUser;
    sessions.add(user);
    await t.pump();
    old.complete(Right(statementValue()));
    await t.pump();
    expect(find.text('Bekleyen alacak'), findsNothing);
    expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
    expect(repo.requests.length, 1);
    // A new route may bind the new session; the expired route never revives.
    await t.pumpWidget(const SizedBox());
    repo.wait = null;
    repo.value = statementValue(enabled: false);
    await host(t);
    await t.pumpAndSettle();
    expect(find.textContaining('kullanıma açık değil'), findsOneWidget);
    expect(repo.requests.length, 2);
  });
  testWidgets('session stream failure clears loaded money', (t) async {
    await host(t);
    await t.pumpAndSettle();
    sessions.addError(StateError('disconnected'));
    await t.pumpAndSettle();
    expect(find.text('750,00 TL'), findsNothing);
    expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
  });
  testWidgets('resume clears stale totals and validates live ownership again', (
    t,
  ) async {
    await host(t);
    await t.pumpAndSettle();
    repo.error = CommerceLedgerFailure.sessionChanged;
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    expect(repo.requests.length, 2);
    expect(find.text('750,00 TL'), findsNothing);
    expect(find.textContaining('Hesap erişimi doğrulanamadı'), findsOneWidget);
  });
  testWidgets(
    'reversal references and large exact amounts fit narrow screens',
    (t) async {
      repo.value = statementValue(
        entries: [
          statementEntry(
            kind: 'admin_reversal',
            amount: '-9007199254740993',
            reverses: statementOlderId,
          ),
        ],
      );
      await host(t, width: 320);
      await t.pumpAndSettle();
      await bottom(t, find.text('İşlem referansı'));
      await t.tap(find.text('İşlem referansı'));
      await t.pumpAndSettle();
      await bottom(t, find.textContaining('Düzeltilen kayıt'));
      expect(find.text('Ters kayıt'), findsOneWidget);
      expect(find.text('−90.071.992.547.409,93 TL'), findsOneWidget);
      await capture(t, 'history-reversal-320');
      expect(t.takeException(), isNull);
    },
  );
}
