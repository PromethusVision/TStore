import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class AllProductsView extends StatelessWidget {
  const AllProductsView({
    super.key,
    this.autoFocusSearch = false,
    this.isSearchMode = false,
    this.currentUserIdProvider,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String? Function()? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (_) => sl<ProductsCubit>(),
      child: _AllProductsContent(
        autoFocusSearch: autoFocusSearch,
        isSearchMode: isSearchMode,
        currentUserIdProvider: currentUserIdProvider,
      ),
    );
  }
}

class _AllProductsContent extends StatefulWidget {
  const _AllProductsContent({
    required this.autoFocusSearch,
    required this.isSearchMode,
    this.currentUserIdProvider,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;
  final String? Function()? currentUserIdProvider;

  @override
  State<_AllProductsContent> createState() => _AllProductsContentState();
}

class _AllProductsContentState extends State<_AllProductsContent> {
  static const double _loadMoreThreshold = 400;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

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
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Expanded(
                child: BlocBuilder<ProductsCubit, ProductsState>(
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
                        return const Center(
                          child: Text('Aradığınız ürün bulunamadı.'),
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
    setState(() {});
    _scrollToTop();

    if (query.isEmpty) {
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    context.read<ProductsCubit>().searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    _scrollToTop();
    context.read<ProductsCubit>().getProducts(refresh: true);
  }

  void _reloadProducts() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _scrollToTop();
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    context.read<ProductsCubit>().searchProducts(query);
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
