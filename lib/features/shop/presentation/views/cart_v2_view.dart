import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';

class CartV2View extends StatefulWidget {
  const CartV2View({super.key});

  @override
  State<CartV2View> createState() => _CartV2ViewState();
}

class _CartV2ViewState extends State<CartV2View> {
  bool _isPreparingPurchaseVerification = false;
  bool _isRefreshingUnavailableItem = false;

  @override
  void initState() {
    super.initState();
    context.read<CartV2Cubit>().getActiveCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: Text(
            'Mağaza Sepeti',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          hasArrowBack: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: BlocConsumer<CartV2Cubit, CartV2State>(
          listenWhen: (previous, current) => current is CartV2Error,
          listener: (context, state) {
            if (state is CartV2Error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          buildWhen: (previous, current) {
            if (current is CartV2Error && previous is CartV2Loaded) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is CartV2Initial || state is CartV2Loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartV2Error) {
              return _CartV2ErrorState(message: state.message);
            }

            if (state is CartV2Loaded) {
              if (state.isEmpty) {
                return const _CartV2EmptyState();
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return _CartV2ItemCard(
                          item: state.items[index],
                          isRefreshingAvailability:
                              _isRefreshingUnavailableItem,
                          onRefreshAvailability: _refreshUnavailableItem,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: TSizes.spaceBtwItems),
                      itemCount: state.items.length,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _CartV2TotalBox(
                    totalAmount: state.totalAmount,
                    requiresRefresh: state.items.any(
                      (item) => !item.isPurchaseVerifiable,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _ShowInStoreButton(
                    isPreparing: _isPreparingPurchaseVerification,
                    onPressed: _preparePurchaseVerification,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const _CancelActiveCartButton(),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _preparePurchaseVerification() async {
    if (_isPreparingPurchaseVerification) return;

    setState(() => _isPreparingPurchaseVerification = true);
    final cartCubit = context.read<CartV2Cubit>();
    final previousState = cartCubit.state;

    try {
      await cartCubit.getActiveCartItems();
      if (!mounted) return;

      final refreshedState = cartCubit.state;
      if (refreshedState is! CartV2Loaded) return;

      if (refreshedState.isEmpty) {
        _showVerificationBlockedMessage(
          'Mağaza sepetiniz boş. Alışverişi doğrulamak için ürün ekleyin.',
        );
        return;
      }

      final canVerifyPurchase = refreshedState.items.every(
        (item) => item.isPurchaseVerifiable,
      );
      if (!canVerifyPurchase) {
        _showVerificationBlockedMessage(
          'Sepetteki ürünlerden biri artık satışta değil veya mağaza '
          'alışverişe kapalı. Sepetinizi güncelleyip tekrar deneyin.',
        );
        return;
      }

      if (previousState is CartV2Loaded &&
          _hasCartPricingChanged(previousState, refreshedState)) {
        final shouldContinue = await _confirmUpdatedCartTotal(
          previousState: previousState,
          refreshedState: refreshedState,
        );
        if (!mounted || !shouldContinue) return;
      }

      setState(() => _isPreparingPurchaseVerification = false);
      await _showQrSessionBottomSheet(refreshedState);
    } finally {
      if (mounted && _isPreparingPurchaseVerification) {
        setState(() => _isPreparingPurchaseVerification = false);
      }
    }
  }

  bool _hasCartPricingChanged(
    CartV2Loaded previousState,
    CartV2Loaded refreshedState,
  ) {
    if (previousState.items.length != refreshedState.items.length) {
      return true;
    }

    final previousItemsById = {
      for (final item in previousState.items) item.id: item,
    };

    for (final refreshedItem in refreshedState.items) {
      final previousItem = previousItemsById[refreshedItem.id];
      if (previousItem == null ||
          previousItem.quantity != refreshedItem.quantity) {
        return true;
      }

      final previousPrice = previousItem.shopProduct?.price;
      final refreshedPrice = refreshedItem.shopProduct?.price;
      if (previousPrice == null ||
          refreshedPrice == null ||
          (previousPrice - refreshedPrice).abs() > 0.005) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _confirmUpdatedCartTotal({
    required CartV2Loaded previousState,
    required CartV2Loaded refreshedState,
  }) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.price_change_outlined),
          title: const Text('Sepet tutarı güncellendi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mağazadaki güncel fiyatlar sepetinize yansıtıldı. '
                'Devam etmeden önce yeni tutarı kontrol edin.',
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              _CartTotalComparisonRow(
                label: 'Önceki toplam',
                amount: previousState.totalAmount,
              ),
              const SizedBox(height: TSizes.sm),
              _CartTotalComparisonRow(
                label: 'Güncel toplam',
                amount: refreshedState.totalAmount,
                isHighlighted: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Güncel tutarla devam et'),
            ),
          ],
        );
      },
    );

    return shouldContinue == true;
  }

  Future<void> _refreshUnavailableItem(String cartItemId) async {
    if (_isRefreshingUnavailableItem) return;

    setState(() => _isRefreshingUnavailableItem = true);
    final cartCubit = context.read<CartV2Cubit>();

    try {
      await cartCubit.getActiveCartItems(showLoading: false);
      if (!mounted) return;

      final refreshedState = cartCubit.state;
      if (refreshedState is! CartV2Loaded) return;

      final refreshedItems = refreshedState.items.where(
        (item) => item.id == cartItemId,
      );
      if (refreshedItems.isEmpty) {
        _showAvailabilityMessage('Ürün artık sepetinizde bulunmuyor.');
        return;
      }

      if (refreshedItems.first.isPurchaseVerifiable) {
        _showAvailabilityMessage('Ürün yeniden satın alınabilir durumda.');
        return;
      }

      _showAvailabilityMessage('Ürün durumu henüz değişmedi.');
    } finally {
      if (mounted) {
        setState(() => _isRefreshingUnavailableItem = false);
      }
    }
  }

  void _showAvailabilityMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showVerificationBlockedMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showQrSessionBottomSheet(CartV2Loaded state) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<QrSessionCubit>(),
          child: CartQrSessionBottomSheet(
            cartId: state.items.first.cartId,
            shopName:
                state.items.first.shopProduct?.shop?.name ?? 'Bilinmeyen esnaf',
            itemCount: state.itemCount,
            totalAmount: state.totalAmount,
          ),
        );
      },
    );

    if (!mounted) return;
    await context.read<CartV2Cubit>().getActiveCartItems();
  }
}

class _CartTotalComparisonRow extends StatelessWidget {
  const _CartTotalComparisonRow({
    required this.label,
    required this.amount,
    this.isHighlighted = false,
  });

  final String label;
  final double amount;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final textStyle = isHighlighted
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: textStyle)),
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: textStyle?.copyWith(
            fontWeight: isHighlighted ? FontWeight.w700 : null,
          ),
        ),
      ],
    );
  }
}

class _ShowInStoreButton extends StatelessWidget {
  final bool isPreparing;
  final VoidCallback onPressed;

  const _ShowInStoreButton({
    required this.isPreparing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPreparing ? null : onPressed,
        child: isPreparing
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Alışverişi doğrula'),
      ),
    );
  }
}

class _CartV2ItemCard extends StatelessWidget {
  const _CartV2ItemCard({
    required this.item,
    required this.isRefreshingAvailability,
    required this.onRefreshAvailability,
  });

  final CartItemV2Entity item;
  final bool isRefreshingAvailability;
  final ValueChanged<String> onRefreshAvailability;

  @override
  Widget build(BuildContext context) {
    final shopProduct = item.shopProduct;
    final shop = shopProduct?.shop;
    final product = shopProduct?.product;
    final shopPrice = shopProduct?.price ?? 0;
    final isUnavailable = !item.isPurchaseVerifiable;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isUnavailable
            ? colorScheme.errorContainer.withValues(alpha: 0.22)
            : null,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: isUnavailable
              ? colorScheme.error.withValues(alpha: 0.55)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  shop?.name ?? 'Bilinmeyen esnaf',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (!isUnavailable)
                IconButton(
                  tooltip: 'Kaldır',
                  onPressed: isRefreshingAvailability
                      ? null
                      : () => _confirmRemoveItem(context),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            shop?.address ?? 'Adres bilgisi yok',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            product?.name ?? 'Ürün bilgisi yok',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: TSizes.sm),
          _CartV2InfoRow(
            label: 'Mağaza fiyatı',
            value: '₺${shopPrice.toStringAsFixed(2)}',
          ),
          _CartV2QuantityRow(
            item: item,
            isEnabled: !isUnavailable && !isRefreshingAvailability,
          ),
          _CartV2InfoRow(
            label: 'Satır toplamı',
            value: '₺${item.totalPrice.toStringAsFixed(2)}',
          ),
          if (isUnavailable) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            _UnavailableCartItemNotice(
              message:
                  item.purchaseBlockReason ??
                  'Bu ürün şu anda satın alınamıyor.',
              isRefreshing: isRefreshingAvailability,
              onRefresh: () => onRefreshAvailability(item.id),
              onRemove: isRefreshingAvailability
                  ? null
                  : () => _confirmRemoveItem(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemoveItem(BuildContext context) async {
    final cubit = context.read<CartV2Cubit>();
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ürünü sepetten kaldır'),
          content: const Text(
            'Bu ürünü mağaza sepetinden kaldırmak istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Kaldır'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      cubit.removeItem(item.id);
    }
  }
}

class _UnavailableCartItemNotice extends StatelessWidget {
  const _UnavailableCartItemNotice({
    required this.message,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onRemove,
  });

  final String message;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: 'Satın alınamayan ürün',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.sm),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: TSizes.iconSm,
                  color: colorScheme.error,
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: isRefreshing ? null : onRefresh,
                  icon: isRefreshing
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    isRefreshing ? 'Kontrol ediliyor…' : 'Yeniden kontrol et',
                  ),
                ),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Sepetten kaldır'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartV2QuantityRow extends StatelessWidget {
  const _CartV2QuantityRow({required this.item, this.isEnabled = true});

  final CartItemV2Entity item;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: TSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Adet', style: Theme.of(context).textTheme.bodyMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Azalt',
                onPressed: !isEnabled || item.quantity <= 1
                    ? null
                    : () {
                        context.read<CartV2Cubit>().decrementItemQuantity(item);
                      },
                icon: const Icon(Icons.remove),
              ),
              Text(
                item.quantity.toString(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                tooltip: 'Artır',
                onPressed: isEnabled
                    ? () {
                        context.read<CartV2Cubit>().incrementItemQuantity(item);
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartV2InfoRow extends StatelessWidget {
  const _CartV2InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: TSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _CartV2TotalBox extends StatelessWidget {
  const _CartV2TotalBox({
    required this.totalAmount,
    required this.requiresRefresh,
  });

  final double totalAmount;
  final bool requiresRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: requiresRefresh
            ? colorScheme.errorContainer.withValues(alpha: 0.22)
            : null,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: requiresRefresh
              ? colorScheme.error.withValues(alpha: 0.55)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: requiresRefresh
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: TSizes.iconMd,
                  color: colorScheme.error,
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam güncellenmeli',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onErrorContainer),
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        'Satın alınamayan ürünü kaldırdığınızda güncel toplam '
                        'gösterilecek.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sepet Toplamı',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '₺${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
    );
  }
}

class _CancelActiveCartButton extends StatelessWidget {
  const _CancelActiveCartButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmCancelCart(context),
        child: const Text('Mağaza sepetini boşalt'),
      ),
    );
  }

  Future<void> _confirmCancelCart(BuildContext context) async {
    final cubit = context.read<CartV2Cubit>();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mağaza sepetini boşalt'),
          content: const Text(
            'Bu mağaza sepetindeki tüm ürünler kaldırılacak. '
            'Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sepeti boşalt'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      cubit.cancelActiveCart();
    }
  }
}

class _CartV2EmptyState extends StatelessWidget {
  const _CartV2EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Henüz mağaza sepetinde ürün yok',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Ürün detayından bir mağaza seçip sepete eklediğinde '
              'ürünlerin burada görünecek.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartV2ErrorState extends StatelessWidget {
  const _CartV2ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sepet bilgileri yüklenemedi',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
