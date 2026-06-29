import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

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
  static bool _isConflictDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _future = sl<GetShopProductsByProductUsecase>()(
      GetShopProductsByProductParams(productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartV2Cubit, CartV2State>(
        listenWhen: (previous, current) {
          return current is CartV2ItemAdded ||
              current is CartV2Error ||
              current is CartV2ShopConflictState;
        },
        listener: (context, state) {
          if (state is CartV2ItemAdded) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Ürün mağaza sepetine eklendi'),
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
              return const Text(
                'Satıcı bilgileri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
              );
            }

            return snapshot.data!.fold(
              (_) => const Text(
                'Satıcı bilgileri yüklenemedi. Lütfen daha sonra tekrar deneyin.',
              ),
              (shopProducts) {
                if (shopProducts.isEmpty) {
                  return const Text(
                    'Bu ürünü satan esnaf henüz listelenmiyor.',
                  );
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
    );
  }

  Future<void> _showShopConflictDialog(
    BuildContext context,
    CartV2ShopConflictState state,
  ) async {
    if (_isConflictDialogOpen) return;

    _isConflictDialogOpen = true;
    final conflict = state.conflict;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sepetinizde başka bir esnafa ait ürünler var'),
          content: const Text(
            'Bu ürünü eklemek için mevcut mağaza sepetiniz iptal edilip bu esnafla devam edilecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                context.read<CartV2Cubit>().replaceActiveCartWithShopProduct(
                  shopProductId: conflict.shopProductId,
                  quantity: conflict.quantity,
                );
              },
              child: const Text(
                'Mevcut mağaza sepetini iptal et ve devam et',
              ),
            ),
          ],
        );
      },
    );

    if (mounted) {
      _isConflictDialogOpen = false;
    }
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
    final canAddToCart = shopProduct.isActive && shopProduct.isAvailable;
    final colorScheme = Theme.of(context).colorScheme;

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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap:
                        shop == null ? null : () => _openShopProfile(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop?.name ?? 'Bilinmeyen esnaf',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (shop != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mağaza profilini görüntüle',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (shop != null)
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                shopProduct.isAvailable
                    ? const _AvailabilityChip()
                    : const _UnavailableChip(),
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
              spacing: TSizes.sm,
              runSpacing: TSizes.xs,
              children: [
                _PriceChip(price: shopProduct.price),
                if (rating > 0) _RatingChip(rating: rating),
              ],
            ),
            const SizedBox(height: TSizes.sm),
            Align(
              alignment: Alignment.centerRight,
              child: canAddToCart
                  ? OutlinedButton(
                      onPressed: () => _handleAddToCart(context),
                      child: const Text('Bu Esnaftan Sepete Ekle'),
                    )
                  : Text(
                      'Şu an rafta yok',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShopProfile(BuildContext context) {
    final shop = shopProduct.shop;
    if (shop == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShopProfileView(shop: shop)),
    );
  }

  void _handleAddToCart(BuildContext context) {
    final user = SupabaseService.instance.currentUser;

    if (user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
      return;
    }

    context.read<CartV2Cubit>().addShopProductToCart(
          shopProductId: shopProduct.id,
          quantity: 1,
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

class _UnavailableChip extends StatelessWidget {
  const _UnavailableChip();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Rafta yok',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final double price;

  const _PriceChip({required this.price});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '₺${price.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.sm,
        vertical: TSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
