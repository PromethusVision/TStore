abstract final class CustomerErrorMessage {
  static const String generic = 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
  static const String signInRequired = 'Devam etmek için lütfen giriş yapın.';
  static const String sessionExpired =
      'Oturumunuz sona ermiş olabilir. Lütfen yeniden giriş yapın.';
  static const String connection =
      'İnternet bağlantınızı kontrol edip tekrar deneyin.';
  static const String serviceUnavailable =
      'Hizmet şu anda yanıt vermiyor. Lütfen kısa süre sonra tekrar deneyin.';
  static const String permissionDenied = 'Bu işlem için yetkiniz bulunmuyor.';
  static const String alreadyExists = 'Bu kayıt zaten mevcut.';
  static const String notFound = 'Aradığınız kayıt bulunamadı.';

  static String from(Object error, {String fallback = generic}) {
    final message = error.toString().toLowerCase();

    if (_containsAny(message, const [
      'socketexception',
      'failed host lookup',
      'failed to fetch',
      'xmlhttprequest',
      'clientexception',
      'connection reset',
      'connection refused',
      'network',
      'timed out',
      'timeout',
    ])) {
      return connection;
    }

    if (_containsAny(message, const [
      'service unavailable',
      'temporarily unavailable',
      'internal server error',
      'bad gateway',
      'statuscode: 500',
      'statuscode: 502',
      'statuscode: 503',
    ])) {
      return serviceUnavailable;
    }

    if (_containsAny(message, const [
      'auth session missing',
      'authentication required',
      'not authenticated',
      'not_authenticated',
      'jwt expired',
      'invalid jwt',
      'invalid token',
      'statuscode: 401',
    ])) {
      return sessionExpired;
    }

    if (_containsAny(message, const [
      'permission denied',
      'row-level security',
      '42501',
      'statuscode: 403',
    ])) {
      return permissionDenied;
    }

    if (_containsAny(message, const [
      'duplicate key',
      'already exists',
      '23505',
    ])) {
      return alreadyExists;
    }

    if (_containsAny(message, const [
      'pgrst116',
      'location_not_found',
      'statuscode: 404',
    ])) {
      return notFound;
    }

    return fallback;
  }

  static bool _containsAny(String message, List<String> values) {
    return values.any(message.contains);
  }
}
