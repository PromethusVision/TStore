import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_purchases_view.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import '../../unit/cart/qr_claim_protocol_test.dart'
    show ClaimTestRepository, claimValue;

PurchaseEvidence purchase({
  int returned = 0,
  List<PurchaseReturnReference> returns = const [],
}) => PurchaseEvidence(
  id: 'purchase',
  shopId: 'shop',
  confirmedAt: DateTime(2026, 10, 15, 12),
  items: [
    PurchaseEvidenceItem(
      id: 'item',
      name: 'Örnek ürün',
      quantity: 3,
      returnedQuantity: returned,
    ),
  ],
  returns: returns,
  finalSaleMinor: 3600,
  classification: 'quote_only_b_v1',
  invalidated: false,
);

class Evidence extends Fake implements PurchaseEvidenceRepository {
  PurchaseEvidence value = purchase();
  String? failure;
  int writes = 0;
  final requests = <String>[];
  Completer<Either<PurchaseReturnFailure, PurchaseEvidence>>? pending;
  @override
  Future<Either<String, List<PurchaseEvidence>>> list(
    String shopId, {
    int offset = 0,
  }) async =>
      failure == null ? Right(offset == 0 ? [value] : []) : Left(failure!);
  @override
  Future<Either<String, PurchaseEvidence>> read(String id) async =>
      Right(value);
  @override
  Future<Either<PurchaseReturnFailure, PurchaseEvidence>> recordReturn({
    required String purchaseId,
    required String requestId,
    required Map<String, int> quantities,
    required String reason,
  }) async {
    writes++;
    requests.add(requestId);
    if (pending != null) return pending!.future;
    if (failure != null) return Left(PurchaseReturnFailure(failure!));
    value = purchase(
      returned: quantities['item']!,
      returns: [
        PurchaseReturnReference('return', DateTime(2026, 10, 15, 13), false),
      ],
    );
    return Right(value);
  }
}

const boundary = Key('slice-b-screen');
Future<void> host(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double scale = 1.3,
}) async {
  tester.view.physicalSize = Size(width, 932);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> openReturn(WidgetTester tester) async {
  await tap(tester, '36,00 TL');
  await tap(tester, 'İade kaydı oluştur');
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
  testWidgets(
    'manual code validates, claims, confirms and exposes server success',
    (tester) async {
      final r = ClaimTestRepository();
      await host(tester, MerchantQrView(repository: r, shopId: 'shop'));
      await tap(tester, 'Kodu kontrol et');
      expect(r.claims, 0);
      await tester.enterText(find.byType(TextField), '123456');
      await tap(tester, 'Kodu kontrol et');
      expect(find.text('İşlemi onayla'), findsOneWidget);
      expect(find.textContaining('Tamamlama son saati'), findsOneWidget);
      await tap(tester, 'İşlemi onayla');
      expect(find.text('Sunucu işlem onayını doğruladı.'), findsOneWidget);
      expect(r.completions, 1);
    },
  );
  testWidgets('unknown outcome keeps recovery action and prevents a new scan', (
    tester,
  ) async {
    final r = ClaimTestRepository()..recovered = claimValue();
    r.completeAction = () async => const Left('Bağlantı yok.');
    r.reconcileAction = () async => const Left('Bağlantı yok.');
    await host(tester, MerchantQrView(repository: r, shopId: 'shop'));
    await tap(tester, 'İşlemi onayla');
    expect(find.textContaining('henüz doğrulanamadı'), findsOneWidget);
    expect(find.text('Yeni QR okut'), findsNothing);
    expect(find.text('Kamerayla okut'), findsNothing);
    r.reconcileAction = () async => Right(claimValue(status: 'used'));
    await tap(tester, 'Tekrar dene');
    expect(find.text('Sunucu işlem onayını doğruladı.'), findsOneWidget);
  });
  testWidgets('purchase read error is retryable without invented empty list', (
    tester,
  ) async {
    final r = Evidence()..failure = 'Bağlantı yok.';
    await host(
      tester,
      MerchantPurchasesView(repository: r, shopId: 'shop', userId: 'owner'),
    );
    expect(find.text('Henüz doğrulanmış alışveriş yok.'), findsNothing);
    r.failure = null;
    await tap(tester, 'Tekrar dene');
    expect(find.textContaining('36'), findsOneWidget);
  });
  testWidgets(
    'return validates and duplicate taps send once; success shows evidence not cash refund',
    (tester) async {
      final r = Evidence();
      await host(
        tester,
        MerchantPurchasesView(repository: r, shopId: 'shop', userId: 'owner'),
        scale: 1,
      );
      await openReturn(tester);
      await tap(tester, 'İade kaydını onayla');
      expect(r.writes, 0);
      await tester.enterText(find.widgetWithText(TextField, 'Örnek ürün'), '2');
      await tester.enterText(
        find.widgetWithText(TextField, 'İade nedeni'),
        'Ürün iadesi',
      );
      final pending =
          Completer<Either<PurchaseReturnFailure, PurchaseEvidence>>();
      r.pending = pending;
      await tester.ensureVisible(find.text('İade kaydını onayla'));
      await tester.tap(find.text('İade kaydını onayla'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(r.writes, 1);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(
                FilledButton,
                'Aynı isteğin sonucunu kontrol et',
              ),
            )
            .onPressed,
        isNull,
      );
      r.value = purchase(
        returned: 2,
        returns: [
          PurchaseReturnReference('return', DateTime(2026, 10, 15, 13), false),
        ],
      );
      pending.complete(Right(r.value));
      await tester.pumpAndSettle();
      expect(find.text('İade kaydı sunucuda doğrulandı.'), findsOneWidget);
      await tap(tester, 'Alışveriş kaydına dön');
      expect(find.text('Para iadesi gerçekleştirilmedi.'), findsOneWidget);
    },
  );
  testWidgets(
    'lost return response persists same request across screen disposal and reopen',
    (tester) async {
      final r = Evidence();
      await host(
        tester,
        MerchantPurchasesView(repository: r, shopId: 'shop', userId: 'owner'),
        scale: 1,
      );
      await openReturn(tester);
      r.failure = 'Bağlantı yok.';
      await tester.enterText(find.widgetWithText(TextField, 'Örnek ürün'), '1');
      await tester.enterText(
        find.widgetWithText(TextField, 'İade nedeni'),
        'İade',
      );
      await tap(tester, 'İade kaydını onayla');
      expect(r.writes, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      r.failure = null;
      await tap(tester, 'İade kaydı oluştur');
      expect(find.text('Aynı isteğin sonucunu kontrol et'), findsOneWidget);
      await tap(tester, 'Aynı isteğin sonucunu kontrol et');
      expect(r.requests[0], r.requests[1]);
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('claimed QR ${width.toInt()} / 130% visual state', (
      tester,
    ) async {
      final r = ClaimTestRepository()..recovered = claimValue();
      await host(
        tester,
        MerchantQrView(repository: r, shopId: 'shop'),
        width: width,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('goldens/slice_b_claim_${width.toInt()}_130.png'),
      );
    });
    testWidgets('purchase detail ${width.toInt()} / 130% visual state', (
      tester,
    ) async {
      final r = Evidence();
      await host(
        tester,
        MerchantPurchasesView(repository: r, shopId: 'shop', userId: 'owner'),
        width: width,
      );
      await tap(tester, '36,00 TL');
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('goldens/slice_b_purchase_${width.toInt()}_130.png'),
      );
    });
  }
}
