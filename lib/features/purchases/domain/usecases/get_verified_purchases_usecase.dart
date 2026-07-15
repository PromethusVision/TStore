import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_history_repository.dart';

class GetVerifiedPurchasesUsecase
    implements UseCase<List<VerifiedPurchaseEntity>, NoParams> {
  final PurchaseHistoryRepository repository;

  GetVerifiedPurchasesUsecase(this.repository);

  @override
  Future<Either<String, List<VerifiedPurchaseEntity>>> call(NoParams params) {
    return repository.getVerifiedPurchases();
  }
}
