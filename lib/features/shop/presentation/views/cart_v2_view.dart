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
          child: BlocBuilder<CartV2Cubit, CartV2State>(
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
          Text(
            shop?.name ?? 'Bilinmeyen esnaf',
            style: Theme.of(context).textTheme.titleMedium,
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
          _CartV2InfoRow(
            label: 'Adet',
            value: item.quantity.toString(),
          ),
          _CartV2InfoRow(
            label: 'Satır toplamı',
            value: '₺${item.totalPrice.toStringAsFixed(2)}',
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
