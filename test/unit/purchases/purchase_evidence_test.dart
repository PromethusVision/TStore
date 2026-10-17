import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/purchases/data/repositories/supabase_purchase_evidence_repository.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';

Map<String, dynamic> evidence() => {
  'id': 'purchase',
  'shop_id': 'shop',
  'confirmed_at': '2026-10-15T00:00:00Z',
  'terms_classification': 'quote_only_b_v1',
  'final_sale_minor': 3600,
  'customer_payment_minor': 3600,
  'ev_coupon_minor': 0,
  'invalidated': false,
  'items': [
    {
      'id': 'item',
      'product_name': 'Ürün',
      'quantity': 3,
      'returned_quantity': 1,
    },
  ],
  'returns': [
    {
      'id': 'return',
      'return_kind': 'genuine',
      'occurred_at': '2026-10-15T00:01:00Z',
      'refund_executed': false,
    },
  ],
};
void main() {
  test(
    'coupon evidence rejects negative physical payment and duplicate return references',
    () {
      expect(
        () => PurchaseEvidence.fromJson({
          ...evidence(),
          'terms_classification': 'coupon_checkout_e_v1',
          'final_sale_minor': '100',
          'ev_coupon_minor': '200',
          'customer_payment_minor': '-100',
          'coupon_restoration_executed': false,
        }),
        throwsFormatException,
      );
      final row = evidence();
      expect(
        () => PurchaseEvidence.fromJson({
          ...row,
          'returns': [...row['returns'] as List, ...row['returns'] as List],
        }),
        throwsFormatException,
      );
    },
  );
  test('evidence uses exact minor units and truthful return references', () {
    final p = PurchaseEvidence.fromJson(evidence());
    expect(p.finalSaleMinor, 3600);
    expect(p.items.single.remaining, 2);
    expect(p.canRecordReturn, true);
    expect(p.returns.single.isCorrection, false);
    expect(
      PurchaseEvidence.fromJson({
        ...evidence(),
        'invalidated': true,
      }).canRecordReturn,
      false,
    );
    expect(
      PurchaseEvidence.fromJson({
        ...evidence(),
        'terms_classification': 'legacy_unclassified',
        'final_sale_minor': null,
      }).canRecordReturn,
      false,
    );
  });
  test(
    'malformed money, unknown terms and fabricated cash refund are rejected',
    () {
      for (final row in [
        {...evidence(), 'final_sale_minor': 36.0},
        {...evidence(), 'ev_coupon_minor': 1},
        {...evidence(), 'terms_classification': 'guessed'},
        {
          ...evidence(),
          'returns': [
            {
              'id': 'return',
              'return_kind': 'genuine',
              'occurred_at': '2026-10-15',
              'refund_executed': true,
            },
          ],
        },
        {
          ...evidence(),
          'items': [
            {
              'id': 'item',
              'product_name': 'Ürün',
              'quantity': 3,
              'returned_quantity': 4,
            },
          ],
        },
      ]) {
        expect(() => PurchaseEvidence.fromJson(row), throwsFormatException);
      }
    },
  );
  test(
    'return RPC carries stable request and exact quantities, no client money',
    () async {
      late Map<String, dynamic> body;
      final client = SupabaseClient(
        'http://localhost:54321',
        'synthetic-key',
        httpClient: MockClient((request) async {
          expect(request.url.path, endsWith('/record_purchase_return_v2'));
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode(evidence()),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final repo = SupabasePurchaseEvidenceRepository(
        client,
        transport: QrProtocolV2(
          client,
          installation: () async => 'installation',
          sessionIdentity: () => 'owner:session',
        ),
      );
      final result = await repo.recordReturn(
        purchaseId: 'purchase',
        requestId: 'stable',
        quantities: {'item': 1},
        reason: 'İade',
      );
      expect(result.isRight(), true);
      expect(body['p_request_id'], 'stable');
      expect(body['p_items'], [
        {'purchase_item_id': 'item', 'quantity': 1},
      ]);
      expect(
        body.keys.any((k) => k.contains('amount') || k.contains('price')),
        false,
      );
    },
  );
  test(
    'only a known rolled-back validation rejection releases an uncertain return draft',
    () async {
      for (final code in ['P0001', '57014', '42501']) {
        final client = SupabaseClient(
          'http://localhost:54321',
          'synthetic-key',
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode({
                'code': code,
                'message': 'Return exceeds purchased quantity',
              }),
              400,
              headers: {'content-type': 'application/json'},
              request: request,
            ),
          ),
        );
        final repo = SupabasePurchaseEvidenceRepository(
          client,
          transport: QrProtocolV2(
            client,
            installation: () async => 'installation',
            sessionIdentity: () => 'owner:session',
          ),
        );
        final result = await repo.recordReturn(
          purchaseId: 'purchase',
          requestId: 'stable',
          quantities: {'item': 1},
          reason: 'İade',
        );
        expect(
          result.fold(
            (e) => e.definitelyRejected,
            (_) => throw StateError('Unexpected success'),
          ),
          code == 'P0001',
        );
        await client.dispose();
      }
    },
  );
  test(
    'purchase read discards response after same-user session switch',
    () async {
      var identity = 'owner:session';
      final client = SupabaseClient(
        'http://localhost:54321',
        'synthetic-key',
        httpClient: MockClient((request) async {
          identity = 'owner:new-session';
          return http.Response(
            jsonEncode(evidence()),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final repo = SupabasePurchaseEvidenceRepository(
        client,
        transport: QrProtocolV2(client, sessionIdentity: () => identity),
      );
      expect((await repo.read('purchase')).isLeft(), true);
    },
  );
}
