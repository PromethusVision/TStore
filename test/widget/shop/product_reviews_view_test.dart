import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/reviews/domain/entities/review_entity.dart';
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

  final reviews = [
    ReviewEntity(
      id: 'review-1',
      userId: 'user-1',
      productId: product.id,
      rating: 5,
      title: 'Çok taze ve güzel',
      comment: 'Mahallede bulup aynı gün alabildiğim için memnun kaldım.',
      isVerifiedPurchase: true,
      helpfulCount: 3,
      userName: 'Ayşe Yılmaz',
      createdAt: DateTime(2026, 8, 5),
    ),
    ReviewEntity(
      id: 'review-2',
      userId: 'user-2',
      productId: product.id,
      rating: 4,
      createdAt: DateTime(2026, 7, 20),
    ),
  ];

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
  });

  Widget buildSubject(ReviewsState state) {
    whenListen(
      reviewsCubit,
      const Stream<ReviewsState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      home: ProductReviewsView(product: product, reviewsCubit: reviewsCubit),
    );
  }

  testWidgets('yükleniyor durumunu gösterir ve gerçek ürünü yükler', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(ReviewsLoading()));
    await tester.pump();

    expect(find.byKey(const Key('product-reviews-content')), findsOneWidget);
    expect(find.byKey(const Key('product-reviews-header')), findsOneWidget);
    expect(find.byKey(const Key('product-reviews-loading')), findsOneWidget);
    expect(find.text('Mahalle Kahvesi'), findsOneWidget);
    verify(() => reviewsCubit.getProductReviews(product.id)).called(1);
  });

  testWidgets('özel geri düğmesi ürün ekranına geri döner', (tester) async {
    whenListen(
      reviewsCubit,
      const Stream<ReviewsState>.empty(),
      initialState: const ReviewsLoaded(reviews: [], hasReachedMax: true),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const Key('open-product-reviews'),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ProductReviewsView(
                    product: product,
                    reviewsCubit: reviewsCubit,
                  ),
                ),
              ),
              child: const Text('Değerlendirmeleri aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-product-reviews')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-reviews-header')), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-reviews-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-product-reviews')), findsOneWidget);
    expect(find.byKey(const Key('product-reviews-header')), findsNothing);
  });

  testWidgets('boş durumda sahte yorum göstermeden yenileme sunar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const ReviewsLoaded(reviews: [], hasReachedMax: true)),
    );
    await tester.pump();

    expect(find.byKey(const Key('product-reviews-empty')), findsOneWidget);
    expect(find.text('Henüz ürün değerlendirmesi yok'), findsOneWidget);
    expect(find.text('Mahmoud Hamdy'), findsNothing);

    await tester.tap(find.text('Yenile'));
    await tester.pump();

    verify(
      () => reviewsCubit.getProductReviews(product.id, refresh: true),
    ).called(1);
  });

  testWidgets('hata durumunda güvenli mesaj ve yeniden deneme sunar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const ReviewsError('Bağlantı kurulamadı.')),
    );
    await tester.pump();

    expect(find.byKey(const Key('product-reviews-error')), findsOneWidget);
    expect(find.text('Değerlendirmeler yüklenemedi'), findsOneWidget);
    expect(find.text('Bağlantı kurulamadı.'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(
      () => reviewsCubit.getProductReviews(product.id, refresh: true),
    ).called(1);
  });

  testWidgets(
    'gerçek değerlendirme bilgilerini ve doğrulama etiketini gösterir',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(ReviewsLoaded(reviews: reviews, hasReachedMax: true)),
      );
      await tester.pump();

      expect(find.byKey(const Key('product-reviews-list')), findsOneWidget);
      expect(find.byKey(const Key('product-reviews-summary')), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('24 değerlendirme'), findsOneWidget);
      expect(find.byKey(const Key('product-review-review-1')), findsOneWidget);
      expect(find.byKey(const Key('product-review-review-2')), findsOneWidget);
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('Doğrulanmış'), findsOneWidget);
      expect(find.text('5 Ağustos 2026'), findsOneWidget);
      expect(find.text('Esnafta Var kullanıcısı'), findsOneWidget);
      expect(find.text('Yalnızca puan verildi.'), findsOneWidget);
      expect(find.text('3 kişi faydalı buldu'), findsOneWidget);
      expect(find.text('Mahmoud Hamdy'), findsNothing);
    },
  );

  testWidgets('daha fazla göster işlemini çift çalıştırmaz', (tester) async {
    final loadMoreResult = Completer<void>();
    when(
      () => reviewsCubit.loadMoreReviews(product.id),
    ).thenAnswer((_) => loadMoreResult.future);

    await tester.pumpWidget(
      buildSubject(ReviewsLoaded(reviews: reviews, hasReachedMax: false)),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('product-reviews-load-more')),
      400,
      scrollable: find.descendant(
        of: find.byKey(const Key('product-reviews-list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('product-reviews-load-more')));
    await tester.pump();

    expect(find.text('Yükleniyor'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('product-reviews-load-more')),
    );
    expect(button.onPressed, isNull);
    verify(() => reviewsCubit.loadMoreReviews(product.id)).called(1);

    loadMoreResult.complete();
    await tester.pump();
  });

  testWidgets('dar ekranda uzun değerlendirme taşma üretmez', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildSubject(ReviewsLoaded(reviews: reviews, hasReachedMax: true)),
    );
    await tester.pump();

    expect(find.byKey(const Key('product-reviews-content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
