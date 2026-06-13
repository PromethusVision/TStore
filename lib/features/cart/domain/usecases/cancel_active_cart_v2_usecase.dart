import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class CancelActiveCartV2Usecase implements UseCase<Unit, NoParams> {
  final CartV2Repository repository;

  CancelActiveCartV2Usecase(this.repository);

  @override
  Future<Either<String, Unit>> call(NoParams params) async {
    return await repository.cancelActiveCart();
  }
}
