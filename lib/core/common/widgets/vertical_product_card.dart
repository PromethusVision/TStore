import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/brand_title_with_verification_view_model.dart';
import 'package:t_store/core/common/view_models/circular_container_view_model.dart';
import 'package:t_store/core/common/view_models/circular_icon_view_model.dart';
import 'package:t_store/core/common/view_models/product_price_text_view_model.dart';
import 'package:t_store/core/common/view_models/product_title_text_view_model.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/brand_title_with_verification.dart';
import 'package:t_store/core/common/widgets/circular_container.dart';
import 'package:t_store/core/common/widgets/circular_icon.dart';
import 'package:t_store/core/common/widgets/product_price_text.dart';
import 'package:t_store/core/common/widgets/product_title_text.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/common/widgets/sale_tag.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/shadow_styles.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

class VerticalProductCard extends StatelessWidget {
  const VerticalProductCard({
    super.key,
    required this.product,
    this.showFavoriteAction = false,
    this.favoriteActionLoading = false,
    this.onFavoritePressed,
    this.currentUserIdProvider,
  });

  final ProductEntity product;
  final bool showFavoriteAction;
  final bool favoriteActionLoading;
  final VoidCallback? onFavoritePressed;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final displayImage = _displayImage;
    final isNetworkImage = _isNetworkImage(displayImage);

    return GestureDetector(
      onTap: () {
        THelperFunctions.navigateToScreen(
          context,
          ProductDetailsView(
            product: product,
            currentUserIdProvider: currentUserIdProvider,
          ),
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductCardShadow],
          borderRadius: const BorderRadius.all(
            Radius.circular(TSizes.productImageRadius),
          ),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularContainer(
              circularContainerModel: CircularContainerModel(
                padding: const EdgeInsets.all(TSizes.sm),
                height: 180,
                color: dark ? TColors.dark : TColors.light,
                child: Stack(
                  children: [
                    RoundedImage(
                      roundedImageModel: RoundedImageModel(
                        isNetworkImage: isNetworkImage,
                        backgroundColor: dark ? TColors.dark : TColors.light,
                        image: displayImage,
                        onTap: () {},
                        applyImageRadius: true,
                      ),
                    ),
                    Row(
                      children: [
                        if (product.hasDiscount)
                          SaleTag(
                            discountPercentage: product.discountPercentage,
                          ),
                        const Spacer(),
                        if (showFavoriteAction)
                          if (favoriteActionLoading ||
                              onFavoritePressed != null)
                            Tooltip(
                              message: 'Favorilerden çıkar',
                              child: favoriteActionLoading
                                  ? GestureDetector(
                                      key: Key(
                                        'favorite-action-loading-${product.id}',
                                      ),
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {},
                                      child: Container(
                                        width: TSizes.iconLg * 1.2,
                                        height: TSizes.iconLg * 1.2,
                                        padding: const EdgeInsets.all(
                                          TSizes.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: dark
                                              ? TColors.darkerGrey
                                              : TColors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : CircularIcon(
                                      key: Key('favorite-action-${product.id}'),
                                      circularIconModel: CircularIconModel(
                                        height: TSizes.iconLg * 1.2,
                                        width: TSizes.iconLg * 1.2,
                                        iconSize: TSizes.iconMd,
                                        icon: Iconsax.heart5,
                                        color: Colors.red,
                                        backgroundColor: dark
                                            ? TColors.darkerGrey
                                            : TColors.white,
                                        onPressed: onFavoritePressed,
                                      ),
                                    ),
                            )
                          else
                            ProductFavoriteButton(
                              productId: product.id,
                              keyPrefix:
                                  'vertical-product-card-favorite-${product.id}',
                              currentUserIdProvider: currentUserIdProvider,
                              height: TSizes.iconLg * 1.2,
                              width: TSizes.iconLg * 1.2,
                              iconSize: TSizes.iconMd,
                              backgroundColor: dark
                                  ? TColors.darkerGrey
                                  : TColors.white,
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductTitleText(
                    productTitleTextModel: ProductTitleTextModel(
                      title: product.name,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  BrandTitleWithVerification(
                    brandTitleWithVerificationModel:
                        BrandTitleWithVerificationModel(
                          brandName: product.brandName ?? '',
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ProductPriceText(
                          productPriceTextModel: ProductPriceTextModel(
                            price: product.effectivePrice.toStringAsFixed(2),
                            maxLines: 1,
                            smallSize: true,
                          ),
                        ),
                      ),
                      const _DetailsBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _displayImage {
    for (final image in product.images) {
      if (image.trim().isNotEmpty) return image.trim();
    }

    final thumbnail = product.thumbnail;
    if (thumbnail != null && thumbnail.trim().isNotEmpty) {
      return thumbnail.trim();
    }

    return TImages.productImage13;
  }

  bool _isNetworkImage(String image) {
    return image.startsWith('http://') || image.startsWith('https://');
  }
}

class _DetailsBadge extends StatelessWidget {
  const _DetailsBadge();

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: dark ? TColors.dark : TColors.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusMd),
          bottomRight: Radius.circular(TSizes.productImageRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detay',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: dark ? TColors.white : TColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: dark ? TColors.white : TColors.primary,
          ),
        ],
      ),
    );
  }
}
