/// Daily values stay strings so older readers never receive nested JSON.
/// Unknown/legacy text is preserved until that day is explicitly edited.
class ShopOpeningHours {
  static const days = {
    'mon': 'Pazartesi',
    'tue': 'Salı',
    'wed': 'Çarşamba',
    'thu': 'Perşembe',
    'fri': 'Cuma',
    'sat': 'Cumartesi',
    'sun': 'Pazar',
  };
  static String? value(Map<String, dynamic> hours, String day) {
    // An explicit empty day overrides an older grouped value.
    final raw = hours.containsKey(day)
        ? hours[day]
        : hours.containsKey(days[day])
        ? hours[days[day]]
        : day == 'sun'
        ? null
        : day == 'sat'
        ? hours['mon_sat']
        : hours['mon_fri'] ?? hours['mon_sat'];
    return raw is String && raw.trim().isNotEmpty ? raw.trim() : null;
  }

  static bool isClosed(String? value) =>
      ['closed', 'kapalı', 'kapali'].contains(value?.toLowerCase());

  static List<int>? minutes(String? value) {
    if (value == null) return null;
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*[-–]\s*(\d{1,2}):(\d{2})(?:\s*\(ertesi gün\))?$',
    ).firstMatch(value);
    if (match == null) return null;
    final n = [for (var i = 1; i <= 4; i++) int.parse(match.group(i)!)];
    if (n[0] > 23 || n[2] > 23 || n[1] > 59 || n[3] > 59) return null;
    return [n[0] * 60 + n[1], n[2] * 60 + n[3]];
  }

  static String clock(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
  static String range(int start, int end) => '${clock(start)}–${clock(end)}';
  static String label(String? value) {
    if (value == null || value.isEmpty) return 'Belirtilmedi';
    if (isClosed(value)) return 'Kapalı';
    final pair = minutes(value);
    if (pair == null) return value;
    return '${range(pair[0], pair[1])}${pair[1] < pair[0] ? ' (ertesi gün)' : ''}';
  }

  static String format(Map<String, dynamic> hours) {
    if (hours.isEmpty) return 'Belirtilmedi';
    if (!hours.keys.any(
      (key) => days.containsKey(key) || key == 'mon_fri' || key == 'mon_sat',
    )) {
      return hours.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');
    }
    return days.entries
        .map((day) => '${day.value}: ${label(value(hours, day.key))}')
        .join('\n');
  }
}
