import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

typedef HomeShopDestinationBuilder = Widget Function(ShopEntity shop);

class HomeNearbyShopsSection extends StatelessWidget {
  const HomeNearbyShopsSection({
    super.key,
    required this.onViewAll,
    this.shopDestinationBuilder,
  });

  final VoidCallback onViewAll;
  final HomeShopDestinationBuilder? shopDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyShopsCubit, NearbyShopsState>(
      builder: (context, state) {
        if (state is NearbyShopsInitial || state is NearbyShopsLoading) {
          return const _NearbyLoading();
        }

        if (state is NearbyShopsError) {
          return _NearbyStatus(
            key: const Key('home-nearby-error'),
            icon: Icons.cloud_off_outlined,
            title: 'Mağazalar yüklenemedi',
            message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
            actionLabel: 'Tekrar Dene',
            onAction: context.read<NearbyShopsCubit>().loadShops,
          );
        }

        if (state is NearbyShopsEmpty) {
          return const _NearbyStatus(
            key: Key('home-nearby-empty'),
            icon: Icons.storefront_outlined,
            title: 'Yakında aktif mağaza bulunamadı',
            message: 'Yeni mağazalar eklendiğinde burada görünecek.',
          );
        }

        final loaded = state as NearbyShopsLoaded;
        final visibleShops = loaded.shops.take(3).toList(growable: false);
        final locationDescription = switch (loaded.locationSource) {
          NearbyLocationSource.savedLocation
              when loaded.locationLabel?.trim().isNotEmpty == true =>
            '${loaded.locationLabel!.trim()} konumuna göre',
          NearbyLocationSource.device => 'Mevcut konumuna göre',
          _ => null,
        };

        return Column(
          key: const Key('home-nearby-loaded'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Yakındaki Mağazalar',
              subtitle: locationDescription,
              onViewAll: onViewAll,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            for (final shop in visibleShops) ...[
              _HomeShopCard(
                shop: shop,
                distanceMeters: loaded.distanceForShop(shop.id),
                destinationBuilder: shopDestinationBuilder,
              ),
              const SizedBox(height: TSizes.sm),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onViewAll,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        TextButton(onPressed: onViewAll, child: const Text('Tümünü Gör')),
      ],
    );
  }
}

class _HomeShopCard extends StatelessWidget {
  const _HomeShopCard({
    required this.shop,
    required this.distanceMeters,
    this.destinationBuilder,
  });

  final ShopEntity shop;
  final double? distanceMeters;
  final HomeShopDestinationBuilder? destinationBuilder;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (shop.ratingCount > 0) 'Puan ${shop.rating.toStringAsFixed(1)}',
      if (distanceMeters != null)
        CustomerProximityHelper.formatDistance(distanceMeters!),
      if (shop.address?.trim().isNotEmpty == true) shop.address!.trim(),
    ];

    return Card(
      key: Key('home-shop-${shop.id}'),
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) =>
                destinationBuilder?.call(shop) ?? ShopProfileView(shop: shop),
          ),
        ),
        leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
        title: Text(shop.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: details.isEmpty
            ? null
            : Text(
                details.join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _NearbyLoading extends StatelessWidget {
  const _NearbyLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: Key('home-nearby-loading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Yakındaki Mağazalar'),
        SizedBox(height: TSizes.spaceBtwItems),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _NearbyStatus extends StatelessWidget {
  const _NearbyStatus({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: TSizes.sm),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.xs),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TSizes.sm),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
