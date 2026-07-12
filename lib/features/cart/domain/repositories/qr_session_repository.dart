import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';

abstract class QrSessionRepository {
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  });

  Future<Either<String, String>> getQrSessionStatus({
    required String sessionId,
  });

  Future<Either<String, QrVerificationEntity>> getQrVerification({
    required String sessionToken,
  });

  Future<Either<String, QrVerificationEntity>> confirmQrVerification({
    required String sessionToken,
  });
}
