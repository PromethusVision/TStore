class SharedPreferencesException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  SharedPreferencesException(this.message, {this.error, this.stackTrace});

  @override
  String toString() => message;
}

class SharedPreferencesExceptionHelper {
  static String handleException(dynamic error) {
    if (error is FormatException) {
      return 'Kaydedilen bilgiler okunamadı.';
    } else if (error is TypeError) {
      return 'Kaydedilen bilgiler geçersiz.';
    } else {
      return 'Cihazdaki bilgilere erişilemedi. Lütfen tekrar deneyin.';
    }
  }
}
