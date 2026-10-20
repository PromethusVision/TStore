import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/purchases/data/repositories/purchase_history_repository_impl.dart';
import 'package:t_store/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:t_store/features/reviews/domain/entities/review_failure.dart';
import '../../helpers/evaluation_auth_fixture.dart';
import '../../helpers/fake_evaluation_repository.dart';

class _Service extends Mock implements SupabaseService {}

void main() {
  late SupabaseClient client;
  late _Service service;
  late Completer<void> started, release;
  setUp(() async {
    started = Completer<void>();
    release = Completer<void>();
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/rest/v1/verified_transactions');
        started.complete();
        await release.future;
        return http.Response(
          jsonEncode([]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    service = _Service();
    when(() => service.client).thenReturn(client);
    when(() => service.currentUser).thenAnswer((_) => client.auth.currentUser);
    await installEvaluationSession(client, 'S1');
    await pumpEventQueue();
  });
  tearDown(() => client.dispose());

  for (final replace in [false, true]) {
    test(
      'customer history ${replace ? 'rejects replacement' : 'accepts renewal'} during read',
      () async {
        final repository = PurchaseHistoryRepositoryImpl(
          supabaseService: service,
          reviewsEnabled: true,
          checkoutEnabled: false,
        );
        final pending = repository.getVerifiedPurchases();
        await started.future;
        await installEvaluationSession(
          client,
          replace ? 'S2' : 'S1',
          tokenRevision: 1,
        );
        await pumpEventQueue();
        release.complete();
        expect(
          (await pending).fold((e) => e, (_) => 'accepted'),
          replace ? contains('Oturum') : 'accepted',
        );
      },
    );
  }
  test('customer eligibility rejects old session rights', () async {
    final repository = ReviewRepositoryImpl(
      supabaseService: service,
      rpcCaller: (_, _) async {
        started.complete();
        await release.future;
        return {
          'product_id': evaluationProduct,
          'eligible': true,
          'can_submit': true,
        };
      },
    );
    final pending = repository.getProductReviewEligibility(evaluationProduct);
    await started.future;
    await installEvaluationSession(client, 'S2');
    await pumpEventQueue();
    release.complete();
    expect(
      (await pending).fold((e) => e.kind, (_) => null),
      ReviewFailureKind.authRequired,
    );
  });
}
