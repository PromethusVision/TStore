import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';

class MockReviewsCubit extends MockCubit<ReviewsState>
    implements ReviewsCubit {}

void main() {
  late MockReviewsCubit reviewsCubit;

  const product = ProductEntity(
    id: 'product-1',
    name: 'Mahalle Kahvesi',
    price: 125,
    categoryId: 'market',
    stock: 10,
    images: [],
    rating: 4.8,
    reviewsCount: 24,
  );
  const stats = ProductReviewStats(
    averageRating: 5,
    totalReviews: 1,
    ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 1},
  );
  final ownReview = ReviewEntity(
    id: 'review-1',
    userId: 'customer-1',
    productId: product.id,
    rating: 5,
    title: 'Çok taze ve güzel',
    comment: 'Mahallede bulup aynı gün alabildim.',
    isVerifiedPurchase: true,
    canEdit: true,
    createdAt: DateTime(2026, 8, 5),
  );
  const guest = ProductReviewEligibility.guest('product-1');
  const unverified = ProductReviewEligibility(
    productId: 'product-1',
    eligible: false,
    canSubmit: false,
  );
  const canSubmit = ProductReviewEligibility(
    productId: 'product-1',
    eligible: true,
    canSubmit: true,
    verifiedTransactionItemId: 'item-1',
    verifiedTransactionId: 'transaction-1',
  );
  const existing = ProductReviewEligibility(
    productId: 'product-1',
    eligible: true,
    canSubmit: false,
    existingReviewId: 'review-1',
    verifiedTransactionItemId: 'item-1',
    verifiedTransactionId: 'transaction-1',
  );

  ReviewsLoaded loaded({
    List<ReviewEntity>? reviews,
    ProductReviewEligibility eligibility = guest,
    bool hasReachedMax = true,
    bool isLoadingMore = false,
    bool isMutating = false,
    ReviewFailure? eligibilityFailure,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? [ownReview],
      stats: stats,
      eligibility: eligibility,
      eligibilityFailure: eligibilityFailure,
      hasReachedMax: hasReachedMax,
      isLoadingMore: isLoadingMore,
      isMutating: isMutating,
      currentPage: 1,
    );
  }

  setUp(() {
    reviewsCubit = MockReviewsCubit();
    when(
      () => reviewsCubit.getProductReviews(product.id),
    ).thenAnswer((_) async {});
    when(
      () => reviewsCubit.getProductReviews(product.id, refresh: true),
    ).thenAnswer((_) async {});
    when(
      () => reviewsCubit.loadMoreReviews(product.id),
    ).thenAnswer((_) async {});
    when(
      () => reviewsCubit.retryEligibility(product.id),
    ).thenAnswer((_) async {});
  });

  Widget buildSubject(
    ReviewsState state, {
    ProductReviewLoginDestinationBuilder? loginDestinationBuilder,
  }) {
    whenListen(
      reviewsCubit,
      const Stream<ReviewsState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      home: ProductReviewsView(
        product: product,
        reviewsCubit: reviewsCubit,
        loginDestinationBuilder:
            loginDestinationBuilder ??
            (_) => const Scaffold(body: Text('Giriş')),
      ),
    );
  }

  testWidgets('loading ve read error retry durumları güvenlidir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(ReviewsLoading()));
    await tester.pump();
    expect(find.byKey(const Key('product-reviews-loading')), findsOneWidget);
    verify(() => reviewsCubit.getProductReviews(product.id)).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      buildSubject(
        const ReviewsError(
          ReviewFailure(ReviewFailureKind.network, 'Bağlantı kurulamadı.'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('product-reviews-error')), findsOneWidget);
    expect(find.text('Bağlantı kurulamadı.'), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    verify(
      () => reviewsCubit.getProductReviews(product.id, refresh: true),
    ).called(1);
  });

  testWidgets('guest canonical login akışından sonra eligibility yeniler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        loaded(reviews: const [], eligibility: guest),
        loginDestinationBuilder: (loginContext) => Scaffold(
          body: TextButton(
            key: const Key('complete-review-login'),
            onPressed: () => Navigator.of(loginContext).pop(true),
            child: const Text('Giriş tamam'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('product-review-eligibility-guest')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('product-review-eligibility-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('complete-review-login')));
    await tester.pumpAndSettle();

    verify(
      () => reviewsCubit.getProductReviews(product.id, refresh: true),
    ).called(1);
  });

  testWidgets('unverified müşteri formu göremez', (tester) async {
    await tester.pumpWidget(
      buildSubject(loaded(reviews: const [], eligibility: unverified)),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('product-review-eligibility-unverified')),
      findsOneWidget,
    );
    expect(find.text('Doğrulanmış alışveriş gerekli'), findsOneWidget);
    expect(
      find.byKey(const Key('product-review-eligibility-action')),
      findsNothing,
    );
  });

  testWidgets('verified müşteri rating title comment ile review oluşturur', (
    tester,
  ) async {
    when(
      () => reviewsCubit.submitReview(
        productId: product.id,
        rating: 5,
        title: 'Taze ürün',
        comment: 'Çok memnun kaldım.',
      ),
    ).thenAnswer(
      (_) async =>
          const ReviewMutationResult.success('Değerlendirmeniz kaydedildi.'),
    );
    await tester.pumpWidget(
      buildSubject(loaded(reviews: const [], eligibility: canSubmit)),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('product-review-eligibility-action')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-review-editor')), findsOneWidget);
    await tester.tap(find.byKey(const Key('product-review-rating-5')));
    await tester.enterText(
      find.byKey(const Key('product-review-title-field')),
      'Taze ürün',
    );
    await tester.enterText(
      find.byKey(const Key('product-review-comment-field')),
      'Çok memnun kaldım.',
    );
    await tester.tap(find.byKey(const Key('product-review-submit')));
    await tester.pumpAndSettle();

    verify(
      () => reviewsCubit.submitReview(
        productId: product.id,
        rating: 5,
        title: 'Taze ürün',
        comment: 'Çok memnun kaldım.',
      ),
    ).called(1);
    expect(find.text('Değerlendirmeniz kaydedildi.'), findsOneWidget);
  });

  testWidgets('form hızlı çift gönderimde butonu kilitler', (tester) async {
    final completer = Completer<ReviewMutationResult>();
    when(
      () => reviewsCubit.submitReview(
        productId: product.id,
        rating: 5,
        title: '',
        comment: '',
      ),
    ).thenAnswer((_) => completer.future);
    await tester.pumpWidget(
      buildSubject(loaded(reviews: const [], eligibility: canSubmit)),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('product-review-eligibility-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-rating-5')));
    await tester.tap(find.byKey(const Key('product-review-submit')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('product-review-submit')),
    );
    expect(button.onPressed, isNull);
    verify(
      () => reviewsCubit.submitReview(
        productId: product.id,
        rating: 5,
        title: '',
        comment: '',
      ),
    ).called(1);

    completer.complete(
      const ReviewMutationResult.success('Değerlendirmeniz kaydedildi.'),
    );
    await tester.pumpAndSettle();
  });

  testWidgets(
    'authoritative aggregate badge ve own review aksiyonları görünür',
    (tester) async {
      await tester.pumpWidget(buildSubject(loaded(eligibility: existing)));
      await tester.pump();

      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('1 değerlendirme'), findsOneWidget);
      expect(find.text('Doğrulanmış Alışveriş'), findsOneWidget);
      expect(find.text('Sizin değerlendirmeniz'), findsOneWidget);
      expect(
        find.byKey(const Key('product-review-edit-review-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('product-review-delete-review-1')),
        findsOneWidget,
      );
    },
  );

  testWidgets('own review edit alanlarını doldurur ve update çağırır', (
    tester,
  ) async {
    when(
      () => reviewsCubit.updateReview(
        productId: product.id,
        reviewId: ownReview.id,
        rating: 4,
        title: 'Güncel başlık',
        comment: ownReview.comment,
      ),
    ).thenAnswer(
      (_) async =>
          const ReviewMutationResult.success('Değerlendirmeniz güncellendi.'),
    );
    await tester.pumpWidget(buildSubject(loaded(eligibility: existing)));
    await tester.pump();

    await tester.drag(
      find.byKey(const Key('product-reviews-list')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-edit-review-1')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('product-review-title-field')),
          )
          .controller!
          .text,
      ownReview.title,
    );
    await tester.tap(find.byKey(const Key('product-review-rating-4')));
    await tester.enterText(
      find.byKey(const Key('product-review-title-field')),
      'Güncel başlık',
    );
    await tester.tap(find.byKey(const Key('product-review-submit')));
    await tester.pumpAndSettle();

    verify(
      () => reviewsCubit.updateReview(
        productId: product.id,
        reviewId: ownReview.id,
        rating: 4,
        title: 'Güncel başlık',
        comment: ownReview.comment,
      ),
    ).called(1);
  });

  testWidgets('delete confirmation olmadan silmez, onayla siler', (
    tester,
  ) async {
    when(
      () => reviewsCubit.deleteReview(
        productId: product.id,
        reviewId: ownReview.id,
      ),
    ).thenAnswer(
      (_) async =>
          const ReviewMutationResult.success('Değerlendirmeniz silindi.'),
    );
    await tester.pumpWidget(buildSubject(loaded(eligibility: existing)));
    await tester.pump();

    await tester.drag(
      find.byKey(const Key('product-reviews-list')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-delete-review-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-delete-cancel')));
    await tester.pumpAndSettle();
    verifyNever(
      () => reviewsCubit.deleteReview(
        productId: product.id,
        reviewId: ownReview.id,
      ),
    );

    await tester.drag(
      find.byKey(const Key('product-reviews-list')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-delete-review-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-review-delete-confirm')));
    await tester.pumpAndSettle();
    verify(
      () => reviewsCubit.deleteReview(
        productId: product.id,
        reviewId: ownReview.id,
      ),
    ).called(1);
  });

  testWidgets('load more in-flight iken tekrar aksiyon vermez', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        loaded(eligibility: guest, hasReachedMax: false, isLoadingMore: true),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('product-reviews-load-more')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('product-reviews-list')),
        matching: find.byType(Scrollable),
      ),
    );
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('product-reviews-load-more')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Yükleniyor'), findsOneWidget);
  });

  testWidgets('dar ekranda uzun verified badge taşma üretmez', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(buildSubject(loaded(eligibility: existing)));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
