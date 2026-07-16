import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/shop/data/services/shared_preferences_recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';

void main() {
  late SharedPreferencesRecentlyViewedProductsStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferencesRecentlyViewedProductsStorage();
  });

  test('aynı ürünü çoğaltmadan en üste taşır', () async {
    await storage.recordProduct(customerId: 'customer-1', productId: 'p1');
    await storage.recordProduct(customerId: 'customer-1', productId: 'p2');
    await storage.recordProduct(customerId: 'customer-1', productId: 'p1');

    expect(await storage.getProductIds('customer-1'), ['p1', 'p2']);
  });

  test('yalnızca son yirmi ürünü en yeniden eskiye saklar', () async {
    for (var index = 0; index < 25; index++) {
      await storage.recordProduct(
        customerId: 'customer-1',
        productId: 'p$index',
      );
    }

    final productIds = await storage.getProductIds('customer-1');

    expect(
      productIds.length,
      RecentlyViewedProductsStorage.maximumProductCount,
    );
    expect(productIds.first, 'p24');
    expect(productIds.last, 'p5');
  });

  test(
    'müşteri geçmişlerini birbirinden ayırır ve seçileni temizler',
    () async {
      await storage.recordProduct(customerId: 'customer-1', productId: 'p1');
      await storage.recordProduct(customerId: 'customer-2', productId: 'p2');

      await storage.clear('customer-1');

      expect(await storage.getProductIds('customer-1'), isEmpty);
      expect(await storage.getProductIds('customer-2'), ['p2']);
    },
  );
}
