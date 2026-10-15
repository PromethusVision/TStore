import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import '../cart/qr_claim_protocol_test.dart' show claimJson;
import '../../support/reward_fixtures.dart' show earningQuote;

void main() {
  Map<String, dynamic> earning({String status = 'claimed'}) => {
    ...claimJson(status: status),
    ...earningQuote(),
    'reward_confirmation_required': true,
    'reward_sale_minor': '50000',
  };
  test('E claim must carry a canonical integer amount and protocol v2', () {
    expect(QrVerificationModel.fromJson(earning()).rewardSaleMinor, '50000');
    for (final amount in [
      null,
      50000,
      '050000',
      '-1',
      '50000.0',
      '5e4',
      '',
      '49999',
    ]) {
      expect(
        () => QrVerificationModel.fromJson({
          ...earning(),
          'reward_sale_minor': amount,
        }),
        throwsFormatException,
      );
    }
    expect(
      () => QrVerificationModel.fromJson({
        ...earning(),
        'reward_confirmation_required': 'yes',
      }),
      throwsFormatException,
    );
    expect(
      QrVerificationModel.fromJson(claimJson()).rewardConfirmationRequired,
      false,
    );
  });
  test(
    'E completion reconciles same claim then sends exact server amount to the E endpoint',
    () async {
      final calls = <String>[], bodies = <Map<String, dynamic>>[];
      final client = SupabaseClient(
        'http://127.0.0.1:55431',
        'synthetic',
        httpClient: MockClient((r) async {
          calls.add(r.url.path.split('/').last);
          bodies.add(jsonDecode(r.body) as Map<String, dynamic>);
          return http.Response(
            jsonEncode(earning(status: calls.length == 1 ? 'claimed' : 'used')),
            200,
            headers: {'content-type': 'application/json'},
            request: r,
          );
        }),
      );
      final p = QrProtocolV2(
        client,
        installation: () async => 'device',
        sessionIdentity: () => 'session',
        rewardEarningEnabled: true,
      );
      expect(
        (await p.operation('complete_existing_qr_v2', 'claim')).isRight(),
        true,
      );
      expect(calls, ['reconcile_claim_v2', 'complete_reward_qr_v1']);
      expect(bodies.last, {
        'p_claim_id': 'claim',
        'p_installation_id': 'device',
        'p_actual_sale_minor': '50000',
      });
      await client.dispose();
    },
  );
  test(
    'legacy B claim retains B completion even in an E-enabled build',
    () async {
      final calls = <String>[];
      final client = SupabaseClient(
        'http://127.0.0.1:55431',
        'synthetic',
        httpClient: MockClient((r) async {
          calls.add(r.url.path.split('/').last);
          return http.Response(
            jsonEncode(
              claimJson(status: calls.length == 1 ? 'claimed' : 'used'),
            ),
            200,
            headers: {'content-type': 'application/json'},
            request: r,
          );
        }),
      );
      final p = QrProtocolV2(
        client,
        installation: () async => 'device',
        sessionIdentity: () => 'session',
        rewardEarningEnabled: true,
      );
      expect(
        (await p.operation('complete_existing_qr_v2', 'claim')).isRight(),
        true,
      );
      expect(calls, ['reconcile_claim_v2', 'complete_existing_qr_v2']);
      await client.dispose();
    },
  );
  test(
    'foreign reconciliation and session change cannot proceed to a money mutation',
    () async {
      for (final changeSession in [false, true]) {
        var identity = 'one';
        var count = 0;
        final client = SupabaseClient(
          'http://127.0.0.1:55431',
          'synthetic',
          httpClient: MockClient((r) async {
            count++;
            if (changeSession) identity = 'two';
            return http.Response(
              jsonEncode({
                ...earning(),
                'claim_id': changeSession ? 'claim' : 'foreign',
              }),
              200,
              headers: {'content-type': 'application/json'},
              request: r,
            );
          }),
        );
        final p = QrProtocolV2(
          client,
          installation: () async => 'device',
          sessionIdentity: () => identity,
          rewardEarningEnabled: true,
        );
        expect(
          (await p.operation('complete_existing_qr_v2', 'claim')).isLeft(),
          true,
        );
        expect(count, 1);
        await client.dispose();
      }
    },
  );
  test(
    'session change during public capability read cannot create QR under the new session',
    () async {
      var identity = 'one';
      final calls = <String>[];
      final client = SupabaseClient(
        'http://127.0.0.1:55431',
        'synthetic',
        httpClient: MockClient((r) async {
          calls.add(r.url.path.split('/').last);
          identity = 'two';
          return http.Response(
            jsonEncode({
              'version': 1,
              'enabled': true,
              'redemption_enabled': false,
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: r,
          );
        }),
      );
      final p = QrProtocolV2(
        client,
        sessionIdentity: () => identity,
        rewardEarningEnabled: true,
      );
      expect((await p.create('cart')).isLeft(), true);
      expect(calls, ['reward_capabilities_v1']);
      await client.dispose();
    },
  );
}
