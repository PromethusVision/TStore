import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/cubit/listing_hero_cubit.dart';
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_fallback.dart';

typedef ListingHeroImageBuilder =
    Widget Function(
      String source,
      Widget Function(Widget) onSuccess,
      Widget Function() onFailure,
    );

class ListingProductHero extends StatefulWidget {
  const ListingProductHero({
    super.key,
    required this.product,
    required this.ranking,
    this.currentUserIdProvider,
    this.visualPrototype = false,
    this.repository,
    this.imageBuilder,
  });
  final ProductEntity product;
  final List<RankedSeller> ranking;
  final String? Function()? currentUserIdProvider;
  final bool visualPrototype;
  final ListingHeroMediaRepository? repository;
  final ListingHeroImageBuilder? imageBuilder;
  @override
  State<ListingProductHero> createState() => _ListingProductHeroState();
}

class _ListingProductHeroState extends State<ListingProductHero> {
  late final ListingHeroCubit _cubit;
  String? _shownListingId;
  @override
  void initState() {
    super.initState();
    _cubit = ListingHeroCubit(
      widget.repository ??
          (sl.isRegistered<ListingHeroMediaRepository>()
              ? sl<ListingHeroMediaRepository>()
              : const LegacyListingHeroMediaRepository()),
    );
    _cubit.load(widget.ranking);
  }

  @override
  void didUpdateWidget(covariant ListingProductHero old) {
    super.didUpdateWidget(old);
    if (old.product.id != widget.product.id ||
        !_same(old.ranking, widget.ranking)) {
      _shownListingId = null;
      _cubit.load(widget.ranking);
    }
  }

  bool _same(List<RankedSeller> a, List<RankedSeller> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((v) => v);
  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ListingHeroCubit, List<ListingHeroPhoto>>(
        bloc: _cubit,
        builder: (context, photos) {
          final ownPhotos = photos
              .where((p) => p.listingId == _shownListingId)
              .map((p) => p.source)
              .toList(growable: false);
          return ProductImageSlider(
            product: widget.product,
            currentUserIdProvider: widget.currentUserIdProvider,
            visualPrototype: widget.visualPrototype,
            heroImages: ownPhotos,
            heroImage: ListingHeroPhotoChain(
              key: ValueKey(photos),
              photos: photos,
              imageBuilder: widget.imageBuilder,
              imageExtent: widget.visualPrototype ? 184 : 245,
              padding: widget.visualPrototype
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.fromLTRB(30, 38, 30, 54),
              sourceBottom: widget.visualPrototype ? 3 : 12,
              sourceRight: widget.visualPrototype && ownPhotos.length > 1
                  ? 100
                  : 18,
              onLoadedPhoto: (photo) {
                if (!mounted ||
                    !identical(_cubit.state, photos) ||
                    _shownListingId == photo?.listingId) {
                  return;
                }
                setState(() => _shownListingId = photo?.listingId);
              },
            ),
          );
        },
      );
}

/// Each failed decode/load advances through the same seller's remaining photos
/// before the next ranked seller. The label follows the photo that actually loads.
class ListingHeroPhotoChain extends StatelessWidget {
  const ListingHeroPhotoChain({
    super.key,
    required this.photos,
    this.imageBuilder,
    this.imageExtent = 245,
    this.padding = const EdgeInsets.fromLTRB(30, 38, 30, 54),
    this.sourceBottom = 12,
    this.sourceRight = 18,
    this.onLoadedPhoto,
  });
  final List<ListingHeroPhoto> photos;
  final ListingHeroImageBuilder? imageBuilder;
  final double imageExtent, sourceBottom, sourceRight;
  final ValueChanged<ListingHeroPhoto?>? onLoadedPhoto;
  final EdgeInsetsGeometry padding;
  void _loaded(ListingHeroPhoto? photo) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => onLoadedPhoto?.call(photo),
    );
  }

  Widget _placeholder() => Padding(
    padding: padding,
    child: Center(
      child: SizedBox.square(
        dimension: imageExtent,
        child: const ProductImageFallback(
          key: Key('listing-hero-placeholder'),
          iconSize: 52,
        ),
      ),
    ),
  );
  Widget _at(int i) {
    if (i >= photos.length) {
      _loaded(null);
      return _placeholder();
    }
    final photo = photos[i];
    Widget failed() => _at(i + 1);
    Widget success(Widget child) {
      _loaded(photo);
      return Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: padding,
            child: Center(
              child: SizedBox.square(dimension: imageExtent, child: child),
            ),
          ),
          Positioned(
            bottom: sourceBottom,
            left: 18,
            right: sourceRight,
            child: Text(
              'Fotoğraf: ${photo.shopName}',
              key: const Key('listing-hero-source'),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    }

    if (imageBuilder != null) {
      return imageBuilder!(photo.source, success, failed);
    }
    final ImageProvider provider = photo.source.startsWith('assets/')
        ? AssetImage(photo.source)
        : NetworkImage(photo.source);
    return Image(
      image: provider,
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, synchronous) =>
          frame != null || synchronous ? success(child) : _placeholder(),
      errorBuilder: (_, _, _) => failed(),
    );
  }

  @override
  Widget build(BuildContext context) => _at(0);
}
