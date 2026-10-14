import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';

/// Optional protocol on the existing QR repository, never an independent QR store.
abstract interface class QrClaimRepository {
  bool get claimsEnabled;
  Future<Either<String, QrVerificationEntity>> claimVerification({
    required String shopId,
    required String requestId,
    String? sessionToken,
    String? manualCode,
  });
  Future<Either<String, QrVerificationEntity>> reconcileClaim(String claimId);
  Future<Either<String, QrVerificationEntity>> completeClaim(String claimId);
  Future<Either<String, QrVerificationEntity>> cancelClaim(String claimId);
  Future<Either<String, QrVerificationEntity?>> recoverClaim(String shopId);
  Future<Either<String, QrSessionEntity>> readCustomerSession(String sessionId);
}
