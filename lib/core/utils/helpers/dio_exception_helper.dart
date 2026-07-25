import 'package:dio/dio.dart';

class DioExceptionHelper {
  static String handleDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return 'Bağlantı zaman aşımına uğradı. İnternetinizi kontrol edin.';
      case DioExceptionType.sendTimeout:
        return 'İstek gönderilemedi. İnternetinizi kontrol edin.';
      case DioExceptionType.receiveTimeout:
        return 'Hizmet yanıt vermedi. Lütfen daha sonra tekrar deneyin.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException.response);
      case DioExceptionType.cancel:
        return 'İşlem iptal edildi. Lütfen tekrar deneyin.';
      case DioExceptionType.unknown:
        return dioException.message?.contains('SocketException') ?? false
            ? 'İnternet bağlantınızı kontrol edip tekrar deneyin.'
            : 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
      default:
        return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response != null) {
      switch (response.statusCode) {
        case 400:
          return 'Girilen bilgileri kontrol edip tekrar deneyin.';
        case 401:
          return 'Oturumunuz sona ermiş olabilir. Lütfen yeniden giriş yapın.';
        case 403:
          return 'Bu işlem için yetkiniz bulunmuyor.';
        case 404:
          return 'Aradığınız kayıt bulunamadı.';
        case 500:
          return 'Hizmet şu anda yanıt vermiyor. Lütfen daha sonra deneyin.';
        case 503:
          return 'Hizmet geçici olarak kullanılamıyor. Lütfen daha sonra deneyin.';
        default:
          return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
      }
    }
    return 'Hizmet şu anda yanıt vermiyor. Lütfen daha sonra deneyin.';
  }
}
