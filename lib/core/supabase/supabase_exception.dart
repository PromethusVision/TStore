import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom exception for Supabase errors
class SupabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SupabaseException({required this.message, this.code, this.originalError});

  /// Create from AuthException
  factory SupabaseException.fromAuthException(AuthException e) {
    return SupabaseException(
      message: _getAuthErrorMessage(e.message),
      code: e.statusCode,
      originalError: e,
    );
  }

  /// Create from PostgrestException
  factory SupabaseException.fromPostgrestException(PostgrestException e) {
    return SupabaseException(
      message: _getDatabaseErrorMessage(e.message, e.code),
      code: e.code,
      originalError: e,
    );
  }

  /// Create from StorageException
  factory SupabaseException.fromStorageException(StorageException e) {
    return SupabaseException(
      message: _getStorageErrorMessage(e.message),
      code: e.statusCode,
      originalError: e,
    );
  }

  /// Create from generic exception
  factory SupabaseException.fromException(dynamic e) {
    if (e is AuthException) {
      return SupabaseException.fromAuthException(e);
    } else if (e is PostgrestException) {
      return SupabaseException.fromPostgrestException(e);
    } else if (e is StorageException) {
      return SupabaseException.fromStorageException(e);
    } else {
      return SupabaseException(
        message: 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
        originalError: e,
      );
    }
  }

  /// Get user-friendly auth error message
  static String _getAuthErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'E-posta adresinizi doğrulamanız gerekiyor.';
    }
    if (lowerMessage.contains('user already registered')) {
      return 'Bu e-posta adresiyle daha önce hesap oluşturulmuş.';
    }
    if (lowerMessage.contains('password')) {
      return 'Şifre güvenlik şartlarını karşılamıyor.';
    }
    if (lowerMessage.contains('email')) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    if (lowerMessage.contains('rate limit')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    }
    if (lowerMessage.contains('network')) {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }

    return 'Kimlik doğrulama işlemi tamamlanamadı. Lütfen tekrar deneyin.';
  }

  /// Get user-friendly database error message
  static String _getDatabaseErrorMessage(String message, String? code) {
    if (code == '23505') {
      return 'Bu kayıt zaten mevcut.';
    }
    if (code == '23503') {
      return 'Bu kayıt başka bilgilerle bağlantılı olduğu için silinemiyor.';
    }
    if (code == 'PGRST116') {
      return 'Aradığınız kayıt bulunamadı.';
    }
    if (code == '42501') {
      return 'Bu işlem için yetkiniz bulunmuyor.';
    }

    return 'Bilgiler işlenemedi. Lütfen tekrar deneyin.';
  }

  /// Get user-friendly storage error message
  static String _getStorageErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('not found')) {
      return 'Dosya bulunamadı.';
    }
    if (lowerMessage.contains('too large')) {
      return 'Dosya boyutu çok büyük.';
    }
    if (lowerMessage.contains('invalid')) {
      return 'Bu dosya türü desteklenmiyor.';
    }

    return 'Dosya işlemi tamamlanamadı. Lütfen tekrar deneyin.';
  }

  @override
  String toString() => 'SupabaseException: $message (code: $code)';
}

/// Extension to handle Supabase errors easily
extension SupabaseErrorHandler<T> on Future<T> {
  /// Handle Supabase errors and convert to SupabaseException
  Future<T> handleSupabaseError() async {
    try {
      return await this;
    } on AuthException catch (e) {
      throw SupabaseException.fromAuthException(e);
    } on PostgrestException catch (e) {
      throw SupabaseException.fromPostgrestException(e);
    } on StorageException catch (e) {
      throw SupabaseException.fromStorageException(e);
    } catch (e) {
      throw SupabaseException.fromException(e);
    }
  }
}
