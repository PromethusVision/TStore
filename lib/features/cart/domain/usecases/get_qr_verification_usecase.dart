import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class GetQrVerificationUsecase
    implements UseCase<QrVerificationEntity, GetQrVerificationParams> {
  final QrSessionRepository repository;

  GetQrVerificationUsecase(this.repository);

  @override
  Future<Either<String, QrVerificationEntity>> call(
    GetQrVerificationParams params,
  ) async {
    return repository.getQrVerification(sessionToken: params.sessionToken);
  }
}

class GetQrVerificationParams {
  final String sessionToken;

  const GetQrVerificationParams({required this.sessionToken});
}
