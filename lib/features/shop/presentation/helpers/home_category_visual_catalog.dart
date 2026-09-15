import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/shop/presentation/helpers/category_symbols.dart';

/// The semantic visual used for a Home category.
///
/// Canonical visuals are deliberately resolved by category name instead of
/// list index. Taxonomy ordering can therefore never shift one category onto
/// another category's icon.
class HomeCategoryVisualSpec {
  const HomeCategoryVisualSpec({
    required this.categoryName,
    required this.icon,
    required this.assetLabel,
    required this.visualMeaning,
    this.isCanonical = true,
    this.tone = CategoryVisualTone.mint,
  });

  final String categoryName;
  final IconData icon;
  final String assetLabel;
  final String visualMeaning;
  final bool isCanonical;
  final CategoryVisualTone tone;

  Color get surfaceColor => switch (tone) {
    CategoryVisualTone.mint => CustomerHomeV1Tokens.categorySurfaces[0],
    CategoryVisualTone.sage => CustomerHomeV1Tokens.categorySurfaces[1],
    CategoryVisualTone.sand => CustomerHomeV1Tokens.categorySurfaces[2],
    CategoryVisualTone.coral => CustomerHomeV1Tokens.categorySurfaces[3],
    CategoryVisualTone.rose => CustomerHomeV1Tokens.categorySurfaces[4],
    CategoryVisualTone.teal => CustomerHomeV1Tokens.categorySurfaces[5],
  };
}

enum CategoryVisualTone { mint, sage, sand, coral, rose, teal }

abstract final class HomeCategoryVisualCatalog {
  static const canonicalVisuals = <HomeCategoryVisualSpec>[
    HomeCategoryVisualSpec(
      categoryName: 'Gıda & İçecek',
      icon: CategorySymbols.grocery,
      assetLabel: 'symbols-rounded:grocery',
      visualMeaning: 'meyve ve market alışverişi',
      tone: CategoryVisualTone.mint,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Giyim & Moda',
      icon: CategorySymbols.apparel,
      assetLabel: 'symbols-rounded:apparel',
      visualMeaning: 'tişört / giyim',
      tone: CategoryVisualTone.sage,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Ayakkabı',
      icon: CategorySymbols.steps,
      assetLabel: 'symbols-rounded:steps',
      visualMeaning: 'ayakkabı silüeti',
      tone: CategoryVisualTone.sand,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Çanta & Aksesuar',
      icon: CategorySymbols.shoppingBag,
      assetLabel: 'symbols-rounded:shopping_bag',
      visualMeaning: 'saplı çanta / aksesuar',
      tone: CategoryVisualTone.coral,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Elektronik',
      icon: CategorySymbols.devices,
      assetLabel: 'symbols-rounded:devices',
      visualMeaning: 'telefon ve elektronik ekranlar',
      tone: CategoryVisualTone.rose,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Bilgisayar & Tablet',
      icon: CategorySymbols.computer,
      assetLabel: 'symbols-rounded:computer',
      visualMeaning: 'bilgisayar ekranı',
      tone: CategoryVisualTone.teal,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Beyaz Eşya & Ev Aletleri',
      icon: CategorySymbols.kitchen,
      assetLabel: 'symbols-rounded:kitchen',
      visualMeaning: 'buzdolabı / ev aleti',
      tone: CategoryVisualTone.mint,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Ev & Yaşam',
      icon: CategorySymbols.chair,
      assetLabel: 'symbols-rounded:chair',
      visualMeaning: 'koltuk / ev yaşam alanı',
      tone: CategoryVisualTone.sage,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Züccaciye & Mutfak',
      icon: CategorySymbols.skillet,
      assetLabel: 'symbols-rounded:skillet',
      visualMeaning: 'tava / mutfak gereci',
      tone: CategoryVisualTone.sand,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Yapı, Hırdavat & Tesisat',
      icon: CategorySymbols.handyman,
      assetLabel: 'symbols-rounded:handyman',
      visualMeaning: 'çekiç ve anahtar / el aletleri',
      tone: CategoryVisualTone.coral,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Otomotiv & Motosiklet',
      icon: CategorySymbols.directionsCar,
      assetLabel: 'symbols-rounded:directions_car',
      visualMeaning: 'otomobil / motorlu araç',
      tone: CategoryVisualTone.rose,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kozmetik & Kişisel Bakım',
      icon: CategorySymbols.healthAndBeauty,
      assetLabel: 'symbols-rounded:health_and_beauty',
      visualMeaning: 'bakım şişesi / kozmetik',
      tone: CategoryVisualTone.teal,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Anne & Bebek',
      icon: CategorySymbols.childFriendly,
      assetLabel: 'symbols-rounded:child_friendly',
      visualMeaning: 'bebek arabası',
      tone: CategoryVisualTone.mint,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Oyuncak & Hobi',
      icon: CategorySymbols.toys,
      assetLabel: 'symbols-rounded:toys',
      visualMeaning: 'oyuncak araba',
      tone: CategoryVisualTone.sage,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Müzik & Enstrüman',
      icon: CategorySymbols.piano,
      assetLabel: 'symbols-rounded:piano',
      visualMeaning: 'piyano tuşları / enstrüman',
      tone: CategoryVisualTone.sand,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Spor & Outdoor',
      icon: CategorySymbols.fitnessCenter,
      assetLabel: 'symbols-rounded:fitness_center',
      visualMeaning: 'dambıl / spor ekipmanı',
      tone: CategoryVisualTone.coral,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kitap',
      icon: CategorySymbols.menuBook,
      assetLabel: 'symbols-rounded:menu_book',
      visualMeaning: 'açık kitap',
      tone: CategoryVisualTone.rose,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kırtasiye & Ofis',
      icon: CategorySymbols.editNote,
      assetLabel: 'symbols-rounded:edit_note',
      visualMeaning: 'kalem ve not satırları',
      tone: CategoryVisualTone.teal,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Evcil Hayvan Ürünleri',
      icon: CategorySymbols.pets,
      assetLabel: 'symbols-rounded:pets',
      visualMeaning: 'pati / evcil hayvan',
      tone: CategoryVisualTone.mint,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Gözlük & Optik',
      icon: CategorySymbols.eyeglasses,
      assetLabel: 'symbols-rounded:eyeglasses',
      visualMeaning: 'gözlük çerçevesi / optik',
      tone: CategoryVisualTone.sage,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Saat & Takı',
      icon: CategorySymbols.watch,
      assetLabel: 'symbols-rounded:watch',
      visualMeaning: 'kol saati / takı aksesuarı',
      tone: CategoryVisualTone.sand,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Sağlık & Medikal',
      icon: CategorySymbols.medicalServices,
      assetLabel: 'symbols-rounded:medical_services',
      visualMeaning: 'ilk yardım çantası / medikal ürün',
      tone: CategoryVisualTone.coral,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Çiçek & Bahçe',
      icon: CategorySymbols.pottedPlant,
      assetLabel: 'symbols-rounded:potted_plant',
      visualMeaning: 'saksıda bitki / çiçek ve bahçe',
      tone: CategoryVisualTone.rose,
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Hediyelik & Parti',
      icon: CategorySymbols.redeem,
      assetLabel: 'symbols-rounded:redeem',
      visualMeaning: 'kurdeleli hediye kutusu',
      tone: CategoryVisualTone.teal,
    ),
  ];

  static const unknownVisual = HomeCategoryVisualSpec(
    categoryName: 'Bilinmeyen kategori',
    icon: CategorySymbols.category,
    assetLabel: 'symbols-rounded:category',
    visualMeaning: 'nötr kategori işareti',
    isCanonical: false,
  );

  static final Map<String, HomeCategoryVisualSpec> _canonicalByName = {
    for (final visual in canonicalVisuals)
      _normalize(visual.categoryName): visual,
  };

  static HomeCategoryVisualSpec? canonicalForName(String categoryName) {
    return _canonicalByName[_normalize(categoryName)];
  }

  static HomeCategoryVisualSpec resolve({
    required String categoryId,
    required String categoryName,
  }) {
    final canonical = canonicalForName(categoryName);
    if (canonical != null) return canonical;

    final key = _normalize(categoryName);
    final id = _normalize(categoryId);
    return switch (key) {
      'electronics' ||
      'elektronik' => _canonicalByName[_normalize('Elektronik')]!,
      'clothes' ||
      'clothing' ||
      'giyim' => _canonicalByName[_normalize('Giyim & Moda')]!,
      'shoes' ||
      'ayakkabı' ||
      'ayakkabi' => _canonicalByName[_normalize('Ayakkabı')]!,
      'furniture' || 'mobilya' => _canonicalByName[_normalize('Ev & Yaşam')]!,
      'accessories' ||
      'aksesuar' => _canonicalByName[_normalize('Çanta & Aksesuar')]!,
      'grocery' ||
      'groceries' ||
      'gıda' ||
      'gida' ||
      'market' => _canonicalByName[_normalize('Gıda & İçecek')]!,
      'greengrocer' || 'produce' || 'manav' => const HomeCategoryVisualSpec(
        categoryName: 'Manav',
        icon: Icons.eco_rounded,
        assetLabel: 'material:eco_rounded',
        visualMeaning: 'yaprak / taze manav ürünü',
        isCanonical: false,
      ),
      'bakery' || 'fırın' || 'firin' => const HomeCategoryVisualSpec(
        categoryName: 'Fırın',
        icon: Icons.bakery_dining_rounded,
        assetLabel: 'material:bakery_dining_rounded',
        visualMeaning: 'fırın ürünü / ekmek',
        isCanonical: false,
      ),
      'butcher' || 'kasap' => const HomeCategoryVisualSpec(
        categoryName: 'Kasap',
        icon: Icons.lunch_dining_rounded,
        assetLabel: 'material:lunch_dining_rounded',
        visualMeaning: 'et ürünü',
        isCanonical: false,
      ),
      'spor' || 'sports' => _canonicalByName[_normalize('Spor & Outdoor')]!,
      'kirtasiye' => _canonicalByName[_normalize('Kırtasiye & Ofis')]!,
      'cosmetics' ||
      'kozmetik' => _canonicalByName[_normalize('Kozmetik & Kişisel Bakım')]!,
      'home & living' ||
      'home and living' ||
      'ev & yaşam' ||
      'ev-yasam' => _canonicalByName[_normalize('Ev & Yaşam')]!,
      _ => _resolveByStableAlias(id) ?? unknownVisual,
    };
  }

  static HomeCategoryVisualSpec? _resolveByStableAlias(String value) {
    const aliases = <String, String>{
      'gida-icecek': 'Gıda & İçecek',
      'giyim-moda': 'Giyim & Moda',
      'ayakkabi': 'Ayakkabı',
      'canta-aksesuar': 'Çanta & Aksesuar',
      'elektronik': 'Elektronik',
      'bilgisayar-tablet': 'Bilgisayar & Tablet',
      'beyaz-esya-ev-aletleri': 'Beyaz Eşya & Ev Aletleri',
      'ev-yasam': 'Ev & Yaşam',
      'zuccaciye-mutfak': 'Züccaciye & Mutfak',
      'yapi-hirdavat-tesisat': 'Yapı, Hırdavat & Tesisat',
      'otomotiv-motosiklet': 'Otomotiv & Motosiklet',
      'kozmetik-kisisel-bakim': 'Kozmetik & Kişisel Bakım',
      'anne-bebek': 'Anne & Bebek',
      'oyuncak-hobi': 'Oyuncak & Hobi',
      'muzik-enstruman': 'Müzik & Enstrüman',
      'spor-outdoor': 'Spor & Outdoor',
      'kitap': 'Kitap',
      'kirtasiye-ofis': 'Kırtasiye & Ofis',
      'evcil-hayvan-urunleri': 'Evcil Hayvan Ürünleri',
      'gozluk-optik': 'Gözlük & Optik',
      'saat-taki': 'Saat & Takı',
      'saglik-medikal': 'Sağlık & Medikal',
      'cicek-bahce': 'Çiçek & Bahçe',
      'hediyelik-parti': 'Hediyelik & Parti',
    };
    final canonicalName = aliases[value];
    return canonicalName == null ? null : canonicalForName(canonicalName);
  }

  static String _normalize(String value) => value
      .trim()
      .replaceAll('İ', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('i\u0307', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');
}
