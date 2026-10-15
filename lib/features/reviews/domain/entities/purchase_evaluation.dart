import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';

String newEvaluationRequestId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class ServiceCriteria extends Equatable {
  const ServiceCriteria({
    required this.friendliness,
    required this.communication,
    required this.cleanliness,
  });
  final int friendliness, communication, cleanliness;
  @override
  List<Object?> get props => [friendliness, communication, cleanliness];
  double get average => (friendliness + communication + cleanliness) / 3;
  bool get valid =>
      [friendliness, communication, cleanliness].every((v) => v >= 1 && v <= 5);
  Map<String, dynamic> toJson() => {
    'friendliness': friendliness,
    'communication': communication,
    'cleanliness': cleanliness,
  };
}

class PurchaseServiceEvaluation extends Equatable {
  const PurchaseServiceEvaluation({
    required this.criteria,
    required this.submittedAt,
    required this.valid,
  });
  final ServiceCriteria criteria;
  final DateTime submittedAt;
  final bool valid;
  @override
  List<Object?> get props => [criteria, submittedAt, valid];
}

class ServiceScores {
  const ServiceScores({
    required this.sampleCount,
    this.friendliness,
    this.communication,
    this.cleanliness,
    this.average,
  });
  final int sampleCount;
  final double? friendliness, communication, cleanliness, average;
}

class EvaluationProduct {
  const EvaluationProduct({
    required this.productId,
    required this.name,
    required this.canSubmit,
    this.existingReview,
  });
  final String productId, name;
  final bool canSubmit;
  final ReviewEntity? existingReview;
}

class PurchaseEvaluation {
  const PurchaseEvaluation({
    required this.purchaseId,
    required this.shopId,
    required this.shopName,
    required this.enabled,
    required this.valid,
    required this.products,
    this.service,
  });
  final String purchaseId, shopId, shopName;
  final bool enabled, valid;
  final ServiceCriteria? service;
  final List<EvaluationProduct> products;
}

class ProductEvaluationInput {
  const ProductEvaluationInput({
    required this.productId,
    required this.rating,
    this.title,
    this.comment,
  });
  final String productId;
  final int rating;
  final String? title, comment;
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'rating': rating,
    'title': title,
    'comment': comment,
  };
  bool get valid =>
      rating >= 1 &&
      rating <= 5 &&
      (title?.length ?? 0) <= 120 &&
      (comment?.length ?? 0) <= 2000;
}

/// Keep this immutable command across an uncertain response and retry it verbatim.
class PurchaseEvaluationCommand {
  PurchaseEvaluationCommand({
    required this.purchaseId,
    required this.requestId,
    required List<ProductEvaluationInput> products,
    this.service,
  }) : products = List.unmodifiable(products);
  final String purchaseId, requestId;
  final ServiceCriteria? service;
  final List<ProductEvaluationInput> products;
}

enum MerchantReviewFilter { all, unanswered, replied, reported }

class MerchantReview {
  const MerchantReview({
    required this.id,
    required this.revisionId,
    required this.productId,
    required this.productName,
    required this.visibility,
    required this.canReply,
    required this.replied,
    required this.reported,
    this.rating,
    this.title,
    this.comment,
    this.reply,
    this.updatedAt,
  });
  final String id, revisionId, productId, productName, visibility;
  final int? rating;
  final String? title, comment, reply;
  final DateTime? updatedAt;
  final bool canReply, replied, reported;
  bool get visible => visibility == 'visible';
}

class MerchantReviewsPage {
  const MerchantReviewsPage({
    required this.shopId,
    required this.scores,
    required this.awaitingReplyCount,
    required this.total,
    required this.reviews,
  });
  final String shopId;
  final ServiceScores scores;
  final int awaitingReplyCount, total;
  final List<MerchantReview> reviews;
}
