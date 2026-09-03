import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';
import 'package:t_store/features/shop/presentation/widgets/selected_product_image.dart';

/// W43A product-owner visual gate for local seller comparison.
///
/// The view is intentionally not wired into production navigation yet. It
/// reuses [ProductSellersSection], so shop identity, sorting, distance, chat,
/// Shop Details handoff, and Cart V2 listing identifiers remain canonical.
class SellerComparisonView extends StatefulWidget {
  const SellerComparisonView({
    super.key,
    required this.product,
    this.currentUserIdProvider,
    this.chatDestinationBuilder,
    this.shopDestinationBuilder,
    this.pendingProductChatStorage,
    this.onChangeLocationRequested,
  });

  final ProductEntity product;
  final ProductSellerCurrentUserIdProvider? currentUserIdProvider;
  final ProductSellerChatDestinationBuilder? chatDestinationBuilder;
  final ProductSellerShopDestinationBuilder? shopDestinationBuilder;
  final PendingProductChatStorage? pendingProductChatStorage;
  final Future<void> Function()? onChangeLocationRequested;

  @override
  State<SellerComparisonView> createState() => _SellerComparisonViewState();
}

class _SellerComparisonViewState extends State<SellerComparisonView> {
  ProductSellerPriceSummary _summary =
      const ProductSellerPriceSummary.loading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const _SellerComparisonHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('seller-comparison-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.sm,
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductContextCard(
                          product: widget.product,
                          summary: _summary,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        ProductSellersSection(
                          productId: widget.product.id,
                          productName: widget.product.name,
                          currentUserIdProvider: widget.currentUserIdProvider,
                          chatDestinationBuilder: widget.chatDestinationBuilder,
                          shopDestinationBuilder: widget.shopDestinationBuilder,
                          pendingProductChatStorage:
                              widget.pendingProductChatStorage,
                          onChangeLocationRequested:
                              widget.onChangeLocationRequested,
                          onPriceSummaryChanged: _updateSummary,
                          visualPrototype: true,
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

  void _updateSummary(ProductSellerPriceSummary summary) {
    if (!mounted || summary == _summary) return;
    setState(() => _summary = summary);
  }
}

class _SellerComparisonHeader extends StatelessWidget {
  const _SellerComparisonHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('seller-comparison-header'),
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
              key: const Key('seller-comparison-back-button'),
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
                  'YEREL FİYAT KARŞILAŞTIRMA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  'Esnafları karşılaştır',
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
        ],
      ),
    );
  }
}

class _ProductContextCard extends StatelessWidget {
  const _ProductContextCard({required this.product, required this.summary});

  final ProductEntity product;
  final ProductSellerPriceSummary summary;

  @override
  Widget build(BuildContext context) {
    final category = product.categoryName?.trim();
    final brand = product.brandName?.trim();
    final contextLabel = [
      if (brand != null && brand.isNotEmpty) brand,
      if (category != null && category.isNotEmpty) category,
    ].join(' • ');

    return Container(
      key: const Key('seller-comparison-product-context'),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: EsnaftaVarColors.surfaceAlt,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
            ),
            child: SelectedProductImage(
              image: _productImage,
              height: 82,
              imageExtent: 66,
              padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contextLabel.isNotEmpty) ...[
                  Text(
                    contextLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: EsnaftaVarColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.xxs),
                ],
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: EsnaftaVarColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xs),
                _SellerSummaryLine(summary: summary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _productImage {
    for (final image in product.images) {
      if (image.trim().isNotEmpty) return image;
    }
    final thumbnail = product.thumbnail?.trim();
    return thumbnail == null || thumbnail.isEmpty ? '' : thumbnail;
  }
}

class _SellerSummaryLine extends StatelessWidget {
  const _SellerSummaryLine({required this.summary});

  final ProductSellerPriceSummary summary;

  @override
  Widget build(BuildContext context) {
    final text = switch (summary.status) {
      ProductSellerPriceSummaryStatus.loading => 'Yerel fiyatlar yükleniyor',
      ProductSellerPriceSummaryStatus.available =>
        '${summary.sellerCount ?? 0} esnaf • ${_formatPrice(summary.minimumPrice!)}’den',
      ProductSellerPriceSummaryStatus.empty => 'Henüz yerel satıcı yok',
      ProductSellerPriceSummaryStatus.error => 'Yerel fiyatlar alınamadı',
    };

    return Row(
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: EsnaftaVarIconSizes.small,
          color: EsnaftaVarColors.primary,
        ),
        const SizedBox(width: EsnaftaVarSpacing.xxs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: EsnaftaVarColors.primaryPressed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(2).split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '$whole,${parts.last} TL';
  }
}
