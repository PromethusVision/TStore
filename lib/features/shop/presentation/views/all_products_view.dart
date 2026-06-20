import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/grid_layout_view_model.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/widgets/grid_layout.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class AllProductsView extends StatefulWidget {
  const AllProductsView({super.key});

  @override
  State<AllProductsView> createState() => _AllProductsViewState();
}

class _AllProductsViewState extends State<AllProductsView> {
  @override
  void initState() {
    super.initState();
    final productsCubit = context.read<ProductsCubit>();
    final state = productsCubit.state;

    if (state is ProductsInitial ||
        (state is ProductsLoaded && state.products.isEmpty)) {
      productsCubit.getProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel:
            AppBarModel(title: const Text("All Products"), hasArrowBack: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading || state is ProductsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductsError) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProductsCubit>()
                                .getProducts(refresh: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return GridLayout(
                    gridLayoutModel: GridLayoutModel(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        return VerticalProductCard(
                          product: state.products[index],
                        );
                      },
                      mainAxisExtent: 288,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
