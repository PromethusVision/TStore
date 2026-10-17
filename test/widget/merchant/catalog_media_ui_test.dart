import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class CatalogMock extends Mock implements CatalogMediaRepository {}

class MerchantMock extends Mock implements MerchantRepository {}

const product = ProductEntity(
  id: 'p',
  name: 'Katalog kalemi',
  price: 5,
  categoryId: 'c',
  stock: 0,
  images: [],
);
const image = ListingImage(
  id: 'i',
  path: 'path',
  state: 'published',
  primary: true,
  order: 0,
);
const image2 = ListingImage(
  id: 'j',
  path: 'path2',
  state: 'published',
  primary: false,
  order: 1,
);
void main() {
  late CatalogMock repo;
  late MerchantMock merchant;
  late MerchantAccess access;
  setUpAll(() async {
    registerFallbackValue(
      const ProductSubmissionDraft(name: 'name', categoryId: 'id'),
    );
    registerFallbackValue(Uint8List(0));
    final fonts = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([fonts.load(), icons.load()]);
  });
  setUp(() async {
    access = (await MerchantPreview().repository.loadAccess()).getOrElse(
      () => null,
    )!;
    repo = CatalogMock();
    merchant = MerchantMock();
    when(
      () => repo.categories(access),
    ).thenAnswer((_) async => const Right([CatalogCategory('c', 'Kategori')]));
    when(
      () => repo.lookup(access, any(), any()),
    ).thenAnswer((_) async => const Right(CatalogLookup([])));
    when(() => repo.media(access, 'l')).thenAnswer(
      (_) async => const Right(
        ListingMedia([image, image2], maxPhotos: 2, maxBytes: 8000000),
      ),
    );
  });
  Future<void> host(
    WidgetTester tester,
    Widget child, {
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(scale),
          ),
          child: RepaintBoundary(key: const Key('screen'), child: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget submission() => MerchantProductSubmission(
    catalog: repo,
    repository: merchant,
    access: access,
    initialName: 'Yeni ürün',
  );
  Future<void> category(WidgetTester tester) async {
    final f = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kategori').last);
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    final f = find.widgetWithText(FilledButton, 'İncelemeye gönder');
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('new submission form matches merchant visual language at 390px', (
    tester,
  ) async {
    await host(tester, submission());
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('screen')),
      matchesGoldenFile('goldens/slice_a_submission_390.png'),
    );
  });
  testWidgets('invalid GTIN prevents lookup and submission', (tester) async {
    await host(tester, submission());
    await category(tester);
    final field = find.widgetWithText(
      TextFormField,
      'Barkod / GTIN (isteğe bağlı)',
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, '123');
    await send(tester);
    expect(find.text('Geçerli bir barkod girin.'), findsOneWidget);
    verifyNever(() => repo.lookup(access, any(), any()));
    verifyNever(() => repo.submit(access, any(), any()));
  });
  testWidgets(
    'exact GTIN offers existing listing and cannot bypass with new candidate',
    (tester) async {
      when(() => repo.lookup(access, any(), any())).thenAnswer(
        (_) async => const Right(CatalogLookup([product], exact: true)),
      );
      await host(tester, submission());
      await category(tester);
      await send(tester);
      expect(find.text('Katalog kalemi'), findsOneWidget);
      expect(find.text('Farklı bir ürün; başvuruyla devam et'), findsNothing);
      verifyNever(() => repo.submit(access, any(), any()));
    },
  );
  testWidgets(
    'ambiguous suggestions require explicit continue; duplicate submit locked',
    (tester) async {
      when(
        () => repo.lookup(access, any(), any()),
      ).thenAnswer((_) async => const Right(CatalogLookup([product])));
      final gate = Completer<Either<String, SubmissionResult>>();
      when(
        () => repo.submit(access, any(), any()),
      ).thenAnswer((_) => gate.future);
      await host(tester, submission());
      await category(tester);
      await send(tester);
      verifyNever(() => repo.submit(access, any(), any()));
      final button = find.widgetWithText(
        OutlinedButton,
        'Farklı bir ürün; başvuruyla devam et',
      );
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      await tester.tap(button);
      await tester.pump();
      verify(() => repo.submit(access, any(), any())).called(1);
      gate.complete(const Left('Geçici bağlantı sorunu'));
      await tester.pumpAndSettle();
      expect(find.text('Geçici bağlantı sorunu'), findsOneWidget);
    },
  );
  testWidgets('pending approved rejected status and approved listing handoff', (
    tester,
  ) async {
    when(() => repo.submissions(access)).thenAnswer(
      (_) async => const Right([
        ProductSubmission(id: 'a', name: 'A', status: 'pending'),
        ProductSubmission(
          id: 'b',
          name: 'B',
          status: 'approved',
          productId: 'p',
        ),
        ProductSubmission(
          id: 'c',
          name: 'C',
          status: 'rejected',
          reason: 'Gerekçe',
        ),
      ]),
    );
    when(
      () => repo.approvedProduct(access, 'p'),
    ).thenAnswer((_) async => const Right(product));
    await host(
      tester,
      MerchantSubmissions(catalog: repo, repository: merchant, access: access),
    );
    expect(find.text('İnceleniyor'), findsOneWidget);
    expect(find.text('Onaylandı'), findsOneWidget);
    expect(find.text('Reddedildi\nGerekçe'), findsOneWidget);
    await tester.tap(find.text('Mağazama ekle'));
    await tester.pumpAndSettle();
    expect(find.byType(MerchantListingForm), findsOneWidget);
    expect(find.text('Katalog kalemi'), findsOneWidget);
  });
  testWidgets('media server cap, primary, reorder and retire controls', (
    tester,
  ) async {
    when(
      () => repo.changeMedia(
        access,
        'l',
        any(),
        imageId: any(named: 'imageId'),
        order: any(named: 'order'),
      ),
    ).thenAnswer((_) async => const Right(null));
    await host(
      tester,
      MerchantListingMedia(repository: repo, access: access, listingId: 'l'),
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Fotoğraf ekle'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Ana fotoğraf yap'));
    await tester.pumpAndSettle();
    verify(
      () => repo.changeMedia(access, 'l', 'primary', imageId: 'j'),
    ).called(1);
    await tester.tap(find.byTooltip('Yukarı taşı').last);
    await tester.pumpAndSettle();
    verify(
      () => repo.changeMedia(access, 'l', 'reorder', order: ['j', 'i']),
    ).called(1);
    await tester.tap(find.text('Kaldır').first);
    await tester.pumpAndSettle();
    verify(
      () => repo.changeMedia(access, 'l', 'retire', imageId: 'i'),
    ).called(1);
  });
  testWidgets(
    'media upload only once while pending and recovers after failure',
    (tester) async {
      when(() => repo.media(access, 'l')).thenAnswer(
        (_) async => const Right(ListingMedia([], maxPhotos: 2, maxBytes: 100)),
      );
      final gate = Completer<Either<String, void>>();
      when(
        () => repo.upload(access, 'l', any()),
      ).thenAnswer((_) => gate.future);
      await host(
        tester,
        MerchantListingMedia(
          repository: repo,
          access: access,
          listingId: 'l',
          pickImage: () async => XFile.fromData(
            Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
          ),
        ),
      );
      final button = find.text('Fotoğraf ekle');
      await tester.tap(button);
      await tester.pump();
      await tester.tap(button);
      await tester.pump();
      verify(() => repo.upload(access, 'l', any())).called(1);
      gate.complete(const Left('Yüklenemedi'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Yüklenemedi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'category loading errors can retry; unavailable categories stay truthful',
    (tester) async {
      when(
        () => repo.categories(access),
      ).thenAnswer((_) async => const Left('Kategori yüklenemedi'));
      await host(tester, submission());
      expect(find.text('Kategori yüklenemedi'), findsOneWidget);
      expect(
        find.text('Şu anda başvuruya açık kategori bulunmuyor.'),
        findsNothing,
      );
      when(
        () => repo.categories(access),
      ).thenAnswer((_) async => const Right([]));
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(
        find.text('Şu anda başvuruya açık kategori bulunmuyor.'),
        findsOneWidget,
      );
    },
  );
  testWidgets('large text has no overflow in new form', (tester) async {
    await host(tester, submission(), scale: 1.5);
    await category(tester);
    expect(tester.takeException(), isNull);
  });
  testWidgets('catalog barcode search reuses exact existing product flow', (
    tester,
  ) async {
    when(
      () => merchant.searchCatalog(access, query: '', page: 0),
    ).thenAnswer((_) async => const Right([]));
    when(() => repo.lookup(access, '', '4006381333931')).thenAnswer(
      (_) async => const Right(CatalogLookup([product], exact: true)),
    );
    await host(
      tester,
      MerchantCatalogPicker(
        repository: merchant,
        access: access,
        catalogMedia: repo,
      ),
    );
    await tester.enterText(find.byType(TextField), '4006381333931');
    await tester.tap(find.byTooltip('Ara'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog kalemi'), findsOneWidget);
    await tester.tap(find.text('Katalog kalemi'));
    await tester.pumpAndSettle();
    expect(find.byType(MerchantListingForm), findsOneWidget);
    verifyNever(() => repo.submit(access, any(), any()));
  });
}
