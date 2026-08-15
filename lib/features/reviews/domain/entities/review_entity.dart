import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool canEdit;

  // Joined data
  final String? userName;
  final String? userAvatar;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.title,
    this.comment,
    this.images,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.createdAt,
    this.updatedAt,
    this.canEdit = false,
    this.userName,
    this.userAvatar,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    productId,
    rating,
    title,
    comment,
    images,
    isVerifiedPurchase,
    helpfulCount,
    createdAt,
    updatedAt,
    canEdit,
    userName,
    userAvatar,
  ];

  ReviewEntity copyWith({
    String? id,
    String? userId,
    String? productId,
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? canEdit,
    String? userName,
    String? userAvatar,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canEdit: canEdit ?? this.canEdit,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }
}

class ProductReviewsPage extends Equatable {
  final String productId;
  final List<ReviewEntity> reviews;
  final ProductReviewStats stats;

  const ProductReviewsPage({
    required this.productId,
    required this.reviews,
    required this.stats,
  });

  @override
  List<Object?> get props => [productId, reviews, stats];
}

enum ProductReviewEligibilityStatus {
  guest,
  unverified,
  canSubmit,
  existingReview,
}

class ProductReviewEligibility extends Equatable {
  final String productId;
  final bool isGuest;
  final bool eligible;
  final bool canSubmit;
  final String? existingReviewId;
  final String? verifiedTransactionItemId;
  final String? verifiedTransactionId;
  final DateTime? verifiedAt;

  const ProductReviewEligibility({
    required this.productId,
    this.isGuest = false,
    required this.eligible,
    required this.canSubmit,
    this.existingReviewId,
    this.verifiedTransactionItemId,
    this.verifiedTransactionId,
    this.verifiedAt,
  });

  const ProductReviewEligibility.guest(this.productId)
    : isGuest = true,
      eligible = false,
      canSubmit = false,
      existingReviewId = null,
      verifiedTransactionItemId = null,
      verifiedTransactionId = null,
      verifiedAt = null;

  ProductReviewEligibilityStatus get status {
    if (isGuest) return ProductReviewEligibilityStatus.guest;
    if (existingReviewId != null) {
      return ProductReviewEligibilityStatus.existingReview;
    }
    if (eligible && canSubmit) {
      return ProductReviewEligibilityStatus.canSubmit;
    }
    return ProductReviewEligibilityStatus.unverified;
  }

  @override
  List<Object?> get props => [
    productId,
    isGuest,
    eligible,
    canSubmit,
    existingReviewId,
    verifiedTransactionItemId,
    verifiedTransactionId,
    verifiedAt,
  ];
}

class SubmitProductReviewResult extends Equatable {
  final bool created;
  final ReviewEntity review;

  const SubmitProductReviewResult({
    required this.created,
    required this.review,
  });

  @override
  List<Object?> get props => [created, review];
}

class DeleteProductReviewResult extends Equatable {
  final String reviewId;
  final bool deleted;

  const DeleteProductReviewResult({
    required this.reviewId,
    required this.deleted,
  });

  @override
  List<Object?> get props => [reviewId, deleted];
}

class ProductReviewStats extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ProductReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  int get fiveStarCount => ratingDistribution[5] ?? 0;
  int get fourStarCount => ratingDistribution[4] ?? 0;
  int get threeStarCount => ratingDistribution[3] ?? 0;
  int get twoStarCount => ratingDistribution[2] ?? 0;
  int get oneStarCount => ratingDistribution[1] ?? 0;

  double getPercentage(int stars) {
    if (totalReviews == 0) return 0;
    return (ratingDistribution[stars] ?? 0) / totalReviews * 100;
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingDistribution];
}
