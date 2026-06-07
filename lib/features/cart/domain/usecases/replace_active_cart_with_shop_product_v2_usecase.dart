import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class ReplaceActiveCartWithShopProductV2Usecase
    implements UseCase<CartV2AddResult, ReplaceActiveCartWithShopProductV2Params> {
  final CartV2Repository repository;

  ReplaceActiveCartWithShopProductV2Usecase(this.repository);

  @override
  Future<Either<String, CartV2AddResult>> call(
    ReplaceActiveCartWithShopProductV2Params params,
  ) async {
    return await repository.replaceActiveCartWithShopProduct(
      shopProductId: params.shopProductId,
      quantity: params.quantity,
    );
  }
}

class ReplaceActiveCartWithShopProductV2Params {
  final String shopProductId;
  final int quantity;

  const ReplaceActiveCartWithShopProductV2Params({
    required this.shopProductId,
    required this.quantity,
  });
}
