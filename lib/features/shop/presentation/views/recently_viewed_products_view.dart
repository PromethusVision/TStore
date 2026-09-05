import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/common/widgets/progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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

class _RecentlyViewedProductsContent extends StatefulWidget {
  const _RecentlyViewedProductsContent({
    required this.customerId,
    required this.onExplore,
    required this.productDestinationBuilder,
  });

  final String customerId;
  final VoidCallback? onExplore;
  final RecentlyViewedProductDestinationBuilder? productDestinationBuilder;

  @override
  State<_RecentlyViewedProductsContent> createState() =>
      _RecentlyViewedProductsContentState();
}

class _RecentlyViewedProductsContentState
    extends State<_RecentlyViewedProductsContent> {
  final Set<String> _openingProductIds = {};
  final Set<String> _removingProductIds = {};
  bool _isOpeningExplore = false;
  bool _isConfirmingClear = false;

  String get customerId => widget.customerId;
  VoidCallback? get onExplore => widget.onExplore;
  RecentlyViewedProductDestinationBuilder? get productDestinationBuilder =>
      widget.productDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            key: const Key('recently-viewed-customer-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xs,
                EsnaftaVarSpacing.md,
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
                          const SizedBox(height: EsnaftaVarSpacing.md),
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
      color: EsnaftaVarColors.primary,
      backgroundColor: EsnaftaVarColors.surface,
      onRefresh: () =>
          context.read<RecentlyViewedProductsCubit>().load(customerId),
      child: ListView.separated(
        key: const Key('recently-viewed-products-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xl),
        itemCount: products.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: EsnaftaVarSpacing.sm),
        itemBuilder: (context, index) => _RecentlyViewedProductCard(
          product: products[index],
          customerId: customerId,
          onTap: products[index].id.trim().isEmpty
              ? null
              : () => _openProduct(context, products[index]),
          onRemove: () => _removeProduct(context, products[index]),
        ),
      ),
    );
  }

  Future<void> _openProduct(BuildContext context, ProductEntity product) async {
    final productId = product.id.trim();
    if (productId.isEmpty || _openingProductIds.contains(productId)) return;

    _openingProductIds.add(productId);
    try {
      final destination =
          productDestinationBuilder?.call(product) ??
          ProductDetailsView(product: product);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));

      if (!context.mounted) return;
      await context.read<RecentlyViewedProductsCubit>().load(customerId);
    } finally {
      _openingProductIds.remove(productId);
    }
  }

  Future<void> _openExplore(BuildContext context) async {
    if (_isOpeningExplore) return;

    _isOpeningExplore = true;
    try {
      final exploreAction = onExplore;
      if (exploreAction != null) {
        await Future<void>.sync(exploreAction);
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const AllProductsView()),
      );
    } finally {
      _isOpeningExplore = false;
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (_isConfirmingClear) return;

    _isConfirmingClear = true;
    var dialogResultSubmitted = false;
    void completeDialog(BuildContext dialogContext, bool result) {
      if (dialogResultSubmitted) return;
      dialogResultSubmitted = true;
      Navigator.of(dialogContext).pop(result);
    }

    try {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          backgroundColor: EsnaftaVarColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
          ),
          title: const Text(
            'Görüntüleme geçmişi silinsin mi?',
            style: TextStyle(
              color: EsnaftaVarColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Bu tarayıcıda kaydedilen son görüntülenen ürünler kaldırılacak.',
            style: TextStyle(color: EsnaftaVarColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => completeDialog(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => completeDialog(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: EsnaftaVarColors.accent,
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
    } finally {
      _isConfirmingClear = false;
    }
  }

  Future<void> _removeProduct(
    BuildContext context,
    ProductEntity product,
  ) async {
    final productId = product.id.trim();
    if (productId.isEmpty || _removingProductIds.contains(productId)) return;

    _removingProductIds.add(productId);
    final cubit = context.read<RecentlyViewedProductsCubit>();
    try {
      final removal = await cubit.removeProduct(customerId, productId);
      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      if (removal == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ürün geçmişten şu anda kaldırılamadı.'),
          ),
        );
        return;
      }

      var restoreRequested = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text('${product.name} geçmişten kaldırıldı.'),
          action: SnackBarAction(
            label: 'Geri Al',
            onPressed: () async {
              if (restoreRequested) return;
              restoreRequested = true;
              final didRestore = await cubit.restoreProduct(
                customerId,
                removal,
              );
              if (!didRestore && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ürün geçmişe geri eklenemedi.'),
                  ),
                );
              }
            },
          ),
        ),
      );
    } finally {
      _removingProductIds.remove(productId);
    }
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
    return Column(
      key: const Key('recently-viewed-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MergeSemantics(
              child: EsnaftaVarSurfaceIconButton(
                buttonKey: const Key('recently-viewed-back'),
                icon: Icons.arrow_back_rounded,
                tooltip: 'Geri',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EsnaftaVarSectionHeader(
                title: 'Son Görüntülediklerim',
                subtitle: _subtitle,
              ),
            ),
          ],
        ),
        if (onClear != null)
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message: 'Geçmişi temizle',
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Geçmişi temizle'),
              ),
            ),
          ),
      ],
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
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final supportingText = _supportingText;
    final isCompact = MediaQuery.sizeOf(context).width <= 340;

    return Semantics(
      button: onTap != null,
      label: '${product.name} ürününü yeniden görüntüle',
      child: Material(
        key: Key('recently-viewed-product-${product.id}'),
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: InkWell(
          key: Key('recently-viewed-product-link-${product.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          child: Container(
            padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
              border: Border.all(color: EsnaftaVarColors.borderDefault),
            ),
            child: Row(
              children: [
                _ProductThumbnail(product: product, width: isCompact ? 72 : 88),
                SizedBox(
                  width: isCompact
                      ? EsnaftaVarSpacing.xs
                      : EsnaftaVarSpacing.sm,
                ),
                Expanded(
                  child: SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        if (supportingText != null) ...[
                          const SizedBox(height: EsnaftaVarSpacing.xxs),
                          Text(
                            supportingText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: EsnaftaVarColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          _priceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: EsnaftaVarColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        const Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Ürünü İncele',
                              style: TextStyle(
                                color: EsnaftaVarColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: EsnaftaVarColors.primary,
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
                      ? EsnaftaVarSpacing.xxs
                      : EsnaftaVarSpacing.xs,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MergeSemantics(
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix: 'recently-viewed-favorite-${product.id}',
                        currentUserIdProvider: () => customerId,
                        height: 48,
                        width: 48,
                        iconSize: 18,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xs),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: PopupMenuButton<_RecentlyViewedProductAction>(
                        tooltip: 'Ürün işlemleri',
                        padding: EdgeInsets.zero,
                        color: EsnaftaVarColors.surface,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            EsnaftaVarRadii.medium,
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
                                  color: EsnaftaVarColors.accent,
                                  size: 20,
                                ),
                                SizedBox(width: EsnaftaVarSpacing.xs),
                                Flexible(
                                  child: Text(
                                    'Geçmişten kaldır',

                                    style: TextStyle(
                                      color: EsnaftaVarColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: EsnaftaVarColors.textSecondary,
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
      color: EsnaftaVarColors.primarySoft,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: EsnaftaVarColors.primary,
          size: 34,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
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
  Widget build(BuildContext context) => const Center(
    key: Key('recently-viewed-loading'),
    child: TLoadingIndicator(label: 'Görüntüleme geçmişi yükleniyor'),
  );
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
