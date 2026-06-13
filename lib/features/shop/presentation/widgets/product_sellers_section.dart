import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';

class ProductSellersSection extends StatefulWidget {
  final String productId;

  const ProductSellersSection({
    super.key,
    required this.productId,
  });

  @override
  State<ProductSellersSection> createState() => _ProductSellersSectionState();
}

class _ProductSellersSectionState extends State<ProductSellersSection> {
  late final Future<Either<String, List<ShopProductEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<GetShopProductsByProductUsecase>()(
      GetShopProductsByProductParams(productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CartV2Cubit>(
      create: (_) => sl<CartV2Cubit>(),
      child: BlocListener<CartV2Cubit, CartV2State>(
        listener: (context, state) {
          if (state is CartV2ItemAdded) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('V2 mağaza sepetine eklendi'),
                ),
              );
          } else if (state is CartV2Error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message)),
              );
          } else if (state is CartV2ShopConflictState) {
            _showShopConflictDialog(context, state);
          }
        },
        child: FutureBuilder<Either<String, List<ShopProductEntity>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Esnaf bilgileri yüklenemedi');
            }

            return snapshot.data!.fold(
              (_) => const Text('Esnaf bilgileri yüklenemedi'),
              (shopProducts) {
                if (shopProducts.isEmpty) {
                  return const Text('Bu ürünü satan esnaf bulunamadı');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu ürünü satan esnaflar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shopProducts.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: TSizes.spaceBtwItems),
                      itemBuilder: (context, index) {
                        return _SellerTile(shopProduct: shopProducts[index]);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showShopConflictDialog(
    BuildContext context,
    CartV2ShopConflictState state,
  ) {
    final cubit = context.read<CartV2Cubit>();
    final conflict = state.conflict;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sepetinizde başka bir esnafa ait ürünler var'),
          content: const Text(
            'Bu ürünü eklemek için mevcut mağaza sepeti iptal edilip yeni esnafla devam edilecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                cubit.replaceActiveCartWithShopProduct(
                  shopProductId: conflict.shopProductId,
                  quantity: conflict.quantity,
                );
              },
              child: const Text('Sepeti temizle ve devam et'),
            ),
          ],
        );
      },
    );
  }
}

class _SellerTile extends StatelessWidget {
  final ShopProductEntity shopProduct;

  const _SellerTile({
    required this.shopProduct,
  });

  @override
  Widget build(BuildContext context) {
    final shop = shopProduct.shop;
    final rating = shop?.rating ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    shop?.name ?? 'Bilinmeyen esnaf',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (shopProduct.isAvailable) const _AvailabilityChip(),
              ],
            ),
            if (shop?.address != null && shop!.address!.isNotEmpty) ...[
              const SizedBox(height: TSizes.xs),
              Text(
                shop.address!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: TSizes.sm),
            Wrap(
              spacing: TSizes.spaceBtwItems,
              runSpacing: TSizes.xs,
              children: [
                Text(
                  'Mağaza fiyatı: ₺${shopProduct.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (rating > 0)
                  Text(
                    'Puan: ${rating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: TSizes.sm),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CartV2Cubit>().addShopProductToCart(
                          shopProductId: shopProduct.id,
                          quantity: 1,
                        );
                  },
                  child: const Text('V2 Test Sepete Ekle'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Rafta var',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.green.shade700,
            ),
      ),
    );
  }
}
