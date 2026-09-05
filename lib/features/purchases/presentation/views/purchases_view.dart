import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/shop_rating_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_by_id_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

part 'purchases_final_ui.dart';

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
      length: 2,
      child: Scaffold(
        backgroundColor: EsnaftaVarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              key: const Key('customer-purchases-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xs,
                      EsnaftaVarSpacing.md,
                      0,
                    ),
                    child: _PurchasesFinalHeader(),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: EsnaftaVarSpacing.md,
                    ),
                    child: _PurchasesFinalControls(),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.xs),
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

class _PurchasesTabBar extends StatelessWidget {
  const _PurchasesTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-purchases-tab-bar'),
      height: 64,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.xxs),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: TabBar(
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: EsnaftaVarColors.primary,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: EsnaftaVarColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          height: 1.15,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
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
              EsnaftaVarSpacing.md,
              EsnaftaVarSpacing.xs,
              EsnaftaVarSpacing.md,
              EsnaftaVarSpacing.xl,
            ),
            itemCount:
                visiblePurchases.length + (showMissingTargetMessage ? 1 : 0),
            separatorBuilder: (_, _) =>
                const SizedBox(height: EsnaftaVarSpacing.sm),
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
                    const SizedBox(height: EsnaftaVarSpacing.xs),
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
        horizontal: EsnaftaVarSpacing.sm,
        vertical: EsnaftaVarSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        border: Border.all(
          color: EsnaftaVarColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.tick_circle,
            color: EsnaftaVarColors.primary,
            size: 19,
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Text(
              isRecentQrPurchase
                  ? 'Az önce onaylanan alışveriş: $shopName'
                  : 'Bildirimdeki alışveriş: $shopName',
              style: const TextStyle(
                color: EsnaftaVarColors.primary,
                fontSize: 13,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.warningSoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
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
                color: EsnaftaVarColors.primary,
                size: 20,
              ),
              const SizedBox(width: EsnaftaVarSpacing.xs),
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
                    color: EsnaftaVarColors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isRecentQrPurchase) ...[
            const SizedBox(height: EsnaftaVarSpacing.xs),
            if (!automaticCheckCompleted) ...[
              const LinearProgressIndicator(
                key: Key('automatic-purchase-check-progress'),
                minHeight: 3,
                color: EsnaftaVarColors.primary,
                backgroundColor: EsnaftaVarColors.surface,
              ),
              const SizedBox(height: EsnaftaVarSpacing.xxs),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('retry-recent-qr-purchase-action'),
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: EsnaftaVarColors.primary,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 13,
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

class _PurchaseCardState extends State<_PurchaseCard> {
  bool _isOpeningShop = false;
  bool _isOpeningRating = false;

  @override
  Widget build(BuildContext context) => _buildPurchaseFinalCard(this, context);

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
        backgroundColor: EsnaftaVarColors.surface,
        barrierColor: EsnaftaVarColors.textPrimary.withValues(alpha: 0.32),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(EsnaftaVarRadii.xxLarge),
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
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ShopRatingCubit, ShopRatingState>(
    builder: (context, state) {
      final isSubmitting = state is ShopRatingSubmitting;
      final text = Theme.of(context).textTheme;
      return PopScope(
        canPop: !isSubmitting,
        child: ColoredBox(
          key: const Key('purchase-shop-rating-sheet'),
          color: EsnaftaVarColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: state is ShopRatingSuccess
                  ? _RatingSuccessContent(
                      rating: state.rating.rating,
                      onClose: () => Navigator.of(context).pop(true),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _RatingSheetHandle(),
                        const SizedBox(height: 12),
                        _RatingEditorHeader(
                          shopName: widget.purchase.shopName,
                          isSubmitting: isSubmitting,
                          onClose: () => Navigator.of(context).pop(false),
                        ),
                        const SizedBox(height: 16),
                        const _RatingInfoCard(),
                        const SizedBox(height: 24),
                        Column(
                          key: const Key('purchase-rating-stars-card'),
                          children: [
                            Text(
                              'Mağaza deneyimin nasıldı?',
                              style: text.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final rating = index + 1;
                                return Semantics(
                                  selected: rating == _selectedRating,
                                  child: IconButton(
                                    key: Key(
                                      'purchase-shop-rating-star-$rating',
                                    ),
                                    tooltip: '$rating yıldız',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                    onPressed: isSubmitting
                                        ? null
                                        : () => setState(
                                            () => _selectedRating = rating,
                                          ),
                                    iconSize: 32,
                                    icon: Icon(
                                      rating <= _selectedRating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: EsnaftaVarColors.highlight,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedRating > 0
                                  ? _ratingLabels[_selectedRating]
                                  : 'Bir yıldız seç',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                        if (state is ShopRatingFailure) ...[
                          const SizedBox(height: 16),
                          _RatingFailureCard(message: state.message),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          key: const Key('purchase-shop-rating-submit-action'),
                          onPressed: isSubmitting || _selectedRating == 0
                              ? null
                              : () => context
                                    .read<ShopRatingCubit>()
                                    .submitRating(
                                      qrSessionId:
                                          widget.purchase.sourceQrSessionId,
                                      rating: _selectedRating,
                                    ),
                          icon: isSubmitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    key: Key('purchase-rating-progress'),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            isSubmitting ? 'Gönderiliyor...' : 'Puanı Gönder',
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const Key('purchase-shop-rating-cancel-action'),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: const Text('Vazgeç'),
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

class _RatingSheetHandle extends StatelessWidget {
  const _RatingSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: EsnaftaVarColors.borderDefault,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
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
  Widget build(BuildContext context) => Row(
    key: const Key('purchase-rating-header'),
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esnafa Puan Ver',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              shopName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EsnaftaVarColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        key: const Key('purchase-shop-rating-close-action'),
        tooltip: 'Kapat',
        icon: const Icon(Icons.close_rounded),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: isSubmitting ? null : onClose,
      ),
    ],
  );
}

class _RatingInfoCard extends StatelessWidget {
  const _RatingInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.shield_tick, color: EsnaftaVarColors.primary, size: 19),
          SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Text(
              'Puanın doğrulanmış alışverişine dayanır ve yalnızca bir kez '
              'gönderilebilir.',
              style: TextStyle(
                color: EsnaftaVarColors.textPrimary,
                fontSize: 13,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.errorSoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        border: Border.all(color: EsnaftaVarColors.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: EsnaftaVarColors.accent,
            size: 19,
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: EsnaftaVarColors.textPrimary,
                fontSize: 13,
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
        const SizedBox(height: EsnaftaVarSpacing.lg),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: EsnaftaVarColors.warningSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star_rounded,
            size: 40,
            color: EsnaftaVarColors.highlight,
          ),
        ),
        const SizedBox(height: EsnaftaVarSpacing.md),
        const Text(
          'Puanınız kaydedildi',
          style: TextStyle(
            color: EsnaftaVarColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          '$rating/5 puan verdiniz. Teşekkür ederiz.',
          style: const TextStyle(
            color: EsnaftaVarColors.textSecondary,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EsnaftaVarSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            key: const Key('purchase-shop-rating-success-close'),
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: EsnaftaVarColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
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
        margin: const EdgeInsets.all(EsnaftaVarSpacing.md),
        padding: const EdgeInsets.all(EsnaftaVarSpacing.xl),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
          boxShadow: EsnaftaVarElevation.xs,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: EsnaftaVarColors.primary,
              ),
            ),
            SizedBox(height: EsnaftaVarSpacing.sm),
            Text(
              'Alışverişlerin hazırlanıyor',
              style: TextStyle(
                color: EsnaftaVarColors.textPrimary,
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
  const _CreateReturnRequestTab({required this.onSeePurchases});
  final VoidCallback onSeePurchases;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.add_business_outlined,
      title: 'İade talebi oluşturma hazırlanıyor',
      description:
          'İade talebini doğrulanmış bir alışveriş üzerinden başlatabileceksin.',
      actionLabel: 'Alışverişlerimi Gör',
      onAction: onSeePurchases,
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
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: EsnaftaVarStateCard(
        key: const Key('customer-purchases-state'),
        icon: icon,
        title: title,
        message: description,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    ),
  );
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
