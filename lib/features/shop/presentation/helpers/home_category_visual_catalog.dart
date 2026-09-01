import 'package:flutter/material.dart';

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
  });

  final String categoryName;
  final IconData icon;
  final String assetLabel;
  final String visualMeaning;
  final bool isCanonical;
}

abstract final class HomeCategoryVisualCatalog {
  static const canonicalVisuals = <HomeCategoryVisualSpec>[
    HomeCategoryVisualSpec(
      categoryName: 'Gıda & İçecek',
      icon: Icons.restaurant_rounded,
      assetLabel: 'material:restaurant_rounded',
      visualMeaning: 'çatal-bıçak / yiyecek ve içecek',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Giyim & Moda',
      icon: Icons.checkroom_rounded,
      assetLabel: 'material:checkroom_rounded',
      visualMeaning: 'askıdaki giysi / moda',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Ayakkabı',
      icon: Icons.roller_skating_rounded,
      assetLabel: 'material:roller_skating_rounded',
      visualMeaning: 'belirgin ayakkabı / patenli ayakkabı silüeti',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Çanta & Aksesuar',
      icon: Icons.business_center_rounded,
      assetLabel: 'material:business_center_rounded',
      visualMeaning: 'taşınabilir çanta / aksesuar',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Elektronik',
      icon: Icons.devices_rounded,
      assetLabel: 'material:devices_rounded',
      visualMeaning: 'telefon ve elektronik ekranlar',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Bilgisayar & Tablet',
      icon: Icons.computer_rounded,
      assetLabel: 'material:computer_rounded',
      visualMeaning: 'masaüstü bilgisayar ekranı',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Beyaz Eşya & Ev Aletleri',
      icon: Icons.kitchen_rounded,
      assetLabel: 'material:kitchen_rounded',
      visualMeaning: 'buzdolabı / elektrikli ev aleti',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Ev & Yaşam',
      icon: Icons.chair_rounded,
      assetLabel: 'material:chair_rounded',
      visualMeaning: 'koltuk / ev yaşam alanı',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Züccaciye & Mutfak',
      icon: Icons.flatware_rounded,
      assetLabel: 'material:flatware_rounded',
      visualMeaning: 'çatal-bıçak / mutfak gereci',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Yapı, Hırdavat & Tesisat',
      icon: Icons.handyman_rounded,
      assetLabel: 'material:handyman_rounded',
      visualMeaning: 'çekiç ve anahtar / el aletleri',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Otomotiv & Motosiklet',
      icon: Icons.directions_car_rounded,
      assetLabel: 'material:directions_car_rounded',
      visualMeaning: 'otomobil / motorlu araç',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kozmetik & Kişisel Bakım',
      icon: Icons.spa_rounded,
      assetLabel: 'material:spa_rounded',
      visualMeaning: 'bakım ve kozmetik yaprağı',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Anne & Bebek',
      icon: Icons.child_friendly_rounded,
      assetLabel: 'material:child_friendly_rounded',
      visualMeaning: 'bebek arabası',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Oyuncak & Hobi',
      icon: Icons.toys_rounded,
      assetLabel: 'material:toys_rounded',
      visualMeaning: 'oyuncak / oyun nesnesi',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Müzik & Enstrüman',
      icon: Icons.piano_rounded,
      assetLabel: 'material:piano_rounded',
      visualMeaning: 'piyano tuşları / enstrüman',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Spor & Outdoor',
      icon: Icons.fitness_center_rounded,
      assetLabel: 'material:fitness_center_rounded',
      visualMeaning: 'dambıl / spor ekipmanı',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kitap',
      icon: Icons.menu_book_rounded,
      assetLabel: 'material:menu_book_rounded',
      visualMeaning: 'açık kitap',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Kırtasiye & Ofis',
      icon: Icons.edit_note_rounded,
      assetLabel: 'material:edit_note_rounded',
      visualMeaning: 'kalem ve not satırları',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Evcil Hayvan Ürünleri',
      icon: Icons.pets_rounded,
      assetLabel: 'material:pets_rounded',
      visualMeaning: 'pati / evcil hayvan',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Gözlük & Optik',
      icon: Icons.visibility_rounded,
      assetLabel: 'material:visibility_rounded',
      visualMeaning: 'göz / görüş ve optik',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Saat & Takı',
      icon: Icons.watch_rounded,
      assetLabel: 'material:watch_rounded',
      visualMeaning: 'kol saati / takı aksesuarı',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Sağlık & Medikal',
      icon: Icons.medical_services_rounded,
      assetLabel: 'material:medical_services_rounded',
      visualMeaning: 'ilk yardım çantası / medikal ürün',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Çiçek & Bahçe',
      icon: Icons.local_florist_rounded,
      assetLabel: 'material:local_florist_rounded',
      visualMeaning: 'çiçek / bitki ve bahçe',
    ),
    HomeCategoryVisualSpec(
      categoryName: 'Hediyelik & Parti',
      icon: Icons.redeem_rounded,
      assetLabel: 'material:redeem_rounded',
      visualMeaning: 'kurdeleli hediye kutusu',
    ),
  ];

  static const unknownVisual = HomeCategoryVisualSpec(
    categoryName: 'Bilinmeyen kategori',
    icon: Icons.category_rounded,
    assetLabel: 'material:category_rounded',
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
      'electronics' || 'elektronik' => canonicalVisuals[4],
      'clothes' || 'clothing' || 'giyim' => canonicalVisuals[1],
      'shoes' || 'ayakkabı' || 'ayakkabi' => canonicalVisuals[2],
      'furniture' || 'mobilya' => canonicalVisuals[7],
      'accessories' || 'aksesuar' => canonicalVisuals[3],
      'grocery' ||
      'groceries' ||
      'gıda' ||
      'gida' ||
      'market' => canonicalVisuals[0],
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
      'cosmetics' || 'kozmetik' => canonicalVisuals[11],
      'home & living' ||
      'home and living' ||
      'ev & yaşam' ||
      'ev-yasam' => canonicalVisuals[7],
      _ => _resolveByStableAlias(id) ?? unknownVisual,
    };
  }

  static HomeCategoryVisualSpec? _resolveByStableAlias(String value) {
    const aliases = <String, int>{
      'gida-icecek': 0,
      'giyim-moda': 1,
      'ayakkabi': 2,
      'canta-aksesuar': 3,
      'elektronik': 4,
      'bilgisayar-tablet': 5,
      'beyaz-esya-ev-aletleri': 6,
      'ev-yasam': 7,
      'zuccaciye-mutfak': 8,
      'yapi-hirdavat-tesisat': 9,
      'otomotiv-motosiklet': 10,
      'kozmetik-kisisel-bakim': 11,
      'anne-bebek': 12,
      'oyuncak-hobi': 13,
      'muzik-enstruman': 14,
      'spor-outdoor': 15,
      'kitap': 16,
      'kirtasiye-ofis': 17,
      'evcil-hayvan-urunleri': 18,
      'gozluk-optik': 19,
      'saat-taki': 20,
      'saglik-medikal': 21,
      'cicek-bahce': 22,
      'hediyelik-parti': 23,
    };
    final index = aliases[value];
    return index == null ? null : canonicalVisuals[index];
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}
