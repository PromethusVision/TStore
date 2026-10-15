import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/reviews/data/repositories/supabase_purchase_evaluation_repository.dart';
import 'package:t_store/features/reviews/domain/entities/purchase_evaluation.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import '../../helpers/fake_evaluation_repository.dart';

void main() {
  late SupabaseClient client;
  late SupabasePurchaseEvaluationRepository repository;
  String? actor;
  dynamic response;
  final calls = <({String name, Map<String, dynamic> params})>[];
  setUp(() {
    client = SupabaseClient('http://127.0.0.1:55431', 'synthetic-anon');
    actor = evaluationActor;
    calls.clear();
    repository = SupabasePurchaseEvaluationRepository(
      client,
      currentUserId: () => actor,
      rpc: (name, params) async {
        calls.add((name: name, params: params));
        if (response is Exception) throw response as Exception;
        if (response is Future) return response;
        return response;
      },
    );
  });
  tearDown(() async {
    await client.dispose();
  });
  Map<String, dynamic> purchase() => {
    'purchase_id': evaluationPurchase,
    'shop_id': evaluationShop,
    'shop_name': 'Mahalle Market',
    'enabled': true,
    'valid': true,
    'service': {'friendliness': 5, 'communication': 4, 'cleanliness': 3},
    'products': [
      {
        'product_id': evaluationProduct,
        'product_name': 'Ürün',
        'can_submit': true,
        'existing_review': null,
      },
    ],
  };
  test(
    'capability and purchase decode preserve nullable service and available rights',
    () async {
      response = {'version': 2, 'enabled': false};
      expect((await repository.enabled()).getOrElse(() => true), false);
      response = purchase();
      final value = (await repository.purchase(
        evaluationPurchase,
      )).getOrElse(() => throw StateError('decode'));
      expect(value.service!.cleanliness, 3);
      expect(value.products.single.canSubmit, true);
      response = purchase()..['service'] = null;
      expect(
        (await repository.purchase(
          evaluationPurchase,
        )).getOrElse(() => throw StateError('decode')).service,
        null,
      );
    },
  );
  test(
    'invalid criteria, duplicate products and invalid IDs never make RPC calls',
    () async {
      expect((await repository.purchase('foreign')).isLeft(), true);
      final command = PurchaseEvaluationCommand(
        purchaseId: evaluationPurchase,
        requestId: evaluationRequest,
        products: const [
          ProductEvaluationInput(productId: evaluationProduct, rating: 5),
          ProductEvaluationInput(productId: evaluationProduct, rating: 4),
        ],
      );
      expect((await repository.submit(command)).isLeft(), true);
      expect(calls, isEmpty);
    },
  );
  test('uncertain retries preserve request and exact payload', () async {
    final command = PurchaseEvaluationCommand(
      purchaseId: evaluationPurchase,
      requestId: evaluationRequest,
      service: exampleCriteria,
      products: const [
        ProductEvaluationInput(
          productId: evaluationProduct,
          rating: 5,
          comment: 'İyi',
        ),
      ],
    );
    response = TimeoutException('private diagnostic');
    expect((await repository.submit(command)).isLeft(), true);
    response = {
      'purchase_id': evaluationPurchase,
      'service_evaluation_id': evaluationService,
      'reviews': [
        {
          'review_id': evaluationRoot,
          'product_id': evaluationProduct,
          'revision_id': evaluationRevision,
          'edit_until': '2026-10-16T12:00:00Z',
        },
      ],
    };
    expect((await repository.submit(command)).isRight(), true);
    expect(calls[0].params, calls[1].params);
    expect(
      calls
          .singleWhere(
            (c) => c.name != 'submit_purchase_evaluation_v2',
            orElse: () => calls.first,
          )
          .name,
      'submit_purchase_evaluation_v2',
    );
  });
  test(
    'account switch drops an in-flight response and guests make no calls',
    () async {
      final waiting = Completer<dynamic>();
      response = waiting.future;
      final pending = repository.purchase(evaluationPurchase);
      actor = evaluationShop;
      waiting.complete(purchase());
      expect(
        (await pending).fold((e) => e.kind, (_) => null),
        ReviewFailureKind.authRequired,
      );
      calls.clear();
      actor = null;
      expect((await repository.purchase(evaluationPurchase)).isLeft(), true);
      expect(calls, isEmpty);
    },
  );
  test(
    'foreign response, malformed scores and unsupported version fail closed',
    () async {
      response = purchase()..['purchase_id'] = evaluationShop;
      expect(
        (await repository.purchase(
          evaluationPurchase,
        )).fold((e) => e.kind, (_) => null),
        ReviewFailureKind.invalidResponse,
      );
      response = {'version': 3, 'enabled': true};
      expect((await repository.enabled()).isLeft(), true);
      response = {
        'shop_id': evaluationShop,
        'scores': {'sample_count': 0, 'average_rating': 5},
        'awaiting_reply_count': 0,
        'total': 0,
        'reviews': [],
      };
      expect((await repository.merchant(evaluationShop)).isLeft(), true);
    },
  );
  test(
    'reply and report carry source revision and private reasons never leak in failures',
    () async {
      response = const PostgrestException(
        message: '[REVIEW_CHANGED] private diagnostic',
        code: '40001',
      );
      final result = await repository.reply(
        shopId: evaluationShop,
        review: exampleMerchantReview,
        requestId: evaluationRequest,
        text: 'Yanıt',
      );
      expect(result.isLeft(), true);
      expect(
        result.fold((e) => e.message, (_) => ''),
        isNot(contains('private')),
      );
      expect(calls.single.params['p_revision_id'], evaluationRevision);
      response = {
        'review_id': evaluationRoot,
        'event_id': evaluationService,
        'action': 'report',
      };
      expect(
        (await repository.report(
          shopId: evaluationShop,
          review: exampleMerchantReview,
          requestId: evaluationRequest,
          reason: 'Neden',
        )).isRight(),
        true,
      );
      expect(calls.last.params['p_action'], 'report');
    },
  );
}
