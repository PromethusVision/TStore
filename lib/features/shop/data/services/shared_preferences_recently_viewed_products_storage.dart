import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';

class SharedPreferencesRecentlyViewedProductsStorage
    implements RecentlyViewedProductsStorage {
  static const String _keyPrefix = 'recently_viewed_product_ids_v1_';

  @override
  Future<List<String>> getProductIds(String customerId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedIds = preferences.getStringList(_key(customerId)) ?? const [];
    final seenIds = <String>{};

    return storedIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && seenIds.add(id))
        .take(RecentlyViewedProductsStorage.maximumProductCount)
        .toList(growable: false);
  }

  @override
  Future<void> recordProduct({
    required String customerId,
    required String productId,
  }) async {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final productIds = await getProductIds(customerId);

    await preferences.setStringList(
      _key(customerId),
      [
        normalizedProductId,
        ...productIds.where((id) => id != normalizedProductId),
      ].take(RecentlyViewedProductsStorage.maximumProductCount).toList(),
    );
  }

  @override
  Future<void> removeProduct({
    required String customerId,
    required String productId,
  }) async {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final productIds = await getProductIds(customerId);

    await preferences.setStringList(
      _key(customerId),
      productIds.where((id) => id != normalizedProductId).toList(),
    );
  }

  @override
  Future<void> restoreProduct({
    required String customerId,
    required String productId,
    required int position,
  }) async {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final productIds = (await getProductIds(
      customerId,
    )).where((id) => id != normalizedProductId).toList();
    final safePosition = position.clamp(0, productIds.length).toInt();
    productIds.insert(safePosition, normalizedProductId);

    await preferences.setStringList(
      _key(customerId),
      productIds
          .take(RecentlyViewedProductsStorage.maximumProductCount)
          .toList(),
    );
  }

  @override
  Future<void> clear(String customerId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(customerId));
  }

  String _key(String customerId) {
    final normalizedCustomerId = customerId.trim();
    if (normalizedCustomerId.isEmpty) {
      throw ArgumentError.value(
        customerId,
        'customerId',
        'Müşteri kimliği boş olamaz.',
      );
    }

    return '$_keyPrefix$normalizedCustomerId';
  }
}
