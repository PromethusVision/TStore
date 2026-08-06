import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/personalization/presentation/views/customer_coupons_view.dart';

void main() {
  Widget buildSubject() {
    return const MaterialApp(home: CustomerCouponsView());
  }

  testWidgets('kullanılabilir kuponlar için dürüst boş durum gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-coupons-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-coupons-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-coupons-tab-bar')), findsOneWidget);
    expect(find.text('Kuponlarım'), findsOneWidget);
    expect(find.text('Kullanılabilir'), findsOneWidget);
    expect(find.text('Geçmiş'), findsOneWidget);
    expect(find.text('Henüz kullanılabilir kuponun yok'), findsOneWidget);
    expect(
      find.textContaining('Sana tanımlanan ve kullanıma açılan kuponlar'),
      findsOneWidget,
    );
  });

  testWidgets('geçmiş sekmesi kendi boş durumunu gösterir', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('coupon-history-tab')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('coupon-history-empty-state')), findsOneWidget);
    expect(find.text('Kupon geçmişin boş'), findsOneWidget);
    expect(
      find.textContaining('Kullandığın veya süresi dolan kuponları'),
      findsOneWidget,
    );
    expect(find.text('Henüz kullanılabilir kuponun yok'), findsNothing);
  });

  testWidgets('dar ekranda taşma hatası oluşturmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('customer-coupons-header')), findsOneWidget);

    await tester.tap(find.byKey(const Key('coupon-history-tab')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Kupon geçmişin boş'), findsOneWidget);
  });
}
