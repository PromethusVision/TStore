import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/view_models/cart_counter_icon_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

class NearbyView extends StatelessWidget {
  const NearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NearbyShopsCubit>()..loadShops(),
      child: const _NearbyContent(),
    );
  }
}

class _NearbyContent extends StatelessWidget {
  const _NearbyContent();

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: Text(
            'Yakındakiler',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            CartCounterIcon(
              cartCounterIconModel: CartCounterIconModel(
                color: dark ? TColors.white : TColors.dark,
                onPressed: () => _openCart(context),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TSizes.defaultSpace,
            TSizes.sm,
            TSizes.defaultSpace,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Çevrendeki mağazaları ve ürünleri keşfet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Expanded(
                child: BlocBuilder<NearbyShopsCubit, NearbyShopsState>(
                  builder: (context, state) {
                    if (state is NearbyShopsInitial ||
                        state is NearbyShopsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is NearbyShopsError) {
                      return _NearbyMessage(
                        icon: Icons.cloud_off_outlined,
                        title: 'Mağazalar yüklenemedi.',
                        message: 'Lütfen bağlantını kontrol edip tekrar dene.',
                        actionLabel: 'Tekrar Dene',
                        onAction: context.read<NearbyShopsCubit>().loadShops,
                      );
                    }

                    if (state is NearbyShopsEmpty) {
                      return const _NearbyMessage(
                        icon: Icons.storefront_outlined,
                        title: 'Yakınında gösterilebilecek mağaza bulunamadı.',
                        message:
                            'Konumunu veya arama kriterlerini değiştirerek tekrar deneyebilirsin.',
                      );
                    }

                    if (state is NearbyShopsLoaded) {
                      return RefreshIndicator(
                        onRefresh: context.read<NearbyShopsCubit>().loadShops,
                        child: ListView.separated(
                          key: const Key('nearby-shop-list'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            bottom: TSizes.defaultSpace,
                          ),
                          itemCount: state.shops.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: TSizes.spaceBtwItems),
                          itemBuilder: (context, index) {
                            return _NearbyShopCard(shop: state.shops[index]);
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    final user = SupabaseService.instance.currentUser;

    if (user == null) {
      THelperFunctions.navigateToScreen(context, const LoginView());
      return;
    }

    THelperFunctions.navigateToScreen(context, const CartV2View());
  }
}

class _NearbyShopCard extends StatelessWidget {
  final ShopEntity shop;

  const _NearbyShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAddress = _hasText(shop.address);
    final hasCoordinates = shop.latitude != null && shop.longitude != null;

    return Card(
      key: ValueKey('nearby-shop-${shop.id}'),
      margin: EdgeInsets.zero,
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
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.storefront_outlined),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (shop.rating > 0) ...[
                        const SizedBox(height: TSizes.xs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: TSizes.xs),
                            Text(
                              'Puan ${shop.rating.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (_hasText(shop.description)) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(shop.description!.trim()),
            ],
            if (hasAddress) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              _ShopInfoLine(
                icon: Icons.location_on_outlined,
                text: shop.address!.trim(),
              ),
            ] else if (hasCoordinates) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              const _ShopInfoLine(
                icon: Icons.location_on_outlined,
                text: 'Konum bilgisi mevcut',
              ),
            ],
            if (_hasText(shop.phone)) ...[
              const SizedBox(height: TSizes.sm),
              _ShopInfoLine(
                icon: Icons.call_outlined,
                text: shop.phone!.trim(),
              ),
            ],
            if (shop.openingHours.isNotEmpty) ...[
              const SizedBox(height: TSizes.sm),
              _ShopInfoLine(
                icon: Icons.schedule_outlined,
                text: _formatOpeningHours(shop.openingHours),
              ),
            ],
            const SizedBox(height: TSizes.spaceBtwItems),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openShop(context),
                icon: const Icon(Icons.arrow_forward_outlined),
                label: const Text('Mağazayı Gör'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShop(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ShopProfileView(shop: shop)));
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _formatOpeningHours(Map<String, dynamic> openingHours) {
    return openingHours.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

class _ShopInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ShopInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: TSizes.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NearbyMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
