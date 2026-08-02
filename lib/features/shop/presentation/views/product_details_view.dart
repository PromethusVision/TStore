import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/product_sellers_section.dart';
import 'package:t_store/features/shop/presentation/widgets/rating_and_share.dart';

typedef ProductDetailsCurrentUserIdProvider = String? Function();

class ProductDetailsView extends StatefulWidget {
  final ProductEntity product;
  final RecentlyViewedProductsStorage? recentlyViewedProductsStorage;
  final ProductDetailsCurrentUserIdProvider? currentUserIdProvider;

  const ProductDetailsView({
    super.key,
    required this.product,
    this.recentlyViewedProductsStorage,
    this.currentUserIdProvider,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageSlider(
                product: widget.product,
                currentUserIdProvider: widget.currentUserIdProvider,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  TSizes.defaultSpace,
                  0,
                  TSizes.defaultSpace,
                  TSizes.defaultSpace,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductInfoCard(
                      product: widget.product,
                      sellerPriceSummary: _sellerPriceSummary,
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    RatingAndShare(product: widget.product),
                    ProductMetadata(product: widget.product),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    ProductSellersSection(
                      productId: widget.product.id,
                      productName: widget.product.name,
                      currentUserIdProvider: widget.currentUserIdProvider,
                      onPriceSummaryChanged: _updateSellerPriceSummary,
                      onBrowseOtherProducts: () {
                        Navigator.of(context).maybePop();
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final description = product.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          ProductSellerPriceSummaryView(summary: sellerPriceSummary),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            hasDescription ? description : 'Bu ürün için açıklama eklenmemiş.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: hasDescription
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
