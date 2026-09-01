import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

typedef HomeProductDestinationBuilder = Widget Function(ProductEntity product);
typedef HomeShopProductsLoader =
    Future<Either<String, List<ShopProductEntity>>> Function(
      List<String> productIds,
    );

class HomeProductsSection extends StatelessWidget {
  const HomeProductsSection({
    super.key,
    this.destinationBuilder,
    this.currentUserIdProvider,
    this.shopProductsLoader,
    this.visualPrototype = false,
  });

  final HomeProductDestinationBuilder? destinationBuilder;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final HomeShopProductsLoader? shopProductsLoader;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Column(
          key: const Key('home-products-section'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EsnaftaVarSectionHeader(
              title: visualPrototype
                  ? 'Mahallende bugün'
                  : 'Size Özel Seçtiklerimiz',
              subtitle: visualPrototype
                  ? 'Fiyatları yerel esnaflarda karşılaştır'
                  : 'Yakındaki esnaflarda bulunan ürünler',
              actionLabel: 'Tümünü Gör',
              actionKey: const Key('home-products-view-all'),
              onAction: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => AllProductsView(
                    currentUserIdProvider: currentUserIdProvider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            if (state is ProductsLoading || state is ProductsInitial)
              const _ProductsLoading()
            else if (state is ProductsError)
              EsnaftaVarStateCard(
                key: const Key('home-products-error'),
                icon: Icons.cloud_off_rounded,
                title: 'Ürünler yüklenemedi',
                message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
                actionLabel: 'Tekrar Dene',
                onAction: () => context.read<ProductsCubit>().getProducts(
                  isFeatured: true,
                  sortBy: 'rating',
                  ascending: false,
                  refresh: true,
                ),
              )
            else if (state is ProductsLoaded && state.products.isEmpty)
              const EsnaftaVarStateCard(
                key: Key('home-products-empty'),
                icon: Icons.inventory_2_outlined,
                title: 'Şu anda gösterilecek ürün bulunamadı',
                message: 'Yeni ürünler eklendiğinde burada görünecek.',
              )
            else if (state is ProductsLoaded)
              _HomeProductCards(
                products: state.products.take(8).toList(growable: false),
                destinationBuilder: destinationBuilder,
                currentUserIdProvider: currentUserIdProvider,
                shopProductsLoader: shopProductsLoader,
                visualPrototype: visualPrototype,
              )
            else
              const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _HomeProductCards extends StatefulWidget {
  final List<ProductEntity> products;
  final HomeProductDestinationBuilder? destinationBuilder;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final HomeShopProductsLoader? shopProductsLoader;
  final bool visualPrototype;

  const _HomeProductCards({
    required this.products,
    required this.destinationBuilder,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
    required this.visualPrototype,
  });

  @override
  State<_HomeProductCards> createState() => _HomeProductCardsState();
}

class _HomeProductCardsState extends State<_HomeProductCards> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;
  final Set<String> _openingProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    _shopProductsFuture = _loadShopProducts();
  }

  @override
  void didUpdateWidget(covariant _HomeProductCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_productIdsKey(oldWidget.products) != _productIdsKey(widget.products)) {
      _shopProductsFuture = _loadShopProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<String, List<ShopProductEntity>>>(
      future: _shopProductsFuture,
      builder: (context, snapshot) {
        final isPriceLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final minimumPrices =
            snapshot.data?.fold(
              (_) => const <String, double>{},
              _minimumPricesFor,
            ) ??
            const <String, double>{};

        return LayoutBuilder(
          builder: (context, constraints) {
            final prototypeCardWidth = ((constraints.maxWidth - 22) / 2).clamp(
              140.0,
              190.0,
            );
            final usesScaledText =
                MediaQuery.textScalerOf(context).scale(1) > 1.15;
            return SizedBox(
              key: const Key('home-products-loaded'),
              height: widget.visualPrototype
                  ? usesScaledText
                        ? 254
                        : 246
                  : 234,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.products.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: CustomerHomeV1Tokens.space8),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  final card = HomeProductCard(
                    product: product,
                    minimumShopPrice: minimumPrices[product.id],
                    isPriceLoading: isPriceLoading,
                    currentUserIdProvider: widget.currentUserIdProvider,
                    visualPrototype: widget.visualPrototype,
                    onTap: product.id.trim().isEmpty
                        ? null
                        : () =>
                              unawaited(_openProductDetails(context, product)),
                  );
                  if (!widget.visualPrototype) return card;
                  return SizedBox(width: prototypeCardWidth, child: card);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openProductDetails(
    BuildContext context,
    ProductEntity product,
  ) async {
    final productId = product.id.trim();
    if (productId.isEmpty || _openingProductIds.contains(productId)) return;

    _openingProductIds.add(productId);
    try {
      final destination =
          widget.destinationBuilder?.call(product) ??
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

  Map<String, double> _minimumPricesFor(List<ShopProductEntity> shopProducts) {
    final minimumPrices = <String, double>{};
    for (final shopProduct in shopProducts) {
      final price = shopProduct.price;
      if (!shopProduct.isCustomerPurchasable || !price.isFinite || price < 0) {
        continue;
      }
      final currentMinimum = minimumPrices[shopProduct.productId];
      if (currentMinimum == null || price < currentMinimum) {
        minimumPrices[shopProduct.productId] = price;
      }
    }
    return minimumPrices;
  }

  String _productIdsKey(List<ProductEntity> products) {
    return products.map((product) => product.id).join('|');
  }
}

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.minimumShopPrice,
    this.isPriceLoading = false,
    this.currentUserIdProvider,
    this.visualPrototype = false,
  });

  final ProductEntity product;
  final VoidCallback? onTap;
  final double? minimumShopPrice;
  final bool isPriceLoading;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;
    if (visualPrototype) {
      return _buildVisualPrototype(context, secondaryText);
    }
    return Material(
      key: Key('home-product-${product.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        key: Key('home-product-link-${product.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
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
              SizedBox(
                height: 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ProductImage(product: product),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix: 'home-product-favorite-${product.id}',
                        currentUserIdProvider: currentUserIdProvider,
                        height: EsnaftaVarTouchTargets.minimum,
                        width: EsnaftaVarTouchTargets.minimum,
                        iconSize: EsnaftaVarIconSizes.medium,
                        backgroundColor: CustomerHomeV1Tokens.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 13,
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
    return SizedBox(
      width: 152,
      child: Material(
        key: Key('home-product-${product.id}'),
        color: Colors.transparent,
        child: InkWell(
          key: Key('home-product-link-${product.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius20,
                      ),
                      child: _ProductImage(
                        product: product,
                        visualPrototype: true,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix: 'home-product-favorite-${product.id}',
                        currentUserIdProvider: currentUserIdProvider,
                        height: EsnaftaVarTouchTargets.minimum,
                        width: EsnaftaVarTouchTargets.minimum,
                        iconSize: EsnaftaVarIconSizes.medium,
                        backgroundColor: CustomerHomeV1Tokens.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CustomerHomeV1Tokens.space8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 13.5,
                          height: 1.22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.petrol,
                          fontSize: 14,
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

  String get _priceLabel {
    if (isPriceLoading) return 'Fiyat yükleniyor';
    final price = minimumShopPrice;
    if (price == null) return 'Mağaza fiyatını gör';
    return '${_priceText(price)}’den';
  }

  String? get _secondaryText {
    final brandName = product.brandName?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;
    final categoryName = product.categoryName?.trim() ?? '';
    return categoryName.isEmpty ? null : categoryName;
  }

  String _priceText(double price) {
    final parts = price.toStringAsFixed(2).split('.');
    final integerDigits = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < integerDigits.length; index++) {
      if (index > 0 && (integerDigits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerDigits[index]);
    }
    return '$buffer,${parts.last} TL';
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, this.visualPrototype = false});

  final ProductEntity product;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _ProductImageFallback();

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      final assetImage = Image.asset(
        imageUrl,
        fit: visualPrototype ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (_, _, _) => const _ProductImageFallback(),
      );
      if (!visualPrototype) return assetImage;
      return ColoredBox(
        color: CustomerHomeV1Tokens.mint,
        child: Padding(
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space8),
          child: assetImage,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _ProductImageFallback(),
      errorWidget: (_, _, _) => const _ProductImageFallback(),
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

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: CustomerHomeV1Tokens.mint,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: CustomerHomeV1Tokens.petrol,
          size: 34,
        ),
      ),
    );
  }
}

class _ProductsLoading extends StatelessWidget {
  const _ProductsLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('home-products-loading'),
      height: 234,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) =>
            const SizedBox(width: CustomerHomeV1Tokens.space8),
        itemBuilder: (_, _) => Container(
          width: 158,
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.mint,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          ),
        ),
      ),
    );
  }
}
