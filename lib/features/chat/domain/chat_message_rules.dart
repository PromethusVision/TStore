abstract final class ChatMessageRules {
  static const int maxTextLength = 1000;

  static String normalizeText(String value) => value.trim();

  static int characterCount(String value) => value.runes.length;

  static String limitText(String value) {
    if (characterCount(value) <= maxTextLength) return value;
    return String.fromCharCodes(value.runes.take(maxTextLength));
  }

  static String? validationError(String value) {
    final normalized = normalizeText(value);
    if (normalized.isEmpty) return 'Mesaj boş olamaz.';
    if (characterCount(normalized) > maxTextLength) {
      return 'Mesaj en fazla 1.000 karakter olabilir.';
    }
    return null;
  }
}
