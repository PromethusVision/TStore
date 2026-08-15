import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/reviews/data/models/review_model.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/review_repository.dart';

typedef ReviewRpcCaller =
    Future<dynamic> Function(String functionName, Map<String, dynamic> params);

class ReviewRepositoryImpl implements ReviewRepository {
  static const String getReviewsRpc = 'get_product_reviews';
  static const String getEligibilityRpc = 'get_product_review_eligibility';
  static const String submitReviewRpc = 'submit_product_review';
  static const String updateReviewRpc = 'update_product_review';
  static const String deleteReviewRpc = 'delete_product_review';

  final SupabaseService supabaseService;
  final ReviewRpcCaller _rpcCaller;

  ReviewRepositoryImpl({
    required this.supabaseService,
    ReviewRpcCaller? rpcCaller,
  }) : _rpcCaller =
           rpcCaller ??
           ((functionName, params) =>
               supabaseService.client.rpc(functionName, params: params));

  bool get _isAuthenticated => supabaseService.currentUser != null;

  @override
  Future<Either<ReviewFailure, ProductReviewsPage>> getProductReviews(
    String productId, {
    int page = 0,
    int limit = 20,
  }) async {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty || page < 0 || limit < 1 || limit > 50) {
      return const Left(_invalidArgumentFailure);
    }

    try {
      final response = await _rpcCaller(getReviewsRpc, {
        'p_product_id': normalizedProductId,
        'p_limit': limit,
        'p_offset': page * limit,
      });
      final json = _jsonObject(response);
      final reviewsJson = _jsonList(json['reviews'], field: 'reviews');
      final distributionJson = _jsonObject(
        json['rating_distribution'],
        field: 'rating_distribution',
      );

      return Right(
        ProductReviewsPage(
          productId: _requiredString(json, 'product_id'),
          reviews: reviewsJson
              .map(ReviewModel.fromJson)
              .toList(growable: false),
          stats: ProductReviewStats(
            averageRating: _toDouble(json['average_rating']),
            totalReviews: _toInt(json['review_count']),
            ratingDistribution: {
              for (var rating = 1; rating <= 5; rating++)
                rating: _toInt(distributionJson['$rating']),
            },
          ),
        ),
      );
    } catch (error) {
      return Left(_mapFailure(error, fallback: _loadFailure));
    }
  }

  @override
  Future<Either<ReviewFailure, ProductReviewEligibility>>
  getProductReviewEligibility(String productId) async {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) {
      return const Left(_invalidArgumentFailure);
    }
    if (!_isAuthenticated) {
      return Right(ProductReviewEligibility.guest(normalizedProductId));
    }

    try {
      final response = await _rpcCaller(getEligibilityRpc, {
        'p_product_id': normalizedProductId,
      });
      final json = _jsonObject(response);
      return Right(
        ProductReviewEligibility(
          productId: _requiredString(json, 'product_id'),
          eligible: _requiredBool(json, 'eligible'),
          canSubmit: _requiredBool(json, 'can_submit'),
          existingReviewId: _optionalString(json['existing_review_id']),
          verifiedTransactionItemId: _optionalString(
            json['verified_transaction_item_id'],
          ),
          verifiedTransactionId: _optionalString(
            json['verified_transaction_id'],
          ),
          verifiedAt: _optionalDate(json['verified_at']),
        ),
      );
    } catch (error) {
      return Left(_mapFailure(error, fallback: _eligibilityFailure));
    }
  }

  @override
  Future<Either<ReviewFailure, SubmitProductReviewResult>> submitReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    final authFailure = _authenticatedMutationFailure();
    if (authFailure != null) return Left(authFailure);
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) {
      return const Left(_invalidArgumentFailure);
    }
    if (rating < 1 || rating > 5) {
      return const Left(_invalidRatingFailure);
    }

    try {
      final response = await _rpcCaller(submitReviewRpc, {
        'p_product_id': normalizedProductId,
        'p_rating': rating,
        'p_title': _optionalInput(title),
        'p_comment': _optionalInput(comment),
      });
      final json = _jsonObject(response);
      return Right(
        SubmitProductReviewResult(
          created: _requiredBool(json, 'created'),
          review: ReviewModel.fromJson(
            _jsonObject(json['review'], field: 'review'),
          ),
        ),
      );
    } catch (error) {
      return Left(_mapFailure(error, fallback: _submitFailure));
    }
  }

  @override
  Future<Either<ReviewFailure, ReviewEntity>> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    final authFailure = _authenticatedMutationFailure();
    if (authFailure != null) return Left(authFailure);
    final normalizedReviewId = reviewId.trim();
    if (normalizedReviewId.isEmpty) {
      return const Left(_invalidArgumentFailure);
    }
    if (rating < 1 || rating > 5) {
      return const Left(_invalidRatingFailure);
    }

    try {
      final response = await _rpcCaller(updateReviewRpc, {
        'p_review_id': normalizedReviewId,
        'p_rating': rating,
        'p_title': _optionalInput(title),
        'p_comment': _optionalInput(comment),
      });
      return Right(ReviewModel.fromJson(_jsonObject(response)));
    } catch (error) {
      return Left(_mapFailure(error, fallback: _updateFailure));
    }
  }

  @override
  Future<Either<ReviewFailure, DeleteProductReviewResult>> deleteReview(
    String reviewId,
  ) async {
    final authFailure = _authenticatedMutationFailure();
    if (authFailure != null) return Left(authFailure);
    final normalizedReviewId = reviewId.trim();
    if (normalizedReviewId.isEmpty) {
      return const Left(_invalidArgumentFailure);
    }

    try {
      final response = await _rpcCaller(deleteReviewRpc, {
        'p_review_id': normalizedReviewId,
      });
      final json = _jsonObject(response);
      return Right(
        DeleteProductReviewResult(
          reviewId: _requiredString(json, 'review_id'),
          deleted: _requiredBool(json, 'deleted'),
        ),
      );
    } catch (error) {
      return Left(_mapFailure(error, fallback: _deleteFailure));
    }
  }

  ReviewFailure? _authenticatedMutationFailure() {
    if (_isAuthenticated) return null;
    return _authFailure;
  }

  static Map<String, dynamic> _jsonObject(
    dynamic response, {
    String field = 'response',
  }) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response is List && response.length == 1) {
      return _jsonObject(response.single, field: field);
    }
    throw FormatException('$field must be a JSON object.');
  }

  static List<Map<String, dynamic>> _jsonList(
    dynamic value, {
    required String field,
  }) {
    if (value is! List) throw FormatException('$field must be a JSON array.');
    return value
        .map((item) => _jsonObject(item, field: field))
        .toList(growable: false);
  }

  static String _requiredString(Map<String, dynamic> json, String field) {
    final value = _optionalString(json[field]);
    if (value == null) throw FormatException('$field is required.');
    return value;
  }

  static String? _optionalString(dynamic value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static bool _requiredBool(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is bool) return value;
    throw FormatException('$field must be a boolean.');
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }

  static DateTime? _optionalDate(dynamic value) {
    final normalized = _optionalString(value);
    return normalized == null ? null : DateTime.parse(normalized);
  }

  static String? _optionalInput(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static ReviewFailure _mapFailure(
    Object error, {
    required ReviewFailure fallback,
  }) {
    final rawMessage = error.toString();
    final normalized = rawMessage.toLowerCase();
    final code = error is PostgrestException
        ? (error.code ?? '').toUpperCase()
        : '';

    if (rawMessage.contains('[REVIEW_AUTH_REQUIRED]') || code == '28000') {
      return _authFailure;
    }
    if (rawMessage.contains('[REVIEW_INVALID_RATING]')) {
      return _invalidRatingFailure;
    }
    if (rawMessage.contains('[REVIEW_INVALID_ARGUMENT]') || code == '22023') {
      return _invalidArgumentFailure;
    }
    if (rawMessage.contains('[REVIEW_PRODUCT_NOT_FOUND]')) {
      return _productNotFoundFailure;
    }
    if (rawMessage.contains('[REVIEW_NOT_VERIFIED]')) {
      return _notVerifiedFailure;
    }
    if (rawMessage.contains('[REVIEW_NOT_FOUND]')) {
      return _reviewNotFoundFailure;
    }
    if (rawMessage.contains('[REVIEW_EVIDENCE_IMMUTABLE]') ||
        rawMessage.contains('[REVIEW_EVIDENCE_MISMATCH]') ||
        code == '42501') {
      return _unauthorizedFailure;
    }
    if (error is FormatException) return _invalidResponseFailure;

    final friendly = CustomerErrorMessage.from(error, fallback: '');
    if (friendly == CustomerErrorMessage.connection) {
      return _networkFailure;
    }
    if (friendly == CustomerErrorMessage.serviceUnavailable) {
      return _unavailableFailure;
    }
    if (friendly == CustomerErrorMessage.sessionExpired ||
        normalized.contains('jwt')) {
      return _authFailure;
    }
    return fallback;
  }

  static const _authFailure = ReviewFailure(
    ReviewFailureKind.authRequired,
    'Devam etmek için lütfen giriş yapın.',
  );
  static const _invalidArgumentFailure = ReviewFailure(
    ReviewFailureKind.invalidArgument,
    'Değerlendirme bilgileri geçersiz. Lütfen tekrar deneyin.',
  );
  static const _invalidRatingFailure = ReviewFailure(
    ReviewFailureKind.invalidRating,
    'Lütfen 1 ile 5 arasında bir puan seçin.',
  );
  static const _productNotFoundFailure = ReviewFailure(
    ReviewFailureKind.productNotFound,
    'Bu ürün artık değerlendirilemiyor.',
  );
  static const _notVerifiedFailure = ReviewFailure(
    ReviewFailureKind.notVerified,
    'Bu ürünü yalnızca doğrulanmış mağaza içi alışverişten sonra '
    'değerlendirebilirsiniz.',
  );
  static const _reviewNotFoundFailure = ReviewFailure(
    ReviewFailureKind.reviewNotFound,
    'Değerlendirme bulunamadı veya bu işlem tamamlanamadı.',
  );
  static const _unauthorizedFailure = ReviewFailure(
    ReviewFailureKind.unauthorized,
    'Bu değerlendirme için işlem yapılamadı.',
  );
  static const _networkFailure = ReviewFailure(
    ReviewFailureKind.network,
    CustomerErrorMessage.connection,
  );
  static const _unavailableFailure = ReviewFailure(
    ReviewFailureKind.unavailable,
    CustomerErrorMessage.serviceUnavailable,
  );
  static const _invalidResponseFailure = ReviewFailure(
    ReviewFailureKind.invalidResponse,
    'Değerlendirme bilgileri alınamadı. Lütfen tekrar deneyin.',
  );
  static const _loadFailure = ReviewFailure(
    ReviewFailureKind.unknown,
    'Değerlendirmeler yüklenemedi. Lütfen tekrar deneyin.',
  );
  static const _eligibilityFailure = ReviewFailure(
    ReviewFailureKind.unknown,
    'Değerlendirme hakkınız kontrol edilemedi. Lütfen tekrar deneyin.',
  );
  static const _submitFailure = ReviewFailure(
    ReviewFailureKind.unknown,
    'Değerlendirmeniz kaydedilemedi. Lütfen tekrar deneyin.',
  );
  static const _updateFailure = ReviewFailure(
    ReviewFailureKind.unknown,
    'Değerlendirmeniz güncellenemedi. Lütfen tekrar deneyin.',
  );
  static const _deleteFailure = ReviewFailure(
    ReviewFailureKind.unknown,
    'Değerlendirmeniz silinemedi. Lütfen tekrar deneyin.',
  );
}
