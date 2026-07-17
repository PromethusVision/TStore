import 'package:dartz/dartz.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class ResendConfirmationUsecase {
  final AuthRepository repository;

  ResendConfirmationUsecase(this.repository);

  Future<Either<String, void>> call(String email) {
    return repository.resendConfirmation(email);
  }
}
