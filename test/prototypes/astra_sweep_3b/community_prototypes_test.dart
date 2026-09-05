import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/prototypes/astra_sweep_3b/community_prototypes.dart';
import 'sweep_test_support.dart';

void main() {
  setUpAll(loadW47Fonts);
  testWidgets('04 inbox 390: actual merchant, unread and receipt fields', (
    tester,
  ) async {
    await pumpSweep(tester, SweepInbox(threads: sweepThreads, onOpen: (_) {}));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Okundu'), findsOneWidget);
    expect(find.text('Mağaza ile görüşme'), findsNothing);
    await captureSweep(tester, '04_inbox_390.png');
  });
  testWidgets('05 shop ratings 390: read-only rated purchase context', (
    tester,
  ) async {
    await pumpSweep(
      tester,
      SweepShopRatings(purchases: [...sweepPurchases, sweepUnrated]),
    );
    expect(find.byKey(Key('sweep-rating-${sweepUnrated.id}')), findsNothing);
    expect(find.text('5/5'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await captureSweep(tester, '05_shop_ratings_390.png');
  });
  testWidgets('06 shop rating modal 390 and exact QR/rating callback', (
    tester,
  ) async {
    String? qr;
    int? rating;
    await openSweepModal(
      tester,
      (context) => SweepShopRatingEditor(
        purchase: sweepUnrated,
        onClose: () => Navigator.of(context).pop(),
        onSubmit: (id, value) {
          qr = id;
          rating = value;
          Navigator.of(context).pop();
        },
      ),
      purchases: true,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('sweep-rating-submit')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('sweep-star-5')));
    await captureSweep(tester, '06_shop_rating_editor_390.png');
    await tester.tap(find.byKey(const Key('sweep-rating-submit')));
    await tester.pumpAndSettle();
    expect(qr, sweepUnrated.sourceQrSessionId);
    expect(rating, 5);
    expect(find.byType(SweepShopRatingEditor), findsNothing);
  });
  testWidgets('review editor canonical create payload', (tester) async {
    List<Object?>? payload;
    await openSweepModal(
      tester,
      (context) => SweepReviewEditor(
        productId: sweepProductId,
        productName: sweepProducts.first.name,
        eligibility: sweepEligibility,
        onClose: () => Navigator.of(context).pop(),
        onSubmit: (product, review, rating, title, comment) {
          payload = [product, review, rating, title, comment];
          Navigator.of(context).pop();
        },
      ),
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('sweep-review-submit')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('sweep-star-5')));
    await tester.enterText(
      find.byKey(const Key('sweep-review-title')),
      'Kumaşı çok rahat',
    );
    await tester.enterText(
      find.byKey(const Key('sweep-review-comment')),
      'Mağazada deneyerek aldım. Kalıbı çok güzel.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sweep-review-submit')));
    await tester.pumpAndSettle();
    expect(payload, [
      sweepProductId,
      null,
      5,
      'Kumaşı çok rahat',
      'Mağazada deneyerek aldım. Kalıbı çok güzel.',
    ]);
  });
  testWidgets('08 review deletion 390 keeps immutable-evidence explanation', (
    tester,
  ) async {
    String? deleted;
    await openSweepModal(
      tester,
      (context) => SweepReviewDelete(
        review: sweepOwnReview,
        onCancel: () => Navigator.of(context).pop(),
        onDelete: (review) {
          deleted = review.id;
          Navigator.of(context).pop();
        },
      ),
      dialog: true,
    );
    expect(find.textContaining('kaydın korunur'), findsOneWidget);
    await captureSweep(tester, '08_review_delete_390.png');
    expect(deleted, isNull);
    await tester.tap(find.byKey(const Key('sweep-delete-confirm')));
    await tester.pumpAndSettle();
    expect(deleted, sweepOwnReview.id);
  });
  testWidgets(
    'inbox selection and back use supplied destination without new shop route',
    (tester) async {
      await pumpSweep(
        tester,
        Builder(
          builder: (context) => SweepInbox(
            threads: sweepThreads,
            onOpen: (thread) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: Text('Alıcı: ${thread.otherUserId}'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(
        find.byKey(const Key('sweep-thread-fixture-merchant-1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alıcı: fixture-merchant-1'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Mesajlarım'), findsOneWidget);
    },
  );
  testWidgets(
    '07 review editor 390 edit mode preserves original review id and closes',
    (tester) async {
      String? edited;
      await openSweepModal(
        tester,
        (context) => SweepReviewEditor(
          productId: sweepProductId,
          productName: sweepProducts.first.name,
          eligibility: sweepEligibility,
          review: sweepOwnReview,
          onClose: () => Navigator.of(context).pop(),
          onSubmit: (product, review, rating, title, comment) {
            edited = review;
            Navigator.of(context).pop();
          },
        ),
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('sweep-review-title')))
            .controller!
            .text,
        sweepOwnReview.title,
      );
      await captureSweep(tester, '07_review_editor_390.png');
      await tester.tap(find.byKey(const Key('sweep-review-submit')));
      await tester.pumpAndSettle();
      expect(edited, sweepOwnReview.id);
    },
  );
}
