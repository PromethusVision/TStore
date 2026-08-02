import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetShopProductsByProductIdsUsecase
    implements
        UseCase<List<ShopProductEntity>, GetShopProductsByProductIdsParams> {
  final ShopRepository repository;

  GetShopProductsByProductIdsUsecase(this.repository);

  @override
  Future<Either<String, List<ShopProductEntity>>> call(
    GetShopProductsByProductIdsParams params,
  ) {
    return repository.getShopProductsByProductIds(params.productIds);
  }
}

class GetShopProductsByProductIdsParams {
  final List<String> productIds;

  const GetShopProductsByProductIdsParams({required this.productIds});
}
