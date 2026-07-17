import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/personalization/presentation/views/help_and_support_view.dart';

void main() {
  Widget buildSubject({
    VoidCallback? onOpenPurchases,
    VoidCallback? onOpenMessages,
    VoidCallback? onOpenSavedLocations,
  }) {
    return MaterialApp(
      home: HelpAndSupportView(
        onOpenPurchases: onOpenPurchases ?? () {},
        onOpenMessages: onOpenMessages ?? () {},
        onOpenSavedLocations: onOpenSavedLocations ?? () {},
      ),
    );
  }

  testWidgets('müşteri yardım başlıklarını ve hızlı işlemleri gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Yardım ve Destek'), findsOneWidget);
    expect(find.text('Nasıl yardımcı olabiliriz?'), findsOneWidget);
    expect(find.text('Kargo Bekleme, Esnafta Var.'), findsOneWidget);
    expect(find.text('Hızlı Yardım'), findsOneWidget);
    expect(find.text('Alışverişlerim'), findsOneWidget);
    expect(find.text('Mesajlarım'), findsOneWidget);
    expect(find.text('Kayıtlı Konumlarım'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sık Sorulan Sorular'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Sık Sorulan Sorular'), findsOneWidget);
    expect(find.text('Esnafta Var nasıl çalışır?'), findsOneWidget);
    expect(find.text('Sepet ve QR ne işe yarar?'), findsOneWidget);
    expect(find.text('İade taleplerime nereden ulaşırım?'), findsOneWidget);
  });

  testWidgets('sık sorulan sorunun cevabını açıp kapatır', (tester) async {
    await tester.pumpWidget(buildSubject());

    const answer =
        'Sepetindeki ürünleri mağazada doğrulatmak için “Alışverişi '
        'Doğrula” ekranındaki QR kodu kullanabilirsin. Bu QR kod bir ödeme '
        'yöntemi değildir.';

    await tester.scrollUntilVisible(
      find.text('Sepet ve QR ne işe yarar?'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(answer), findsNothing);

    await tester.tap(find.text('Sepet ve QR ne işe yarar?'));
    await tester.pumpAndSettle();
    expect(find.text(answer), findsOneWidget);

    await tester.tap(find.text('Sepet ve QR ne işe yarar?'));
    await tester.pumpAndSettle();
    expect(find.text(answer), findsNothing);
  });

  testWidgets('hızlı yardım seçenekleri doğru işlemleri çağırır', (
    tester,
  ) async {
    var purchasesCallCount = 0;
    var messagesCallCount = 0;
    var savedLocationsCallCount = 0;

    await tester.pumpWidget(
      buildSubject(
        onOpenPurchases: () => purchasesCallCount++,
        onOpenMessages: () => messagesCallCount++,
        onOpenSavedLocations: () => savedLocationsCallCount++,
      ),
    );

    for (final actionKey in [
      const Key('help-purchases-action'),
      const Key('help-messages-action'),
      const Key('help-saved-locations-action'),
    ]) {
      await tester.ensureVisible(find.byKey(actionKey));
      await tester.tap(find.byKey(actionKey));
      await tester.pump();
    }

    expect(purchasesCallCount, 1);
    expect(messagesCallCount, 1);
    expect(savedLocationsCallCount, 1);
  });

  testWidgets('dar ekranda aşağı kaydırılabilir ve taşma oluşturmaz', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sık Sorulan Sorular'), findsOneWidget);
  });
}
