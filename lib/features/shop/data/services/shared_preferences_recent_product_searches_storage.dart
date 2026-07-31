import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';

class SharedPreferencesRecentProductSearchesStorage
    implements RecentProductSearchesStorage {
  static const String _key = 'recent_product_search_queries_v1';

  @override
  Future<List<String>> getQueries() async {
    final preferences = await SharedPreferences.getInstance();
    final storedQueries = preferences.getStringList(_key) ?? const [];
    final seenQueries = <String>{};

    return storedQueries
        .map((query) => query.trim())
        .where(
          (query) => query.isNotEmpty && seenQueries.add(query.toLowerCase()),
        )
        .take(RecentProductSearchesStorage.maximumQueryCount)
        .toList(growable: false);
  }

  @override
  Future<void> recordQuery(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final normalizedKey = normalizedQuery.toLowerCase();
    final queries = await getQueries();

    await preferences.setStringList(
      _key,
      [
        normalizedQuery,
        ...queries.where((item) => item.toLowerCase() != normalizedKey),
      ].take(RecentProductSearchesStorage.maximumQueryCount).toList(),
    );
  }

  @override
  Future<void> removeQuery(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final normalizedKey = normalizedQuery.toLowerCase();
    final queries = await getQueries();

    await preferences.setStringList(
      _key,
      queries.where((item) => item.toLowerCase() != normalizedKey).toList(),
    );
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
