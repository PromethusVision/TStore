import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-ratings-content'),
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
                  child: _RatingsHeader(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
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
                        color: CustomerHomeV1Tokens.petrol,
                        onRefresh: context
                            .read<PurchaseHistoryCubit>()
                            .loadPurchases,
                        child: ListView.separated(
                          key: const Key('customer-ratings-list'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            CustomerHomeV1Tokens.space16,
                            CustomerHomeV1Tokens.space4,
                            CustomerHomeV1Tokens.space16,
                            CustomerHomeV1Tokens.space24,
                          ),
                          itemCount: ratings.length,
                          separatorBuilder: (_, _) => const SizedBox(
                            height: CustomerHomeV1Tokens.space12,
                          ),
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
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-ratings-header'),
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
              key: const Key('customer-ratings-back-button'),
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
                  'Değerlendirmelerim',
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
                  'Mağazalara verdiğin puanları görüntüle',
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
              color: const Color(0xFFFFF0C7),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Iconsax.star1,
              color: CustomerHomeV1Tokens.yellow,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingsLoadingState extends StatelessWidget {
  const _RatingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-ratings-loading-state'),
        margin: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space24,
          vertical: CustomerHomeV1Tokens.space20,
        ),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            ),
            SizedBox(width: CustomerHomeV1Tokens.space12),
            Flexible(
              child: Text(
                'Değerlendirmelerin yükleniyor',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
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
    final ratingDate = _ratingDate(purchase);

    return Container(
      key: ValueKey('customer-rating-${purchase.id}'),
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
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      'Değerlendirme: ${_formatDate(ratingDate)}',
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomerHomeV1Tokens.space12,
                  vertical: CustomerHomeV1Tokens.space8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0C7),
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radiusPill,
                  ),
                ),
                child: Text(
                  '$rating/5',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: CustomerHomeV1Tokens.space12,
              vertical: CustomerHomeV1Tokens.space8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: Semantics(
              label: '$rating üzerinden 5 yıldız',
              child: Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: CustomerHomeV1Tokens.yellow,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İlgili alışveriş',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.petrol,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  '${purchase.itemCount} ürün • ${_formatMoney(purchase.totalAmount)}',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Alışveriş tarihi: ${_formatDate(purchase.confirmedAt)}',
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-ratings-state'),
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
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 29, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                description,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('customer-ratings-state-action'),
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.petrol,
                    side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
                    padding: const EdgeInsets.symmetric(
                      vertical: CustomerHomeV1Tokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
