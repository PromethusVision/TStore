import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/chat/domain/services/pending_product_chat_storage.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_proximity_helper.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:t_store/features/shop/presentation/widgets/product_seller_price_summary.dart';
import 'package:t_store/features/shop/presentation/widgets/seller_comparison_offer_card.dart';

typedef ProductSellerCurrentUserIdProvider = String? Function();
typedef ProductSellerPriceSummaryChanged =
    void Function(ProductSellerPriceSummary summary);
typedef ProductSellerChatDestinationBuilder =
    Widget Function(
      String receiverId,
      String receiverName,
      String initialDraft,
    );
typedef ProductSellerShopDestinationBuilder = Widget Function(ShopEntity shop);

class ProductSellersSection extends StatefulWidget {
  final String productId;
  final String productName;
  final Future<void> Function()? onChangeLocationRequested;
  final VoidCallback? onBrowseOtherProducts;
  final ProductSellerPriceSummaryChanged? onPriceSummaryChanged;
  final ProductSellerCurrentUserIdProvider? currentUserIdProvider;
  final ProductSellerChatDestinationBuilder? chatDestinationBuilder;
  final ProductSellerShopDestinationBuilder? shopDestinationBuilder;
  final PendingProductChatStorage? pendingProductChatStorage;
  final bool visualPrototype;

  const ProductSellersSection({
    super.key,
    required this.productId,
    required this.productName,
    this.onChangeLocationRequested,
    this.onBrowseOtherProducts,
    this.onPriceSummaryChanged,
    this.currentUserIdProvider,
    this.chatDestinationBuilder,
    this.shopDestinationBuilder,
    this.pendingProductChatStorage,
    this.visualPrototype = false,
  });

  @override
  State<ProductSellersSection> createState() => _ProductSellersSectionState();
}

class _ProductSellersSectionState extends State<ProductSellersSection> {
  late Future<Either<String, List<ShopProductEntity>>> _future;
  late final CustomerLocationService _customerLocationService;
  CustomerPreferredLocation? _preferredLocation;
  _SellerSortOption? _selectedSortOption;
  final Set<String> _openingShopIds = <String>{};
  bool _isRetryInProgress = false;
  static bool _isConflictDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _customerLocationService = sl<CustomerLocationService>();
    _future = _fetchSellers();
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
            return _SellersErrorState(
              onRetry: _retrySellers,
              isRetrying: _isRetryInProgress,
            );
          }

          return snapshot.data!.fold(
            (_) => _SellersErrorState(
              onRetry: _retrySellers,
              isRetrying: _isRetryInProgress,
            ),
            (shopProducts) {
              final customerVisibleShopProducts = _customerVisibleSellers(
                shopProducts,
              );

              if (customerVisibleShopProducts.isEmpty) {
                return _SellersEmptyState(
                  onBrowseOtherProducts: widget.onBrowseOtherProducts,
                );
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
                customerVisibleShopProducts,
                coordinates,
                effectiveSort,
              );
              final lowestPrice = customerVisibleShopProducts
                  .map((seller) => seller.price)
                  .where((price) => price.isFinite && price >= 0)
                  .fold<double?>(
                    null,
                    (lowest, price) =>
                        lowest == null || price < lowest ? price : lowest,
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
                        widget.visualPrototype
                            ? 'Esnaf teklifleri'
                            : 'Bu ürünü satan esnaflar',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: widget.visualPrototype
                                  ? EsnaftaVarColors.textPrimary
                                  : null,
                              fontWeight: widget.visualPrototype
                                  ? FontWeight.w700
                                  : null,
                            ),
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
                  const SizedBox(height: TSizes.xs),
                  Text(
                    widget.visualPrototype
                        ? 'Fiyatı, puanı ve sana olan uzaklığı karşılaştır.'
                        : 'Mağazaları karşılaştırıp sepetine eklemek istediğin satıcıyı seçebilirsin.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.visualPrototype
                          ? EsnaftaVarColors.textSecondary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (preferredLocation != null) ...[
                    const SizedBox(height: TSizes.sm),
                    _PreferredLocationNotice(
                      locationName: preferredLocation.name,
                      onChangeLocation: _openSavedLocations,
                    ),
                  ],
                  SizedBox(
                    height: widget.visualPrototype
                        ? EsnaftaVarSpacing.sm
                        : TSizes.spaceBtwItems,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rankedSellers.length,
                    separatorBuilder: (_, _) => SizedBox(
                      height: widget.visualPrototype
                          ? EsnaftaVarSpacing.sm
                          : TSizes.spaceBtwItems,
                    ),
                    itemBuilder: (context, index) {
                      final rankedSeller = rankedSellers[index];
                      final shop = rankedSeller.shopProduct.shop;
                      return _SellerTile(
                        shopProduct: rankedSeller.shopProduct,
                        productName: widget.productName,
                        distanceMeters: rankedSeller.distanceMeters,
                        locationReady: locationReady,
                        currentUserIdProvider: widget.currentUserIdProvider,
                        chatDestinationBuilder: widget.chatDestinationBuilder,
                        pendingProductChatStorage:
                            widget.pendingProductChatStorage,
                        visualPrototype: widget.visualPrototype,
                        isLowestPrice:
                            lowestPrice != null &&
                            (rankedSeller.shopProduct.price - lowestPrice)
                                    .abs() <
                                0.005,
                        onShopProfileTap: shop?.isActive == true
                            ? () => unawaited(_openShopProfile(context, shop!))
                            : null,
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

  Future<Either<String, List<ShopProductEntity>>> _fetchSellers() {
    final request = sl<GetShopProductsByProductUsecase>()(
      GetShopProductsByProductParams(productId: widget.productId),
    );

    unawaited(
      request.then<void>(
        _notifyPriceSummary,
        onError: (_, _) => _notifyPriceSummaryError(),
      ),
    );
    return request;
  }

  Future<void> _openShopProfile(BuildContext context, ShopEntity shop) async {
    final shopId = shop.id.trim();
    if (shopId.isEmpty || _openingShopIds.contains(shopId)) return;

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

  void _notifyPriceSummary(Either<String, List<ShopProductEntity>> result) {
    if (!mounted) return;
    final summary = result.fold(
      (_) => const ProductSellerPriceSummary.error(),
      _priceSummaryFor,
    );
    widget.onPriceSummaryChanged?.call(summary);
  }

  void _notifyPriceSummaryError() {
    if (!mounted) return;
    widget.onPriceSummaryChanged?.call(const ProductSellerPriceSummary.error());
  }

  ProductSellerPriceSummary _priceSummaryFor(
    List<ShopProductEntity> shopProducts,
  ) {
    final prices =
        _customerVisibleSellers(shopProducts)
            .map((shopProduct) => shopProduct.price)
            .where((price) => price.isFinite && price >= 0)
            .toList(growable: false)
          ..sort();
    if (prices.isEmpty) return const ProductSellerPriceSummary.empty();

    return ProductSellerPriceSummary.available(
      minimumPrice: prices.first,
      maximumPrice: prices.last,
      sellerCount: prices.length,
    );
  }

  List<ShopProductEntity> _customerVisibleSellers(
    List<ShopProductEntity> shopProducts,
  ) {
    return shopProducts
        .where((shopProduct) => shopProduct.isCustomerPurchasable)
        .toList(growable: false);
  }

  void _retrySellers() {
    if (_isRetryInProgress) return;

    widget.onPriceSummaryChanged?.call(
      const ProductSellerPriceSummary.loading(),
    );
    final nextFuture = _fetchSellers();
    setState(() {
      _isRetryInProgress = true;
      _future = nextFuture;
    });

    unawaited(
      nextFuture.then<void>(
        (_) => _finishRetry(),
        onError: (_, _) => _finishRetry(),
      ),
    );
  }

  void _finishRetry() {
    if (!mounted) return;
    setState(() => _isRetryInProgress = false);
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

class _SellersEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseOtherProducts;

  const _SellersEmptyState({required this.onBrowseOtherProducts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('product-sellers-empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined, size: 32, color: colorScheme.primary),
          const SizedBox(height: TSizes.sm),
          Text(
            'Bu ürün şu anda aktif mağazalarda bulunamadı',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Yeni satıcılar eklendiğinde burada görünecek. Bu sırada diğer ürünlere göz atabilirsin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (onBrowseOtherProducts != null) ...[
            const SizedBox(height: TSizes.md),
            FilledButton.tonalIcon(
              key: const Key('product-sellers-browse-products'),
              onPressed: onBrowseOtherProducts,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Ürünlere dön'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SellersErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isRetrying;

  const _SellersErrorState({required this.onRetry, required this.isRetrying});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, color: colorScheme.error),
          const SizedBox(height: TSizes.sm),
          const Text(
            'Satıcı bilgileri yüklenemedi. Lütfen tekrar deneyin.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.sm),
          OutlinedButton.icon(
            key: const Key('product-sellers-retry'),
            onPressed: isRetrying ? null : onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

class _SellerTile extends StatelessWidget {
  final ShopProductEntity shopProduct;
  final String productName;
  final double? distanceMeters;
  final bool locationReady;
  final ProductSellerCurrentUserIdProvider? currentUserIdProvider;
  final ProductSellerChatDestinationBuilder? chatDestinationBuilder;
  final PendingProductChatStorage? pendingProductChatStorage;
  final VoidCallback? onShopProfileTap;
  final bool visualPrototype;
  final bool isLowestPrice;

  const _SellerTile({
    required this.shopProduct,
    required this.productName,
    required this.distanceMeters,
    required this.locationReady,
    required this.currentUserIdProvider,
    required this.chatDestinationBuilder,
    required this.pendingProductChatStorage,
    required this.onShopProfileTap,
    required this.visualPrototype,
    required this.isLowestPrice,
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
    final canAddToCart = shopProduct.isCustomerPurchasable;
    final ownerUserId = shop?.ownerUserId?.trim();
    final currentUserId = _currentUserId;
    final canMessage =
        ownerUserId != null &&
        ownerUserId.isNotEmpty &&
        currentUserId != ownerUserId;
    final colorScheme = Theme.of(context).colorScheme;

    if (visualPrototype) {
      final locationText = _locationText(
        hasCoordinates: hasCoordinates,
        hasAddress: hasAddress,
      );
      return SellerComparisonOfferCard(
        key: ValueKey('product-seller-${shopProduct.id}'),
        listingId: shopProduct.id,
        shopName: shop?.name ?? 'Bilinmeyen esnaf',
        address: hasAddress ? shop.address!.trim() : null,
        price: shopProduct.price,
        rating: rating,
        locationText: locationText.isEmpty ? null : locationText,
        isAvailable: shopProduct.isAvailable,
        isLowestPrice: isLowestPrice,
        canAddToCart: canAddToCart,
        onViewShop: onShopProfileTap,
        onMessage: canMessage ? () => _openChat(context, ownerUserId) : null,
        onAddToCart: () => _startAddToCart(context),
      );
    }

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
                    key: ValueKey(
                      'product-seller-shop-profile-${shopProduct.id}',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    onTap: onShopProfileTap,
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
            Wrap(
              alignment: WrapAlignment.end,
              spacing: TSizes.sm,
              runSpacing: TSizes.xs,
              children: [
                if (canMessage)
                  _SellerChatButton(
                    shopProductId: shopProduct.id,
                    onPressed: () => _openChat(context, ownerUserId),
                  ),
                if (canAddToCart)
                  _SellerAddToCartButton(
                    shopProductId: shopProduct.id,
                    onPressed: () => _startAddToCart(context),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
                    child: Text(
                      'Şu an rafta yok',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _locationText({
    required bool hasCoordinates,
    required bool hasAddress,
  }) {
    final distance = distanceMeters;
    if (distance != null) {
      return CustomerProximityHelper.formatDistance(distance);
    }
    if (locationReady) return 'Mesafe bilgisi yok';
    if (hasCoordinates) return 'Konum bilgisi mevcut';
    if (hasAddress) return 'Adres bilgisi mevcut';
    return '';
  }

  String? get _currentUserId {
    final provider = currentUserIdProvider;
    final userId = provider != null
        ? provider()
        : SupabaseService.instance.currentUser?.id;
    final normalizedUserId = userId?.trim();
    return normalizedUserId == null || normalizedUserId.isEmpty
        ? null
        : normalizedUserId;
  }

  PendingProductChatStorage get _pendingProductChatStorage =>
      pendingProductChatStorage ?? sl<PendingProductChatStorage>();

  Future<void> _openChat(BuildContext context, String ownerUserId) async {
    final shop = shopProduct.shop;
    if (shop == null) return;

    final normalizedProductName = productName.trim();
    final productReference = normalizedProductName.isEmpty
        ? 'bu ürün'
        : '"$normalizedProductName"';
    final initialDraft = 'Merhaba, $productReference mağazanızda mevcut mu?';
    final pendingIntent = PendingProductChatIntent(
      receiverId: ownerUserId,
      receiverName: shop.name,
      initialDraft: initialDraft,
      createdAt: DateTime.now(),
    );
    var pendingIntentWasSaved = false;

    if (_currentUserId == null) {
      pendingIntentWasSaved = await _savePendingIntent(pendingIntent);
      if (!context.mounted) {
        if (pendingIntentWasSaved) {
          await _clearPendingIntent();
        }
        return;
      }
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              const LoginView(returnToCallerAfterCustomerLogin: true),
        ),
      );
      if (!context.mounted) return;
      if (signedIn != true) {
        if (pendingIntentWasSaved) {
          await _clearPendingIntent();
        }
        return;
      }
    }

    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    if (currentUserId == ownerUserId) {
      if (pendingIntentWasSaved) {
        await _clearPendingIntent();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Bu mağazaya kendi hesabınızla mesaj gönderemezsiniz.',
            ),
          ),
        );
      return;
    }

    if (pendingIntentWasSaved) {
      await _clearPendingIntent();
    }
    if (!context.mounted) return;

    final destination =
        chatDestinationBuilder?.call(ownerUserId, shop.name, initialDraft) ??
        ChatView(
          receiverId: ownerUserId,
          receiverName: shop.name,
          initialDraft: initialDraft,
        );

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
  }

  Future<bool> _savePendingIntent(PendingProductChatIntent intent) async {
    try {
      await _pendingProductChatStorage.save(intent);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearPendingIntent() async {
    try {
      await _pendingProductChatStorage.clear();
    } catch (_) {}
  }

  Future<void>? _startAddToCart(BuildContext context) {
    if (shopProduct.shop?.isActive != true) return null;

    return _addToCartAfterSignIn(context);
  }

  Future<void> _addToCartAfterSignIn(BuildContext context) async {
    if (_currentUserId == null) {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) =>
              const LoginView(returnToCallerAfterCustomerLogin: true),
        ),
      );
      if (!context.mounted || signedIn != true || _currentUserId == null) {
        return;
      }
    }

    await context.read<CartV2Cubit>().addShopProductToCart(
      shopProductId: shopProduct.id,
      quantity: 1,
    );
  }
}

class _SellerChatButton extends StatefulWidget {
  const _SellerChatButton({
    required this.shopProductId,
    required this.onPressed,
  });

  final String shopProductId;
  final Future<void> Function() onPressed;

  @override
  State<_SellerChatButton> createState() => _SellerChatButtonState();
}

class _SellerChatButtonState extends State<_SellerChatButton> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: Key('product-seller-message-${widget.shopProductId}'),
      onPressed: _isOpening ? null : _handlePressed,
      icon: const Icon(Icons.message_outlined),
      label: const Text('Esnafa Yaz'),
    );
  }

  Future<void> _handlePressed() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }
}

class _SellerAddToCartButton extends StatefulWidget {
  const _SellerAddToCartButton({
    required this.shopProductId,
    required this.onPressed,
  });

  final String shopProductId;
  final Future<void>? Function() onPressed;

  @override
  State<_SellerAddToCartButton> createState() => _SellerAddToCartButtonState();
}

class _SellerAddToCartButtonState extends State<_SellerAddToCartButton> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: ValueKey('product-seller-add-${widget.shopProductId}'),
      onPressed: _isAdding ? null : _handlePressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: _isAdding ? 0 : 1,
            child: const Text('Bu Esnaftan Sepete Ekle'),
          ),
          if (_isAdding)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  key: Key('product-seller-add-progress'),
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: TSizes.sm),
                Text('Sepete ekleniyor…'),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _handlePressed() async {
    if (_isAdding) return;

    final operation = widget.onPressed();
    if (operation == null) return;

    setState(() => _isAdding = true);
    try {
      await operation;
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
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
        color: Colors.green.withValues(alpha: 0.12),
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
