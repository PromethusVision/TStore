import 'package:flutter/services.dart';
import 'package:t_store/core/utils/helpers/logger_helper.dart';

class PlatformExceptionHelper {
  static String handlePlatformError(PlatformException exception) {
    LoggerHelper.error("Platform Exception: ${exception.message}", exception);

    switch (exception.code) {
      case 'PERMISSION_DENIED':
        return 'İzin verilmedi. Lütfen uygulama iznini etkinleştirin.';
      case 'PERMISSION_DENIED_NEVER_ASK':
        return 'İzin kapalı. Ayarlar bölümünden etkinleştirebilirsiniz.';
      case 'LOCATION_SERVICES_DISABLED':
        return 'Konum hizmetleri kapalı. Konumu açıp tekrar deneyin.';
      case 'NETWORK_ERROR':
        return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
      case 'IO_ERROR':
        return 'İşlem tamamlanamadı. Lütfen daha sonra tekrar deneyin.';
      case 'UNAVAILABLE':
        return 'Hizmet şu anda kullanılamıyor. Lütfen daha sonra deneyin.';
      case 'ACTIVITY_NOT_FOUND':
        return 'Gerekli uygulama açılamadı.';
      case 'INVALID_ARGUMENT':
        return 'Girilen bilgileri kontrol edip tekrar deneyin.';
      case 'TIMEOUT':
        return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case 'SIGN_IN_FAILED':
        return 'Giriş yapılamadı. Bilgilerinizi kontrol edip tekrar deneyin.';
      case 'USER_CANCELLED':
        return 'İşlem iptal edildi.';
      case 'STORAGE_FULL':
        return 'Cihaz depolama alanı dolu. Biraz yer açıp tekrar deneyin.';
      case 'INTERNAL_ERROR':
        return 'İşlem tamamlanamadı. Lütfen daha sonra tekrar deneyin.';
      case 'UNKNOWN_ERROR':
        return 'İşlem tamamlanamadı. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
    }
  }
}
