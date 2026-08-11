import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/data/models/banner_model.dart';

void main() {
  group('BannerModel.tryFromJson', () {
    test('normalizes valid read values without changing banner meaning', () {
      final model = BannerModel.tryFromJson({
        'id': ' banner-1 ',
        'image_url': ' https://example.com/banner.png ',
        'title': ' Campaign ',
        'sort_order': '4',
        'is_active': 'false',
        'start_date': '2026-08-12T12:00:00+03:00',
        'end_date': '2026-08-13T12:00:00+03:00',
      });

      expect(model, isNotNull);
      expect(model!.id, 'banner-1');
      expect(model.imageUrl, 'https://example.com/banner.png');
      expect(model.title, 'Campaign');
      expect(model.sortOrder, 4);
      expect(model.isActive, isFalse);
      expect(model.startDate, DateTime.parse('2026-08-12T12:00:00+03:00'));
    });

    test('rejects rows missing the required id or image reference', () {
      expect(
        BannerModel.tryFromJson({'id': '', 'image_url': 'image.png'}),
        isNull,
      );
      expect(
        BannerModel.tryFromJson({'id': 'banner-1', 'image_url': '  '}),
        isNull,
      );
      expect(
        BannerModel.tryFromJson({'id': 1, 'image_url': 'image.png'}),
        isNull,
      );
    });

    test('rejects malformed or inverted active date ranges', () {
      expect(
        BannerModel.tryFromJson({
          'id': 'malformed',
          'image_url': 'image.png',
          'start_date': 'not-a-date',
        }),
        isNull,
      );
      expect(
        BannerModel.tryFromJson({
          'id': 'inverted',
          'image_url': 'image.png',
          'start_date': '2026-08-13T00:00:00Z',
          'end_date': '2026-08-12T00:00:00Z',
        }),
        isNull,
      );
    });

    test('rejects malformed active and order values', () {
      expect(
        BannerModel.tryFromJson({
          'id': 'bad-active',
          'image_url': 'image.png',
          'is_active': 'sometimes',
        }),
        isNull,
      );
      expect(
        BannerModel.tryFromJson({
          'id': 'bad-order',
          'image_url': 'image.png',
          'sort_order': 1.5,
        }),
        isNull,
      );
    });

    test('fromJson surfaces an invalid row as a format error', () {
      expect(
        () => BannerModel.fromJson({'id': 'banner-1'}),
        throwsFormatException,
      );
    });
  });
}
