import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/presentation/merchant_reviews.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import '../../helpers/fake_evaluation_repository.dart';

void main() {
  late FakeEvaluationRepository repository;
  setUp(() => repository = FakeEvaluationRepository());
  tearDown(() async {
    await repository.dispose();
  });
  Future<void> open(WidgetTester tester, {bool summary = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: summary
            ? Scaffold(
                body: SingleChildScrollView(
                  child: MerchantReviewSummary(
                    repository: repository,
                    shopId: evaluationShop,
                    ownerId: evaluationActor,
                  ),
                ),
              )
            : MerchantReviewsView(
                repository: repository,
                shopId: evaluationShop,
                ownerId: evaluationActor,
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dashboard shows criteria, sample count and center navigation without overflow',
    (tester) async {
      await open(tester, summary: true);
      expect(find.text('Güleryüz'), findsOneWidget);
      expect(find.textContaining('21 doğrulanmış'), findsOneWidget);
      expect(find.text('Yanıt bekleyen: 1'), findsOneWidget);
      await tap(tester, find.byKey(const Key('merchant-reviews-open')));
      expect(find.text('Değerlendirme merkezi'), findsOneWidget);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'disabled capability has no center entry and failure offers retry',
    (tester) async {
      repository.capability = false;
      await open(tester, summary: true);
      expect(find.byKey(const Key('merchant-reviews-open')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      repository.readFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Özet alınamadı',
      );
      await open(tester, summary: true);
      expect(find.text('Özet alınamadı'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      repository.readFailure = null;
      repository.capability = true;
      await tap(tester, find.text('Tekrar dene'));
      expect(find.byKey(const Key('merchant-reviews-open')), findsOneWidget);
    },
  );
  testWidgets(
    'reply has one-use copy, preserves uncertain text and closes the action after success',
    (tester) async {
      await open(tester);
      await tap(
        tester,
        find.byKey(const Key('merchant-review-$evaluationRoot')),
      );
      expect(find.textContaining('yalnızca bir kez yanıt'), findsOneWidget);
      await tap(tester, find.text('Yanıt yaz'));
      await tester.enterText(
        find.byKey(const Key('merchant-review-response')),
        'Teşekkür ederiz.',
      );
      repository.mutationFailure = const ReviewFailure(
        ReviewFailureKind.network,
        'Bağlantı yok',
      );
      await tap(tester, find.text('Gönder'));
      final original = repository.responses.single;
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('merchant-review-response')),
            )
            .readOnly,
        true,
      );
      repository.mutationFailure = null;
      await tap(tester, find.text('Tekrar dene'));
      expect(repository.responses.last, original);
      expect(find.text('Yanıt yaz'), findsNothing);
      expect(find.textContaining('Yanıt kaydedildi.'), findsOneWidget);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'report validates reason and does not claim that reporting hides a review',
    (tester) async {
      await open(tester);
      await tap(
        tester,
        find.byKey(const Key('merchant-review-$evaluationRoot')),
      );
      await tap(tester, find.text('Değerlendirmeyi bildir'));
      await tap(tester, find.text('Gönder'));
      expect(repository.responses, isEmpty);
      expect(find.text('Bildirim nedeninizi yazın.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('merchant-review-response')),
        'İncelenmesini istiyorum.',
      );
      await tap(tester, find.text('Gönder'));
      expect(repository.responses.single.report, true);
      expect(
        find.text('Bu sürüm için bildiriminiz kaydedildi.'),
        findsOneWidget,
      );
      expect(find.textContaining('tek başına değerlendirmeyi'), findsOneWidget);
    },
  );
  testWidgets(
    'late filter response is ignored and session change removes private detail',
    (tester) async {
      await open(tester);
      final stale = Completer<Either<ReviewFailure, MerchantReviewsPage>>();
      repository.merchantRead = (filter, offset) async {
        if (filter == MerchantReviewFilter.unanswered) return stale.future;
        return const Right(
          MerchantReviewsPage(
            shopId: evaluationShop,
            scores: exampleScores,
            awaitingReplyCount: 0,
            total: 0,
            reviews: [],
          ),
        );
      };
      await tester.ensureVisible(find.text('Yanıt bekleyen'));
      await tester.tap(find.text('Yanıt bekleyen'));
      await tester.pump();
      await tester.tap(find.text('Bildirilen'));
      await tester.pumpAndSettle();
      stale.complete(Right(repository.page));
      await tester.pumpAndSettle();
      expect(
        find.text('Bu filtrede değerlendirme bulunmuyor.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('merchant-review-$evaluationRoot')),
        findsNothing,
      );
      repository.switchAccount(evaluationShop);
      await tester.pump();
      expect(find.textContaining('Oturum değişti.'), findsOneWidget);
      expect(find.text('Güleryüz'), findsNothing);
    },
  );
}
