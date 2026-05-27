import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class RatingAndShare extends StatelessWidget {
  const RatingAndShare({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final hasReviews = product.rating > 0 && product.reviewsCount > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        hasReviews
            ? Row(
                children: [
                  const Icon(
                    Iconsax.star5,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${product.rating.toStringAsFixed(1)} ',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text: '(${product.reviewsCount})',
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                'Henüz yorum yok',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
        const Icon(
          Icons.share,
          size: TSizes.iconMd,
        )
      ],
    );
  }
}
