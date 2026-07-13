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
                        title: 'Gösterilebilecek mağaza bulunamadı.',
                        message:
                            'Şu anda aktif bir mağaza görünmüyor. Daha sonra tekrar deneyebilirsin.',
                      );
                    }

                    if (state is NearbyShopsLoaded) {
                      return _LoadedNearbyShops(
                        state: state,
                        onLocationRequested: () =>
                            _showLocationExplanation(context),
                        onRefresh: context.read<NearbyShopsCubit>().loadShops,
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

  Future<void> _showLocationExplanation(BuildContext context) async {
    final shouldUseLocation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.location_on_outlined),
        title: const Text('Konumunu kullanalım mı?'),
        content: const Text(
          'Yakınındaki mağazaları bulmak için cihazının konumunu bir kez '
          'kullanırız. Konumunu hesabına kaydetmeyiz, mağazalarla paylaşmayız '
          've arka planda takip etmeyiz.',
        ),
        actions: [
          TextButton(
            key: const Key('nearby-location-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Şimdi Değil'),
          ),
          FilledButton(
            key: const Key('nearby-location-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Konumumu Kullan'),
          ),
        ],
      ),
    );

    if (shouldUseLocation != true || !context.mounted) return;
    await context.read<NearbyShopsCubit>().useCurrentLocation();
  }
}

class _LoadedNearbyShops extends StatelessWidget {
  final NearbyShopsLoaded state;
  final VoidCallback onLocationRequested;
  final Future<void> Function() onRefresh;

  const _LoadedNearbyShops({
    required this.state,
    required this.onLocationRequested,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        key: const Key('nearby-shop-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: TSizes.defaultSpace),
        itemCount: state.shops.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(height: TSizes.spaceBtwItems),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _NearbyLocationCard(
              status: state.locationStatus,
              hasDistances: state.distanceMetersByShopId.isNotEmpty,
              onLocationRequested: onLocationRequested,
            );
          }

          final shop = state.shops[index - 1];
          return _NearbyShopCard(
            shop: shop,
            distanceMeters: state.distanceForShop(shop.id),
            locationReady: state.locationStatus == NearbyLocationStatus.ready,
          );
        },
      ),
    );
  }
}

class _NearbyLocationCard extends StatelessWidget {
  final NearbyLocationStatus status;
  final bool hasDistances;
  final VoidCallback onLocationRequested;

  const _NearbyLocationCard({
    required this.status,
    required this.hasDistances,
    required this.onLocationRequested,
  });

  @override
  Widget build(BuildContext context) {
    final content = _contentForStatus();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: const Key('nearby-location-card'),
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(content.icon, color: colorScheme.primary),
            const SizedBox(width: TSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TSizes.xs),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      content.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (status == NearbyLocationStatus.requesting) ...[
                    const SizedBox(height: TSizes.sm),
                    const LinearProgressIndicator(
                      key: Key('nearby-location-progress'),
                    ),
                  ] else if (content.actionLabel != null) ...[
                    const SizedBox(height: TSizes.sm),
                    FilledButton.icon(
                      key: const Key('nearby-location-action'),
                      onPressed: onLocationRequested,
                      icon: const Icon(Icons.my_location_outlined, size: 18),
                      label: Text(content.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NearbyLocationCardContent _contentForStatus() {
    return switch (status) {
      NearbyLocationStatus.idle => const _NearbyLocationCardContent(
        icon: Icons.near_me_outlined,
        title: 'En yakın mağazaları öne çıkar',
        message:
            'Konumunu kullanarak mağazaları yakından uzağa sıralayabiliriz.',
        actionLabel: 'Konumumu Kullan',
      ),
      NearbyLocationStatus.requesting => const _NearbyLocationCardContent(
        icon: Icons.my_location_outlined,
        title: 'Konumun alınıyor',
        message: 'Mağaza listesini açık tutuyoruz. Bu işlem kısa sürebilir.',
      ),
      NearbyLocationStatus.ready => _NearbyLocationCardContent(
        icon: Icons.check_circle_outline,
        title: hasDistances ? 'Yakına göre sıralandı' : 'Konumun alındı',
        message: hasDistances
            ? 'Konumunu yalnızca bu sıralama için kullandık; kaydetmedik ve paylaşmadık.'
            : 'Mağazaların mesafe bilgisi henüz hazır değil. Konumunu kaydetmedik.',
      ),
      NearbyLocationStatus.permissionDenied => const _NearbyLocationCardContent(
        icon: Icons.location_off_outlined,
        title: 'Konum izni verilmedi',
        message:
            'Mağazaları ada göre göstermeye devam ediyoruz. İzin vermek '
            'istersen Chrome adres çubuğundaki site ayarlarından konumu açabilirsin.',
        actionLabel: 'Tekrar Kontrol Et',
      ),
      NearbyLocationStatus.servicesDisabled => const _NearbyLocationCardContent(
        icon: Icons.location_disabled_outlined,
        title: 'Cihaz konumu kapalı',
        message:
            'Mağazaları ada göre göstermeye devam ediyoruz. Cihaz konumunu '
            'açtıktan sonra yeniden deneyebilirsin.',
        actionLabel: 'Tekrar Dene',
      ),
      NearbyLocationStatus.timedOut => const _NearbyLocationCardContent(
        icon: Icons.timer_off_outlined,
        title: 'Konum alınamadı',
        message:
            'İşlem beklenenden uzun sürdü. Mağazaları göstermeye devam ediyoruz.',
        actionLabel: 'Tekrar Dene',
      ),
      NearbyLocationStatus.unavailable => const _NearbyLocationCardContent(
        icon: Icons.wrong_location_outlined,
        title: 'Konum şu anda kullanılamıyor',
        message:
            'Mağazaları ada göre göstermeye devam ediyoruz. Biraz sonra yeniden deneyebilirsin.',
        actionLabel: 'Tekrar Dene',
      ),
    };
  }
}

class _NearbyLocationCardContent {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;

  const _NearbyLocationCardContent({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
  });
}

class _NearbyShopCard extends StatelessWidget {
  final ShopEntity shop;
  final double? distanceMeters;
  final bool locationReady;

  const _NearbyShopCard({
    required this.shop,
    required this.distanceMeters,
    required this.locationReady,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAddress = _hasText(shop.address);
    final hasCoordinates = _hasValidCoordinates(shop);

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
            if (distanceMeters != null) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              _ShopInfoLine(
                icon: Icons.near_me_outlined,
                text: _formatDistance(distanceMeters!),
              ),
            ] else if (locationReady) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              const _ShopInfoLine(
                icon: Icons.location_searching_outlined,
                text: 'Mesafe bilgisi yok',
              ),
            ],
            if (hasAddress) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              _ShopInfoLine(
                icon: Icons.location_on_outlined,
                text: shop.address!.trim(),
              ),
            ] else if (hasCoordinates && !locationReady) ...[
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

  static bool _hasValidCoordinates(ShopEntity shop) {
    final latitude = shop.latitude;
    final longitude = shop.longitude;

    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static String _formatDistance(double distanceMeters) {
    if (distanceMeters < 10) {
      return "10 m'den az";
    }

    if (distanceMeters < 1000) {
      final roundedMeters = (distanceMeters / 10).round() * 10;
      return 'Yaklaşık $roundedMeters m';
    }

    final kilometers = (distanceMeters / 1000)
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    return 'Yaklaşık $kilometers km';
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
