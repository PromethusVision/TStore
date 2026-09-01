import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
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
    this.visualPrototype = false,
  });

  final VoidCallback onViewAll;
  final HomeShopDestinationBuilder? shopDestinationBuilder;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyShopsCubit, NearbyShopsState>(
      builder: (context, state) {
        if (state is NearbyShopsInitial || state is NearbyShopsLoading) {
          return const _NearbyLoading();
        }

        if (state is NearbyShopsError) {
          return EsnaftaVarStateCard(
            key: const Key('home-nearby-error'),
            icon: Icons.cloud_off_rounded,
            title: 'Mağazalar yüklenemedi',
            message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
            actionLabel: 'Tekrar Dene',
            onAction: context.read<NearbyShopsCubit>().loadShops,
          );
        }

        if (state is NearbyShopsEmpty) {
          return const EsnaftaVarStateCard(
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
            EsnaftaVarSectionHeader(
              title: visualPrototype
                  ? 'Yakınındaki esnaf'
                  : 'Yakındaki Mağazalar',
              subtitle: locationDescription,
              actionLabel: 'Tümünü Gör',
              actionKey: const Key('home-nearby-view-all'),
              onAction: onViewAll,
            ),
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            if (visualPrototype)
              Column(
                children: [
                  for (
                    var index = 0;
                    index < visibleShops.take(3).length;
                    index++
                  ) ...[
                    if (index > 0)
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                    _HomeShopCard(
                      shop: visibleShops[index],
                      distanceMeters: loaded.distanceForShop(
                        visibleShops[index].id,
                      ),
                      destinationBuilder: shopDestinationBuilder,
                      visualPrototype: true,
                    ),
                  ],
                ],
              )
            else
              SizedBox(
                height: 190,
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

class _HomeShopCard extends StatefulWidget {
  const _HomeShopCard({
    required this.shop,
    required this.distanceMeters,
    this.destinationBuilder,
    this.visualPrototype = false,
  });

  final ShopEntity shop;
  final double? distanceMeters;
  final HomeShopDestinationBuilder? destinationBuilder;
  final bool visualPrototype;

  @override
  State<_HomeShopCard> createState() => _HomeShopCardState();
}

class _HomeShopCardState extends State<_HomeShopCard> {
  bool _isOpeningProfile = false;

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    if (widget.visualPrototype) {
      return _buildVisualPrototype(context, shop);
    }
    return Material(
      key: Key('home-shop-${shop.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        key: Key('home-shop-link-${shop.id}'),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        onTap: !shop.isActive || shop.id.trim().isEmpty
            ? null
            : () => unawaited(_openShopProfile(context)),
        child: Container(
          width: 158,
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
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 3,
                      runSpacing: 1,
                      children: [
                        if (widget.distanceMeters != null)
                          _ShopDetail(
                            icon: Icons.location_on_rounded,
                            text: _compactDistance(widget.distanceMeters!),
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

  Widget _buildVisualPrototype(BuildContext context, ShopEntity shop) {
    return Material(
      key: Key('home-shop-${shop.id}'),
      color: Colors.transparent,
      child: InkWell(
        key: Key('home-shop-link-${shop.id}'),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        onTap: !shop.isActive || shop.id.trim().isEmpty
            ? null
            : () => unawaited(_openShopProfile(context)),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius20,
                  ),
                  child: _ShopImageFallback(shopId: shop.id),
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        if (widget.distanceMeters != null)
                          _ShopDetail(
                            icon: Icons.location_on_rounded,
                            text: _compactDistance(widget.distanceMeters!),
                          ),
                        if (shop.ratingCount > 0)
                          _ShopDetail(
                            icon: Icons.star_rounded,
                            text: shop.rating.toStringAsFixed(1),
                          ),
                      ],
                    ),
                    if (shop.address?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        shop.address!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: CustomerHomeV1Tokens.petrol,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openShopProfile(BuildContext context) async {
    final shop = widget.shop;
    if (_isOpeningProfile || !shop.isActive || shop.id.trim().isEmpty) return;

    _isOpeningProfile = true;
    try {
      final destination =
          widget.destinationBuilder?.call(shop) ?? ShopProfileView(shop: shop);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _isOpeningProfile = false;
    }
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

  static const _backgrounds = CustomerHomeV1Tokens.merchantFallbacks;

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
              color: CustomerHomeV1Tokens.onPrimary.withValues(alpha: 0.13),
            ),
          ),
          const Center(
            child: Icon(
              Icons.storefront_rounded,
              color: CustomerHomeV1Tokens.onPrimary,
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
        Icon(icon, color: CustomerHomeV1Tokens.coral, size: 14),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: CustomerHomeV1Tokens.muted,
            fontSize: 10.5,
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
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) =>
                const SizedBox(width: CustomerHomeV1Tokens.space8),
            itemBuilder: (_, _) => Container(
              width: 158,
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
