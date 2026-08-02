import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';

void main() {
  Future<void> pumpSummary(
    WidgetTester tester,
    ProductSellerPriceSummary summary, {
    double width = 390,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ProductSellerPriceSummaryView(summary: summary),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('tek mağaza fiyatını açık biçimde gösterir', (tester) async {
    await pumpSummary(
      tester,
      const ProductSellerPriceSummary.available(
        minimumPrice: 129.99,
        maximumPrice: 129.99,
      ),
    );

    expect(find.text('Mağaza fiyatı'), findsOneWidget);
    expect(find.text('₺129,99'), findsOneWidget);
    expect(find.textContaining('fiyatı kullanılır'), findsOneWidget);
  });

  testWidgets('birden çok mağazada gerçek fiyat aralığını gösterir', (
    tester,
  ) async {
    await pumpSummary(
      tester,
      const ProductSellerPriceSummary.available(
        minimumPrice: 1299.99,
        maximumPrice: 1399.99,
      ),
    );

    expect(find.text('Mağaza fiyat aralığı'), findsOneWidget);
    expect(find.text('₺1299,99 – ₺1399,99'), findsOneWidget);
  });

  testWidgets(
    'yüklenme, boş ve hata durumlarını yanıltıcı fiyat olmadan gösterir',
    (tester) async {
      await pumpSummary(tester, const ProductSellerPriceSummary.loading());
      expect(find.text('Mağaza fiyatları yükleniyor'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await pumpSummary(tester, const ProductSellerPriceSummary.empty());
      expect(find.text('Mağaza fiyatı henüz yok'), findsOneWidget);
      expect(find.byKey(const Key('product-seller-price-value')), findsNothing);

      await pumpSummary(tester, const ProductSellerPriceSummary.error());
      expect(find.text('Mağaza fiyatları alınamadı'), findsOneWidget);
      expect(find.byKey(const Key('product-seller-price-value')), findsNothing);
    },
  );

  testWidgets('dar ekranda ve büyük yazıda taşma yapmaz', (tester) async {
    await pumpSummary(
      tester,
      const ProductSellerPriceSummary.available(
        minimumPrice: 1299.99,
        maximumPrice: 1399.99,
      ),
      width: 320,
      textScaler: const TextScaler.linear(1.4),
    );

    expect(tester.takeException(), isNull);
  });
}
