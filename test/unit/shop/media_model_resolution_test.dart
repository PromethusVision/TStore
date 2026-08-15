import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/shop/data/models/banner_model.dart';
import 'package:t_store/features/shop/data/models/category_model.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';

void main() {
  const productId = '11111111-1111-4111-8111-111111111111';
  const shopId = '22222222-2222-4222-8222-222222222222';
  const shopProductId = '33333333-3333-4333-8333-333333333333';
  const categoryId = '44444444-4444-4444-8444-444444444444';
  const bannerId = '55555555-5555-4555-8555-555555555555';
  final resolver = PublicMediaSourceResolver.withUrlBuilder(
    (bucket, path) => 'https://project.example/storage/$bucket/$path',
  );

  test('product model resolves catalog media and preserves legacy HTTPS', () {
    const thumbnail = 'catalog/$productId/thumbnail.webp';
    const legacyImage = 'https://legacy.example/product-detail.jpg';
    final model = ProductModel.fromJson({
      'id': productId,
      'name': 'Product',
      'price': 10,
      'category_id': categoryId,
      'images': [legacyImage, 'catalog/$productId/detail.webp'],
      'thumbnail': thumbnail,
    }, mediaResolver: resolver);

    expect(model.thumbnail, contains('/product-images/$thumbnail'));
    expect(model.images.first, legacyImage);
    expect(
      model.images.last,
      contains('/product-images/catalog/$productId/detail.webp'),
    );
  });

  test('shop product model resolves listing and nested catalog media', () {
    const shopImage = 'shops/$shopId/$shopProductId/listing.webp';
    final model = ShopProductModel.fromJson({
      'id': shopProductId,
      'shop_id': shopId,
      'product_id': productId,
      'price': 9,
      'images': [shopImage],
      'products': {
        'id': productId,
        'name': 'Product',
        'price': 10,
        'category_id': categoryId,
        'images': ['catalog/$productId/detail.webp'],
      },
    }, mediaResolver: resolver);

    expect(model.images.single, contains('/product-images/$shopImage'));
    expect(
      model.product?.images.single,
      contains('/product-images/catalog/$productId/detail.webp'),
    );
  });

  test('category and banner models resolve their dedicated buckets', () {
    const categoryPath = 'catalog/$categoryId/tile.webp';
    const bannerPath = 'catalog/$bannerId/hero.webp';
    final category = CategoryModel.fromJson({
      'id': categoryId,
      'name': 'Category',
      'image_url': categoryPath,
    }, mediaResolver: resolver);
    final banner = BannerModel.tryFromJson({
      'id': bannerId,
      'image_url': bannerPath,
    }, mediaResolver: resolver);

    expect(category.imageUrl, contains('/category-images/$categoryPath'));
    expect(banner?.imageUrl, contains('/banner-images/$bannerPath'));
  });

  test('invalid media becomes the existing empty/fallback model state', () {
    final product = ProductModel.fromJson({
      'id': productId,
      'name': 'Product',
      'price': 10,
      'category_id': categoryId,
      'images': const [
        'javascript:alert(1)',
        'catalog/another-product/image.webp',
      ],
      'thumbnail': 'file:///tmp/image.webp',
    }, mediaResolver: resolver);
    final category = CategoryModel.fromJson({
      'id': categoryId,
      'name': 'Category',
      'image_url': 'data:image/png;base64,AA==',
    }, mediaResolver: resolver);
    final banner = BannerModel.tryFromJson({
      'id': bannerId,
      'image_url': 'avatars/$bannerId/image.webp',
    }, mediaResolver: resolver);

    expect(product.images, isEmpty);
    expect(product.thumbnail, isNull);
    expect(category.imageUrl, isNull);
    expect(banner, isNull);
  });
}
