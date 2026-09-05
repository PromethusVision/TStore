part of 'cart_v2_view.dart';

String _prototypeCartPrice(double amount) =>
    '${NumberFormat('#,##0.00', 'tr_TR').format(amount)} TL';

class _CartPrototypeHeader extends StatelessWidget {
  const _CartPrototypeHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      EsnaftaVarSurfaceIconButton(
        buttonKey: const Key('customer-cart-back-button'),
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
              'MAĞAZA ALIŞVERİŞİNE HAZIRLIK',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EsnaftaVarColors.accent,
                letterSpacing: 0.4,
              ),
            ),
            Text('Sepet', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    ],
  );
}

Widget _buildCartLoadedPrototype(
  _CartV2ViewState view,
  CartV2Loaded cart,
  BuildContext context,
) {
  final theme = Theme.of(context).textTheme;
  final shop = cart.items.first.shopProduct?.shop;
  final requiresRefresh = cart.items.any((item) => !item.isPurchaseVerifiable);
  return ListView(
    key: const Key('customer-cart-items-list'),
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    children: [
      Text(
        'Mağazadan almak için\nhazırladığın ürünler',
        style: theme.headlineSmall,
      ),
      const SizedBox(height: EsnaftaVarSpacing.md),
      Container(
        key: const Key('cart-prototype-shop-context'),
        padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.primarySoft,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.storefront_rounded,
              size: 28,
              color: EsnaftaVarColors.primary,
            ),
            const SizedBox(width: EsnaftaVarSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop?.name ?? 'Mağaza bilgisi yok',
                    style: theme.titleMedium,
                  ),
                  if (shop?.address?.trim().isNotEmpty == true)
                    Text(
                      shop!.address!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Sepetin tek bir mağazaya ait.',
                    style: theme.labelSmall?.copyWith(
                      color: EsnaftaVarColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: EsnaftaVarSpacing.md),
      EsnaftaVarSectionHeader(
        title: '${cart.items.length} ürün · ${cart.itemCount} adet',
      ),
      const SizedBox(height: EsnaftaVarSpacing.sm),
      for (final item in cart.items)
        Padding(
          padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xs),
          child: item.isPurchaseVerifiable
              ? _CartPrototypeItem(
                  item: item,
                  pending: view._pendingItemActions[item.id],
                  enabled: !view._isCartInteractionBlocked,
                  increment: () =>
                      view._updateItemQuantity(item, shouldIncrement: true),
                  decrement: () =>
                      view._updateItemQuantity(item, shouldIncrement: false),
                  remove: () => view._confirmAndRemoveItem(item),
                )
              : _CartV2ItemCard(
                  item: item,
                  pendingAction: view._pendingItemActions[item.id],
                  isCartInteractionBlocked: view._isCartInteractionBlocked,
                  isRefreshingAvailability: view._isRefreshingUnavailableItem,
                  onRefreshAvailability: view._refreshUnavailableItem,
                  onIncrement: () =>
                      view._updateItemQuantity(item, shouldIncrement: true),
                  onDecrement: () =>
                      view._updateItemQuantity(item, shouldIncrement: false),
                  onRemove: () => view._confirmAndRemoveItem(item),
                ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.xs),
        child: Row(
          children: [
            Expanded(child: Text('Ürün tutarı', style: theme.titleMedium)),
            Text(
              _prototypeCartPrice(cart.totalAmount),
              style: theme.titleLarge,
            ),
          ],
        ),
      ),
      Text(
        requiresRefresh
            ? 'Tutar için ürün bilgilerini yenile.'
            : 'Listelenen mağaza fiyatlarıyla hesaplandı.',
        style: theme.bodySmall?.copyWith(color: EsnaftaVarColors.textMuted),
      ),
      const SizedBox(height: EsnaftaVarSpacing.md),
      const Divider(height: 1),
      const SizedBox(height: EsnaftaVarSpacing.md),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.qr_code_rounded,
            color: EsnaftaVarColors.primary,
            size: 24,
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mağazaya gittiğinde', style: theme.titleSmall),
                Text(
                  'Alışverişini doğrulamak için QR kodunu esnafa göster.',
                  style: theme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: EsnaftaVarSpacing.sm),
      OutlinedButton.icon(
        key: const Key('customer-cart-verify-button'),
        onPressed: view._isCartInteractionBlocked
            ? null
            : view._preparePurchaseVerification,
        icon: view._isPreparingPurchaseVerification
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.qr_code_2_rounded, size: 20),
        label: Text(
          view._isPreparingPurchaseVerification
              ? 'Hazırlanıyor…'
              : 'Mağazada göster',
        ),
      ),
      Center(
        child: TextButton(
          key: const Key('cart-prototype-clear'),
          onPressed: view._isCartInteractionBlocked
              ? null
              : view._confirmAndClearCart,
          child: Text(
            view._isClearingCart ? 'Boşaltılıyor…' : 'Sepeti boşalt',
            style: const TextStyle(color: EsnaftaVarColors.textMuted),
          ),
        ),
      ),
    ],
  );
}

class _CartPrototypeItem extends StatelessWidget {
  const _CartPrototypeItem({
    required this.item,
    required this.pending,
    required this.enabled,
    required this.increment,
    required this.decrement,
    required this.remove,
  });
  final CartItemV2Entity item;
  final _CartItemPendingAction? pending;
  final bool enabled;
  final VoidCallback increment, decrement, remove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final product = item.shopProduct?.product;
    // Preserve the cart's existing product-image precedence.
    final image = product?.images.isNotEmpty == true
        ? product!.images.first.trim()
        : '';
    return Container(
      key: Key('customer-cart-item-${item.id}'),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty)
                RoundedImage(
                  roundedImageModel: RoundedImageModel(
                    image: image,
                    width: 64,
                    height: 72,
                    padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
                    fit: BoxFit.contain,
                    backgroundColor: EsnaftaVarColors.surfaceAlt,
                    isNetworkImage: image.startsWith('http'),
                    errorWidget: const _CartProductImagePlaceholder(),
                  ),
                )
              else
                const SizedBox(
                  width: 64,
                  height: 72,
                  child: _CartProductImagePlaceholder(),
                ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Ürün bilgisi yok',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_prototypeCartPrice(item.shopProduct?.price ?? 0)} / adet',
                      style: theme.bodySmall?.copyWith(
                        color: EsnaftaVarColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: Key('customer-cart-item-${item.id}-remove'),
                tooltip: 'Kaldır',
                onPressed: enabled ? remove : null,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: EsnaftaVarColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  _prototypeCartPrice(item.totalPrice),
                  style: theme.titleMedium?.copyWith(
                    color: EsnaftaVarColors.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: _CartV2QuantityRow(
                  item: item,
                  isEnabled: enabled,
                  isUpdating:
                      pending == _CartItemPendingAction.updatingQuantity,
                  onIncrement: increment,
                  onDecrement: decrement,
                ),
              ),
            ],
          ),
          if (pending == _CartItemPendingAction.removing)
            Text('Kaldırılıyor…', style: theme.bodySmall),
        ],
      ),
    );
  }
}
