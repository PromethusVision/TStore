import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_cubit.dart';
import 'package:t_store/features/purchases/presentation/cubit/purchase_history_state.dart';

class PurchasesView extends StatelessWidget {
  const PurchasesView({super.key, this.purchaseHistoryCubit});

  final PurchaseHistoryCubit? purchaseHistoryCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (purchaseHistoryCubit ?? sl<PurchaseHistoryCubit>())..loadPurchases(),
      child: const _PurchasesScaffold(),
    );
  }
}

class _PurchasesScaffold extends StatelessWidget {
  const _PurchasesScaffold();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alışverişlerim'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Alışverişlerim'),
              Tab(text: 'İade Taleplerim'),
              Tab(text: 'İade Talebi Oluştur'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PurchaseHistoryTab(),
            _ReturnRequestsTab(),
            _CreateReturnRequestTab(),
          ],
        ),
      ),
    );
  }
}

class _PurchaseHistoryTab extends StatelessWidget {
  const _PurchaseHistoryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseHistoryCubit, PurchaseHistoryState>(
      builder: (context, state) {
        if (state is PurchaseHistoryInitial ||
            state is PurchaseHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
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
        if (purchases.isEmpty) {
          return _CenteredState(
            icon: Icons.shopping_bag_outlined,
            title: 'Henüz doğrulanmış alışverişin yok',
            description:
                'Mağazada QR ile onaylanan alışverişlerin burada görünecek.',
            actionLabel: 'Yenile',
            onAction: context.read<PurchaseHistoryCubit>().loadPurchases,
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<PurchaseHistoryCubit>().loadPurchases,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            itemCount: purchases.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (context, index) =>
                _PurchaseCard(purchase: purchases[index]),
          ),
        );
      },
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase});

  final VerifiedPurchaseEntity purchase;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
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
                        _formatDate(purchase.confirmedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.sm,
                    vertical: TSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Onaylandı',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: TSizes.spaceBtwSections),
            ...purchase.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: TSizes.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName),
                          const SizedBox(height: 2),
                          Text(
                            '${item.quantity} adet × ${_formatMoney(item.unitPrice)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TSizes.sm),
                    Text(
                      _formatMoney(item.lineTotal),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${purchase.itemCount} ürün',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  'Toplam: ${_formatMoney(purchase.totalAmount)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TSizes.spaceBtwSections),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
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
