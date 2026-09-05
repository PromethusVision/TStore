import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/widgets/cart_qr_session_bottom_sheet.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

part 'cart_v2_visual_prototype.dart';

class CartV2View extends StatefulWidget {
  const CartV2View({super.key, this.visualPrototype = true});

  /// Owner-approved Final UI is the default for every customer entry.
  /// Explicit false retains the legacy presentation for regression comparison.
  final bool visualPrototype;

  @override
  State<CartV2View> createState() => _CartV2ViewState();
}

class _CartV2ViewState extends State<CartV2View> {
  bool _isPreparingPurchaseVerification = false;
  bool _isRefreshingUnavailableItem = false;
  bool _isClearingCart = false;
  bool _isCartConfirmationOpen = false;
  final Map<String, _CartItemPendingAction> _pendingItemActions = {};

  bool get _isCartMutationInProgress =>
      _isClearingCart || _pendingItemActions.isNotEmpty;

  bool get _isCartInteractionBlocked =>
      _isCartConfirmationOpen ||
      _isPreparingPurchaseVerification ||
      _isRefreshingUnavailableItem ||
      _isCartMutationInProgress;

  @override
  void initState() {
    super.initState();
    context.read<CartV2Cubit>().getActiveCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-cart-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: widget.visualPrototype
                      ? const _CartPrototypeHeader()
                      : const _CartV2Header(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
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
                        return const _CartV2LoadingState();
                      }

                      if (state is CartV2Error) {
                        return _CartV2ErrorState(
                          message: state.message,
                          onRetry: () =>
                              context.read<CartV2Cubit>().getActiveCartItems(),
                        );
                      }

                      if (state is CartV2Loaded) {
                        if (state.isEmpty) {
                          return const _CartV2EmptyState();
                        }

                        if (widget.visualPrototype) {
                          return _buildCartLoadedPrototype(
                            this,
                            state,
                            context,
                          );
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                key: const Key('customer-cart-items-list'),
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  CustomerHomeV1Tokens.space16,
                                  CustomerHomeV1Tokens.space4,
                                  CustomerHomeV1Tokens.space16,
                                  CustomerHomeV1Tokens.space16,
                                ),
                                itemBuilder: (context, index) {
                                  final item = state.items[index];
                                  return _CartV2ItemCard(
                                    item: item,
                                    pendingAction: _pendingItemActions[item.id],
                                    isCartInteractionBlocked:
                                        _isCartInteractionBlocked,
                                    isRefreshingAvailability:
                                        _isRefreshingUnavailableItem,
                                    onRefreshAvailability:
                                        _refreshUnavailableItem,
                                    onIncrement: () => _updateItemQuantity(
                                      item,
                                      shouldIncrement: true,
                                    ),
                                    onDecrement: () => _updateItemQuantity(
                                      item,
                                      shouldIncrement: false,
                                    ),
                                    onRemove: () => _confirmAndRemoveItem(item),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                      height: CustomerHomeV1Tokens.space12,
                                    ),
                                itemCount: state.items.length,
                              ),
                            ),
                            _CartV2VerificationPanel(
                              totalAmount: state.totalAmount,
                              requiresRefresh: state.items.any(
                                (item) => !item.isPurchaseVerifiable,
                              ),
                              isPreparing: _isPreparingPurchaseVerification,
                              isVerificationEnabled: !_isCartInteractionBlocked,
                              onVerify: _preparePurchaseVerification,
                              isClearing: _isClearingCart,
                              isClearEnabled: !_isCartInteractionBlocked,
                              onClear: _confirmAndClearCart,
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateItemQuantity(
    CartItemV2Entity item, {
    required bool shouldIncrement,
  }) async {
    await _runCartItemAction(
      itemId: item.id,
      action: _CartItemPendingAction.updatingQuantity,
      request: () => shouldIncrement
          ? context.read<CartV2Cubit>().incrementItemQuantity(item)
          : context.read<CartV2Cubit>().decrementItemQuantity(item),
    );
  }

  Future<void> _confirmAndRemoveItem(CartItemV2Entity item) async {
    if (_isCartInteractionBlocked) return;

    _isCartConfirmationOpen = true;
    var isClosingDialog = false;
    bool shouldRemove;
    try {
      shouldRemove =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  void closeDialog(bool result) {
                    if (isClosingDialog) return;
                    setDialogState(() => isClosingDialog = true);
                    Navigator.of(dialogContext).pop(result);
                  }

                  return AlertDialog(
                    title: const Text('Ürünü sepetten kaldır'),
                    content: const Text(
                      'Bu ürünü mağaza sepetinden kaldırmak istiyor musunuz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: isClosingDialog
                            ? null
                            : () => closeDialog(false),
                        child: const Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: isClosingDialog
                            ? null
                            : () => closeDialog(true),
                        child: const Text('Kaldır'),
                      ),
                    ],
                  );
                },
              );
            },
          ) ==
          true;
    } finally {
      _isCartConfirmationOpen = false;
    }

    if (!mounted || !shouldRemove) return;
    await _runCartItemAction(
      itemId: item.id,
      action: _CartItemPendingAction.removing,
      request: () => context.read<CartV2Cubit>().removeItem(item.id),
    );
  }

  Future<void> _confirmAndClearCart() async {
    if (_isCartInteractionBlocked) return;

    _isCartConfirmationOpen = true;
    var isClosingDialog = false;
    bool shouldClear;
    try {
      shouldClear =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  void closeDialog(bool result) {
                    if (isClosingDialog) return;
                    setDialogState(() => isClosingDialog = true);
                    Navigator.of(dialogContext).pop(result);
                  }

                  return AlertDialog(
                    title: const Text('Mağaza sepetini boşalt'),
                    content: const Text(
                      'Bu mağaza sepetindeki tüm ürünler kaldırılacak. '
                      'Bu işlem geri alınamaz.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: isClosingDialog
                            ? null
                            : () => closeDialog(false),
                        child: const Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: isClosingDialog
                            ? null
                            : () => closeDialog(true),
                        child: const Text('Sepeti boşalt'),
                      ),
                    ],
                  );
                },
              );
            },
          ) ==
          true;
    } finally {
      _isCartConfirmationOpen = false;
    }

    if (!mounted || !shouldClear) return;
    setState(() => _isClearingCart = true);
    try {
      await context.read<CartV2Cubit>().cancelActiveCart();
    } finally {
      if (mounted) setState(() => _isClearingCart = false);
    }
  }

  Future<void> _runCartItemAction({
    required String itemId,
    required _CartItemPendingAction action,
    required Future<void> Function() request,
  }) async {
    if (_isCartInteractionBlocked) return;

    setState(() => _pendingItemActions[itemId] = action);
    try {
      await request();
    } finally {
      if (mounted) {
        setState(() => _pendingItemActions.remove(itemId));
      }
    }
  }

  Future<void> _preparePurchaseVerification() async {
    if (_isCartInteractionBlocked) return;

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
    var isClosingDialog = false;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void closeDialog(bool result) {
              if (isClosingDialog) return;
              setDialogState(() => isClosingDialog = true);
              Navigator.of(dialogContext).pop(result);
            }

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
                  onPressed: isClosingDialog ? null : () => closeDialog(false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: isClosingDialog ? null : () => closeDialog(true),
                  child: const Text('Güncel tutarla devam et'),
                ),
              ],
            );
          },
        );
      },
    );

    return shouldContinue == true;
  }

  Future<void> _refreshUnavailableItem(String cartItemId) async {
    if (_isCartInteractionBlocked) return;

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
    final completedQrSessionId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => sl<QrSessionCubit>(),
          child: CartQrSessionBottomSheet(
            cartId: state.items.first.cartId,
            shopName:
                state.items.first.shopProduct?.shop?.name ?? 'Bilinmeyen esnaf',
            itemCount: state.itemCount,
            totalAmount: state.totalAmount,
            onViewPurchases: (sessionId) =>
                Navigator.of(sheetContext).pop(sessionId),
          ),
        );
      },
    );

    if (!mounted) return;
    await context.read<CartV2Cubit>().getActiveCartItems();
    if (!mounted || completedQrSessionId == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PurchasesView(initialQrSessionId: completedQrSessionId),
      ),
    );
  }
}

class _CartV2Header extends StatelessWidget {
  const _CartV2Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-cart-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('customer-cart-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sepetim',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Mağazada doğrulanacak ürünleri burada hazırla',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4DE),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Iconsax.shopping_bag,
              color: CustomerHomeV1Tokens.coral,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartV2LoadingState extends StatelessWidget {
  const _CartV2LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-cart-loading-state'),
        margin: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            ),
            SizedBox(height: CustomerHomeV1Tokens.space12),
            Text(
              'Sepetin hazırlanıyor',
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartV2VerificationPanel extends StatelessWidget {
  const _CartV2VerificationPanel({
    required this.totalAmount,
    required this.requiresRefresh,
    required this.isPreparing,
    required this.isVerificationEnabled,
    required this.onVerify,
    required this.isClearing,
    required this.isClearEnabled,
    required this.onClear,
  });

  final double totalAmount;
  final bool requiresRefresh;
  final bool isPreparing;
  final bool isVerificationEnabled;
  final VoidCallback onVerify;
  final bool isClearing;
  final bool isClearEnabled;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-cart-verification-panel'),
      padding: const EdgeInsets.fromLTRB(
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space12,
        CustomerHomeV1Tokens.space16,
        CustomerHomeV1Tokens.space16,
      ),
      decoration: const BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        border: Border(top: BorderSide(color: CustomerHomeV1Tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CartV2TotalBox(
            totalAmount: totalAmount,
            requiresRefresh: requiresRefresh,
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          _ShowInStoreButton(
            isPreparing: isPreparing,
            isEnabled: isVerificationEnabled,
            onPressed: onVerify,
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space8),
          _CancelActiveCartButton(
            isClearing: isClearing,
            isEnabled: isClearEnabled,
            onPressed: onClear,
          ),
        ],
      ),
    );
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
  final bool isEnabled;
  final VoidCallback onPressed;

  const _ShowInStoreButton({
    required this.isPreparing,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        key: const Key('customer-cart-verify-button'),
        onPressed: isPreparing || !isEnabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: CustomerHomeV1Tokens.petrol,
          foregroundColor: Colors.white,
          disabledBackgroundColor: CustomerHomeV1Tokens.muted.withValues(
            alpha: 0.28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        icon: isPreparing
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Iconsax.scan_barcode, size: 20),
        label: Text(isPreparing ? 'Hazırlanıyor…' : 'Alışverişi doğrula'),
      ),
    );
  }
}

class _CartV2ItemCard extends StatelessWidget {
  const _CartV2ItemCard({
    required this.item,
    required this.pendingAction,
    required this.isCartInteractionBlocked,
    required this.isRefreshingAvailability,
    required this.onRefreshAvailability,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItemV2Entity item;
  final _CartItemPendingAction? pendingAction;
  final bool isCartInteractionBlocked;
  final bool isRefreshingAvailability;
  final ValueChanged<String> onRefreshAvailability;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final shopProduct = item.shopProduct;
    final shop = shopProduct?.shop;
    final product = shopProduct?.product;
    final shopPrice = shopProduct?.price ?? 0;
    final isUnavailable = !item.isPurchaseVerifiable;
    final imageUrl = product?.images.isNotEmpty == true
        ? product!.images.first.trim()
        : '';

    return Container(
      key: Key('customer-cart-item-${item.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: isUnavailable
            ? const Color(0xFFFFF3F0)
            : CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(
          color: isUnavailable
              ? CustomerHomeV1Tokens.coral.withValues(alpha: 0.55)
              : CustomerHomeV1Tokens.border,
        ),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.shop,
                  size: 17,
                  color: CustomerHomeV1Tokens.petrol,
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop?.name ?? 'Bilinmeyen esnaf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shop?.address ?? 'Adres bilgisi yok',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingAction == _CartItemPendingAction.removing)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CustomerHomeV1Tokens.coral,
                      ),
                    ),
                    SizedBox(width: CustomerHomeV1Tokens.space4),
                    Text(
                      'Kaldırılıyor…',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              else if (!isUnavailable)
                IconButton(
                  key: Key('customer-cart-item-${item.id}-remove'),
                  tooltip: 'Kaldır',
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      isRefreshingAvailability || isCartInteractionBlocked
                      ? null
                      : onRemove,
                  icon: const Icon(
                    Iconsax.trash,
                    size: 19,
                    color: CustomerHomeV1Tokens.coral,
                  ),
                ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(height: 1, color: CustomerHomeV1Tokens.border),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CartProductThumbnail(imageUrl: imageUrl),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Ürün bilgisi yok',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      '₺${shopPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.petrol,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space12),
                    _CartV2QuantityRow(
                      item: item,
                      isEnabled:
                          !isUnavailable &&
                          !isRefreshingAvailability &&
                          !isCartInteractionBlocked,
                      isUpdating:
                          pendingAction ==
                          _CartItemPendingAction.updatingQuantity,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          _CartV2InfoRow(
            label: 'Ürün toplamı',
            value: '₺${item.totalPrice.toStringAsFixed(2)}',
          ),
          if (isUnavailable) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            _UnavailableCartItemNotice(
              message:
                  item.purchaseBlockReason ??
                  'Bu ürün şu anda satın alınamıyor.',
              isRefreshing: isRefreshingAvailability,
              onRefresh: () => onRefreshAvailability(item.id),
              onRemove: isRefreshingAvailability || isCartInteractionBlocked
                  ? null
                  : onRemove,
            ),
          ],
        ],
      ),
    );
  }
}

class _CartProductThumbnail extends StatelessWidget {
  const _CartProductThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: Container(
        key: const Key('customer-cart-product-thumbnail'),
        width: 88,
        height: 88,
        color: CustomerHomeV1Tokens.mint,
        child: imageUrl.isEmpty
            ? const _CartProductImagePlaceholder()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomerHomeV1Tokens.petrol,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const _CartProductImagePlaceholder(),
              ),
      ),
    );
  }
}

class _CartProductImagePlaceholder extends StatelessWidget {
  const _CartProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Iconsax.gallery,
        color: CustomerHomeV1Tokens.petrol,
        size: 28,
      ),
    );
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
    return Semantics(
      container: true,
      label: 'Satın alınamayan ürün',
      child: Container(
        key: const Key('customer-cart-unavailable-notice'),
        width: double.infinity,
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.coral.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
          border: Border.all(
            color: CustomerHomeV1Tokens.coral.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 19,
                  color: CustomerHomeV1Tokens.coral,
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 11,
                      height: 1.35,
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
                  style: TextButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.petrol,
                    textStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Sepetten kaldır'),
                  style: TextButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.coral,
                    textStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700),
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
  const _CartV2QuantityRow({
    required this.item,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
    this.isEnabled = true,
  });

  final CartItemV2Entity item;
  final bool isEnabled;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      overflowAlignment: OverflowBarAlignment.end,
      overflowSpacing: EsnaftaVarSpacing.xxs,
      children: [
        const Text(
          'Adet',
          style: TextStyle(
            color: CustomerHomeV1Tokens.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isUpdating)
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomerHomeV1Tokens.petrol,
                ),
              ),
              SizedBox(width: CustomerHomeV1Tokens.space4),
              Text(
                'Güncelleniyor…',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 9.5,
                ),
              ),
            ],
          )
        else
          Container(
            height: EsnaftaVarTouchTargets.preferred,
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.cream,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
              border: Border.all(color: CustomerHomeV1Tokens.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Azalt',
                  visualDensity: VisualDensity.standard,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: !isEnabled || item.quantity <= 1
                      ? null
                      : onDecrement,
                  icon: const Icon(Icons.remove, size: 17),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 24),
                  child: Text(
                    item.quantity.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Artır',
                  visualDensity: VisualDensity.standard,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: isEnabled ? onIncrement : null,
                  icon: const Icon(Icons.add, size: 17),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CartV2InfoRow extends StatelessWidget {
  const _CartV2InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: CustomerHomeV1Tokens.space8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CustomerHomeV1Tokens.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
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
    return Container(
      key: const Key('customer-cart-total-box'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: requiresRefresh
            ? CustomerHomeV1Tokens.coral.withValues(alpha: 0.08)
            : CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(
          color: requiresRefresh
              ? CustomerHomeV1Tokens.coral.withValues(alpha: 0.42)
              : CustomerHomeV1Tokens.petrol.withValues(alpha: 0.14),
        ),
      ),
      child: requiresRefresh
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 21,
                  color: CustomerHomeV1Tokens.coral,
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam güncellenmeli',
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space4),
                      const Text(
                        'Satın alınamayan ürünü kaldırdığınızda güncel toplam '
                        'gösterilecek.',
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 10.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
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
                const Expanded(
                  child: Text(
                    'Sepet Toplamı',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space8),
                Text(
                  '₺${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.petrol,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CancelActiveCartButton extends StatelessWidget {
  const _CancelActiveCartButton({
    required this.isClearing,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isClearing;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: isClearing || !isEnabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: CustomerHomeV1Tokens.coral,
          side: BorderSide(
            color: CustomerHomeV1Tokens.coral.withValues(alpha: 0.48),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: isClearing
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomerHomeV1Tokens.coral,
                    ),
                  ),
                  SizedBox(width: CustomerHomeV1Tokens.space8),
                  Text('Sepet boşaltılıyor…'),
                ],
              )
            : const Text('Mağaza sepetini boşalt'),
      ),
    );
  }
}

enum _CartItemPendingAction { updatingQuantity, removing }

class _CartV2EmptyState extends StatelessWidget {
  const _CartV2EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-cart-empty-state'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.shopping_bag,
                  color: CustomerHomeV1Tokens.petrol,
                  size: 31,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              const Text(
                'Henüz mağaza sepetinde ürün yok',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              const Text(
                'Ürün detayından bir mağaza seçip sepete eklediğinde '
                'ürünlerin burada görünecek.',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 11.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartV2ErrorState extends StatelessWidget {
  const _CartV2ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-cart-error-state'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.warning_2,
                  color: CustomerHomeV1Tokens.coral,
                  size: 31,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              const Text(
                'Sepet bilgileri yüklenemedi',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                message,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 11.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              FilledButton.icon(
                key: const Key('customer-cart-retry-button'),
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: CustomerHomeV1Tokens.petrol,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius16,
                    ),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
