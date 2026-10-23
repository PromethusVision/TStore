import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_account_recovery.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_account_recovery_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import '../../unit/merchant/merchant_account_recovery_test.dart'
    show RecoveryBackendFake, pilotCallback;
import '../../unit/merchant/merchant_repository_test.dart' show access, listing;
import 'merchant_v1_test.dart' show host, tab;

class _Catalog extends Mock implements CatalogMediaRepository {}

class _Merchant extends Mock
    implements MerchantRepository, MerchantRecoveryRepository {}

Finder input(String label) => find.byElementPredicate((element) {
  final widget = element.widget;
  if (widget is! TextField) return false;
  return element.findAncestorWidgetOfExactType<MerchantInput>()?.labelText ==
          label ||
      widget.decoration?.labelText == label;
});

Future<void> surface(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetViewInsets();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: EsnaftaVarTheme.light,
      home: RepaintBoundary(key: const Key('accessible-screen'), child: child),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> compact(WidgetTester tester, MerchantPreview preview) async {
  await host(tester, preview, width: 320, scale: 2);
  tester.view.physicalSize = const Size(320, 640);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpAndSettle();
}

Future<void> reveal(
  WidgetTester tester,
  Finder finder, {
  double delta = 160,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 80,
  );
  await tester.pumpAndSettle();
}

void readable(WidgetTester tester, String value) {
  final text = find.text(value);
  expect(text, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(text);
  expect(paragraph.didExceedMaxLines, isFalse, reason: value);
}

void main() {
  setUpAll(() async {
    registerFallbackValue(
      const ProductSubmissionDraft(name: 'prova', categoryId: 'c'),
    );
    registerFallbackValue(
      const MerchantListingDraft(productId: 'p', priceMinor: 0),
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

  testWidgets('invalid login reveals its email and never signs in', (
    tester,
  ) async {
    final preview = MerchantPreview(signedIn: false);
    await compact(tester, preview);
    await reveal(tester, find.text('Giriş yap'));
    await tester.tap(find.text('Giriş yap'));
    await tester.pumpAndSettle();
    expect(find.text('Geçerli e-posta girin.').hitTestable(), findsOneWidget);
    readable(tester, 'Geçerli e-posta girin.');
    expect(preview.currentId, isNull);
  });

  testWidgets('recovery request validates visibly without sending an email', (
    tester,
  ) async {
    final backend = RecoveryBackendFake();
    final recovery = MerchantAccountRecovery(
      backend: backend,
      contract: AuthCallbackContract.merchantPilot(),
    )..request();
    addTearDown(() async {
      recovery.dispose();
      await backend.changes.close();
    });
    await surface(tester, MerchantAccountRecoveryView(recovery: recovery));
    await reveal(tester, find.text('Bağlantı gönder'));
    await tester.tap(find.text('Bağlantı gönder'));
    await tester.pumpAndSettle();
    readable(tester, 'Geçerli e-posta girin.');
    expect(find.text('Geçerli e-posta girin.').hitTestable(), findsOneWidget);
    expect(backend.sends, 0);
  });

  testWidgets(
    'password mismatch remains readable and does not update password',
    (tester) async {
      final backend = RecoveryBackendFake();
      final recovery = MerchantAccountRecovery(
        backend: backend,
        contract: AuthCallbackContract.merchantPilot(),
      );
      await recovery.receive(pilotCallback);
      addTearDown(() async {
        recovery.dispose();
        await backend.changes.close();
      });
      await surface(tester, MerchantAccountRecoveryView(recovery: recovery));
      await reveal(tester, input('Yeni şifre'));
      await tester.enterText(input('Yeni şifre'), 'synthetic-only');
      await reveal(tester, input('Yeni şifre tekrar'));
      await tester.enterText(input('Yeni şifre tekrar'), 'different');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Şifreyi yenile'));
      await tester.tap(find.text('Şifreyi yenile'));
      await tester.pumpAndSettle();
      readable(tester, 'Şifreler eşleşmiyor.');
      expect(find.text('Şifreler eşleşmiyor.').hitTestable(), findsOneWidget);
      expect(backend.updates, 0);
    },
  );

  testWidgets(
    'catalog validation reveals the first error and never submits an invalid product',
    (tester) async {
      final catalog = _Catalog();
      final merchant = _Merchant();
      when(() => catalog.categories(access)).thenAnswer(
        (_) async => const Right([CatalogCategory('c', 'Kırtasiye')]),
      );
      await surface(
        tester,
        MerchantProductSubmission(
          catalog: catalog,
          repository: merchant,
          access: access,
        ),
      );
      await reveal(tester, find.text('İncelemeye gönder'));
      await tester.tap(find.text('İncelemeye gönder'));
      await tester.pumpAndSettle();
      expect(find.text('Ürün adını girin.').hitTestable(), findsOneWidget);
      verifyNever(() => catalog.lookup(access, any(), any()));
      verifyNever(() => catalog.submit(access, any(), any()));
      await tester.enterText(input('Ürün adı'), 'Yerel prova ürünü');
      await reveal(tester, find.text('İncelemeye gönder'));
      await tester.tap(find.text('İncelemeye gönder'));
      await tester.pumpAndSettle();
      expect(find.text('Kategori seçin.').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'lost listing response keeps the draft and recovery controls usable at large text',
    (tester) async {
      final merchant = _Merchant();
      final response = Completer<Either<String, ShopProductEntity>>();
      when(
        () => merchant.saveListing(access, any(), existing: listing),
      ).thenAnswer((_) => response.future);
      when(
        () => merchant.readListing(access, listing.productId),
      ).thenAnswer((_) async => Right(listing));
      await surface(
        tester,
        MerchantListingForm(
          repository: merchant,
          access: access,
          existing: listing,
        ),
      );
      await tester.enterText(input('Mağaza fiyatı (TL)'), '64,25');
      await reveal(tester, find.text('Ürünü kaydet'));
      await tester.tap(find.text('Ürünü kaydet'));
      await tester.tap(find.text('Ürünü kaydet'));
      await tester.pumpAndSettle();
      expect(find.text('Kaydediliyor…'), findsOneWidget);
      verify(
        () => merchant.saveListing(access, any(), existing: listing),
      ).called(1);
      response.complete(const Left('Kayıt yanıtı alınamadı.'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Güncel kaydı kontrol et'), delta: -160);
      await tester.tap(find.text('Güncel kaydı kontrol et'));
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Taslağımı bu kayıt üzerinde düzenle'));
      readable(tester, 'Taslağımı bu kayıt üzerinde düzenle');
      await tester.tap(find.text('Taslağımı bu kayıt üzerinde düzenle'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('64,25'), delta: -160);
      expect(find.text('64,25'), findsOneWidget);
      verifyNever(() => merchant.saveListing(access, any(), existing: listing));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('long catalog category is readable in menu and selected field', (
    tester,
  ) async {
    final catalog = _Catalog();
    const name = 'Ev, yaşam ve mutfak ürünleri';
    when(
      () => catalog.categories(access),
    ).thenAnswer((_) async => const Right([CatalogCategory('c', name)]));
    await surface(
      tester,
      MerchantProductSubmission(
        catalog: catalog,
        repository: _Merchant(),
        access: access,
      ),
    );
    final field = find.byType(DropdownButtonFormField<String>);
    await reveal(tester, field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    readable(tester, name);
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
    readable(tester, name);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a retired form cannot scroll a replacement page after validation',
    (tester) async {
      final key = GlobalKey<FormState>();
      await surface(
        tester,
        MerchantPage(
          title: 'Yerel prova',
          children: [
            Form(
              key: key,
              child: TextFormField(validator: (_) => 'Eksik alan'),
            ),
          ],
        ),
      );
      expect(merchantValidateForm(key), isFalse);
      // Replace before the validation's post-frame reveal runs.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Yeni oturum'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Yeni oturum'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'covered form does not move behind another route after validation',
    (tester) async {
      final key = GlobalKey<FormState>();
      await surface(
        tester,
        MerchantPage(
          title: 'Yerel prova',
          children: [
            Form(
              key: key,
              child: Column(
                children: [
                  TextFormField(validator: (_) => 'Eksik alan'),
                  const SizedBox(height: 1200),
                  const Text('Alt bölüm'),
                ],
              ),
            ),
          ],
        ),
      );
      await reveal(tester, find.text('Alt bölüm'));
      final scroll = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      final before = scroll.pixels;
      expect(merchantValidateForm(key), isFalse);
      Navigator.of(key.currentContext!).push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Başka ekran')),
        ),
      );
      await tester.pumpAndSettle();
      expect(scroll.pixels, before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all five daily tabs remain usable at 320dp and 200 percent text',
    (tester) async {
      await compact(tester, MerchantPreview());
      for (final label in ['Ürünler', 'QR', 'Bildirim', 'Hesap', 'Özet']) {
        await tab(tester, label);
        expect(tester.takeException(), isNull, reason: label);
      }
      await reveal(tester, find.text('Ürünleri ve fiyatları yönet'));
      await tester.tap(find.text('Ürünleri ve fiyatları yönet'));
      await tester.pumpAndSettle();
      expect(find.text('Ürünlerim'), findsOneWidget);
    },
  );

  testWidgets('long listing field label is fully readable before typing', (
    tester,
  ) async {
    await compact(tester, MerchantPreview());
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Mağazana özel açıklama'));
    readable(tester, 'Mağazana özel açıklama');
  });

  testWidgets(
    'owned product search keeps its full label and filters at large text',
    (tester) async {
      await compact(tester, MerchantPreview());
      await tab(tester, 'Ürünler');
      readable(tester, 'Ürünlerinde ara');
      await tester.enterText(input('Ürünlerinde ara'), 'süt');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Tam yağlı süt 1 L'), findsOneWidget);
      expect(find.text('Maden suyu 6 × 200 ml'), findsNothing);
    },
  );

  testWidgets(
    'catalog search keeps its full barcode label and filters at large text',
    (tester) async {
      final preview = MerchantPreview();
      addTearDown(preview.dispose);
      await surface(
        tester,
        MerchantCatalogPicker(
          repository: preview.repository,
          access: (await preview.repository.loadAccess()).getOrElse(
            () => null,
          )!,
          catalogMedia: _Catalog(),
        ),
      );
      readable(tester, 'Ürün adı veya barkodla ara');
      await tester.enterText(input('Ürün adı veya barkodla ara'), 'süt');
      await tester.tap(find.byTooltip('Ara'));
      await tester.pumpAndSettle();
      expect(find.text('Tam yağlı süt 1 L'), findsOneWidget);
      expect(find.text('Maden suyu 6 × 200 ml'), findsNothing);
    },
  );

  testWidgets(
    'shop opening-hour choice is fully readable before and after selection',
    (tester) async {
      await compact(tester, MerchantPreview(hasShop: false));
      final field = find.byKey(const ValueKey('hours-sat'));
      await reveal(tester, field);
      readable(tester, 'Cumartesi');
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kapalı').last);
      await tester.pumpAndSettle();
      readable(tester, 'Cumartesi');
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Cumartesi'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('merchant-screen')),
        matchesGoldenFile('goldens/accessible_shop_hours_320_200.png'),
      );
    },
  );

  testWidgets('daily hours retain an actionable accessible name and value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await compact(tester, MerchantPreview(hasShop: false));
    final field = find.byKey(const ValueKey('hours-sat'));
    await reveal(tester, field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kapalı').last);
    await tester.pumpAndSettle();
    final node = tester.getSemantics(field);
    expect(node.getSemanticsData().label, contains('Cumartesi'));
    expect(node.getSemanticsData().label, contains('Kapalı'));
    expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('daily navigation keeps labeled touch targets with large text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await compact(tester, MerchantPreview());
    for (final label in ['Ürünler', 'Bildirim', 'Hesap', 'Özet']) {
      await tab(tester, label);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    }
    semantics.dispose();
  });

  testWidgets('price validation explains the whole error at large text', (
    tester,
  ) async {
    final preview = MerchantPreview();
    await compact(tester, preview);
    await tab(tester, 'Ürünler');
    await tester.tap(find.text('Tam yağlı süt 1 L'));
    await tester.pumpAndSettle();
    await tester.enterText(input('Mağaza fiyatı (TL)'), '-1');
    await reveal(tester, find.text('Ürünü kaydet'));
    await tester.tap(find.text('Ürünü kaydet'));
    await tester.pumpAndSettle();
    const message =
        'En fazla iki ondalık basamaklı, negatif olmayan fiyat girin.';
    await reveal(tester, find.text(message), delta: -160);
    readable(tester, message);
    expect(preview.repository.items.first.price, isNot(-1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'saving invalid price reveals the field without hunting upwards',
    (tester) async {
      await compact(tester, MerchantPreview());
      await tab(tester, 'Ürünler');
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(input('Mağaza fiyatı (TL)'), '-1');
      await reveal(tester, find.text('Ürünü kaydet'));
      await tester.tap(find.text('Ürünü kaydet'));
      await tester.pumpAndSettle();
      expect(
        find
            .text(
              'En fazla iki ondalık basamaklı, negatif olmayan fiyat girin.',
            )
            .hitTestable(),
        findsOneWidget,
      );
      await expectLater(
        find.byKey(const Key('merchant-screen')),
        matchesGoldenFile('goldens/accessible_price_error_320_200.png'),
      );
    },
  );

  testWidgets('empty onboarding brings the required name back into view', (
    tester,
  ) async {
    final preview = MerchantPreview(hasShop: false, empty: true);
    await compact(tester, preview);
    await reveal(tester, find.text('Mağazayı kaydet'));
    await tester.tap(find.text('Mağazayı kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Bu alanı doldurun.').hitTestable(), findsOneWidget);
    expect(preview.repository.shop, isNull);
  });

  testWidgets('onboarding heading is not silently truncated at large text', (
    tester,
  ) async {
    await compact(tester, MerchantPreview(hasShop: false));
    readable(tester, 'Mağazanı oluştur');
  });

  testWidgets(
    'dragging the editor dismisses keyboard without losing entered price',
    (tester) async {
      await compact(tester, MerchantPreview());
      await tab(tester, 'Ürünler');
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      final price = input('Mağaza fiyatı (TL)');
      await tester.enterText(price, '64,25');
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.drag(find.byType(ListView).first, const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(find.text('64,25'), findsOneWidget);
    },
  );

  testWidgets(
    'dirty editor confirmation fits above keyboard and preserves draft on cancel',
    (tester) async {
      await compact(tester, MerchantPreview());
      await tab(tester, 'Ürünler');
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(input('Mağaza fiyatı (TL)'), '64,25');
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final cancel = find.text('Düzenlemeye dön');
      await reveal(tester, cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(find.text('64,25'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('onboarding can be completed with large text and keyboard', (
    tester,
  ) async {
    final preview = MerchantPreview(hasShop: false, empty: true);
    await compact(tester, preview);
    final name = input('Mağaza adı');
    await reveal(tester, name);
    await tester.enterText(name, 'Yerel prova mağazası');
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Mağazayı kaydet'));
    await tester.tap(find.text('Mağazayı kaydet'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(preview.repository.shop!.name, 'Yerel prova mağazası');
    expect(find.text('Mağaza özeti'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
