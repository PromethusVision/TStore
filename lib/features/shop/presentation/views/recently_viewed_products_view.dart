import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

typedef RecentlyViewedProductDestinationBuilder =
    Widget Function(ProductEntity product);

class RecentlyViewedProductsView extends StatelessWidget {
  const RecentlyViewedProductsView({
    super.key,
    required this.customerId,
    this.recentlyViewedProductsCubit,
    this.onExplore,
    this.productDestinationBuilder,
  });

  final String customerId;
  final RecentlyViewedProductsCubit? recentlyViewedProductsCubit;
  final VoidCallback? onExplore;
  final RecentlyViewedProductDestinationBuilder? productDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (recentlyViewedProductsCubit ?? sl<RecentlyViewedProductsCubit>())
            ..load(customerId),
      child: _RecentlyViewedProductsContent(
        customerId: customerId,
        onExplore: onExplore,
        productDestinationBuilder: productDestinationBuilder,
      ),
    );
  }
}

class _RecentlyViewedProductsContent extends StatelessWidget {
  const _RecentlyViewedProductsContent({
    required this.customerId,
    required this.onExplore,
    required this.productDestinationBuilder,
  });

  final String customerId;
  final VoidCallback? onExplore;
  final RecentlyViewedProductDestinationBuilder? productDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('recently-viewed-customer-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                0,
              ),
              child:
                  BlocBuilder<
                    RecentlyViewedProductsCubit,
                    RecentlyViewedProductsState
                  >(
                    builder: (context, state) {
                      final products = state is RecentlyViewedProductsLoaded
                          ? state.products
                          : const <ProductEntity>[];
                      final canClear = products.isNotEmpty;

                      return Column(
                        children: [
                          _RecentlyViewedHeader(
                            productCount: products.length,
                            isLoading:
                                state is RecentlyViewedProductsInitial ||
                                state is RecentlyViewedProductsLoading,
                            onClear: canClear
                                ? () => _confirmClear(context)
                                : null,
                          ),
                          const SizedBox(height: CustomerHomeV1Tokens.space16),
                          Expanded(
                            child: _buildStateContent(context, state, products),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    RecentlyViewedProductsState state,
    List<ProductEntity> products,
  ) {
    if (state is RecentlyViewedProductsInitial ||
        state is RecentlyViewedProductsLoading) {
      return const _RecentlyViewedLoadingView();
    }

    if (state is RecentlyViewedProductsError) {
      return _RecentlyViewedStatus(
        key: const Key('recently-viewed-error'),
        icon: Icons.error_outline_rounded,
        title: 'Ürün geçmişin yüklenemedi',
        description: state.message,
        actionLabel: 'Tekrar Dene',
        onAction: () =>
            context.read<RecentlyViewedProductsCubit>().load(customerId),
      );
    }

    if (products.isEmpty) {
      return _RecentlyViewedStatus(
        key: const Key('recently-viewed-empty'),
        icon: Icons.history_rounded,
        title: 'Henüz görüntülediğin ürün yok',
        description:
            'İncelediğin ürünler burada en yeniden eskiye sıralanacak.',
        actionLabel: 'Ürünleri Keşfet',
        onAction: () => _openExplore(context),
      );
    }

    return RefreshIndicator(
      color: CustomerHomeV1Tokens.petrol,
      backgroundColor: CustomerHomeV1Tokens.surface,
      onRefresh: () =>
          context.read<RecentlyViewedProductsCubit>().load(customerId),
      child: ListView.separated(
        key: const Key('recently-viewed-products-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: CustomerHomeV1Tokens.space24),
        itemCount: products.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: CustomerHomeV1Tokens.space12),
        itemBuilder: (context, index) => _RecentlyViewedProductCard(
          product: products[index],
          customerId: customerId,
          onTap: () => _openProduct(context, products[index]),
          onRemove: () => _removeProduct(context, products[index]),
        ),
      ),
    );
  }

  Future<void> _openProduct(BuildContext context, ProductEntity product) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            productDestinationBuilder?.call(product) ??
            ProductDetailsView(product: product),
      ),
    );

    if (!context.mounted) return;
    await context.read<RecentlyViewedProductsCubit>().load(customerId);
  }

  void _openExplore(BuildContext context) {
    final exploreAction = onExplore;
    if (exploreAction != null) {
      exploreAction();
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AllProductsView()));
  }

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CustomerHomeV1Tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        ),
        title: const Text(
          'Görüntüleme geçmişi silinsin mi?',
          style: TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Bu tarayıcıda kaydedilen son görüntülenen ürünler kaldırılacak.',
          style: TextStyle(color: CustomerHomeV1Tokens.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.coral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tümünü Temizle'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) return;

    final didClear = await context.read<RecentlyViewedProductsCubit>().clear(
      customerId,
    );
    if (!didClear && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Görüntüleme geçmişi şu anda temizlenemedi.'),
        ),
      );
    }
  }

  Future<void> _removeProduct(
    BuildContext context,
    ProductEntity product,
  ) async {
    final cubit = context.read<RecentlyViewedProductsCubit>();
    final removal = await cubit.removeProduct(customerId, product.id);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (removal == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ürün geçmişten şu anda kaldırılamadı.')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.name} geçmişten kaldırıldı.'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            final didRestore = await cubit.restoreProduct(customerId, removal);
            if (!didRestore && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ürün geçmişe geri eklenemedi.')),
              );
            }
          },
        ),
      ),
    );
  }
}

class _RecentlyViewedHeader extends StatelessWidget {
  const _RecentlyViewedHeader({
    required this.productCount,
    required this.isLoading,
    required this.onClear,
  });

  final int productCount;
  final bool isLoading;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('recently-viewed-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('recently-viewed-back'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              color: CustomerHomeV1Tokens.petrol,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Son Görüntülediklerim',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: CustomerHomeV1Tokens.space8),
            Material(
              color: const Color(0xFFFFE6DF),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Geçmişi temizle',
                onPressed: onClear,
                color: CustomerHomeV1Tokens.coral,
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _subtitle {
    if (isLoading) return 'Ürün geçmişin hazırlanıyor.';
    if (productCount == 0) return 'İncelediğin ürünlere yeniden ulaş.';
    return '$productCount ürün yakın zamanda görüntülendi.';
  }
}

enum _RecentlyViewedProductAction { remove }

class _RecentlyViewedProductCard extends StatelessWidget {
  const _RecentlyViewedProductCard({
    required this.product,
    required this.customerId,
    required this.onTap,
    required this.onRemove,
  });

  final ProductEntity product;
  final String customerId;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final supportingText = _supportingText;
    final isCompact = MediaQuery.sizeOf(context).width <= 340;

    return Semantics(
      button: true,
      label: '${product.name} ürününü yeniden görüntüle',
      child: Material(
        key: Key('recently-viewed-product-${product.id}'),
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          child: Container(
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius16,
              ),
              border: Border.all(color: CustomerHomeV1Tokens.border),
              boxShadow: CustomerHomeV1Tokens.softShadow,
            ),
            child: Row(
              children: [
                _ProductThumbnail(product: product, width: isCompact ? 72 : 88),
                SizedBox(
                  width: isCompact
                      ? CustomerHomeV1Tokens.space8
                      : CustomerHomeV1Tokens.space12,
                ),
                Expanded(
                  child: SizedBox(
                    height: 108,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.navy,
                            fontSize: 13,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (supportingText != null) ...[
                          const SizedBox(height: CustomerHomeV1Tokens.space4),
                          Text(
                            supportingText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CustomerHomeV1Tokens.muted,
                              fontSize: 10,
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
                        const SizedBox(height: CustomerHomeV1Tokens.space4),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ürünü İncele',
                              style: TextStyle(
                                color: CustomerHomeV1Tokens.petrol,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: CustomerHomeV1Tokens.petrol,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: isCompact
                      ? CustomerHomeV1Tokens.space4
                      : CustomerHomeV1Tokens.space8,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProductFavoriteButton(
                      productId: product.id,
                      keyPrefix: 'recently-viewed-favorite-${product.id}',
                      currentUserIdProvider: () => customerId,
                      height: 34,
                      width: 34,
                      iconSize: 18,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: PopupMenuButton<_RecentlyViewedProductAction>(
                        tooltip: 'Ürün işlemleri',
                        padding: EdgeInsets.zero,
                        color: CustomerHomeV1Tokens.surface,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radius12,
                          ),
                        ),
                        onSelected: (action) {
                          if (action == _RecentlyViewedProductAction.remove) {
                            onRemove();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _RecentlyViewedProductAction.remove,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: CustomerHomeV1Tokens.coral,
                                  size: 20,
                                ),
                                SizedBox(width: CustomerHomeV1Tokens.space8),
                                Flexible(
                                  child: Text(
                                    'Geçmişten kaldır',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CustomerHomeV1Tokens.coral,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: CustomerHomeV1Tokens.muted,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _supportingText {
    final brandName = product.brandName?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;

    final categoryName = product.categoryName?.trim() ?? '';
    return categoryName.isEmpty ? null : categoryName;
  }

  String get _priceLabel {
    final parts = product.effectivePrice.toStringAsFixed(2).split('.');
    final integerDigits = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < integerDigits.length; index++) {
      if (index > 0 && (integerDigits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerDigits[index]);
    }
    return '₺$buffer,${parts.last}';
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product, required this.width});

  final ProductEntity product;
  final double width;

  @override
  Widget build(BuildContext context) {
    final imagePath = _imagePath;
    const fallback = ColoredBox(
      color: CustomerHomeV1Tokens.mint,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: CustomerHomeV1Tokens.petrol,
          size: 34,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
      child: SizedBox(
        width: width,
        height: 108,
        child: imagePath == null
            ? fallback
            : imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://')
            ? CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.cover,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }

  String? get _imagePath {
    for (final image in product.images) {
      if (image.trim().isNotEmpty) return image.trim();
    }

    final thumbnail = product.thumbnail?.trim();
    return thumbnail == null || thumbnail.isEmpty ? null : thumbnail;
  }
}

class _RecentlyViewedLoadingView extends StatelessWidget {
  const _RecentlyViewedLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('recently-viewed-loading'),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) =>
          const SizedBox(height: CustomerHomeV1Tokens.space12),
      itemBuilder: (_, _) => const _RecentlyViewedProductSkeleton(),
    );
  }
}

class _RecentlyViewedProductSkeleton extends StatelessWidget {
  const _RecentlyViewedProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 134,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 108,
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkeletonLine(width: 126),
                SizedBox(height: CustomerHomeV1Tokens.space8),
                _SkeletonLine(width: 78),
                SizedBox(height: CustomerHomeV1Tokens.space16),
                _SkeletonLine(width: 92),
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

class _RecentlyViewedStatus extends StatelessWidget {
  const _RecentlyViewedStatus({
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
