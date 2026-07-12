import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class ConfirmQrVerificationUsecase
    implements UseCase<QrVerificationEntity, ConfirmQrVerificationParams> {
  final QrSessionRepository repository;

  ConfirmQrVerificationUsecase(this.repository);

  @override
  Future<Either<String, QrVerificationEntity>> call(
    ConfirmQrVerificationParams params,
  ) async {
    return repository.confirmQrVerification(sessionToken: params.sessionToken);
  }
}

class ConfirmQrVerificationParams {
  final String sessionToken;

  const ConfirmQrVerificationParams({required this.sessionToken});
}
