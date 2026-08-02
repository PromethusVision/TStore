import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

typedef WishlistProductDestinationBuilder =
    Widget Function(ProductEntity product);

class WishlistView extends StatefulWidget {
  const WishlistView({super.key, this.destinationBuilder});

  final WishlistProductDestinationBuilder? destinationBuilder;

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final Set<String> _removingProductIds = {};

  @override
  void initState() {
    super.initState();
    unawaited(context.read<WishlistCubit>().getWishlist());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('wishlist-customer-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) {
                if (state is WishlistInitial ||
                    state is WishlistLoading ||
                    state is WishlistItemAdded ||
                    state is WishlistItemRemoved) {
                  return const _WishlistLoadingView();
                }

                if (state is WishlistError) {
                  return _WishlistStateLayout(
                    subtitle: 'Kaydettiğin ürünlere hızlıca ulaş.',
                    child: _WishlistStatus(
                      key: const Key('wishlist-error'),
                      icon: Iconsax.warning_2,
                      title: 'Favorilerin yüklenemedi',
                      description:
                          'Bağlantını kontrol edip yeniden deneyebilirsin.',
                      actionLabel: 'Tekrar Dene',
                      onAction: _reloadWishlist,
                    ),
                  );
                }

                final items = (state as WishlistLoaded).items
                    .where((item) => item.product != null)
                    .toList(growable: false);

                if (items.isEmpty) {
                  return _WishlistStateLayout(
                    subtitle: 'Beğendiklerini tek yerde biriktir.',
                    child: _WishlistStatus(
                      key: const Key('wishlist-empty'),
                      icon: Iconsax.heart,
                      title: 'Henüz favorin yok',
                      description:
                          'Beğendiğin ürünleri favorilerine eklediğinde burada '
                          'görebilirsin.',
                      actionLabel: 'Ürünleri Keşfet',
                      onAction: _exploreProducts,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: CustomerHomeV1Tokens.petrol,
                  backgroundColor: CustomerHomeV1Tokens.surface,
                  onRefresh: context.read<WishlistCubit>().getWishlist,
                  child: CustomScrollView(
                    key: const Key('wishlist-products-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          CustomerHomeV1Tokens.space16,
                          CustomerHomeV1Tokens.space12,
                          CustomerHomeV1Tokens.space16,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _WishlistHeader(
                            subtitle: '${items.length} ürün seni bekliyor.',
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: CustomerHomeV1Tokens.space16),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          CustomerHomeV1Tokens.space16,
                          0,
                          CustomerHomeV1Tokens.space16,
                          CustomerHomeV1Tokens.space24,
                        ),
                        sliver: SliverGrid(
                          key: const Key('wishlist-products-grid'),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: CustomerHomeV1Tokens.space12,
                                crossAxisSpacing: CustomerHomeV1Tokens.space12,
                                mainAxisExtent: 250,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildProductCard(items[index]),
                            childCount: items.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(WishlistItemEntity item) {
    final product = item.product!;
    final isRemoving = _removingProductIds.contains(item.productId);

    return _WishlistProductCard(
      product: product,
      isRemoving: isRemoving,
      onTap: isRemoving
          ? null
          : () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) =>
                    widget.destinationBuilder?.call(product) ??
                    ProductDetailsView(product: product),
              ),
            ),
      onRemove: isRemoving ? null : () => _removeFavorite(item),
    );
  }

  Future<void> _removeFavorite(WishlistItemEntity item) async {
    if (_removingProductIds.contains(item.productId)) return;

    setState(() => _removingProductIds.add(item.productId));
    await context.read<WishlistCubit>().removeFromWishlist(item.productId);

    if (!mounted) return;
    setState(() => _removingProductIds.remove(item.productId));
  }

  void _reloadWishlist() {
    unawaited(context.read<WishlistCubit>().getWishlist());
  }

  void _exploreProducts() {
    context.read<NavigationMenuCubit>().changeIndex(0);
  }
}

class _WishlistStateLayout extends StatelessWidget {
  const _WishlistStateLayout({required this.subtitle, required this.child});

  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space12,
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space24,
      ),
      child: Column(
        children: [
          _WishlistHeader(subtitle: subtitle),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  const _WishlistHeader({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wishlist-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE6DF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.heart5,
              color: CustomerHomeV1Tokens.coral,
              size: 24,
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favorilerim',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.product,
    required this.isRemoving,
    required this.onTap,
    required this.onRemove,
  });

  final ProductEntity product;
  final bool isRemoving;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;

    return Material(
      key: Key('wishlist-product-${product.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 158,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _WishlistProductImage(product: product),
                    if (product.hasDiscount)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CustomerHomeV1Tokens.coral,
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radiusPill,
                            ),
                          ),
                          child: Text(
                            '%${product.discountPercentage.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _FavoriteRemoveButton(
                        productId: product.id,
                        isRemoving: isRemoving,
                        onPressed: onRemove,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 12.5,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: CustomerHomeV1Tokens.space4),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.muted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? get _secondaryText {
    final brandName = product.brandName?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;
    final categoryName = product.categoryName?.trim() ?? '';
    return categoryName.isEmpty ? null : categoryName;
  }

  String get _priceLabel {
    final parts = product.effectivePrice.toStringAsFixed(2).split('.');
    return '${parts.first},${parts.last} TL';
  }
}

class _FavoriteRemoveButton extends StatelessWidget {
  const _FavoriteRemoveButton({
    required this.productId,
    required this.isRemoving,
    required this.onPressed,
  });

  final String productId;
  final bool isRemoving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: isRemoving
          ? SizedBox(
              key: Key('favorite-action-loading-$productId'),
              width: 34,
              height: 34,
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomerHomeV1Tokens.petrol,
                ),
              ),
            )
          : IconButton(
              key: Key('favorite-action-$productId'),
              tooltip: 'Favorilerden çıkar',
              onPressed: onPressed,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Iconsax.heart5,
                color: CustomerHomeV1Tokens.coral,
                size: 18,
              ),
            ),
    );
  }
}

class _WishlistProductImage extends StatelessWidget {
  const _WishlistProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _WishlistProductImageFallback();

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _WishlistProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _WishlistProductImageFallback(),
      errorWidget: (_, _, _) => const _WishlistProductImageFallback(),
    );
  }

  String? get _imageUrl {
    for (final image in product.images) {
      if (image.trim().isNotEmpty) return image.trim();
    }
    final thumbnail = product.thumbnail?.trim() ?? '';
    return thumbnail.isEmpty ? null : thumbnail;
  }
}

class _WishlistProductImageFallback extends StatelessWidget {
  const _WishlistProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: CustomerHomeV1Tokens.mint,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: CustomerHomeV1Tokens.petrol,
          size: 38,
        ),
      ),
    );
  }
}

class _WishlistLoadingView extends StatelessWidget {
  const _WishlistLoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('wishlist-loading'),
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space12,
            CustomerHomeV1Tokens.space16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _WishlistHeader(subtitle: 'Favorilerin hazırlanıyor.'),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: CustomerHomeV1Tokens.space16),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomerHomeV1Tokens.space16,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: CustomerHomeV1Tokens.space12,
              crossAxisSpacing: CustomerHomeV1Tokens.space12,
              mainAxisExtent: 250,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => const _WishlistProductSkeleton(),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _WishlistProductSkeleton extends StatelessWidget {
  const _WishlistProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 158,
            width: double.infinity,
            child: ColoredBox(color: CustomerHomeV1Tokens.mint),
          ),
          Padding(
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonLine(width: 112),
                SizedBox(height: CustomerHomeV1Tokens.space8),
                _SkeletonLine(width: 72),
                SizedBox(height: CustomerHomeV1Tokens.space12),
                _SkeletonLine(width: 88),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
      ),
    );
  }
}

class _WishlistStatus extends StatelessWidget {
  const _WishlistStatus({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space20),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: CustomerHomeV1Tokens.petrol,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CustomerHomeV1Tokens.space20,
                    vertical: CustomerHomeV1Tokens.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radiusPill,
                    ),
                  ),
                ),
                icon: Icon(
                  actionLabel == 'Tekrar Dene'
                      ? Icons.refresh_rounded
                      : Icons.explore_outlined,
                  size: 18,
                ),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
