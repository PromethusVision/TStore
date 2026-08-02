import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_ids_usecase.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_category_presentation_helper.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

typedef CustomerCategoryDestinationBuilder =
    Widget Function(CategoryEntity category);
typedef CustomerShopDestinationBuilder = Widget Function(ShopEntity shop);
typedef SearchResultsShopProductsLoader =
    Future<Either<String, List<ShopProductEntity>>> Function(
      List<String> productIds,
    );

class AllProductsView extends StatelessWidget {
  const AllProductsView({
    super.key,
    this.autoFocusSearch = false,
    this.isSearchMode = false,
    this.initialQuery = '',
    this.currentUserIdProvider,
    this.recentSearchesStorage,
    this.customerSearchCubit,
    this.categoryDestinationBuilder,
    this.shopDestinationBuilder,
    this.shopProductsLoader,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String initialQuery;
  final String? Function()? currentUserIdProvider;
  final RecentProductSearchesStorage? recentSearchesStorage;
  final CustomerSearchCubit? customerSearchCubit;
  final CustomerCategoryDestinationBuilder? categoryDestinationBuilder;
  final CustomerShopDestinationBuilder? shopDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  Widget build(BuildContext context) {
    final content = _AllProductsContent(
      autoFocusSearch: autoFocusSearch,
      isSearchMode: isSearchMode,
      initialQuery: initialQuery,
      currentUserIdProvider: currentUserIdProvider,
      recentSearchesStorage:
          recentSearchesStorage ?? sl<RecentProductSearchesStorage>(),
      categoryDestinationBuilder: categoryDestinationBuilder,
      shopDestinationBuilder: shopDestinationBuilder,
      shopProductsLoader: shopProductsLoader,
    );

    if (!isSearchMode) {
      return BlocProvider<ProductsCubit>(
        create: (_) => sl<ProductsCubit>(),
        child: content,
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsCubit>(create: (_) => sl<ProductsCubit>()),
        BlocProvider<CustomerSearchCubit>(
          create: (_) => customerSearchCubit ?? sl<CustomerSearchCubit>(),
        ),
      ],
      child: content,
    );
  }
}

class _AllProductsContent extends StatefulWidget {
  const _AllProductsContent({
    required this.autoFocusSearch,
    required this.isSearchMode,
    required this.initialQuery,
    required this.recentSearchesStorage,
    this.currentUserIdProvider,
    this.categoryDestinationBuilder,
    this.shopDestinationBuilder,
    this.shopProductsLoader,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String initialQuery;
  final String? Function()? currentUserIdProvider;
  final RecentProductSearchesStorage recentSearchesStorage;
  final CustomerCategoryDestinationBuilder? categoryDestinationBuilder;
  final CustomerShopDestinationBuilder? shopDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  State<_AllProductsContent> createState() => _AllProductsContentState();
}

class _AllProductsContentState extends State<_AllProductsContent> {
  static const double _loadMoreThreshold = 400;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 350);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;
  List<String> _recentSearches = const [];
  String? _lastRequestedQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_loadRecentSearches());

    final initialQuery = widget.initialQuery.trim();
    if (initialQuery.isNotEmpty) {
      _searchController
        ..text = initialQuery
        ..selection = TextSelection.collapsed(offset: initialQuery.length);
    }

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }

    if (widget.isSearchMode && initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _runSearch(initialQuery);
        }
      });
    } else {
      context.read<ProductsCubit>().getProducts(refresh: true);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSearchMode ? 'Ara' : 'Tüm Ürünler';

    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(title: Text(title), hasArrowBack: true),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                enabled: true,
                readOnly: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                autofocus: widget.autoFocusSearch,
                onTap: () {
                  if (!_searchFocusNode.hasFocus) {
                    _searchFocusNode.requestFocus();
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.isSearchMode
                      ? 'Ürün, kategori veya mağaza ara'
                      : 'Tüm ürünlerde ara',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Aramayı temizle',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _onSearchChanged(value);
                },
                onFieldSubmitted: _submitSearch,
              ),
              if (_shouldShowRecentSearches) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                _RecentSearchesSection(
                  queries: _recentSearches,
                  onSelected: _selectRecentSearch,
                  onRemoved: _removeRecentSearch,
                  onClear: _clearRecentSearches,
                ),
              ],
              const SizedBox(height: TSizes.spaceBtwItems),
              Expanded(
                child:
                    widget.isSearchMode &&
                        _searchController.text.trim().isNotEmpty
                    ? BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
                        builder: _buildCustomerSearchState,
                      )
                    : BlocConsumer<ProductsCubit, ProductsState>(
                        listener: _handleProductsState,
                        builder: _buildProductsState,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSearchState(
    BuildContext context,
    CustomerSearchState state,
  ) {
    if (state is CustomerSearchInitial || state is CustomerSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CustomerSearchError) {
      return _SearchError(message: state.message, onRetry: _reloadProducts);
    }

    if (state is CustomerSearchLoaded) {
      if (state.isEmpty) {
        return _EmptySearchResult(
          query: state.query,
          onEditSearch: _editSearch,
          onShowAllProducts: _clearSearch,
          isUnifiedSearch: true,
        );
      }

      return _CustomerSearchResultsView(
        controller: _scrollController,
        state: state,
        currentUserIdProvider: widget.currentUserIdProvider,
        categoryDestinationBuilder: widget.categoryDestinationBuilder,
        shopDestinationBuilder: widget.shopDestinationBuilder,
        shopProductsLoader: widget.shopProductsLoader,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProductsState(BuildContext context, ProductsState state) {
    if (state is ProductsLoading ||
        state is ProductsInitial ||
        state is ProductsSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductsError) {
      return _SearchError(
        message: 'Ürünler yüklenemedi. Lütfen daha sonra tekrar deneyin.',
        onRetry: _reloadProducts,
      );
    }

    if (state is ProductsSearchResult) {
      if (state.products.isEmpty) {
        return _EmptySearchResult(
          query: state.query,
          onEditSearch: _editSearch,
          onShowAllProducts: _clearSearch,
        );
      }

      return _ProductsScrollView(
        controller: _scrollController,
        products: state.products,
        currentUserIdProvider: widget.currentUserIdProvider,
        shopProductsLoader: widget.shopProductsLoader,
      );
    }

    if (state is ProductsLoaded) {
      if (state.products.isEmpty) {
        return const Center(child: Text('Ürün bulunamadı.'));
      }

      return _ProductsScrollView(
        controller: _scrollController,
        products: state.products,
        currentUserIdProvider: widget.currentUserIdProvider,
        shopProductsLoader: widget.shopProductsLoader,
        footer: _ProductsLoadMoreFooter(state: state, onRetry: _retryLoadMore),
      );
    }

    return const SizedBox.shrink();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    setState(() {});
    _scrollToTop();

    if (query.isEmpty) {
      _lastRequestedQuery = null;
      if (widget.isSearchMode) {
        context.read<CustomerSearchCubit>().reset();
      }
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted || _searchController.text.trim() != query) return;
      _runSearch(query);
    });
  }

  void _submitSearch(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    if (query.isEmpty) return;

    _runSearch(query);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _lastRequestedQuery = null;
    setState(() {});
    _scrollToTop();
    if (widget.isSearchMode) {
      context.read<CustomerSearchCubit>().reset();
    }
    context.read<ProductsCubit>().getProducts(refresh: true);
  }

  void _editSearch() {
    _searchDebounce?.cancel();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
    _searchFocusNode.requestFocus();
  }

  void _reloadProducts() {
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _scrollToTop();
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    _runSearch(query);
  }

  void _runSearch(String query) {
    if (widget.isSearchMode) {
      final customerSearchCubit = context.read<CustomerSearchCubit>();
      if (_lastRequestedQuery == query &&
          customerSearchCubit.state is CustomerSearchLoading) {
        return;
      }

      _lastRequestedQuery = query;
      unawaited(_searchCustomerResults(customerSearchCubit, query));
      return;
    }

    final productsCubit = context.read<ProductsCubit>();
    if (_lastRequestedQuery == query &&
        productsCubit.state is ProductsSearching) {
      return;
    }

    _lastRequestedQuery = query;
    unawaited(productsCubit.searchProducts(query));
  }

  void _handleProductsState(BuildContext context, ProductsState state) {
    if (state is! ProductsSearchResult) return;

    final currentQuery = _searchController.text.trim();
    if (currentQuery.isEmpty || state.query.trim() != currentQuery) return;

    unawaited(_recordRecentSearch(currentQuery));
  }

  Future<void> _searchCustomerResults(
    CustomerSearchCubit cubit,
    String query,
  ) async {
    await cubit.search(query);
    if (!mounted || _searchController.text.trim() != query) return;

    final state = cubit.state;
    if (state is CustomerSearchLoaded && state.query.trim() == query) {
      await _recordRecentSearch(query);
    }
  }

  bool get _shouldShowRecentSearches =>
      widget.isSearchMode &&
      _searchController.text.trim().isEmpty &&
      _recentSearches.isNotEmpty;

  Future<void> _loadRecentSearches() async {
    try {
      final queries = await widget.recentSearchesStorage.getQueries();
      if (!mounted) return;

      setState(() => _recentSearches = queries);
    } catch (_) {
      // Arama geçmişi ana ürün arama akışını engellememelidir.
    }
  }

  Future<void> _recordRecentSearch(String query) async {
    try {
      await widget.recentSearchesStorage.recordQuery(query);
      await _loadRecentSearches();
    } catch (_) {
      // Yerel kayıt başarısız olsa bile arama sonucu kullanılabilir kalır.
    }
  }

  void _selectRecentSearch(String query) {
    _searchDebounce?.cancel();
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    setState(() {});
    _scrollToTop();
    _searchFocusNode.requestFocus();
    _runSearch(query);
  }

  Future<void> _removeRecentSearch(String query) async {
    try {
      await widget.recentSearchesStorage.removeQuery(query);
      await _loadRecentSearches();
    } catch (_) {
      // Tek bir geçmiş kaydı silinemese de ürün araması çalışmaya devam eder.
    }
  }

  Future<void> _clearRecentSearches() async {
    try {
      await widget.recentSearchesStorage.clear();
      if (!mounted) return;

      setState(() => _recentSearches = const []);
    } catch (_) {
      // Geçmiş temizleme hatası ana arama deneyimini engellememelidir.
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > _loadMoreThreshold ||
        _searchController.text.trim().isNotEmpty) {
      return;
    }

    final productsCubit = context.read<ProductsCubit>();
    final state = productsCubit.state;
    if (state is! ProductsLoaded ||
        state.hasReachedMax ||
        state.isLoadingMore ||
        state.loadMoreError != null) {
      return;
    }

    unawaited(productsCubit.loadMoreProducts());
  }

  void _retryLoadMore() {
    if (_searchController.text.trim().isNotEmpty) return;
    unawaited(context.read<ProductsCubit>().loadMoreProducts());
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: TSizes.spaceBtwItems),
          ElevatedButton(
            key: const Key('retry-customer-search'),
            onPressed: onRetry,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

class _CustomerSearchResultsView extends StatelessWidget {
  const _CustomerSearchResultsView({
    required this.controller,
    required this.state,
    this.currentUserIdProvider,
    this.categoryDestinationBuilder,
    this.shopDestinationBuilder,
    this.shopProductsLoader,
  });

  final ScrollController controller;
  final CustomerSearchLoaded state;
  final String? Function()? currentUserIdProvider;
  final CustomerCategoryDestinationBuilder? categoryDestinationBuilder;
  final CustomerShopDestinationBuilder? shopDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('customer-search-results'),
      controller: controller,
      slivers: [
        if (state.warningMessage != null)
          SliverToBoxAdapter(
            child: Container(
              key: const Key('customer-search-warning'),
              margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: TSizes.sm),
                  Expanded(child: Text(state.warningMessage!)),
                ],
              ),
            ),
          ),
        if (state.categories.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SearchSectionTitle(
              key: Key('customer-search-category-section'),
              title: 'Kategoriler',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
              child: Wrap(
                spacing: TSizes.sm,
                runSpacing: TSizes.sm,
                children: [
                  for (final category in state.categories)
                    ActionChip(
                      key: ValueKey('customer-search-category-${category.id}'),
                      avatar: const Icon(Icons.category_outlined, size: 18),
                      label: Text(
                        CustomerCategoryPresentationHelper.localizedTitle(
                          category.name,
                        ),
                      ),
                      onPressed: () => _openCategory(context, category),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (state.shops.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SearchSectionTitle(
              key: Key('customer-search-shop-section'),
              title: 'Mağazalar',
            ),
          ),
          SliverList.separated(
            itemCount: state.shops.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: TSizes.spaceBtwItems / 2),
            itemBuilder: (context, index) {
              final shop = state.shops[index];
              return _CustomerSearchShopCard(
                key: ValueKey('customer-search-shop-${shop.id}'),
                shop: shop,
                onTap: () => _openShop(context, shop),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: TSizes.spaceBtwSections),
          ),
        ],
        if (state.products.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: _SearchSectionTitle(
              key: Key('customer-search-product-section'),
              title: 'Ürünler',
            ),
          ),
          _SearchResultProductGrid(
            products: state.products,
            currentUserIdProvider: currentUserIdProvider,
            shopProductsLoader: shopProductsLoader,
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: TSizes.defaultSpace)),
      ],
    );
  }

  void _openCategory(BuildContext context, CategoryEntity category) {
    final destination =
        categoryDestinationBuilder?.call(category) ??
        SubCategoryView(
          title: CustomerCategoryPresentationHelper.localizedTitle(
            category.name,
          ),
          categoryId: category.id,
        );
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }

  void _openShop(BuildContext context, ShopEntity shop) {
    final destination =
        shopDestinationBuilder?.call(shop) ??
        ShopProfileView(
          shop: shop,
          currentUserIdProvider: currentUserIdProvider,
        );
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }
}

class _SearchResultProductGrid extends StatefulWidget {
  const _SearchResultProductGrid({
    required this.products,
    required this.currentUserIdProvider,
    required this.shopProductsLoader,
  });

  static const int maximumPricedProductCount = 30;

  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  State<_SearchResultProductGrid> createState() =>
      _SearchResultProductGridState();
}

class _SearchResultProductGridState extends State<_SearchResultProductGrid> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;

  @override
  void initState() {
    super.initState();
    _shopProductsFuture = _loadShopProducts();
  }

  @override
  void didUpdateWidget(covariant _SearchResultProductGrid oldWidget) {
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

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: TSizes.gridViewSpacing,
            crossAxisSpacing: TSizes.gridViewSpacing,
            mainAxisExtent: 288,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = widget.products[index];
            return VerticalProductCard(
              product: product,
              showFavoriteAction: true,
              currentUserIdProvider: widget.currentUserIdProvider,
              priceLabel: _sellerPriceLabel(
                product.id,
                minimumPrices,
                isPriceLoading,
              ),
              showCatalogDiscount: false,
            );
          }, childCount: widget.products.length),
        );
      },
    );
  }

  Future<Either<String, List<ShopProductEntity>>> _loadShopProducts() async {
    final productIds = widget.products
        .take(_SearchResultProductGrid.maximumPricedProductCount)
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

  String _productIdsKey(List<ProductEntity> products) {
    return products
        .take(_SearchResultProductGrid.maximumPricedProductCount)
        .map((product) => product.id)
        .join('|');
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

String _sellerPriceLabel(
  String productId,
  Map<String, double> minimumPrices,
  bool isPriceLoading,
) {
  if (isPriceLoading) return 'Fiyat yükleniyor';
  final price = minimumPrices[productId];
  if (price == null) return 'Mağaza fiyatını gör';
  return '${_formatTurkishPrice(price)} TL’den';
}

String _formatTurkishPrice(double price) {
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

class _SearchSectionTitle extends StatelessWidget {
  const _SearchSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _CustomerSearchShopCard extends StatelessWidget {
  const _CustomerSearchShopCard({
    super.key,
    required this.shop,
    required this.onTap,
  });

  final ShopEntity shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = shop.address?.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address == null || address.isEmpty
                          ? 'Adres bilgisi paylaşılmamış'
                          : address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (shop.ratingCount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${shop.rating.toStringAsFixed(1)} '
                            '(${shop.ratingCount})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({
    required this.query,
    required this.onEditSearch,
    required this.onShowAllProducts,
    this.isUnifiedSearch = false,
  });

  final String query;
  final VoidCallback onEditSearch;
  final VoidCallback onShowAllProducts;
  final bool isUnifiedSearch;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                normalizedQuery.isEmpty
                    ? isUnifiedSearch
                          ? 'Aradığınız sonuç bulunamadı.'
                          : 'Aradığınız ürün bulunamadı.'
                    : isUnifiedSearch
                    ? '"$normalizedQuery" için sonuç bulamadık.'
                    : '"$normalizedQuery" için ürün bulamadık.',
                key: const Key('empty-search-result-title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                isUnifiedSearch
                    ? 'Ürün, kategori veya mağaza adıyla yeniden arayabilirsiniz.'
                    : 'Daha kısa veya farklı bir kelimeyle yeniden arayabilirsiniz.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('edit-empty-product-search'),
                  onPressed: onEditSearch,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Aramayı Düzenle'),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('show-all-products-after-empty-search'),
                  onPressed: onShowAllProducts,
                  child: const Text('Tüm Ürünleri Göster'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesSection extends StatelessWidget {
  const _RecentSearchesSection({
    required this.queries,
    required this.onSelected,
    required this.onRemoved,
    required this.onClear,
  });

  final List<String> queries;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemoved;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Son aramalar',
      child: Column(
        key: const Key('recent-product-searches-section'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Son Aramalar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                key: const Key('clear-recent-product-searches'),
                onPressed: onClear,
                child: const Text('Tümünü Temizle'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in queries)
                InputChip(
                  key: ValueKey('recent-product-search-$query'),
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(query),
                  onPressed: () => onSelected(query),
                  onDeleted: () => onRemoved(query),
                  deleteButtonTooltipMessage: '$query aramasını sil',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductsScrollView extends StatefulWidget {
  static const int priceBatchSize = 20;

  final ScrollController controller;
  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final SearchResultsShopProductsLoader? shopProductsLoader;
  final Widget? footer;

  const _ProductsScrollView({
    required this.controller,
    required this.products,
    this.currentUserIdProvider,
    this.shopProductsLoader,
    this.footer,
  });

  @override
  State<_ProductsScrollView> createState() => _ProductsScrollViewState();
}

class _ProductsScrollViewState extends State<_ProductsScrollView> {
  final Map<String, double> _minimumPrices = <String, double>{};
  final Set<String> _requestedProductIds = <String>{};
  final Set<String> _loadingProductIds = <String>{};
  var _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    _requestMissingPrices();
  }

  @override
  void didUpdateWidget(covariant _ProductsScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProductIds = oldWidget.products
        .map((product) => product.id)
        .toList(growable: false);
    final productIds = widget.products
        .map((product) => product.id)
        .toList(growable: false);
    final isAppend =
        productIds.length >= oldProductIds.length &&
        _hasPrefix(productIds, oldProductIds);
    if (oldWidget.shopProductsLoader != widget.shopProductsLoader ||
        !isAppend) {
      _requestGeneration++;
      _minimumPrices.clear();
      _requestedProductIds.clear();
      _loadingProductIds.clear();
    }
    _requestMissingPrices();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: TSizes.gridViewSpacing,
            crossAxisSpacing: TSizes.gridViewSpacing,
            mainAxisExtent: 288,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = widget.products[index];
            return VerticalProductCard(
              product: product,
              showFavoriteAction: true,
              currentUserIdProvider: widget.currentUserIdProvider,
              priceLabel: _sellerPriceLabel(
                product.id,
                _minimumPrices,
                _loadingProductIds.contains(product.id),
              ),
              showCatalogDiscount: false,
            );
          }, childCount: widget.products.length),
        ),
        SliverToBoxAdapter(
          child: widget.footer ?? const SizedBox(height: TSizes.defaultSpace),
        ),
      ],
    );
  }

  void _requestMissingPrices() {
    final missingProductIds = widget.products
        .map((product) => product.id)
        .where((productId) => _requestedProductIds.add(productId))
        .toList(growable: false);
    if (missingProductIds.isEmpty) return;

    _loadingProductIds.addAll(missingProductIds);
    final generation = _requestGeneration;
    for (
      var start = 0;
      start < missingProductIds.length;
      start += _ProductsScrollView.priceBatchSize
    ) {
      final proposedEnd = start + _ProductsScrollView.priceBatchSize;
      final end = proposedEnd < missingProductIds.length
          ? proposedEnd
          : missingProductIds.length;
      unawaited(
        _loadPrices(
          missingProductIds.sublist(start, end),
          generation: generation,
        ),
      );
    }
  }

  Future<void> _loadPrices(
    List<String> productIds, {
    required int generation,
  }) async {
    Either<String, List<ShopProductEntity>> result;
    try {
      final loader = widget.shopProductsLoader;
      result = loader != null
          ? await loader(List.unmodifiable(productIds))
          : await sl<GetShopProductsByProductIdsUsecase>()(
              GetShopProductsByProductIdsParams(productIds: productIds),
            );
    } catch (_) {
      result = const Left('Mağaza fiyatları yüklenemedi.');
    }

    if (!mounted || generation != _requestGeneration) return;
    final requestedIds = productIds.toSet();
    final loadedPrices = result.fold(
      (_) => const <String, double>{},
      _minimumPurchasablePrices,
    );
    setState(() {
      _loadingProductIds.removeAll(productIds);
      for (final entry in loadedPrices.entries) {
        if (requestedIds.contains(entry.key)) {
          _minimumPrices[entry.key] = entry.value;
        }
      }
    });
  }

  bool _hasPrefix(List<String> productIds, List<String> prefix) {
    for (var index = 0; index < prefix.length; index++) {
      if (productIds[index] != prefix[index]) return false;
    }
    return true;
  }
}

class _ProductsLoadMoreFooter extends StatelessWidget {
  final ProductsLoaded state;
  final VoidCallback onRetry;

  const _ProductsLoadMoreFooter({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: TSizes.spaceBtwItems),
        child: Column(
          children: [
            const Text(
              'Diğer ürünler yüklenemedi.',
              textAlign: TextAlign.center,
            ),
            TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    return const SizedBox(height: TSizes.defaultSpace);
  }
}
