import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_session_identity.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class _Qr extends Mock implements QrSessionRepository {}

class _Credentials extends Mock implements MerchantCredentials {}

class _DelayedMerchant extends PreviewMerchantRepository {
  _DelayedMerchant(super.host) : super(hasShop: true, empty: false);
  final pending = Completer<Either<String, ShopProductEntity>>();
  @override
  Future<Either<String, ShopProductEntity>> saveListing(
    MerchantAccess access,
    MerchantListingDraft draft, {
    ShopProductEntity? existing,
  }) => pending.future;
}

MerchantServices _services(
  MerchantPreview preview, {
  MerchantRepository? merchants,
  MerchantCredentials? credentials,
  QrSessionRepository? qr,
  String? Function()? currentSessionKey,
  Stream<MerchantSessionIdentity>? sessionIdentities,
}) => MerchantServices(
  merchants: merchants ?? preview.services.merchants,
  credentials: credentials ?? preview.services.credentials,
  notifications: preview.services.notifications,
  qr: qr ?? preview.services.qr,
  preferences: preview.services.preferences,
  sessionChanges: preview.changes.stream,
  currentUserId: () => preview.currentId,
  currentSessionKey: currentSessionKey,
  sessionIdentities: sessionIdentities,
  preview: true,
);

const _screen = Key('merchant-session-screen');

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  Future<MerchantPreview> host(
    WidgetTester tester, {
    MerchantPreview? data,
    MerchantServices? services,
    double width = 430,
    double scale = 1,
  }) async {
    final preview = data ?? MerchantPreview();
    tester.view.physicalSize = Size(width, 932);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      // A closed stream can hold a completion future from the widget fake
      // clock. Close only live controllers, outside that clock.
      await tester.runAsync(() async {
        if (!preview.changes.isClosed) await preview.changes.close();
        if (!preview.notifications.events.isClosed) {
          await preview.notifications.events.close();
        }
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await tester.pumpWidget(
      RepaintBoundary(
        key: _screen,
        child: MerchantApp(services: services ?? preview.services),
      ),
    );
    await tester.pumpAndSettle();
    return preview;
  }

  Future<void> tab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> editor(WidgetTester tester) async {
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
      '79,25',
    );
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('MERCHANT_SESSION_CAPTURE')) return;
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_screen),
    );
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File('docs/evidence/merchant_session/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  testWidgets('same owner refresh preserves unsaved form and root overlay', (
    tester,
  ) async {
    final preview = await host(tester);
    await editor(tester);
    final context = tester.element(find.byType(MerchantListingForm));
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current private dialog'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    preview.changes.add(preview.currentId);
    await tester.pumpAndSettle();
    expect(find.text('Current private dialog'), findsOneWidget);
    await tester.tap(find.text('Kapat'));
    await tester.pumpAndSettle();
    expect(find.text('79,25'), findsOneWidget);
  });

  testWidgets(
    'same-account logout/login between frames discards the old editor',
    (tester) async {
      final preview = await host(tester);
      await editor(tester);
      preview.currentId = null;
      preview.changes.add(null);
      preview.currentId = preview.user.id;
      preview.changes.add(preview.currentId);
      await tester.pumpAndSettle();
      expect(find.text('Ürünü düzenle'), findsNothing);
      expect(find.text('79,25'), findsNothing);
      expect(find.text('Mağaza özeti'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('79,25'), findsNothing);
    },
  );

  testWidgets(
    'stable refresh preserves editor; replacement removes root overlay and draft',
    (tester) async {
      final preview = MerchantPreview();
      var key = 'S1';
      await host(
        tester,
        data: preview,
        services: _services(preview, currentSessionKey: () => key),
      );
      await editor(tester);
      final context = tester.element(find.byType(MerchantListingForm));
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(title: Text('S1 private dialog')),
      );
      await tester.pumpAndSettle();
      preview.changes.add(preview.currentId);
      await tester.pumpAndSettle();
      expect(find.text('S1 private dialog'), findsOneWidget);
      expect(find.text('79,25', skipOffstage: false), findsOneWidget);
      key = 'S2';
      preview.changes.add(preview.currentId);
      await tester.pumpAndSettle();
      expect(find.text('S1 private dialog'), findsNothing);
      expect(find.text('79,25', skipOffstage: false), findsNothing);
      expect(find.text('Mağaza özeti'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('79,25', skipOffstage: false), findsNothing);
    },
  );

  testWidgets('same-user replacement ignores the old listing completion', (
    tester,
  ) async {
    final preview = MerchantPreview();
    final repo = _DelayedMerchant(preview);
    var key = 'S1';
    await host(
      tester,
      data: preview,
      services: _services(
        preview,
        merchants: repo,
        currentSessionKey: () => key,
      ),
    );
    await editor(tester);
    await tester.ensureVisible(find.text('Ürünü kaydet'));
    await tester.tap(find.text('Ürünü kaydet'));
    await tester.pump();
    key = 'S2';
    preview.changes.add(preview.currentId);
    await tester.pumpAndSettle();
    repo.pending.complete(Right(repo.items.first));
    await tester.pumpAndSettle();
    expect(find.text('Mağaza özeti'), findsOneWidget);
    expect(find.text('Ürün bilgileri kaydedildi.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('queued S1 S2 S1 events cannot revive an old editor', (
    tester,
  ) async {
    final preview = MerchantPreview();
    final signals = StreamController<MerchantSessionIdentity>();
    addTearDown(() => tester.runAsync(signals.close));
    await host(
      tester,
      data: preview,
      services: _services(
        preview,
        currentSessionKey: () => 'S1',
        sessionIdentities: signals.stream,
      ),
    );
    await editor(tester);
    signals.add(
      MerchantSessionIdentity(userId: preview.currentId, sessionKey: 'S2'),
    );
    signals.add(
      MerchantSessionIdentity(userId: preview.currentId, sessionKey: 'S1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('79,25', skipOffstage: false), findsNothing);
    expect(find.text('Mağaza özeti'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('79,25', skipOffstage: false), findsNothing);
  });

  testWidgets(
    'a late listing result cannot navigate or notify the replacement session',
    (tester) async {
      final preview = MerchantPreview();
      final repo = _DelayedMerchant(preview);
      await host(
        tester,
        data: preview,
        services: _services(preview, merchants: repo),
      );
      await editor(tester);
      await tester.ensureVisible(find.text('Ürünü kaydet'));
      await tester.tap(find.text('Ürünü kaydet'));
      await tester.pump();
      preview.currentId = null;
      preview.changes.add(null);
      preview.currentId = preview.user.id;
      preview.changes.add(preview.currentId);
      await tester.pumpAndSettle();
      repo.pending.complete(Right(repo.items.first));
      await tester.pumpAndSettle();
      expect(find.text('Mağaza özeti'), findsOneWidget);
      expect(find.text('Ürün bilgileri kaydedildi.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final reason in [
    'role',
    'inactive-shop',
    'shop-revision',
    'session-error',
  ]) {
    testWidgets('$reason removes a private root route and its history', (
      tester,
    ) async {
      final preview = await host(tester);
      final context = tester.element(
        find.byType(MerchantProducts, skipOffstage: false),
      );
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => const Text('Private root sheet'),
      );
      await tester.pumpAndSettle();
      if (reason == 'role') {
        preview.user = preview.user.copyWith(role: 'customer');
      } else if (reason == 'inactive-shop') {
        preview.repository.shop = preview.repository.shop!.copyWith(
          isActive: false,
        );
      } else if (reason == 'shop-revision') {
        preview.repository.shop = preview.repository.shop!.copyWith(
          name: 'Güncel mağaza',
          updatedAt: DateTime.utc(2026, 10, 17),
        );
      }
      if (reason == 'session-error') {
        preview.changes.addError(StateError('synthetic'));
      } else {
        preview.changes.add(preview.currentId);
      }
      await tester.pumpAndSettle();
      expect(find.text('Private root sheet'), findsNothing);
      expect(
        find.text(
          reason == 'session-error'
              ? 'Hesabını doğrula'
              : reason == 'shop-revision'
              ? 'Mağaza özeti'
              : 'Esnaf erişimi',
        ),
        findsOneWidget,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Private root sheet'), findsNothing);
    });
  }

  testWidgets(
    'actual sale confirmation disappears on logout without confirming purchase',
    (tester) async {
      final preview = MerchantPreview();
      final qr = _Qr();
      when(
        () => qr.getQrVerification(sessionToken: 'synthetic-sale'),
      ).thenAnswer(
        (_) async => Right(
          QrVerificationEntity(
            sessionId: 'synthetic-session',
            sessionToken: 'synthetic-sale',
            status: 'active',
            expiresAt: DateTime.now().add(const Duration(minutes: 5)),
            shopId: MerchantPreview.shopId,
            shopName: 'Mahalle Market',
            itemCount: 0,
            totalAmount: 500,
            items: const [],
            rewardConfirmationRequired: true,
            rewardSaleMinor: '50000',
          ),
        ),
      );
      await host(
        tester,
        data: preview,
        services: _services(preview, qr: qr),
      );
      await tab(tester, 'QR');
      await tester.enterText(
        find.widgetWithText(TextField, 'Yerel test QR kodu'),
        'synthetic-sale',
      );
      await tester.tap(find.text('Test kodunu kontrol et'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('İşlemi onayla'));
      await tester.tap(find.text('İşlemi onayla'));
      await tester.pumpAndSettle();
      expect(find.text('Gerçek satış tutarını doğrula'), findsOneWidget);
      preview.currentId = null;
      preview.changes.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Gerçek satış tutarını doğrula'), findsNothing);
      expect(find.text('Satışı doğrula'), findsNothing);
      expect(find.text('Giriş yap'), findsOneWidget);
      verifyNever(
        () =>
            qr.confirmQrVerification(sessionToken: any(named: 'sessionToken')),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed login preserves typed fields and prevents duplicate submit',
    (tester) async {
      final preview = MerchantPreview(signedIn: false);
      final credentials = _Credentials();
      final pending = Completer<Either<String, void>>();
      when(
        () => credentials.signIn('pilot@example.invalid', 'synthetic-input'),
      ).thenAnswer((_) => pending.future);
      await host(
        tester,
        data: preview,
        services: _services(preview, credentials: credentials),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-posta'),
        'pilot@example.invalid',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Şifre'),
        'synthetic-input',
      );
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Giriş yap'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
      await tester.pump();
      expect(find.text('pilot@example.invalid'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Giriş yapılıyor…'),
            )
            .onPressed,
        isNull,
      );
      pending.complete(const Left('Giriş bilgilerini kontrol edin.'));
      await tester.pumpAndSettle();
      expect(find.text('pilot@example.invalid'), findsOneWidget);
      expect(find.text('Giriş bilgilerini kontrol edin.'), findsOneWidget);
      verify(
        () => credentials.signIn('pilot@example.invalid', 'synthetic-input'),
      ).called(1);
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('failure and recovery render at $width / 130 percent', (
      tester,
    ) async {
      final preview = await host(tester, width: width, scale: 1.3);
      preview.changes.addError(StateError('synthetic'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, 'failure-${width.toInt()}');
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.text('Mağaza özeti'), findsOneWidget);
      await preview.changes.close();
      await tester.pumpAndSettle();
      expect(find.text('Tekrar dene'), findsNothing);
      expect(find.textContaining('yeniden açın'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capture(tester, 'monitor-ended-${width.toInt()}');
    });
  }

  testWidgets('session expiry removes root dialog and its private content', (
    tester,
  ) async {
    final preview = await host(tester);
    final context = tester.element(
      find.byType(MerchantProducts, skipOffstage: false),
    );
    // Matches the root-dialog routing used by sale confirmation and replies.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const AlertDialog(title: Text('Private merchant confirmation')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Private merchant confirmation'), findsOneWidget);
    preview.currentId = null;
    preview.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Private merchant confirmation'), findsNothing);
    expect(find.text('Giriş yap'), findsOneWidget);
  });

  testWidgets('private success message cannot survive into login', (
    tester,
  ) async {
    final preview = await host(tester);
    final context = tester.element(
      find.byType(MerchantProducts, skipOffstage: false),
    );
    merchantSaved(context, 'Private merchant result');
    await tester.pump();
    preview.currentId = null;
    preview.changes.add(null);
    await tester.pump();
    expect(find.text('Private merchant result'), findsNothing);
    expect(find.text('Giriş yap'), findsOneWidget);
  });
}
