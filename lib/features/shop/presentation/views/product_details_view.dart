import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';
import 'package:t_store/features/shop/presentation/widgets/rating_and_share.dart';

typedef ProductDetailsCurrentUserIdProvider = String? Function();
typedef ProductReviewsDestinationBuilder =
    Widget Function(ProductEntity product);

class ProductDetailsView extends StatefulWidget {
  final ProductEntity product;
  final RecentlyViewedProductsStorage? recentlyViewedProductsStorage;
  final ProductDetailsCurrentUserIdProvider? currentUserIdProvider;
  final ProductReviewsDestinationBuilder? reviewsDestinationBuilder;

  const ProductDetailsView({
    super.key,
    required this.product,
    this.recentlyViewedProductsStorage,
    this.currentUserIdProvider,
    this.reviewsDestinationBuilder,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  ProductSellerPriceSummary _sellerPriceSummary =
      const ProductSellerPriceSummary.loading();

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

  void _openProductReviews() {
    final destination =
        widget.reviewsDestinationBuilder?.call(widget.product) ??
        ProductReviewsView(product: widget.product);
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
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
