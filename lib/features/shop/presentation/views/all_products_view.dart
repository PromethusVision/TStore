import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class AllProductsView extends StatelessWidget {
  const AllProductsView({
    super.key,
    this.autoFocusSearch = false,
    this.isSearchMode = false,
    this.currentUserIdProvider,
    this.recentSearchesStorage,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String? Function()? currentUserIdProvider;
  final RecentProductSearchesStorage? recentSearchesStorage;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (_) => sl<ProductsCubit>(),
      child: _AllProductsContent(
        autoFocusSearch: autoFocusSearch,
        isSearchMode: isSearchMode,
        currentUserIdProvider: currentUserIdProvider,
        recentSearchesStorage:
            recentSearchesStorage ?? sl<RecentProductSearchesStorage>(),
      ),
    );
  }
}

class _AllProductsContent extends StatefulWidget {
  const _AllProductsContent({
    required this.autoFocusSearch,
    required this.isSearchMode,
    required this.recentSearchesStorage,
    this.currentUserIdProvider,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String? Function()? currentUserIdProvider;
  final RecentProductSearchesStorage recentSearchesStorage;

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

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }

    context.read<ProductsCubit>().getProducts(refresh: true);
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
    final title = widget.isSearchMode ? 'Ürün Ara' : 'Tüm Ürünler';

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
                  hintText: 'Tüm ürünlerde ara',
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
                child: BlocConsumer<ProductsCubit, ProductsState>(
                  listener: _handleProductsState,
                  builder: (context, state) {
                    if (state is ProductsLoading ||
                        state is ProductsInitial ||
                        state is ProductsSearching) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ProductsError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Ürünler yüklenemedi. Lütfen daha sonra tekrar deneyin.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            ElevatedButton(
                              onPressed: _reloadProducts,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
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
                        footer: _ProductsLoadMoreFooter(
                          state: state,
                          onRetry: _retryLoadMore,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();
    setState(() {});
    _scrollToTop();

    if (query.isEmpty) {
      _lastRequestedQuery = null;
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

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({
    required this.query,
    required this.onEditSearch,
    required this.onShowAllProducts,
  });

  final String query;
  final VoidCallback onEditSearch;
  final VoidCallback onShowAllProducts;

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
                    ? 'Aradığınız ürün bulunamadı.'
                    : '"$normalizedQuery" için ürün bulamadık.',
                key: const Key('empty-search-result-title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                'Daha kısa veya farklı bir kelimeyle yeniden arayabilirsiniz.',
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

class _ProductsScrollView extends StatelessWidget {
  final ScrollController controller;
  final List<ProductEntity> products;
  final String? Function()? currentUserIdProvider;
  final Widget? footer;

  const _ProductsScrollView({
    required this.controller,
    required this.products,
    this.currentUserIdProvider,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: TSizes.gridViewSpacing,
            crossAxisSpacing: TSizes.gridViewSpacing,
            mainAxisExtent: 288,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => VerticalProductCard(
              product: products[index],
              showFavoriteAction: true,
              currentUserIdProvider: currentUserIdProvider,
            ),
            childCount: products.length,
          ),
        ),
        SliverToBoxAdapter(
          child: footer ?? const SizedBox(height: TSizes.defaultSpace),
        ),
      ],
    );
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
