import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/product_repository.dart';

class GetProductsByIdsUsecase {
  const GetProductsByIdsUsecase(this.repository);

  final ProductRepository repository;

  Future<Either<String, List<ProductEntity>>> call(List<String> productIds) {
    if (productIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return repository.getProductsByIds(productIds);
  }
}
