import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

class CustomerRatingsView extends StatelessWidget {
  const CustomerRatingsView({
    super.key,
    this.purchaseHistoryCubit,
    this.purchasesDestinationBuilder,
  });

  final PurchaseHistoryCubit? purchaseHistoryCubit;
  final WidgetBuilder? purchasesDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (purchaseHistoryCubit ?? sl<PurchaseHistoryCubit>())..loadPurchases(),
      child: _CustomerRatingsScaffold(
        purchasesDestinationBuilder: purchasesDestinationBuilder,
      ),
    );
  }
}

class _CustomerRatingsScaffold extends StatefulWidget {
  const _CustomerRatingsScaffold({this.purchasesDestinationBuilder});

  final WidgetBuilder? purchasesDestinationBuilder;

  @override
  State<_CustomerRatingsScaffold> createState() =>
      _CustomerRatingsScaffoldState();
}

class _CustomerRatingsScaffoldState extends State<_CustomerRatingsScaffold> {
  bool _isOpeningPurchases = false;

  Future<void> _openPurchases() async {
    if (_isOpeningPurchases) return;

    setState(() => _isOpeningPurchases = true);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder:
              widget.purchasesDestinationBuilder ??
              (_) => const PurchasesView(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningPurchases = false);
      } else {
        _isOpeningPurchases = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-ratings-content'),
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
                  child: _RatingsHeader(),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
                Expanded(
                  child: BlocBuilder<PurchaseHistoryCubit, PurchaseHistoryState>(
                    builder: (context, state) {
                      if (state is PurchaseHistoryInitial ||
                          state is PurchaseHistoryLoading) {
                        return const _RatingsLoadingState();
                      }

                      if (state is PurchaseHistoryError) {
                        return _RatingsStateView(
                          icon: Icons.error_outline_rounded,
                          title: 'Değerlendirmelerin yüklenemedi',
                          description: state.message,
                          actionLabel: 'Tekrar Dene',
                          onAction: context
                              .read<PurchaseHistoryCubit>()
                              .loadPurchases,
                        );
                      }

                      final ratings =
                          (state as PurchaseHistoryLoaded).purchases
                              .where(
                                (purchase) => purchase.customerRating != null,
                              )
                              .toList(growable: false)
                            ..sort(
                              (first, second) => _ratingDate(
                                second,
                              ).compareTo(_ratingDate(first)),
                            );

                      if (ratings.isEmpty) {
                        return _RatingsStateView(
                          icon: Icons.star_outline_rounded,
                          title: 'Henüz değerlendirme yapmadınız',
                          description:
                              'Mağazalara verdiğiniz puanlar burada görünecek.',
                          actionLabel: 'Alışverişlerime Git',
                          onAction: _isOpeningPurchases ? null : _openPurchases,
                        );
                      }

                      return RefreshIndicator(
                        color: EsnaftaVarColors.primary,
                        onRefresh: context
                            .read<PurchaseHistoryCubit>()
                            .loadPurchases,
                        child: ListView.separated(
                          key: const Key('customer-ratings-list'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            EsnaftaVarSpacing.md,
                            EsnaftaVarSpacing.xxs,
                            EsnaftaVarSpacing.md,
                            EsnaftaVarSpacing.xl,
                          ),
                          itemCount: ratings.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: EsnaftaVarSpacing.sm),
                          itemBuilder: (context, index) =>
                              _RatingCard(purchase: ratings[index]),
                        ),
                      );
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
}

class _RatingsHeader extends StatelessWidget {
  const _RatingsHeader();
  @override
  Widget build(BuildContext context) => Row(
    key: const Key('customer-ratings-header'),
    children: [
      EsnaftaVarSurfaceIconButton(
        buttonKey: const Key('customer-ratings-back-button'),
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
              'Esnaf değerlendirmelerim',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EsnaftaVarSpacing.xxs),
            Text(
              'Mağazalara verdiğin puanlar.',
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

class _RatingsLoadingState extends StatelessWidget {
  const _RatingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-ratings-loading-state'),
        margin: const EdgeInsets.all(EsnaftaVarSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: EsnaftaVarSpacing.xl,
          vertical: EsnaftaVarSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
          boxShadow: EsnaftaVarElevation.xs,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: EsnaftaVarColors.primary,
              ),
            ),
            SizedBox(width: EsnaftaVarSpacing.sm),
            Flexible(
              child: Text(
                'Değerlendirmelerin yükleniyor',
                style: TextStyle(
                  color: EsnaftaVarColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.purchase});
  final VerifiedPurchaseEntity purchase;
  @override
  Widget build(BuildContext context) {
    final rating = purchase.customerRating!;
    final text = Theme.of(context).textTheme;
    return Container(
      key: ValueKey('customer-rating-${purchase.id}'),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
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
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: EsnaftaVarColors.primary,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(child: Text(purchase.shopName, style: text.titleMedium)),
              const SizedBox(width: EsnaftaVarSpacing.xs),
              Text(
                '$rating/5',
                style: text.titleMedium?.copyWith(
                  color: EsnaftaVarColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          Semantics(
            label: '5 üzerinden $rating yıldız',
            child: ExcludeSemantics(
              child: Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: EsnaftaVarColors.highlight,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Text(
            'Değerlendirme: ${_formatDate(_ratingDate(purchase))}',
            style: text.bodySmall?.copyWith(
              color: EsnaftaVarColors.textSecondary,
            ),
          ),
          const Divider(height: EsnaftaVarSpacing.xl),
          Text(
            'İlgili alışveriş',
            style: text.labelMedium?.copyWith(color: EsnaftaVarColors.primary),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${purchase.itemCount} ürün',
                  style: text.bodySmall,
                ),
              ),
              Flexible(
                child: Text(
                  _formatMoney(purchase.totalAmount),
                  textAlign: TextAlign.end,
                  style: text.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.xxs),
          Text(
            'Alışveriş tarihi: ${_formatDate(purchase.confirmedAt)}',
            style: text.bodySmall?.copyWith(
              color: EsnaftaVarColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingsStateView extends StatelessWidget {
  const _RatingsStateView({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EsnaftaVarStateCard(
            key: const Key('customer-ratings-state'),
            icon: icon,
            title: title,
            message: description,
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          OutlinedButton(
            key: const Key('customer-ratings-state-action'),
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    ),
  );
}

DateTime _ratingDate(VerifiedPurchaseEntity purchase) {
  return purchase.customerRatedAt ?? purchase.confirmedAt;
}

String _formatMoney(double amount) {
  return '${amount.toStringAsFixed(2).replaceAll('.', ',')} TL';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}
