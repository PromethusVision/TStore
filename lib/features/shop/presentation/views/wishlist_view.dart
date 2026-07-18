import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final Set<String> _removingProductIds = {};

  @override
  void initState() {
    super.initState();
    unawaited(context.read<WishlistCubit>().getWishlist());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: Text(
            TTexts.wishlistView,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            if (state is WishlistInitial ||
                state is WishlistLoading ||
                state is WishlistItemAdded ||
                state is WishlistItemRemoved) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WishlistError) {
              return _WishlistStatus(
                icon: Iconsax.warning_2,
                title: 'Favorilerin yüklenemedi',
                description: 'Bağlantını kontrol edip yeniden deneyebilirsin.',
                actionLabel: 'Tekrar Dene',
                onAction: _reloadWishlist,
              );
            }

            final items = (state as WishlistLoaded).items
                .where((item) => item.product != null)
                .toList(growable: false);

            if (items.isEmpty) {
              return _WishlistStatus(
                icon: Iconsax.heart,
                title: 'Henüz favorin yok',
                description:
                    'Beğendiğin ürünleri favorilerine eklediğinde burada '
                    'görebilirsin.',
                actionLabel: 'Ürünleri Keşfet',
                onAction: _exploreProducts,
              );
            }

            return RefreshIndicator(
              onRefresh: context.read<WishlistCubit>().getWishlist,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: TSizes.gridViewSpacing,
                            crossAxisSpacing: TSizes.gridViewSpacing,
                            mainAxisExtent: 288,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(items[index]),
                        childCount: items.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(WishlistItemEntity item) {
    final product = item.product!;
    final isRemoving = _removingProductIds.contains(item.productId);

    return VerticalProductCard(
      product: product,
      showFavoriteAction: true,
      favoriteActionLoading: isRemoving,
      onFavoritePressed: isRemoving ? null : () => _removeFavorite(item),
    );
  }

  Future<void> _removeFavorite(WishlistItemEntity item) async {
    if (_removingProductIds.contains(item.productId)) return;

    setState(() => _removingProductIds.add(item.productId));
    await context.read<WishlistCubit>().removeFromWishlist(item.productId);

    if (!mounted) return;
    setState(() => _removingProductIds.remove(item.productId));
  }

  void _reloadWishlist() {
    unawaited(context.read<WishlistCubit>().getWishlist());
  }

  void _exploreProducts() {
    context.read<NavigationMenuCubit>().changeIndex(0);
  }
}

class _WishlistStatus extends StatelessWidget {
  const _WishlistStatus({
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
            Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
