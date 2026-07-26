import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';

class PromoBannerCarouselSlider extends StatefulWidget {
  const PromoBannerCarouselSlider({super.key, this.onDiscover});

  final VoidCallback? onDiscover;

  @override
  State<PromoBannerCarouselSlider> createState() =>
      _PromoBannerCarouselSliderState();
}

class _PromoBannerCarouselSliderState extends State<PromoBannerCarouselSlider> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<BannersCubit>().getBanners();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        if (state is BannersLoading || state is BannersInitial) {
          return const _BannerShimmer();
        }

        final images = _activeImages(state);
        return _ApprovedHeroCarousel(
          images: images,
          selectedIndex: _selectedIndex.clamp(0, images.length - 1),
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          onDiscover:
              widget.onDiscover ??
              () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const AllProductsView(),
                ),
              ),
        );
      },
    );
  }

  List<String> _activeImages(BannersState state) {
    if (state is BannersLoaded) {
      final activeImages = state.banners
          .where((banner) => banner.isCurrentlyActive)
          .map((banner) => banner.imageUrl.trim())
          .where((url) => url.isNotEmpty)
          .toList(growable: false);
      if (activeImages.isNotEmpty) return activeImages;
    }

    return TImages.promoBannerImages;
  }
}

class _ApprovedHeroCarousel extends StatelessWidget {
  const _ApprovedHeroCarousel({
    required this.images,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onDiscover,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('customer-home-hero'),
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        child: Stack(
          children: [
            Positioned.fill(
              child: CarouselSlider.builder(
                itemCount: images.length,
                itemBuilder: (_, index, _) =>
                    _HeroImage(imagePath: images[index]),
                options: CarouselOptions(
                  height: 175,
                  viewportFraction: 1,
                  enableInfiniteScroll: images.length > 1,
                  autoPlay: images.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, _) => onPageChanged(index),
                ),
              ),
            ),
            const Positioned.fill(child: _HeroGradient()),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 11, 14, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mahallendeki\nesnafa destek ol,\nkazanan sen ol!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Aradığın ürün\nsana en yakın esnafta.',
                      style: TextStyle(
                        color: Color(0xFFF1F7F7),
                        fontSize: 10.5,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: FilledButton(
                        key: const Key('customer-home-discover'),
                        onPressed: onDiscover,
                        style: FilledButton.styleFrom(
                          backgroundColor: CustomerHomeV1Tokens.yellow,
                          foregroundColor: CustomerHomeV1Tokens.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radiusPill,
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Keşfet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                right: 14,
                bottom: 10,
                child: Row(
                  children: [
                    for (var index = 0; index < images.length; index++) ...[
                      if (index > 0)
                        const SizedBox(width: CustomerHomeV1Tokens.space4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: index == selectedIndex ? 13 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: index == selectedIndex
                              ? CustomerHomeV1Tokens.yellow
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radiusPill,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imagePath);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (!isNetwork) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BrandedHeroArtwork(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _BrandedHeroArtwork(),
      errorWidget: (_, _, _) => const _BrandedHeroArtwork(),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0D5C5E),
            const Color(0xFF0D5C5E).withValues(alpha: 0.92),
            CustomerHomeV1Tokens.petrol.withValues(alpha: 0.14),
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _BrandedHeroArtwork extends StatelessWidget {
  const _BrandedHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CustomerHomeV1Tokens.petrol,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 26),
          child: Icon(
            Icons.storefront_rounded,
            size: 92,
            color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CustomerHomeV1Tokens.mint,
      highlightColor: Colors.white,
      child: Container(
        key: const Key('customer-home-hero-loading'),
        height: 175,
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.mint,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        ),
      ),
    );
  }
}
