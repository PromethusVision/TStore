import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/grid_layout_view_model.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/widgets/grid_layout.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class AllProductsView extends StatefulWidget {
  const AllProductsView({
    super.key,
    this.autoFocusSearch = false,
    this.isSearchMode = false,
  });

  final bool autoFocusSearch;
  final bool isSearchMode;

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final productsCubit = context.read<ProductsCubit>();
    final state = productsCubit.state;

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }

    if (state is ProductsInitial ||
        (state is ProductsLoaded && state.products.isEmpty)) {
      productsCubit.getProducts(refresh: true);
    }
  }

  @override
  void dispose() {
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

                      return SingleChildScrollView(
                        child: _ProductsGrid(products: state.products),
                      );
                    }

                    if (state is ProductsLoaded) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('Ürün bulunamadı.'));
                      }

                      return SingleChildScrollView(
                        child: _ProductsGrid(products: state.products),
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

    if (query.isEmpty) {
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    context.read<ProductsCubit>().searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<ProductsCubit>().getProducts(refresh: true);
  }

  void _reloadProducts() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      context.read<ProductsCubit>().getProducts(refresh: true);
      return;
    }

    context.read<ProductsCubit>().searchProducts(query);
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridLayout(
      gridLayoutModel: GridLayoutModel(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return VerticalProductCard(
            product: products[index],
          );
        },
        mainAxisExtent: 288,
      ),
    );
  }
}
