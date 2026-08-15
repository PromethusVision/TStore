import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/review_repository.dart';

class SubmitProductReviewUsecase {
  final ReviewRepository repository;

  SubmitProductReviewUsecase(this.repository);

  Future<Either<ReviewFailure, SubmitProductReviewResult>> call(
    SubmitProductReviewParams params,
  ) {
    return repository.submitReview(
      productId: params.productId,
      rating: params.rating,
      title: params.title,
      comment: params.comment,
    );
  }
}

class SubmitProductReviewParams {
  final String productId;
  final int rating;
  final String? title;
  final String? comment;

  const SubmitProductReviewParams({
    required this.productId,
    required this.rating,
    this.title,
    this.comment,
  });
}
