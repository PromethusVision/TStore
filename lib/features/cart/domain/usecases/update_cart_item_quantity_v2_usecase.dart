import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class UpdateCartItemQuantityV2Usecase
    implements UseCase<Unit, UpdateCartItemQuantityV2Params> {
  final CartV2Repository repository;

  UpdateCartItemQuantityV2Usecase(this.repository);

  @override
  Future<Either<String, Unit>> call(
    UpdateCartItemQuantityV2Params params,
  ) async {
    return await repository.updateCartItemQuantity(
      cartItemId: params.cartItemId,
      quantity: params.quantity,
    );
  }
}

class UpdateCartItemQuantityV2Params {
  final String cartItemId;
  final int quantity;

  const UpdateCartItemQuantityV2Params({
    required this.cartItemId,
    required this.quantity,
  });
}
