import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

/// Adds an exact-workspace boundary around the existing server-authoritative QR.
class MerchantQrRepository implements QrSessionRepository, QrClaimRepository {
  const MerchantQrRepository({
    required this.delegate,
    required this.merchants,
    required this.access,
  });
  final QrSessionRepository delegate;
  final MerchantRepository merchants;
  final MerchantAccess access;
  QrClaimRepository? get _claims =>
      delegate is QrClaimRepository ? delegate as QrClaimRepository : null;
  @override
  bool get claimsEnabled => _claims?.claimsEnabled ?? false;
  Future<Either<String, QrVerificationEntity>> _claimRun(
    Future<Either<String, QrVerificationEntity>> Function(QrClaimRepository) fn,
  ) async {
    if (_claims == null || !await _authorized()) {
      return const Left(merchantAccessDenied);
    }
    final result = await fn(_claims!);
    if (!await _authorized()) return const Left(merchantSessionChanged);
    return result.flatMap(
      (v) => v.shopId == access.shop?.id
          ? Right(v)
          : const Left(merchantAccessDenied),
    );
  }

  @override
  Future<Either<String, QrVerificationEntity>> claimVerification({
    required String shopId,
    required String requestId,
    String? sessionToken,
    String? manualCode,
  }) => shopId != access.shop?.id
      ? Future.value(const Left(merchantAccessDenied))
      : _claimRun(
          (r) => r.claimVerification(
            shopId: shopId,
            requestId: requestId,
            sessionToken: sessionToken,
            manualCode: manualCode,
          ),
        );
  @override
  Future<Either<String, QrVerificationEntity>> reconcileClaim(String id) =>
      _claimRun((r) => r.reconcileClaim(id));
  @override
  Future<Either<String, QrVerificationEntity>> completeClaim(String id) =>
      _claimRun((r) => r.completeClaim(id));
  @override
  Future<Either<String, QrVerificationEntity>> cancelClaim(String id) =>
      _claimRun((r) => r.cancelClaim(id));
  @override
  Future<Either<String, QrVerificationEntity?>> recoverClaim(
    String shopId,
  ) async {
    if (_claims == null || shopId != access.shop?.id || !await _authorized()) {
      return const Left(merchantAccessDenied);
    }
    final result = await _claims!.recoverClaim(shopId);
    if (!await _authorized()) return const Left(merchantSessionChanged);
    return result.flatMap(
      (v) => v == null || v.shopId == shopId
          ? Right(v)
          : const Left(merchantAccessDenied),
    );
  }

  @override
  Future<Either<String, QrSessionEntity>> readCustomerSession(
    String sessionId,
  ) async => const Left(merchantAccessDenied);

  Future<bool> _authorized() async {
    final result = await merchants.loadAccess();
    return result.fold(
      (_) => false,
      (fresh) =>
          fresh != null &&
          fresh.canManage &&
          fresh.user.id == access.user.id &&
          fresh.shop!.id == access.shop?.id,
    );
  }

  Future<Either<String, QrVerificationEntity>> _run(
    String token, {
    required bool confirm,
  }) async {
    if (!await _authorized()) return const Left(merchantAccessDenied);
    final result = confirm
        ? await delegate.confirmQrVerification(sessionToken: token)
        : await delegate.getQrVerification(sessionToken: token);
    if (!await _authorized()) return const Left(merchantSessionChanged);
    return result.flatMap(
      (value) =>
          value.shopId == access.shop?.id && value.sessionToken == token.trim()
          ? Right(value)
          : const Left('Bu QR kodu mağazanıza ait değil.'),
    );
  }

  @override
  Future<Either<String, QrVerificationEntity>> getQrVerification({
    required String sessionToken,
  }) => _run(sessionToken, confirm: false);
  @override
  Future<Either<String, QrVerificationEntity>> confirmQrVerification({
    required String sessionToken,
  }) => _run(sessionToken, confirm: true);
  @override
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  }) async => const Left('QR kodunu müşteri oluşturur.');
  @override
  Future<Either<String, String>> getQrSessionStatus({
    required String sessionId,
  }) async => const Left('Merchant ekranında QR doğrulama akışını kullanın.');
}
