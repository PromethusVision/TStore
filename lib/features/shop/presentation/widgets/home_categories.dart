import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/helpers/taxonomy_category_destination.dart';
import 'package:t_store/features/shop/presentation/views/sub_category_view.dart';

typedef HomeCategoryDestinationBuilder =
    Widget Function(CategoryEntity category, String localizedTitle);
typedef HomeCanonicalCategoryDestinationBuilder =
    Widget Function(TaxonomyCategoryNode category);

class HomeCategories extends StatefulWidget {
  const HomeCategories({
    super.key,
    this.destinationBuilder,
    this.canonicalDestinationBuilder,
    this.visualPrototype = false,
  });

  final HomeCategoryDestinationBuilder? destinationBuilder;
  final HomeCanonicalCategoryDestinationBuilder? canonicalDestinationBuilder;
  final bool visualPrototype;

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  final Set<String> _openingCategoryIds = {};

  static const _pastelSurfaces = CustomerHomeV1Tokens.categorySurfaces;

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
    final usesScaledText = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    return Column(
      key: const Key('home-categories'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoriler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CustomerHomeV1Tokens.navy,
            fontWeight: widget.visualPrototype ? FontWeight.w700 : null,
          ),
        ),
        if (!widget.visualPrototype) ...[
          const SizedBox(height: CustomerHomeV1Tokens.space4),
          Text(
            'Mahallende aradığını kolayca bul',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: CustomerHomeV1Tokens.muted),
          ),
        ],
        const SizedBox(height: CustomerHomeV1Tokens.space8),
        SizedBox(
          height: widget.visualPrototype
              ? usesScaledText
                    ? 132
                    : 108
              : 112,
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
                    final canonicalNode = state.canonicalNodeFor(categoryId);
                    return _HomeCategoryItem(
                      key: Key('home-category-${category.id}'),
                      category: category,
                      title: _localizedTitle(category.name),
                      fallbackIcon: _fallbackIcon(category.name, index),
                      backgroundColor:
                          _pastelSurfaces[index % _pastelSurfaces.length],
                      visualPrototype: widget.visualPrototype,
                      onTap: categoryId.isEmpty
                          ? null
                          : () => _openCategory(
                              context,
                              category,
                              canonicalNode: canonicalNode,
                            ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openCategory(
    BuildContext context,
    CategoryEntity category, {
    TaxonomyCategoryNode? canonicalNode,
  }) async {
    final categoryId = category.id.trim();
    if (categoryId.isEmpty || _openingCategoryIds.contains(categoryId)) return;

    final title = _localizedTitle(category.name);
    final normalizedCategory = category.copyWith(id: categoryId);
    _openingCategoryIds.add(categoryId);
    try {
      Widget? destination;
      final legacyOverride = widget.destinationBuilder;
      if (legacyOverride != null) {
        destination = legacyOverride(normalizedCategory, title);
      } else if (canonicalNode != null) {
        destination = widget.canonicalDestinationBuilder?.call(canonicalNode);
        if (destination == null) {
          final cubit = context.read<CategoriesCubit>();
          destination = buildCanonicalTaxonomyDestination(
            category: canonicalNode,
            repository: cubit.activeCanonicalRepository,
            capability: cubit.taxonomyCapability,
          );
        }
      } else {
        destination = SubCategoryView(categoryId: categoryId, title: title);
      }
      final resolvedDestination = destination;
      if (resolvedDestination == null) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => resolvedDestination),
      );
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
    required this.visualPrototype,
  });

  final CategoryEntity category;
  final String title;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl?.trim() ?? '';
    final imageUri = Uri.tryParse(imageUrl);
    final isNetworkImage =
        imageUri != null &&
        (imageUri.scheme == 'http' || imageUri.scheme == 'https');
    return SizedBox(
      width: visualPrototype ? 78 : 104,
      child: Semantics(
        button: onTap != null,
        label: '$title kategorisi',
        child: InkWell(
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: visualPrototype ? 1 : 4,
              vertical: 2,
            ),
            child: Column(
              children: [
                Container(
                  width: visualPrototype ? 72 : 52,
                  height: visualPrototype ? 72 : 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(
                      visualPrototype
                          ? CustomerHomeV1Tokens.radius20
                          : CustomerHomeV1Tokens.radius16,
                    ),
                    border: visualPrototype
                        ? Border.all(
                            color: EsnaftaVarColors.primary.withValues(
                              alpha: 0.10,
                            ),
                          )
                        : null,
                    boxShadow: visualPrototype ? EsnaftaVarElevation.xs : null,
                  ),
                  child: visualPrototype
                      ? _CategoryFallback(
                          icon: fallbackIcon,
                          visualPrototype: true,
                        )
                      : imageUrl.isEmpty
                      ? _CategoryFallback(
                          icon: fallbackIcon,
                          visualPrototype: visualPrototype,
                        )
                      : !isNetworkImage
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _CategoryFallback(
                            icon: fallbackIcon,
                            visualPrototype: visualPrototype,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => _CategoryFallback(
                            icon: fallbackIcon,
                            visualPrototype: visualPrototype,
                          ),
                          errorWidget: (_, _, _) => _CategoryFallback(
                            icon: fallbackIcon,
                            visualPrototype: visualPrototype,
                          ),
                        ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomerHomeV1Tokens.navy,
                      fontSize: 11,
                      height: visualPrototype ? 1.15 : 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFallback extends StatelessWidget {
  const _CategoryFallback({required this.icon, required this.visualPrototype});

  final IconData icon;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    if (visualPrototype) {
      return Center(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: EsnaftaVarColors.surface.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: EsnaftaVarColors.divider),
          ),
          child: Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 24),
        ),
      );
    }
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
