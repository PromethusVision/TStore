import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
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
    return FutureBuilder<Either<String, List<ShopProductEntity>>>(
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
                  'Mağaza fiyatı: \$${shopProduct.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (rating > 0)
                  Text(
                    'Puan: ${rating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
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
