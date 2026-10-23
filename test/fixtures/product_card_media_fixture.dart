import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/helpers/product_card_media_loader.dart';

/// Explicit owned-listing fixture, never an implicit central-photo fallback.
void installCardPhoto(String productId, String source) {
  installCardPhotos({productId: source});
}

void installCardPhotos(Map<String, String> sources) {
  sl.registerSingleton<ProductCardMediaLoader>(
    ProductCardMediaLoader(
      media: const LegacyListingHeroMediaRepository(),
      loadListings: (_) async => Right([
        for (final entry in sources.entries)
          ShopProductEntity(
            id: 'fixture-listing-${entry.key}',
            shopId: 'fixture-shop',
            productId: entry.key,
            price: 10,
            images: [entry.value],
            shop: const ShopEntity(id: 'fixture-shop', name: 'Fixture shop'),
          ),
      ]),
    ),
  );
  addTearDown(() async {
    if (sl.isRegistered<ProductCardMediaLoader>()) {
      await sl.unregister<ProductCardMediaLoader>();
    }
  });
}
