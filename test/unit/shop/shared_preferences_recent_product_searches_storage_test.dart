import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/shop/data/services/shared_preferences_recent_product_searches_storage.dart';

void main() {
  late SharedPreferencesRecentProductSearchesStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferencesRecentProductSearchesStorage();
  });

  test('returns an empty list when there is no recent search', () async {
    expect(await storage.getQueries(), isEmpty);
  });

  test('keeps the newest five unique searches', () async {
    for (final query in [
      'telefon',
      'kulaklık',
      'kahve',
      'ekmek',
      'ayakkabı',
      'mont',
    ]) {
      await storage.recordQuery(query);
    }

    expect(await storage.getQueries(), [
      'mont',
      'ayakkabı',
      'ekmek',
      'kahve',
      'kulaklık',
    ]);
  });

  test('moves a repeated search to the front without duplicating it', () async {
    await storage.recordQuery('Kahve');
    await storage.recordQuery('Ekmek');
    await storage.recordQuery('kahve');

    expect(await storage.getQueries(), ['kahve', 'Ekmek']);
  });

  test('removes one search and clears the full history', () async {
    await storage.recordQuery('Kahve');
    await storage.recordQuery('Ekmek');

    await storage.removeQuery('kahve');
    expect(await storage.getQueries(), ['Ekmek']);

    await storage.clear();
    expect(await storage.getQueries(), isEmpty);
  });

  test('ignores blank searches', () async {
    await storage.recordQuery('   ');

    expect(await storage.getQueries(), isEmpty);
  });
}
