import 'package:dartz/dartz.dart' hide State;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
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
  });

  final HomeProductDestinationBuilder? destinationBuilder;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;
  final HomeShopProductsLoader? shopProductsLoader;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Column(
          key: const Key('home-products-section'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductsHeader(
              onViewAll: () => Navigator.of(context).push<void>(
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
              _ProductsStatus(
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
              const _ProductsStatus(
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

  const _HomeProductCards({
    required this.products,
    required this.destinationBuilder,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
  });

  @override
  State<_HomeProductCards> createState() => _HomeProductCardsState();
}

class _HomeProductCardsState extends State<_HomeProductCards> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;

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

        return SizedBox(
          key: const Key('home-products-loaded'),
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.products.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: CustomerHomeV1Tokens.space8),
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return HomeProductCard(
                product: product,
                minimumShopPrice: minimumPrices[product.id],
                isPriceLoading: isPriceLoading,
                currentUserIdProvider: widget.currentUserIdProvider,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        widget.destinationBuilder?.call(product) ??
                        ProductDetailsView(
                          product: product,
                          currentUserIdProvider: widget.currentUserIdProvider,
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final double? minimumShopPrice;
  final bool isPriceLoading;
  final ProductFavoriteCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;
    return Material(
      key: Key('home-product-${product.id}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: Container(
          width: 116,
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
                height: 106,
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
                        height: 28,
                        width: 28,
                        iconSize: 15,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
                            fontSize: 8,
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
                          fontSize: 11,
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
  const _ProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _ProductImageFallback();

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ProductImageFallback(),
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

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Size Özel Seçtiklerimiz',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.25,
            ),
          ),
        ),
        TextButton(
          key: const Key('home-products-view-all'),
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

class _ProductsLoading extends StatelessWidget {
  const _ProductsLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('home-products-loading'),
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) =>
            const SizedBox(width: CustomerHomeV1Tokens.space8),
        itemBuilder: (_, _) => Container(
          width: 116,
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.mint,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          ),
        ),
      ),
    );
  }
}

class _ProductsStatus extends StatelessWidget {
  const _ProductsStatus({
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
