import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/presentation/evaluation_recovery.dart';
import '../../helpers/fake_evaluation_repository.dart';

void main() {
  late FakeEvaluationRepository repository;
  setUp(() => repository = FakeEvaluationRepository());
  tearDown(() => repository.dispose());

  PurchaseEvaluationCommand purchase() => PurchaseEvaluationCommand(
    purchaseId: evaluationPurchase,
    requestId: newEvaluationRequestId(),
    service: exampleCriteria,
    products: const [],
  );
  ReviewResponseCommand response({
    bool report = false,
    String text = 'Özgün metin',
  }) => ReviewResponseCommand(
    shopId: evaluationShop,
    review: exampleMerchantReview,
    report: report,
    text: text,
  );
  const uncertain = ReviewFailure(ReviewFailureKind.network, 'Yanıt alınamadı');

  test(
    'two forms share one in-flight purchase and identical uncertain retry',
    () async {
      final store = EvaluationRecovery.of(repository);
      final pending = Completer<Either<ReviewFailure, Unit>>();
      repository.submitWait = () => pending.future;
      final original = purchase();
      final first = store.submit(original);
      final duplicate = store.submit(purchase());
      expect(identical(first, duplicate), true);
      expect(repository.submissions, [original]);
      pending.complete(const Left(uncertain));
      await first;
      final reopened = EvaluationRecovery.of(repository);
      expect(identical(reopened.purchase(evaluationPurchase), original), true);
      repository.submitWait = null;
      await reopened.submit(purchase());
      expect(repository.submissions, [original, original]);
      expect(reopened.purchase(evaluationPurchase), null);
    },
  );

  for (final report in [false, true]) {
    test(
      '${report ? 'report' : 'reply'} keeps exact payload and clears definitive rejection',
      () async {
        final store = EvaluationRecovery.of(repository);
        repository.mutationFailure = uncertain;
        final command = response(report: report);
        await store.respond(command);
        await store.respond(response(report: report, text: 'Değişmiş metin'));
        expect(repository.responses[0], repository.responses[1]);
        expect(
          store.response(evaluationShop, exampleMerchantReview, report),
          command,
        );
        repository.mutationFailure = const ReviewFailure(
          ReviewFailureKind.invalidArgument,
          'Geçersiz bilgi',
        );
        await store.respond(command);
        expect(
          store.response(evaluationShop, exampleMerchantReview, report),
          null,
        );
        repository.mutationFailure = null;
        await store.respond(response(report: report, text: 'Yeni metin'));
        expect(repository.responses.last.request, isNot(command.requestId));
        expect(repository.responses.last.text, 'Yeni metin');
      },
    );
  }

  test('normal refresh keeps payload; S1 S2 S1 drops it permanently', () async {
    final store = EvaluationRecovery.of(repository);
    repository.mutationFailure = uncertain;
    final command = response();
    await store.respond(command);
    repository.replaceSession('$evaluationActor:S1');
    expect(
      store.response(evaluationShop, exampleMerchantReview, false),
      command,
    );
    repository.replaceSession('$evaluationActor:S2');
    repository.replaceSession('$evaluationActor:S1');
    expect(store.current, false);
    final fresh = EvaluationRecovery.of(repository);
    expect(fresh.response(evaluationShop, exampleMerchantReview, false), null);
    final count = repository.responses.length;
    expect((await store.respond(command)).isLeft(), true);
    expect(repository.responses.length, count);
  });

  test('late mutation cannot clear a new session pending command', () async {
    final store = EvaluationRecovery.of(repository);
    final waiting = Completer<Either<ReviewFailure, Unit>>();
    repository.submitWait = () => waiting.future;
    final first = store.submit(purchase());
    repository.replaceSession('$evaluationActor:S2');
    final fresh = EvaluationRecovery.of(repository);
    repository.submitWait = null;
    repository.mutationFailure = uncertain;
    final second = purchase();
    await fresh.submit(second);
    waiting.complete(const Right(unit));
    expect((await first).isLeft(), true);
    expect(fresh.purchase(evaluationPurchase), second);
  });

  for (final error in [false, true]) {
    test(
      'session stream ${error ? 'error' : 'closure'} discards private retry text',
      () async {
        final store = EvaluationRecovery.of(repository);
        repository.mutationFailure = uncertain;
        await store.respond(response());
        if (error) {
          repository.sessionKeys.addError(StateError('synthetic'));
        } else {
          await repository.sessionKeys.close();
        }
        expect(store.current, false);
        expect(
          store.response(evaluationShop, exampleMerchantReview, false),
          null,
        );
      },
    );
  }

  test(
    'detail reads its selected page and refuses missing or incomplete evidence',
    () async {
      final offsets = <int>[];
      repository.merchantRead = (_, offset) async {
        offsets.add(offset);
        return Right(
          MerchantReviewsPage(
            shopId: evaluationShop,
            scores: exampleScores,
            awaitingReplyCount: 1,
            total: 2,
            reviews: offset == 0
                ? [
                    const MerchantReview(
                      id: 'another',
                      revisionId: evaluationRevision,
                      productId: evaluationProduct,
                      productName: 'Başka ürün',
                      visibility: 'visible',
                      canReply: false,
                      replied: true,
                      reported: false,
                    ),
                  ]
                : [exampleMerchantReview],
          ),
        );
      };
      expect(
        (await readMerchantReview(
          repository,
          evaluationShop,
          evaluationRoot,
          offset: 20,
        )).getOrElse(() => throw StateError('missing')).id,
        evaluationRoot,
      );
      expect(offsets, [20]);
      expect(
        (await readMerchantReview(
          repository,
          evaluationShop,
          evaluationRoot,
        )).isLeft(),
        true,
      );
      repository.merchantRead = (_, _) async => const Left(uncertain);
      expect(
        (await readMerchantReview(
          repository,
          evaluationShop,
          evaluationRoot,
        )).isLeft(),
        true,
      );
    },
  );
}
