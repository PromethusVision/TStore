import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';
import 'package:t_store/features/wishlist/presentation/widgets/product_favorite_button.dart';

typedef CustomerCategoryDestinationBuilder =
    Widget Function(CategoryEntity category);
typedef CustomerShopDestinationBuilder = Widget Function(ShopEntity shop);
typedef CustomerProductDestinationBuilder =
    Widget Function(ProductEntity product);
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
    this.productDestinationBuilder,
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
  final CustomerProductDestinationBuilder? productDestinationBuilder;
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
      productDestinationBuilder: productDestinationBuilder,
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
    this.productDestinationBuilder,
    this.shopProductsLoader,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String initialQuery;
  final String? Function()? currentUserIdProvider;
  final RecentProductSearchesStorage recentSearchesStorage;
  final CustomerCategoryDestinationBuilder? categoryDestinationBuilder;
  final CustomerShopDestinationBuilder? shopDestinationBuilder;
  final CustomerProductDestinationBuilder? productDestinationBuilder;
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
  int _recentSearchesRequestId = 0;

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
      backgroundColor: CustomerHomeV1Tokens.cream,
      appBar: AppBar(
        backgroundColor: CustomerHomeV1Tokens.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('all-products-back-button'),
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
          style: const TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    key: const Key('all-products-search-field'),
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
                      hintStyle: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: CustomerHomeV1Tokens.petrol,
                      ),
                      suffixIcon: _searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Aramayı temizle',
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: CustomerHomeV1Tokens.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius16,
                        ),
                        borderSide: const BorderSide(
                          color: CustomerHomeV1Tokens.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius16,
                        ),
                        borderSide: const BorderSide(
                          color: CustomerHomeV1Tokens.petrol,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                    onFieldSubmitted: _submitSearch,
                  ),
                  if (_shouldShowRecentSearches) ...[
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    _RecentSearchesSection(
                      queries: _recentSearches,
                      onSelected: _selectRecentSearch,
                      onRemoved: _removeRecentSearch,
                      onClear: _clearRecentSearches,
                    ),
                  ],
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
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
        ),
      ),
    );
  }

  Widget _buildCustomerSearchState(
    BuildContext context,
    CustomerSearchState state,
  ) {
    if (state is CustomerSearchInitial || state is CustomerSearchLoading) {
      return const _AllProductsLoadingView(title: 'Arama sonuçları');
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
        productDestinationBuilder: widget.productDestinationBuilder,
        shopProductsLoader: widget.shopProductsLoader,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProductsState(BuildContext context, ProductsState state) {
    if (state is ProductsLoading ||
        state is ProductsInitial ||
        state is ProductsSearching) {
      return _AllProductsLoadingView(
        title: _searchController.text.trim().isEmpty
            ? 'Tüm Ürünler'
            : 'Arama sonuçları',
      );
    }

    if (state is ProductsError) {
      return _AllProductsStatusView(
        key: const Key('all-products-error'),
        icon: Icons.cloud_off_rounded,
        title: 'Ürünler yüklenemedi',
        message: 'Bağlantını kontrol edip tekrar deneyebilirsin.',
        actionLabel: 'Tekrar Dene',
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
        summaryTitle: 'Arama Sonuçları',
        currentUserIdProvider: widget.currentUserIdProvider,
        productDestinationBuilder: widget.productDestinationBuilder,
        shopProductsLoader: widget.shopProductsLoader,
      );
    }

    if (state is ProductsLoaded) {
      if (state.products.isEmpty) {
        return const _AllProductsStatusView(
          key: Key('all-products-empty'),
          icon: Icons.inventory_2_outlined,
          title: 'Henüz ürün bulunmuyor',
          message: 'Yeni ürünler eklendiğinde burada görünecek.',
        );
      }

      return _ProductsScrollView(
        controller: _scrollController,
        products: state.products,
        summaryTitle: 'Tüm Ürünler',
        currentUserIdProvider: widget.currentUserIdProvider,
        productDestinationBuilder: widget.productDestinationBuilder,
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

  Future<void> _loadRecentSearches({int? requestId}) async {
    final activeRequestId = requestId ?? ++_recentSearchesRequestId;
    try {
      final queries = await widget.recentSearchesStorage.getQueries();
      if (!mounted || activeRequestId != _recentSearchesRequestId) return;

      setState(() => _recentSearches = queries);
    } catch (_) {
      // Arama geçmişi ana ürün arama akışını engellememelidir.
    }
  }

  Future<void> _recordRecentSearch(String query) async {
    final requestId = ++_recentSearchesRequestId;
    try {
      await widget.recentSearchesStorage.recordQuery(query);
      if (!mounted || requestId != _recentSearchesRequestId) return;
      await _loadRecentSearches(requestId: requestId);
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
    final requestId = ++_recentSearchesRequestId;
    try {
      await widget.recentSearchesStorage.removeQuery(query);
      if (!mounted || requestId != _recentSearchesRequestId) return;
      await _loadRecentSearches(requestId: requestId);
    } catch (_) {
      // Tek bir geçmiş kaydı silinemese de ürün araması çalışmaya devam eder.
    }
  }

  Future<void> _clearRecentSearches() async {
    final requestId = ++_recentSearchesRequestId;
    try {
      await widget.recentSearchesStorage.clear();
      if (!mounted || requestId != _recentSearchesRequestId) return;

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

class _CustomerSearchResultsView extends StatefulWidget {
  const _CustomerSearchResultsView({
    required this.controller,
    required this.state,
    this.currentUserIdProvider,
    this.categoryDestinationBuilder,
    this.shopDestinationBuilder,
    this.productDestinationBuilder,
    this.shopProductsLoader,
  });

  final ScrollController controller;
  final CustomerSearchLoaded state;
  final String? Function()? currentUserIdProvider;
  final CustomerCategoryDestinationBuilder? categoryDestinationBuilder;
  final CustomerShopDestinationBuilder? shopDestinationBuilder;
  final CustomerProductDestinationBuilder? productDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  State<_CustomerSearchResultsView> createState() =>
      _CustomerSearchResultsViewState();
}

class _CustomerSearchResultsViewState
    extends State<_CustomerSearchResultsView> {
  final Set<String> _openingCategoryIds = {};
  final Set<String> _openingShopIds = {};

  ScrollController get controller => widget.controller;
  CustomerSearchLoaded get state => widget.state;
  String? Function()? get currentUserIdProvider => widget.currentUserIdProvider;
  CustomerCategoryDestinationBuilder? get categoryDestinationBuilder =>
      widget.categoryDestinationBuilder;
  CustomerShopDestinationBuilder? get shopDestinationBuilder =>
      widget.shopDestinationBuilder;
  CustomerProductDestinationBuilder? get productDestinationBuilder =>
      widget.productDestinationBuilder;
  SearchResultsShopProductsLoader? get shopProductsLoader =>
      widget.shopProductsLoader;

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
                      onPressed: category.id.trim().isEmpty
                          ? null
                          : () => _openCategory(context, category),
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
                onTap: !shop.isActive || shop.id.trim().isEmpty
                    ? null
                    : () => _openShop(context, shop),
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
            productDestinationBuilder: productDestinationBuilder,
            shopProductsLoader: shopProductsLoader,
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: TSizes.defaultSpace)),
      ],
    );
  }

  Future<void> _openCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final categoryId = category.id.trim();
    if (categoryId.isEmpty || _openingCategoryIds.contains(categoryId)) return;

    _openingCategoryIds.add(categoryId);
    try {
      final destination =
          categoryDestinationBuilder?.call(category) ??
          SubCategoryView(
            title: CustomerCategoryPresentationHelper.localizedTitle(
              category.name,
            ),
            categoryId: categoryId,
          );
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingCategoryIds.remove(categoryId);
    }
  }

  Future<void> _openShop(BuildContext context, ShopEntity shop) async {
    final shopId = shop.id.trim();
    if (!shop.isActive || shopId.isEmpty || _openingShopIds.contains(shopId)) {
      return;
    }

    _openingShopIds.add(shopId);
    try {
      final destination =
          shopDestinationBuilder?.call(shop) ??
          ShopProfileView(
            shop: shop,
            currentUserIdProvider: currentUserIdProvider,
          );
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingShopIds.remove(shopId);
    }
  }
}

class _SearchResultProductGrid extends StatefulWidget {
  const _SearchResultProductGrid({
    required this.products,
    required this.currentUserIdProvider,
    required this.productDestinationBuilder,
    required this.shopProductsLoader,
  });

  static const int maximumPricedProductCount = 30;

  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final CustomerProductDestinationBuilder? productDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;

  @override
  State<_SearchResultProductGrid> createState() =>
      _SearchResultProductGridState();
}

class _SearchResultProductGridState extends State<_SearchResultProductGrid> {
  late Future<Either<String, List<ShopProductEntity>>> _shopProductsFuture;
  final Set<String> _openingProductIds = {};

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
          key: const Key('customer-search-product-grid'),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: CustomerHomeV1Tokens.space12,
            crossAxisSpacing: CustomerHomeV1Tokens.space12,
            mainAxisExtent: 250,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = widget.products[index];
            return _AllProductsProductCard(
              product: product,
              currentUserIdProvider: widget.currentUserIdProvider,
              priceLabel: _sellerPriceLabel(
                product.id,
                minimumPrices,
                isPriceLoading,
              ),
              onTap: product.id.trim().isEmpty
                  ? null
                  : () => _openProduct(context, product),
            );
          }, childCount: widget.products.length),
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

class _AllProductsSummary extends StatelessWidget {
  const _AllProductsSummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('all-products-summary'),
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
              Icons.grid_view_rounded,
              color: CustomerHomeV1Tokens.petrol,
              size: 24,
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

class _AllProductsProductCard extends StatelessWidget {
  const _AllProductsProductCard({
    required this.product,
    required this.priceLabel,
    required this.currentUserIdProvider,
    required this.onTap,
  });

  final ProductEntity product;
  final String priceLabel;
  final String? Function()? currentUserIdProvider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final secondaryText = _secondaryText;
    return Material(
      key: Key('all-products-product-${product.id}'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        key: Key('all-products-product-link-${product.id}'),
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
                    _AllProductsProductImage(product: product),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ProductFavoriteButton(
                        productId: product.id,
                        keyPrefix: 'all-products-favorite-${product.id}',
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
                        key: Key('all-products-price-${product.id}'),
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

class _AllProductsProductImage extends StatelessWidget {
  const _AllProductsProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl;
    if (imageUrl == null) return const _AllProductsProductImageFallback();

    final uri = Uri.tryParse(imageUrl);
    final isNetwork =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isNetwork) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AllProductsProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _AllProductsProductImageFallback(),
      errorWidget: (_, _, _) => const _AllProductsProductImageFallback(),
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

class _AllProductsProductImageFallback extends StatelessWidget {
  const _AllProductsProductImageFallback();

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

class _AllProductsLoadingView extends StatelessWidget {
  const _AllProductsLoadingView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('all-products-loading'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: CustomerHomeV1Tokens.space16,
            ),
            child: _AllProductsSummary(
              title: title,
              subtitle: 'Ürünler hazırlanıyor',
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: CustomerHomeV1Tokens.space12,
            crossAxisSpacing: CustomerHomeV1Tokens.space12,
            mainAxisExtent: 250,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, _) => const _AllProductsProductSkeleton(),
            childCount: 6,
          ),
        ),
      ],
    );
  }
}

class _AllProductsProductSkeleton extends StatelessWidget {
  const _AllProductsProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 158,
            width: double.infinity,
            child: ColoredBox(color: CustomerHomeV1Tokens.mint),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 11,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CustomerHomeV1Tokens.border,
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radiusPill,
                    ),
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space8),
                Container(
                  height: 9,
                  width: 72,
                  decoration: BoxDecoration(
                    color: CustomerHomeV1Tokens.border,
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radiusPill,
                    ),
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

class _AllProductsStatusView extends StatelessWidget {
  const _AllProductsStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: CustomerHomeV1Tokens.mint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 28),
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
            if (actionLabel != null && onRetry != null) ...[
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              FilledButton(
                onPressed: onRetry,
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
    );
  }
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final address = shop.address?.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('customer-search-shop-link-${shop.id}'),
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
  final String summaryTitle;
  final String? Function()? currentUserIdProvider;
  final CustomerProductDestinationBuilder? productDestinationBuilder;
  final SearchResultsShopProductsLoader? shopProductsLoader;
  final Widget? footer;

  const _ProductsScrollView({
    required this.controller,
    required this.products,
    required this.summaryTitle,
    this.currentUserIdProvider,
    this.productDestinationBuilder,
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
  final Set<String> _openingProductIds = <String>{};
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: CustomerHomeV1Tokens.space16,
            ),
            child: _AllProductsSummary(
              title: widget.summaryTitle,
              subtitle: '${widget.products.length} ürün gösteriliyor',
            ),
          ),
        ),
        SliverGrid(
          key: const Key('all-products-grid'),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: CustomerHomeV1Tokens.space12,
            crossAxisSpacing: CustomerHomeV1Tokens.space12,
            mainAxisExtent: 250,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = widget.products[index];
            return _AllProductsProductCard(
              product: product,
              currentUserIdProvider: widget.currentUserIdProvider,
              priceLabel: _sellerPriceLabel(
                product.id,
                _minimumPrices,
                _loadingProductIds.contains(product.id),
              ),
              onTap: product.id.trim().isEmpty
                  ? null
                  : () => _openProduct(context, product),
            );
          }, childCount: widget.products.length),
        ),
        SliverToBoxAdapter(
          child: widget.footer ?? const SizedBox(height: TSizes.defaultSpace),
        ),
      ],
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
