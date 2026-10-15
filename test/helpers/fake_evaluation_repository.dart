import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import 'package:t_store/features/reviews/domain/repositories/purchase_evaluation_repository.dart';

const evaluationActor = '11111111-1111-4111-8111-111111111111';
const evaluationShop = '22222222-2222-4222-8222-222222222222';
const evaluationPurchase = '33333333-3333-4333-8333-333333333333';
const evaluationProduct = '44444444-4444-4444-8444-444444444444';
const evaluationRoot = '55555555-5555-4555-8555-555555555555';
const evaluationRevision = '66666666-6666-4666-8666-666666666666';
const evaluationRequest = '77777777-7777-4777-8777-777777777777';
const evaluationService = '88888888-8888-4888-8888-888888888888';
const exampleCriteria = ServiceCriteria(
  friendliness: 5,
  communication: 4,
  cleanliness: 3,
);
const exampleScores = ServiceScores(
  sampleCount: 21,
  friendliness: 4.8,
  communication: 4.5,
  cleanliness: 4.2,
  average: 4.5,
);
const exampleMerchantReview = MerchantReview(
  id: evaluationRoot,
  revisionId: evaluationRevision,
  productId: evaluationProduct,
  productName: 'Mahalle ürünü',
  visibility: 'visible',
  canReply: true,
  replied: false,
  reported: false,
  rating: 4,
  comment: 'Güzel bir alışverişti.',
);

class FakeEvaluationRepository implements PurchaseEvaluationRepository {
  @override
  String? currentUserId = evaluationActor;
  final sessions = StreamController<String?>.broadcast(sync: true);
  @override
  Stream<String?> get sessionChanges => sessions.stream;
  void switchAccount(String? id) {
    currentUserId = id;
    sessions.add(id);
  }

  bool capability = true;
  ReviewFailure? readFailure, mutationFailure;
  PurchaseEvaluation value = const PurchaseEvaluation(
    purchaseId: evaluationPurchase,
    shopId: evaluationShop,
    shopName: 'Mahalle Market',
    enabled: true,
    valid: true,
    products: [
      EvaluationProduct(
        productId: evaluationProduct,
        name: 'Mahalle ürünü',
        canSubmit: true,
      ),
    ],
  );
  MerchantReviewsPage page = const MerchantReviewsPage(
    shopId: evaluationShop,
    scores: exampleScores,
    awaitingReplyCount: 1,
    total: 1,
    reviews: [exampleMerchantReview],
  );
  final submissions = <PurchaseEvaluationCommand>[];
  final responses = <({String request, String text, bool report})>[];
  Future<Either<ReviewFailure, Unit>> Function()? submitWait;
  Future<Either<ReviewFailure, MerchantReviewsPage>> Function(
    MerchantReviewFilter,
    int,
  )?
  merchantRead;
  @override
  Future<Either<ReviewFailure, bool>> enabled() async =>
      readFailure == null ? Right(capability) : Left(readFailure!);
  @override
  Future<Either<ReviewFailure, PurchaseEvaluation>> purchase(
    String purchaseId,
  ) async => readFailure == null ? Right(value) : Left(readFailure!);
  @override
  Future<Either<ReviewFailure, Unit>> submit(
    PurchaseEvaluationCommand command,
  ) async {
    submissions.add(command);
    if (submitWait != null) return submitWait!();
    return mutationFailure == null ? const Right(unit) : Left(mutationFailure!);
  }

  @override
  Future<Either<ReviewFailure, MerchantReviewsPage>> merchant(
    String shopId, {
    MerchantReviewFilter filter = MerchantReviewFilter.all,
    int offset = 0,
  }) async {
    if (merchantRead != null) return merchantRead!(filter, offset);
    return readFailure == null ? Right(page) : Left(readFailure!);
  }

  @override
  Future<Either<ReviewFailure, Unit>> reply({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String text,
  }) async {
    responses.add((request: requestId, text: text, report: false));
    return mutationFailure == null ? const Right(unit) : Left(mutationFailure!);
  }

  @override
  Future<Either<ReviewFailure, Unit>> report({
    required String shopId,
    required MerchantReview review,
    required String requestId,
    required String reason,
  }) async {
    responses.add((request: requestId, text: reason, report: true));
    return mutationFailure == null ? const Right(unit) : Left(mutationFailure!);
  }

  Future<void> dispose() => sessions.close();
}
