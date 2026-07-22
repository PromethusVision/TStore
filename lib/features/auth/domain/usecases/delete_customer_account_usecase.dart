import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class DeleteCustomerAccountUsecase implements UseCase<void, NoParams> {
  const DeleteCustomerAccountUsecase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<String, void>> call(NoParams params) {
    return repository.deleteCurrentCustomerAccount();
  }
}
