import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
            icon: Icons.cloud_off_rounded,
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
        final visibleShops = loaded.shops.take(8).toList(growable: false);
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
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: visibleShops.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: CustomerHomeV1Tokens.space8),
                itemBuilder: (context, index) {
                  final shop = visibleShops[index];
                  return _HomeShopCard(
                    shop: shop,
                    distanceMeters: loaded.distanceForShop(shop.id),
                    destinationBuilder: shopDestinationBuilder,
                  );
                },
              ),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          key: const Key('home-nearby-view-all'),
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: CustomerHomeV1Tokens.petrol,
            textStyle: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tümünü Gör'),
              SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
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
    return Material(
      key: Key('home-shop-${shop.id}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) =>
                destinationBuilder?.call(shop) ?? ShopProfileView(shop: shop),
          ),
        ),
        child: Container(
          width: 122,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ShopImageFallback(shopId: shop.id)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 7, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 3,
                      runSpacing: 1,
                      children: [
                        if (distanceMeters != null)
                          _ShopDetail(
                            icon: Icons.location_on_rounded,
                            text: _compactDistance(distanceMeters!),
                          ),
                        if (shop.ratingCount > 0)
                          _ShopDetail(
                            icon: Icons.star_rounded,
                            text: shop.rating.toStringAsFixed(1),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _compactDistance(double distanceMeters) {
    return CustomerProximityHelper.formatDistance(
      distanceMeters,
    ).replaceFirst('Yaklaşık ', '≈ ');
  }
}

class _ShopImageFallback extends StatelessWidget {
  const _ShopImageFallback({required this.shopId});

  final String shopId;

  static const _backgrounds = [
    CustomerHomeV1Tokens.petrol,
    Color(0xFF2A7E72),
    Color(0xFF274E67),
    Color(0xFF8B6045),
  ];

  @override
  Widget build(BuildContext context) {
    final background =
        _backgrounds[shopId.hashCode.abs() % _backgrounds.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, background.withValues(alpha: 0.78)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -10,
            bottom: -12,
            child: Icon(
              Icons.storefront_rounded,
              size: 76,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          const Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 9,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomerHomeV1Tokens.coral,
                    CustomerHomeV1Tokens.yellow,
                    CustomerHomeV1Tokens.coral,
                    CustomerHomeV1Tokens.yellow,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopDetail extends StatelessWidget {
  const _ShopDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: CustomerHomeV1Tokens.coral, size: 9),
        const SizedBox(width: 1),
        Text(
          text,
          style: const TextStyle(
            color: CustomerHomeV1Tokens.muted,
            fontSize: 7,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NearbyLoading extends StatelessWidget {
  const _NearbyLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('home-nearby-loading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yakındaki Mağazalar',
          style: TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space8),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) =>
                const SizedBox(width: CustomerHomeV1Tokens.space8),
            itemBuilder: (_, _) => Container(
              width: 122,
              decoration: BoxDecoration(
                color: CustomerHomeV1Tokens.mint,
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
            ),
          ),
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      ),
      child: Column(
        children: [
          Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 28),
          const SizedBox(height: CustomerHomeV1Tokens.space8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 10,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
