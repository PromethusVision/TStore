import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/review_repository.dart';

class UpdateProductReviewUsecase {
  final ReviewRepository repository;

  UpdateProductReviewUsecase(this.repository);

  Future<Either<ReviewFailure, ReviewEntity>> call(
    UpdateProductReviewParams params,
  ) {
    return repository.updateReview(
      reviewId: params.reviewId,
      rating: params.rating,
      title: params.title,
      comment: params.comment,
    );
  }
}

class UpdateProductReviewParams {
  final String reviewId;
  final int rating;
  final String? title;
  final String? comment;

  const UpdateProductReviewParams({
    required this.reviewId,
    required this.rating,
    this.title,
    this.comment,
  });
}
