import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/navigation/engagement_target.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/data/models/banner_model.dart';
import 'package:t_store/features/shop/domain/services/home_campaign_catalog.dart';

void main() {
  final now = DateTime.utc(2026, 9, 26);
  const valid = BannerEntity(
    id: 'valid',
    imageUrl: '',
    contentVersion: 2,
    title: 'Kampanya',
    subtitle: 'Açıklama',
  );
  test(
    'rejects unreviewed, inactive, targeted, expired and invalid compositions',
    () {
      final invalid = [
        valid.copyWith(contentVersion: 1),
        valid.copyWith(audience: 'merchant'),
        valid.copyWith(city: 'Yerel'),
        valid.copyWith(categoryScope: 'school'),
        valid.copyWith(isActive: false),
        valid.copyWith(startDate: now.add(const Duration(days: 1))),
        valid.copyWith(endDate: now.subtract(const Duration(seconds: 1))),
        valid.copyWith(imageUrl: 'http://unsafe.test/a'),
        valid.copyWith(title: ''),
      ];
      expect(
        HomeCampaignCatalog.select(invalid, now),
        HomeCampaignCatalog.fallback,
      );
    },
  );
  test(
    'remote-first deterministic priority, de-duplication and local fallback',
    () {
      expect(
        HomeCampaignCatalog.select([
          valid.copyWith(id: 'later', sortOrder: 4),
          valid,
          valid,
        ], now).map((c) => c.id),
        ['valid', 'later'],
      );
      expect(HomeCampaignCatalog.fallback.map((b) => b.id).toSet().length, 5);
    },
  );
  test(
    'version two motif composition can omit artwork and roundtrips fields',
    () {
      final parsed = BannerModel.fromJson({
        'id': 'campaign',
        'image_url': '',
        'content_version': 2,
        'title': 'Başlık',
        'subtitle': 'Metin',
        'cta_text': 'Keşfet',
        'audience': 'general',
      });
      expect(parsed.ctaText, 'Keşfet');
      expect(BannerModel.fromJson(parsed.toJson()), parsed);
      expect(BannerModel.tryFromJson({'id': 'old', 'image_url': ''}), isNull);
    },
  );
  test(
    'shared targets reject arbitrary URL, invalid UUID, and injected controls',
    () {
      expect(EngagementTarget.parse('url', 'https://example.test'), isNull);
      expect(EngagementTarget.parse('product', 'not-an-id'), isNull);
      expect(EngagementTarget.parse('search', 'a\nb'), isNull);
      expect(EngagementTarget.parse('reward', ''), isNotNull);
      expect(EngagementTarget.parse('search', 'USB')?.value, 'USB');
    },
  );
}
