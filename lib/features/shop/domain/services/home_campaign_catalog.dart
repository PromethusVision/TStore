import 'package:t_store/features/shop/domain/entities/banner_entity.dart';

/// Extends the existing banner contract. Version 2 identifies reviewed complete
/// compositions; old image-only stock rows cannot become active Home campaigns.
abstract final class HomeCampaignCatalog {
  static const fallback = <BannerEntity>[
    BannerEntity(
      id: 'local-discover',
      imageUrl: '',
      contentVersion: 2,
      title: 'Kargo bekleme, EsnaftaVar',
      subtitle: 'Aradığın ürün yakındaki esnafta seni bekliyor.',
      ctaText: 'Ürünleri keşfet',
      actionType: 'search',
      actionUrl: '',
    ),
    BannerEntity(
      id: 'local-compare',
      imageUrl: '',
      contentVersion: 2,
      title: 'Aynı ürünü farklı esnaflarda karşılaştır',
      subtitle: 'Fiyatları gör, sana uygun mağazayı seç.',
      ctaText: 'Karşılaştır',
      actionType: 'search',
      actionUrl: '',
    ),
    BannerEntity(
      id: 'local-city',
      imageUrl: '',
      contentVersion: 2,
      title: 'Şehre dönüş ihtiyaçların hazır',
      subtitle:
          'Elektronikten günlük ihtiyaçlara kadar aradığın ürünler yakınında.',
      ctaText: 'Keşfet',
      actionType: 'search',
      actionUrl: '',
    ),
    BannerEntity(
      id: 'local-route',
      imageUrl: '',
      contentVersion: 2,
      title: 'Mağaza mağaza dolaşma',
      subtitle: 'Ürünün bulunduğu yeri gör, yol tarifini al, doğrudan git.',
      ctaText: 'Ürün ara',
      actionType: 'search',
      actionUrl: '',
    ),
    BannerEntity(
      id: 'local-today',
      imageUrl: '',
      contentVersion: 2,
      title: 'Bugün lazım olanı bugün bul',
      subtitle: 'Ürünü online ara, mağazayı bul, hemen ulaş.',
      ctaText: 'Hemen bul',
      actionType: 'search',
      actionUrl: '',
    ),
  ];

  static List<BannerEntity> select(
    Iterable<BannerEntity> remote,
    DateTime now,
  ) {
    final seen = <String>{};
    final campaigns =
        remote.where((c) {
          final image = Uri.tryParse(c.imageUrl);
          return c.contentVersion == 2 &&
              c.isActiveAt(now) &&
              c.id.trim().isNotEmpty &&
              (c.title?.trim().isNotEmpty ?? false) &&
              (c.subtitle?.trim().isNotEmpty ?? false) &&
              (c.title?.length ?? 0) <= 120 &&
              (c.subtitle?.length ?? 0) <= 300 &&
              (c.ctaText?.length ?? 0) <= 48 &&
              c.audience == 'general' &&
              c.city == null &&
              c.district == null &&
              c.categoryScope == null &&
              (c.imageUrl.isEmpty ||
                  (image?.scheme == 'https' &&
                      image!.host.isNotEmpty &&
                      image.userInfo.isEmpty)) &&
              seen.add(c.id);
        }).toList()..sort((a, b) {
          final order = a.sortOrder.compareTo(b.sortOrder);
          return order != 0 ? order : a.id.compareTo(b.id);
        });
    return campaigns.isEmpty
        ? fallback
        : campaigns.take(12).toList(growable: false);
  }
}
