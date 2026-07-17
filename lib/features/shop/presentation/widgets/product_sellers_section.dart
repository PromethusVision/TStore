import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

class ProductSellersSection extends StatefulWidget {
  final String productId;
  final Future<void> Function()? onChangeLocationRequested;

  const ProductSellersSection({
    super.key,
    required this.productId,
    this.onChangeLocationRequested,
  });

  @override
  State<ProductSellersSection> createState() => _ProductSellersSectionState();
}

class _ProductSellersSectionState extends State<ProductSellersSection> {
  late final Future<Either<String, List<ShopProductEntity>>> _future;
  late final CustomerLocationService _customerLocationService;
  CustomerPreferredLocation? _preferredLocation;
  _SellerSortOption? _selectedSortOption;
  static bool _isConflictDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _customerLocationService = sl<CustomerLocationService>();
    _future = sl<GetShopProductsByProductUsecase>()(
      GetShopProductsByProductParams(productId: widget.productId),
    );
    unawaited(_loadPreferredLocation());
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
              const SnackBar(content: Text('Ürün mağaza sepetine eklendi')),
            );
        } else if (state is CartV2Error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
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
                return const Text('Bu ürünü satan esnaf henüz listelenmiyor.');
              }

              final preferredLocation = _preferredLocation;
              final coordinates =
                  preferredLocation?.coordinates ??
                  _customerLocationService.cachedCoordinates;
              final locationReady = coordinates?.isValid ?? false;
              final effectiveSort =
                  _selectedSortOption ??
                  (locationReady ? _SellerSortOption.nearest : null);
              final rankedSellers = _sortSellers(
                shopProducts,
                coordinates,
                effectiveSort,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: TSizes.sm,
                    runSpacing: TSizes.sm,
                    children: [
                      Text(
                        'Bu ürünü satan esnaflar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      _SellerSortMenu(
                        selectedOption: effectiveSort,
                        locationReady: locationReady,
                        onSelected: (option) {
                          setState(() => _selectedSortOption = option);
                        },
                      ),
                    ],
                  ),
                  if (preferredLocation != null) ...[
                    const SizedBox(height: TSizes.sm),
                    _PreferredLocationNotice(
                      locationName: preferredLocation.name,
                      onChangeLocation: _openSavedLocations,
                    ),
                  ],
                  const SizedBox(height: TSizes.spaceBtwItems),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rankedSellers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: TSizes.spaceBtwItems),
                    itemBuilder: (context, index) {
                      final rankedSeller = rankedSellers[index];
                      return _SellerTile(
                        shopProduct: rankedSeller.shopProduct,
                        distanceMeters: rankedSeller.distanceMeters,
                        locationReady: locationReady,
                      );
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

  Future<void> _loadPreferredLocation() async {
    final location = await _customerLocationService.getPreferredLocation();
    if (!mounted) return;

    final nextLocation = location?.isValid == true ? location : null;
    final hasDeviceLocation =
        _customerLocationService.cachedCoordinates?.isValid ?? false;
    final shouldClearNearest =
        nextLocation == null &&
        !hasDeviceLocation &&
        _selectedSortOption == _SellerSortOption.nearest;
    if (_preferredLocation == nextLocation && !shouldClearNearest) return;

    setState(() {
      _preferredLocation = nextLocation;
      if (shouldClearNearest) {
        _selectedSortOption = null;
      }
    });
  }

  Future<void> _openSavedLocations() async {
    final onChangeLocationRequested = widget.onChangeLocationRequested;
    if (onChangeLocationRequested != null) {
      await onChangeLocationRequested();
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const CustomerSavedLocationsView(),
        ),
      );
    }

    if (!mounted) return;
    await _loadPreferredLocation();
  }

  List<_RankedSeller> _sortSellers(
    List<ShopProductEntity> shopProducts,
    CustomerCoordinates? coordinates,
    _SellerSortOption? sortOption,
  ) {
    final rankedSellers = <_RankedSeller>[];

    for (var index = 0; index < shopProducts.length; index++) {
      final shopProduct = shopProducts[index];
      final shop = shopProduct.shop;
      final distance = coordinates == null || !coordinates.isValid
          ? null
          : CustomerProximityHelper.distanceInMeters(
              from: coordinates,
              latitude: shop?.latitude,
              longitude: shop?.longitude,
            );

      rankedSellers.add(
        _RankedSeller(
          shopProduct: shopProduct,
          originalIndex: index,
          distanceMeters: distance,
        ),
      );
    }

    if (sortOption == null) {
      return rankedSellers;
    }

    rankedSellers.sort((first, second) {
      final comparison = switch (sortOption) {
        _SellerSortOption.cheapest => _compareFiniteValues(
          first.shopProduct.price,
          second.shopProduct.price,
          ascending: true,
        ),
        _SellerSortOption.mostExpensive => _compareFiniteValues(
          first.shopProduct.price,
          second.shopProduct.price,
          ascending: false,
        ),
        _SellerSortOption.highestRated => _compareFiniteValues(
          first.shopProduct.shop?.rating,
          second.shopProduct.shop?.rating,
          ascending: false,
        ),
        _SellerSortOption.nearest => _compareFiniteValues(
          first.distanceMeters,
          second.distanceMeters,
          ascending: true,
        ),
      };

      return comparison != 0
          ? comparison
          : first.originalIndex.compareTo(second.originalIndex);
    });

    return rankedSellers;
  }

  int _compareFiniteValues(
    double? first,
    double? second, {
    required bool ascending,
  }) {
    final firstIsValid = first != null && first.isFinite;
    final secondIsValid = second != null && second.isFinite;

    if (!firstIsValid && !secondIsValid) return 0;
    if (!firstIsValid) return 1;
    if (!secondIsValid) return -1;

    final comparison = first.compareTo(second);
    return ascending ? comparison : -comparison;
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
              child: const Text('Mevcut mağaza sepetini iptal et ve devam et'),
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
  final double? distanceMeters;
  final bool locationReady;

  const _SellerTile({
    required this.shopProduct,
    required this.distanceMeters,
    required this.locationReady,
  });

  @override
  Widget build(BuildContext context) {
    final shop = shopProduct.shop;
    final rating = shop?.rating ?? 0;
    final hasCoordinates = CustomerProximityHelper.hasValidCoordinates(
      shop?.latitude,
      shop?.longitude,
    );
    final hasAddress =
        shop?.address != null && shop!.address!.trim().isNotEmpty;
    final canAddToCart = shopProduct.isActive && shopProduct.isAvailable;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      key: ValueKey('product-seller-${shopProduct.id}'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    onTap: shop == null
                        ? null
                        : () => _openShopProfile(context),
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
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (shop != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mağaza profilini görüntüle',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: colorScheme.primary),
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
              Text(shop.address!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: TSizes.sm),
            Wrap(
              spacing: TSizes.sm,
              runSpacing: TSizes.xs,
              children: [
                _PriceChip(price: shopProduct.price),
                if (rating > 0) _RatingChip(rating: rating),
                if (locationReady || hasCoordinates || hasAddress)
                  _LocationHintChip(
                    hasCoordinates: hasCoordinates,
                    distanceMeters: distanceMeters,
                    locationReady: locationReady,
                  ),
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

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ShopProfileView(shop: shop)));
  }

  void _handleAddToCart(BuildContext context) {
    final user = SupabaseService.instance.currentUser;

    if (user == null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginView()));
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
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.green.shade700),
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
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
          Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
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

class _LocationHintChip extends StatelessWidget {
  final bool hasCoordinates;
  final double? distanceMeters;
  final bool locationReady;

  const _LocationHintChip({
    required this.hasCoordinates,
    required this.distanceMeters,
    required this.locationReady,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = distanceMeters != null
        ? CustomerProximityHelper.formatDistance(distanceMeters!)
        : locationReady
        ? 'Mesafe bilgisi yok'
        : hasCoordinates
        ? 'Konum bilgisi mevcut'
        : 'Adres bilgisi mevcut';

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
            Icons.location_on_outlined,
            size: 15,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferredLocationNotice extends StatelessWidget {
  final String locationName;
  final VoidCallback onChangeLocation;

  const _PreferredLocationNotice({
    required this.locationName,
    required this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedName = locationName.trim();

    return Semantics(
      label: '$normalizedName ana konumuna göre mesafeler gösteriliyor',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.sm,
          vertical: TSizes.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark_added_outlined,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Text(
                    '$normalizedName konumuna göre mesafeler gösteriliyor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const Key('product-seller-change-location'),
                onPressed: onChangeLocation,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: const Text('Konumu Değiştir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SellerSortOption { cheapest, mostExpensive, highestRated, nearest }

extension on _SellerSortOption {
  String get label => switch (this) {
    _SellerSortOption.cheapest => 'Fiyata göre en ucuz',
    _SellerSortOption.mostExpensive => 'Fiyata göre en pahalı',
    _SellerSortOption.highestRated => 'En yüksek puan',
    _SellerSortOption.nearest => 'En yakın',
  };

  String get buttonLabel => switch (this) {
    _SellerSortOption.cheapest => 'En ucuz',
    _SellerSortOption.mostExpensive => 'En pahalı',
    _SellerSortOption.highestRated => 'Puan',
    _SellerSortOption.nearest => 'En yakın',
  };

  IconData get icon => switch (this) {
    _SellerSortOption.cheapest => Icons.arrow_downward_outlined,
    _SellerSortOption.mostExpensive => Icons.arrow_upward_outlined,
    _SellerSortOption.highestRated => Icons.star_outline_rounded,
    _SellerSortOption.nearest => Icons.near_me_outlined,
  };

  Key get menuKey => switch (this) {
    _SellerSortOption.cheapest => const Key('product-seller-sort-cheapest'),
    _SellerSortOption.mostExpensive => const Key(
      'product-seller-sort-most-expensive',
    ),
    _SellerSortOption.highestRated => const Key(
      'product-seller-sort-highest-rated',
    ),
    _SellerSortOption.nearest => const Key('product-seller-sort-nearest'),
  };
}

class _SellerSortMenu extends StatelessWidget {
  final _SellerSortOption? selectedOption;
  final bool locationReady;
  final ValueChanged<_SellerSortOption> onSelected;

  const _SellerSortMenu({
    required this.selectedOption,
    required this.locationReady,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tooltip = selectedOption == null
        ? 'Satıcıları sırala'
        : 'Satıcıları sırala: ${selectedOption!.label}';

    return MenuAnchor(
      menuChildren: _SellerSortOption.values
          .map((option) {
            final locationUnavailable =
                option == _SellerSortOption.nearest && !locationReady;

            return MenuItemButton(
              key: option.menuKey,
              onPressed: locationUnavailable ? null : () => onSelected(option),
              leadingIcon: Icon(option.icon),
              trailingIcon: selectedOption == option
                  ? const Icon(Icons.check_rounded)
                  : null,
              child: locationUnavailable
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.label),
                        Text(
                          'Konum gerekli',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    )
                  : Text(option.label),
            );
          })
          .toList(growable: false),
      builder: (context, controller, child) {
        return Tooltip(
          message: tooltip,
          child: OutlinedButton.icon(
            key: const Key('product-seller-sort-button'),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.swap_vert_rounded),
            label: Text(selectedOption?.buttonLabel ?? 'Sırala'),
          ),
        );
      },
    );
  }
}

class _RankedSeller {
  final ShopProductEntity shopProduct;
  final int originalIndex;
  final double? distanceMeters;

  const _RankedSeller({
    required this.shopProduct,
    required this.originalIndex,
    required this.distanceMeters,
  });
}
