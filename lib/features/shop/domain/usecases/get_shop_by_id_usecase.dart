import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetShopByIdUsecase implements UseCase<ShopEntity?, String> {
  final ShopRepository repository;

  GetShopByIdUsecase(this.repository);

  @override
  Future<Either<String, ShopEntity?>> call(String shopId) {
    return repository.getShopById(shopId);
  }
}
