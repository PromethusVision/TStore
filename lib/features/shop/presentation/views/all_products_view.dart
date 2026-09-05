import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/shop/presentation/widgets/product_image_fallback.dart';
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
import 'package:t_store/features/shop/presentation/helpers/taxonomy_category_destination.dart';
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

    return EsnaftaVarScaffold(
      safeAreaBottom: true,
      body: Builder(
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EsnaftaVarSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: EsnaftaVarSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        EsnaftaVarSurfaceIconButton(
                          buttonKey: const Key('all-products-back-button'),
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Geri',
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const SizedBox(width: EsnaftaVarSpacing.sm),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: EsnaftaVarSectionHeader(title: title),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomerLightInputTheme(
                    child: TextFormField(
                      key: const Key('all-products-search-field'),
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      autofocus: widget.autoFocusSearch,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: widget.isSearchMode
                            ? 'Ürün, kategori veya mağaza ara'
                            : 'Tüm ürünlerde ara',
                        hintStyle: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: EsnaftaVarColors.textMuted),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: EsnaftaVarColors.primary,
                        ),
                        suffixIcon: _searchController.text.trim().isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Aramayı temizle',
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor: EsnaftaVarColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: EsnaftaVarSpacing.md,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EsnaftaVarRadii.large,
                          ),
                          borderSide: const BorderSide(
                            color: EsnaftaVarColors.borderDefault,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EsnaftaVarRadii.large,
                          ),
                          borderSide: const BorderSide(
                            color: EsnaftaVarColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                      onFieldSubmitted: _submitSearch,
                    ),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.md),
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

  Widget? get _recentSearchesHeader => _shouldShowRecentSearches
      ? Padding(
          padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xl),
          child: _RecentSearchesSection(
            queries: _recentSearches,
            onSelected: _selectRecentSearch,
            onRemoved: _removeRecentSearch,
            onClear: _clearRecentSearches,
          ),
        )
      : null;

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
          warningMessage: state.warningMessage,
          onRetry: _reloadProducts,
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
        header: _recentSearchesHeader,
        title: _searchController.text.trim().isEmpty
            ? 'Tüm Ürünler'
            : 'Arama sonuçları',
      );
    }

    if (state is ProductsError) {
      return _AllProductsStatusView(
        key: const Key('all-products-error'),
        header: _recentSearchesHeader,
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
        header: _recentSearchesHeader,
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
        return _AllProductsStatusView(
          key: const Key('all-products-empty'),
          header: _recentSearchesHeader,
          icon: Icons.inventory_2_outlined,
          title: 'Henüz ürün bulunmuyor',
          message: 'Yeni ürünler eklendiğinde burada görünecek.',
        );
      }

      return _ProductsScrollView(
        header: _recentSearchesHeader,
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
  Widget build(BuildContext context) => _AllProductsStatusView(
    key: const Key('retry-customer-search'),
    icon: Icons.cloud_off_rounded,
    title: 'Arama tamamlanamadı',
    message: message,
    actionLabel: 'Tekrar Dene',
    onRetry: onRetry,
  );
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.md),
            child: EsnaftaVarSectionHeader(
              key: const Key('customer-search-summary'),
              title: 'Arama sonuçları',
              subtitle:
                  '${state.products.length} ürün · ${state.categories.length} kategori · ${state.shops.length} mağaza',
            ),
          ),
        ),
        if (state.warningMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.md),
              child: EsnaftaVarStateCard(
                key: const Key('customer-search-warning'),
                icon: Icons.info_outline_rounded,
                title: 'Bazı sonuçlar eksik',
                message: state.warningMessage!,
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
              padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xl),
              child: Wrap(
                spacing: EsnaftaVarSpacing.xs,
                runSpacing: EsnaftaVarSpacing.xs,
                children: [
                  for (final category in state.categories)
                    ActionChip(
                      key: ValueKey('customer-search-category-${category.id}'),
                      avatar: const Icon(
                        Icons.category_outlined,
                        size: EsnaftaVarIconSizes.small,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      visualDensity: VisualDensity.standard,
                      backgroundColor: EsnaftaVarColors.surfaceElevated,
                      side: const BorderSide(
                        color: EsnaftaVarColors.borderDefault,
                      ),
                      label: Text(
                        CustomerCategoryPresentationHelper.localizedTitle(
                          category.name,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed:
                          category.id.trim().isEmpty ||
                              !state.canOpenCategory(category.id)
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
                const SizedBox(height: EsnaftaVarSpacing.md / 2),
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
            child: SizedBox(height: EsnaftaVarSpacing.xl),
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
        const SliverToBoxAdapter(child: SizedBox(height: EsnaftaVarSpacing.xl)),
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
      Widget? destination;
      final destinationOverride = categoryDestinationBuilder;
      if (destinationOverride != null) {
        destination = destinationOverride(category);
      } else {
        final searchCubit = context.read<CustomerSearchCubit>();
        final canonicalResult = searchCubit.canonicalResultFor(categoryId);
        if (canonicalResult != null) {
          destination = buildCanonicalTaxonomyDestination(
            category: canonicalResult.matchedCategory,
            breadcrumb: canonicalResult.breadcrumb,
            repository: searchCubit.activeCanonicalRepository,
            capability: searchCubit.taxonomyCapability,
          );
          if (destination == null) return;
        } else {
          destination = SubCategoryView(
            title: CustomerCategoryPresentationHelper.localizedTitle(
              category.name,
            ),
            categoryId: categoryId,
          );
        }
      }
      final resolvedDestination = destination;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => resolvedDestination),
      );
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: EsnaftaVarSpacing.sm,
            crossAxisSpacing: EsnaftaVarSpacing.sm,
            mainAxisExtent: _CatalogGridLayout(context).cardExtent,
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
  Widget build(BuildContext context) => EsnaftaVarSectionHeader(
    key: const Key('all-products-summary'),
    title: title,
    subtitle: subtitle,
  );
}

/// Matches the integrated Product Listing image proportions while allocating
/// real scaled-text space. Both catalog and search consume this layout.
class _CatalogGridLayout {
  _CatalogGridLayout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width.clamp(0.0, 430.0);
    imageHeight = (((width - 44) / 2) * .81).clamp(116.0, 144.0);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    cardExtent = imageHeight + 148 * scale.clamp(1.0, double.infinity);
  }
  late final double imageHeight;
  late final double cardExtent;
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
    final layout = _CatalogGridLayout(context);
    final theme = Theme.of(context);
    final secondaryText = _secondaryText;
    return Material(
      key: Key('all-products-product-${product.id}'),
      color: EsnaftaVarColors.surfaceElevated,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
      child: InkWell(
        key: Key('all-products-product-link-${product.id}'),
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
                height: layout.imageHeight,
                width: double.infinity,
                child: ColoredBox(
                  color: EsnaftaVarColors.surfaceAlt,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.all(EsnaftaVarSpacing.xs),
                          child: _AllProductsProductImage(product: product),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: MergeSemantics(
                          child: ProductFavoriteButton(
                            productId: product.id,
                            keyPrefix: 'all-products-favorite-${product.id}',
                            currentUserIdProvider: currentUserIdProvider,
                            height: EsnaftaVarTouchTargets.minimum,
                            width: EsnaftaVarTouchTargets.minimum,
                            iconSize: EsnaftaVarIconSizes.medium,
                            backgroundColor: EsnaftaVarColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: product.name,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (secondaryText != null) ...[
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        Text(
                          secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: EsnaftaVarColors.textMuted,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        'Mağaza fiyatı',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: EsnaftaVarColors.primary,
                        ),
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      Text(
                        priceLabel,
                        key: Key('all-products-price-${product.id}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: EsnaftaVarColors.price,
                          fontSize: 14,
                          height: 1.2,
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
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _AllProductsProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
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
  Widget build(BuildContext context) => const ProductImageFallback();
}

class _AllProductsLoadingView extends StatelessWidget {
  const _AllProductsLoadingView({required this.title, this.header});
  final String title;
  final Widget? header;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const Key('all-products-loading'),
    slivers: [
      if (header != null) SliverToBoxAdapter(child: header),
      SliverToBoxAdapter(
        child: Semantics(
          liveRegion: true,
          child: EsnaftaVarStateCard(
            icon: Icons.hourglass_top_rounded,
            title: title,
            message: 'Sonuçlar hazırlanıyor',
          ),
        ),
      ),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.md),
          child: LinearProgressIndicator(semanticsLabel: 'Yükleniyor'),
        ),
      ),
    ],
  );
}

class _AllProductsStatusView extends StatelessWidget {
  const _AllProductsStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.header,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final Widget? header;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      if (header != null) SliverToBoxAdapter(child: header),
      SliverToBoxAdapter(
        child: Semantics(
          liveRegion: true,
          child: EsnaftaVarStateCard(
            icon: icon,
            title: title,
            message: message,
            actionLabel: actionLabel,
            onAction: onRetry,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: EsnaftaVarSpacing.xl)),
    ],
  );
}

class _SearchSectionTitle extends StatelessWidget {
  const _SearchSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.md),
      child: EsnaftaVarSectionHeader(title: title),
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
    final theme = Theme.of(context);
    final address = shop.address?.trim();
    return Material(
      color: EsnaftaVarColors.surfaceElevated,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        side: const BorderSide(color: EsnaftaVarColors.borderDefault),
      ),
      child: InkWell(
        key: Key('customer-search-shop-link-${shop.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: EsnaftaVarTouchTargets.minimum,
                height: EsnaftaVarTouchTargets.minimum,
                decoration: BoxDecoration(
                  color: EsnaftaVarColors.primarySoft,
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: EsnaftaVarColors.primary,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: shop.name,
                      child: Text(
                        shop.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      address == null || address.isEmpty
                          ? 'Adres bilgisi paylaşılmamış'
                          : address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: EsnaftaVarColors.textSecondary,
                      ),
                    ),
                    if (shop.ratingCount > 0) ...[
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: EsnaftaVarIconSizes.small,
                            color: EsnaftaVarColors.warning,
                          ),
                          const SizedBox(width: EsnaftaVarSpacing.xxs),
                          Expanded(
                            child: Text(
                              '${shop.rating.toStringAsFixed(1)} (${shop.ratingCount})',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: EsnaftaVarIconSizes.medium,
                color: EsnaftaVarColors.textMuted,
              ),
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
    this.warningMessage,
    this.onRetry,
  });
  final String query;
  final VoidCallback onEditSearch;
  final VoidCallback onShowAllProducts;
  final bool isUnifiedSearch;
  final String? warningMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    final title = normalizedQuery.isEmpty
        ? isUnifiedSearch
              ? 'Aradığınız sonuç bulunamadı.'
              : 'Aradığınız ürün bulunamadı.'
        : isUnifiedSearch
        ? '"$normalizedQuery" için sonuç bulamadık.'
        : '"$normalizedQuery" için ürün bulamadık.';
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.xl),
      child: Column(
        children: [
          EsnaftaVarStateCard(
            key: const Key('empty-search-result-title'),
            icon: warningMessage == null
                ? Icons.search_off_rounded
                : Icons.cloud_off_rounded,
            title: warningMessage == null ? title : 'Sonuçlar tam yüklenemedi',
            message: warningMessage == null
                ? isUnifiedSearch
                      ? 'Ürün, kategori veya mağaza adıyla yeniden arayabilirsiniz.'
                      : 'Daha kısa veya farklı bir kelimeyle yeniden arayabilirsiniz.'
                : 'Aramanın bir kısmı yüklenemedi. Sonuçları kontrol etmek için yeniden deneyebilirsin.',
            actionLabel: warningMessage == null ? null : 'Tekrar Dene',
            onAction: onRetry,
          ),
          const SizedBox(height: EsnaftaVarSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('edit-empty-product-search'),
              onPressed: onEditSearch,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Aramayı Düzenle'),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
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
  Widget build(BuildContext context) => Column(
    key: const Key('recent-product-searches-section'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Semantics(
            header: true,
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
      Material(
        color: EsnaftaVarColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          side: const BorderSide(color: EsnaftaVarColors.borderDefault),
        ),
        child: Column(
          children: [
            for (final query in queries)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: ValueKey('recent-product-search-$query'),
                      onTap: () => onSelected(query),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: EsnaftaVarTouchTargets.preferred,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: EsnaftaVarSpacing.sm,
                            vertical: EsnaftaVarSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: EsnaftaVarIconSizes.medium,
                                color: EsnaftaVarColors.textMuted,
                              ),
                              const SizedBox(width: EsnaftaVarSpacing.xs),
                              Expanded(
                                child: Text(
                                  query,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '$query aramasını sil',
                    onPressed: () => onRemoved(query),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: EsnaftaVarIconSizes.medium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
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
  final Widget? header;

  const _ProductsScrollView({
    required this.controller,
    required this.products,
    required this.summaryTitle,
    this.currentUserIdProvider,
    this.productDestinationBuilder,
    this.shopProductsLoader,
    this.footer,
    this.header,
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: EsnaftaVarSpacing.md),
            child: _AllProductsSummary(
              title: widget.summaryTitle,
              subtitle: '${widget.products.length} ürün gösteriliyor',
            ),
          ),
        ),
        SliverGrid(
          key: const Key('all-products-grid'),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: EsnaftaVarSpacing.sm,
            crossAxisSpacing: EsnaftaVarSpacing.sm,
            mainAxisExtent: _CatalogGridLayout(context).cardExtent,
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
          child: widget.footer ?? const SizedBox(height: EsnaftaVarSpacing.xl),
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
        key: Key('all-products-loading-more'),
        padding: EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.md),
        child: LinearProgressIndicator(
          semanticsLabel: 'Diğer ürünler yükleniyor',
        ),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.md),
        child: EsnaftaVarStateCard(
          key: const Key('all-products-load-more-error'),
          icon: Icons.cloud_off_rounded,
          title: 'Diğer ürünler yüklenemedi.',
          message:
              'Gösterilen ürünleri inceleyebilir veya yeniden deneyebilirsin.',
          actionLabel: 'Tekrar Dene',
          onAction: onRetry,
        ),
      );
    }
    return const SizedBox(height: EsnaftaVarSpacing.xl);
  }
}
