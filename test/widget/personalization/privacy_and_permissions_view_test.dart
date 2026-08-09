import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/personalization/presentation/views/privacy_and_permissions_view.dart';

void main() {
  Widget buildSubject(CustomerLocationPermissionLoader permissionLoader) {
    return MaterialApp(
      home: PrivacyAndPermissionsView(
        locationPermissionLoader: permissionLoader,
      ),
    );
  }

  testWidgets('izin okunurken konum istemeden loading durumu gösterir', (
    tester,
  ) async {
    final permissionResult = Completer<CustomerLocationPermissionStatus>();
    var callCount = 0;

    await tester.pumpWidget(
      buildSubject(() {
        callCount++;
        return permissionResult.future;
      }),
    );

    expect(find.byKey(const Key('customer-privacy-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-privacy-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-privacy-hero')), findsOneWidget);
    expect(find.byKey(const Key('customer-privacy-scroll')), findsOneWidget);
    expect(callCount, 1);
    expect(find.text('İzin durumu kontrol ediliyor'), findsOneWidget);
    expect(
      find.byKey(const Key('location-permission-progress')),
      findsOneWidget,
    );

    final refreshButton = tester.widget<IconButton>(
      find.byKey(const Key('location-permission-refresh')),
    );
    expect(refreshButton.onPressed, isNull);

    permissionResult.complete(CustomerLocationPermissionStatus.allowed);
    await tester.pumpAndSettle();

    expect(find.text('İzin verildi'), findsOneWidget);
    expect(callCount, 1);
  });

  testWidgets(
    'konum izni kapalıyken güvenli açıklama ve yönetim yolunu gösterir',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(() async => CustomerLocationPermissionStatus.notAllowed),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kapalı veya henüz verilmedi'), findsOneWidget);
      expect(
        find.textContaining('Konum izni olmadan da mağazaları görebilirsin'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.textContaining('Chrome’da adres çubuğundaki site ayarlarından'),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.textContaining('Android veya iOS’ta'), findsOneWidget);
    },
  );

  testWidgets('GPS ve kayıtlı konum kullanımını birbirinden ayırır', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(() async => CustomerLocationPermissionStatus.allowed),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Konumunu nasıl kullanıyoruz?'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Yalnızca sen istediğinde'), findsOneWidget);
    expect(
      find.textContaining('Bu sayfayı açmak konumunu almaz'),
      findsOneWidget,
    );
    expect(find.text('Kaydetmeyi sen seçersin'), findsOneWidget);
    expect(
      find.textContaining('koordinatları hesabında saklanır'),
      findsOneWidget,
    );
    expect(find.textContaining('arka planda takip edilmez'), findsOneWidget);
  });

  testWidgets('izin durumu okunamazsa hata gösterir ve tekrar dener', (
    tester,
  ) async {
    var callCount = 0;

    await tester.pumpWidget(
      buildSubject(() async {
        callCount++;
        if (callCount == 1) throw StateError('permission unavailable');
        return CustomerLocationPermissionStatus.blocked;
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('İzin durumu alınamadı'), findsOneWidget);
    expect(find.textContaining('yeni bir izin istemez'), findsOneWidget);

    await tester.tap(find.byKey(const Key('location-permission-refresh')));
    await tester.pumpAndSettle();

    expect(callCount, 2);
    expect(find.text('Ayarlar üzerinden kapalı'), findsOneWidget);
  });

  testWidgets('KVKK ve kullanım koşulları metinlerini açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(() async => CustomerLocationPermissionStatus.allowed),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('privacy-kvkk-action')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('privacy-kvkk-action')));
    await tester.pumpAndSettle();

    expect(find.text('KVKK Aydınlatma Metni'), findsWidgets);

    await tester.tap(find.byKey(const Key('customer-legal-back')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('privacy-terms-action')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('privacy-terms-action')));
    await tester.pumpAndSettle();

    expect(find.text('Kullanım Koşulları'), findsWidgets);
  });

  for (final document in const [
    (actionKey: Key('privacy-kvkk-action'), title: 'KVKK Aydınlatma Metni'),
    (actionKey: Key('privacy-terms-action'), title: 'Kullanım Koşulları'),
  ]) {
    testWidgets(
      '${document.title} hızlı dokunmada bir kez açılır ve dönüşte yeniden çalışır',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(() async => CustomerLocationPermissionStatus.allowed),
        );
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.byKey(document.actionKey),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        final action = tester.widget<InkWell>(
          find.descendant(
            of: find.byKey(document.actionKey),
            matching: find.byType(InkWell),
          ),
        );
        action.onTap!();
        action.onTap!();
        await tester.pumpAndSettle();

        expect(find.text(document.title), findsWidgets);

        await tester.tap(find.byKey(const Key('customer-legal-back')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('customer-privacy-content')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('customer-legal-back')), findsNothing);

        await tester.scrollUntilVisible(
          find.byKey(document.actionKey),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(document.actionKey));
        await tester.pumpAndSettle();

        expect(find.text(document.title), findsWidgets);
      },
    );
  }

  testWidgets('dar ekranda taşmadan aşağı kaydırılabilir', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildSubject(() async => CustomerLocationPermissionStatus.allowed),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Uygulamadaki bilgilerin'), findsOneWidget);
  });
}
