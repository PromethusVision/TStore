import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:t_store/features/reviews/presentation/cubit/reviews_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_reviews_view.dart';
import '../w47_prototype_support.dart';

class _Reviews extends MockCubit<ReviewsState> implements ReviewsCubit {}

const _productId = 'fixture-product';
const _product = ProductEntity(
  id: 'fixture-product',
  name: 'Günlük pamuklu tişört',
  price: 399.90,
  categoryId: 'fixture-category',
  stock: 10,
  images: [],
);
const _existing = ProductReviewEligibility(
  productId: _productId,
  eligible: true,
  canSubmit: false,
  existingReviewId: 'fixture-review-1',
  verifiedTransactionItemId: 'fixture-evidence-item',
  verifiedTransactionId: 'fixture-evidence',
);
const _canSubmit = ProductReviewEligibility(
  productId: _productId,
  eligible: true,
  canSubmit: true,
  verifiedTransactionItemId: 'fixture-evidence-item',
  verifiedTransactionId: 'fixture-evidence',
);
final _own = ReviewEntity(
  id: 'fixture-review-1',
  userId: 'fixture-customer',
  productId: _productId,
  rating: 5,
  title: 'Kumaşı çok rahat',
  comment: 'Mağazada deneyerek aldım. Kalıbı ve dokusu çok güzel.',
  isVerifiedPurchase: true,
  canEdit: true,
  createdAt: DateTime(2026, 9, 4),
);
final _other = ReviewEntity(
  id: 'fixture-review-2',
  userId: 'fixture-other',
  productId: _productId,
  rating: 4,
  title: 'Günlük kullanım için iyi',
  comment: 'Yumuşak bir kumaşı var, bedenini deneyerek seçtim.',
  isVerifiedPurchase: true,
  createdAt: DateTime(2026, 9, 2),
);

ReviewsLoaded _loaded({
  ProductReviewEligibility? eligibility = _existing,
  List<ReviewEntity>? reviews,
  bool mutating = false,
}) => ReviewsLoaded(
  reviews: reviews ?? [_own, _other],
  stats: const ProductReviewStats(
    averageRating: 4.7,
    totalReviews: 36,
    ratingDistribution: {5: 28, 4: 6, 3: 2, 2: 0, 1: 0},
  ),
  eligibility: eligibility,
  hasReachedMax: true,
  isMutating: mutating,
);

void main() {
  late _Reviews cubit;
  setUpAll(loadW47Fonts);
  setUp(() {
    cubit = _Reviews();
    when(() => cubit.getProductReviews(_productId)).thenAnswer((_) async {});
    when(
      () => cubit.getProductReviews(_productId, refresh: true),
    ).thenAnswer((_) async {});
    when(() => cubit.retryEligibility(_productId)).thenAnswer((_) async {});
  });
  Widget view({bool prototype = true}) => ProductReviewsView(
    product: _product,
    reviewsCubit: cubit,
    visualPrototype: prototype,
    loginDestinationBuilder: (_) => const Scaffold(body: Text('Giriş hedefi')),
  );
  Future<void> pump(
    WidgetTester tester, {
    bool prototype = true,
    ReviewsLoaded? state,
  }) async {
    setW47Viewport(tester);
    whenListen(
      cubit,
      const Stream<ReviewsState>.empty(),
      initialState: state ?? _loaded(),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: RepaintBoundary(
          key: const Key('evidence'),
          child: view(prototype: prototype),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final prototype in [false, true]) {
    testWidgets('390 px ${prototype ? 'prototype' : 'before'} evidence', (
      tester,
    ) async {
      await pump(tester, prototype: prototype);
      expect(find.text(_product.name), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(
        find.byKey(const Key('product-review-verified-fixture-review-1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('evidence')),
        matchesGoldenFile(
          'goldens/w47_${prototype ? '' : 'before_'}reviews_390.png',
        ),
      );
    });
  }
  testWidgets('eligible create uses existing editor and canonical product', (
    tester,
  ) async {
    when(
      () => cubit.submitReview(
        productId: _productId,
        rating: 5,
        title: 'Rahat',
        comment: 'Mağazada deneyerek aldım.',
      ),
    ).thenAnswer(
      (_) async => const ReviewMutationResult.success('Kaydedildi.'),
    );
    await pump(
      tester,
      state: _loaded(eligibility: _canSubmit, reviews: [_other]),
    );
    await tester.tap(
      find.byKey(const Key('product-review-eligibility-action')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-review-editor')), findsOneWidget);
    await tester.tap(find.byKey(const Key('product-review-rating-5')));
    await tester.enterText(
      find.byKey(const Key('product-review-title-field')),
      'Rahat',
    );
    await tester.enterText(
      find.byKey(const Key('product-review-comment-field')),
      'Mağazada deneyerek aldım.',
    );
    await tester.ensureVisible(find.byKey(const Key('product-review-submit')));
    await tester.tap(find.byKey(const Key('product-review-submit')));
    await tester.pumpAndSettle();
    verify(
      () => cubit.submitReview(
        productId: _productId,
        rating: 5,
        title: 'Rahat',
        comment: 'Mağazada deneyerek aldım.',
      ),
    ).called(1);
  });
  testWidgets('existing review edit retains review id and original content', (
    tester,
  ) async {
    when(
      () => cubit.updateReview(
        productId: _productId,
        reviewId: _own.id,
        rating: 5,
        title: _own.title!,
        comment: _own.comment!,
      ),
    ).thenAnswer(
      (_) async => const ReviewMutationResult.success('Güncellendi.'),
    );
    await pump(tester);
    expect(find.text('Değerlendirme Yaz'), findsNothing);
    await tester.ensureVisible(
      find.byKey(Key('product-review-edit-${_own.id}')),
    );
    await tester.tap(find.byKey(Key('product-review-edit-${_own.id}')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('product-review-title-field')),
          )
          .controller!
          .text,
      _own.title,
    );
    await tester.ensureVisible(find.byKey(const Key('product-review-submit')));
    await tester.tap(find.byKey(const Key('product-review-submit')));
    await tester.pumpAndSettle();
    verify(
      () => cubit.updateReview(
        productId: _productId,
        reviewId: _own.id,
        rating: 5,
        title: _own.title!,
        comment: _own.comment!,
      ),
    ).called(1);
  });
  testWidgets(
    'delete uses evidence-preserving confirmation and existing mutation',
    (tester) async {
      when(
        () => cubit.deleteReview(productId: _productId, reviewId: _own.id),
      ).thenAnswer((_) async => const ReviewMutationResult.success('Silindi.'));
      await pump(tester);
      await tester.ensureVisible(
        find.byKey(Key('product-review-delete-${_own.id}')),
      );
      await tester.tap(find.byKey(Key('product-review-delete-${_own.id}')));
      await tester.pumpAndSettle();
      expect(find.textContaining('kaydınız korunur'), findsOneWidget);
      await tester.tap(find.byKey(const Key('product-review-delete-confirm')));
      await tester.pumpAndSettle();
      verify(
        () => cubit.deleteReview(productId: _productId, reviewId: _own.id),
      ).called(1);
    },
  );
  for (final eligibility in [
    null,
    const ProductReviewEligibility.guest(_productId),
    const ProductReviewEligibility(
      productId: _productId,
      eligible: false,
      canSubmit: false,
    ),
  ]) {
    testWidgets(
      'no create without authoritative eligibility: ${eligibility?.status}',
      (tester) async {
        await pump(
          tester,
          state: _loaded(
            eligibility: eligibility,
            reviews: [_other.copyWith(isVerifiedPurchase: false)],
          ),
        );
        expect(find.text('Değerlendirme Yaz'), findsNothing);
        expect(
          find.byKey(Key('product-review-verified-${_other.id}')),
          findsNothing,
        );
        expect(
          find.byKey(Key('product-review-edit-${_other.id}')),
          findsNothing,
        );
        if (eligibility?.isGuest == true) {
          await tester.tap(
            find.byKey(const Key('product-review-eligibility-action')),
          );
          await tester.pumpAndSettle();
          expect(find.text('Giriş hedefi'), findsOneWidget);
        }
      },
    );
  }
  testWidgets('mutation guard keeps edit and delete disabled', (tester) async {
    await pump(tester, state: _loaded(mutating: true));
    expect(
      tester
          .widget<TextButton>(find.byKey(Key('product-review-edit-${_own.id}')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(
            find.byKey(Key('product-review-delete-${_own.id}')),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('back preserves caller navigation', (tester) async {
    setW47Viewport(tester);
    whenListen(
      cubit,
      const Stream<ReviewsState>.empty(),
      initialState: _loaded(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => view())),
              child: const Text('Ürüne dön'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ürüne dön'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('product-reviews-back')));
    await tester.pumpAndSettle();
    expect(find.text('Ürüne dön'), findsOneWidget);
  });
  test(
    'prototype stays opt-in',
    () => expect(
      const ProductReviewsView(product: _product).visualPrototype,
      isFalse,
    ),
  );
}
