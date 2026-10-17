import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_catalog_cubit.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import '../../unit/merchant/merchant_repository_test.dart'
    show access, shop, listing, user;

class _Repo extends Mock
    implements MerchantRepository, MerchantRecoveryRepository {}

class _Media extends Mock implements CatalogMediaRepository {}

const _product = ProductEntity(
  id: 'product-a',
  name: 'Örnek ürün',
  categoryId: 'c',
  price: 0,
  stock: 0,
  images: [],
);
const _image = ListingImage(
  id: 'image',
  path: 'local',
  state: 'published',
  primary: true,
  order: 0,
);

void main() {
  late _Repo repo;
  late _Media media;
  setUpAll(() async {
    registerFallbackValue(access);
    registerFallbackValue(
      const MerchantListingDraft(productId: 'x', priceMinor: 0),
    );
    registerFallbackValue(const MerchantShopDraft(name: 'x'));
    registerFallbackValue(
      const ProductSubmissionDraft(name: 'x', categoryId: 'c'),
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
  setUp(() {
    repo = _Repo();
    media = _Media();
    when(
      () => repo.saveListing(any(), any(), existing: any(named: 'existing')),
    ).thenAnswer((_) async => const Left('Kayıt sonucu alınamadı.'));
    when(
      () => repo.saveShop(any(), any()),
    ).thenAnswer((_) async => const Left('Kayıt sonucu alınamadı.'));
    when(
      () => repo.readListing(any(), any()),
    ).thenAnswer((_) async => Right(listing));
    when(() => repo.loadAccess()).thenAnswer((_) async => Right(access));
  });
  Future<void> host(
    WidgetTester t,
    Widget child, {
    double width = 390,
    double scale = 1,
  }) async {
    t.view.physicalSize = Size(width, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: RepaintBoundary(key: const Key('capture'), child: child!),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => child),
              ),
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Aç'));
    await t.pumpAndSettle();
  }

  Widget form({bool creating = false}) => MerchantListingForm(
    repository: repo,
    access: access,
    product: _product,
    existing: creating ? null : listing,
  );
  Future<void> tap(WidgetTester t, String label) async {
    final finder = find.text(label);
    await t.ensureVisible(finder);
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  Future<void> edit(WidgetTester t, {String value = '25,50'}) async {
    await t.enterText(
      find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
      value,
    );
    await tap(t, 'Ürünü kaydet');
  }

  ShopProductEntity current({double price = 25.5}) => ShopProductEntity(
    id: listing.id,
    shopId: shop.id,
    productId: listing.productId,
    price: price,
    updatedAt: DateTime.utc(2026, 10, 17),
  );

  testWidgets(
    'lost listing acknowledgement reconciles matching state without resubmission',
    (t) async {
      when(
        () => repo.readListing(access, listing.productId),
      ).thenAnswer((_) async => Right(current()));
      await host(t, form());
      await edit(t);
      expect(find.text('25,50'), findsOneWidget);
      expect(
        t
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Ürünü kaydet'),
            )
            .onPressed,
        isNull,
      );
      await tap(t, 'Güncel kaydı kontrol et');
      expect(
        find.text('Güncel kayıt, gönderdiğin bilgilerle aynı.'),
        findsOneWidget,
      );
      await tap(t, 'Güncel kayıtla devam et');
      expect(find.text('Aç'), findsOneWidget);
      verify(
        () => repo.saveListing(access, any(), existing: listing),
      ).called(1);
    },
  );
  testWidgets(
    'conflict keeps draft only by explicit review and uses fresh revision',
    (t) async {
      final fresh = current(price: 35);
      when(
        () => repo.readListing(access, listing.productId),
      ).thenAnswer((_) async => Right(fresh));
      await host(t, form());
      await edit(t);
      await tap(t, 'Güncel kaydı kontrol et');
      expect(find.textContaining('35,00 TL'), findsOneWidget);
      await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
      expect(find.text('25,50'), findsOneWidget);
      await tap(t, 'Ürünü kaydet');
      verify(() => repo.saveListing(access, any(), existing: fresh)).called(1);
    },
  );
  testWidgets('use current updates all fields without writing', (t) async {
    final fresh = ShopProductEntity(
      id: listing.id,
      shopId: shop.id,
      productId: listing.productId,
      price: 35,
      description: 'Başka cihaz',
      isActive: false,
      isAvailable: false,
      updatedAt: DateTime.utc(2026, 10, 17),
    );
    when(
      () => repo.readListing(access, listing.productId),
    ).thenAnswer((_) async => Right(fresh));
    await host(t, form());
    await edit(t);
    await tap(t, 'Güncel kaydı kontrol et');
    await tap(t, 'Güncel bilgileri kullan');
    expect(find.text('35,00'), findsOneWidget);
    expect(find.text('Başka cihaz'), findsOneWidget);
    expect(
      t
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Stokta var'),
          )
          .value,
      false,
    );
    verify(() => repo.saveListing(access, any(), existing: listing)).called(1);
  });
  testWidgets('failed reconciliation keeps edits and blocks blind retry', (
    t,
  ) async {
    when(
      () => repo.readListing(access, listing.productId),
    ).thenAnswer((_) async => const Left('Çevrimdışı'));
    await host(t, form());
    await edit(t);
    await tap(t, 'Güncel kaydı kontrol et');
    expect(find.text('Çevrimdışı'), findsOneWidget);
    expect(find.text('25,50'), findsOneWidget);
    expect(
      t
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Ürünü kaydet'),
          )
          .onPressed,
      isNull,
    );
    verify(() => repo.saveListing(access, any(), existing: listing)).called(1);
  });
  testWidgets('deleted listing is never recreated by recovery', (t) async {
    when(
      () => repo.readListing(access, listing.productId),
    ).thenAnswer((_) async => const Right(null));
    await host(t, form());
    await edit(t);
    await tap(t, 'Güncel kaydı kontrol et');
    expect(find.text('Taslağımı bu kayıt üzerinde düzenle'), findsNothing);
    expect(find.textContaining('artık ulaşılamıyor'), findsOneWidget);
    verifyNever(() => repo.saveListing(access, any(), existing: null));
  });
  testWidgets('new listing missing after failure can be explicitly retried', (
    t,
  ) async {
    when(
      () => repo.readListing(access, listing.productId),
    ).thenAnswer((_) async => const Right(null));
    await host(t, form(creating: true));
    await edit(t);
    await tap(t, 'Güncel kaydı kontrol et');
    await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
    await tap(t, 'Ürünü kaydet');
    verify(() => repo.saveListing(access, any(), existing: null)).called(2);
  });
  testWidgets(
    'duplicate add switches to existing listing only after explicit review',
    (t) async {
      final fresh = current(price: 50);
      when(
        () => repo.readListing(access, listing.productId),
      ).thenAnswer((_) async => Right(fresh));
      await host(t, form(creating: true));
      await edit(t);
      await tap(t, 'Güncel kaydı kontrol et');
      verifyNever(() => repo.saveListing(access, any(), existing: fresh));
      await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
      await tap(t, 'Ürünü kaydet');
      verify(() => repo.saveListing(access, any(), existing: fresh)).called(1);
    },
  );
  testWidgets('pending write stays locked past read deadline and blocks back', (
    t,
  ) async {
    final gate = Completer<Either<String, ShopProductEntity>>();
    when(
      () => repo.saveListing(access, any(), existing: listing),
    ).thenAnswer((_) => gate.future);
    await host(t, form());
    await t.enterText(
      find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
      '25,50',
    );
    await t.ensureVisible(find.text('Ürünü kaydet'));
    await t.tap(find.text('Ürünü kaydet'));
    await t.pump(const Duration(seconds: 20));
    await t.binding.handlePopRoute();
    await t.pump();
    expect(find.text('Kaydediliyor…'), findsOneWidget);
    verifyNever(() => repo.readListing(any(), any()));
    gate.complete(const Left('Belirsiz'));
    await t.pumpAndSettle();
    expect(find.text('Kayıt durumunu kontrol et'), findsOneWidget);
  });
  testWidgets(
    'dirty back asks once, cancellation preserves edits, discard leaves',
    (t) async {
      await host(t, form());
      await t.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '25,50',
      );
      await t.pump();
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tap(t, 'Düzenlemeye dön');
      expect(find.text('25,50'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await tap(t, 'Vazgeç ve çık');
      expect(find.text('Aç'), findsOneWidget);
      verifyNever(
        () => repo.saveListing(any(), any(), existing: any(named: 'existing')),
      );
    },
  );
  testWidgets('shop conflict uses reviewed timestamp and preserves draft', (
    t,
  ) async {
    final fresh = shop.copyWith(
      name: 'Diğer cihaz',
      updatedAt: DateTime.utc(2026, 10, 17),
    );
    when(
      () => repo.loadAccess(),
    ).thenAnswer((_) async => Right(MerchantAccess(user: user, shop: fresh)));
    await host(
      t,
      MerchantShopForm(repository: repo, access: access, onSaved: () {}),
    );
    await t.enterText(
      find.widgetWithText(TextFormField, 'Mağaza adı'),
      'Benim taslağım',
    );
    await tap(t, 'Mağazayı kaydet');
    await tap(t, 'Güncel kaydı kontrol et');
    await tap(t, 'Taslağımı bu kayıt üzerinde düzenle');
    await tap(t, 'Mağazayı kaydet');
    final calls = verify(() => repo.saveShop(captureAny(), any())).captured;
    expect(calls, hasLength(2));
    expect((calls.last as MerchantAccess).shop!.updatedAt, fresh.updatedAt);
    expect(find.text('Benim taslağım'), findsOneWidget);
  });
  testWidgets('onboarding lost response does not insert another shop', (
    t,
  ) async {
    var done = 0;
    final fresh = shop.copyWith(name: 'Yeni mağaza');
    when(
      () => repo.loadAccess(),
    ).thenAnswer((_) async => Right(MerchantAccess(user: user, shop: fresh)));
    await host(
      t,
      MerchantShopForm(
        repository: repo,
        access: MerchantAccess(user: user),
        onSaved: () => done++,
      ),
    );
    await t.enterText(
      find.widgetWithText(TextFormField, 'Mağaza adı'),
      'Yeni mağaza',
    );
    await tap(t, 'Mağazayı kaydet');
    await tap(t, 'Güncel kaydı kontrol et');
    await tap(t, 'Güncel kayıtla devam et');
    expect(done, 1);
    verify(() => repo.saveShop(any(), any())).called(1);
  });
  testWidgets(
    'foreign shop recovery reveals no values and cannot rebase draft',
    (t) async {
      when(() => repo.loadAccess()).thenAnswer(
        (_) async => Right(
          MerchantAccess(
            user: user,
            shop: shop.copyWith(ownerUserId: 'other', name: 'SECRET'),
          ),
        ),
      );
      await host(
        t,
        MerchantShopForm(repository: repo, access: access, onSaved: () {}),
      );
      await t.enterText(
        find.widgetWithText(TextFormField, 'Mağaza adı'),
        'Taslak',
      );
      await tap(t, 'Mağazayı kaydet');
      await tap(t, 'Güncel kaydı kontrol et');
      expect(find.textContaining('SECRET'), findsNothing);
      await t.drag(find.byType(ListView).first, const Offset(0, 900));
      await t.pumpAndSettle();
      expect(
        find.text(merchantAccessDenied),
        findsOneWidget,
        reason: t
            .widgetList<Text>(find.byType(Text))
            .map((v) => v.data)
            .join(' | '),
      );
    },
  );
  testWidgets('media refresh failure removes stale mutation controls', (
    t,
  ) async {
    var reads = 0;
    when(() => media.media(access, listing.id)).thenAnswer(
      (_) async => ++reads == 1
          ? const Right(ListingMedia([_image], maxPhotos: 5, maxBytes: 100))
          : const Left('Bağlantı yok'),
    );
    when(
      () => media.changeMedia(access, listing.id, 'retire', imageId: 'image'),
    ).thenAnswer((_) async => const Left('Belirsiz'));
    await host(
      t,
      MerchantListingMedia(
        repository: media,
        access: access,
        listingId: listing.id,
      ),
    );
    await tap(t, 'Kaldır');
    expect(find.text('Kaldır'), findsNothing);
    expect(find.text('Fotoğraf ekle'), findsNothing);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });
  testWidgets(
    'media read timeout exits spinner and retry ignores late response',
    (t) async {
      final gate = Completer<Either<String, ListingMedia>>();
      when(
        () => media.media(access, listing.id),
      ).thenAnswer((_) => gate.future);
      // Host avoids settling a deliberately pending spinner.
      await t.pumpWidget(
        MaterialApp(
          home: MerchantListingMedia(
            repository: media,
            access: access,
            listingId: listing.id,
          ),
        ),
      );
      await t.pump(const Duration(seconds: 16));
      await t.pumpAndSettle();
      expect(find.text(merchantReadTimeout), findsOneWidget);
      when(() => media.media(access, listing.id)).thenAnswer(
        (_) async => const Right(ListingMedia([], maxPhotos: 5, maxBytes: 100)),
      );
      await tap(t, 'Tekrar dene');
      gate.complete(
        const Right(ListingMedia([_image], maxPhotos: 5, maxBytes: 100)),
      );
      await t.pumpAndSettle();
      expect(find.text('Ana fotoğraf'), findsNothing);
      expect(find.textContaining('0 / 5'), findsOneWidget);
    },
  );
  testWidgets(
    'submission retry retains exact id and payload after lost response',
    (t) async {
      when(() => media.categories(access)).thenAnswer(
        (_) async => const Right([CatalogCategory('c', 'Kategori')]),
      );
      when(
        () => media.lookup(access, any(), any()),
      ).thenAnswer((_) async => const Right(CatalogLookup([])));
      when(
        () => media.submit(access, any(), any()),
      ).thenAnswer((_) async => const Left('Belirsiz'));
      await host(
        t,
        MerchantProductSubmission(
          catalog: media,
          repository: repo,
          access: access,
          initialName: 'Yeni ürün',
        ),
      );
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await t.ensureVisible(dropdown);
      await t.tap(dropdown);
      await t.pumpAndSettle();
      await t.tap(find.text('Kategori').last);
      await t.pumpAndSettle();
      await tap(t, 'İncelemeye gönder');
      await tap(t, 'Aynı başvuruyu tekrar kontrol et');
      final values = verify(
        () => media.submit(access, captureAny(), captureAny()),
      ).captured;
      expect(values, hasLength(4));
      expect(values[0], values[2]);
      expect(identical(values[1], values[3]), true);
      verify(() => media.lookup(access, any(), any())).called(1);
    },
  );
  test(
    'catalog timeout does not append late page after fresh search',
    () async {
      final gate = Completer<Either<String, List<ShopProductEntity>>>();
      when(
        () => repo.listings(access, page: 0, query: ''),
      ).thenAnswer((_) => gate.future);
      when(
        () => repo.listings(access, page: 0, query: 'new'),
      ).thenAnswer((_) async => const Right([]));
      final cubit = MerchantCatalogCubit(repo, access);
      final old = cubit.load();
      await cubit.load(refresh: true, query: 'new');
      gate.complete(Right([listing]));
      await old;
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.query, 'new');
      await cubit.close();
    },
  );
  testWidgets(
    'confirmed catalog match survives returning from add form without uncertain copy',
    (t) async {
      when(() => media.categories(access)).thenAnswer(
        (_) async => const Right([CatalogCategory('c', 'Kategori')]),
      );
      when(
        () => media.lookup(access, any(), any()),
      ).thenAnswer((_) async => const Right(CatalogLookup([])));
      when(() => media.submit(access, any(), any())).thenAnswer(
        (_) async => const Right(SubmissionResult(existing: _product)),
      );
      await host(
        t,
        MerchantProductSubmission(
          catalog: media,
          repository: repo,
          access: access,
          initialName: 'Yeni ürün',
        ),
      );
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await t.ensureVisible(dropdown);
      await t.tap(dropdown);
      await t.pumpAndSettle();
      await t.tap(find.text('Kategori').last);
      await t.pumpAndSettle();
      await tap(t, 'İncelemeye gönder');
      expect(find.byType(MerchantListingForm), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Mevcut ürünü mağazama ekle'), findsOneWidget);
      expect(find.textContaining('Başvuru sonucu doğrulanamadı'), findsNothing);
      verify(() => media.submit(access, any(), any())).called(1);
    },
  );
  testWidgets(
    'category timeout is not an empty success and retry rejects late categories',
    (t) async {
      final gate = Completer<Either<String, List<CatalogCategory>>>();
      when(() => media.categories(access)).thenAnswer((_) => gate.future);
      await t.pumpWidget(
        MaterialApp(
          home: MerchantProductSubmission(
            catalog: media,
            repository: repo,
            access: access,
          ),
        ),
      );
      await t.pump(const Duration(seconds: 16));
      await t.pumpAndSettle();
      expect(find.text(merchantReadTimeout), findsOneWidget);
      expect(
        find.text('Şu anda başvuruya açık kategori bulunmuyor.'),
        findsNothing,
      );
      when(() => media.categories(access)).thenAnswer(
        (_) async => const Right([CatalogCategory('new', 'Yeni kategori')]),
      );
      await tap(t, 'Tekrar dene');
      gate.complete(const Right([CatalogCategory('old', 'Eski kategori')]));
      await t.pumpAndSettle();
      final widget = t.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(widget, isNotNull);
      expect(find.text('Eski kategori'), findsNothing);
    },
  );
  testWidgets(
    'authority loss removes dirty confirmation and cannot return to old draft',
    (t) async {
      final preview = MerchantPreview();
      await t.pumpWidget(MerchantApp(services: preview.services));
      await t.pumpAndSettle();
      await t.tap(find.text('Ürünler'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tam yağlı süt 1 L'));
      await t.pumpAndSettle();
      await t.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '123,45',
      );
      await t.pump();
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      preview.currentId = null;
      preview.changes.add(null);
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('123,45'), findsNothing);
      expect(find.text('Giriş yap'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await preview.dispose();
    },
  );
  testWidgets('double catalog selection opens one editor', (t) async {
    when(
      () => repo.searchCatalog(access, query: '', page: 0),
    ).thenAnswer((_) async => const Right([_product]));
    await host(t, MerchantCatalogPicker(repository: repo, access: access));
    final tile = t.widget<ListTile>(
      find.widgetWithText(ListTile, 'Örnek ürün'),
    );
    tile.onTap!();
    tile.onTap!();
    await t.pumpAndSettle();
    expect(
      find.byType(MerchantListingForm, skipOffstage: false),
      findsOneWidget,
    );
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.byType(MerchantCatalogPicker), findsOneWidget);
  });
  for (final width in [320.0, 390.0, 430.0]) {
    for (final matching in [false, true]) {
      testWidgets('recovery at ${width.toInt()} scaled text matching=$matching', (
        t,
      ) async {
        when(
          () => repo.readListing(access, listing.productId),
        ).thenAnswer((_) async => Right(current(price: matching ? 25.5 : 35)));
        await host(t, form(), width: width, scale: 1.3);
        await edit(t);
        await tap(t, 'Güncel kaydı kontrol et');
        await t.ensureVisible(find.text('Kayıt durumunu kontrol et'));
        await t.pumpAndSettle();
        await t.pump(const Duration(milliseconds: 200));
        final position = Scrollable.of(
          t.element(find.text('Kayıt durumunu kontrol et')),
        ).position;
        position.jumpTo(0);
        await t.pumpAndSettle();
        expect(position.pixels, 0);
        expect(
          t.getTopLeft(find.text('Kayıt durumunu kontrol et')).dy,
          greaterThan(50),
        );
        expect(t.takeException(), isNull);
        if (const bool.fromEnvironment('CAPTURE_MERCHANT_RECOVERY')) {
          final boundary = t.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('capture')),
          );
          boundary.markNeedsPaint();
          await t.pump();
          await t.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'docs/evidence/merchant_catalog_recovery/${matching ? 'matched' : 'conflict'}-${width.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
