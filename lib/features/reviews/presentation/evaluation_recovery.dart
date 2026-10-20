import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';

bool uncertainEvaluation(ReviewFailure failure) =>
    failure.kind == ReviewFailureKind.network ||
    failure.kind == ReviewFailureKind.invalidResponse;

/// Existing paged contract only. An incomplete search never authorizes a write.
Future<Either<ReviewFailure, MerchantReview>> readMerchantReview(
  PurchaseEvaluationRepository repository,
  String shopId,
  String reviewId, {
  MerchantReviewFilter filter = MerchantReviewFilter.all,
  int offset = 0,
}) async {
  final recovery = EvaluationRecovery.of(repository);
  if (recovery.current) {
    final result = await repository.merchant(
      shopId,
      filter: filter,
      offset: offset,
    );
    if (!recovery.current) {
      return const Left(
        ReviewFailure(
          ReviewFailureKind.authRequired,
          'Oturumunuz değişti. Bu ekranı kapatın.',
        ),
      );
    }
    final failure = result.fold<ReviewFailure?>((e) => e, (_) => null);
    if (failure != null) return Left(failure);
    final page = result.getOrElse(() => throw StateError('unreachable'));
    for (final review
        in page.shopId == shopId ? page.reviews : <MerchantReview>[]) {
      if (review.id == reviewId) return Right(review);
    }
  }
  return const Left(
    ReviewFailure(
      ReviewFailureKind.unavailable,
      'Değerlendirmenin güncel hali alınamadı. Merkezi yenileyip yeniden açın.',
    ),
  );
}

class ReviewResponseCommand {
  ReviewResponseCommand({
    required this.shopId,
    required this.review,
    required this.report,
    required this.text,
  }) : requestId = newEvaluationRequestId();
  final String shopId, requestId, text;
  final MerchantReview review;
  final bool report;
}

/// In-memory retry payloads survive route closure, never a replacement session.
/// A retry uses the server's existing request receipt; reads are not receipts.
/// Nothing here is persisted to disk or replayed automatically.
class EvaluationRecovery {
  EvaluationRecovery._(this.repository)
    : _actor = repository.currentUserId,
      _session = repository.currentSessionKey {
    _actors = repository.sessionChanges.listen(
      (actor) {
        if (actor != _actor || !current) _invalidate();
      },
      onError: (Object _) => _invalidate(),
      onDone: _invalidate,
    );
    _keys = repository.sessionKeyChanges.listen(
      (key) {
        if (key != _session || !current) _invalidate();
      },
      onError: (Object _) => _invalidate(),
      onDone: _invalidate,
    );
  }
  static final _stores = Expando<EvaluationRecovery>();
  static EvaluationRecovery of(PurchaseEvaluationRepository repository) {
    final old = _stores[repository];
    if (old != null && old.current) return old;
    old?._invalidate();
    return _stores[repository] = EvaluationRecovery._(repository);
  }

  final PurchaseEvaluationRepository repository;
  final String? _actor, _session;
  StreamSubscription<String?>? _actors, _keys;
  bool _invalid = false;
  final _purchases = <String, PurchaseEvaluationCommand>{};
  final _responses = <String, ReviewResponseCommand>{};
  final _running = <Object, Future<Either<ReviewFailure, Unit>>>{};
  bool get current =>
      !_invalid &&
      _actor != null &&
      _session != null &&
      repository.currentUserId == _actor &&
      repository.currentSessionKey == _session;

  void _invalidate() {
    if (_invalid) return;
    _invalid = true;
    _purchases.clear();
    _responses.clear();
    _running.clear();
    _actors?.cancel();
    _keys?.cancel();
  }

  PurchaseEvaluationCommand? purchase(String id) =>
      current ? _purchases[id] : null;
  String _responseKey(String shop, MerchantReview review, bool report) =>
      '$shop:${review.id}:${report ? review.revisionId : 'reply'}';
  ReviewResponseCommand? response(
    String shop,
    MerchantReview review,
    bool report,
  ) => current ? _responses[_responseKey(shop, review, report)] : null;

  Future<Either<ReviewFailure, Unit>> submit(
    PurchaseEvaluationCommand command,
  ) {
    final pending = purchase(command.purchaseId) ?? command;
    if (current) _purchases[pending.purchaseId] = pending;
    return _run(
      pending,
      () => repository.submit(pending),
      () => _purchases.remove(pending.purchaseId),
    );
  }

  Future<Either<ReviewFailure, Unit>> respond(ReviewResponseCommand command) {
    final key = _responseKey(command.shopId, command.review, command.report);
    final pending =
        response(command.shopId, command.review, command.report) ?? command;
    if (current) _responses[key] = pending;
    return _run(
      pending,
      () => pending.report
          ? repository.report(
              shopId: pending.shopId,
              review: pending.review,
              requestId: pending.requestId,
              reason: pending.text,
            )
          : repository.reply(
              shopId: pending.shopId,
              review: pending.review,
              requestId: pending.requestId,
              text: pending.text,
            ),
      () => _responses.remove(key),
    );
  }

  Future<Either<ReviewFailure, Unit>> _run(
    Object command,
    Future<Either<ReviewFailure, Unit>> Function() send,
    void Function() clear,
  ) {
    const expired = Left<ReviewFailure, Unit>(
      ReviewFailure(
        ReviewFailureKind.authRequired,
        'Oturumunuz değişti. Yeniden giriş yapın.',
      ),
    );
    if (!current) {
      _invalidate();
      return Future.value(expired);
    }
    if (_running[command] case final running?) return running;
    // Install the shared future before calling an adapter that may throw.
    final completion = Completer<Either<ReviewFailure, Unit>>();
    _running[command] = completion.future;
    () async {
      Either<ReviewFailure, Unit> result;
      try {
        result = await send();
      } catch (_) {
        result = const Left(
          ReviewFailure(
            ReviewFailureKind.network,
            'İşlem sonucu doğrulanamadı. Aynı işlemi tekrar deneyin.',
          ),
        );
      }
      if (!current) {
        _invalidate();
        result = expired;
      } else {
        if (result.fold(
          (failure) => !uncertainEvaluation(failure),
          (_) => true,
        )) {
          clear();
        }
        _running.remove(command);
      }
      completion.complete(result);
    }();
    return completion.future;
  }
}
