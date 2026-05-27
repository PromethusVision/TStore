import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/horizontal_small_list_view_item_view_model.dart';
import 'package:t_store/core/common/widgets/horizontal_small_list_view.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> categoriesTitles = TTexts.categories;
    const List<String> categoriesImages = TImages.categoryIcons;

    final List<HorizontalSmallListViewItemModel> fallbackItems = List.generate(
        categoriesImages.length,
        (index) => HorizontalSmallListViewItemModel(
              title: categoriesTitles[index],
              image: categoriesImages[index],
            ));
    final categoriesState = context.watch<CategoriesCubit>().state;
    final List<HorizontalSmallListViewItemModel> items =
        categoriesState is CategoriesLoaded && categoriesState.categories.isNotEmpty
            ? List.generate(
                categoriesState.categories.length,
                (index) {
                  final category = categoriesState.categories[index];
                  return HorizontalSmallListViewItemModel(
                    categoryId: category.id,
                    title: category.name,
                    image: categoriesImages[index % categoriesImages.length],
                  );
                },
              )
            : fallbackItems;

    return SizedBox(
      height: 100,
      child: HorizontalSmallListView(items: items),
    );
  }
}
