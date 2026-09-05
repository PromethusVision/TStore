// Visual-only candidates for FS-31/33 and MD-05/17/18. Callbacks are supplied
// by the fixture host; no service, repository, Cubit or auth is changed here.
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'sweep_frame.dart';

class SweepInbox extends StatelessWidget {
  const SweepInbox({super.key, required this.threads, required this.onOpen});
  final List<ChatThreadEntity> threads;
  final ValueChanged<ChatThreadEntity> onOpen;
  @override
  Widget build(BuildContext context) => SweepFrame(
    title: 'Mesajlarım',
    subtitle: 'Mağazalarla görüşmelerin',
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: threads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final thread = threads[index];
        return Semantics(
          button: true,
          label: '${thread.displayName}, ${thread.unreadCount} okunmamış mesaj',
          child: InkWell(
            key: Key('sweep-thread-${thread.otherUserId}'),
            onTap: () => onOpen(thread),
            borderRadius: BorderRadius.circular(16),
            child: SweepSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: EsnaftaVarColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: EsnaftaVarColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          thread.displayName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: EsnaftaVarColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    thread.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: thread.unreadCount > 0
                          ? EsnaftaVarColors.textPrimary
                          : EsnaftaVarColors.textSecondary,
                      fontWeight: thread.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (thread.lastMessageAt != null)
                        Text(
                          '${sweepDate(thread.lastMessageAt!)} · ${sweepTime(thread.lastMessageAt!)}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: EsnaftaVarColors.textMuted),
                        ),
                      const Spacer(),
                      if (thread.lastMessageIsMine)
                        Text(
                          thread.lastMessageIsRead ? 'Okundu' : 'Gönderildi',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: EsnaftaVarColors.primary),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class SweepShopRatings extends StatelessWidget {
  const SweepShopRatings({super.key, required this.purchases});
  final List<VerifiedPurchaseEntity> purchases;
  @override
  Widget build(BuildContext context) {
    final rated =
        purchases.where((purchase) => purchase.customerRating != null).toList()
          ..sort(
            (a, b) => (b.customerRatedAt ?? b.confirmedAt).compareTo(
              a.customerRatedAt ?? a.confirmedAt,
            ),
          );
    return SweepFrame(
      title: 'Esnaf değerlendirmelerim',
      subtitle: 'Mağazalara verdiğin puanlar',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: rated.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final purchase = rated[index];
          return SweepSurface(
            key: Key('sweep-rating-${purchase.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      color: EsnaftaVarColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        purchase.shopName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${purchase.customerRating}/5',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EsnaftaVarColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SweepStars(rating: purchase.customerRating!),
                const SizedBox(height: 8),
                Text(
                  'Değerlendirme: ${sweepDate(purchase.customerRatedAt ?? purchase.confirmedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textMuted,
                  ),
                ),
                const Divider(height: 28),
                Text(
                  'İlgili alışveriş',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${purchase.itemCount} ürün',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      sweepMoney(purchase.totalAmount),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Alışveriş tarihi: ${sweepDate(purchase.confirmedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SweepShopRatingEditor extends StatefulWidget {
  const SweepShopRatingEditor({
    super.key,
    required this.purchase,
    required this.onSubmit,
    required this.onClose,
  });
  final VerifiedPurchaseEntity purchase;
  final void Function(String qrSessionId, int rating) onSubmit;
  final VoidCallback onClose;
  @override
  State<SweepShopRatingEditor> createState() => _SweepShopRatingEditorState();
}

class _SweepShopRatingEditorState extends State<SweepShopRatingEditor> {
  int _rating = 0;
  @override
  Widget build(BuildContext context) => SweepSheet(
    title: 'Esnafa puan ver',
    subtitle: widget.purchase.shopName,
    onClose: widget.onClose,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SweepSurface(
          color: EsnaftaVarColors.primarySoft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_outlined,
                color: EsnaftaVarColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Puanın doğrulanmış alışverişine dayanır ve yalnızca bir kez gönderilebilir.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Mağaza deneyimin nasıldı?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: SweepStars(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _rating == 0
              ? 'Bir yıldız seç'
              : const [
                  '',
                  'Çok kötü',
                  'Kötü',
                  'Orta',
                  'İyi',
                  'Çok iyi',
                ][_rating],
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: EsnaftaVarColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('sweep-rating-submit'),
          onPressed: _rating == 0 || widget.purchase.customerRating != null
              ? null
              : () =>
                    widget.onSubmit(widget.purchase.sourceQrSessionId, _rating),
          child: const Text('Puanı gönder'),
        ),
      ],
    ),
  );
}

typedef SweepReviewSubmit =
    void Function(
      String productId,
      String? reviewId,
      int rating,
      String title,
      String comment,
    );

class SweepReviewEditor extends StatefulWidget {
  const SweepReviewEditor({
    super.key,
    required this.productId,
    required this.productName,
    required this.eligibility,
    required this.onSubmit,
    required this.onClose,
    this.review,
  });
  final String productId;
  final String productName;
  final ProductReviewEligibility eligibility;
  final ReviewEntity? review;
  final SweepReviewSubmit onSubmit;
  final VoidCallback onClose;
  @override
  State<SweepReviewEditor> createState() => _SweepReviewEditorState();
}

class _SweepReviewEditorState extends State<SweepReviewEditor> {
  late final TextEditingController _title = TextEditingController(
    text: widget.review?.title ?? '',
  );
  late final TextEditingController _comment = TextEditingController(
    text: widget.review?.comment ?? '',
  );
  late int _rating = widget.review?.rating ?? 0;
  @override
  void dispose() {
    _title.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Visual fixture only; runtime Cubit/RPC remains authoritative on integration.
    final eligible = widget.review != null
        ? widget.review!.canEdit
        : widget.eligibility.status == ProductReviewEligibilityStatus.canSubmit;
    return SweepSheet(
      title: widget.review == null
          ? 'Ürünü değerlendir'
          : 'Değerlendirmeni düzenle',
      subtitle: widget.productName,
      onClose: widget.onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ürüne puanın', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Center(
            child: SweepStars(
              rating: _rating,
              onChanged: eligible
                  ? (value) => setState(() => _rating = value)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('sweep-review-title'),
            controller: _title,
            enabled: eligible,
            decoration: const InputDecoration(
              labelText: 'Kısa başlık (isteğe bağlı)',
              hintText: 'Deneyimini özetle',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('sweep-review-comment'),
            controller: _comment,
            enabled: eligible,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Yorum (isteğe bağlı)',
              hintText: 'Ürünle ilgili deneyimini paylaş',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('sweep-review-submit'),
            onPressed: eligible && _rating > 0
                ? () => widget.onSubmit(
                    widget.productId,
                    widget.review?.id,
                    _rating,
                    _title.text,
                    _comment.text,
                  )
                : null,
            child: Text(
              widget.review == null
                  ? 'Değerlendirmeyi paylaş'
                  : 'Değişiklikleri kaydet',
            ),
          ),
        ],
      ),
    );
  }
}

class SweepReviewDelete extends StatelessWidget {
  const SweepReviewDelete({
    super.key,
    required this.review,
    required this.onDelete,
    required this.onCancel,
  });
  final ReviewEntity review;
  final ValueChanged<ReviewEntity> onDelete;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: EsnaftaVarColors.surface,
    surfaceTintColor: Colors.transparent,
    title: const Text('Değerlendirme silinsin mi?'),
    icon: const Icon(
      Icons.delete_outline_rounded,
      color: EsnaftaVarColors.error,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (review.title?.isNotEmpty == true) ...[
          Text(review.title!, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
        ],
        const Text(
          'Değerlendirmen ürün puanından çıkarılır. Doğrulanmış alışveriş kaydın korunur; daha sonra yeniden değerlendirme yapabilirsin.',
        ),
      ],
    ),
    actions: [
      TextButton(
        key: const Key('sweep-delete-cancel'),
        onPressed: onCancel,
        child: const Text('Vazgeç'),
      ),
      FilledButton(
        key: const Key('sweep-delete-confirm'),
        onPressed: review.canEdit ? () => onDelete(review) : null,
        style: FilledButton.styleFrom(backgroundColor: EsnaftaVarColors.error),
        child: const Text('Sil'),
      ),
    ],
  );
}
