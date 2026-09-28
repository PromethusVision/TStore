import 'package:dartz/dartz.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

/// Adds an exact-workspace boundary around the existing server-authoritative QR.
class MerchantQrRepository implements QrSessionRepository {
  const MerchantQrRepository({
    required this.delegate,
    required this.merchants,
    required this.access,
  });
  final QrSessionRepository delegate;
  final MerchantRepository merchants;
  final MerchantAccess access;

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
