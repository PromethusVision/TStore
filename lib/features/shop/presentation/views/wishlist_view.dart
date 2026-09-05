import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/common/widgets/progress_indicator.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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
  final Set<String> _openingProductIds = {};

  @override
  void initState() {
    super.initState();
    unawaited(context.read<WishlistCubit>().getWishlist());
  }

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
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
                  color: EsnaftaVarColors.primary,
                  backgroundColor: EsnaftaVarColors.surface,
                  onRefresh: context.read<WishlistCubit>().getWishlist,
                  child: CustomScrollView(
                    key: const Key('wishlist-products-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          EsnaftaVarSpacing.md,
                          EsnaftaVarSpacing.sm,
                          EsnaftaVarSpacing.md,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _WishlistHeader(
                            subtitle: '${items.length} ürün seni bekliyor.',
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: EsnaftaVarSpacing.md),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          EsnaftaVarSpacing.md,
                          0,
                          EsnaftaVarSpacing.md,
                          EsnaftaVarSpacing.xl,
                        ),
                        sliver: SliverGrid(
                          key: const Key('wishlist-products-grid'),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.sizeOf(context).width < 350 ||
                                        MediaQuery.textScalerOf(
                                              context,
                                            ).scale(14) >
                                            17
                                    ? 1
                                    : 2,
                                mainAxisSpacing: EsnaftaVarSpacing.sm,
                                crossAxisSpacing: EsnaftaVarSpacing.sm,
                                mainAxisExtent:
                                    300 +
                                    (MediaQuery.textScalerOf(
                                              context,
                                            ).scale(14) -
                                            14) *
                                        7,
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
    final productId = product.id.trim();
    final isRemoving = _removingProductIds.contains(item.productId);

    return _WishlistProductCard(
      product: product,
      isRemoving: isRemoving,
      onTap: isRemoving || productId.isEmpty
          ? null
          : () => unawaited(_openProduct(product)),
      onRemove: isRemoving ? null : () => _removeFavorite(item),
    );
  }

  Future<void> _openProduct(ProductEntity product) async {
    final productId = product.id.trim();
    if (productId.isEmpty || _openingProductIds.contains(productId)) return;

    _openingProductIds.add(productId);
    try {
      final destination =
          widget.destinationBuilder?.call(product) ??
          ProductDetailsView(product: product);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingProductIds.remove(productId);
    }
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
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.sm,
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.xl,
      ),
      child: Column(
        children: [
          _WishlistHeader(subtitle: subtitle),
          const SizedBox(height: EsnaftaVarSpacing.md),
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
    return EsnaftaVarSectionHeader(
      key: const Key('wishlist-header'),
      title: 'Favorilerim',
      subtitle: subtitle,
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
      color: EsnaftaVarColors.surface,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      child: InkWell(
        key: Key('wishlist-product-link-${product.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
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
                            color: EsnaftaVarColors.accent,
                            borderRadius: BorderRadius.circular(
                              EsnaftaVarRadii.pill,
                            ),
                          ),
                          child: Text(
                            '%${product.discountPercentage.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
                          color: EsnaftaVarColors.textPrimary,
                          fontSize: 14,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: EsnaftaVarColors.textSecondary,
                            fontSize: 12,
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
                          color: EsnaftaVarColors.textPrimary,
                          fontSize: 16,
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
              width: 48,
              height: 48,
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: EsnaftaVarColors.primary,
                ),
              ),
            )
          : IconButton(
              key: Key('favorite-action-$productId'),
              tooltip: 'Favorilerden çıkar',
              onPressed: onPressed,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Iconsax.heart5,
                color: EsnaftaVarColors.primary,
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
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _WishlistProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
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
      color: EsnaftaVarColors.primarySoft,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: EsnaftaVarColors.primary,
          size: 38,
        ),
      ),
    );
  }
}

class _WishlistLoadingView extends StatelessWidget {
  const _WishlistLoadingView();
  @override
  Widget build(BuildContext context) => const Padding(
    key: Key('wishlist-loading'),
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        _WishlistHeader(subtitle: 'Favorilerin hazırlanıyor.'),
        Expanded(
          child: Center(
            child: TLoadingIndicator(label: 'Favoriler yükleniyor'),
          ),
        ),
      ],
    ),
  );
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
    return SingleChildScrollView(
      child: EsnaftaVarStateCard(
        icon: icon,
        title: title,
        message: description,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
