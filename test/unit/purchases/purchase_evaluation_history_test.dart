import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/purchases/data/repositories/purchase_history_repository_impl.dart';
import '../../helpers/evaluation_auth_fixture.dart';

class _Service extends Mock implements SupabaseService {}

class _User extends Mock implements User {}

void main() {
  late _Service service;
  late _User user;
  late SupabaseClient client;
  final paths = <String>[];
  var count = 1, mode = 'valid';
  Map<String, dynamic> purchase(int index) => {
    'id': 'purchase-$index',
    'source_qr_session_id': 'qr-$index',
    'shop_id': 'shop',
    'shop_name': 'Mağaza',
    'item_count': 1,
    'total_amount': 10,
    'confirmed_at': '2026-10-15T10:00:00Z',
    'shop_ratings': [
      {'rating': 2, 'created_at': '2026-10-15T10:01:00Z'},
    ],
    'verified_transaction_items': [
      {
        'id': 'item-$index',
        'shop_product_id': 'listing',
        'product_id': 'product',
        'product_name': 'Ürün',
        'quantity': 1,
        'unit_price': 10,
        'line_total': 10,
      },
    ],
  };
  setUp(() async {
    service = _Service();
    user = _User();
    when(() => user.id).thenReturn('customer');
    when(() => service.currentUser).thenReturn(user);
    paths.clear();
    count = 1;
    mode = 'valid';
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-anon',
      httpClient: MockClient((request) async {
        paths.add(request.url.path);
        Object body;
        var status = 200;
        if (request.url.path.endsWith('/verified_transactions')) {
          body = List.generate(count, purchase);
        } else if (request.url.path.endsWith('/review_capabilities_v2')) {
          if (mode == 'legacy') {
            status = 404;
            body = {'code': 'PGRST202', 'message': 'function unavailable'};
          } else {
            body = {'version': 2, 'enabled': true};
          }
        } else {
          final ids = (jsonDecode(request.body)['p_purchase_ids'] as List)
              .cast<String>();
          expect(ids.length, lessThanOrEqualTo(100));
          if (mode == 'switch') {
            when(() => service.currentUser).thenReturn(null);
          }
          body = [
            for (final id in ids)
              {
                'purchase_id': mode == 'foreign' ? 'foreign' : id,
                'friendliness': 5,
                'communication': 4,
                'cleanliness': mode == 'malformed' ? null : 3,
                'valid': false,
                'submitted_at': '2026-10-15T10:02:00Z',
              },
          ];
        }
        return http.Response(
          jsonEncode(body),
          status,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    when(() => service.client).thenReturn(client);
    await installEvaluationSession(client, 'S1', actor: 'customer');
    await pumpEventQueue();
  });
  tearDown(() async {
    await client.dispose();
  });
  test(
    'three criteria remain distinct from scalar legacy history and invalid evidence stays labeled',
    () async {
      final result = await PurchaseHistoryRepositoryImpl(
        supabaseService: service,
        reviewsEnabled: true,
      ).getVerifiedPurchases();
      final value = result.getOrElse(() => throw StateError('failed')).single;
      expect(value.customerRating, 2);
      expect(value.serviceEvaluation!.criteria.communication, 4);
      expect(value.serviceEvaluation!.criteria.average, 4);
      expect(value.serviceEvaluation!.valid, false);
    },
  );
  test(
    'history batches preserve all records and avoid per-purchase RPCs',
    () async {
      count = 201;
      final result = await PurchaseHistoryRepositoryImpl(
        supabaseService: service,
        reviewsEnabled: true,
      ).getVerifiedPurchases();
      expect(result.getOrElse(() => []).length, 201);
      expect(
        paths
            .where((p) => p.endsWith('/read_customer_service_evaluations_v2'))
            .length,
        3,
      );
    },
  );
  test(
    'flag OFF and an older backend preserve the old history contract',
    () async {
      expect(
        (await PurchaseHistoryRepositoryImpl(
          supabaseService: service,
          reviewsEnabled: false,
        ).getVerifiedPurchases()).isRight(),
        true,
      );
      expect(paths.length, 1);
      paths.clear();
      mode = 'legacy';
      final result = await PurchaseHistoryRepositoryImpl(
        supabaseService: service,
        reviewsEnabled: true,
      ).getVerifiedPurchases();
      expect(result.isRight(), true);
      expect(paths.length, 2);
      expect(result.getOrElse(() => []).single.serviceEvaluation, null);
    },
  );
  test(
    'foreign or incomplete criterion rows and account changes fail closed',
    () async {
      for (final invalid in ['foreign', 'malformed', 'switch']) {
        mode = invalid;
        when(() => service.currentUser).thenReturn(user);
        final result = await PurchaseHistoryRepositoryImpl(
          supabaseService: service,
          reviewsEnabled: true,
        ).getVerifiedPurchases();
        expect(result.isLeft(), true);
      }
    },
  );
}
