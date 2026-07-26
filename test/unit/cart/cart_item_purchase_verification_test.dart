import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

void main() {
  CartItemV2Entity cartItem({
    bool shopIsActive = true,
    bool shopProductIsActive = true,
    bool shopProductIsAvailable = true,
    bool productIsActive = true,
    int quantity = 1,
    bool includeShopProduct = true,
    bool includeProduct = true,
  }) {
    return CartItemV2Entity(
      id: 'item-1',
      cartId: 'cart-1',
      shopProductId: 'shop-product-1',
      quantity: quantity,
      shopProduct: includeShopProduct
          ? ShopProductEntity(
              id: 'shop-product-1',
              shopId: 'shop-1',
              productId: 'product-1',
              price: 99,
              isActive: shopProductIsActive,
              isAvailable: shopProductIsAvailable,
              shop: ShopEntity(
                id: 'shop-1',
                name: 'Mahalle Mağazası',
                isActive: shopIsActive,
              ),
              product: includeProduct
                  ? ProductEntity(
                      id: 'product-1',
                      name: 'Test Ürünü',
                      price: 99,
                      categoryId: 'category-1',
                      stock: 1,
                      images: const [],
                      isActive: productIsActive,
                    )
                  : null,
            )
          : null,
    );
  }

  test('aktif mağaza ve ürün için alışveriş doğrulanabilir', () {
    expect(cartItem().isPurchaseVerifiable, isTrue);
  });

  test('pasif mağaza veya mağaza ürünü doğrulamayı engeller', () {
    expect(cartItem(shopIsActive: false).isPurchaseVerifiable, isFalse);
    expect(cartItem(shopProductIsActive: false).isPurchaseVerifiable, isFalse);
    expect(
      cartItem(shopProductIsAvailable: false).isPurchaseVerifiable,
      isFalse,
    );
  });

  test('pasif veya eksik ürün doğrulamayı engeller', () {
    expect(cartItem(productIsActive: false).isPurchaseVerifiable, isFalse);
    expect(cartItem(includeProduct: false).isPurchaseVerifiable, isFalse);
    expect(cartItem(includeShopProduct: false).isPurchaseVerifiable, isFalse);
  });

  test('geçersiz ürün adedi doğrulamayı engeller', () {
    expect(cartItem(quantity: 0).isPurchaseVerifiable, isFalse);
  });
}
