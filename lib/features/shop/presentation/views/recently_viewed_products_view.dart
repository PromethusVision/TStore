import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';

class RecentlyViewedProductsView extends StatelessWidget {
  const RecentlyViewedProductsView({
    super.key,
    required this.customerId,
    this.recentlyViewedProductsCubit,
    this.onExplore,
  });

  final String customerId;
  final RecentlyViewedProductsCubit? recentlyViewedProductsCubit;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (recentlyViewedProductsCubit ?? sl<RecentlyViewedProductsCubit>())
            ..load(customerId),
      child: _RecentlyViewedProductsContent(
        customerId: customerId,
        onExplore: onExplore,
      ),
    );
  }
}

class _RecentlyViewedProductsContent extends StatelessWidget {
  const _RecentlyViewedProductsContent({
    required this.customerId,
    required this.onExplore,
  });

  final String customerId;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Görüntülediklerim'),
        actions: [
          BlocBuilder<RecentlyViewedProductsCubit, RecentlyViewedProductsState>(
            builder: (context, state) {
              if (state is! RecentlyViewedProductsLoaded ||
                  state.products.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Geçmişi temizle',
                onPressed: () => _confirmClear(context),
                icon: const Icon(Icons.delete_sweep_outlined),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RecentlyViewedProductsCubit, RecentlyViewedProductsState>(
        builder: (context, state) {
          if (state is RecentlyViewedProductsInitial ||
              state is RecentlyViewedProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecentlyViewedProductsError) {
            return _RecentlyViewedStatus(
              icon: Icons.error_outline,
              title: 'Ürün geçmişin yüklenemedi',
              description: state.message,
              actionLabel: 'Tekrar Dene',
              onAction: () =>
                  context.read<RecentlyViewedProductsCubit>().load(customerId),
            );
          }

          final products = (state as RecentlyViewedProductsLoaded).products;
          if (products.isEmpty) {
            return _RecentlyViewedStatus(
              icon: Icons.history_outlined,
              title: 'Henüz görüntülediğin ürün yok',
              description:
                  'İncelediğin ürünler burada en yeniden eskiye sıralanacak.',
              actionLabel: 'Ürünleri Keşfet',
              onAction: () => _openExplore(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<RecentlyViewedProductsCubit>().load(customerId),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              itemCount: products.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) => _RecentlyViewedProductCard(
                product: products[index],
                onTap: () => _openProduct(context, products[index]),
                onRemove: () => _removeProduct(context, products[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openProduct(BuildContext context, ProductEntity product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailsView(product: product)),
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
    ).push(MaterialPageRoute(builder: (_) => const AllProductsView()));
  }

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Görüntüleme geçmişi silinsin mi?'),
        content: const Text(
          'Bu tarayıcıda kaydedilen son görüntülenen ürünler kaldırılacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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

enum _RecentlyViewedProductAction { remove }

class _RecentlyViewedProductCard extends StatelessWidget {
  const _RecentlyViewedProductCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final supportingText = _supportingText;

    return Semantics(
      button: true,
      label: '${product.name} ürününü yeniden görüntüle',
      child: Material(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Row(
              children: [
                _ProductThumbnail(product: product),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (supportingText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          supportingText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: TSizes.sm),
                      Text(
                        '₺${product.effectivePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ürünü İncele',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                PopupMenuButton<_RecentlyViewedProductAction>(
                  tooltip: 'Ürün işlemleri',
                  onSelected: (action) {
                    if (action == _RecentlyViewedProductAction.remove) {
                      onRemove();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _RecentlyViewedProductAction.remove,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: TSizes.sm),
                          Flexible(
                            child: Text(
                              'Geçmişten kaldır',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _supportingText {
    final brandName = product.brandName?.trim();
    if (brandName != null && brandName.isNotEmpty) return brandName;

    final categoryName = product.categoryName?.trim();
    if (categoryName != null && categoryName.isNotEmpty) return categoryName;

    return null;
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imagePath = _imagePath;
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_outlined, size: 32)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        height: 96,
        child: imagePath == null
            ? fallback
            : imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
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

class _RecentlyViewedStatus extends StatelessWidget {
  const _RecentlyViewedStatus({
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
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
