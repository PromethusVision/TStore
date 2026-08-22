import 'package:dartz/dartz.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository repository;

  UpdatePasswordUsecase(this.repository);

  Future<Either<PasswordRecoveryFailure, PasswordRecoveryVerification>> call(
    UpdatePasswordParams params,
  ) {
    return repository.updatePassword(params);
  }
}
