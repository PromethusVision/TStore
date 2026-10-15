import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/presentation/merchant_reviews.dart';
import 'package:t_store/features/reviews/presentation/widgets/purchase_evaluation_sheet.dart';
import '../../helpers/fake_evaluation_repository.dart';
import '../w49/w49_domain_fixture.dart' show loadW49Fonts, pumpW49;

void main() {
  setUpAll(loadW49Fonts);
  for (final width in [320.0, 390.0]) {
    testWidgets('review center and customer form at $width', (tester) async {
      final repo = FakeEvaluationRepository();
      addTearDown(repo.dispose);
      final scale = width == 320 ? 1.3 : 1.0;
      await pumpW49(
        tester,
        MerchantReviewsView(
          repository: repo,
          shopId: evaluationShop,
          ownerId: evaluationActor,
        ),
        width: width,
        scale: scale,
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/c_merchant_center_${width.toInt()}.png'),
      );
      await tester.ensureVisible(
        find.byKey(const Key('merchant-review-$evaluationRoot')),
      );
      await tester.tap(
        find.byKey(const Key('merchant-review-$evaluationRoot')),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/c_merchant_detail_${width.toInt()}.png'),
      );
      await tester.pumpWidget(const SizedBox());
      await pumpW49(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPurchaseEvaluation(
                context,
                repository: repo,
                purchaseId: evaluationPurchase,
                selectedProductId: evaluationProduct,
              ),
              child: const Text('Alışverişi değerlendir'),
            ),
          ),
        ),
        width: width,
        scale: scale,
      );
      await tester.tap(find.text('Alışverişi değerlendir'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('w49-evidence')),
        matchesGoldenFile('goldens/c_customer_evaluation_${width.toInt()}.png'),
      );
      expect(tester.takeException(), null);
    });
  }
}
