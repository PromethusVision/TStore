import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchases_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_form.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import '../../unit/merchant/merchant_qr_recovery_test.dart' show RecoveryRepo;
import '../../unit/merchant/merchant_return_recovery_test.dart'
    show ReturnRepo, ReturnStore, intent;
import 'merchant_qr_slice_b_test.dart'
    show Evidence, host, tap, purchase, openReturn, boundary;

class HistoryRepo extends Evidence {
  Future<Either<String, List<PurchaseEvidence>>> Function(int)? listAction;
  Future<Either<String, PurchaseEvidence>> Function()? readAction;
  final offsets = <int>[];
  int detailReads = 0;
  @override
  Future<Either<String, List<PurchaseEvidence>>> list(
    String shopId, {
    int offset = 0,
  }) {
    offsets.add(offset);
    return listAction?.call(offset) ?? super.list(shopId, offset: offset);
  }

  @override
  Future<Either<String, PurchaseEvidence>> read(String id) {
    detailReads++;
    return readAction?.call() ?? super.read(id);
  }
}

Future<void> quickHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(theme: EsnaftaVarTheme.light, home: child),
  );
  await tester.pump();
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_COMMERCE_RECOVERY')) return;
  final render = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundary),
  );
  render.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final shot = await render.toImage(pixelRatio: 1);
    try {
      final bytes = await shot.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/evidence/merchant_commerce_recovery/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      shot.dispose();
    }
  });
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
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
  testWidgets('lost first claim offers recovery, never another code input', (
    tester,
  ) async {
    final repo = RecoveryRepo()
      ..claimAction = () async => const Left('Bağlantı yok.');
    await host(tester, MerchantQrView(repository: repo, shopId: 'shop'));
    await tester.enterText(find.byType(TextField), '123456');
    await tap(tester, 'Kodu kontrol et');
    expect(find.textContaining('Yeni kod almadan'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Yeni QR okut'), findsNothing);
    await tap(tester, 'Tekrar dene');
    expect(find.text('Kodu kontrol et'), findsOneWidget);
    expect(repo.claims, 1);
  });
  testWidgets('startup recovery failure is retryable and resume recovers it', (
    tester,
  ) async {
    final repo = RecoveryRepo()..recovery = () async => const Left('offline');
    await host(tester, MerchantQrView(repository: repo, shopId: 'shop'));
    expect(find.text('Kamerayla okut'), findsNothing);
    repo.recovery = () async => const Right(null);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Kodu kontrol et'), findsOneWidget);
  });
  testWidgets('purchase read timeout has retry and ignores late first result', (
    tester,
  ) async {
    final pending = Completer<Either<String, List<PurchaseEvidence>>>();
    final repo = HistoryRepo()..listAction = (_) => pending.future;
    await quickHost(
      tester,
      MerchantPurchasesView(repository: repo, shopId: 'shop', userId: 'owner'),
    );
    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    expect(find.text('Henüz doğrulanmış alışveriş yok.'), findsNothing);
    repo.listAction = (_) async => const Right([]);
    await tap(tester, 'Tekrar dene');
    expect(find.text('Henüz doğrulanmış alışveriş yok.'), findsOneWidget);
    pending.complete(Right([purchase()]));
    await tester.pumpAndSettle();
    expect(find.text('36,00 TL'), findsNothing);
  });
  testWidgets(
    'repository replacement drops late history and starts fresh scope',
    (tester) async {
      final pending = Completer<Either<String, List<PurchaseEvidence>>>();
      final old = HistoryRepo()..listAction = (_) => pending.future;
      final fresh = HistoryRepo()..listAction = (_) async => const Right([]);
      await quickHost(
        tester,
        MerchantPurchasesView(repository: old, shopId: 'shop', userId: 'owner'),
      );
      await quickHost(
        tester,
        MerchantPurchasesView(
          repository: fresh,
          shopId: 'shop',
          userId: 'owner',
        ),
      );
      await tester.pumpAndSettle();
      pending.complete(Right([purchase()]));
      await tester.pumpAndSettle();
      expect(find.text('36,00 TL'), findsNothing);
      expect(find.text('Henüz doğrulanmış alışveriş yok.'), findsOneWidget);
    },
  );
  testWidgets('pagination deduplicates rows but advances using server offset', (
    tester,
  ) async {
    final repo = HistoryRepo()
      ..listAction = (offset) async => offset == 0
          ? Right(List.filled(20, purchase()))
          : const Left('page unavailable');
    await host(
      tester,
      MerchantPurchasesView(repository: repo, shopId: 'shop', userId: 'owner'),
    );
    expect(find.text('36,00 TL'), findsOneWidget);
    await tap(tester, 'Daha fazla göster');
    expect(repo.offsets, [0, 20]);
    repo.listAction = (_) async => const Right([]);
    await tap(tester, 'Tekrar dene');
    expect(repo.offsets, [0, 20, 20]);
    expect(find.text('36,00 TL'), findsOneWidget);
  });
  testWidgets('double tap history row opens only one detail', (tester) async {
    final repo = HistoryRepo();
    await host(
      tester,
      MerchantPurchasesView(repository: repo, shopId: 'shop', userId: 'owner'),
    );
    final open = tester
        .widget<ListTile>(find.widgetWithText(ListTile, '36,00 TL'))
        .onTap!;
    open();
    open();
    await tester.pumpAndSettle();
    expect(repo.detailReads, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Doğrulanmış alışverişler'), findsOneWidget);
  });
  testWidgets('detail refresh failure clears stale return actions', (
    tester,
  ) async {
    final repo = HistoryRepo();
    await host(
      tester,
      MerchantPurchasesView(repository: repo, shopId: 'shop', userId: 'owner'),
    );
    await tap(tester, '36,00 TL');
    repo.readAction = () async => const Left('offline');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('İade kaydı oluştur'), findsNothing);
    expect(find.text('Bekleyen iade isteğini kontrol et'), findsNothing);
    expect(find.text('offline'), findsOneWidget);
  });
  testWidgets('return draft asks before abandoning edits', (tester) async {
    await host(
      tester,
      MerchantPurchasesView(
        repository: Evidence(),
        shopId: 'shop',
        userId: 'owner',
      ),
      scale: 1,
    );
    await openReturn(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'İade nedeni'),
      'Taslak',
    );
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Değişikliklerden vazgeçilsin mi?'), findsOneWidget);
    await tap(tester, 'Düzenlemeye dön');
    expect(find.text('Taslak'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tap(tester, 'Vazgeç ve çık');
    expect(find.text('Alışveriş kaydı'), findsOneWidget);
  });
  testWidgets('in-flight return blocks back and duplicate submission', (
    tester,
  ) async {
    final repo = Evidence();
    await host(
      tester,
      MerchantPurchasesView(repository: repo, shopId: 'shop', userId: 'owner'),
      scale: 1,
    );
    await openReturn(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Örnek ürün'), '1');
    await tester.enterText(
      find.widgetWithText(TextField, 'İade nedeni'),
      'İade',
    );
    repo.pending = Completer<Either<PurchaseReturnFailure, PurchaseEvidence>>();
    await tester.ensureVisible(find.text('İade kaydını onayla'));
    await tester.tap(find.text('İade kaydını onayla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pageBack();
    await tester.pump();
    expect(find.text('İade kaydı'), findsOneWidget);
    expect(repo.writes, 1);
    repo.pending!.complete(Right(purchase(returned: 1)));
    await tester.pumpAndSettle();
  });
  testWidgets('known success cleanup retry never re-submits a return', (
    tester,
  ) async {
    final repo = ReturnRepo();
    final store = ReturnStore()..failClear = true;
    await host(
      tester,
      MerchantReturnForm(
        repository: repo,
        purchase: purchase(),
        userId: 'owner',
        store: store,
      ),
      scale: 1,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Örnek ürün'), '1');
    await tester.enterText(
      find.widgetWithText(TextField, 'İade nedeni'),
      'İade',
    );
    await tap(tester, 'İade kaydını onayla');
    expect(find.text('İade kaydı sunucuda doğrulandı.'), findsOneWidget);
    expect(find.text('Aynı isteğin sonucunu kontrol et'), findsNothing);
    store.failClear = false;
    await tap(tester, 'Tekrar dene');
    expect(repo.sent.length, 1);
  });
  testWidgets('stored return remains recoverable on an exhausted purchase', (
    tester,
  ) async {
    final repo = ReturnRepo();
    final store = ReturnStore()..value = intent();
    await host(
      tester,
      MerchantReturnForm(
        repository: repo,
        purchase: purchase(returned: 3),
        userId: 'owner',
        store: store,
      ),
    );
    expect(find.text('Aynı isteğin sonucunu kontrol et'), findsOneWidget);
    await tap(tester, 'Aynı isteğin sonucunu kontrol et');
    expect(repo.sent.single.requestId, intent().requestId);
  });
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('QR recovery ${width.toInt()} at 130 percent renders', (
      tester,
    ) async {
      final repo = RecoveryRepo()
        ..recovery = () async => const Left('Bağlantı kurulamadı.');
      await host(
        tester,
        MerchantQrView(repository: repo, shopId: 'shop'),
        width: width,
      );
      expect(tester.takeException(), null);
      await capture(tester, 'qr-recovery-${width.toInt()}');
    });
    testWidgets('return recovery ${width.toInt()} at 130 percent renders', (
      tester,
    ) async {
      final store = ReturnStore()..value = intent();
      await host(
        tester,
        MerchantReturnForm(
          repository: ReturnRepo(),
          purchase: purchase(returned: 1),
          userId: 'owner',
          store: store,
        ),
        width: width,
      );
      expect(tester.takeException(), null);
      await tester.ensureVisible(find.text('Aynı isteğin sonucunu kontrol et'));
      expect(tester.takeException(), null);
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      position.jumpTo(0);
      await tester.pumpAndSettle();
      await capture(tester, 'return-recovery-${width.toInt()}');
    });
  }
}
