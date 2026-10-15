import 'package:t_store/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.rating,
    super.title,
    super.comment,
    super.images,
    super.isVerifiedPurchase,
    super.helpfulCount,
    super.createdAt,
    super.updatedAt,
    super.canEdit,
    super.canWithdraw,
    super.withdrawn,
    super.reviewVersion,
    super.editUntil,
    super.merchantReply,
    super.userName,
    super.userAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      canEdit: json['can_edit'] as bool? ?? false,
      canWithdraw: json['can_withdraw'] as bool? ?? false,
      withdrawn: json['withdrawn'] as bool? ?? false,
      reviewVersion: json['review_version'] as int? ?? 1,
      editUntil: json['edit_until'] == null
          ? null
          : DateTime.parse(json['edit_until'] as String),
      merchantReply: json['merchant_reply'] as String?,
      userName: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['full_name'] as String?
          : null,
      userAvatar: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['avatar_url'] as String?
          : null,
    );
  }
}
