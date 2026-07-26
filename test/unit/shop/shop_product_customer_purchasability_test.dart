import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

void main() {
  ShopProductEntity shopProduct({
    bool isActive = true,
    bool isAvailable = true,
    ShopEntity? shop,
  }) {
    return ShopProductEntity(
      id: 'shop-product-1',
      shopId: 'shop-1',
      productId: 'product-1',
      price: 99,
      isActive: isActive,
      isAvailable: isAvailable,
      shop: shop,
    );
  }

  const activeShop = ShopEntity(
    id: 'shop-1',
    name: 'Aktif Esnaf',
    isActive: true,
  );
  const inactiveShop = ShopEntity(
    id: 'shop-1',
    name: 'Pasif Esnaf',
    isActive: false,
  );

  test('aktif mağazadaki satışta olan ürün müşteri sepetine uygundur', () {
    expect(shopProduct(shop: activeShop).isCustomerPurchasable, isTrue);
  });

  test('pasif mağazadaki ürün müşteri sepetine uygun değildir', () {
    expect(shopProduct(shop: inactiveShop).isCustomerPurchasable, isFalse);
  });

  test('mağaza bilgisi eksik ürün müşteri sepetine uygun değildir', () {
    expect(shopProduct().isCustomerPurchasable, isFalse);
  });

  test('satıştan kaldırılan veya rafta olmayan ürün uygun değildir', () {
    expect(
      shopProduct(shop: activeShop, isActive: false).isCustomerPurchasable,
      isFalse,
    );
    expect(
      shopProduct(shop: activeShop, isAvailable: false).isCustomerPurchasable,
      isFalse,
    );
  });

  test('sunucudan gelen pasif mağaza bilgisi güvenli biçimde reddedilir', () {
    final model = ShopProductModel.fromJson({
      'id': 'shop-product-1',
      'shop_id': 'shop-1',
      'product_id': 'product-1',
      'price': 99,
      'is_active': true,
      'is_available': true,
      'shops': {'id': 'shop-1', 'name': 'Pasif Esnaf', 'is_active': false},
    });

    expect(model.shop, isNotNull);
    expect(model.isCustomerPurchasable, isFalse);
  });
}
