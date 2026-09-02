import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';
import 'package:t_store/features/shop/presentation/widgets/rating_and_share.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

typedef ProductDetailsCurrentUserIdProvider = String? Function();
typedef ProductReviewsDestinationBuilder =
    Widget Function(ProductEntity product);

class ProductDetailsView extends StatefulWidget {
  final ProductEntity product;
  final RecentlyViewedProductsStorage? recentlyViewedProductsStorage;
  final ProductDetailsCurrentUserIdProvider? currentUserIdProvider;
  final ProductReviewsDestinationBuilder? reviewsDestinationBuilder;
  final bool visualPrototype;

  const ProductDetailsView({
    super.key,
    required this.product,
    this.recentlyViewedProductsStorage,
    this.currentUserIdProvider,
    this.reviewsDestinationBuilder,
    this.visualPrototype = false,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  ProductSellerPriceSummary _sellerPriceSummary =
      const ProductSellerPriceSummary.loading();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _sellersSectionKey = GlobalKey();
  bool _isOpeningProductReviews = false;

  @override
  void initState() {
    super.initState();
    _recordProductView();
  }

  void _recordProductView() {
    final currentUserIdProvider = widget.currentUserIdProvider;
    final customerId =
        (currentUserIdProvider != null
                ? currentUserIdProvider()
                : SupabaseService.instance.currentUser?.id)
            ?.trim();
    if (customerId == null || customerId.isEmpty) return;

    final storage =
        widget.recentlyViewedProductsStorage ??
        (sl.isRegistered<RecentlyViewedProductsStorage>()
            ? sl<RecentlyViewedProductsStorage>()
            : null);
    if (storage == null) return;

    unawaited(
      _recordSafely(
        storage: storage,
        customerId: customerId,
        productId: widget.product.id,
      ),
    );
  }

  Future<void> _recordSafely({
    required RecentlyViewedProductsStorage storage,
    required String customerId,
    required String productId,
  }) async {
    try {
      await storage.recordProduct(customerId: customerId, productId: productId);
    } catch (_) {
      // Görüntüleme geçmişi temel ürün deneyimini engellememelidir.
    }
  }

  void _updateSellerPriceSummary(ProductSellerPriceSummary summary) {
    if (!mounted || _sellerPriceSummary == summary) return;
    setState(() => _sellerPriceSummary = summary);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openProductReviews() async {
    final productId = widget.product.id.trim();
    if (_isOpeningProductReviews || productId.isEmpty) return;

    _isOpeningProductReviews = true;
    try {
      final product = widget.product.id == productId
          ? widget.product
          : widget.product.copyWith(id: productId);
      final destination =
          widget.reviewsDestinationBuilder?.call(product) ??
          ProductReviewsView(product: product);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _isOpeningProductReviews = false;
    }
  }

  Future<void> _showSellerComparison() async {
    final sellerContext = _sellersSectionKey.currentContext;
    if (sellerContext == null) return;
    await Scrollable.ensureVisible(
      sellerContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visualPrototype) {
      return _buildVisualPrototype(context);
    }

    final compactLayout = MediaQuery.sizeOf(context).width < 360;
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('product-details-scroll'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageSlider(
                    product: widget.product,
                    currentUserIdProvider: widget.currentUserIdProvider,
                  ),
                  Padding(
                    key: const Key('product-details-content'),
                    padding: EdgeInsets.fromLTRB(
                      compactLayout ? 8 : 16,
                      16,
                      compactLayout ? 8 : 16,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductInfoCard(
                          product: widget.product,
                          sellerPriceSummary: _sellerPriceSummary,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        _ProductFactsCard(
                          product: widget.product,
                          onReviewsTap: _openProductReviews,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space16),
                        _ProductSellersCard(
                          child: ProductSellersSection(
                            productId: widget.product.id,
                            productName: widget.product.name,
                            currentUserIdProvider: widget.currentUserIdProvider,
                            onPriceSummaryChanged: _updateSellerPriceSummary,
                            onBrowseOtherProducts: () {
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPrototype(BuildContext context) {
    return Scaffold(
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                _ProductDetailsHeader(
                  product: widget.product,
                  currentUserIdProvider: widget.currentUserIdProvider,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('product-details-scroll'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.sm,
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImageSlider(
                          product: widget.product,
                          currentUserIdProvider: widget.currentUserIdProvider,
                          visualPrototype: true,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        _ProductIdentity(product: widget.product),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        _LocalAvailabilityCard(
                          summary: _sellerPriceSummary,
                          onCompareTap: _showSellerComparison,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        _FinalProductInformation(product: widget.product),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        _FinalProductReviews(
                          product: widget.product,
                          onTap: _openProductReviews,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        KeyedSubtree(
                          key: _sellersSectionKey,
                          child: _FinalSellerComparison(
                            child: ProductSellersSection(
                              productId: widget.product.id,
                              productName: widget.product.name,
                              currentUserIdProvider:
                                  widget.currentUserIdProvider,
                              onPriceSummaryChanged: _updateSellerPriceSummary,
                              onBrowseOtherProducts: () {
                                Navigator.of(context).maybePop();
                              },
                            ),
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
      ),
    );
  }
}

class _ProductDetailsHeader extends StatelessWidget {
  const _ProductDetailsHeader({
    required this.product,
    required this.currentUserIdProvider,
  });

  final ProductEntity product;
  final ProductDetailsCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('product-details-final-header'),
      padding: const EdgeInsets.fromLTRB(
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.xs,
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: EsnaftaVarColors.background,
        border: Border(bottom: BorderSide(color: EsnaftaVarColors.divider)),
      ),
      child: Row(
        children: [
          Material(
            color: EsnaftaVarColors.surfaceElevated,
            shape: const CircleBorder(
              side: BorderSide(color: EsnaftaVarColors.borderDefault),
            ),
            child: IconButton(
              key: const Key('product-details-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: EsnaftaVarColors.primary,
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YEREL ÜRÜN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  'Ürün detayları',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: EsnaftaVarColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          ProductFavoriteButton(
            productId: product.id,
            keyPrefix: 'product-details-favorite',
            currentUserIdProvider: currentUserIdProvider,
            height: EsnaftaVarTouchTargets.minimum,
            width: EsnaftaVarTouchTargets.minimum,
            iconSize: EsnaftaVarIconSizes.medium,
            backgroundColor: EsnaftaVarColors.surfaceElevated,
          ),
        ],
      ),
    );
  }
}

class _ProductIdentity extends StatelessWidget {
  const _ProductIdentity({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final brand = product.brandName?.trim();
    final category = product.categoryName?.trim();

    return Column(
      key: const Key('product-details-info-card'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null && category.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: EsnaftaVarSpacing.sm,
              vertical: EsnaftaVarSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: EsnaftaVarColors.accentSoft,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
            ),
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EsnaftaVarColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
        ],
        Text(
          product.name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: EsnaftaVarColors.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (brand != null && brand.isNotEmpty) ...[
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Text(
            brand,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EsnaftaVarColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _LocalAvailabilityCard extends StatelessWidget {
  const _LocalAvailabilityCard({
    required this.summary,
    required this.onCompareTap,
  });

  final ProductSellerPriceSummary summary;
  final VoidCallback onCompareTap;

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final canCompare =
        summary.status == ProductSellerPriceSummaryStatus.available;

    return Container(
      key: const Key('product-details-local-availability'),
      width: double.infinity,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: EsnaftaVarTouchTargets.minimum,
                height: EsnaftaVarTouchTargets.minimum,
                decoration: BoxDecoration(
                  color: EsnaftaVarColors.surface,
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: EsnaftaVarColors.primary,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.sellerLabel,
                      key: const Key('product-details-seller-count'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: EsnaftaVarColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (content.priceLabel != null) ...[
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          content.priceLabel!,
                          key: const Key('product-details-minimum-price'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: EsnaftaVarColors.price,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('product-details-compare-sellers'),
              onPressed: canCompare ? onCompareTap : null,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text('Esnafları karşılaştır'),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Text(
            'Fiyat ve stok seçtiğin esnafa göre değişir.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EsnaftaVarColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  _LocalAvailabilityContent get _content {
    switch (summary.status) {
      case ProductSellerPriceSummaryStatus.loading:
        return const _LocalAvailabilityContent(
          sellerLabel: 'Esnaf seçenekleri hazırlanıyor',
        );
      case ProductSellerPriceSummaryStatus.available:
        final count = summary.sellerCount;
        final sellerLabel = count == null
            ? 'Yerel esnaflarda mevcut'
            : '$count esnafta var';
        return _LocalAvailabilityContent(
          sellerLabel: sellerLabel,
          priceLabel: '${_formatTurkishPrice(summary.minimumPrice!)} TL’den',
        );
      case ProductSellerPriceSummaryStatus.empty:
        return const _LocalAvailabilityContent(
          sellerLabel: 'Şu anda aktif esnaf yok',
        );
      case ProductSellerPriceSummaryStatus.error:
        return const _LocalAvailabilityContent(
          sellerLabel: 'Esnaf bilgileri alınamadı',
        );
    }
  }
}

class _LocalAvailabilityContent {
  const _LocalAvailabilityContent({required this.sellerLabel, this.priceLabel});

  final String sellerLabel;
  final String? priceLabel;
}

class _FinalProductInformation extends StatelessWidget {
  const _FinalProductInformation({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim();
    final brand = product.brandName?.trim();
    final category = product.categoryName?.trim();

    return _FinalDetailsSurface(
      key: const Key('product-details-facts-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FinalSectionTitle(
            icon: Icons.info_outline_rounded,
            title: 'Ürün bilgileri',
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          Text(
            description == null || description.isEmpty
                ? 'Bu ürün için açıklama eklenmemiş.'
                : description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: description == null || description.isEmpty
                  ? EsnaftaVarColors.textMuted
                  : EsnaftaVarColors.textSecondary,
            ),
          ),
          if ((brand != null && brand.isNotEmpty) ||
              (category != null && category.isNotEmpty)) ...[
            const SizedBox(height: EsnaftaVarSpacing.sm),
            Wrap(
              spacing: EsnaftaVarSpacing.xs,
              runSpacing: EsnaftaVarSpacing.xs,
              children: [
                if (brand != null && brand.isNotEmpty)
                  _ProductFactChip(label: 'Marka: $brand'),
                if (category != null && category.isNotEmpty)
                  _ProductFactChip(label: 'Kategori: $category'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FinalProductReviews extends StatelessWidget {
  const _FinalProductReviews({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasReviews = product.rating > 0 && product.reviewsCount > 0;

    return Material(
      color: EsnaftaVarColors.surfaceElevated,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
      child: InkWell(
        key: const Key('product-reviews-action'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        child: Container(
          key: const Key('product-details-reviews-preview'),
          padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: EsnaftaVarTouchTargets.minimum,
                height: EsnaftaVarTouchTargets.minimum,
                decoration: const BoxDecoration(
                  color: EsnaftaVarColors.warningSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: EsnaftaVarColors.warning,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasReviews
                          ? '${product.rating.toStringAsFixed(1)} · ${product.reviewsCount} değerlendirme'
                          : 'Henüz değerlendirme yok',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: EsnaftaVarColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      'Değerlendirmeleri gör',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EsnaftaVarColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: EsnaftaVarColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalSellerComparison extends StatelessWidget {
  const _FinalSellerComparison({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FinalDetailsSurface(
      key: const Key('product-details-sellers-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FinalSectionTitle(
            icon: Icons.storefront_outlined,
            title: 'Yerel esnaf seçenekleri',
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Text(
            'Fiyat ve stok durumunu karşılaştır; fiziksel alışverişin için bir esnaf seç.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EsnaftaVarColors.textSecondary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.md),
            child: Divider(height: 1, color: EsnaftaVarColors.divider),
          ),
          child,
        ],
      ),
    );
  }
}

class _FinalDetailsSurface extends StatelessWidget {
  const _FinalDetailsSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.xs,
      ),
      child: child,
    );
  }
}

class _FinalSectionTitle extends StatelessWidget {
  const _FinalSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: EsnaftaVarIconSizes.medium,
          color: EsnaftaVarColors.primary,
        ),
        const SizedBox(width: EsnaftaVarSpacing.xs),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: EsnaftaVarColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductFactChip extends StatelessWidget {
  const _ProductFactChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EsnaftaVarSpacing.sm,
        vertical: EsnaftaVarSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceAlt,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: EsnaftaVarColors.textSecondary),
      ),
    );
  }
}

String _formatTurkishPrice(double price) {
  final parts = price.toStringAsFixed(2).split('.');
  final integerDigits = parts.first;
  final buffer = StringBuffer();
  for (var index = 0; index < integerDigits.length; index++) {
    if (index > 0 && (integerDigits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(integerDigits[index]);
  }
  return '$buffer,${parts.last}';
}

class _ProductInfoCard extends StatelessWidget {
  final ProductEntity product;
  final ProductSellerPriceSummary sellerPriceSummary;

  const _ProductInfoCard({
    required this.product,
    required this.sellerPriceSummary,
  });

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Container(
      key: const Key('product-details-info-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          ProductSellerPriceSummaryView(summary: sellerPriceSummary),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          const Text(
            'Ürün hakkında',
            style: TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space8),
          Text(
            hasDescription ? description : 'Bu ürün için açıklama eklenmemiş.',
            style: TextStyle(
              color: hasDescription
                  ? CustomerHomeV1Tokens.navy
                  : CustomerHomeV1Tokens.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFactsCard extends StatelessWidget {
  const _ProductFactsCard({required this.product, required this.onReviewsTap});

  final ProductEntity product;
  final VoidCallback onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.sizeOf(context).width < 360;
    return Container(
      key: const Key('product-details-facts-card'),
      width: double.infinity,
      padding: EdgeInsets.all(compactLayout ? 4 : 16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingAndShare(product: product, onReviewsTap: onReviewsTap),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: CustomerHomeV1Tokens.space12,
            ),
            child: Divider(height: 1, color: CustomerHomeV1Tokens.border),
          ),
          ProductMetadata(product: product),
        ],
      ),
    );
  }
}

class _ProductSellersCard extends StatelessWidget {
  const _ProductSellersCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('product-details-sellers-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: child,
    );
  }
}
