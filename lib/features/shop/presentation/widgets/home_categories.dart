import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/horizontal_small_list_view_item_view_model.dart';
import 'package:t_store/core/common/widgets/horizontal_small_list_view.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  static String _normalizedName(String name) => name.trim().toLowerCase();

  static String _localizedTitle(String name) {
    return switch (_normalizedName(name)) {
      'electronics' || 'elektronik' => TTexts.homeCategoryTitles[0],
      'clothes' || 'clothing' || 'giyim' => TTexts.homeCategoryTitles[1],
      'shoes' || 'ayakkabı' => TTexts.homeCategoryTitles[2],
      'furniture' || 'mobilya' => TTexts.homeCategoryTitles[3],
      'accessories' || 'aksesuar' => TTexts.homeCategoryTitles[4],
      _ => name.trim(),
    };
  }

  static String _categoryIcon(String name, int fallbackIndex) {
    return switch (_normalizedName(name)) {
      'electronics' || 'elektronik' => TImages.homeCategoryIcons[0],
      'clothes' || 'clothing' || 'giyim' => TImages.homeCategoryIcons[1],
      'shoes' || 'ayakkabı' => TImages.homeCategoryIcons[2],
      'furniture' || 'mobilya' => TImages.homeCategoryIcons[3],
      'accessories' || 'aksesuar' => TImages.homeCategoryIcons[4],
      _ => TImages.categoryIcons[fallbackIndex % TImages.categoryIcons.length],
    };
  }

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
    const List<String> categoriesTitles = TTexts.homeCategoryTitles;
    const List<String> categoriesImages = TImages.homeCategoryIcons;

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
            final items = List.generate(state.categories.length, (index) {
              final category = state.categories[index];
              return HorizontalSmallListViewItemModel(
                categoryId: category.id,
                title: _localizedTitle(category.name),
                image: _categoryIcon(category.name, index),
              );
            });

            return HorizontalSmallListView(items: items);
          }

          return HorizontalSmallListView(items: fallbackItems);
        },
      ),
    );
  }
}
