import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';

void main() {
  ProductEntity product({required String id, required int stock}) {
    return ProductEntity(
      id: id,
      name: 'Test ürünü',
      price: 100,
      categoryId: 'category-1',
      stock: stock,
      images: const [],
    );
  }

  testWidgets('genel ürün stoğu yerine mağazaya göre değişen durumu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ProductMetadata(product: product(id: 'in-stock', stock: 20)),
              ProductMetadata(product: product(id: 'out-of-stock', stock: 0)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Stok durumu:'), findsNWidgets(2));
    expect(find.text('Mağazaya göre değişir'), findsNWidgets(2));
    expect(find.text('Stokta var'), findsNothing);
    expect(find.text('Stokta yok'), findsNothing);
  });

  testWidgets('dar ekranda ve büyük yazıda stok açıklaması taşmaz', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: Scaffold(
            body: ProductMetadata(product: product(id: 'product-1', stock: 8)),
          ),
        ),
      ),
    );

    expect(find.text('Stok durumu:'), findsOneWidget);
    expect(find.text('Mağazaya göre değişir'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
