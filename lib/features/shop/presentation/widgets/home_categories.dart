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
    return SizedBox(
      height: 100,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return const Center(
              child: SizedBox(
                key: Key('home-categories-loading'),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (state is CategoriesError) {
            return Center(
              child: TextButton(
                key: const Key('home-categories-retry'),
                onPressed: context.read<CategoriesCubit>().getCategories,
                child: const Text('Kategorileri Tekrar Yükle'),
              ),
            );
          }

          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                child: Text('Şu anda gösterilecek kategori bulunamadı.'),
              );
            }

            final items = List.generate(state.categories.length, (index) {
              final category = state.categories[index];
              final imageUrl = category.imageUrl?.trim() ?? '';
              return HorizontalSmallListViewItemModel(
                categoryId: category.id,
                title: _localizedTitle(category.name),
                image: imageUrl.isNotEmpty
                    ? imageUrl
                    : _categoryIcon(category.name, index),
                isNetworkImage: imageUrl.isNotEmpty,
              );
            });

            return HorizontalSmallListView(items: items);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
