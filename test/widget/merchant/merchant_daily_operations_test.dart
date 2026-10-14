import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_dashboard.dart';
import 'package:t_store/features/merchant/presentation/merchant_pending_uploads.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'merchant_v1_test.dart' show tab, saveListing;

class Operations extends Mock implements MerchantOperationsRepository {}

class Media extends Mock implements CatalogMediaRepository {}

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
  late MerchantPreview preview;
  late MerchantAccess access;
  late Operations ops;
  late Media media;
  setUp(() {
    preview = MerchantPreview(empty: true);
    access = MerchantAccess(user: preview.user, shop: preview.repository.shop);
    ops = Operations();
    media = Media();
    registerFallbackValue(access);
    when(() => ops.read(any())).thenAnswer(
      (_) async => const Right(
        MerchantOperations(
          pendingSubmissions: 105,
          approvedSubmissions: 2,
          rejectedSubmissions: 1,
          pendingListings: 1,
          uploads: [
            PendingListingUpload('listing-a', 'Yarım fotoğraflı ürün', 2),
          ],
        ),
      ),
    );
    when(
      () => media.submissions(any()),
    ).thenAnswer((_) async => const Right([]));
    when(() => media.media(any(), 'listing-a')).thenAnswer(
      (_) async => const Right(
        ListingMedia(
          [
            ListingImage(
              id: 'image',
              path: 'local',
              state: 'pending',
              primary: false,
              order: 0,
            ),
          ],
          maxPhotos: 6,
          maxBytes: 8388608,
        ),
      ),
    );
  });
  tearDown(() async {
    await preview.dispose();
  });
  Future<void> host(WidgetTester tester) async {
    final s = preview.services;
    await tester.pumpWidget(
      MerchantApp(
        services: MerchantServices(
          merchants: s.merchants,
          credentials: s.credentials,
          notifications: s.notifications,
          qr: s.qr,
          preferences: s.preferences,
          sessionChanges: s.sessionChanges,
          currentUserId: s.currentUserId,
          preview: true,
          catalogMedia: media,
          operations: ops,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> show(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(
      find.text(label),
      350,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 100,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dashboard quick add refreshes counts and product list; survives widget restart',
    (tester) async {
      await host(tester);
      await show(tester, 'Katalogdan ürün ekle');
      await tester.tap(find.text('Katalogdan ürün ekle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mağaza fiyatı (TL)'),
        '24,50',
      );
      await saveListing(tester);
      expect(preview.repository.items.single.price, 24.5);
      expect(find.byType(MerchantDashboard), findsOneWidget);
      await tab(tester, 'Ürünler');
      expect(find.text('Tam yağlı süt 1 L'), findsOneWidget);
      await tester.tap(find.text('Tam yağlı süt 1 L'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(SwitchListTile, 'Stokta var'),
      );
      await tester.tap(find.widgetWithText(SwitchListTile, 'Stokta var'));
      await saveListing(tester);
      await tab(tester, 'Özet');
      expect(preview.repository.items.single.isAvailable, false);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await host(tester);
      await tab(tester, 'Ürünler');
      expect(find.textContaining('24,50 TL\nStokta yok'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'real status totals and pending upload route refresh after recovery',
    (tester) async {
      await host(tester);
      await show(tester, 'Takip edilecek işlemler');
      expect(
        find.text('İnceleniyor: 105 • Onaylandı: 2 • Reddedildi: 1'),
        findsOneWidget,
      );
      await show(tester, 'Yarım fotoğraflı ürün');
      await tester.tap(find.text('Yarım fotoğraflı ürün'));
      await tester.pumpAndSettle();
      expect(find.text('Yükleme tamamlanmadı'), findsOneWidget);
      when(
        () => media.changeMedia(any(), 'listing-a', 'retire', imageId: 'image'),
      ).thenAnswer((_) async {
        when(() => media.media(any(), 'listing-a')).thenAnswer(
          (_) async =>
              const Right(ListingMedia([], maxPhotos: 6, maxBytes: 8388608)),
        );
        when(
          () => ops.read(any()),
        ).thenAnswer((_) async => const Right(MerchantOperations()));
        return const Right(null);
      });
      await tester.tap(find.text('Kaldır'));
      await tester.pumpAndSettle();
      expect(find.text('0 / 6 fotoğraf • JPEG, PNG, WebP'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await show(tester, 'Takip edilecek işlemler');
      expect(
        find.text('Yarım kalan fotoğraf yüklemesi: 0 ürün'),
        findsOneWidget,
      );
      await show(tester, 'Ürün başvurularım');
      await tester.tap(find.text('Ürün başvurularım'));
      await tester.pumpAndSettle();
      expect(find.text('Henüz ürün başvurun yok.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'failed operations do not hide product actions or claim zero; retry recovers',
    (tester) async {
      when(
        () => ops.read(any()),
      ).thenAnswer((_) async => const Left('İşlem özeti alınamadı.'));
      await host(tester);
      await show(tester, 'İşlem özeti alınamadı.');
      expect(
        find.textContaining('Yarım kalan fotoğraf yüklemesi: 0'),
        findsNothing,
      );
      expect(find.byType(MerchantDashboard), findsOneWidget);
      when(
        () => ops.read(any()),
      ).thenAnswer((_) async => const Right(MerchantOperations()));
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(
        find.text('Yarım kalan fotoğraf yüklemesi: 0 ürün'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'newer refresh wins over slow old response and logout removes private state',
    (tester) async {
      final slow = Completer<Either<String, MerchantOperations>>();
      when(() => ops.read(any())).thenAnswer((_) => slow.future);
      await host(
        tester,
      ); // Operations loading is non-animated, actions remain usable.
      when(() => ops.read(any())).thenAnswer(
        (_) async => const Right(MerchantOperations(pendingSubmissions: 7)),
      );
      await tester.tap(find.byTooltip('Özeti yenile'));
      await tester.pumpAndSettle();
      slow.complete(const Right(MerchantOperations(pendingSubmissions: 999)));
      await tester.pumpAndSettle();
      await show(tester, 'Takip edilecek işlemler');
      expect(find.textContaining('İnceleniyor: 7'), findsOneWidget);
      expect(find.textContaining('999'), findsNothing);
      preview.currentId = null;
      preview.changes.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(MerchantDashboard), findsNothing);
      expect(find.text('Giriş yap'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'one inbox filters other identities and shares read state with overview',
    (tester) async {
      await host(tester);
      preview.notifications.events.add(
        const NotificationEntity(
          id: 'merchant-new',
          userId: MerchantPreview.userId,
          title: 'Başvurun güncellendi',
          body: 'Bildirim ayrıntısı',
          type: NotificationType.system,
          data: {'app_role': 'merchant'},
        ),
      );
      preview.notifications.events.add(
        const NotificationEntity(
          id: 'customer-new',
          userId: MerchantPreview.userId,
          title: 'Müşteriye özel',
          body: 'Gizli',
          type: NotificationType.system,
          data: {'app_role': 'customer'},
        ),
      );
      await tester.pumpAndSettle();
      await show(tester, 'Son bildirimler');
      expect(find.text('Başvurun güncellendi'), findsOneWidget);
      expect(find.text('Müşteriye özel'), findsNothing);
      // Preview persistence mirrors the same inbox when tab selection refreshes it.
      preview.notifications.items = [
        const NotificationEntity(
          id: 'merchant-new',
          userId: MerchantPreview.userId,
          title: 'Başvurun güncellendi',
          body: 'Bildirim ayrıntısı',
          type: NotificationType.system,
          data: {'app_role': 'merchant'},
        ),
      ];
      await show(tester, 'Bildirim merkezini aç');
      await tester.tap(find.text('Bildirim merkezini aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Başvurun güncellendi'));
      await tester.pumpAndSettle();
      expect(preview.notifications.items.single.isRead, true);
      await tab(tester, 'Özet');
      await show(tester, 'Son bildirimler');
      expect(find.byIcon(Icons.notifications_active_outlined), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('pending recovery paginates and refreshes removed entries', (
    tester,
  ) async {
    when(() => ops.read(any(), page: 0)).thenAnswer(
      (_) async => Right(
        MerchantOperations(
          pendingListings: 21,
          uploads: List.generate(
            20,
            (i) => PendingListingUpload('l$i', 'Ürün $i', 1),
          ),
        ),
      ),
    );
    when(() => ops.read(any(), page: 1)).thenAnswer(
      (_) async => const Right(
        MerchantOperations(
          pendingListings: 21,
          uploads: [PendingListingUpload('l20', 'Son ürün', 1)],
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: MerchantPendingUploads(
          operations: ops,
          media: media,
          access: access,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await show(tester, 'Daha fazla ürün');
    await tester.tap(find.text('Daha fazla ürün'));
    await tester.pumpAndSettle();
    expect(find.text('Son ürün'), findsOneWidget);
    expect(find.text('Daha fazla ürün'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('all submissions are reachable beyond 100', (tester) async {
    when(() => media.submissions(any())).thenAnswer(
      (_) async => Right(
        List.generate(
          100,
          (i) => ProductSubmission(
            id: 's$i',
            name: 'Başvuru $i',
            status: 'pending',
          ),
        ),
      ),
    );
    when(() => media.submissions(any(), page: 1)).thenAnswer(
      (_) async => const Right([
        ProductSubmission(
          id: 'last',
          name: 'Son başvuru',
          status: 'rejected',
          reason: 'Eksik bilgi',
        ),
      ]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MerchantSubmissions(
          catalog: media,
          repository: preview.repository,
          access: access,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await show(tester, 'Daha fazla başvuru');
    await tester.tap(find.text('Daha fazla başvuru'));
    await tester.pumpAndSettle();
    expect(find.text('Son başvuru'), findsOneWidget);
    expect(find.text('Reddedildi\nEksik bilgi'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  for (final width in [320.0, 390.0]) {
    testWidgets('operations section visual and large text at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 932);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      await host(tester);
      await show(tester, 'Takip edilecek işlemler');
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MerchantApp),
        matchesGoldenFile('goldens/daily_operations_${width.toInt()}_130.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
}
