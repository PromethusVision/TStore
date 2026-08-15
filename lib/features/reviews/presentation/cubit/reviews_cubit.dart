import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/usecases/delete_product_review_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/get_product_review_eligibility_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/get_product_reviews_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/submit_product_review_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/update_product_review_usecase.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final GetProductReviewsUsecase getProductReviewsUsecase;
  final GetProductReviewEligibilityUsecase getEligibilityUsecase;
  final SubmitProductReviewUsecase submitReviewUsecase;
  final UpdateProductReviewUsecase updateReviewUsecase;
  final DeleteProductReviewUsecase deleteReviewUsecase;

  ReviewsCubit({
    required this.getProductReviewsUsecase,
    required this.getEligibilityUsecase,
    required this.submitReviewUsecase,
    required this.updateReviewUsecase,
    required this.deleteReviewUsecase,
  }) : super(ReviewsInitial());

  static const int _limit = 20;
  List<ReviewEntity> _allReviews = [];
  int _currentPage = 0;
  int _requestEpoch = 0;
  String? _productId;
  bool _isLoading = false;
  bool _mutationInFlight = false;

  Future<void> getProductReviews(String productId, {bool refresh = false}) {
    final normalizedProductId = productId.trim();
    final productChanged = _productId != normalizedProductId;
    if (_isLoading && !refresh && !productChanged) return Future.value();

    if (refresh || productChanged) {
      _currentPage = 0;
      _allReviews = [];
    }
    _productId = normalizedProductId;
    return _loadPage(
      normalizedProductId,
      replace: refresh || productChanged || _currentPage == 0,
    );
  }

  Future<void> loadMoreReviews(String productId) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore ||
        _isLoading) {
      return;
    }
    emit(
      currentState.copyWith(isLoadingMore: true, clearLoadMoreFailure: true),
    );
    await _loadPage(productId.trim(), replace: false);
  }

  Future<ReviewMutationResult> submitReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    if (_mutationInFlight) return const ReviewMutationResult.ignored();
    if (rating < 1 || rating > 5) {
      return const ReviewMutationResult.failure(
        'Lütfen 1 ile 5 arasında bir puan seçin.',
      );
    }

    final normalizedProductId = productId.trim();
    _beginMutation();
    final result = await submitReviewUsecase(
      SubmitProductReviewParams(
        productId: normalizedProductId,
        rating: rating,
        title: title,
        comment: comment,
      ),
    );

    return result.fold(
      (failure) async {
        await _finishFailedMutation(normalizedProductId, failure);
        return ReviewMutationResult.failure(failure.message);
      },
      (submission) async {
        _mutationInFlight = false;
        await getProductReviews(normalizedProductId, refresh: true);
        if (submission.created) {
          return const ReviewMutationResult.success(
            'Değerlendirmeniz kaydedildi.',
          );
        }
        return const ReviewMutationResult.success(
          'Bu ürün için mevcut değerlendirmeniz gösteriliyor.',
          duplicate: true,
        );
      },
    );
  }

  Future<ReviewMutationResult> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    if (_mutationInFlight) return const ReviewMutationResult.ignored();
    if (rating < 1 || rating > 5) {
      return const ReviewMutationResult.failure(
        'Lütfen 1 ile 5 arasında bir puan seçin.',
      );
    }

    final normalizedProductId = productId.trim();
    _beginMutation(reviewId: reviewId);
    final result = await updateReviewUsecase(
      UpdateProductReviewParams(
        reviewId: reviewId,
        rating: rating,
        title: title,
        comment: comment,
      ),
    );

    return result.fold(
      (failure) async {
        await _finishFailedMutation(normalizedProductId, failure);
        return ReviewMutationResult.failure(failure.message);
      },
      (_) async {
        _mutationInFlight = false;
        await getProductReviews(normalizedProductId, refresh: true);
        return const ReviewMutationResult.success(
          'Değerlendirmeniz güncellendi.',
        );
      },
    );
  }

  Future<ReviewMutationResult> deleteReview({
    required String productId,
    required String reviewId,
  }) async {
    if (_mutationInFlight) return const ReviewMutationResult.ignored();

    final normalizedProductId = productId.trim();
    _beginMutation(reviewId: reviewId);
    final result = await deleteReviewUsecase(reviewId);

    return result.fold(
      (failure) async {
        await _finishFailedMutation(normalizedProductId, failure);
        return ReviewMutationResult.failure(failure.message);
      },
      (deletion) async {
        if (!deletion.deleted) {
          const failure = ReviewFailure(
            ReviewFailureKind.reviewNotFound,
            'Değerlendirme bulunamadı veya bu işlem tamamlanamadı.',
          );
          await _finishFailedMutation(normalizedProductId, failure);
          return ReviewMutationResult.failure(failure.message);
        }
        _mutationInFlight = false;
        await getProductReviews(normalizedProductId, refresh: true);
        return const ReviewMutationResult.success(
          'Değerlendirmeniz silindi. Dilerseniz yeniden değerlendirebilirsiniz.',
        );
      },
    );
  }

  Future<void> retryEligibility(String productId) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded) return;
    final result = await getEligibilityUsecase(productId.trim());
    if (isClosed || state is! ReviewsLoaded) return;
    result.fold(
      (failure) => emit(
        (state as ReviewsLoaded).copyWith(
          eligibilityFailure: failure,
          isMutating: false,
          clearMutatingReviewId: true,
        ),
      ),
      (eligibility) => emit(
        (state as ReviewsLoaded).copyWith(
          eligibility: eligibility,
          clearEligibilityFailure: true,
          isMutating: false,
          clearMutatingReviewId: true,
        ),
      ),
    );
  }

  void resetReviews() {
    _requestEpoch++;
    _currentPage = 0;
    _allReviews = [];
    _productId = null;
    _isLoading = false;
    _mutationInFlight = false;
    emit(ReviewsInitial());
  }

  Future<void> _loadPage(String productId, {required bool replace}) async {
    final requestEpoch = ++_requestEpoch;
    _isLoading = true;
    final page = replace ? 0 : _currentPage;
    if (replace) emit(ReviewsLoading());

    final reviewsFuture = getProductReviewsUsecase(
      GetProductReviewsParams(productId: productId, page: page, limit: _limit),
    );
    final eligibilityFuture = replace ? getEligibilityUsecase(productId) : null;

    final reviewsResult = await reviewsFuture;
    final eligibilityResult = eligibilityFuture == null
        ? null
        : await eligibilityFuture;
    if (isClosed || requestEpoch != _requestEpoch || _productId != productId) {
      return;
    }
    _isLoading = false;

    reviewsResult.fold(
      (failure) {
        final currentState = state;
        if (!replace && currentState is ReviewsLoaded) {
          emit(
            currentState.copyWith(
              loadMoreFailure: failure,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(ReviewsError(failure));
        }
      },
      (pageResult) {
        ProductReviewEligibility? eligibility;
        ReviewFailure? eligibilityFailure;
        if (eligibilityResult != null) {
          eligibilityResult.fold(
            (failure) => eligibilityFailure = failure,
            (value) => eligibility = value,
          );
        } else if (state is ReviewsLoaded) {
          eligibility = (state as ReviewsLoaded).eligibility;
          eligibilityFailure = (state as ReviewsLoaded).eligibilityFailure;
        }

        _allReviews = replace
            ? pageResult.reviews
            : _mergeReviews(_allReviews, pageResult.reviews);
        _currentPage = page + 1;
        emit(
          ReviewsLoaded(
            reviews: List.unmodifiable(_allReviews),
            stats: pageResult.stats,
            eligibility: eligibility,
            eligibilityFailure: eligibilityFailure,
            hasReachedMax: pageResult.reviews.length < _limit,
            currentPage: _currentPage,
          ),
        );
      },
    );
  }

  void _beginMutation({String? reviewId}) {
    _mutationInFlight = true;
    final currentState = state;
    if (currentState is ReviewsLoaded) {
      emit(
        currentState.copyWith(
          isMutating: true,
          mutatingReviewId: reviewId,
          clearMutatingReviewId: reviewId == null,
        ),
      );
    }
  }

  Future<void> _finishFailedMutation(
    String productId,
    ReviewFailure failure,
  ) async {
    _mutationInFlight = false;
    if (failure.kind == ReviewFailureKind.notVerified ||
        failure.kind == ReviewFailureKind.authRequired) {
      await retryEligibility(productId);
      return;
    }
    final currentState = state;
    if (!isClosed && currentState is ReviewsLoaded) {
      emit(
        currentState.copyWith(isMutating: false, clearMutatingReviewId: true),
      );
    }
  }

  static List<ReviewEntity> _mergeReviews(
    List<ReviewEntity> existing,
    List<ReviewEntity> incoming,
  ) {
    final byId = <String, ReviewEntity>{
      for (final review in existing) review.id: review,
      for (final review in incoming) review.id: review,
    };
    return byId.values.toList(growable: false);
  }
}
