import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class _LostAcknowledgement extends PreviewMerchantRepository {
  _LostAcknowledgement(super.host) : super(hasShop: true, empty: false);
  int writes = 0;
  @override
  Future<Either<String, ShopProductEntity>> saveListing(
    MerchantAccess access,
    MerchantListingDraft draft, {
    ShopProductEntity? existing,
  }) async {
    writes++;
    await super.saveListing(access, draft, existing: existing);
    return const Left('Kayıt yanıtı alınamadı.');
  }

  @override
  Future<Either<String, ShopEntity>> saveShop(
    MerchantAccess access,
    MerchantShopDraft draft,
  ) async {
    writes++;
    await super.saveShop(access, draft);
    return const Left('Kayıt yanıtı alınamadı.');
  }
}

void main() {
  Future<_LostAcknowledgement> host(WidgetTester tester) async {
    final preview = MerchantPreview();
    final repo = _LostAcknowledgement(preview);
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(preview.dispose);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MerchantApp(
        services: MerchantServices(
          merchants: repo,
          credentials: preview.services.credentials,
          notifications: preview.services.notifications,
          qr: preview.services.qr,
          preferences: preview.services.preferences,
          sessionChanges: preview.changes.stream,
          currentUserId: () => preview.currentId,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vazgeç ve çık'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'leaving an uncertain listing save reloads the authoritative price',
    (tester) async {
      final repo = await host(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ürünler'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '79,25',
      );
      await tester.ensureVisible(find.text('Ürünü kaydet'));
      await tester.tap(find.text('Ürünü kaydet'));
      await tester.pumpAndSettle();
      expect(find.text('Kayıt durumunu kontrol et'), findsOneWidget);
      await leave(tester);
      expect(find.textContaining('79,25'), findsOneWidget);
      expect(repo.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'leaving an uncertain profile save refreshes the workspace identity',
    (tester) async {
      final repo = await host(tester);
      await tester.ensureVisible(find.text('Mağaza bilgilerini düzenle'));
      await tester.tap(find.text('Mağaza bilgilerini düzenle'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mağaza adı'),
        'Yeni mağaza adı',
      );
      await tester.ensureVisible(find.text('Mağazayı kaydet'));
      await tester.tap(find.text('Mağazayı kaydet'));
      await tester.pumpAndSettle();
      expect(find.text('Kayıt durumunu kontrol et'), findsOneWidget);
      await leave(tester);
      expect(find.text('Yeni mağaza adı'), findsOneWidget);
      expect(repo.writes, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
