import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetMyShopUsecase implements UseCase<ShopEntity?, NoParams> {
  final ShopRepository repository;

  GetMyShopUsecase(this.repository);

  @override
  Future<Either<String, ShopEntity?>> call(NoParams params) async {
    return await repository.getMyShop();
  }
}
