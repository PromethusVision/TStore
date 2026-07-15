import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

class CustomerRatingsView extends StatelessWidget {
  const CustomerRatingsView({super.key, this.purchaseHistoryCubit});

  final PurchaseHistoryCubit? purchaseHistoryCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (purchaseHistoryCubit ?? sl<PurchaseHistoryCubit>())..loadPurchases(),
      child: const _CustomerRatingsScaffold(),
    );
  }
}

class _CustomerRatingsScaffold extends StatelessWidget {
  const _CustomerRatingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Değerlendirmelerim')),
      body: BlocBuilder<PurchaseHistoryCubit, PurchaseHistoryState>(
        builder: (context, state) {
          if (state is PurchaseHistoryInitial ||
              state is PurchaseHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PurchaseHistoryError) {
            return _RatingsStateView(
              icon: Icons.error_outline,
              title: 'Değerlendirmelerin yüklenemedi',
              description: state.message,
              actionLabel: 'Tekrar Dene',
              onAction: context.read<PurchaseHistoryCubit>().loadPurchases,
            );
          }

          final ratings =
              (state as PurchaseHistoryLoaded).purchases
                  .where((purchase) => purchase.customerRating != null)
                  .toList(growable: false)
                ..sort(
                  (first, second) =>
                      _ratingDate(second).compareTo(_ratingDate(first)),
                );

          if (ratings.isEmpty) {
            return _RatingsStateView(
              icon: Icons.star_outline_rounded,
              title: 'Henüz değerlendirme yapmadınız',
              description:
                  'Doğrulanmış alışverişlerinize verdiğiniz mağaza puanları burada görünecek.',
              actionLabel: 'Alışverişlerime Git',
              onAction: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PurchasesView())),
            );
          }

          return RefreshIndicator(
            onRefresh: context.read<PurchaseHistoryCubit>().loadPurchases,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              itemCount: ratings.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) =>
                  _RatingCard(purchase: ratings[index]),
            ),
          );
        },
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

    return Card(
      key: ValueKey('customer-rating-${purchase.id}'),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.storefront_outlined),
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.shopName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        'Değerlendirme: ${_formatDate(ratingDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Semantics(
              label: '$rating üzerinden 5 yıldız',
              child: Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Text(
                    '$rating/5',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: TSizes.spaceBtwSections),
            Text(
              'İlgili alışveriş',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              '${purchase.itemCount} ürün • ${_formatMoney(purchase.totalAmount)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              'Alışveriş tarihi: ${_formatDate(purchase.confirmedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
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
