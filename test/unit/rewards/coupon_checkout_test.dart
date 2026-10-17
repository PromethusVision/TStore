import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/data/models/qr_session_model.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/data/supabase_coupon_checkout_repository.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout_terms.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import '../../support/reward_fixtures.dart';
import '../../support/coupon_checkout_fixtures.dart';
import '../cart/qr_claim_protocol_test.dart' show claimJson;

void main() {
  test('physical coupon terms cannot imply negative remaining payment', () {
    expect(
      () => CouponCheckoutTerms.fromJson({
        ...checkoutTerms(),
        'sale_minor': '100',
        'coupon_minor': '200',
        'payment_minor': '-100',
      }),
      throwsFormatException,
    );
  });
  test(
    'recovery reads an owned existing approval without generating another authorization',
    () async {
      final client = SupabaseClient('http://127.0.0.1:55431', 'synthetic');
      addTearDown(client.dispose);
      var foreign = false;
      final calls = <String>[];
      final repo = SupabaseCouponCheckoutRepository(
        client,
        identity: () => 'session',
        user: () => rewardUser,
        sessions: const Stream.empty(),
        rpc: (name, args) async {
          calls.add(name);
          return {
            ...checkoutPreview(),
            'existing_qr': {
              ...checkoutQr(),
              if (foreign) 'user_id': rewardShop,
            },
          };
        },
      );
      final result = await repo.preview(rewardId);
      expect(result.isRight(), true);
      expect(
        result.getOrElse(() => throw StateError('missing')).existingSession?.id,
        'qr',
      );
      expect(calls, ['preview_coupon_checkout_v1']);
      foreign = true;
      expect((await repo.preview(rewardId)).isLeft(), true);
    },
  );
  test(
    'purchase evidence retains exact economic amounts and refuses invented restoration',
    () {
      final row = <String, dynamic>{
        'id': rewardId,
        'shop_id': rewardShop,
        'confirmed_at': rewardNow,
        'invalidated': false,
        'terms_classification': 'coupon_checkout_e_v1',
        'final_sale_minor': '9007199254740993',
        'ev_coupon_minor': '25000',
        'customer_payment_minor': '9007199254715993',
        'coupon_restoration_executed': false,
        'returns': <dynamic>[],
        'items': [
          {
            'id': 'item',
            'product_name': 'Ürün',
            'quantity': 1,
            'returned_quantity': 0,
          },
        ],
      };
      final evidence = PurchaseEvidence.fromJson(row);
      expect(evidence.saleExact!.value.toString(), '9007199254740993');
      expect(evidence.canRecordReturn, true);
      for (final change in [
        {'ev_coupon_minor': 25000},
        {'customer_payment_minor': '1'},
        {'coupon_restoration_executed': true},
      ]) {
        expect(
          () => PurchaseEvidence.fromJson({...row, ...change}),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'preview rejects numeric or over-limit authority and unknown eligibility',
    () {
      expect(
        CouponCheckoutPreview.fromJson(checkoutPreview()).maximum.value,
        BigInt.from(25000),
      );
      for (final change in [
        {'sale_minor': 50000},
        {'maximum_coupon_minor': '25001'},
        {'enabled': false},
        {'eligibility': 'invented'},
        {'fingerprint': 'bad'},
        {'cart_id': 'other'},
      ]) {
        expect(
          () =>
              CouponCheckoutPreview.fromJson({...checkoutPreview(), ...change}),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'exact terms roundtrip and QR reject missing, inconsistent or legacy monetary terms',
    () {
      final terms = CouponCheckoutTerms.fromJson(checkoutTerms());
      expect(CouponCheckoutTerms.fromJson(terms.toJson()), terms);
      for (final value in [null, 0, '-1', '01', '1.0', '']) {
        expect(
          () => CouponCheckoutTerms.fromJson({
            ...checkoutTerms(),
            'coupon_minor': value,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => CouponCheckoutTerms.fromJson({
          ...checkoutTerms(),
          'payment_minor': '25001',
        }),
        throwsFormatException,
      );
      final qr = QrSessionModel.fromJson(checkoutQr());
      expect(QrSessionModel.fromEntity(qr).couponCheckout, terms);
      expect(QrSessionModel.fromJson(qr.toJson()).couponCheckout, terms);
      expect(
        () => QrSessionModel.fromJson({...checkoutQr(), 'protocol_version': 1}),
        throwsFormatException,
      );
    },
  );
  test(
    'customer approval sends exact reviewed fingerprint and rejects foreign response',
    () async {
      final client = SupabaseClient('http://127.0.0.1:55431', 'synthetic');
      addTearDown(client.dispose);
      final calls = <String>[], args = <Map<String, dynamic>>[];
      var foreign = false;
      final repo = SupabaseCouponCheckoutRepository(
        client,
        identity: () => 'session',
        user: () => rewardUser,
        sessions: const Stream.empty(),
        rpc: (name, parameters) async {
          calls.add(name);
          args.add(parameters);
          return name.startsWith('preview')
              ? checkoutPreview()
              : {...checkoutQr(), if (foreign) 'user_id': rewardShop};
        },
      );
      expect((await repo.preview(rewardId)).isRight(), true);
      final preview = CouponCheckoutPreview.fromJson(checkoutPreview());
      expect(
        (await repo.approve(
          preview,
          rewardUser,
          LedgerMinorUnits.fromWire('25000'),
        )).isRight(),
        true,
      );
      expect(args.last, {
        'p_cart': rewardId,
        'p_request': rewardUser,
        'p_fingerprint': 'a' * 64,
        'p_coupon_minor': '25000',
      });
      final count = calls.length;
      expect(
        (await repo.approve(
          preview,
          rewardUser,
          LedgerMinorUnits.fromWire('25001'),
        )).isLeft(),
        true,
      );
      expect(calls.length, count);
      foreign = true;
      expect(
        (await repo.approve(
          preview,
          rewardUser,
          LedgerMinorUnits.fromWire('25000'),
        )).isLeft(),
        true,
      );
    },
  );
  test(
    'session A to B to A and response timeout discard private approval result',
    () async {
      final client = SupabaseClient('http://127.0.0.1:55431', 'synthetic');
      addTearDown(client.dispose);
      final sessions = StreamController<void>.broadcast(sync: true);
      addTearDown(sessions.close);
      var identity = 'A';
      final pending = Completer<dynamic>();
      final repo = SupabaseCouponCheckoutRepository(
        client,
        identity: () => identity,
        user: () => rewardUser,
        sessions: sessions.stream,
        rpc: (_, _) => pending.future,
      );
      final result = repo.preview(rewardId);
      identity = 'B';
      sessions.add(null);
      identity = 'A';
      sessions.add(null);
      pending.complete(checkoutPreview());
      expect((await result).isLeft(), true);
      final timeout = SupabaseCouponCheckoutRepository(
        client,
        identity: () => identity,
        user: () => rewardUser,
        sessions: sessions.stream,
        timeout: const Duration(milliseconds: 1),
        rpc: (_, _) => Completer<dynamic>().future,
      );
      expect((await timeout.preview(rewardId)).isLeft(), true);
    },
  );
  test(
    'merchant reconciles and attests all three exact amounts; old client never spends coupon',
    () async {
      for (final enabled in [true, false]) {
        final calls = <String>[], bodies = <Map<String, dynamic>>[];
        final client = SupabaseClient(
          'http://127.0.0.1:55431',
          'synthetic',
          httpClient: MockClient((request) async {
            calls.add(request.url.path.split('/').last);
            bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
            return http.Response(
              jsonEncode({
                ...claimJson(status: calls.length == 1 ? 'claimed' : 'used'),
                ...earningQuote(),
                'reward_confirmation_required': true,
                'reward_sale_minor': '50000',
                'coupon_checkout': checkoutTerms(),
              }),
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            );
          }),
        );
        final protocol = QrProtocolV2(
          client,
          installation: () async => 'device',
          sessionIdentity: () => 'session',
          rewardEarningEnabled: true,
          couponCheckoutEnabled: enabled,
        );
        expect(
          (await protocol.operation(
            'complete_existing_qr_v2',
            'claim',
          )).isRight(),
          enabled,
        );
        expect(
          calls,
          enabled
              ? ['reconcile_claim_v2', 'complete_coupon_qr_v1']
              : ['reconcile_claim_v2'],
        );
        if (enabled) {
          expect(bodies.last, {
            'p_claim_id': 'claim',
            'p_installation_id': 'device',
            'p_sale_minor': '50000',
            'p_coupon_minor': '25000',
            'p_payment_minor': '25000',
          });
        }
        await client.dispose();
      }
    },
  );
  test('merchant model rejects coupon checkout without reward attestation', () {
    expect(
      () => QrVerificationModel.fromJson({
        ...claimJson(),
        ...earningQuote(),
        'coupon_checkout': checkoutTerms(),
      }),
      throwsFormatException,
    );
  });
}
