abstract class RecentProductSearchesStorage {
  static const int maximumQueryCount = 5;

  Future<List<String>> getQueries();

  Future<void> recordQuery(String query);

  Future<void> removeQuery(String query);

  Future<void> clear();
}
