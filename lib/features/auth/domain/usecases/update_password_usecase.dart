import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class UpdatePasswordUsecase implements UseCase<void, String> {
  final AuthRepository repository;

  UpdatePasswordUsecase(this.repository);

  @override
  Future<Either<String, void>> call(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}
