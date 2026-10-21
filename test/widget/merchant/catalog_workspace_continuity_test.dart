import 'dart:async';
import 'dart:typed_data';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_session_identity.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';

class _Catalog extends Fake implements CatalogMediaRepository {
  int uploads = 0, submits = 0, reads = 0;
  final mutation = Completer<Either<String, void>>();
  bool published = false;
  final lookupResult = Completer<Either<String, CatalogLookup>>();
  @override
  Future<Either<String, ListingMedia>> media(
    MerchantAccess a,
    String id,
  ) async {
    reads++;
    return Right(
      ListingMedia(
        published
            ? const [
                ListingImage(
                  id: 'photo',
                  path: 'path',
                  state: 'published',
                  primary: true,
                  order: 0,
                ),
              ]
            : const [],
        maxPhotos: 5,
        maxBytes: 100,
      ),
    );
  }

  @override
  Future<Either<String, void>> changeMedia(
    MerchantAccess a,
    String id,
    String action, {
    String? imageId,
    List<String>? order,
  }) => mutation.future;

  @override
  Future<Either<String, void>> upload(
    MerchantAccess a,
    String id,
    Uint8List b,
  ) async {
    uploads++;
    return const Right(null);
  }

  @override
  Future<Either<String, List<CatalogCategory>>> categories(
    MerchantAccess a,
  ) async => const Right([CatalogCategory('category', 'Kategori')]);
  @override
  Future<Either<String, CatalogLookup>> lookup(
    MerchantAccess a,
    String n,
    String g,
  ) => lookupResult.future;
  @override
  Future<Either<String, SubmissionResult>> submit(
    MerchantAccess a,
    String id,
    ProductSubmissionDraft d,
  ) async {
    submits++;
    return const Left('Synthetic uncertain acknowledgement');
  }
}

class _PickedFile extends Fake implements XFile {
  _PickedFile(this.phase);
  final String phase;
  final size = Completer<int>();
  final bytes = Completer<Uint8List>();
  static final png = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
  @override
  Future<int> length() async =>
      phase == 'gallery-size' ? size.future : png.length;
  @override
  Future<Uint8List> readAsBytes() async =>
      phase == 'gallery-bytes' ? bytes.future : png;
}

class _Merchant extends PreviewMerchantRepository {
  _Merchant(super.host) : super(hasShop: true, empty: false);
  final saved = Completer<Either<String, ShopEntity>>();
  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess a,
    MerchantShopDraft d,
  ) => saved.future;
}

void main() {
  for (final change in ['replacement', 'monitor-error', 'renew']) {
    for (final journey in [
      'gallery',
      'gallery-size',
      'gallery-bytes',
      'media-write',
      'submission',
      'profile',
    ]) {
      testWidgets('$journey continuation before next frame respects $change', (
        t,
      ) async {
        final preview = MerchantPreview();
        final merchant = _Merchant(preview);
        final catalog = _Catalog();
        catalog.published = journey == 'media-write';
        final signals = StreamController<MerchantSessionIdentity>.broadcast(
          sync: true,
        );
        var key = 'S1';
        final services = MerchantServices(
          merchants: merchant,
          credentials: preview.services.credentials,
          notifications: preview.services.notifications,
          qr: preview.services.qr,
          preferences: preview.services.preferences,
          sessionChanges: preview.changes.stream,
          currentUserId: () => preview.currentId,
          currentSessionKey: () => key,
          sessionIdentities: signals.stream,
          preview: true,
        );
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(() async {
          await t.pumpWidget(const SizedBox());
          await t.runAsync(() async {
            await signals.close();
            await preview.changes.close();
            await preview.notifications.events.close();
          });
          t.view.resetPhysicalSize();
          t.view.resetDevicePixelRatio();
        });
        await t.pumpWidget(MerchantApp(services: services));
        await t.pumpAndSettle();
        final access = (await merchant.loadAccess()).getOrElse(() => null)!;
        final picker = Completer<XFile?>();
        final file = _PickedFile(journey);
        var onSaved = 0;
        final page = switch (journey) {
          'gallery' ||
          'gallery-size' ||
          'gallery-bytes' ||
          'media-write' => MerchantListingMedia(
            repository: catalog,
            access: access,
            listingId: 'listing',
            pickImage: () => picker.future,
          ),
          'submission' => MerchantProductSubmission(
            catalog: catalog,
            repository: merchant,
            access: access,
            initialName: 'Yeni ürün',
          ),
          _ => MerchantShopForm(
            repository: merchant,
            access: access,
            onSaved: () => onSaved++,
          ),
        };
        final context = t.element(
          find.byType(MerchantProducts, skipOffstage: false),
        );
        Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (_) => page));
        await t.pumpAndSettle();
        if (journey == 'submission') {
          final category = find.byType(DropdownButtonFormField<String>);
          await t.ensureVisible(category);
          await t.tap(category);
          await t.pumpAndSettle();
          await t.tap(find.text('Kategori').last);
          await t.pumpAndSettle();
        }
        final label = switch (journey) {
          'gallery' || 'gallery-size' || 'gallery-bytes' => 'Fotoğraf ekle',
          'media-write' => 'Kaldır',
          'submission' => 'İncelemeye gönder',
          _ => 'Mağazayı kaydet',
        };
        await t.scrollUntilVisible(
          find.text(label),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await t.tap(find.text(label));
        await t.pump();
        if (journey == 'gallery-size' || journey == 'gallery-bytes') {
          picker.complete(file);
          await t.idle();
        }
        void signal() => signals.add(
          MerchantSessionIdentity(userId: preview.currentId, sessionKey: key),
        );
        if (change == 'monitor-error') {
          signals.addError(StateError('synthetic monitor loss'));
        } else {
          if (change == 'replacement') {
            key = 'S2';
            signal();
            key = 'S1';
          }
          signal();
        }
        // Deliberately drain asynchronous callbacks without rendering the
        // scheduled host replacement. mounted alone is still true here.
        await t.idle();
        if (journey == 'gallery') {
          picker.complete(file);
        } else if (journey == 'gallery-size') {
          file.size.complete(8);
        } else if (journey == 'gallery-bytes') {
          file.bytes.complete(_PickedFile.png);
        } else if (journey == 'media-write') {
          catalog.mutation.complete(const Left('synthetic uncertain write'));
        } else if (journey == 'submission') {
          catalog.lookupResult.complete(const Right(CatalogLookup([])));
        } else {
          merchant.saved.complete(Right(access.shop!));
        }
        await t.idle();
        final continued = switch (journey) {
          'gallery' || 'gallery-size' || 'gallery-bytes' => catalog.uploads,
          'media-write' => catalog.reads - 1,
          'submission' => catalog.submits,
          _ => onSaved,
        };
        expect(continued, change == 'renew' ? 1 : 0);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  }
}
