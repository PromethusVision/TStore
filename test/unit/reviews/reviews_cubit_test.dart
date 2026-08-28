import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/usecases/delete_product_review_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/get_product_review_eligibility_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/get_product_reviews_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/submit_product_review_usecase.dart';
import 'package:t_store/features/reviews/domain/usecases/update_product_review_usecase.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';

class MockGetProductReviewsUsecase extends Mock
    implements GetProductReviewsUsecase {}

class MockGetProductReviewEligibilityUsecase extends Mock
    implements GetProductReviewEligibilityUsecase {}

class MockSubmitProductReviewUsecase extends Mock
    implements SubmitProductReviewUsecase {}

class MockUpdateProductReviewUsecase extends Mock
    implements UpdateProductReviewUsecase {}

class MockDeleteProductReviewUsecase extends Mock
    implements DeleteProductReviewUsecase {}

class FakeGetProductReviewsParams extends Fake
    implements GetProductReviewsParams {}

class FakeSubmitProductReviewParams extends Fake
    implements SubmitProductReviewParams {}

class FakeUpdateProductReviewParams extends Fake
    implements UpdateProductReviewParams {}

void main() {
  const productId = 'product-1';
  const stats = ProductReviewStats(
    averageRating: 5,
    totalReviews: 1,
    ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 1},
  );
  final review = ReviewEntity(
    id: 'review-1',
    userId: 'customer-1',
    productId: productId,
    rating: 5,
    title: 'Çok iyi',
    comment: 'Memnun kaldım.',
    isVerifiedPurchase: true,
    canEdit: true,
    createdAt: DateTime(2026, 8, 15),
  );
  final page = ProductReviewsPage(
    productId: productId,
    reviews: [review],
    stats: stats,
  );
  const guest = ProductReviewEligibility.guest(productId);
  const unverified = ProductReviewEligibility(
    productId: productId,
    eligible: false,
    canSubmit: false,
  );
  const canSubmit = ProductReviewEligibility(
    productId: productId,
    eligible: true,
    canSubmit: true,
    verifiedTransactionItemId: 'item-1',
    verifiedTransactionId: 'transaction-1',
  );
  const existing = ProductReviewEligibility(
    productId: productId,
    eligible: true,
    canSubmit: false,
    existingReviewId: 'review-1',
    verifiedTransactionItemId: 'item-1',
    verifiedTransactionId: 'transaction-1',
  );

  late MockGetProductReviewsUsecase getReviews;
  late MockGetProductReviewEligibilityUsecase getEligibility;
  late MockSubmitProductReviewUsecase submitReview;
  late MockUpdateProductReviewUsecase updateReview;
  late MockDeleteProductReviewUsecase deleteReview;
  late ReviewsCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeGetProductReviewsParams());
    registerFallbackValue(FakeSubmitProductReviewParams());
    registerFallbackValue(FakeUpdateProductReviewParams());
  });

  setUp(() {
    getReviews = MockGetProductReviewsUsecase();
    getEligibility = MockGetProductReviewEligibilityUsecase();
    submitReview = MockSubmitProductReviewUsecase();
    updateReview = MockUpdateProductReviewUsecase();
    deleteReview = MockDeleteProductReviewUsecase();
    when(() => getReviews(any())).thenAnswer((_) async => Right(page));
    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(guest));
    cubit = ReviewsCubit(
      getProductReviewsUsecase: getReviews,
      getEligibilityUsecase: getEligibility,
      submitReviewUsecase: submitReview,
      updateReviewUsecase: updateReview,
      deleteReviewUsecase: deleteReview,
    );
  });

  tearDown(() => cubit.close());

  test('review listesi ve guest eligibility birlikte yüklenir', () async {
    await cubit.getProductReviews(productId);

    final loaded = cubit.state as ReviewsLoaded;
    expect(loaded.reviews, [review]);
    expect(loaded.stats, stats);
    expect(loaded.eligibility?.status, ProductReviewEligibilityStatus.guest);
    expect(loaded.currentPage, 1);
  });

  test('authenticated unverified müşteri ayrı eligibility durumudur', () async {
    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(unverified));

    await cubit.getProductReviews(productId);

    expect(
      (cubit.state as ReviewsLoaded).eligibility?.status,
      ProductReviewEligibilityStatus.unverified,
    );
  });

  test('verified müşteri submit edebilir ve mevcut review ayrılır', () async {
    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(canSubmit));
    await cubit.getProductReviews(productId);
    expect(
      (cubit.state as ReviewsLoaded).eligibility?.status,
      ProductReviewEligibilityStatus.canSubmit,
    );

    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(existing));
    await cubit.getProductReviews(productId, refresh: true);
    expect(
      (cubit.state as ReviewsLoaded).eligibility?.status,
      ProductReviewEligibilityStatus.existingReview,
    );
    expect((cubit.state as ReviewsLoaded).editableReview, review);
  });

  test(
    'network eligibility hatası review listesini gizlemez ve retry edilir',
    () async {
      const failure = ReviewFailure(
        ReviewFailureKind.network,
        'İnternet bağlantınızı kontrol edip tekrar deneyin.',
      );
      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Left(failure));
      await cubit.getProductReviews(productId);

      expect((cubit.state as ReviewsLoaded).reviews, [review]);
      expect((cubit.state as ReviewsLoaded).eligibilityFailure, failure);

      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Right(canSubmit));
      await cubit.retryEligibility(productId);
      expect((cubit.state as ReviewsLoaded).eligibility, canSubmit);
      expect((cubit.state as ReviewsLoaded).eligibilityFailure, isNull);
    },
  );

  test('stale slow response yeni refresh sonucunu ezmez', () async {
    final slow = Completer<Either<ReviewFailure, ProductReviewsPage>>();
    final freshReview = review.copyWith(id: 'review-fresh', rating: 4);
    final freshPage = ProductReviewsPage(
      productId: productId,
      reviews: [freshReview],
      stats: const ProductReviewStats(
        averageRating: 4,
        totalReviews: 1,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 1, 5: 0},
      ),
    );
    var callCount = 0;
    when(() => getReviews(any())).thenAnswer((_) {
      callCount++;
      return callCount == 1 ? slow.future : Future.value(Right(freshPage));
    });

    final first = cubit.getProductReviews(productId);
    final refresh = cubit.getProductReviews(productId, refresh: true);
    await refresh;
    slow.complete(Right(page));
    await first;

    expect((cubit.state as ReviewsLoaded).reviews, [freshReview]);
  });

  test(
    'verified submit liste, aggregate ve eligibility verisini yeniler',
    () async {
      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Right(canSubmit));
      when(() => submitReview(any())).thenAnswer(
        (_) async =>
            Right(SubmitProductReviewResult(created: true, review: review)),
      );
      await cubit.getProductReviews(productId);
      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Right(existing));

      final result = await cubit.submitReview(
        productId: productId,
        rating: 5,
        title: ' Çok iyi ',
        comment: ' Memnun kaldım. ',
      );

      expect(result.succeeded, isTrue);
      expect((cubit.state as ReviewsLoaded).eligibility, existing);
      final params =
          verify(() => submitReview(captureAny())).captured.single
              as SubmitProductReviewParams;
      expect(params.rating, 5);
      expect(params.title, ' Çok iyi ');
      expect(params.comment, ' Memnun kaldım. ');
    },
  );

  test('duplicate submit hata olmaz ve mevcut review refresh edilir', () async {
    when(() => submitReview(any())).thenAnswer(
      (_) async =>
          Right(SubmitProductReviewResult(created: false, review: review)),
    );
    await cubit.getProductReviews(productId);

    final result = await cubit.submitReview(productId: productId, rating: 5);

    expect(result.succeeded, isTrue);
    expect(result.duplicate, isTrue);
    verify(() => getReviews(any())).called(2);
  });

  test('rapid double submit ikinci RPC çağrısını engeller', () async {
    final completer =
        Completer<Either<ReviewFailure, SubmitProductReviewResult>>();
    when(() => submitReview(any())).thenAnswer((_) => completer.future);
    await cubit.getProductReviews(productId);

    final first = cubit.submitReview(productId: productId, rating: 5);
    final second = await cubit.submitReview(productId: productId, rating: 5);

    expect(second.ignored, isTrue);
    verify(() => submitReview(any())).called(1);
    completer.complete(
      Right(SubmitProductReviewResult(created: true, review: review)),
    );
    expect((await first).succeeded, isTrue);
  });

  test('REVIEW_NOT_VERIFIED eligibility durumunu yeniden doğrular', () async {
    const failure = ReviewFailure(
      ReviewFailureKind.notVerified,
      'Bu ürünü yalnızca doğrulanmış mağaza içi alışverişten sonra değerlendirebilirsiniz.',
    );
    when(
      () => submitReview(any()),
    ).thenAnswer((_) async => const Left(failure));
    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(canSubmit));
    await cubit.getProductReviews(productId);
    when(
      () => getEligibility(productId),
    ).thenAnswer((_) async => const Right(unverified));

    final result = await cubit.submitReview(productId: productId, rating: 5);

    expect(result.succeeded, isFalse);
    expect((cubit.state as ReviewsLoaded).eligibility, unverified);
  });

  test(
    'own review edit yalnız düzenlenebilir alanları usecase e gönderir',
    () async {
      when(() => updateReview(any())).thenAnswer(
        (_) async => Right(review.copyWith(rating: 4, title: 'Güncel')),
      );
      await cubit.getProductReviews(productId);

      final result = await cubit.updateReview(
        productId: productId,
        reviewId: review.id,
        rating: 4,
        title: 'Güncel',
        comment: 'Yeni yorum',
      );

      expect(result.succeeded, isTrue);
      final params =
          verify(() => updateReview(captureAny())).captured.single
              as UpdateProductReviewParams;
      expect(params.reviewId, review.id);
      expect(params.rating, 4);
      expect(params.title, 'Güncel');
      expect(params.comment, 'Yeni yorum');
    },
  );

  test(
    'delete sonrası geçerli evidence yeniden submit durumuna döner',
    () async {
      when(() => deleteReview(review.id)).thenAnswer(
        (_) async => const Right(
          DeleteProductReviewResult(reviewId: 'review-1', deleted: true),
        ),
      );
      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Right(existing));
      await cubit.getProductReviews(productId);
      when(
        () => getEligibility(productId),
      ).thenAnswer((_) async => const Right(canSubmit));
      when(() => getReviews(any())).thenAnswer(
        (_) async => const Right(
          ProductReviewsPage(
            productId: productId,
            reviews: [],
            stats: ProductReviewStats(
              averageRating: 0,
              totalReviews: 0,
              ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
            ),
          ),
        ),
      );

      final result = await cubit.deleteReview(
        productId: productId,
        reviewId: review.id,
      );

      expect(result.succeeded, isTrue);
      final loaded = cubit.state as ReviewsLoaded;
      expect(loaded.reviews, isEmpty);
      expect(loaded.stats.totalReviews, 0);
      expect(
        loaded.eligibility?.status,
        ProductReviewEligibilityStatus.canSubmit,
      );
    },
  );

  test('rapid double delete ikinci RPC çağrısını engeller', () async {
    final completer =
        Completer<Either<ReviewFailure, DeleteProductReviewResult>>();
    when(() => deleteReview(review.id)).thenAnswer((_) => completer.future);
    await cubit.getProductReviews(productId);

    final first = cubit.deleteReview(productId: productId, reviewId: review.id);
    final second = await cubit.deleteReview(
      productId: productId,
      reviewId: review.id,
    );

    expect(second.ignored, isTrue);
    verify(() => deleteReview(review.id)).called(1);

    completer.complete(
      const Right(
        DeleteProductReviewResult(reviewId: 'review-1', deleted: true),
      ),
    );
    expect((await first).succeeded, isTrue);
  });

  test(
    'quantity semantiği client API sinde entitlement parametresi üretmez',
    () {
      const params = SubmitProductReviewParams(productId: productId, rating: 5);
      expect(params.productId, productId);
      expect(params.rating, 5);
    },
  );
}
