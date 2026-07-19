import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/shop/presentation/widgets/bottom_add_to_cart.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_slider.dart';
import 'package:t_store/features/shop/presentation/widgets/product_metadata.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAddToCart(product: widget.product),
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
                    _ProductInfoCard(product: widget.product),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    RatingAndShare(product: widget.product),
                    ProductMetadata(product: widget.product),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    Text(
                      'Bu ürünü mağaza sepetine eklemek için aşağıdaki esnaflardan seçim yapın.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    ProductSellersSection(productId: widget.product.id),
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

  const _ProductInfoCard({required this.product});

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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.md,
              vertical: TSizes.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '₺${product.effectivePrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
