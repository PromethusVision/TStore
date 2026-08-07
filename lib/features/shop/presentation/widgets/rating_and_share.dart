import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class RatingAndShare extends StatelessWidget {
  const RatingAndShare({
    super.key,
    required this.product,
    required this.onReviewsTap,
  });

  final ProductEntity product;
  final VoidCallback onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final hasReviews = product.rating > 0 && product.reviewsCount > 0;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('product-reviews-action'),
              onTap: onReviewsTap,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: CustomerHomeV1Tokens.space4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFA66A00),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: CustomerHomeV1Tokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasReviews
                                ? '${product.rating.toStringAsFixed(1)} '
                                      '(${product.reviewsCount})'
                                : 'Henüz değerlendirme yok',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: CustomerHomeV1Tokens.navy,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: CustomerHomeV1Tokens.space4),
                          Text(
                            'Değerlendirmeleri gör',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: CustomerHomeV1Tokens.petrol,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: CustomerHomeV1Tokens.petrol,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        const Icon(Icons.share, size: 24, color: CustomerHomeV1Tokens.navy),
      ],
    );
  }
}
