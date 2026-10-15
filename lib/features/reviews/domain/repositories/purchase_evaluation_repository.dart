import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';

abstract class PurchaseEvaluationRepository {
  String? get currentUserId;
  Stream<String?> get sessionChanges;
  Future<Either<ReviewFailure, bool>> enabled();
  Future<Either<ReviewFailure, PurchaseEvaluation>> purchase(String purchaseId);
  Future<Either<ReviewFailure, Unit>> submit(PurchaseEvaluationCommand command);
  Future<Either<ReviewFailure, MerchantReviewsPage>> merchant(
    String shopId, {
    MerchantReviewFilter filter = MerchantReviewFilter.all,
    int offset = 0,
  });
  Future<Either<ReviewFailure, Unit>> reply({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String text,
  });
  Future<Either<ReviewFailure, Unit>> report({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String reason,
  });
}
