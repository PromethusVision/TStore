import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/helpers/customer_category_presentation_helper.dart';

typedef HomeSearchQuerySubmitted = void Function(String query);
typedef HomeSearchProductSelected = void Function(ProductEntity product);
typedef HomeSearchCategorySelected = void Function(CategoryEntity category);
typedef HomeSearchShopSelected = void Function(ShopEntity shop);

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.searchCubit,
    required this.onQuerySubmitted,
    required this.onProductSelected,
    required this.onCategorySelected,
    required this.onShopSelected,
    this.recentSearchesStorage,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.minimumQueryLength = 2,
  });

  final CustomerSearchCubit searchCubit;
  final HomeSearchQuerySubmitted onQuerySubmitted;
  final HomeSearchProductSelected onProductSelected;
  final HomeSearchCategorySelected onCategorySelected;
  final HomeSearchShopSelected onShopSelected;
  final RecentProductSearchesStorage? recentSearchesStorage;
  final Duration debounceDuration;
  final int minimumQueryLength;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _isDebouncing = false;
  bool _navigationLocked = false;
  bool _isLoadingRecentSearches = false;
  bool _recentSearchesLoadInProgress = false;
  List<String> _recentSearches = const [];

  bool get _shouldShowSuggestions =>
      _focusNode.hasFocus && _query.length >= widget.minimumQueryLength;

  bool get _shouldShowRecentSearches =>
      _focusNode.hasFocus &&
      _query.isEmpty &&
      (_isLoadingRecentSearches || _recentSearches.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
    unawaited(_loadRecentSearches());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: Column(
        key: const Key('home-search-autocomplete'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            key: const Key('home-search-bar'),
            color: Colors.white,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
                border: Border.all(color: CustomerHomeV1Tokens.border),
                boxShadow: CustomerHomeV1Tokens.softShadow,
              ),
              child: TextField(
                key: const Key('home-search-input'),
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                onChanged: _handleQueryChanged,
                onSubmitted: _submitQuery,
                onTapOutside: (_) => _focusNode.unfocus(),
                decoration: InputDecoration(
                  hintText: 'Ürün, kategori veya mağaza ara',
                  hintStyle: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: CustomerHomeV1Tokens.petrol,
                    size: 22,
                  ),
                  suffixIcon: _query.isEmpty
                      ? IconButton(
                          key: const Key('home-search-submit'),
                          tooltip: 'Arama sayfasını aç',
                          onPressed: null,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: CustomerHomeV1Tokens.muted,
                            size: 18,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: const Key('clear-home-search'),
                              tooltip: 'Aramayı temizle',
                              onPressed: _clearQuery,
                              icon: const Icon(Icons.close_rounded, size: 19),
                            ),
                            IconButton(
                              key: const Key('home-search-submit'),
                              tooltip: 'Tüm sonuçları gör',
                              onPressed: () => _submitQuery(_query),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: CustomerHomeV1Tokens.petrol,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: _shouldShowSuggestions || _shouldShowRecentSearches
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: CustomerHomeV1Tokens.space8,
                    ),
                    child: _query.isEmpty
                        ? _RecentSearchesCard(
                            isLoading: _isLoadingRecentSearches,
                            queries: _recentSearches,
                            onSelected: _selectRecentSearch,
                            onRemoved: _removeRecentSearch,
                            onClear: _clearRecentSearches,
                          )
                        : BlocBuilder<CustomerSearchCubit, CustomerSearchState>(
                            bloc: widget.searchCubit,
                            builder: (context, state) => _SuggestionsCard(
                              state: state,
                              query: _query,
                              isDebouncing: _isDebouncing,
                              onRetry: () => _runSearch(_query),
                              onViewAll: () => _submitQuery(_query),
                              onProductSelected: _selectProduct,
                              onCategorySelected: _selectCategory,
                              onShopSelected: _selectShop,
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus && _query.isEmpty) {
      unawaited(_loadRecentSearches());
    }
    if (mounted) setState(() {});
  }

  void _handleQueryChanged(String value) {
    final query = value.trim();
    _debounce?.cancel();

    if (query.length < widget.minimumQueryLength) {
      widget.searchCubit.reset();
      setState(() {
        _query = query;
        _isDebouncing = false;
      });
      if (query.isEmpty) unawaited(_loadRecentSearches());
      return;
    }

    setState(() {
      _query = query;
      _isDebouncing = true;
    });
    _debounce = Timer(widget.debounceDuration, () {
      if (!mounted || _controller.text.trim() != query) return;
      _runSearch(query);
    });
  }

  void _runSearch(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < widget.minimumQueryLength) return;

    setState(() => _isDebouncing = false);
    unawaited(widget.searchCubit.search(normalizedQuery));
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    widget.searchCubit.reset();
    setState(() {
      _query = '';
      _isDebouncing = false;
    });
    _focusNode.requestFocus();
    unawaited(_loadRecentSearches());
  }

  void _submitQuery(String value) {
    final query = value.trim();
    if (query.isEmpty || _navigationLocked) return;

    _debounce?.cancel();
    _navigationLocked = true;
    _focusNode.unfocus();
    unawaited(_recordCurrentQuery(query));
    widget.onQuerySubmitted(query);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigationLocked = false;
    });
  }

  void _selectProduct(ProductEntity product) {
    if (_navigationLocked) return;
    _navigationLocked = true;
    _focusNode.unfocus();
    unawaited(_recordCurrentQuery(_query));
    widget.onProductSelected(product);
    _unlockNavigationNextFrame();
  }

  void _selectCategory(CategoryEntity category) {
    if (_navigationLocked) return;
    _navigationLocked = true;
    _focusNode.unfocus();
    unawaited(_recordCurrentQuery(_query));
    widget.onCategorySelected(category);
    _unlockNavigationNextFrame();
  }

  void _selectShop(ShopEntity shop) {
    if (_navigationLocked) return;
    _navigationLocked = true;
    _focusNode.unfocus();
    unawaited(_recordCurrentQuery(_query));
    widget.onShopSelected(shop);
    _unlockNavigationNextFrame();
  }

  void _unlockNavigationNextFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigationLocked = false;
    });
  }

  Future<void> _loadRecentSearches() async {
    final storage = widget.recentSearchesStorage;
    if (storage == null || _recentSearchesLoadInProgress) return;

    _recentSearchesLoadInProgress = true;
    if (mounted) setState(() => _isLoadingRecentSearches = true);
    try {
      final queries = await storage.getQueries();
      if (!mounted) return;
      setState(() {
        _recentSearches = queries
            .take(RecentProductSearchesStorage.maximumQueryCount)
            .toList(growable: false);
      });
    } catch (_) {
      // Yerel arama geçmişi ana arama akışını engellememelidir.
    } finally {
      _recentSearchesLoadInProgress = false;
      if (mounted) setState(() => _isLoadingRecentSearches = false);
    }
  }

  Future<void> _recordCurrentQuery(String value) async {
    final storage = widget.recentSearchesStorage;
    final query = value.trim();
    if (storage == null || query.isEmpty) return;

    try {
      await storage.recordQuery(query);
    } catch (_) {
      // Yerel kayıt başarısız olsa bile arama ve yönlendirme çalışmaya devam eder.
    }
  }

  void _selectRecentSearch(String query) {
    _debounce?.cancel();
    _controller
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    setState(() {
      _query = query;
      _isDebouncing = false;
    });
    unawaited(_recordCurrentQuery(query));
    _runSearch(query);
  }

  Future<void> _removeRecentSearch(String query) async {
    final storage = widget.recentSearchesStorage;
    if (storage == null) return;

    try {
      await storage.removeQuery(query);
      if (!mounted) return;
      setState(() {
        _recentSearches = _recentSearches
            .where((item) => item.toLowerCase() != query.toLowerCase())
            .toList(growable: false);
      });
    } catch (_) {
      // Tek bir kayıt silinemese de arama alanı kullanılabilir kalmalıdır.
    }
  }

  Future<void> _clearRecentSearches() async {
    final storage = widget.recentSearchesStorage;
    if (storage == null) return;

    try {
      await storage.clear();
      if (!mounted) return;
      setState(() => _recentSearches = const []);
    } catch (_) {
      // Geçmiş temizlenemese de ana arama akışı çalışmaya devam etmelidir.
    }
  }
}

class _RecentSearchesCard extends StatelessWidget {
  const _RecentSearchesCard({
    required this.isLoading,
    required this.queries,
    required this.onSelected,
    required this.onRemoved,
    required this.onClear,
  });

  final bool isLoading;
  final List<String> queries;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemoved;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('home-recent-searches'),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      clipBehavior: Clip.antiAlias,
      child: isLoading && queries.isEmpty
          ? const _SuggestionStatus(
              key: Key('home-recent-searches-loading'),
              icon: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              message: 'Son aramalar yükleniyor...',
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 20,
                        color: CustomerHomeV1Tokens.petrol,
                      ),
                      const SizedBox(width: CustomerHomeV1Tokens.space8),
                      Expanded(
                        child: Text(
                          'Son Aramalar',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        key: const Key('clear-home-recent-searches'),
                        onPressed: onClear,
                        child: const Text('Tümünü temizle'),
                      ),
                    ],
                  ),
                ),
                for (var index = 0; index < queries.length; index++)
                  InkWell(
                    key: ValueKey('home-recent-search-$index'),
                    onTap: () => onSelected(queries[index]),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: 19,
                            color: CustomerHomeV1Tokens.muted,
                          ),
                          const SizedBox(width: CustomerHomeV1Tokens.space12),
                          Expanded(
                            child: Text(
                              queries[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            key: ValueKey('remove-home-recent-search-$index'),
                            tooltip: '${queries[index]} aramasını sil',
                            onPressed: () => onRemoved(queries[index]),
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
    );
  }
}

class _SuggestionsCard extends StatelessWidget {
  const _SuggestionsCard({
    required this.state,
    required this.query,
    required this.isDebouncing,
    required this.onRetry,
    required this.onViewAll,
    required this.onProductSelected,
    required this.onCategorySelected,
    required this.onShopSelected,
  });

  static const int _maximumProductSuggestions = 3;
  static const int _maximumCategorySuggestions = 2;
  static const int _maximumShopSuggestions = 2;

  final CustomerSearchState state;
  final String query;
  final bool isDebouncing;
  final VoidCallback onRetry;
  final VoidCallback onViewAll;
  final HomeSearchProductSelected onProductSelected;
  final HomeSearchCategorySelected onCategorySelected;
  final HomeSearchShopSelected onShopSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('home-search-suggestions'),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isDebouncing ||
        state is CustomerSearchInitial ||
        state is CustomerSearchLoading ||
        state is CustomerSearchLoaded &&
            (state as CustomerSearchLoaded).query != query) {
      return const _SuggestionStatus(
        key: Key('home-search-suggestions-loading'),
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        message: 'Öneriler hazırlanıyor...',
      );
    }

    if (state is CustomerSearchError) {
      return _SuggestionStatus(
        key: const Key('home-search-suggestions-error'),
        icon: const Icon(Icons.cloud_off_outlined),
        message: 'Öneriler yüklenemedi.',
        actionLabel: 'Tekrar Dene',
        onAction: onRetry,
      );
    }

    final loaded = state as CustomerSearchLoaded;
    if (loaded.isEmpty) {
      return _SuggestionStatus(
        key: const Key('home-search-suggestions-empty'),
        icon: const Icon(Icons.search_off_rounded),
        message: 'Bu aramayla eşleşen öneri bulunamadı.',
        actionLabel: 'Tüm sonuçları gör',
        onAction: onViewAll,
      );
    }

    final categories = loaded.categories
        .take(_maximumCategorySuggestions)
        .toList(growable: false);
    final products = loaded.products
        .take(_maximumProductSuggestions)
        .toList(growable: false);
    final shops = loaded.shops
        .take(_maximumShopSuggestions)
        .toList(growable: false);

    return ListView(
      key: const Key('home-search-suggestions-list'),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: [
        if (categories.isNotEmpty) ...[
          const _SuggestionSectionTitle('Kategoriler'),
          for (final category in categories)
            _SuggestionTile(
              key: ValueKey('home-category-suggestion-${category.id}'),
              icon: Icons.category_outlined,
              title: CustomerCategoryPresentationHelper.localizedTitle(
                category.name,
              ),
              subtitle: 'Kategori',
              onTap: () => onCategorySelected(category),
            ),
        ],
        if (products.isNotEmpty) ...[
          const _SuggestionSectionTitle('Ürünler'),
          for (final product in products)
            _SuggestionTile(
              key: ValueKey('home-product-suggestion-${product.id}'),
              icon: Icons.inventory_2_outlined,
              title: product.name,
              subtitle:
                  '${product.effectivePrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
              onTap: () => onProductSelected(product),
            ),
        ],
        if (shops.isNotEmpty) ...[
          const _SuggestionSectionTitle('Mağazalar'),
          for (final shop in shops)
            _SuggestionTile(
              key: ValueKey('home-shop-suggestion-${shop.id}'),
              icon: Icons.storefront_outlined,
              title: shop.name,
              subtitle: shop.address?.trim().isNotEmpty == true
                  ? shop.address!.trim()
                  : 'Mağaza profilini görüntüle',
              onTap: () => onShopSelected(shop),
            ),
        ],
        const Divider(height: 1),
        TextButton.icon(
          key: const Key('view-all-home-search-results'),
          onPressed: onViewAll,
          icon: const Icon(Icons.search_rounded, size: 18),
          label: Text('“$query” için tüm sonuçları gör'),
        ),
      ],
    );
  }
}

class _SuggestionSectionTitle extends StatelessWidget {
  const _SuggestionSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: CustomerHomeV1Tokens.petrol,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CustomerHomeV1Tokens.mint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: CustomerHomeV1Tokens.petrol),
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: CustomerHomeV1Tokens.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionStatus extends StatelessWidget {
  const _SuggestionStatus({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(child: Text(message)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
