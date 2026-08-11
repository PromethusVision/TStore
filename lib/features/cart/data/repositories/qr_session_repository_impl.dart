import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/cart/data/models/qr_session_status_model.dart';
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
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('Devam etmek için giriş yapın.');
      }

      final normalizedCartId = cartId.trim();
      if (normalizedCartId.isEmpty) {
        return const Left('Aktif mağaza sepeti bulunamadı.');
      }

      var response = await supabaseService.client.rpc(
        'create_qr_session',
        params: {'p_cart_id': normalizedCartId},
      );
      if (!_isSameAuthenticatedUser(user.id)) {
        return const Left(
          'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
        );
      }

      var json = _asJsonObject(response);
      if (json == null) {
        return const Left('QR kodu oluşturulamadı. Lütfen tekrar deneyin.');
      }

      var session = QrSessionModel.fromJson(json);
      if (session.userId == user.id &&
          session.cartId == normalizedCartId &&
          session.status == 'active' &&
          !session.expiresAt.isAfter(DateTime.now())) {
        // A heavily contended older RPC can return an active row whose
        // deadline passed while it waited for a database lock. One bounded,
        // idempotent retry lets the server expire that row and create a fresh
        // snapshot without exposing a stale QR to the customer.
        response = await supabaseService.client.rpc(
          'create_qr_session',
          params: {'p_cart_id': normalizedCartId},
        );
        if (!_isSameAuthenticatedUser(user.id)) {
          return const Left(
            'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
          );
        }
        json = _asJsonObject(response);
        if (json == null) {
          return const Left('QR kodu oluşturulamadı. Lütfen tekrar deneyin.');
        }
        session = QrSessionModel.fromJson(json);
      }

      if (session.userId != user.id ||
          session.cartId != normalizedCartId ||
          session.sessionToken.trim().isEmpty ||
          session.status != 'active' ||
          !session.expiresAt.isAfter(DateTime.now()) ||
          session.itemCount == null ||
          session.itemCount! <= 0 ||
          session.totalAmount == null ||
          !session.totalAmount!.isFinite ||
          session.totalAmount! < 0) {
        return const Left(
          'QR bilgileri sunucudan güvenli biçimde doğrulanamadı.',
        );
      }

      return Right(session);
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
          .select('status, expires_at')
          .eq('id', normalizedSessionId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (!_isSameAuthenticatedUser(user.id)) {
        return const Left(
          'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
        );
      }

      if (response == null) {
        return const Left('QR oturumu bulunamadı.');
      }

      final status = QrSessionStatusModel.fromJson(response);
      return Right(status.resolveAt(DateTime.now()));
    } catch (e) {
      return Left(_friendlyError(e, fallback: 'QR durumu kontrol edilemedi.'));
    }
  }

  @override
  Future<Either<String, QrVerificationEntity>> getQrVerification({
    required String sessionToken,
  }) async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
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
      if (!_isSameAuthenticatedUser(user.id)) {
        return const Left(
          'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
        );
      }

      final json = _asJsonObject(response);
      if (json == null) {
        return const Left('QR bilgileri bulunamadı.');
      }

      final verification = QrVerificationModel.fromJson(json);
      if (verification.sessionToken != normalizedToken) {
        return const Left(
          'QR bilgileri sunucudan güvenli biçimde doğrulanamadı.',
        );
      }

      return Right(verification);
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
      final user = supabaseService.currentUser;
      if (user == null) {
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
      if (!_isSameAuthenticatedUser(user.id)) {
        return const Left(
          'Oturumunuz değişti. Güvenliğiniz için yeniden giriş yapın.',
        );
      }

      final json = _asJsonObject(response);
      if (json == null) {
        return const Left('Alışveriş onaylanamadı.');
      }

      final verification = QrVerificationModel.fromJson(json);
      if (verification.sessionToken != normalizedToken ||
          verification.status != 'used' ||
          verification.usedAt == null) {
        return const Left(
          'Sunucu alışveriş onayını güvenli biçimde doğrulayamadı.',
        );
      }

      return Right(verification);
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

  bool _isSameAuthenticatedUser(String expectedUserId) =>
      supabaseService.currentUser?.id == expectedUserId;

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
    if (message.contains('shop is not active')) {
      return 'Mağaza aktif olmadığı için QR işlemi yapılamıyor.';
    }
    if (message.contains('not active') ||
        message.contains('no longer eligible')) {
      return 'QR kodu artık geçerli değil.';
    }
    if (message.contains('snapshot is missing') ||
        message.contains('snapshot is incomplete') ||
        message.contains('snapshot is inconsistent')) {
      return 'QR ürün ve toplam bilgileri doğrulanamadı.';
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
