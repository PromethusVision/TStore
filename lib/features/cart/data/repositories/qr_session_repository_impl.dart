import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class QrSessionRepositoryImpl implements QrSessionRepository {
  final SupabaseService supabaseService;

  QrSessionRepositoryImpl({required this.supabaseService});

  @override
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  }) async {
    try {
      if (supabaseService.currentUser == null) {
        return const Left('Devam etmek için giriş yapın.');
      }

      if (cartId.trim().isEmpty) {
        return const Left('Aktif mağaza sepeti bulunamadı.');
      }

      final response = await supabaseService.client.rpc(
        'create_qr_session',
        params: {'p_cart_id': cartId},
      );

      if (response is Map<String, dynamic>) {
        return Right(QrSessionModel.fromJson(response));
      }

      if (response is Map) {
        return Right(
          QrSessionModel.fromJson(Map<String, dynamic>.from(response)),
        );
      }

      return const Left('QR kodu oluşturulamadı. Lütfen tekrar deneyin.');
    } catch (e) {
      return Left(
        _friendlyError(
          e,
          fallback: 'QR kodu oluşturulamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, String>> getQrSessionStatus({
    required String sessionId,
  }) async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('Devam etmek için giriş yapın.');
      }

      final normalizedSessionId = sessionId.trim();
      if (normalizedSessionId.isEmpty) {
        return const Left('QR oturumu bulunamadı.');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.qrSessions)
          .select('status')
          .eq('id', normalizedSessionId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null || response['status'] == null) {
        return const Left('QR oturumu bulunamadı.');
      }

      return Right(response['status'].toString());
    } catch (e) {
      return Left(_friendlyError(e, fallback: 'QR durumu kontrol edilemedi.'));
    }
  }

  @override
  Future<Either<String, QrVerificationEntity>> getQrVerification({
    required String sessionToken,
  }) async {
    try {
      if (supabaseService.currentUser == null) {
        return const Left('Devam etmek için giriş yapın.');
      }

      final normalizedToken = sessionToken.trim();
      if (normalizedToken.isEmpty) {
        return const Left('QR kodu okunamadı. Lütfen yeniden okutun.');
      }

      final response = await supabaseService.client.rpc(
        'get_qr_session_for_verification',
        params: {'p_session_token': normalizedToken},
      );
      final json = _asJsonObject(response);
      if (json == null) {
        return const Left('QR bilgileri bulunamadı.');
      }

      return Right(QrVerificationModel.fromJson(json));
    } catch (e) {
      return Left(
        _friendlyError(
          e,
          fallback: 'QR bilgileri alınamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, QrVerificationEntity>> confirmQrVerification({
    required String sessionToken,
  }) async {
    try {
      if (supabaseService.currentUser == null) {
        return const Left('Devam etmek için giriş yapın.');
      }

      final normalizedToken = sessionToken.trim();
      if (normalizedToken.isEmpty) {
        return const Left('Onaylanacak QR kodu bulunamadı.');
      }

      final response = await supabaseService.client.rpc(
        'confirm_qr_session',
        params: {'p_session_token': normalizedToken},
      );
      final json = _asJsonObject(response);
      if (json == null) {
        return const Left('Alışveriş onaylanamadı.');
      }

      return Right(QrVerificationModel.fromJson(json));
    } catch (e) {
      return Left(
        _friendlyError(
          e,
          fallback: 'Alışveriş onaylanamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  static Map<String, dynamic>? _asJsonObject(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response is List && response.length == 1) {
      final first = response.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }

  static String _friendlyError(Object error, {required String fallback}) {
    final message = error.toString().toLowerCase();

    if (message.contains('authentication required') ||
        message.contains('not authenticated') ||
        message.contains('jwt')) {
      return 'Oturumunuz sona ermiş olabilir. Lütfen yeniden giriş yapın.';
    }
    if (message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('42501') ||
        message.contains('merchant access required') ||
        message.contains('not authorized')) {
      return 'Bu işlem için yetkiniz yok.';
    }
    if (message.contains('different shop') ||
        message.contains('another shop') ||
        message.contains('shop mismatch')) {
      return 'Bu QR kodu başka bir mağazaya ait.';
    }
    if (message.contains('already used') ||
        message.contains('session used') ||
        message.contains('already been confirmed')) {
      return 'Bu QR kodu daha önce kullanılmış.';
    }
    if (message.contains('expired')) {
      return 'QR kodunun süresi dolmuş.';
    }
    if (message.contains('not found') || message.contains('p0002')) {
      return 'QR kodu bulunamadı veya artık geçerli değil.';
    }
    if (message.contains('not active') ||
        message.contains('no longer eligible')) {
      return 'QR kodu artık geçerli değil.';
    }
    if (message.contains('shop is not active')) {
      return 'Mağaza aktif olmadığı için QR işlemi yapılamıyor.';
    }
    if (message.contains('unavailable or different shop item')) {
      return 'Sepette artık satışta olmayan veya farklı mağazaya ait bir ürün var.';
    }
    if (message.contains('empty cart')) {
      return 'Boş sepet için QR kodu oluşturulamaz.';
    }

    return fallback;
  }
}
