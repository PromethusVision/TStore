import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class AddShopProductToCartV2Usecase
    implements UseCase<CartV2AddResult, AddShopProductToCartV2Params> {
  final CartV2Repository repository;

  AddShopProductToCartV2Usecase(this.repository);

  @override
  Future<Either<String, CartV2AddResult>> call(
    AddShopProductToCartV2Params params,
  ) async {
    return await repository.addShopProductToCart(
      shopProductId: params.shopProductId,
      quantity: params.quantity,
    );
  }
}

class AddShopProductToCartV2Params {
  final String shopProductId;
  final int quantity;

  const AddShopProductToCartV2Params({
    required this.shopProductId,
    required this.quantity,
  });
}
