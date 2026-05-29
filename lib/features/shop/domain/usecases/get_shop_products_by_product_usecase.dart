import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetShopProductsByProductUsecase
    implements
        UseCase<List<ShopProductEntity>, GetShopProductsByProductParams> {
  final ShopRepository repository;

  GetShopProductsByProductUsecase(this.repository);

  @override
  Future<Either<String, List<ShopProductEntity>>> call(
    GetShopProductsByProductParams params,
  ) async {
    return await repository.getShopProductsByProduct(params.productId);
  }
}

class GetShopProductsByProductParams {
  final String productId;

  const GetShopProductsByProductParams({
    required this.productId,
  });
}
