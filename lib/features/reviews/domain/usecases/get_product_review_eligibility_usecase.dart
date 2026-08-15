import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/review_repository.dart';

class GetProductReviewEligibilityUsecase {
  final ReviewRepository repository;

  GetProductReviewEligibilityUsecase(this.repository);

  Future<Either<ReviewFailure, ProductReviewEligibility>> call(
    String productId,
  ) {
    return repository.getProductReviewEligibility(productId);
  }
}
