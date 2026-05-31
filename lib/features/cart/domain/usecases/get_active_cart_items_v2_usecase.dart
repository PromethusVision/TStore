import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class GetActiveCartItemsV2Usecase
    implements UseCase<List<CartItemV2Entity>, NoParams> {
  final CartV2Repository repository;

  GetActiveCartItemsV2Usecase(this.repository);

  @override
  Future<Either<String, List<CartItemV2Entity>>> call(NoParams params) async {
    return await repository.getActiveCartItems();
  }
}
