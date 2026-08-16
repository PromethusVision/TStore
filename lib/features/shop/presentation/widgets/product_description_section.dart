import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/common/view_models/section_heading_view_model.dart';
import 'package:t_store/core/common/widgets/read_more.dart';
import 'package:t_store/core/common/widgets/section_heading.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';

class ProductDescriptionAndReviewsSection extends StatelessWidget {
  const ProductDescriptionAndReviewsSection({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final description = product.description?.trim();
    return Column(
      children: [
        SectionHeading(
          sectionHeadingModel: SectionHeadingModel(
            title: 'Ürün Açıklaması',
            showActionButton: false,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        ReadMore(
          text: description == null || description.isEmpty
              ? 'Bu ürün için açıklama eklenmemiş.'
              : description,
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeading(
              sectionHeadingModel: SectionHeadingModel(
                title: 'Değerlendirmeler (${product.reviewsCount})',
                showActionButton: false,
              ),
            ),
            TextButton(
              onPressed: () {
                THelperFunctions.navigateToScreen(
                  context,
                  ProductReviewsView(product: product),
                );
              },
              child: const Icon(Iconsax.arrow_right_3, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}
