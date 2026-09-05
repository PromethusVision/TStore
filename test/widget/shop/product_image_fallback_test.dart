import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/other_same_products_list.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_fallback.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';

void main() {
  const brokenImageUrl = 'https://example.com/missing-product.jpg';
  const product = ProductEntity(
    id: 'product-1',
    name: 'Mahalle Ürünü',
    price: 100,
    categoryId: 'category-1',
    stock: 1,
    images: [brokenImageUrl],
  );

  Widget errorFallback(WidgetTester tester, {int index = 0}) {
    final finder = find.byType(CachedNetworkImage).at(index);
    final image = tester.widget<CachedNetworkImage>(finder);
    return image.errorWidget!(
      tester.element(finder),
      image.imageUrl,
      Exception('Görsel yüklenemedi'),
    );
  }

  testWidgets('ürün yedeği yazısız ve hata simgesiz görünür', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductImageFallback()));

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.error), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('ürün detayındaki bozuk ana görsel güvenli yedeği kullanır', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SelectedProductImage(image: brokenImageUrl)),
    );

    final fallback = errorFallback(tester);

    expect(fallback, isA<ProductImageFallback>());
    expect(fallback.key, const Key('selected-product-image-fallback'));
  });

  testWidgets('ürün detayındaki bozuk küçük görsel güvenli yedeği kullanır', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 430,
            height: 300,
            child: Stack(
              children: [
                OtherSameProductsList(images: [brokenImageUrl]),
              ],
            ),
          ),
        ),
      ),
    );

    final fallback = errorFallback(tester);

    expect(fallback, isA<ProductImageFallback>());
    expect(fallback.key, const Key('product-thumbnail-fallback-0'));
  });

  testWidgets('dikey ürün kartındaki bozuk görsel güvenli yedeği kullanır', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 288,
            child: VerticalProductCard(product: product),
          ),
        ),
      ),
    );

    final fallback = errorFallback(tester);

    expect(fallback, isA<ProductImageFallback>());
    expect(
      fallback.key,
      const Key('vertical-product-image-fallback-product-1'),
    );
  });

  testWidgets('boş ürün görseli başka bir ürün fotoğrafı göstermez', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SelectedProductImage(image: '')),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(ProductImageFallback), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
