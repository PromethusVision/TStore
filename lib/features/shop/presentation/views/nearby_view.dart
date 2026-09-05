import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/core/common/view_models/cart_counter_icon_view_model.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

part 'nearby_visual_prototype.dart';

typedef NearbyCurrentUserIdProvider = String? Function();
typedef NearbyCartDestinationBuilder = Widget Function(BuildContext context);
typedef NearbyShopDestinationBuilder = Widget Function(ShopEntity shop);

String? _nearbyCurrentUserId() {
  try {
    return SupabaseService.instance.currentUser?.id;
  } catch (_) {
    return null;
  }
}

Widget _defaultNearbyCartDestinationBuilder(BuildContext context) {
  return const CartV2View();
}

class NearbyView extends StatelessWidget {
  /// Owner gate only. Existing tab/navigation callers keep the current layout.
  final bool visualPrototype;
  final Future<void> Function()? onChangeLocationRequested;
  final NearbyCurrentUserIdProvider currentUserIdProvider;
  final NearbyCartDestinationBuilder cartDestinationBuilder;
  final NearbyShopDestinationBuilder? shopDestinationBuilder;

  const NearbyView({
    super.key,
    this.visualPrototype = false,
    this.onChangeLocationRequested,
    this.currentUserIdProvider = _nearbyCurrentUserId,
    this.cartDestinationBuilder = _defaultNearbyCartDestinationBuilder,
    this.shopDestinationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NearbyShopsCubit>()..loadShops(),
      child: _NearbyContent(
        visualPrototype: visualPrototype,
        onChangeLocationRequested: onChangeLocationRequested,
        currentUserIdProvider: currentUserIdProvider,
        cartDestinationBuilder: cartDestinationBuilder,
        shopDestinationBuilder: shopDestinationBuilder,
      ),
    );
  }
}

class _NearbyContent extends StatefulWidget {
  final bool visualPrototype;
  final Future<void> Function()? onChangeLocationRequested;
  final NearbyCurrentUserIdProvider currentUserIdProvider;
  final NearbyCartDestinationBuilder cartDestinationBuilder;
  final NearbyShopDestinationBuilder? shopDestinationBuilder;

  const _NearbyContent({
    required this.visualPrototype,
    this.onChangeLocationRequested,
    required this.currentUserIdProvider,
    required this.cartDestinationBuilder,
    this.shopDestinationBuilder,
  });

  @override
  State<_NearbyContent> createState() => _NearbyContentState();
}

class _NearbyContentState extends State<_NearbyContent>
    with WidgetsBindingObserver {
  bool _isOpeningCart = false;
  bool _isOpeningSavedLocations = false;
  bool _isRequestingCurrentLocation = false;
  bool _isOpeningLocationSettings = false;
  bool _refreshLocationOnResume = false;
  final Set<String> _openingShopIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final currentState = context.read<NearbyShopsCubit>().state;
      if (currentState is NearbyShopsLoaded &&
          _requiresSettingsRefresh(currentState.locationStatus)) {
        _refreshLocationOnResume = true;
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _refreshLocationOnResume) {
      _refreshLocationOnResume = false;
      unawaited(_refreshLocationAfterSettings());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('nearby-customer-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.visualPrototype)
                    _NearbyPrototypeHeader(
                      onCartPressed: () => unawaited(_openCart(context)),
                    )
                  else
                    _NearbyHeader(
                      onCartPressed: () => unawaited(_openCart(context)),
                    ),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  Expanded(
                    child: BlocBuilder<NearbyShopsCubit, NearbyShopsState>(
                      builder: (context, state) {
                        if (state is NearbyShopsInitial ||
                            state is NearbyShopsLoading) {
                          return const _NearbyLoading();
                        }

                        if (state is NearbyShopsError) {
                          return _NearbyMessage(
                            icon: Icons.cloud_off_outlined,
                            title: 'Mağazalar yüklenemedi.',
                            message:
                                'Lütfen bağlantını kontrol edip tekrar dene.',
                            actionLabel: 'Tekrar Dene',
                            onAction: context
                                .read<NearbyShopsCubit>()
                                .loadShops,
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
                            visualPrototype: widget.visualPrototype,
                            state: state,
                            onLocationRequested: () =>
                                _showLocationExplanation(context),
                            onLocationSettingsRequested: (status) =>
                                _openLocationSettings(context, status),
                            onSavedLocationRequested: () =>
                                _openSavedLocations(context),
                            onRefresh: context
                                .read<NearbyShopsCubit>()
                                .loadShops,
                            onShopSelected: (shop) =>
                                unawaited(_openShopProfile(context, shop)),
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
        ),
      ),
    );
  }

  Future<void> _openCart(BuildContext context) async {
    if (_isOpeningCart) return;
    _isOpeningCart = true;

    try {
      if (widget.currentUserIdProvider() == null) {
        final signedIn = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) =>
                const LoginView(returnToCallerAfterCustomerLogin: true),
          ),
        );
        if (!context.mounted ||
            signedIn != true ||
            widget.currentUserIdProvider() == null) {
          return;
        }
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: widget.cartDestinationBuilder),
      );
    } finally {
      _isOpeningCart = false;
    }
  }

  Future<void> _openShopProfile(BuildContext context, ShopEntity shop) async {
    final shopId = shop.id.trim();
    if (!shop.isActive || shopId.isEmpty || _openingShopIds.contains(shopId)) {
      return;
    }

    _openingShopIds.add(shopId);
    try {
      final destination =
          widget.shopDestinationBuilder?.call(shop) ??
          ShopProfileView(shop: shop);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingShopIds.remove(shopId);
    }
  }

  Future<void> _showLocationExplanation(BuildContext context) async {
    if (_isRequestingCurrentLocation) return;
    _isRequestingCurrentLocation = true;
    final nearbyShopsCubit = context.read<NearbyShopsCubit>();

    try {
      final shouldUseLocation = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: CustomerHomeV1Tokens.surface,
          insetPadding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: CustomerHomeV1Tokens.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: CustomerHomeV1Tokens.petrol,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  const Text(
                    'Konumunu kullan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  const Text(
                    'Sana en yakın mağazaları gösterebilmemiz için konum izni ver.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomerHomeV1Tokens.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: CustomerHomeV1Tokens.space8,
                    runSpacing: CustomerHomeV1Tokens.space8,
                    children: [
                      TextButton(
                        key: const Key('nearby-location-cancel'),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: CustomerHomeV1Tokens.muted,
                        ),
                        child: const Text('Şimdi Değil'),
                      ),
                      FilledButton(
                        key: const Key('nearby-location-confirm'),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: CustomerHomeV1Tokens.petrol,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radius12,
                            ),
                          ),
                        ),
                        child: const Text('İzin Ver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (shouldUseLocation != true || !context.mounted) return;
      await nearbyShopsCubit.useCurrentLocation();
    } finally {
      _isRequestingCurrentLocation = false;
    }
  }

  Future<void> _openSavedLocations(BuildContext context) async {
    if (_isOpeningSavedLocations) return;
    _isOpeningSavedLocations = true;
    final nearbyShopsCubit = context.read<NearbyShopsCubit>();

    try {
      final callback = widget.onChangeLocationRequested;
      if (callback != null) {
        await callback();
      } else {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const CustomerSavedLocationsView(),
          ),
        );
      }

      if (!context.mounted) return;
      await nearbyShopsCubit.loadShops();
    } finally {
      _isOpeningSavedLocations = false;
    }
  }

  Future<void> _openLocationSettings(
    BuildContext context,
    NearbyLocationStatus status,
  ) async {
    if (_isOpeningLocationSettings) return;
    _isOpeningLocationSettings = true;
    _refreshLocationOnResume = true;
    final cubit = context.read<NearbyShopsCubit>();

    try {
      final opened = status == NearbyLocationStatus.permissionDeniedForever
          ? await cubit.openAppSettings()
          : await cubit.openLocationSettings();
      if (!context.mounted) return;
      if (!opened) {
        _refreshLocationOnResume = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ayarlar açılamadı. Lütfen cihaz ayarlarından konumu kontrol edin.',
            ),
          ),
        );
      }
    } finally {
      _isOpeningLocationSettings = false;
    }
  }

  Future<void> _refreshLocationAfterSettings() async {
    if (!mounted || _isRequestingCurrentLocation) return;
    _isRequestingCurrentLocation = true;
    try {
      await context.read<NearbyShopsCubit>().useCurrentLocation();
    } finally {
      _isRequestingCurrentLocation = false;
    }
  }

  bool _requiresSettingsRefresh(NearbyLocationStatus status) {
    return status == NearbyLocationStatus.permissionDenied ||
        status == NearbyLocationStatus.permissionDeniedForever ||
        status == NearbyLocationStatus.servicesDisabled;
  }
}

class _NearbyHeader extends StatelessWidget {
  const _NearbyHeader({required this.onCartPressed});

  final VoidCallback onCartPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('nearby-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yakındakiler',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                'Çevrendeki mağazaları ve ürünleri keşfet.',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            shape: BoxShape.circle,
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: CartCounterIcon(
            cartCounterIconModel: CartCounterIconModel(
              color: CustomerHomeV1Tokens.petrol,
              onPressed: onCartPressed,
            ),
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
    return Center(
      child: Container(
        key: const Key('nearby-loading'),
        width: double.infinity,
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: CustomerHomeV1Tokens.petrol),
            SizedBox(height: CustomerHomeV1Tokens.space16),
            Text(
              'Yakınındaki mağazalar hazırlanıyor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedNearbyShops extends StatelessWidget {
  final bool visualPrototype;
  final NearbyShopsLoaded state;
  final VoidCallback onLocationRequested;
  final ValueChanged<NearbyLocationStatus> onLocationSettingsRequested;
  final VoidCallback onSavedLocationRequested;
  final Future<void> Function() onRefresh;
  final ValueChanged<ShopEntity> onShopSelected;

  const _LoadedNearbyShops({
    this.visualPrototype = false,
    required this.state,
    required this.onLocationRequested,
    required this.onLocationSettingsRequested,
    required this.onSavedLocationRequested,
    required this.onRefresh,
    required this.onShopSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (visualPrototype) return _buildNearbyPrototype(this, context);
    return RefreshIndicator(
      color: CustomerHomeV1Tokens.petrol,
      onRefresh: onRefresh,
      child: ListView.separated(
        key: const Key('nearby-shop-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: CustomerHomeV1Tokens.space24),
        itemCount: state.shops.length + 2,
        separatorBuilder: (context, index) =>
            const SizedBox(height: CustomerHomeV1Tokens.space12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _NearbyLocationCard(
              status: state.locationStatus,
              hasDistances: state.distanceMetersByShopId.isNotEmpty,
              locationSource: state.locationSource,
              locationLabel: state.locationLabel,
              onLocationRequested: onLocationRequested,
              onLocationSettingsRequested: onLocationSettingsRequested,
              onSavedLocationRequested: onSavedLocationRequested,
            );
          }

          if (index == 1) {
            return _NearbyListHeader(shopCount: state.shops.length);
          }

          final shop = state.shops[index - 2];
          return _NearbyShopCard(
            shop: shop,
            distanceMeters: state.distanceForShop(shop.id),
            locationReady: state.locationStatus == NearbyLocationStatus.ready,
            onOpenShop: !shop.isActive || shop.id.trim().isEmpty
                ? null
                : () => onShopSelected(shop),
          );
        },
      ),
    );
  }
}

class _NearbyListHeader extends StatelessWidget {
  const _NearbyListHeader({required this.shopCount});

  final int shopCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: CustomerHomeV1Tokens.space4,
        left: CustomerHomeV1Tokens.space4,
        right: CustomerHomeV1Tokens.space4,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Yakındaki mağazalar',
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CustomerHomeV1Tokens.space8,
              vertical: CustomerHomeV1Tokens.space4,
            ),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radiusPill,
              ),
            ),
            child: Text(
              '$shopCount mağaza',
              style: const TextStyle(
                color: CustomerHomeV1Tokens.petrol,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyLocationCard extends StatelessWidget {
  final NearbyLocationStatus status;
  final bool hasDistances;
  final NearbyLocationSource? locationSource;
  final String? locationLabel;
  final VoidCallback onLocationRequested;
  final ValueChanged<NearbyLocationStatus> onLocationSettingsRequested;
  final VoidCallback onSavedLocationRequested;

  const _NearbyLocationCard({
    required this.status,
    required this.hasDistances,
    required this.locationSource,
    required this.locationLabel,
    required this.onLocationRequested,
    required this.onLocationSettingsRequested,
    required this.onSavedLocationRequested,
  });

  @override
  Widget build(BuildContext context) {
    final content = _contentForStatus();
    final canChangeSavedLocation =
        status == NearbyLocationStatus.ready &&
        locationSource == NearbyLocationSource.savedLocation &&
        locationLabel?.trim().isNotEmpty == true;

    return Container(
      key: const Key('nearby-location-card'),
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(
          color: CustomerHomeV1Tokens.petrol.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.petrol,
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    content.message,
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
                if (status == NearbyLocationStatus.requesting) ...[
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  const LinearProgressIndicator(
                    key: Key('nearby-location-progress'),
                    color: CustomerHomeV1Tokens.petrol,
                    backgroundColor: Colors.white,
                  ),
                ] else if (content.actionLabel != null) ...[
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  FilledButton.icon(
                    key: const Key('nearby-location-action'),
                    onPressed: _opensSettings
                        ? () => onLocationSettingsRequested(status)
                        : onLocationRequested,
                    style: FilledButton.styleFrom(
                      backgroundColor: CustomerHomeV1Tokens.petrol,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CustomerHomeV1Tokens.space12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius12,
                        ),
                      ),
                    ),
                    icon: Icon(
                      _opensSettings
                          ? Icons.settings_outlined
                          : Icons.my_location_rounded,
                      size: 17,
                    ),
                    label: Text(content.actionLabel!),
                  ),
                ] else if (canChangeSavedLocation) ...[
                  const SizedBox(height: CustomerHomeV1Tokens.space4),
                  TextButton.icon(
                    key: const Key('nearby-change-location'),
                    onPressed: onSavedLocationRequested,
                    style: TextButton.styleFrom(
                      foregroundColor: CustomerHomeV1Tokens.petrol,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                    label: const Text(
                      'Konumu Değiştir',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NearbyLocationCardContent _contentForStatus() {
    if (status == NearbyLocationStatus.ready &&
        locationSource == NearbyLocationSource.savedLocation &&
        locationLabel?.trim().isNotEmpty == true) {
      return _NearbyLocationCardContent(
        icon: Icons.bookmark_added_outlined,
        title: '${locationLabel!.trim()} konumuna göre sıralandı',
        message: hasDistances
            ? 'Ana konumunu mağazaları yakından uzağa sıralamak için kullandık; mağazalarla paylaşmadık.'
            : 'Ana konumun seçildi ancak mağazaların mesafe bilgisi henüz hazır değil.',
      );
    }

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
            'Mağazaları göstermeye devam ediyoruz. Tekrar deneyerek Android '
            'konum izni ekranını açabilirsin.',
        actionLabel: 'Tekrar Kontrol Et',
      ),
      NearbyLocationStatus.permissionDeniedForever =>
        const _NearbyLocationCardContent(
          icon: Icons.app_settings_alt_outlined,
          title: 'Konum izni uygulama ayarlarında kapalı',
          message:
              'Konumu kullanmak için uygulama ayarlarından izni açıp geri dönebilirsin.',
          actionLabel: 'Uygulama Ayarlarını Aç',
        ),
      NearbyLocationStatus.servicesDisabled => const _NearbyLocationCardContent(
        icon: Icons.location_disabled_outlined,
        title: 'Cihaz konumu kapalı',
        message:
            'Mağazaları ada göre göstermeye devam ediyoruz. Cihaz konumunu '
            'açtıktan sonra yeniden deneyebilirsin.',
        actionLabel: 'Konum Ayarlarını Aç',
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

  bool get _opensSettings =>
      status == NearbyLocationStatus.permissionDeniedForever ||
      status == NearbyLocationStatus.servicesDisabled;
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
  final VoidCallback? onOpenShop;

  const _NearbyShopCard({
    required this.shop,
    required this.distanceMeters,
    required this.locationReady,
    required this.onOpenShop,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = _hasText(shop.address);
    final hasCoordinates = CustomerProximityHelper.hasValidCoordinates(
      shop.latitude,
      shop.longitude,
    );

    return Container(
      key: ValueKey('nearby-shop-${shop.id}'),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NearbyShopVisual(shopId: shop.id),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (shop.rating > 0) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      _ShopBadge(
                        icon: Icons.star_rounded,
                        label: 'Puan ${shop.rating.toStringAsFixed(1)}',
                        color: CustomerHomeV1Tokens.yellow,
                      ),
                    ],
                    if (distanceMeters != null) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      _ShopBadge(
                        icon: Icons.near_me_rounded,
                        label: CustomerProximityHelper.formatDistance(
                          distanceMeters!,
                        ),
                        color: CustomerHomeV1Tokens.mint,
                      ),
                    ] else if (locationReady) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      const _ShopBadge(
                        icon: Icons.location_searching_rounded,
                        label: 'Mesafe bilgisi yok',
                        color: CustomerHomeV1Tokens.mint,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_hasText(shop.description)) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            Text(
              shop.description!.trim(),
              style: const TextStyle(
                color: CustomerHomeV1Tokens.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (hasAddress) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            _ShopInfoLine(
              icon: Icons.location_on_outlined,
              text: shop.address!.trim(),
            ),
          ] else if (hasCoordinates && !locationReady) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            const _ShopInfoLine(
              icon: Icons.location_on_outlined,
              text: 'Konum bilgisi mevcut',
            ),
          ],
          if (_hasText(shop.phone)) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            _ShopInfoLine(icon: Icons.call_outlined, text: shop.phone!.trim()),
          ],
          if (shop.openingHours.isNotEmpty) ...[
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            _ShopInfoLine(
              icon: Icons.schedule_outlined,
              text: _formatOpeningHours(shop.openingHours),
            ),
          ],
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: Key('nearby-shop-open-${shop.id}'),
              onPressed: onOpenShop,
              style: OutlinedButton.styleFrom(
                foregroundColor: CustomerHomeV1Tokens.petrol,
                side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius12,
                  ),
                ),
              ),
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: const Text(
                'Mağazayı Gör',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
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

class _NearbyShopVisual extends StatelessWidget {
  const _NearbyShopVisual({required this.shopId});

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

    return Container(
      width: 92,
      height: 92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, background.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -9,
            bottom: -10,
            child: Icon(
              Icons.storefront_rounded,
              size: 68,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          const Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 8,
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

class _ShopBadge extends StatelessWidget {
  const _ShopBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space8,
        vertical: CustomerHomeV1Tokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: CustomerHomeV1Tokens.petrol),
          const SizedBox(width: CustomerHomeV1Tokens.space4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
        Icon(icon, size: 17, color: CustomerHomeV1Tokens.coral),
        const SizedBox(width: CustomerHomeV1Tokens.space8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 11,
              height: 1.4,
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
        padding: const EdgeInsets.symmetric(
          vertical: CustomerHomeV1Tokens.space16,
        ),
        child: Container(
          key: const Key('nearby-status-card'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: CustomerHomeV1Tokens.space16),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: CustomerHomeV1Tokens.petrol,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
