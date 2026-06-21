import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetShopProductsByShopUsecase
    implements UseCase<List<ShopProductEntity>, GetShopProductsByShopParams> {
  final ShopRepository repository;

  GetShopProductsByShopUsecase(this.repository);

  @override
  Future<Either<String, List<ShopProductEntity>>> call(
    GetShopProductsByShopParams params,
  ) async {
    return await repository.getShopProductsByShop(params.shopId);
  }
}

class GetShopProductsByShopParams {
  final String shopId;

  const GetShopProductsByShopParams({
    required this.shopId,
  });
}
