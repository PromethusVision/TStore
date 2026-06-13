import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class RemoveCartItemV2Usecase implements UseCase<Unit, RemoveCartItemV2Params> {
  final CartV2Repository repository;

  RemoveCartItemV2Usecase(this.repository);

  @override
  Future<Either<String, Unit>> call(RemoveCartItemV2Params params) async {
    return await repository.removeCartItem(
      cartItemId: params.cartItemId,
    );
  }
}

class RemoveCartItemV2Params {
  final String cartItemId;

  const RemoveCartItemV2Params({
    required this.cartItemId,
  });
}
