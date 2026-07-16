abstract class RecentlyViewedProductsStorage {
  static const int maximumProductCount = 20;

  Future<List<String>> getProductIds(String customerId);

  Future<void> recordProduct({
    required String customerId,
    required String productId,
  });

  Future<void> removeProduct({
    required String customerId,
    required String productId,
  });

  Future<void> restoreProduct({
    required String customerId,
    required String productId,
    required int position,
  });

  Future<void> clear(String customerId);
}
