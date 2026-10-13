import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class ListingHeroPhoto {
  const ListingHeroPhoto({
    required this.listingId,
    required this.shopName,
    required this.source,
  });
  final String listingId, shopName, source;
}

abstract interface class ListingHeroMediaRepository {
  /// Ordered input is the displayed seller result; this port never ranks.
  Future<List<ListingHeroPhoto>> photos(List<ShopProductEntity> rankedListings);
}

/// Legacy read compatibility for a backend that has not installed Slice A.
class LegacyListingHeroMediaRepository implements ListingHeroMediaRepository {
  const LegacyListingHeroMediaRepository();
  @override
  Future<List<ListingHeroPhoto>> photos(
    List<ShopProductEntity> listings,
  ) async => [
    for (final s in listings.where((s) => s.isCustomerPurchasable))
      for (final image in s.images.where(validLegacyListingImage))
        ListingHeroPhoto(
          listingId: s.id,
          shopName: s.shop?.name ?? 'Esnaf',
          source: image,
        ),
  ];
}

bool validLegacyListingImage(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.userInfo.isNotEmpty) return false;
  if (uri.scheme == 'https' && uri.host.isNotEmpty) return true;
  // Only bundled assets and explicit local-development URLs are accepted.
  return value.startsWith('assets/') ||
      (uri.scheme == 'http' &&
          ['localhost', '127.0.0.1', '::1', '[::1]'].contains(uri.host));
}
