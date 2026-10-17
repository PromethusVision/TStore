import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/features/merchant/domain/merchant_account_recovery.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/main_merchant_pilot.dart';
import '../../unit/merchant/merchant_account_recovery_test.dart'
    show RecoveryBackendFake, pilotCallback;

void main() {
  setUpAll(() async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf')))
        .load();
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    await (FontLoader('MaterialIcons')..addFont(
          File(
            '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
  });
  late MerchantPreview preview;
  late RecoveryBackendFake backend;
  late MerchantAccountRecovery recovery;
  Future<void> host(
    WidgetTester tester, {
    bool signedIn = false,
    double width = 390,
  }) async {
    preview = MerchantPreview(signedIn: signedIn);
    backend = RecoveryBackendFake();
    recovery = MerchantAccountRecovery(
      backend: backend,
      contract: AuthCallbackContract.merchantPilot(),
    );
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      recovery.dispose();
      await tester.runAsync(() async {
        await backend.changes.close();
        await preview.dispose();
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final old = preview.services;
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('pilot-capture'),
        child: MerchantApp(
          services: MerchantServices(
            merchants: old.merchants,
            credentials: old.credentials,
            notifications: old.notifications,
            qr: old.qr,
            preferences: old.preferences,
            sessionChanges: old.sessionChanges,
            currentUserId: old.currentUserId,
            recovery: recovery,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('PILOT_CAPTURE')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('pilot-capture')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))!.buffer.asUint8List();
      final file = File('docs/evidence/merchant_pilot/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      image.dispose();
    });
  }

  testWidgets(
    'forgot password validates, sends once and returns to Merchant login',
    (tester) async {
      await host(tester);
      await tester.ensureVisible(find.text('Şifremi unuttum'));
      await tester.tap(find.text('Şifremi unuttum'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bağlantı gönder'));
      await tester.pumpAndSettle();
      expect(backend.sends, 0);
      expect(find.text('Geçerli e-posta girin.'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-posta'),
        'a@shop.invalid',
      );
      backend.sendWait = Completer();
      await tester.tap(find.text('Bağlantı gönder'));
      await tester.pump();
      expect(find.text('Bağlantı gönder'), findsNothing);
      expect(backend.sends, 1);
      backend.sendWait!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Hesabınız uygunsa'), findsOneWidget);
      await tester.tap(find.text('Girişe dön'));
      await tester.pumpAndSettle();
      expect(find.text('Giriş yap'), findsOneWidget);
    },
  );
  testWidgets(
    'incoming recovery closes private routes and root dialog before exchange',
    (tester) async {
      await host(tester, signedIn: true);
      expect(find.text('Mağaza özeti'), findsOneWidget);
      final context = tester.element(find.text('Mağaza özeti'));
      unawaited(
        showDialog<void>(
          context: context,
          builder: (_) =>
              const AlertDialog(title: Text('Özel mağaza diyaloğu')),
        ),
      );
      await tester.pumpAndSettle();
      backend.verifyWait = Completer();
      final verification = recovery.receive(pilotCallback);
      await tester.pump();
      await tester.pump();
      expect(find.text('Özel mağaza diyaloğu'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      backend.verifyWait!.complete();
      await verification;
      await tester.pumpAndSettle();
      expect(find.text('Yeni şifre'), findsOneWidget);
      expect(find.text('Mağaza özeti'), findsNothing);
    },
  );
  testWidgets(
    'mismatch never submits and session change removes password form',
    (tester) async {
      await host(tester);
      await recovery.receive(pilotCallback);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Yeni şifre'),
        'new-password',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Yeni şifre tekrar'),
        'different',
      );
      await tester.tap(find.text('Şifreyi yenile'));
      await tester.pumpAndSettle();
      expect(backend.updates, 0);
      expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
      backend.sessionKey = 'merchant-b:new';
      backend.changes.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(find.textContaining('doğrulanamadı'), findsOneWidget);
    },
  );
  testWidgets(
    'successful password update returns to fresh login, never opens dashboard',
    (tester) async {
      await host(tester);
      await recovery.receive(pilotCallback);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Yeni şifre'),
        'new-password',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Yeni şifre tekrar'),
        'new-password',
      );
      await tester.tap(find.text('Şifreyi yenile'));
      await tester.pumpAndSettle();
      expect(backend.updates, 1);
      expect(find.textContaining('Şifreniz yenilendi'), findsOneWidget);
      expect(find.text('Mağaza özeti'), findsNothing);
      await tester.tap(find.text('Girişe dön'));
      await tester.pumpAndSettle();
      expect(find.text('Giriş yap'), findsOneWidget);
    },
  );
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('pilot recovery render at $width and 130% scale', (
      tester,
    ) async {
      await host(tester, width: width);
      await recovery.receive(pilotCallback);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, 'password_${width.toInt()}');
      backend.sessionKey = 'other';
      backend.changes.add(null);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, 'invalid_${width.toInt()}');
    });
  }
  testWidgets('unconfigured artifact displays a safe setup surface', (
    tester,
  ) async {
    await tester.pumpWidget(const MerchantPilotSetupRequired());
    await tester.pumpAndSettle();
    expect(find.text('Pilot kurulumu gerekli'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'uncertain exchange cannot offer an action that logs out a new account',
    (tester) async {
      await host(tester, signedIn: true);
      backend.failVerify = true;
      backend.failureSession = 'merchant-b:new';
      await recovery.receive(pilotCallback);
      await tester.pumpAndSettle();
      expect(find.textContaining('kapatıp yeniden açın'), findsOneWidget);
      expect(find.text('Girişe dön'), findsNothing);
      expect(find.text('Mağaza özeti'), findsNothing);
      expect(backend.clears, 0);
    },
  );
}
