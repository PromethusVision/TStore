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
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';

class SubCategoryView extends StatelessWidget {
  final String title;
  final String? categoryId;

  const SubCategoryView({
    super.key,
    required this.title,
    this.categoryId,
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

                      if (state is ProductsLoading || state is ProductsInitial) {
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

                        return SizedBox(
                          height: 128,
                          child: ListView.separated(
                            itemCount: state.products.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) =>
                                HorizontalProductCard(
                              product: state.products[index],
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: TSizes.spaceBtwItems),
                          ),
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
