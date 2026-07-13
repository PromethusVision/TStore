import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class GetShopsUsecase implements UseCase<List<ShopEntity>, NoParams> {
  final ShopRepository repository;

  GetShopsUsecase(this.repository);

  @override
  Future<Either<String, List<ShopEntity>>> call(NoParams params) async {
    return repository.getShops();
  }
}
