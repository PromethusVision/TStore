import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';

void main() {
  group('BannerEntity.isActiveAt', () {
    final instant = DateTime.parse('2026-08-12T09:00:00Z');

    test('treats the start and end instants as inclusive', () {
      final startsNow = BannerEntity(
        id: 'starts-now',
        imageUrl: 'https://example.com/starts.png',
        startDate: instant,
      );
      final endsNow = BannerEntity(
        id: 'ends-now',
        imageUrl: 'https://example.com/ends.png',
        endDate: instant,
      );

      expect(startsNow.isActiveAt(instant), isTrue);
      expect(endsNow.isActiveAt(instant), isTrue);
    });

    test('compares timezone offsets as the same absolute instant', () {
      final banner = BannerEntity(
        id: 'timezone-boundary',
        imageUrl: 'https://example.com/timezone.png',
        startDate: DateTime.parse('2026-08-12T12:00:00+03:00'),
        endDate: DateTime.parse('2026-08-12T12:00:00+03:00'),
      );

      expect(banner.isActiveAt(instant), isTrue);
    });

    test('rejects inactive, future, and expired banners', () {
      final inactive = BannerEntity(
        id: 'inactive',
        imageUrl: 'https://example.com/inactive.png',
        isActive: false,
      );
      final future = BannerEntity(
        id: 'future',
        imageUrl: 'https://example.com/future.png',
        startDate: instant.add(const Duration(seconds: 1)),
      );
      final expired = BannerEntity(
        id: 'expired',
        imageUrl: 'https://example.com/expired.png',
        endDate: instant.subtract(const Duration(seconds: 1)),
      );

      expect(inactive.isActiveAt(instant), isFalse);
      expect(future.isActiveAt(instant), isFalse);
      expect(expired.isActiveAt(instant), isFalse);
    });
  });
}
