import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

typedef HomeCategoryDestinationBuilder =
    Widget Function(CategoryEntity category, String localizedTitle);

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key, this.destinationBuilder});

  final HomeCategoryDestinationBuilder? destinationBuilder;

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  final Set<String> _openingCategoryIds = {};

  static const _pastelSurfaces = [
    CustomerHomeV1Tokens.mint,
    Color(0xFFE4F0E0),
    Color(0xFFFFEDD3),
    Color(0xFFFFE1DC),
    Color(0xFFF9DFDF),
    Color(0xFFDDEDEA),
  ];

  static String _normalizedName(String name) => name.trim().toLowerCase();

  static String _localizedTitle(String name) {
    return switch (_normalizedName(name)) {
      'electronics' || 'elektronik' => TTexts.homeCategoryTitles[0],
      'clothes' || 'clothing' || 'giyim' => TTexts.homeCategoryTitles[1],
      'shoes' || 'ayakkabı' => TTexts.homeCategoryTitles[2],
      'furniture' || 'mobilya' => TTexts.homeCategoryTitles[3],
      'accessories' || 'aksesuar' => TTexts.homeCategoryTitles[4],
      'grocery' || 'groceries' || 'market' => 'Market',
      'greengrocer' || 'produce' || 'manav' => 'Manav',
      'bakery' || 'fırın' || 'firin' => 'Fırın',
      'butcher' || 'kasap' => 'Kasap',
      'cosmetics' || 'kozmetik' => 'Kozmetik',
      'home & living' || 'home and living' || 'ev & yaşam' => 'Ev & Yaşam',
      _ => name.trim(),
    };
  }

  static IconData _fallbackIcon(String name, int fallbackIndex) {
    return switch (_normalizedName(name)) {
      'grocery' || 'groceries' || 'market' => Icons.shopping_basket_rounded,
      'greengrocer' || 'produce' || 'manav' => Icons.eco_rounded,
      'bakery' || 'fırın' || 'firin' => Icons.bakery_dining_rounded,
      'butcher' || 'kasap' => Icons.lunch_dining_rounded,
      'cosmetics' || 'kozmetik' => Icons.spa_rounded,
      'home & living' ||
      'home and living' ||
      'ev & yaşam' => Icons.chair_rounded,
      _ => const [
        Icons.shopping_basket_rounded,
        Icons.eco_rounded,
        Icons.bakery_dining_rounded,
        Icons.lunch_dining_rounded,
        Icons.spa_rounded,
        Icons.chair_rounded,
      ][fallbackIndex % 6],
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
      key: const Key('home-categories'),
      height: 75,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return const _CategoryStatus(
              key: Key('home-categories-loading'),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: CustomerHomeV1Tokens.petrol,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (state is CategoriesError) {
            return _CategoryStatus(
              child: TextButton.icon(
                key: const Key('home-categories-retry'),
                onPressed: context.read<CategoriesCubit>().getCategories,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Kategorileri Tekrar Yükle'),
              ),
            );
          }

          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return const _CategoryStatus(
                child: Text(
                  'Şu anda gösterilecek kategori bulunamadı.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 11,
                  ),
                ),
              );
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.categories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: CustomerHomeV1Tokens.space8),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final categoryId = category.id.trim();
                return _HomeCategoryItem(
                  key: Key('home-category-${category.id}'),
                  category: category,
                  title: _localizedTitle(category.name),
                  fallbackIcon: _fallbackIcon(category.name, index),
                  backgroundColor:
                      _pastelSurfaces[index % _pastelSurfaces.length],
                  onTap: categoryId.isEmpty
                      ? null
                      : () => _openCategory(context, category),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _openCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final categoryId = category.id.trim();
    if (categoryId.isEmpty || _openingCategoryIds.contains(categoryId)) return;

    final title = _localizedTitle(category.name);
    final normalizedCategory = category.copyWith(id: categoryId);
    _openingCategoryIds.add(categoryId);
    try {
      final destination =
          widget.destinationBuilder?.call(normalizedCategory, title) ??
          SubCategoryView(categoryId: categoryId, title: title);
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      _openingCategoryIds.remove(categoryId);
    }
  }
}

class _HomeCategoryItem extends StatelessWidget {
  const _HomeCategoryItem({
    super.key,
    required this.category,
    required this.title,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.onTap,
  });

  final CategoryEntity category;
  final String title;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl?.trim() ?? '';
    return SizedBox(
      width: 52,
      child: InkWell(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: imageUrl.isEmpty
                  ? _CategoryFallback(icon: fallbackIcon)
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          _CategoryFallback(icon: fallbackIcon),
                      errorWidget: (_, _, _) =>
                          _CategoryFallback(icon: fallbackIcon),
                    ),
            ),
            const SizedBox(height: CustomerHomeV1Tokens.space4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFallback extends StatelessWidget {
  const _CategoryFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: CustomerHomeV1Tokens.navy, size: 23);
  }
}

class _CategoryStatus extends StatelessWidget {
  const _CategoryStatus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(child: child);
  }
}
