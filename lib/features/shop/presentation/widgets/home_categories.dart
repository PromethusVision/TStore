import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/horizontal_small_list_view_item_view_model.dart';
import 'package:t_store/core/common/widgets/horizontal_small_list_view.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({
    super.key,
  });

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CategoriesCubit>();
    if (cubit.state is! CategoriesLoaded && cubit.state is! CategoriesLoading) {
      cubit.getCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<String> categoriesTitles = TTexts.categories;
    const List<String> categoriesImages = TImages.categoryIcons;

    final fallbackItems = List.generate(
      categoriesImages.length,
      (index) => HorizontalSmallListViewItemModel(
        title: categoriesTitles[index],
        image: categoriesImages[index],
      ),
    );

    return SizedBox(
      height: 100,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoaded && state.categories.isNotEmpty) {
            final items = List.generate(
              state.categories.length,
              (index) {
                final category = state.categories[index];
                return HorizontalSmallListViewItemModel(
                  categoryId: category.id,
                  title: category.name,
                  image: categoriesImages[index % categoriesImages.length],
                );
              },
            );

            return HorizontalSmallListView(items: items);
          }

          return HorizontalSmallListView(items: fallbackItems);
        },
      ),
    );
  }
}
