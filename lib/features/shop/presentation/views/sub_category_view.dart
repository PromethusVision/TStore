import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/horizontal_product_card.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

typedef CategoryShopProductsLoader =
    Future<Either<String, List<ShopProductEntity>>> Function(
      List<String> productIds,
    );

class SubCategoryView extends StatelessWidget {
  final String title;
  final String? categoryId;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;

  const SubCategoryView({
    super.key,
    required this.title,
    this.categoryId,
    this.currentUserIdProvider,
    this.shopProductsLoader,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<ProductsCubit>();
        if (categoryId != null) {
          cubit.getProducts(categoryId: categoryId, refresh: true);
        }
        return cubit;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          appBarModel: AppBarModel(hasArrowBack: true, title: Text(title)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  RoundedImage(
                    roundedImageModel: RoundedImageModel(
                      image: TImages.promoBanner2,
                      applyImageRadius: true,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, state) {
                      if (categoryId == null) {
                        return const Center(
                          child: Text('Bu kategoride ürün bulunamadı'),
                        );
                      }

                      if (state is ProductsLoading ||
                          state is ProductsInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ProductsError) {
                        return Center(child: Text(state.message));
                      }

                      if (state is ProductsLoaded) {
                        if (state.products.isEmpty) {
                          return const Center(
                            child: Text('Bu kategoride ürün bulunamadı'),
                          );
                        }

                        return _CategoryProductsList(
                          products: state.products,
                          currentUserIdProvider: currentUserIdProvider,
                          shopProductsLoader: shopProductsLoader,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryProductsList extends StatefulWidget {
  const _CategoryProductsList({
    required this.products,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
  });

  static const int maximumProductCount = 20;

  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final CategoryShopProductsLoader? shopProductsLoader;

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

        return SizedBox(
          height: 128,
          child: ListView.separated(
            key: const Key('category-products-list'),
            itemCount: widget.products.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return HorizontalProductCard(
                product: product,
                currentUserIdProvider: widget.currentUserIdProvider,
                priceLabel: _priceLabel(
                  product.id,
                  minimumPrices,
                  isPriceLoading,
                ),
                showCatalogDiscount: false,
              );
            },
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.spaceBtwItems),
          ),
        );
      },
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
