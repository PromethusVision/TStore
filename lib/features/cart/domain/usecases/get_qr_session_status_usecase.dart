import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class GetQrSessionStatusUsecase
    implements UseCase<String, GetQrSessionStatusParams> {
  final QrSessionRepository repository;

  GetQrSessionStatusUsecase(this.repository);

  @override
  Future<Either<String, String>> call(GetQrSessionStatusParams params) async {
    return repository.getQrSessionStatus(sessionId: params.sessionId);
  }
}

class GetQrSessionStatusParams {
  final String sessionId;

  const GetQrSessionStatusParams({required this.sessionId});
}
