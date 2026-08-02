import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
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
    this.currentUserIdProvider,
    this.shopProductsLoader,
    this.productDestinationBuilder,
  });

  final String title;
  final String? categoryId;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (_) {
        final cubit = sl<ProductsCubit>();
        final selectedCategoryId = categoryId;
        if (selectedCategoryId != null) {
          cubit.getProducts(categoryId: selectedCategoryId, refresh: true);
        }
        return cubit;
      },
      child: Scaffold(
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
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _CategoryBody(
                title: title,
                categoryId: categoryId,
                currentUserIdProvider: currentUserIdProvider,
                shopProductsLoader: shopProductsLoader,
                productDestinationBuilder: productDestinationBuilder,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({
    required this.title,
    required this.categoryId,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
    required this.productDestinationBuilder,
  });

  final String title;
  final String? categoryId;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (categoryId == null) {
          return const _CategoryStatusView(
            key: Key('category-products-empty'),
            icon: Icons.inventory_2_outlined,
            title: 'Bu kategoride ürün bulunamadı',
            message: 'Yeni ürünler eklendiğinde burada görünecek.',
          );
        }

        if (state is ProductsLoading || state is ProductsInitial) {
          return _CategoryLoadingView(title: title);
        }

        if (state is ProductsError) {
          return _CategoryStatusView(
            key: const Key('category-products-error'),
            icon: Icons.cloud_off_rounded,
            title: 'Kategori ürünleri yüklenemedi',
            message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
            actionLabel: 'Tekrar Dene',
            onAction: () => context.read<ProductsCubit>().getProducts(
              categoryId: categoryId,
              refresh: true,
            ),
          );
        }

        if (state is ProductsLoaded) {
          if (state.products.isEmpty) {
            return const _CategoryStatusView(
              key: Key('category-products-empty'),
              icon: Icons.inventory_2_outlined,
              title: 'Bu kategoride ürün bulunamadı',
              message: 'Yeni ürünler eklendiğinde burada görünecek.',
            );
          }

          return _CategoryProductsList(
            title: title,
            products: state.products,
            currentUserIdProvider: currentUserIdProvider,
            shopProductsLoader: shopProductsLoader,
            productDestinationBuilder: productDestinationBuilder,
          );
        }

        return const SizedBox.shrink();
      },
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
  });

  static const int maximumProductCount = 20;

  final String title;
  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;
  final CategoryProductDestinationBuilder? productDestinationBuilder;

  @override
  State<_CategoryProductsList> createState() => _CategoryProductsListState();
}

class _CategoryProductsListState extends State<_CategoryProductsList> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;

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
        final minimumPrices =
            snapshot.data?.fold(
              (_) => const <String, double>{},
              _minimumPurchasablePrices,
            ) ??
            const <String, double>{};
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
                child: _CategorySummary(
                  title: widget.title,
                  subtitle: '${widget.products.length} ürün gösteriliyor',
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
                key: const Key('category-products-grid'),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: CustomerHomeV1Tokens.space12,
                  crossAxisSpacing: CustomerHomeV1Tokens.space12,
                  mainAxisExtent: 250,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = widget.products[index];
                  return _CategoryProductCard(
                    product: product,
                    currentUserIdProvider: widget.currentUserIdProvider,
                    priceLabel: _priceLabel(
                      product.id,
                      minimumPrices,
                      isPriceLoading,
                    ),
                    onTap: () => _openProduct(context, product),
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

  void _openProduct(BuildContext context, ProductEntity product) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            widget.productDestinationBuilder?.call(product) ??
            ProductDetailsView(
              product: product,
              currentUserIdProvider: widget.currentUserIdProvider,
            ),
      ),
    );
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

  Map<String, double> _minimumPurchasablePrices(
    List<ShopProductEntity> shopProducts,
  ) {
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

  String _priceLabel(
    String productId,
    Map<String, double> minimumPrices,
    bool isPriceLoading,
  ) {
    if (isPriceLoading) return 'Fiyat yükleniyor';
    final price = minimumPrices[productId];
    if (price == null) return 'Mağaza fiyatını gör';
    return '${_formatPrice(price)} TL’den';
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
    required this.currentUserIdProvider,
    required this.onTap,
  });

  final ProductEntity product;
  final String priceLabel;
  final String? Function()? currentUserIdProvider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;
    return Material(
      key: Key('category-product-${product.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
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

  String? get _secondaryText {
    final brandName = product.brandName?.trim() ?? '';
    if (brandName.isNotEmpty) return brandName;
    final categoryName = product.categoryName?.trim() ?? '';
    return categoryName.isEmpty ? null : categoryName;
  }
}

class _CategoryProductImage extends StatelessWidget {
  const _CategoryProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _CategoryProductImageFallback();

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _CategoryProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _CategoryProductImageFallback(),
      errorWidget: (_, _, _) => const _CategoryProductImageFallback(),
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

class _CategoryProductImageFallback extends StatelessWidget {
  const _CategoryProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: CustomerHomeV1Tokens.mint,
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          color: CustomerHomeV1Tokens.petrol,
          size: 38,
        ),
      ),
    );
  }
}

class _CategoryLoadingView extends StatelessWidget {
  const _CategoryLoadingView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
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
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
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
