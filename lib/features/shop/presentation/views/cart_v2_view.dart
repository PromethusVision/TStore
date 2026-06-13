import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CartV2View extends StatelessWidget {
  const CartV2View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartV2Cubit>()..getActiveCartItems(),
      child: Scaffold(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
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
                          return _CartV2ItemCard(item: state.items[index]);
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: TSizes.spaceBtwItems),
                        itemCount: state.items.length,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _CartV2TotalBox(totalAmount: state.totalAmount),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    const _CancelActiveCartButton(),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _CartV2ItemCard extends StatelessWidget {
  const _CartV2ItemCard({required this.item});

  final CartItemV2Entity item;

  @override
  Widget build(BuildContext context) {
    final shopProduct = item.shopProduct;
    final shop = shopProduct?.shop;
    final product = shopProduct?.product;
    final shopPrice = shopProduct?.price ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
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
              IconButton(
                tooltip: 'Kaldır',
                onPressed: () => _confirmRemoveItem(context),
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
          _CartV2QuantityRow(item: item),
          _CartV2InfoRow(
            label: 'Satır toplamı',
            value: '₺${item.totalPrice.toStringAsFixed(2)}',
          ),
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

class _CartV2QuantityRow extends StatelessWidget {
  const _CartV2QuantityRow({required this.item});

  final CartItemV2Entity item;

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
                onPressed: item.quantity <= 1
                    ? null
                    : () {
                        context
                            .read<CartV2Cubit>()
                            .decrementItemQuantity(item);
                      },
                icon: const Icon(Icons.remove),
              ),
              Text(
                item.quantity.toString(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                tooltip: 'Artır',
                onPressed: () {
                  context.read<CartV2Cubit>().incrementItemQuantity(item);
                },
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
  const _CartV2InfoRow({
    required this.label,
    required this.value,
  });

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
  const _CartV2TotalBox({required this.totalAmount});

  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
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
        child: const Text('Mağaza Sepetini İptal Et'),
      ),
    );
  }

  Future<void> _confirmCancelCart(BuildContext context) async {
    final cubit = context.read<CartV2Cubit>();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mağaza sepetini iptal et'),
          content: const Text(
            'Bu mağaza sepeti iptal edilecek. Ürünler aktif sepetten kaldırılmış sayılacak.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('İptal Et'),
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
              'Bu alan ileride mağazada doğrulanacak sepetini gösterecek.',
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
