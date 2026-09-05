part of 'purchases_view.dart';

class _PurchasesFinalControls extends StatelessWidget {
  const _PurchasesFinalControls();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _PurchasesTabBar(),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          key: const Key('purchase-create-return-action'),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('İade Talebi Oluştur'),
          onPressed: () {
            final tabs = DefaultTabController.of(context);
            showModalBottomSheet<void>(
              context: context,
              useSafeArea: true,
              builder: (sheetContext) => SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.65,
                child: _CreateReturnRequestTab(
                  onSeePurchases: () {
                    tabs.animateTo(0);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _PurchasesFinalHeader extends StatelessWidget {
  const _PurchasesFinalHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      key: const Key('customer-purchases-header'),
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

Widget _buildPurchaseFinalCard(_PurchaseCardState view, BuildContext context) {
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
              Flexible(
                child: Text(
                  _formatMoney(purchase.items[index].lineTotal),
                  textAlign: TextAlign.end,
                  style: text.labelLarge,
                ),
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
            Flexible(
              child: Text(
                _formatMoney(purchase.totalAmount),
                style: text.titleMedium?.copyWith(
                  color: EsnaftaVarColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: EsnaftaVarSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 310 ||
                MediaQuery.textScalerOf(context).scale(14) > 16;
            final shop = OutlinedButton(
              key: Key('purchase-shop-profile-open-${purchase.id}'),
              onPressed: view._isOpeningShop ? null : view._openShopProfile,
              child: Text(view._isOpeningShop ? 'Açılıyor…' : 'Mağazayı Gör'),
            );
            final rating = purchase.customerRating == null
                ? FilledButton(
                    key: const Key('purchase-shop-rating-open-action'),
                    onPressed: view._isOpeningRating
                        ? null
                        : () => view._openShopRating(context),
                    child: const Text('Esnafa Puan Ver'),
                  )
                : Semantics(
                    label:
                        'Esnafa verdiğin puan ${purchase.customerRating}, 5 üzerinden',
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Puanın ${purchase.customerRating}/5',
                        textAlign: TextAlign.center,
                        style: text.labelMedium,
                      ),
                    ),
                  );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [shop, const SizedBox(height: 8), rating],
              );
            }
            return Row(
              children: [
                Expanded(child: shop),
                const SizedBox(width: 8),
                Expanded(child: rating),
              ],
            );
          },
        ),
      ],
    ),
  );
}
