import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';

abstract class ReviewRepository {
  Future<Either<ReviewFailure, ProductReviewsPage>> getProductReviews(
    String productId, {
    int page = 0,
    int limit = 20,
  });

  Future<Either<ReviewFailure, ProductReviewEligibility>>
  getProductReviewEligibility(String productId);

  Future<Either<ReviewFailure, SubmitProductReviewResult>> submitReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  });

  Future<Either<ReviewFailure, ReviewEntity>> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  });

  Future<Either<ReviewFailure, DeleteProductReviewResult>> deleteReview(
    String reviewId,
  );
}
