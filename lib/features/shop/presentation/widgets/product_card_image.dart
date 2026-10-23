import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/helpers/product_card_media_loader.dart';

/// Uses the same published listing photos as details. Explicit listings restrict
/// the image to that surface (a shop card must never borrow another shop's photo).
class ProductCardImage extends StatefulWidget {
  const ProductCardImage({
    super.key,
    required this.productId,
    required this.fallback,
    this.listings,
    this.fit = BoxFit.contain,
    this.loader,
    this.refreshKey,
    this.imageFrame,
  });
  final String productId;
  final List<ShopProductEntity>? listings;
  final Widget fallback;
  final BoxFit fit;
  final ProductCardMediaLoader? loader;
  final Object? refreshKey;
  final Widget Function(Widget image)? imageFrame;
  @override
  State<ProductCardImage> createState() => _ProductCardImageState();
}

class _ProductCardImageState extends State<ProductCardImage> {
  late Future<List<ListingHeroPhoto>> _photos;
  late ProductCardMediaLoader _loader;
  @override
  void initState() {
    super.initState();
    _resolveLoader();
    _load();
  }

  void _resolveLoader() {
    _loader =
        widget.loader ??
        (sl.isRegistered<ProductCardMediaLoader>()
            ? sl<ProductCardMediaLoader>()
            : ProductCardMediaLoader(
                media: sl.isRegistered<ListingHeroMediaRepository>()
                    ? sl<ListingHeroMediaRepository>()
                    : const LegacyListingHeroMediaRepository(),
              ));
  }

  void _load() {
    _photos = _loader.load(widget.productId, listings: widget.listings);
  }

  @override
  void didUpdateWidget(covariant ProductCardImage old) {
    super.didUpdateWidget(old);
    if (old.loader != widget.loader) _resolveLoader();
    if (old.productId != widget.productId ||
        old.loader != widget.loader ||
        old.refreshKey != widget.refreshKey ||
        !listEquals(old.listings, widget.listings)) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ListingHeroPhoto>>(
    key: ValueKey(
      _photos,
    ), // A replacement must clear the previous photo immediately.
    future: _photos,
    builder: (context, snapshot) => _at(snapshot.data ?? const [], 0),
  );
  Widget _at(List<ListingHeroPhoto> photos, int index) {
    if (index >= photos.length) return widget.fallback;
    final photo = photos[index];
    Widget failed() => _at(photos, index + 1);
    Widget described(Widget image) => Semantics(
      image: true,
      label: 'Ürün fotoğrafı: ${photo.shopName}',
      child: widget.imageFrame?.call(image) ?? image,
    );
    if (photo.source.startsWith('assets/')) {
      return Image.asset(
        photo.source,
        key: ValueKey(photo.source),
        fit: widget.fit,
        frameBuilder: (_, child, frame, sync) =>
            frame != null || sync ? described(child) : widget.fallback,
        errorBuilder: (_, _, _) => failed(),
      );
    }
    return CachedNetworkImage(
      imageUrl: photo.source,
      key: ValueKey(photo.source),
      fit: widget.fit,
      imageBuilder: (_, provider) =>
          described(Image(image: provider, fit: widget.fit)),
      placeholder: (_, _) => widget.fallback,
      errorWidget: (_, _, _) => failed(),
    );
  }
}
