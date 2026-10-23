import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';

typedef CardListingsLoader =
    Future<Either<String, List<ShopProductEntity>>> Function(List<String> ids);

/// Coalesces cards built together into existing listing/media batch reads.
/// No retained lookup cache, catalog mutation, upload or extra GPS request.
class ProductCardMediaLoader {
  ProductCardMediaLoader({
    required this.media,
    this.loadListings,
    this.location,
  });
  final ListingHeroMediaRepository media;
  final CardListingsLoader? loadListings;
  final CustomerLocationService? location;
  final List<_CardRequest> _pending = [];
  static const _timeout = Duration(seconds: 15);

  Future<List<ListingHeroPhoto>> load(
    String productId, {
    List<ShopProductEntity>? listings,
  }) {
    if (productId.trim().isEmpty) return Future.value(const []);
    final request = _CardRequest(
      productId,
      listings == null ? null : List.of(listings),
    );
    _pending.add(request);
    if (_pending.length == 1) scheduleMicrotask(_flush);
    return request.result.future;
  }

  Future<void> _flush() async {
    final requests = List<_CardRequest>.of(_pending);
    _pending.clear();
    try {
      final ids = requests
          .where((r) => r.listings == null)
          .map((r) => r.productId)
          .toSet()
          .toList();
      final loaded = <ShopProductEntity>[];
      final read = loadListings;
      if (read != null) {
        for (var offset = 0; offset < ids.length; offset += 100) {
          final end = (offset + 100).clamp(0, ids.length);
          final result = await read(ids.sublist(offset, end)).timeout(_timeout);
          result.fold((_) {}, loaded.addAll);
        }
      }
      CustomerCoordinates? coordinates;
      try {
        coordinates = (await location?.getPreferredLocation().timeout(
          _timeout,
        ))?.coordinates;
      } catch (_) {
        /* A location read cannot prevent public photo display. */
      }
      coordinates ??= location?.cachedCoordinates;
      final rankings = <_CardRequest, List<ShopProductEntity>>{};
      final unique = <String, ShopProductEntity>{};
      for (final request in requests) {
        final candidates = (request.listings ?? loaded)
            .where((s) => s.productId == request.productId)
            .toList();
        final ranked = SellerRanking.rank(
          candidates,
          coordinates,
          coordinates?.isValid == true ? SellerSortOption.nearest : null,
        ).map((r) => r.shopProduct).toList();
        rankings[request] = ranked;
        for (final listing in ranked) {
          unique[listing.id] = listing;
        }
      }
      final photos = unique.isEmpty
          ? const <ListingHeroPhoto>[]
          : await media.photos(unique.values.toList()).timeout(_timeout);
      for (final request in requests) {
        request.result.complete(
          List.unmodifiable([
            for (final listing in rankings[request]!)
              for (final photo in photos)
                if (photo.listingId == listing.id &&
                    validLegacyListingImage(photo.source))
                  photo,
          ]),
        );
      }
    } catch (_) {
      // Never resurrect central catalog images on permission/network failure.
      for (final request in requests) {
        if (!request.result.isCompleted) request.result.complete(const []);
      }
    }
  }
}

class _CardRequest {
  _CardRequest(this.productId, this.listings);
  final String productId;
  final List<ShopProductEntity>? listings;
  final result = Completer<List<ListingHeroPhoto>>();
}
