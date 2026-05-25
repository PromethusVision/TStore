import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/brand_title_with_verification_view_model.dart';
import 'package:t_store/core/common/view_models/product_price_text_view_model.dart';
import 'package:t_store/core/common/view_models/product_title_text_view_model.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/brand_title_with_verification.dart';
import 'package:t_store/core/common/widgets/product_price_text.dart';
import 'package:t_store/core/common/widgets/product_title_text.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class ProductMetadata extends StatelessWidget {
  final ProductEntity product;

  const ProductMetadata({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          ProductPriceText(
              productPriceTextModel: ProductPriceTextModel(
            price: product.price.toStringAsFixed(2),
            smallSize: false,
          ))
        ],
      ),
      const SizedBox(
        height: TSizes.spaceBtwItems / 1.5,
      ),
      ProductTitleText(
          productTitleTextModel: ProductTitleTextModel(
        title: product.name,
      )),
      const SizedBox(
        height: TSizes.spaceBtwItems / 1.5,
      ),
      Row(
        children: [
          ProductTitleText(
              productTitleTextModel: ProductTitleTextModel(
            title: "Status",
          )),
          const SizedBox(
            width: TSizes.spaceBtwItems,
          ),
          Text(
            product.isInStock ? "In Stock" : "Out of Stock",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      const SizedBox(
        height: TSizes.spaceBtwItems / 1.5,
      ),
      Row(
        children: [
          RoundedImage(
            roundedImageModel: RoundedImageModel(
              image: TImages.nikeLogo,
              width: 32,
              height: 32,
              backgroundColor: dark ? TColors.black : TColors.white,
              overlayColor: dark ? TColors.white : TColors.black,
            ),
          ),
          BrandTitleWithVerification(
            brandTitleWithVerificationModel:
                BrandTitleWithVerificationModel(brandName: product.brandName ?? ""),
          ),
        ],
      ),
    ]);
  }
}
