import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class _Repository extends Mock implements MerchantRepository {}

const _boundary = Key('merchant-screen');

void main() {
  setUpAll(() async {
    registerFallbackValue(
      const MerchantListingDraft(productId: 'fallback', priceMinor: 0),
    );
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

  testWidgets('onboarding persists shop and opens merchant workspace', (
    tester,
  ) async {
    final preview = MerchantPreview(hasShop: false, empty: true);
    await host(tester, preview);
    expect(find.text('Mağazanı oluştur'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mağaza adı'),
      'Yeni mağazam',
    );
    final save = find.widgetWithText(FilledButton, 'Mağazayı kaydet');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Mağaza özeti'), findsOneWidget);
    expect(preview.repository.shop!.name, 'Yeni mağazam');
  });
  testWidgets('wrong role has no dashboard or catalog route', (tester) async {
    final preview = MerchantPreview(role: 'customer');
    await host(tester, preview);
    expect(find.text('Esnaf erişimi'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Ürünleri ve fiyatları yönet'), findsNothing);
  });
  testWidgets('login validates before any auth operation', (tester) async {
    final preview = MerchantPreview(signedIn: false);
    await host(tester, preview);
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('Geçerli e-posta girin.'), findsOneWidget);
    expect(preview.currentId, isNull);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-posta'),
      'esnaf@example.invalid',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Şifre'),
      'local-preview',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('Mağaza özeti'), findsOneWidget);
  });
  testWidgets(
    'add product, edit price/availability, deactivate, return to list',
    (tester) async {
      final preview = MerchantPreview(empty: true);
      await host(tester, preview);
      await tab(tester, 'Ürünler');
      await tester.tap(find.byTooltip('Ürün ekle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '42,50',
      );
      await saveListing(tester);
      expect(preview.repository.items.single.price, 42.5);
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '45',
      );
      await tester.tap(find.widgetWithText(SwitchListTile, 'Stokta var'));
      await tester.ensureVisible(
        find.widgetWithText(SwitchListTile, 'Ürün aktif'),
      );
      await tester.tap(find.widgetWithText(SwitchListTile, 'Ürün aktif'));
      await saveListing(tester);
      final item = preview.repository.items.single;
      expect(item.price, 45);
      expect(item.isAvailable, false);
      expect(item.isActive, false);
      expect(find.textContaining('Pasif'), findsOneWidget);
    },
  );
  testWidgets(
    'system back closes the merchant editor before leaving workspace',
    (tester) async {
      final preview = MerchantPreview();
      await host(tester, preview);
      await tab(tester, 'Ürünler');
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Ürünlerim'), findsOneWidget);
      expect(find.text('Ürünü düzenle'), findsNothing);
    },
  );
  testWidgets('session expiry removes an open editor and private navigation', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await host(tester, preview);
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    preview.currentId = null;
    preview.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Giriş yap'), findsOneWidget);
    expect(find.text('Ürünü düzenle'), findsNothing);
    expect(find.text('Mağaza fiyatı (TL)'), findsNothing);
  });
  testWidgets('resume keeps an editor open when role and shop are unchanged', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await host(tester, preview);
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Ürünü düzenle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shared notification read-state and local settings work', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await host(tester, preview);
    await tab(tester, 'Bildirim');
    await tester.tap(find.text('Esnaf uygulamasına hoş geldin'));
    await tester.pumpAndSettle();
    expect(preview.notifications.items.single.isRead, true);
    await tab(tester, 'Hesap');
    expect(find.text('Bildirim tercihleri'), findsOneWidget);
    expect(find.textContaining('henüz etkin değil'), findsOneWidget);
  });
  testWidgets('QR preview follows explicit confirmation and reset', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await host(tester, preview);
    await tab(tester, 'QR');
    await tester.enterText(
      find.widgetWithText(TextField, 'Yerel test QR kodu'),
      'merchant-v1-preview',
    );
    await tester.tap(find.text('Test kodunu kontrol et'));
    await tester.pumpAndSettle();
    expect(find.text('İşlemi onayla'), findsOneWidget);
    await tester.ensureVisible(find.text('İşlemi onayla'));
    await tester.tap(find.text('İşlemi onayla'));
    await tester.pumpAndSettle();
    expect(find.text('Sunucu işlem onayını doğruladı.'), findsOneWidget);
    await tester.ensureVisible(find.text('Yeni QR okut'));
    await tester.tap(find.text('Yeni QR okut'));
    await tester.pumpAndSettle();
    expect(find.text('Test kodunu kontrol et'), findsOneWidget);
  });
  testWidgets('slow save suppresses second submit and preserves failed form', (
    tester,
  ) async {
    final preview = MerchantPreview();
    final repository = _Repository();
    final access = MerchantAccess(
      user: preview.user,
      shop: preview.repository.shop,
    );
    final pending = Completer<Either<String, ShopProductEntity>>();
    when(
      () => repository.saveListing(access, any(), existing: null),
    ).thenAnswer((_) => pending.future);
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: MerchantListingForm(
          repository: repository,
          access: access,
          product: PreviewMerchantRepository.catalog.first,
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
      '12,99',
    );
    await tester.ensureVisible(find.text('Ürünü kaydet'));
    await tester.tap(find.text('Ürünü kaydet'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    verify(
      () => repository.saveListing(access, any(), existing: null),
    ).called(1);
    pending.complete(const Left('Bağlantı kurulamadı.'));
    await tester.pumpAndSettle();
    expect(find.text('Bağlantı kurulamadı.'), findsOneWidget);
    expect(find.text('12,99'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await preview.dispose();
  });
  testWidgets('offline list has retry and recovers without fake success', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await host(tester, preview);
    await tab(tester, 'Ürünler');
    preview.repository.failure = 'Bağlantı kurulamadı.';
    await tester.enterText(
      find.widgetWithText(TextField, 'Ürünlerinde ara'),
      'süt',
    );
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('Bağlantı kurulamadı.'), findsOneWidget);
    preview.repository.failure = null;
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(find.text('Tam yağlı süt 1 L'), findsOneWidget);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('merchant tabs and dashboard at ${width.toInt()}px / 130%', (
      tester,
    ) async {
      final preview = MerchantPreview();
      await host(tester, preview, width: width, scale: 1.3);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(_boundary),
        matchesGoldenFile('goldens/dashboard_${width.toInt()}_130.png'),
      );
      for (final label in ['Ürünler', 'QR', 'Bildirim', 'Hesap']) {
        await tab(tester, label);
        expect(tester.takeException(), isNull, reason: label);
      }
    });
  }
  testWidgets('product editor 390px visual state', (tester) async {
    final preview = MerchantPreview();
    await host(tester, preview, width: 390, scale: 1.0);
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_boundary),
      matchesGoldenFile('goldens/product_editor_390.png'),
    );
  });
}

Future<void> host(
  WidgetTester tester,
  MerchantPreview preview, {
  double width = 430,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 932);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await preview.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: MerchantApp(services: preview.services),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> saveListing(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Ürünü kaydet'));
  await tester.tap(find.text('Ürünü kaydet'));
  await tester.pumpAndSettle();
}
