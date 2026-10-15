import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_session_status_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import 'package:t_store/features/rewards/presentation/coupon_checkout_approval.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import '../../support/reward_fixtures.dart';
import '../../support/coupon_checkout_fixtures.dart';
import '../../unit/cart/qr_claim_protocol_test.dart'
    show ClaimTestRepository, claimJson;

class CheckoutFake extends Fake implements CouponCheckoutRepository {
  final changes = StreamController<void>.broadcast(sync: true);
  CouponCheckoutPreview value = CouponCheckoutPreview.fromJson(
    checkoutPreview(),
  );
  Completer<Either<String, CouponCheckoutPreview>>? pendingPreview;
  Completer<Either<String, QrSessionEntity>>? pendingApproval;
  String? error;
  final requests = <String>[], amounts = <String>[];
  @override
  Stream<void> get sessionChanges => changes.stream;
  @override
  Future<Either<String, CouponCheckoutPreview>> preview(String cartId) async =>
      pendingPreview?.future ?? (error == null ? Right(value) : Left(error!));
  @override
  Future<Either<String, QrSessionEntity>> approve(
    CouponCheckoutPreview preview,
    String request,
    LedgerMinorUnits coupon,
  ) async {
    requests.add(request);
    amounts.add(coupon.value.toString());
    return pendingApproval?.future ?? const Left('Sonuç doğrulanamadı');
  }
}

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    final root = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${root.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  const boundary = Key('checkout-screen');
  late CheckoutFake repo;
  setUp(() => repo = CheckoutFake());
  tearDown(() async {
    await repo.changes.close();
  });
  Future<void> host(
    WidgetTester t,
    Widget child, {
    double width = 390,
    bool scroll = true,
  }) async {
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
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          home: Scaffold(
            body: scroll
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
    await t.pump();
  }

  Widget approval({
    VoidCallback? skip,
    ValueChanged<QrSessionEntity>? approved,
  }) => CouponCheckoutApproval(
    cartId: rewardId,
    repository: repo,
    onApproved: approved ?? (_) {},
    onWithoutCoupon: skip ?? () {},
  );
  Future<void> screenshot(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('CHECKOUT_CAPTURE')) return;
    await t.pumpAndSettle();
    final render = t.renderObject<RenderRepaintBoundary>(find.byKey(boundary));
    await t.runAsync(() async {
      final picture = await render.toImage();
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final dir = Directory('docs/evidence/checkout_e');
      await dir.create(recursive: true);
      await File(
        '${dir.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  testWidgets(
    'actual Customer QR sheet recovers prior approval after restart without a new spend authorization',
    (t) async {
      await sl.reset();
      addTearDown(sl.reset);
      repo.value = repo.value.withExistingSession(
        QrSessionModel.fromJson({
          ...checkoutQr(),
          'expires_at': DateTime.now()
              .add(const Duration(minutes: 2))
              .toUtc()
              .toIso8601String(),
        }),
      );
      sl.registerSingleton<CouponCheckoutRepository>(repo);
      final qrRepo = ClaimTestRepository();
      final cubit = QrSessionCubit(
        createQrSessionUsecase: CreateQrSessionUsecase(qrRepo),
        getQrSessionStatusUsecase: GetQrSessionStatusUsecase(qrRepo),
        statusCheckInterval: const Duration(hours: 1),
      );
      await host(
        t,
        BlocProvider<QrSessionCubit>(
          create: (_) => cubit,
          child: CartQrSessionBottomSheet(
            cartId: rewardId,
            shopName: 'Örnek Esnaf',
            itemCount: 1,
            totalAmount: 500,
            onViewPurchases: (_) {},
          ),
        ),
        scroll: false,
      );
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('purchase-verification-qr-code')),
        findsOneWidget,
      );
      expect(find.text('Onaylanan EV kuponu'), findsOneWidget);
      expect(repo.requests, isEmpty);
      await screenshot(t, 'customer-existing-qr');
      await t.pumpWidget(const SizedBox());
      await t.pump();
    },
  );

  testWidgets(
    'customer sees exact sale coupon payment and narrow scaled layout validates amount',
    (t) async {
      await host(t, approval(), width: 320);
      await t.pumpAndSettle();
      expect(find.text('Satış tutarı: 500,00 TL'), findsOneWidget);
      expect(find.text('Mağazada ödenecek: 250,00 TL'), findsOneWidget);
      await screenshot(t, 'customer-approval-narrow');
      for (final value in ['250,01', '1e2', '-1', '0', '1,111']) {
        await t.enterText(find.byType(TextField), value);
        await t.pump();
        expect(
          t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
      }
      await t.enterText(find.byType(TextField), '12,34');
      await t.pump();
      expect(find.text('Mağazada ödenecek: 487,66 TL'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'duplicate submit is suppressed and ambiguous retry preserves exact request and amount',
    (t) async {
      repo.pendingApproval = Completer();
      await host(t, approval());
      await t.pumpAndSettle();
      await t.tap(find.text('Kuponu onayla ve QR oluştur'));
      await t.tap(find.text('Kuponu onayla ve QR oluştur'));
      await t.pump();
      expect(repo.requests.length, 1);
      expect(t.widget<TextField>(find.byType(TextField)).enabled, false);
      repo.pendingApproval!.complete(const Left('Sonuç doğrulanamadı'));
      await t.pumpAndSettle();
      await screenshot(t, 'customer-approval-retry');
      repo.pendingApproval = null;
      await t.tap(find.text('Aynı onayı tekrar kontrol et'));
      await t.pumpAndSettle();
      expect(repo.requests.length, 2);
      expect(repo.requests.toSet().length, 1);
      expect(repo.amounts, ['25000', '25000']);
      expect(find.text('Kuponsuz devam et'), findsNothing);
    },
  );
  testWidgets(
    'unknown eligibility offers no coupon action; disabled capability follows old QR flow',
    (t) async {
      repo.value = CouponCheckoutPreview.fromJson(
        checkoutPreview(
          maximum: '0',
          eligibility: 'classification_unavailable',
        ),
      );
      await host(t, approval());
      await t.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
      expect(find.textContaining('uygunluğu doğrulanamayan'), findsOneWidget);
      await screenshot(t, 'customer-ineligible');
      var skips = 0;
      repo.value = CouponCheckoutPreview.fromJson(
        checkoutPreview(enabled: false, maximum: '0'),
      );
      await t.pumpWidget(const SizedBox());
      await host(t, approval(skip: () => skips++));
      await t.pumpAndSettle();
      expect(skips, 1);
    },
  );
  testWidgets(
    'account changes clear amounts and discard prior approval response',
    (t) async {
      repo.pendingApproval = Completer();
      var accepted = 0;
      await host(t, approval(approved: (_) => accepted++));
      await t.pumpAndSettle();
      await t.tap(find.text('Kuponu onayla ve QR oluştur'));
      await t.pump();
      repo.error = 'Oturum kapandı';
      repo.changes.add(null);
      await t.pumpAndSettle();
      repo.pendingApproval!.complete(
        Right(QrSessionModel.fromJson(checkoutQr())),
      );
      await t.pumpAndSettle();
      expect(accepted, 0);
      expect(find.textContaining('500,00'), findsNothing);
      expect(find.text('Oturum kapandı'), findsOneWidget);
    },
  );
  testWidgets(
    'merchant confirmation shows exact split and requires explicit attestation',
    (t) async {
      final merchant = ClaimTestRepository();
      merchant.recovered = QrVerificationModel.fromJson({
        ...claimJson(),
        ...earningQuote(),
        'reward_confirmation_required': true,
        'reward_sale_minor': '50000',
        'coupon_checkout': checkoutTerms(),
      });
      await host(
        t,
        MerchantQrView(repository: merchant, shopId: 'shop'),
        scroll: false,
      );
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('İşlemi onayla'));
      await t.tap(find.text('İşlemi onayla'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('Müşterinin onayladığı EV kuponu: 250,00 TL'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Müşteriden alınacak: 250,00 TL'),
        findsOneWidget,
      );
      expect(merchant.completions, 0);
      await screenshot(t, 'merchant-attestation');
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(merchant.completions, 0);
    },
  );
}
