import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

class PurchasesView extends StatelessWidget {
  const PurchasesView({
    super.key,
    this.purchaseHistoryCubit,
    this.initialPurchaseId,
    this.initialQrSessionId,
    this.getShopByIdUsecase,
    this.shopProfileBuilder,
  });

  final PurchaseHistoryCubit? purchaseHistoryCubit;
  final String? initialPurchaseId;
  final String? initialQrSessionId;
  final GetShopByIdUsecase? getShopByIdUsecase;
  final Widget Function(ShopEntity shop)? shopProfileBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (purchaseHistoryCubit ?? sl<PurchaseHistoryCubit>())..loadPurchases(),
      child: _PurchasesScaffold(
        initialPurchaseId: initialPurchaseId,
        initialQrSessionId: initialQrSessionId,
        getShopByIdUsecase: getShopByIdUsecase,
        shopProfileBuilder: shopProfileBuilder,
      ),
    );
  }
}

class _PurchasesScaffold extends StatelessWidget {
  const _PurchasesScaffold({
    required this.initialPurchaseId,
    required this.initialQrSessionId,
    required this.getShopByIdUsecase,
    required this.shopProfileBuilder,
  });

  final String? initialPurchaseId;
  final String? initialQrSessionId;
  final GetShopByIdUsecase? getShopByIdUsecase;
  final Widget Function(ShopEntity shop)? shopProfileBuilder;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CustomerHomeV1Tokens.cream,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              key: const Key('customer-purchases-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space8,
                      CustomerHomeV1Tokens.space16,
                      0,
                    ),
                    child: _PurchasesHeader(),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomerHomeV1Tokens.space16,
                    ),
                    child: _PurchasesTabBar(),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _PurchaseHistoryTab(
                          initialPurchaseId: initialPurchaseId,
                          initialQrSessionId: initialQrSessionId,
                          getShopByIdUsecase: getShopByIdUsecase,
                          shopProfileBuilder: shopProfileBuilder,
                        ),
                        const _ReturnRequestsTab(),
                        const _CreateReturnRequestTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchasesHeader extends StatelessWidget {
  const _PurchasesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-purchases-header'),
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
              key: const Key('customer-purchases-back-button'),
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
                  'Alışverişlerim',
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
                  'Mağazada doğrulanan alışverişlerini takip et',
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
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Iconsax.receipt_item,
              color: CustomerHomeV1Tokens.petrol,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchasesTabBar extends StatelessWidget {
  const _PurchasesTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-purchases-tab-bar'),
      height: 54,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space4),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: CustomerHomeV1Tokens.petrol,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: CustomerHomeV1Tokens.muted,
        labelStyle: const TextStyle(
          fontSize: 10,
          height: 1.15,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 9.5,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            child: Text(
              'Alışverişlerim',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          Tab(
            child: Text(
              'İade Taleplerim',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          Tab(
            child: Text(
              'İade Talebi Oluştur',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseHistoryTab extends StatefulWidget {
  const _PurchaseHistoryTab({
    required this.initialPurchaseId,
    required this.initialQrSessionId,
    required this.getShopByIdUsecase,
    required this.shopProfileBuilder,
  });

  final String? initialPurchaseId;
  final String? initialQrSessionId;
  final GetShopByIdUsecase? getShopByIdUsecase;
  final Widget Function(ShopEntity shop)? shopProfileBuilder;

  @override
  State<_PurchaseHistoryTab> createState() => _PurchaseHistoryTabState();
}

class _PurchaseHistoryTabState extends State<_PurchaseHistoryTab> {
  static const _automaticRetryDelay = Duration(seconds: 2);
  static const _maximumAutomaticRetryAttempts = 3;

  Timer? _automaticRetryTimer;
  int _automaticRetryAttempts = 0;
  bool _automaticRefreshInProgress = false;

  bool get _isRecentQrPurchase =>
      widget.initialPurchaseId == null && widget.initialQrSessionId != null;

  bool get _automaticRetryCompleted =>
      _automaticRetryAttempts >= _maximumAutomaticRetryAttempts &&
      !_automaticRefreshInProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleAutomaticRetry(context.read<PurchaseHistoryCubit>().state);
    });
  }

  @override
  void dispose() {
    _automaticRetryTimer?.cancel();
    super.dispose();
  }

  bool _containsTarget(List<VerifiedPurchaseEntity> purchases) {
    return purchases.any(
      (purchase) => purchase.sourceQrSessionId == widget.initialQrSessionId,
    );
  }

  void _handleAutomaticRetry(PurchaseHistoryState state) {
    if (!_isRecentQrPurchase || state is! PurchaseHistoryLoaded) return;

    if (_containsTarget(state.purchases)) {
      _automaticRetryTimer?.cancel();
      _automaticRetryTimer = null;
      return;
    }

    _scheduleAutomaticRetry();
  }

  void _scheduleAutomaticRetry() {
    if (_automaticRetryTimer != null ||
        _automaticRefreshInProgress ||
        _automaticRetryAttempts >= _maximumAutomaticRetryAttempts) {
      return;
    }

    _automaticRetryTimer = Timer(
      _automaticRetryDelay,
      _refreshMissingQrPurchase,
    );
  }

  Future<void> _refreshMissingQrPurchase() async {
    _automaticRetryTimer = null;
    if (!mounted) return;

    final cubit = context.read<PurchaseHistoryCubit>();
    final currentState = cubit.state;
    if (currentState is! PurchaseHistoryLoaded ||
        _containsTarget(currentState.purchases)) {
      return;
    }

    _automaticRefreshInProgress = true;
    _automaticRetryAttempts++;
    try {
      await cubit.refreshPurchasesSilently();
    } finally {
      _automaticRefreshInProgress = false;
    }

    if (!mounted) return;
    final refreshedState = cubit.state;
    _handleAutomaticRetry(refreshedState);
    if (refreshedState is PurchaseHistoryLoaded &&
        !_containsTarget(refreshedState.purchases) &&
        _automaticRetryCompleted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseHistoryCubit, PurchaseHistoryState>(
      listener: (_, state) => _handleAutomaticRetry(state),
      builder: (context, state) {
        if (state is PurchaseHistoryInitial ||
            state is PurchaseHistoryLoading) {
          return const _PurchaseLoadingState();
        }

        if (state is PurchaseHistoryError) {
          return _CenteredState(
            icon: Icons.error_outline,
            title: 'Alışverişlerin yüklenemedi',
            description: state.message,
            actionLabel: 'Tekrar Dene',
            onAction: context.read<PurchaseHistoryCubit>().loadPurchases,
          );
        }

        final purchases = (state as PurchaseHistoryLoaded).purchases;
        final isRecentQrPurchase =
            widget.initialPurchaseId == null &&
            widget.initialQrSessionId != null;
        final hasTarget =
            widget.initialPurchaseId != null ||
            widget.initialQrSessionId != null;

        if (purchases.isEmpty && !hasTarget) {
          return _CenteredState(
            icon: Icons.shopping_bag_outlined,
            title: 'Henüz doğrulanmış alışverişin yok',
            description:
                'Mağazada QR ile onaylanan alışverişlerin burada görünecek.',
            actionLabel: 'Yenile',
            onAction: context.read<PurchaseHistoryCubit>().loadPurchases,
          );
        }

        final targetedPurchaseIndex = purchases.indexWhere((purchase) {
          if (widget.initialPurchaseId != null) {
            return purchase.id == widget.initialPurchaseId;
          }
          return purchase.sourceQrSessionId == widget.initialQrSessionId;
        });
        final targetedPurchase = targetedPurchaseIndex == -1
            ? null
            : purchases[targetedPurchaseIndex];
        final visiblePurchases = targetedPurchase == null
            ? purchases
            : [
                targetedPurchase,
                ...purchases.where(
                  (purchase) => purchase.id != targetedPurchase.id,
                ),
              ];
        final showMissingTargetMessage = hasTarget && targetedPurchase == null;

        return RefreshIndicator(
          onRefresh: context.read<PurchaseHistoryCubit>().loadPurchases,
          child: ListView.separated(
            key: const Key('customer-purchases-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space8,
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space24,
            ),
            itemCount:
                visiblePurchases.length + (showMissingTargetMessage ? 1 : 0),
            separatorBuilder: (_, _) =>
                const SizedBox(height: CustomerHomeV1Tokens.space12),
            itemBuilder: (context, index) {
              if (showMissingTargetMessage && index == 0) {
                return _MissingTargetPurchaseMessage(
                  isRecentQrPurchase: isRecentQrPurchase,
                  automaticCheckCompleted: _automaticRetryCompleted,
                  onRetry: context.read<PurchaseHistoryCubit>().loadPurchases,
                );
              }

              final purchaseIndex = showMissingTargetMessage
                  ? index - 1
                  : index;
              final purchase = visiblePurchases[purchaseIndex];
              final isTargeted = purchase.id == targetedPurchase?.id;

              return Column(
                key: isTargeted
                    ? Key('highlighted-purchase-${purchase.id}')
                    : null,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isTargeted) ...[
                    _TargetPurchaseLabel(
                      shopName: purchase.shopName,
                      isRecentQrPurchase: isRecentQrPurchase,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                  ],
                  _PurchaseCard(
                    purchase: purchase,
                    getShopByIdUsecase: widget.getShopByIdUsecase,
                    shopProfileBuilder: widget.shopProfileBuilder,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TargetPurchaseLabel extends StatelessWidget {
  const _TargetPurchaseLabel({
    required this.shopName,
    required this.isRecentQrPurchase,
  });

  final String shopName;
  final bool isRecentQrPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-purchase-highlight'),
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space12,
        vertical: CustomerHomeV1Tokens.space8,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        border: Border.all(
          color: CustomerHomeV1Tokens.petrol.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.tick_circle,
            color: CustomerHomeV1Tokens.petrol,
            size: 19,
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              isRecentQrPurchase
                  ? 'Az önce onaylanan alışveriş: $shopName'
                  : 'Bildirimdeki alışveriş: $shopName',
              style: const TextStyle(
                color: CustomerHomeV1Tokens.petrol,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingTargetPurchaseMessage extends StatelessWidget {
  const _MissingTargetPurchaseMessage({
    required this.isRecentQrPurchase,
    required this.automaticCheckCompleted,
    required this.onRetry,
  });

  final bool isRecentQrPurchase;
  final bool automaticCheckCompleted;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(
        isRecentQrPurchase
            ? 'missing-recent-qr-purchase-message'
            : 'missing-notification-purchase-message',
      ),
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DF),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: const Color(0xFFEED99B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Iconsax.info_circle,
                color: CustomerHomeV1Tokens.petrol,
                size: 20,
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Expanded(
                child: Text(
                  isRecentQrPurchase
                      ? automaticCheckCompleted
                            ? 'Alışveriş kaydı henüz görünmüyor. Yeniden kontrol '
                                  'et ile tekrar bakabilirsin.'
                            : 'Az önce onaylanan alışveriş kontrol ediliyor. '
                                  'Birkaç saniye bekleyebilirsin.'
                      : 'Bildirimdeki alışveriş artık bulunamıyor. '
                            'Diğer alışverişlerin gösteriliyor.',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isRecentQrPurchase) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            if (!automaticCheckCompleted) ...[
              const LinearProgressIndicator(
                key: Key('automatic-purchase-check-progress'),
                minHeight: 3,
                color: CustomerHomeV1Tokens.petrol,
                backgroundColor: CustomerHomeV1Tokens.surface,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('retry-recent-qr-purchase-action'),
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: CustomerHomeV1Tokens.petrol,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Yeniden kontrol et'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatefulWidget {
  const _PurchaseCard({
    required this.purchase,
    required this.getShopByIdUsecase,
    required this.shopProfileBuilder,
  });

  final VerifiedPurchaseEntity purchase;
  final GetShopByIdUsecase? getShopByIdUsecase;
  final Widget Function(ShopEntity shop)? shopProfileBuilder;

  @override
  State<_PurchaseCard> createState() => _PurchaseCardState();
}

class _PurchaseItemRow extends StatelessWidget {
  const _PurchaseItemRow({required this.item});

  final VerifiedPurchaseItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
          ),
          child: const Icon(
            Iconsax.bag_2,
            color: CustomerHomeV1Tokens.petrol,
            size: 16,
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 11.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                '${item.quantity} adet × ${_formatMoney(item.unitPrice)}',
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space8),
        Text(
          _formatMoney(item.lineTotal),
          style: const TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PurchaseCardState extends State<_PurchaseCard> {
  bool _isOpeningShop = false;
  bool _isOpeningRating = false;

  @override
  Widget build(BuildContext context) {
    final purchase = widget.purchase;

    return Container(
      key: ValueKey('customer-purchase-card-${purchase.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius12,
                  ),
                ),
                child: const Icon(
                  Iconsax.shop,
                  color: CustomerHomeV1Tokens.petrol,
                  size: 21,
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.shopName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 14.5,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      _formatDate(purchase.confirmedAt),
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomerHomeV1Tokens.space8,
                  vertical: CustomerHomeV1Tokens.space4,
                ),
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radiusPill,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      color: CustomerHomeV1Tokens.green,
                      size: 14,
                    ),
                    SizedBox(width: CustomerHomeV1Tokens.space4),
                    Text(
                      'Onaylandı',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.green,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.cream,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
              border: Border.all(color: CustomerHomeV1Tokens.border),
            ),
            child: Column(
              children: [
                for (var index = 0; index < purchase.items.length; index++) ...[
                  _PurchaseItemRow(item: purchase.items[index]),
                  if (index != purchase.items.length - 1)
                    const Divider(
                      height: CustomerHomeV1Tokens.space16,
                      color: CustomerHomeV1Tokens.border,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: CustomerHomeV1Tokens.space12,
              vertical: CustomerHomeV1Tokens.space8,
            ),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${purchase.itemCount} ürün',
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Toplam: ${_formatMoney(purchase.totalAmount)}',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.petrol,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (purchase.customerRating != null) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CustomerHomeV1Tokens.space12,
                vertical: CustomerHomeV1Tokens.space8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DF),
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE09B15),
                    size: 19,
                  ),
                  const SizedBox(width: CustomerHomeV1Tokens.space4),
                  Text(
                    '${purchase.customerRating}/5 puan verdiniz',
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: CustomerHomeV1Tokens.space8,
            runSpacing: CustomerHomeV1Tokens.space4,
            children: [
              OutlinedButton.icon(
                key: Key('purchase-shop-profile-open-${purchase.id}'),
                onPressed: _isOpeningShop ? null : _openShopProfile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomerHomeV1Tokens.petrol,
                  side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius12,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: _isOpeningShop
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.shop, size: 17),
                label: Text(
                  _isOpeningShop ? 'Mağaza açılıyor' : 'Mağazayı Gör',
                ),
              ),
              if (purchase.customerRating == null)
                TextButton.icon(
                  key: const Key('purchase-shop-rating-open-action'),
                  onPressed: _isOpeningRating
                      ? null
                      : () => _openShopRating(context),
                  style: TextButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Esnafa Puan Ver'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openShopProfile() async {
    if (_isOpeningShop) return;

    setState(() => _isOpeningShop = true);
    final getShopByIdUsecase =
        widget.getShopByIdUsecase ?? sl<GetShopByIdUsecase>();
    final result = await getShopByIdUsecase(widget.purchase.shopId);

    if (!mounted) return;
    setState(() => _isOpeningShop = false);

    result.fold(_showMessage, (shop) {
      if (shop == null) {
        _showMessage('Bu mağaza şu anda görüntülenemiyor.');
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              widget.shopProfileBuilder?.call(shop) ??
              ShopProfileView(shop: shop),
        ),
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openShopRating(BuildContext context) async {
    if (_isOpeningRating) return;

    setState(() => _isOpeningRating = true);
    try {
      final didRate = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: CustomerHomeV1Tokens.cream,
        barrierColor: CustomerHomeV1Tokens.navy.withValues(alpha: 0.32),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CustomerHomeV1Tokens.radius24),
          ),
        ),
        builder: (_) => BlocProvider(
          create: (_) => sl<ShopRatingCubit>(),
          child: _PurchaseShopRatingSheet(purchase: widget.purchase),
        ),
      );

      if (didRate == true && context.mounted) {
        await context.read<PurchaseHistoryCubit>().loadPurchases();
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningRating = false);
      } else {
        _isOpeningRating = false;
      }
    }
  }
}

class _PurchaseShopRatingSheet extends StatefulWidget {
  const _PurchaseShopRatingSheet({required this.purchase});

  final VerifiedPurchaseEntity purchase;

  @override
  State<_PurchaseShopRatingSheet> createState() =>
      _PurchaseShopRatingSheetState();
}

class _PurchaseShopRatingSheetState extends State<_PurchaseShopRatingSheet> {
  static const List<String> _ratingLabels = [
    '',
    'Çok kötü',
    'Kötü',
    'Orta',
    'İyi',
    'Çok iyi',
  ];

  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopRatingCubit, ShopRatingState>(
      builder: (context, state) {
        final isSubmitting = state is ShopRatingSubmitting;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return ColoredBox(
          key: const Key('purchase-shop-rating-sheet'),
          color: CustomerHomeV1Tokens.cream,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space12,
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space24 + bottomInset,
                ),
                child: state is ShopRatingSuccess
                    ? _RatingSuccessContent(
                        rating: state.rating.rating,
                        onClose: () => Navigator.of(context).pop(true),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _RatingSheetHandle(),
                          const SizedBox(height: CustomerHomeV1Tokens.space12),
                          _RatingEditorHeader(
                            shopName: widget.purchase.shopName,
                            isSubmitting: isSubmitting,
                            onClose: () => Navigator.of(context).pop(false),
                          ),
                          const SizedBox(height: CustomerHomeV1Tokens.space16),
                          const _RatingInfoCard(),
                          const SizedBox(height: CustomerHomeV1Tokens.space16),
                          Container(
                            key: const Key('purchase-rating-stars-card'),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: CustomerHomeV1Tokens.space8,
                              vertical: CustomerHomeV1Tokens.space16,
                            ),
                            decoration: BoxDecoration(
                              color: CustomerHomeV1Tokens.surface,
                              borderRadius: BorderRadius.circular(
                                CustomerHomeV1Tokens.radius20,
                              ),
                              border: Border.all(
                                color: CustomerHomeV1Tokens.border,
                              ),
                              boxShadow: CustomerHomeV1Tokens.softShadow,
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Deneyimin nasıldı?',
                                  style: TextStyle(
                                    color: CustomerHomeV1Tokens.navy,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: CustomerHomeV1Tokens.space8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(5, (index) {
                                    final rating = index + 1;
                                    final isSelected =
                                        rating <= _selectedRating;
                                    return IconButton(
                                      key: Key(
                                        'purchase-shop-rating-star-$rating',
                                      ),
                                      tooltip: '$rating yıldız',
                                      onPressed: isSubmitting
                                          ? null
                                          : () => setState(
                                              () => _selectedRating = rating,
                                            ),
                                      iconSize: 32,
                                      icon: Icon(
                                        isSelected
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: const Color(0xFFE09B15),
                                      ),
                                    );
                                  }),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: _selectedRating > 0
                                      ? Container(
                                          key: ValueKey(_selectedRating),
                                          margin: const EdgeInsets.only(
                                            top: CustomerHomeV1Tokens.space4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                CustomerHomeV1Tokens.space12,
                                            vertical:
                                                CustomerHomeV1Tokens.space4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF6DF),
                                            borderRadius: BorderRadius.circular(
                                              CustomerHomeV1Tokens.radiusPill,
                                            ),
                                          ),
                                          child: Text(
                                            _ratingLabels[_selectedRating],
                                            style: const TextStyle(
                                              color: CustomerHomeV1Tokens.navy,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(
                                          key: ValueKey(0),
                                          height: 24,
                                          child: Center(
                                            child: Text(
                                              'Bir yıldız seç',
                                              style: TextStyle(
                                                color:
                                                    CustomerHomeV1Tokens.muted,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (state is ShopRatingFailure) ...[
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space12,
                            ),
                            _RatingFailureCard(message: state.message),
                          ],
                          const SizedBox(height: CustomerHomeV1Tokens.space20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              key: const Key(
                                'purchase-shop-rating-submit-action',
                              ),
                              onPressed: isSubmitting || _selectedRating == 0
                                  ? null
                                  : () => context
                                        .read<ShopRatingCubit>()
                                        .submitRating(
                                          qrSessionId:
                                              widget.purchase.sourceQrSessionId,
                                          rating: _selectedRating,
                                        ),
                              style: FilledButton.styleFrom(
                                backgroundColor: CustomerHomeV1Tokens.petrol,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    CustomerHomeV1Tokens.mint,
                                disabledForegroundColor:
                                    CustomerHomeV1Tokens.muted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    CustomerHomeV1Tokens.radius16,
                                  ),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              icon: isSubmitting
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        key: Key('purchase-rating-progress'),
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Iconsax.send_2, size: 18),
                              label: Text(
                                isSubmitting
                                    ? 'Gönderiliyor...'
                                    : 'Puanı Gönder',
                              ),
                            ),
                          ),
                          const SizedBox(height: CustomerHomeV1Tokens.space8),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              key: const Key(
                                'purchase-shop-rating-cancel-action',
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CustomerHomeV1Tokens.navy,
                                side: const BorderSide(
                                  color: CustomerHomeV1Tokens.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    CustomerHomeV1Tokens.radius16,
                                  ),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Vazgeç'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RatingSheetHandle extends StatelessWidget {
  const _RatingSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.border,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
        ),
      ),
    );
  }
}

class _RatingEditorHeader extends StatelessWidget {
  const _RatingEditorHeader({
    required this.shopName,
    required this.isSubmitting,
    required this.onClose,
  });

  final String shopName;
  final bool isSubmitting;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('purchase-rating-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6DF),
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: Color(0xFFE09B15),
            size: 23,
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esnafa Puan Ver',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                shopName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space8),
        Material(
          color: CustomerHomeV1Tokens.surface,
          shape: const CircleBorder(
            side: BorderSide(color: CustomerHomeV1Tokens.border),
          ),
          child: IconButton(
            key: const Key('purchase-shop-rating-close-action'),
            tooltip: 'Kapat',
            onPressed: isSubmitting ? null : onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: CustomerHomeV1Tokens.navy,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingInfoCard extends StatelessWidget {
  const _RatingInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.shield_tick,
            color: CustomerHomeV1Tokens.petrol,
            size: 19,
          ),
          SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              'Puanın doğrulanmış alışverişine dayanır ve yalnızca bir kez '
              'gönderilebilir.',
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 10,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingFailureCard extends StatelessWidget {
  const _RatingFailureCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('purchase-rating-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        border: Border.all(color: const Color(0xFFF0C8BE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: CustomerHomeV1Tokens.coral,
            size: 19,
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSuccessContent extends StatelessWidget {
  const _RatingSuccessContent({required this.rating, required this.onClose});

  final int rating;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('purchase-rating-success-content'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const _RatingSheetHandle(),
        const SizedBox(height: CustomerHomeV1Tokens.space20),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF6DF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star_rounded,
            size: 40,
            color: Color(0xFFE09B15),
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space16),
        const Text(
          'Puanınız kaydedildi',
          style: TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space8),
        Text(
          '$rating/5 puan verdiniz. Teşekkür ederiz.',
          style: const TextStyle(
            color: CustomerHomeV1Tokens.muted,
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            key: const Key('purchase-shop-rating-success-close'),
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.petrol,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Iconsax.tick_circle, size: 19),
            label: const Text('Tamam'),
          ),
        ),
      ],
    );
  }
}

class _PurchaseLoadingState extends StatelessWidget {
  const _PurchaseLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-purchases-loading-state'),
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
              'Alışverişlerin hazırlanıyor',
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

class _ReturnRequestsTab extends StatelessWidget {
  const _ReturnRequestsTab();

  @override
  Widget build(BuildContext context) {
    return const _CenteredState(
      icon: Icons.assignment_return_outlined,
      title: 'Henüz iade talebin yok',
      description:
          'İade sistemi kullanıma açıldığında taleplerini ve durumlarını burada görebileceksin.',
    );
  }
}

class _CreateReturnRequestTab extends StatelessWidget {
  const _CreateReturnRequestTab();

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.add_business_outlined,
      title: 'İade talebi oluşturma hazırlanıyor',
      description:
          'İade talebini doğrulanmış bir alışveriş üzerinden başlatabileceksin.',
      actionLabel: 'Alışverişlerimi Gör',
      onAction: () => DefaultTabController.of(context).animateTo(0),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-purchases-state'),
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
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                description,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: CustomerHomeV1Tokens.space20),
                OutlinedButton.icon(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.petrol,
                    side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatMoney(double amount) {
  return '${amount.toStringAsFixed(2).replaceAll('.', ',')} TL';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day.$month.${local.year} • $hour:$minute';
}
