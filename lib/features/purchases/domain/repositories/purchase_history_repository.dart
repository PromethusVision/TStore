import 'package:dartz/dartz.dart';
import 'package:t_store/features/purchases/domain/entities/verified_purchase_entity.dart';

abstract class PurchaseHistoryRepository {
  Future<Either<String, List<VerifiedPurchaseEntity>>> getVerifiedPurchases();
}
