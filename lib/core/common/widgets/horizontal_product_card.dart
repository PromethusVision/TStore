import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/brand_title_with_verification_view_model.dart';
import 'package:t_store/core/common/view_models/circular_container_view_model.dart';
import 'package:t_store/core/common/view_models/product_price_text_view_model.dart';
import 'package:t_store/core/common/view_models/product_title_text_view_model.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/add_to_cart_container.dart';
import 'package:t_store/core/common/widgets/brand_title_with_verification.dart';
import 'package:t_store/core/common/widgets/circular_container.dart';
import 'package:t_store/core/common/widgets/product_price_text.dart';
import 'package:t_store/core/common/widgets/product_title_text.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/common/widgets/sale_tag.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

class HorizontalProductCard extends StatelessWidget {
  const HorizontalProductCard({
    super.key,
    required this.product,
    this.currentUserIdProvider,
  });

  final ProductEntity product;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final image = product.images.isNotEmpty
        ? product.images.first
        : TImages.productImage11;
    final isNetworkImage = image.startsWith('http');

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
        width: 310,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(TSizes.productImageRadius),
          ),
          color: dark ? TColors.darkerGrey : TColors.lightContainer,
        ),
        child: Row(
          children: [
            CircularContainer(
              circularContainerModel: CircularContainerModel(
                padding: const EdgeInsets.all(TSizes.sm),
                height: 120,
                color: dark ? TColors.dark : TColors.light,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: RoundedImage(
                        roundedImageModel: RoundedImageModel(
                          applyImageRadius: true,
                          backgroundColor: dark ? TColors.dark : TColors.light,
                          image: image,
                          isNetworkImage: isNetworkImage,
                        ),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 12,
                        child: SaleTag(
                          discountPercentage: product.discountPercentage,
                        ),
                      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix:
                            'horizontal-product-card-favorite-${product.id}',
                        currentUserIdProvider: currentUserIdProvider,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 172,
              child: Padding(
                padding: const EdgeInsets.only(top: TSizes.sm, left: TSizes.sm),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductTitleText(
                          productTitleTextModel: ProductTitleTextModel(
                            title: product.name,
                            smallSize: true,
                          ),
                        ),
                        if (product.brandName != null &&
                            product.brandName!.isNotEmpty) ...[
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          BrandTitleWithVerification(
                            brandTitleWithVerificationModel:
                                BrandTitleWithVerificationModel(
                                  brandName: product.brandName!,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: ProductPriceText(
                            productPriceTextModel: ProductPriceTextModel(
                              price: product.price.toStringAsFixed(2),
                              smallSize: true,
                            ),
                          ),
                        ),
                        const AddToCartContainer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
