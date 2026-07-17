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
