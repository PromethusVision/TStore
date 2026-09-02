import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_product_query_scope.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

typedef CategoryShopProductsLoader =
    Future<Either<String, List<ShopProductEntity>>> Function(
      List<String> productIds,
    );
typedef CategoryProductDestinationBuilder =
    Widget Function(ProductEntity product);

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({
    super.key,
    required this.title,
    this.categoryId,
    this.taxonomyQueryScope,
    this.currentUserIdProvider,
    this.shopProductsLoader,
    this.productDestinationBuilder,
    this.categoryPathLabel,
    this.visualPrototype = false,
  });

  final String title;
  final String? categoryId;
  final TaxonomyProductQueryScope? taxonomyQueryScope;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;
  final String? categoryPathLabel;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (_) {
        final cubit = sl<ProductsCubit>();
        final selectedCategoryId = categoryId;
        final selectedTaxonomyScope = taxonomyQueryScope;
        if (selectedTaxonomyScope != null) {
          cubit.getProducts(
            categoryId: selectedCategoryId,
            taxonomyQueryScope: selectedTaxonomyScope,
            refresh: true,
          );
        } else if (selectedCategoryId != null) {
          cubit.getProducts(categoryId: selectedCategoryId, refresh: true);
        }
        return cubit;
      },
      child: visualPrototype
          ? EsnaftaVarScaffold(
              body: Column(
                children: [
                  _ProductListingHeader(
                    title: title,
                    categoryPathLabel: categoryPathLabel,
                  ),
                  Expanded(child: _buildCategoryBody()),
                ],
              ),
            )
          : Scaffold(
              backgroundColor: CustomerHomeV1Tokens.cream,
              appBar: AppBar(
                backgroundColor: CustomerHomeV1Tokens.cream,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  key: const Key('category-back-button'),
                  tooltip: 'Geri',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: CustomerHomeV1Tokens.navy,
                  ),
                ),
                titleSpacing: 0,
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              body: SafeArea(top: false, child: _buildCategoryBody()),
            ),
    );
  }

  Widget _buildCategoryBody() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: _CategoryBody(
          title: title,
          categoryId: categoryId,
          taxonomyQueryScope: taxonomyQueryScope,
          currentUserIdProvider: currentUserIdProvider,
          shopProductsLoader: shopProductsLoader,
          productDestinationBuilder: productDestinationBuilder,
          visualPrototype: visualPrototype,
        ),
      ),
    );
  }
}

class _ProductListingHeader extends StatelessWidget {
  const _ProductListingHeader({
    required this.title,
    required this.categoryPathLabel,
  });

  final String title;
  final String? categoryPathLabel;

  @override
  Widget build(BuildContext context) {
    final pathLabel = categoryPathLabel?.trim() ?? '';
    return Container(
      key: const Key('product-listing-header'),
      padding: const EdgeInsets.fromLTRB(
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.xs,
        EsnaftaVarSpacing.md,
        EsnaftaVarSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: EsnaftaVarColors.divider)),
      ),
      child: Row(
        children: [
          EsnaftaVarSurfaceIconButton(
            buttonKey: const Key('category-back-button'),
            icon: Icons.arrow_back_rounded,
            tooltip: 'Geri',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YEREL ÜRÜNLER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: EsnaftaVarColors.textPrimary,
                  ),
                ),
                if (pathLabel.isNotEmpty) ...[
                  const SizedBox(height: EsnaftaVarSpacing.xxs),
                  _CompactCategoryPath(fullLabel: pathLabel),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCategoryPath extends StatelessWidget {
  const _CompactCategoryPath({required this.fullLabel});

  final String fullLabel;

  @override
  Widget build(BuildContext context) {
    final parts = fullLabel
        .split('›')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final visibleLabel = parts.length > 2
        ? '${parts.first} › … › ${parts.last}'
        : parts.join(' › ');

    return Semantics(
      label: 'Kategori yolu: $fullLabel',
      excludeSemantics: true,
      child: Tooltip(
        message: fullLabel,
        child: Row(
          key: const Key('product-listing-category-path'),
          children: [
            const Icon(
              Icons.account_tree_outlined,
              size: EsnaftaVarIconSizes.small,
              color: EsnaftaVarColors.textMuted,
            ),
            const SizedBox(width: EsnaftaVarSpacing.xxs),
            Expanded(
              child: Text(
                visibleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: EsnaftaVarColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBody extends StatefulWidget {
  const _CategoryBody({
    required this.title,
    required this.categoryId,
    required this.taxonomyQueryScope,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
    required this.productDestinationBuilder,
    required this.visualPrototype,
  });

  final String title;
  final String? categoryId;
  final TaxonomyProductQueryScope? taxonomyQueryScope;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;
  final bool visualPrototype;

  @override
  State<_CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<_CategoryBody> {
  _ProductSortOption _selectedSort = _ProductSortOption.defaultOrder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (widget.categoryId == null && widget.taxonomyQueryScope == null) {
          return _CategoryStatusView(
            key: Key('category-products-empty'),
            icon: Icons.inventory_2_outlined,
            title: 'Bu kategoride ürün bulunamadı',
            message: 'Yeni ürünler eklendiğinde burada görünecek.',
            visualPrototype: widget.visualPrototype,
          );
        }

        if (state is ProductsLoading || state is ProductsInitial) {
          return _CategoryLoadingView(
            title: widget.title,
            visualPrototype: widget.visualPrototype,
          );
        }

        if (state is ProductsError) {
          return _CategoryStatusView(
            key: const Key('category-products-error'),
            icon: Icons.cloud_off_rounded,
            title: 'Kategori ürünleri yüklenemedi',
            message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
            actionLabel: 'Tekrar Dene',
            onAction: _reload,
            visualPrototype: widget.visualPrototype,
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return _CategoryStatusView(
              key: Key('category-products-empty'),
              icon: Icons.inventory_2_outlined,
              title: 'Bu kategoride ürün bulunamadı',
              message: 'Yeni ürünler eklendiğinde burada görünecek.',
              visualPrototype: widget.visualPrototype,
            );
          }

          return _CategoryProductsList(
            title: widget.title,
            products: state.products,
            currentUserIdProvider: widget.currentUserIdProvider,
            shopProductsLoader: widget.shopProductsLoader,
            productDestinationBuilder: widget.productDestinationBuilder,
            visualPrototype: widget.visualPrototype,
            selectedSort: _selectedSort,
            onSortSelected: _applySort,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _applySort(_ProductSortOption option) {
    if (_selectedSort != option) {
      setState(() => _selectedSort = option);
    }
    _loadProducts(refresh: true);
  }

  void _reload() => _loadProducts(refresh: true);

  void _loadProducts({required bool refresh}) {
    final (sortBy, ascending) = widget.visualPrototype
        ? _selectedSort.query
        : (null, true);
    unawaited(
      context.read<ProductsCubit>().getProducts(
        categoryId: widget.categoryId,
        taxonomyQueryScope: widget.taxonomyQueryScope,
        sortBy: sortBy,
        ascending: ascending,
        refresh: refresh,
      ),
    );
  }
}

class _CategoryProductsList extends StatefulWidget {
  const _CategoryProductsList({
    required this.title,
    required this.products,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
    required this.productDestinationBuilder,
    required this.visualPrototype,
    required this.selectedSort,
    required this.onSortSelected,
  });

  static const int maximumProductCount = 20;

  final String title;
  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;
  final bool visualPrototype;
  final _ProductSortOption selectedSort;
  final ValueChanged<_ProductSortOption> onSortSelected;

  @override
  State<_CategoryProductsList> createState() => _CategoryProductsListState();
}

class _CategoryProductsListState extends State<_CategoryProductsList> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;
  final Set<String> _openingProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    _shopProductsFuture = _loadShopProducts();
  }

  @override
  void didUpdateWidget(covariant _CategoryProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_productIdsKey(oldWidget.products) != _productIdsKey(widget.products) ||
        oldWidget.shopProductsLoader != widget.shopProductsLoader) {
      _shopProductsFuture = _loadShopProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<String, List<ShopProductEntity>>>(
      future: _shopProductsFuture,
      builder: (context, snapshot) {
        final productLayout = _ProductListingLayout.resolve(context);
        final listingContexts =
            snapshot.data?.fold(
              (_) => const <String, _LocalListingContext>{},
              _localListingContexts,
            ) ??
            const <String, _LocalListingContext>{};
        final isPriceLoading =
            snapshot.connectionState == ConnectionState.waiting;

        return CustomScrollView(
          key: const Key('category-products-scroll'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: widget.visualPrototype
                    ? _ProductListingOverview(
                        productCount: widget.products.length,
                        selectedSort: widget.selectedSort,
                        onSortSelected: widget.onSortSelected,
                      )
                    : _CategorySummary(
                        title: widget.title,
                        subtitle: '${widget.products.length} ürün gösteriliyor',
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: widget.visualPrototype
                    ? EsnaftaVarSpacing.sm
                    : CustomerHomeV1Tokens.space16,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CustomerHomeV1Tokens.space16,
              ),
              sliver: SliverGrid(
                key: const Key('category-products-grid'),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: CustomerHomeV1Tokens.space12,
                  crossAxisSpacing: CustomerHomeV1Tokens.space12,
                  mainAxisExtent: widget.visualPrototype
                      ? productLayout.cardExtent
                      : 250,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = widget.products[index];
                  return _CategoryProductCard(
                    product: product,
                    currentUserIdProvider: widget.currentUserIdProvider,
                    priceLabel: _priceLabel(
                      product.id,
                      listingContexts,
                      isPriceLoading,
                    ),
                    merchantContextLabel: _merchantContextLabel(
                      product.id,
                      listingContexts,
                      isPriceLoading,
                    ),
                    visualPrototype: widget.visualPrototype,
                    visualLayout: productLayout,
                    onTap: product.id.trim().isEmpty
                        ? null
                        : () => unawaited(_openProduct(context, product)),
                  );
                }, childCount: widget.products.length),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: CustomerHomeV1Tokens.space24),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProduct(BuildContext context, ProductEntity product) async {
    final productId = product.id.trim();
    if (productId.isEmpty || _openingProductIds.contains(productId)) return;

    _openingProductIds.add(productId);
    try {
      final destination =
          widget.productDestinationBuilder?.call(product) ??
          ProductDetailsView(
            product: product,
            currentUserIdProvider: widget.currentUserIdProvider,
          );
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingProductIds.remove(productId);
    }
  }

  Future<Either<String, List<ShopProductEntity>>> _loadShopProducts() async {
    final productIds = widget.products
        .take(_CategoryProductsList.maximumProductCount)
        .map((product) => product.id)
        .toList(growable: false);
    try {
      final loader = widget.shopProductsLoader;
      if (loader != null) return await loader(productIds);
      return await sl<GetShopProductsByProductIdsUsecase>()(
        GetShopProductsByProductIdsParams(productIds: productIds),
      );
    } catch (_) {
      return const Left('Mağaza fiyatları yüklenemedi.');
    }
  }

  Map<String, _LocalListingContext> _localListingContexts(
    List<ShopProductEntity> shopProducts,
  ) {
    final minimumPrices = <String, double>{};
    final shopIds = <String, Set<String>>{};
    final shopNames = <String, String>{};
    for (final shopProduct in shopProducts) {
      final price = shopProduct.price;
      if (!shopProduct.isCustomerPurchasable || !price.isFinite || price < 0) {
        continue;
      }
      shopIds
          .putIfAbsent(shopProduct.productId, () => <String>{})
          .add(shopProduct.shopId);
      final shopName = shopProduct.shop?.name.trim() ?? '';
      if (shopName.isNotEmpty) {
        shopNames.putIfAbsent(shopProduct.productId, () => shopName);
      }
      final currentMinimum = minimumPrices[shopProduct.productId];
      if (currentMinimum == null || price < currentMinimum) {
        minimumPrices[shopProduct.productId] = price;
      }
    }
    return {
      for (final entry in minimumPrices.entries)
        entry.key: _LocalListingContext(
          minimumPrice: entry.value,
          shopCount: shopIds[entry.key]?.length ?? 0,
          singleShopName: shopIds[entry.key]?.length == 1
              ? shopNames[entry.key]
              : null,
        ),
    };
  }

  String _priceLabel(
    String productId,
    Map<String, _LocalListingContext> listingContexts,
    bool isPriceLoading,
  ) {
    if (isPriceLoading) return 'Fiyat yükleniyor';
    final price = listingContexts[productId]?.minimumPrice;
    if (price == null) return 'Mağaza fiyatını gör';
    return '${_formatPrice(price)} TL’den';
  }

  String _merchantContextLabel(
    String productId,
    Map<String, _LocalListingContext> listingContexts,
    bool isPriceLoading,
  ) {
    if (isPriceLoading) return 'Esnaf seçenekleri hazırlanıyor';
    final context = listingContexts[productId];
    if (context == null || context.shopCount == 0) {
      return 'Esnaf seçeneklerini gör';
    }
    final singleShopName = context.singleShopName?.trim() ?? '';
    if (context.shopCount == 1 && singleShopName.isNotEmpty) {
      return 'Mağaza: $singleShopName';
    }
    return '${context.shopCount} esnafta var';
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(2).split('.');
    final integerDigits = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < integerDigits.length; index++) {
      if (index > 0 && (integerDigits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerDigits[index]);
    }
    return '$buffer,${parts.last}';
  }

  String _productIdsKey(List<ProductEntity> products) {
    return products
        .take(_CategoryProductsList.maximumProductCount)
        .map((product) => product.id)
        .join('|');
  }
}

class _LocalListingContext {
  const _LocalListingContext({
    required this.minimumPrice,
    required this.shopCount,
    required this.singleShopName,
  });

  final double minimumPrice;
  final int shopCount;
  final String? singleShopName;
}

class _ProductListingLayout {
  const _ProductListingLayout({
    required this.cardExtent,
    required this.imageHeight,
    required this.usesScaledText,
  });

  factory _ProductListingLayout.resolve(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(
      context,
    ).width.clamp(0.0, 430.0).toDouble();
    final cardWidth = (viewportWidth - 44) / 2;
    final imageHeight = (cardWidth * 0.81).clamp(116.0, 144.0).toDouble();
    final usesScaledText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final contentHeight = usesScaledText
        ? 188.0
        : viewportWidth <= 340
        ? 164.0
        : 154.0;
    return _ProductListingLayout(
      cardExtent: imageHeight + contentHeight,
      imageHeight: imageHeight,
      usesScaledText: usesScaledText,
    );
  }

  final double cardExtent;
  final double imageHeight;
  final bool usesScaledText;
}

enum _ProductSortOption { defaultOrder, newest, highestRated }

extension on _ProductSortOption {
  (String?, bool) get query => switch (this) {
    _ProductSortOption.defaultOrder => (null, true),
    _ProductSortOption.newest => ('created_at', false),
    _ProductSortOption.highestRated => ('rating', false),
  };

  String get compactLabel => switch (this) {
    _ProductSortOption.defaultOrder => 'Sırala',
    _ProductSortOption.newest => 'En yeni',
    _ProductSortOption.highestRated => 'Puan',
  };
}

class _ProductListingOverview extends StatelessWidget {
  const _ProductListingOverview({
    required this.productCount,
    required this.selectedSort,
    required this.onSortSelected,
  });

  final int productCount;
  final _ProductSortOption selectedSort;
  final ValueChanged<_ProductSortOption> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('product-listing-overview'),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: EsnaftaVarTouchTargets.minimum,
            height: EsnaftaVarTouchTargets.minimum,
            decoration: BoxDecoration(
              color: EsnaftaVarColors.surface,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: EsnaftaVarColors.primary,
              size: EsnaftaVarIconSizes.large,
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$productCount ürün',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: EsnaftaVarColors.textPrimary,
                  ),
                ),
                Text(
                  'Yakındaki esnafların fiyatlarını karşılaştır',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          PopupMenuButton<_ProductSortOption>(
            key: const Key('category-sort-button'),
            tooltip: 'Ürünleri sırala',
            initialValue: selectedSort,
            onSelected: onSortSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _ProductSortOption.defaultOrder,
                child: Text('Varsayılan sıra'),
              ),
              PopupMenuItem(
                value: _ProductSortOption.newest,
                child: Text('En yeniler'),
              ),
              PopupMenuItem(
                value: _ProductSortOption.highestRated,
                child: Text('Puana göre'),
              ),
            ],
            child: Container(
              height: EsnaftaVarTouchTargets.minimum,
              padding: const EdgeInsets.symmetric(
                horizontal: EsnaftaVarSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: EsnaftaVarColors.surface,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
                border: Border.all(color: EsnaftaVarColors.borderDefault),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: EsnaftaVarIconSizes.small,
                    color: EsnaftaVarColors.primary,
                  ),
                  const SizedBox(width: EsnaftaVarSpacing.xxs),
                  Text(
                    selectedSort.compactLabel,
                    key: const Key('category-sort-selection'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: EsnaftaVarColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  const _CategorySummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('category-summary'),
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius16,
              ),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: CustomerHomeV1Tokens.petrol,
              size: 25,
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  const _CategoryProductCard({
    required this.product,
    required this.priceLabel,
    required this.merchantContextLabel,
    required this.currentUserIdProvider,
    required this.onTap,
    required this.visualPrototype,
    required this.visualLayout,
  });

  final ProductEntity product;
  final String priceLabel;
  final String merchantContextLabel;
  final String? Function()? currentUserIdProvider;
  final VoidCallback? onTap;
  final bool visualPrototype;
  final _ProductListingLayout visualLayout;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;
    if (visualPrototype) {
      return _buildVisualPrototype(context, secondaryText);
    }
    return Material(
      key: Key('category-product-${product.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        key: Key('category-product-link-${product.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 158,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CategoryProductImage(product: product),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix: 'category-product-favorite-${product.id}',
                        currentUserIdProvider: currentUserIdProvider,
                        height: 32,
                        width: 32,
                        iconSize: 17,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 12.5,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: CustomerHomeV1Tokens.space4),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.muted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        priceLabel,
                        key: Key('category-product-price-${product.id}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPrototype(BuildContext context, String? secondaryText) {
    return Semantics(
      button: onTap != null,
      label:
          '${product.name}. $merchantContextLabel. $priceLabel. Ürün detayını gör.',
      child: Material(
        key: Key('category-product-${product.id}'),
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        child: InkWell(
          key: Key('category-product-link-${product.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
              border: Border.all(color: EsnaftaVarColors.borderDefault),
              boxShadow: EsnaftaVarElevation.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: visualLayout.imageHeight,
                  width: double.infinity,
                  child: ColoredBox(
                    color: EsnaftaVarColors.surfaceAlt,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
                          child: _CategoryProductImageStage(product: product),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: ProductFavoriteButton(
                            productId: product.id,
                            keyPrefix:
                                'category-product-favorite-${product.id}',
                            currentUserIdProvider: currentUserIdProvider,
                            height: EsnaftaVarTouchTargets.minimum,
                            width: EsnaftaVarTouchTargets.minimum,
                            iconSize: EsnaftaVarIconSizes.medium,
                            backgroundColor: EsnaftaVarColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.sm,
                      EsnaftaVarSpacing.xs,
                      EsnaftaVarSpacing.sm,
                      EsnaftaVarSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: visualLayout.usesScaledText ? 44 : 34,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: EsnaftaVarColors.textPrimary,
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                            ),
                          ),
                        ),
                        if (secondaryText != null) ...[
                          const SizedBox(height: 2),
                          SizedBox(
                            height: visualLayout.usesScaledText ? 20 : 16,
                            child: Text(
                              secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: EsnaftaVarColors.textMuted,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                        ] else
                          SizedBox(
                            height: visualLayout.usesScaledText ? 22 : 18,
                          ),
                        const Spacer(),
                        SizedBox(
                          height: visualLayout.usesScaledText ? 40 : 34,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: EsnaftaVarIconSizes.small,
                                  color: EsnaftaVarColors.primary,
                                ),
                              ),
                              const SizedBox(width: EsnaftaVarSpacing.xxs),
                              Expanded(
                                child: Tooltip(
                                  message: merchantContextLabel,
                                  child: Text(
                                    merchantContextLabel,
                                    key: Key(
                                      'category-product-merchant-${product.id}',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: EsnaftaVarColors.primary,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        SizedBox(
                          width: double.infinity,
                          height: visualLayout.usesScaledText ? 28 : 22,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              priceLabel,
                              key: Key('category-product-price-${product.id}'),
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: EsnaftaVarColors.price,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _secondaryText {
    final brandName = product.brandName?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;
    final categoryName = product.categoryName?.trim() ?? '';
    return categoryName.isEmpty ? null : categoryName;
  }
}

class _CategoryProductImage extends StatelessWidget {
  const _CategoryProductImage({
    required this.product,
    this.fit = BoxFit.cover,
    this.useCanonicalFallback = false,
  });

  final ProductEntity product;
  final BoxFit fit;
  final bool useCanonicalFallback;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) {
      return _CategoryProductImageFallback(
        visualPrototype: useCanonicalFallback,
      );
    }

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (_, _, _) => _CategoryProductImageFallback(
          visualPrototype: useCanonicalFallback,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (_, _) =>
          _CategoryProductImageFallback(visualPrototype: useCanonicalFallback),
      errorWidget: (_, _, _) =>
          _CategoryProductImageFallback(visualPrototype: useCanonicalFallback),
    );
  }

  String? get _imageUrl {
    for (final image in product.images) {
      if (image.trim().isNotEmpty) return image.trim();
    }
    final thumbnail = product.thumbnail?.trim() ?? '';
    return thumbnail.isEmpty ? null : thumbnail;
  }
}

class _CategoryProductImageStage extends StatelessWidget {
  const _CategoryProductImageStage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        border: Border.all(color: EsnaftaVarColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium - 1),
        child: Padding(
          padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
          child: Center(
            child: _CategoryProductImage(
              product: product,
              fit: BoxFit.contain,
              useCanonicalFallback: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryProductImageFallback extends StatelessWidget {
  const _CategoryProductImageFallback({this.visualPrototype = false});

  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: visualPrototype
          ? EsnaftaVarColors.primarySoft
          : CustomerHomeV1Tokens.mint,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: visualPrototype
              ? EsnaftaVarColors.primary
              : CustomerHomeV1Tokens.petrol,
          size: 38,
        ),
      ),
    );
  }
}

class _CategoryLoadingView extends StatelessWidget {
  const _CategoryLoadingView({
    required this.title,
    required this.visualPrototype,
  });

  final String title;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    if (visualPrototype) return _buildVisualPrototype(context);
    return CustomScrollView(
      key: const Key('category-products-loading'),
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space8,
            CustomerHomeV1Tokens.space16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: _CategorySummary(
              title: title,
              subtitle: 'Ürünler hazırlanıyor',
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: CustomerHomeV1Tokens.space16),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomerHomeV1Tokens.space16,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: CustomerHomeV1Tokens.space12,
              crossAxisSpacing: CustomerHomeV1Tokens.space12,
              mainAxisExtent: 250,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => const _CategoryProductSkeleton(),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualPrototype(BuildContext context) {
    final layout = _ProductListingLayout.resolve(context);
    return CustomScrollView(
      key: const Key('category-products-loading'),
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            EsnaftaVarSpacing.md,
            EsnaftaVarSpacing.xs,
            EsnaftaVarSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 72,
              padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
              decoration: BoxDecoration(
                color: EsnaftaVarColors.primarySoft,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
                border: Border.all(color: EsnaftaVarColors.borderDefault),
              ),
              child: const Row(
                children: [
                  _ProductListingSkeletonBlock(width: 44, height: 44),
                  SizedBox(width: EsnaftaVarSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductListingSkeletonLine(width: 72),
                        SizedBox(height: EsnaftaVarSpacing.xs),
                        _ProductListingSkeletonLine(width: 154),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: EsnaftaVarSpacing.sm)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: EsnaftaVarSpacing.md),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: EsnaftaVarSpacing.sm,
              crossAxisSpacing: EsnaftaVarSpacing.sm,
              mainAxisExtent: layout.cardExtent,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => _ProductListingProductSkeleton(layout: layout),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductListingProductSkeleton extends StatelessWidget {
  const _ProductListingProductSkeleton({required this.layout});

  final _ProductListingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductListingSkeletonBlock(
            width: double.infinity,
            height: layout.imageHeight,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(EsnaftaVarSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductListingSkeletonLine(width: 118),
                  SizedBox(height: EsnaftaVarSpacing.xs),
                  _ProductListingSkeletonLine(width: 76),
                  Spacer(),
                  _ProductListingSkeletonLine(width: 102),
                  SizedBox(height: EsnaftaVarSpacing.xs),
                  _ProductListingSkeletonLine(width: 88),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListingSkeletonBlock extends StatelessWidget {
  const _ProductListingSkeletonBlock({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceAlt,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
      ),
    );
  }
}

class _ProductListingSkeletonLine extends StatelessWidget {
  const _ProductListingSkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: EsnaftaVarColors.borderDefault,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
      ),
    );
  }
}

class _CategoryProductSkeleton extends StatelessWidget {
  const _CategoryProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 158,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(CustomerHomeV1Tokens.radius16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 112),
                SizedBox(height: CustomerHomeV1Tokens.space8),
                _SkeletonLine(width: 72),
                SizedBox(height: CustomerHomeV1Tokens.space12),
                _SkeletonLine(width: 88),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
      ),
    );
  }
}

class _CategoryStatusView extends StatelessWidget {
  const _CategoryStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.visualPrototype = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    if (visualPrototype) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
                child: IntrinsicHeight(
                  child: EsnaftaVarStateCard(
                    icon: icon,
                    title: title,
                    message: message,
                    actionLabel: actionLabel,
                    onAction: onAction,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.surface,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius20,
                  ),
                  border: Border.all(color: CustomerHomeV1Tokens.border),
                  boxShadow: CustomerHomeV1Tokens.softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: CustomerHomeV1Tokens.mint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: CustomerHomeV1Tokens.petrol,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space16),
                      FilledButton(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: CustomerHomeV1Tokens.petrol,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radiusPill,
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
          ),
        ),
      ],
    );
  }
}
