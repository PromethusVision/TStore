import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/product_title_text_view_model.dart';
import 'package:t_store/core/common/widgets/product_title_text.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class ProductMetadata extends StatelessWidget {
  final ProductEntity product;

  const ProductMetadata({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: TSizes.spaceBtwItems,
          runSpacing: TSizes.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ProductTitleText(
              productTitleTextModel: ProductTitleTextModel(
                title: 'Stok durumu:',
              ),
            ),
            Text(
              'Mağazaya göre değişir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (product.brandName != null && product.brandName!.isNotEmpty) ...[
          const SizedBox(height: TSizes.spaceBtwItems / 1.5),
          Row(
            children: [
              ProductTitleText(
                productTitleTextModel: ProductTitleTextModel(title: 'Marka:'),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Text(
                product.brandName!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
