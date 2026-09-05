part of 'purchases_view.dart';

class _PurchasesPrototypeHeader extends StatelessWidget {
  const _PurchasesPrototypeHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            EsnaftaVarSurfaceIconButton(
              buttonKey: const Key('customer-purchases-back-button'),
              icon: Icons.arrow_back_rounded,
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: EsnaftaVarSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAĞAZADAKİ ALIŞVERİŞLERİN',
                    style: text.labelSmall?.copyWith(
                      color: EsnaftaVarColors.accent,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text('Alışverişlerim', style: text.titleLarge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EsnaftaVarSpacing.md),
        Text(
          'Mağazada QR ile doğrulanan alışverişlerin.',
          style: text.bodyMedium?.copyWith(
            color: EsnaftaVarColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

Widget _buildPurchasePrototypeCard(
  _PurchaseCardState view,
  BuildContext context,
) {
  final purchase = view.widget.purchase;
  final text = Theme.of(context).textTheme;
  return Container(
    key: ValueKey('customer-purchase-card-${purchase.id}'),
    padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
    decoration: BoxDecoration(
      color: EsnaftaVarColors.surface,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      border: Border.all(color: EsnaftaVarColors.borderDefault),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: EsnaftaVarColors.primarySoft,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: EsnaftaVarColors.primary,
              ),
            ),
            const SizedBox(width: EsnaftaVarSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(purchase.shopName, style: text.titleMedium),
                  const SizedBox(height: EsnaftaVarSpacing.xxs),
                  Text(
                    _formatDate(purchase.confirmedAt),
                    style: text.bodySmall?.copyWith(
                      color: EsnaftaVarColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: EsnaftaVarSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 16,
              color: EsnaftaVarColors.success,
            ),
            const SizedBox(width: EsnaftaVarSpacing.xxs),
            Text(
              'Mağazada doğrulandı',
              style: text.labelSmall?.copyWith(color: EsnaftaVarColors.success),
            ),
          ],
        ),
        const Divider(height: EsnaftaVarSpacing.xl),
        for (var index = 0; index < purchase.items.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.items[index].productName,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      '${purchase.items[index].quantity} adet × ${_formatMoney(purchase.items[index].unitPrice)}',
                      style: text.bodySmall?.copyWith(
                        color: EsnaftaVarColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.xs),
              Text(
                _formatMoney(purchase.items[index].lineTotal),
                style: text.labelLarge,
              ),
            ],
          ),
          if (index < purchase.items.length - 1)
            const SizedBox(height: EsnaftaVarSpacing.sm),
        ],
        const SizedBox(height: EsnaftaVarSpacing.md),
        Row(
          children: [
            Expanded(child: Text('Alışveriş tutarı', style: text.bodySmall)),
            Text(
              _formatMoney(purchase.totalAmount),
              style: text.titleMedium?.copyWith(
                color: EsnaftaVarColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: EsnaftaVarSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: Key('purchase-shop-profile-open-${purchase.id}'),
                onPressed: view._isOpeningShop ? null : view._openShopProfile,
                child: Text(view._isOpeningShop ? 'Açılıyor…' : 'Mağazayı gör'),
              ),
            ),
            const SizedBox(width: EsnaftaVarSpacing.xs),
            Expanded(
              child: purchase.customerRating == null
                  ? FilledButton(
                      key: const Key('purchase-shop-rating-open-action'),
                      onPressed: view._isOpeningRating
                          ? null
                          : () => view._openShopRating(context),
                      child: const Text('Esnafa puan ver'),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: EsnaftaVarColors.highlight,
                        ),
                        const SizedBox(width: EsnaftaVarSpacing.xxs),
                        Text(
                          'Puanın ${purchase.customerRating}/5',
                          style: text.labelMedium,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ],
    ),
  );
}
