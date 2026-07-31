import 'package:t_store/features/shop/domain/entities/category_entity.dart';

class CustomerCategoryPresentationHelper {
  const CustomerCategoryPresentationHelper._();

  static String normalizedName(String name) => name.trim().toLowerCase();

  static String localizedTitle(String name) {
    return switch (normalizedName(name)) {
      'electronics' || 'elektronik' => 'Elektronik',
      'clothes' || 'clothing' || 'giyim' => 'Giyim',
      'shoes' || 'ayakkabı' => 'Ayakkabı',
      'furniture' || 'mobilya' => 'Mobilya',
      'accessories' || 'aksesuar' => 'Aksesuar',
      'grocery' || 'groceries' || 'market' => 'Market',
      'greengrocer' || 'produce' || 'manav' => 'Manav',
      'bakery' || 'fırın' || 'firin' => 'Fırın',
      'butcher' || 'kasap' => 'Kasap',
      'cosmetics' || 'kozmetik' => 'Kozmetik',
      'home & living' || 'home and living' || 'ev & yaşam' => 'Ev & Yaşam',
      _ => name.trim(),
    };
  }

  static bool matchesSearch(CategoryEntity category, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return false;

    return [
      category.name,
      localizedTitle(category.name),
      category.description ?? '',
    ].any((value) => value.toLowerCase().contains(normalizedQuery));
  }
}
