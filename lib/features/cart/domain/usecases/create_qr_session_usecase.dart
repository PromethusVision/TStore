import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';

class CreateQrSessionUsecase
    implements UseCase<QrSessionEntity, CreateQrSessionParams> {
  final QrSessionRepository repository;

  CreateQrSessionUsecase(this.repository);

  @override
  Future<Either<String, QrSessionEntity>> call(
    CreateQrSessionParams params,
  ) async {
    return await repository.createQrSession(cartId: params.cartId);
  }
}

class CreateQrSessionParams {
  final String cartId;

  const CreateQrSessionParams({required this.cartId});
}
