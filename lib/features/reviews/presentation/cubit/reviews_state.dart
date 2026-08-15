import 'package:equatable/equatable.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;
  final ProductReviewStats stats;
  final ProductReviewEligibility? eligibility;
  final ReviewFailure? eligibilityFailure;
  final ReviewFailure? loadMoreFailure;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final bool isMutating;
  final String? mutatingReviewId;

  const ReviewsLoaded({
    required this.reviews,
    required this.stats,
    this.eligibility,
    this.eligibilityFailure,
    this.loadMoreFailure,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.isMutating = false,
    this.mutatingReviewId,
  });

  ReviewEntity? get editableReview {
    for (final review in reviews) {
      if (review.canEdit) return review;
    }
    return null;
  }

  ReviewsLoaded copyWith({
    List<ReviewEntity>? reviews,
    ProductReviewStats? stats,
    ProductReviewEligibility? eligibility,
    ReviewFailure? eligibilityFailure,
    ReviewFailure? loadMoreFailure,
    bool clearEligibilityFailure = false,
    bool clearLoadMoreFailure = false,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    bool? isMutating,
    String? mutatingReviewId,
    bool clearMutatingReviewId = false,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      eligibility: eligibility ?? this.eligibility,
      eligibilityFailure: clearEligibilityFailure
          ? null
          : eligibilityFailure ?? this.eligibilityFailure,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : loadMoreFailure ?? this.loadMoreFailure,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMutating: isMutating ?? this.isMutating,
      mutatingReviewId: clearMutatingReviewId
          ? null
          : mutatingReviewId ?? this.mutatingReviewId,
    );
  }

  @override
  List<Object?> get props => [
    reviews,
    stats,
    eligibility,
    eligibilityFailure,
    loadMoreFailure,
    hasReachedMax,
    currentPage,
    isLoadingMore,
    isMutating,
    mutatingReviewId,
  ];
}

class ReviewsError extends ReviewsState {
  final ReviewFailure failure;

  const ReviewsError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

class ReviewMutationResult extends Equatable {
  final bool succeeded;
  final bool duplicate;
  final bool ignored;
  final String message;

  const ReviewMutationResult._({
    required this.succeeded,
    required this.duplicate,
    required this.ignored,
    required this.message,
  });

  const ReviewMutationResult.success(String message, {bool duplicate = false})
    : this._(
        succeeded: true,
        duplicate: duplicate,
        ignored: false,
        message: message,
      );

  const ReviewMutationResult.failure(String message)
    : this._(
        succeeded: false,
        duplicate: false,
        ignored: false,
        message: message,
      );

  const ReviewMutationResult.ignored()
    : this._(succeeded: false, duplicate: false, ignored: true, message: '');

  @override
  List<Object?> get props => [succeeded, duplicate, ignored, message];
}
