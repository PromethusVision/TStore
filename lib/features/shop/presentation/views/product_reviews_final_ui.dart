part of 'product_reviews_view.dart';

class _ReviewsFinalHeader extends StatelessWidget {
  const _ReviewsFinalHeader({required this.productName});
  final String productName;

  @override
  Widget build(BuildContext context) => Row(
    key: const Key('product-reviews-header'),
    children: [
      EsnaftaVarSurfaceIconButton(
        buttonKey: const Key('product-reviews-back'),
        icon: Icons.arrow_back_rounded,
        tooltip: 'Geri',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Değerlendirmeler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EsnaftaVarColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ReviewsFinalSummary extends StatelessWidget {
  const _ReviewsFinalSummary({required this.stats});
  final ProductReviewStats stats;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('product-reviews-summary'),
    padding: const EdgeInsets.all(16),
    decoration: _reviewsFinalSurface,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ÜRÜN PUANI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EsnaftaVarColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 36,
                  color: EsnaftaVarColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              _StarRow(rating: stats.averageRating),
              const SizedBox(height: 8),
              Text(
                '${stats.totalReviews} değerlendirme',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (var rating = 5; rating >= 1; rating--)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        child: Text(
                          '$rating',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Semantics(
                          label:
                              '$rating yıldız, ${stats.ratingDistribution[rating] ?? 0} değerlendirme',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stats.totalReviews == 0
                                  ? 0
                                  : ((stats.ratingDistribution[rating] ?? 0) /
                                            stats.totalReviews)
                                        .clamp(0, 1),
                              minHeight: 6,
                              color: EsnaftaVarColors.primary,
                              backgroundColor: EsnaftaVarColors.primarySoft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

final _reviewsFinalSurface = BoxDecoration(
  color: EsnaftaVarColors.surface,
  borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
  border: Border.all(color: EsnaftaVarColors.borderDefault),
);

// The existing eligibility switch supplies all content and callbacks.
Widget _buildReviewsFinalAction(
  _ReviewActionCard card,
  BuildContext context,
) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: EsnaftaVarColors.primarySoft,
    borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, size: 20, color: EsnaftaVarColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  card.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      if (card.actionLabel != null) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('product-review-eligibility-action'),
            onPressed: card.onAction == null ? null : () => card.onAction!(),
            child: Text(card.actionLabel!),
          ),
        ),
      ],
    ],
  ),
);

Widget _buildReviewsFinalCard(_ReviewCard card, BuildContext context) {
  final review = card.review;
  final title = review.title?.trim();
  final comment = review.comment?.trim();
  return Container(
    key: Key('product-review-${review.id}'),
    padding: const EdgeInsets.all(16),
    decoration: _reviewsFinalSurface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                review.canEdit
                    ? 'Sizin değerlendirmeniz'
                    : 'Esnafta Var kullanıcısı',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _formatReviewDate(review.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EsnaftaVarColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StarRow(rating: review.rating.toDouble()),
        if (review.isVerifiedPurchase) ...[
          const SizedBox(height: 8),
          Row(
            key: Key('product-review-verified-${review.id}'),
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: EsnaftaVarColors.success,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Doğrulanmış Alışveriş',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (title != null && title.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
        const SizedBox(height: 6),
        Text(
          comment == null || comment.isEmpty
              ? 'Yalnızca puan verildi.'
              : comment,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: EsnaftaVarColors.textSecondary,
          ),
        ),
        if (review.canEdit) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  key: Key('product-review-edit-${review.id}'),
                  onPressed: card.isMutating ? null : () => card.onEdit(review),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Düzenle'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  key: Key('product-review-delete-${review.id}'),
                  onPressed: card.isMutating
                      ? null
                      : () => card.onDelete(review),
                  style: TextButton.styleFrom(
                    foregroundColor: EsnaftaVarColors.error,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Sil'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
