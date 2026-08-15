import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockUser extends Mock implements User {}

void main() {
  const productId = '11111111-1111-4111-8111-111111111111';
  const reviewId = '22222222-2222-4222-8222-222222222222';
  const customerId = '33333333-3333-4333-8333-333333333333';
  final reviewJson = <String, dynamic>{
    'id': reviewId,
    'user_id': customerId,
    'product_id': productId,
    'rating': 5,
    'title': 'Taze ürün',
    'comment': 'Mağazadan aynı gün aldım.',
    'images': <String>[],
    'is_verified_purchase': true,
    'helpful_count': 2,
    'created_at': '2026-08-15T10:00:00Z',
    'updated_at': '2026-08-15T10:00:00Z',
    'can_edit': true,
  };

  late MockSupabaseService service;
  late MockUser user;
  late List<({String name, Map<String, dynamic> params})> calls;
  late Future<dynamic> Function(String, Map<String, dynamic>) handler;
  late ReviewRepositoryImpl repository;

  setUp(() {
    service = MockSupabaseService();
    user = MockUser();
    when(() => user.id).thenReturn(customerId);
    when(() => service.currentUser).thenReturn(user);
    calls = [];
    handler = (_, _) async => throw UnimplementedError();
    repository = ReviewRepositoryImpl(
      supabaseService: service,
      rpcCaller: (name, params) {
        calls.add((name: name, params: params));
        return handler(name, params);
      },
    );
  });

  test(
    'canonical read RPC authoritative aggregate ve pagination döndürür',
    () async {
      handler = (name, params) async => {
        'product_id': productId,
        'average_rating': 4.5,
        'review_count': 2,
        'rating_distribution': {'1': 0, '2': 0, '3': 0, '4': 1, '5': 1},
        'reviews': [reviewJson],
      };

      final result = await repository.getProductReviews(
        productId,
        page: 2,
        limit: 20,
      );

      final page = result.getOrElse(() => throw StateError('expected page'));
      expect(page.stats.averageRating, 4.5);
      expect(page.stats.totalReviews, 2);
      expect(page.stats.ratingDistribution[4], 1);
      expect(page.reviews.single.isVerifiedPurchase, isTrue);
      expect(page.reviews.single.canEdit, isTrue);
      expect(calls.single.name, ReviewRepositoryImpl.getReviewsRpc);
      expect(calls.single.params, {
        'p_product_id': productId,
        'p_limit': 20,
        'p_offset': 40,
      });
    },
  );

  test('guest eligibility RPC çağırmadan login state döndürür', () async {
    when(() => service.currentUser).thenReturn(null);

    final result = await repository.getProductReviewEligibility(productId);

    expect(
      result.getOrElse(() => throw StateError('expected eligibility')).status,
      ProductReviewEligibilityStatus.guest,
    );
    expect(calls, isEmpty);
  });

  test(
    'unverified, verified ve existing eligibility alanları exact parse edilir',
    () async {
      handler = (_, _) async => {
        'product_id': productId,
        'eligible': false,
        'can_submit': false,
        'existing_review_id': null,
        'verified_transaction_item_id': null,
        'verified_transaction_id': null,
        'verified_at': null,
      };
      final unverified = await repository.getProductReviewEligibility(
        productId,
      );
      expect(
        unverified.getOrElse(() => throw StateError('expected')).status,
        ProductReviewEligibilityStatus.unverified,
      );

      handler = (_, _) async => {
        'product_id': productId,
        'eligible': true,
        'can_submit': true,
        'existing_review_id': null,
        'verified_transaction_item_id': 'item-1',
        'verified_transaction_id': 'transaction-1',
        'verified_at': '2026-08-15T09:00:00Z',
      };
      final verified = await repository.getProductReviewEligibility(productId);
      expect(
        verified.getOrElse(() => throw StateError('expected')).status,
        ProductReviewEligibilityStatus.canSubmit,
      );

      handler = (_, _) async => {
        'product_id': productId,
        'eligible': true,
        'can_submit': false,
        'existing_review_id': reviewId,
        'verified_transaction_item_id': 'item-1',
        'verified_transaction_id': 'transaction-1',
        'verified_at': '2026-08-15T09:00:00Z',
      };
      final existing = await repository.getProductReviewEligibility(productId);
      expect(
        existing.getOrElse(() => throw StateError('expected')).status,
        ProductReviewEligibilityStatus.existingReview,
      );
    },
  );

  test(
    'submit yalnız frozen RPC alanlarını yollar ve verified flag üretmez',
    () async {
      final mutationReviewJson = {...reviewJson}..remove('can_edit');
      handler = (_, _) async => {'created': true, 'review': mutationReviewJson};

      final result = await repository.submitReview(
        productId: ' $productId ',
        rating: 5,
        title: ' Başlık ',
        comment: ' Yorum ',
      );

      expect(result.isRight(), isTrue);
      expect(calls.single.name, ReviewRepositoryImpl.submitReviewRpc);
      expect(calls.single.params, {
        'p_product_id': productId,
        'p_rating': 5,
        'p_title': 'Başlık',
        'p_comment': 'Yorum',
      });
      expect(calls.single.params, isNot(contains('is_verified_purchase')));
      expect(calls.single.params, isNot(contains('user_id')));
      expect(calls.single.params, isNot(contains('images')));
    },
  );

  test('duplicate submit created false sonucu hata olmadan döner', () async {
    handler = (_, _) async => {'created': false, 'review': reviewJson};

    final result = await repository.submitReview(
      productId: productId,
      rating: 4,
    );
    final submission = result.getOrElse(() => throw StateError('expected'));

    expect(submission.created, isFalse);
    expect(submission.review.id, reviewId);
  });

  test(
    'REVIEW_NOT_VERIFIED stable tag 42501 den önce özel map edilir',
    () async {
      handler = (_, _) async => throw const PostgrestException(
        message: '[REVIEW_NOT_VERIFIED] verified purchase required',
        code: '42501',
      );

      final result = await repository.submitReview(
        productId: productId,
        rating: 5,
      );

      expect(
        result,
        isA<Left<ReviewFailure, SubmitProductReviewResult>>().having(
          (left) => left.value.kind,
          'kind',
          ReviewFailureKind.notVerified,
        ),
      );
    },
  );

  test('wrong product ve invalid rating güvenli hata döndürür', () async {
    handler = (_, _) async => throw const PostgrestException(
      message: '[REVIEW_NOT_VERIFIED] no evidence',
      code: '42501',
    );
    final wrongProduct = await repository.submitReview(
      productId: '44444444-4444-4444-8444-444444444444',
      rating: 5,
    );
    expect(
      wrongProduct.fold((failure) => failure.kind, (_) => null),
      ReviewFailureKind.notVerified,
    );

    calls.clear();
    final invalidRating = await repository.submitReview(
      productId: productId,
      rating: 6,
    );
    expect(
      invalidRating.fold((failure) => failure.kind, (_) => null),
      ReviewFailureKind.invalidRating,
    );
    expect(calls, isEmpty);
  });

  test(
    'update yalnız rating title comment gönderir ve evidence alanı yoktur',
    () async {
      handler = (_, _) async => {
        ...reviewJson,
        'rating': 4,
        'title': 'Güncel',
        'comment': 'Güncel yorum',
      };

      final result = await repository.updateReview(
        reviewId: reviewId,
        rating: 4,
        title: 'Güncel',
        comment: 'Güncel yorum',
      );

      expect(result.getOrElse(() => throw StateError('expected')).rating, 4);
      expect(calls.single.name, ReviewRepositoryImpl.updateReviewRpc);
      expect(calls.single.params, {
        'p_review_id': reviewId,
        'p_rating': 4,
        'p_title': 'Güncel',
        'p_comment': 'Güncel yorum',
      });
      expect(calls.single.params.keys, isNot(contains('product_id')));
      expect(calls.single.params.keys, isNot(contains('is_verified_purchase')));
    },
  );

  test(
    'delete false başka kullanıcı hakkında bilgi sızdırmadan korunur',
    () async {
      handler = (_, _) async => {'review_id': reviewId, 'deleted': false};

      final result = await repository.deleteReview(reviewId);

      expect(
        result.getOrElse(() => throw StateError('expected')).deleted,
        isFalse,
      );
      expect(calls.single.name, ReviewRepositoryImpl.deleteReviewRpc);
      expect(calls.single.params, {'p_review_id': reviewId});
    },
  );

  test(
    'network ve auth failures müşteri dostu kategorilere map edilir',
    () async {
      handler = (_, _) async => throw Exception('SocketException: offline');
      final network = await repository.getProductReviews(productId);
      expect(
        network.fold((failure) => failure.kind, (_) => null),
        ReviewFailureKind.network,
      );

      handler = (_, _) async => throw const PostgrestException(
        message: '[REVIEW_AUTH_REQUIRED] authentication required',
        code: '28000',
      );
      final auth = await repository.getProductReviewEligibility(productId);
      expect(
        auth.fold((failure) => failure.kind, (_) => null),
        ReviewFailureKind.authRequired,
      );
    },
  );
}
