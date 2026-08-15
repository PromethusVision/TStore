import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/review_repository.dart';

class DeleteProductReviewUsecase {
  final ReviewRepository repository;

  DeleteProductReviewUsecase(this.repository);

  Future<Either<ReviewFailure, DeleteProductReviewResult>> call(
    String reviewId,
  ) {
    return repository.deleteReview(reviewId);
  }
}
