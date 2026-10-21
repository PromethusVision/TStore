import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/data/repositories/qr_session_repository_impl.dart';
import 'package:t_store/features/purchases/data/repositories/supabase_purchase_evidence_repository.dart';
import 'package:t_store/features/rewards/data/supabase_coupon_checkout_repository.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import '../../support/coupon_checkout_fixtures.dart';
import '../../support/reward_fixtures.dart';
import 'qr_claim_protocol_test.dart' show claimJson;

class Service extends Fake implements SupabaseService {
  Service(this.client);
  @override
  final SupabaseClient client;
  @override
  User? get currentUser => client.auth.currentUser;
}

void main() {
  late SupabaseClient client;
  late QrProtocolV2 protocol;
  late QrSessionRepositoryImpl legacy;
  late SupabaseCouponCheckoutRepository coupon;
  late SupabasePurchaseEvidenceRepository purchases;
  late Future<http.Response> Function(http.Request) respond;
  late Future<String> Function() installation;
  final calls = <String>[];
  String segment(Object v) =>
      base64Url.encode(utf8.encode(jsonEncode(v))).replaceAll('=', '');
  Future<void> session({
    String key = 'S1',
    int token = 0,
    String user = rewardUser,
  }) => client.auth.setInitialSession(
    jsonEncode({
      'access_token':
          '${segment({'alg': 'none'})}.${segment({'sub': user, 'session_id': key, 'nonce': token, 'exp': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000})}.synthetic',
      'refresh_token': 'synthetic-only',
      'token_type': 'bearer',
      'user': {
        'id': user,
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    }),
  );
  Future<void> bounce() async {
    await Future.wait([session(key: 'S2'), session(token: 2)]);
    await pumpEventQueue();
  }

  http.Response json(Object? v, [int status = 200]) => http.Response(
    jsonEncode(v),
    status,
    headers: {'content-type': 'application/json'},
  );
  Map<String, dynamic> purchase() => {
    'id': 'purchase',
    'shop_id': 'shop',
    'confirmed_at': rewardNow,
    'terms_classification': 'quote_only_b_v1',
    'invalidated': false,
    'final_sale_minor': 3600,
    'ev_coupon_minor': 0,
    'customer_payment_minor': 3600,
    'returns': <dynamic>[],
    'items': [
      {
        'id': 'item',
        'product_name': 'Ürün',
        'quantity': 3,
        'returned_quantity': 0,
      },
    ],
  };
  Object? payload(String op) => switch (op) {
    'create' || 'read' || 'legacy-create' || 'approve' => checkoutQr(),
    'legacy-status' => {
      'status': 'active',
      'expires_at': '2099-01-01T00:00:00Z',
    },
    'legacy-read' || 'legacy-confirm' => {
      ...claimJson(status: op == 'legacy-confirm' ? 'used' : 'active'),
      'protocol_version': 1,
      'expires_at': '2099-01-01T00:00:00Z',
    },
    'preview' => checkoutPreview(),
    'list' => [purchase()],
    'purchase' || 'return' => purchase(),
    'recover' => null,
    _ => claimJson(
      status: op == 'complete'
          ? 'used'
          : op == 'cancel'
          ? 'cancelled'
          : 'claimed',
    ),
  };
  Future<dynamic> invoke(String op) => switch (op) {
    'create' => protocol.create(rewardId),
    'read' => protocol.read('qr'),
    'claim' => protocol.claim(
      shopId: 'shop',
      requestId: 'request',
      manualCode: '123456',
    ),
    'complete' => protocol.operation('complete_existing_qr_v2', 'claim'),
    'cancel' => protocol.operation('cancel_claim_v2', 'claim'),
    'reconcile' => protocol.operation('reconcile_claim_v2', 'claim'),
    'recover' => protocol.recover('shop'),
    'legacy-create' => legacy.createQrSession(cartId: rewardId),
    'legacy-status' => legacy.getQrSessionStatus(sessionId: 'qr'),
    'legacy-read' => legacy.getQrVerification(sessionToken: 'token'),
    'legacy-confirm' => legacy.confirmQrVerification(sessionToken: 'token'),
    'preview' => coupon.preview(rewardId),
    'approve' => coupon.approve(
      CouponCheckoutPreview.fromJson(checkoutPreview()),
      'request',
      CouponCheckoutPreview.fromJson(checkoutPreview()).maximum,
    ),
    'list' => purchases.list('shop'),
    'purchase' => purchases.read('purchase'),
    _ => purchases.recordReturn(
      purchaseId: 'purchase',
      requestId: 'request',
      quantities: {'item': 1},
      reason: 'İade',
    ),
  };
  setUp(() async {
    calls.clear();
    installation = () async => 'installation';
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-only',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((r) async {
        calls.add(r.url.path.split('/').last);
        final response = await respond(r);
        return http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: r,
        );
      }),
    );
    await session();
    protocol = QrProtocolV2(client, installation: () => installation());
    legacy = QrSessionRepositoryImpl(supabaseService: Service(client));
    coupon = SupabaseCouponCheckoutRepository(client);
    purchases = SupabasePurchaseEvidenceRepository(client, transport: protocol);
  });
  tearDown(() => client.dispose());

  test(
    'concurrent identical coupon approval shares one request without write timeout',
    () async {
      final wait = Completer<http.Response>();
      respond = (_) => wait.future;
      coupon = SupabaseCouponCheckoutRepository(
        client,
        timeout: const Duration(milliseconds: 1),
      );
      final preview = CouponCheckoutPreview.fromJson(checkoutPreview());
      var done = false;
      final first = coupon
          .approve(preview, 'same', preview.maximum)
          .whenComplete(() => done = true);
      final second = coupon.approve(preview, 'same', preview.maximum);
      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(done, false);
      expect(calls, ['create_coupon_qr_v1']);
      expect(
        (await coupon.approve(preview, 'different', preview.maximum)).isLeft(),
        true,
      );
      wait.complete(json(checkoutQr()));
      expect((await first).isRight(), true);
      expect((await second).isRight(), true);
      expect(calls.length, 1);
    },
  );
  for (final replaced in [false, true]) {
    test(
      'reopened coupon preview waits for dispatched write; replacement=$replaced',
      () async {
        final wait = Completer<http.Response>();
        respond = (r) => r.url.path.endsWith('create_coupon_qr_v1')
            ? wait.future
            : Future.value(
                json({...checkoutPreview(), 'existing_qr': checkoutQr()}),
              );
        final preview = CouponCheckoutPreview.fromJson(checkoutPreview());
        final command = coupon.approve(preview, 'same', preview.maximum);
        await pumpEventQueue();
        final read = coupon.preview(rewardId);
        await pumpEventQueue();
        expect(calls, ['create_coupon_qr_v1']);
        if (replaced) await bounce();
        wait.complete(json(checkoutQr()));
        expect((await command).isRight(), !replaced);
        expect((await read).isRight(), !replaced);
        expect(calls.length, replaced ? 1 : 2);
      },
    );
  }
  for (final signal in ['error', 'closed', 'logout', 'other account']) {
    test('QR pending request fails closed on $signal', () async {
      final keys = StreamController<String?>.broadcast();
      final wait = Completer<void>();
      protocol = QrProtocolV2(client, sessionKeys: keys.stream);
      final request = protocol.run(() async {
        await wait.future;
        return 'private';
      });
      if (signal == 'error') {
        keys.addError(StateError('lost source'));
      }
      if (signal == 'closed') {
        await keys.close();
      }
      if (signal == 'logout') {
        keys.add(null);
      }
      if (signal == 'other account') {
        await session(user: rewardShop);
        keys.add('$rewardShop:S1');
      }
      await pumpEventQueue();
      wait.complete();
      expect((await request).isLeft(), true);
      if (signal != 'closed') await keys.close();
    });
  }

  for (final op in [
    'create',
    'read',
    'claim',
    'complete',
    'cancel',
    'reconcile',
    'recover',
    'legacy-create',
    'legacy-status',
    'legacy-read',
    'legacy-confirm',
    'preview',
    'approve',
    'list',
    'purchase',
    'return',
  ]) {
    for (final outcome in ['success', 'server error', 'malformed']) {
      test('$op rejects queued S1 S2 S1 $outcome', () async {
        respond = (_) async {
          await bounce();
          return outcome == 'server error'
              ? json({
                  'message': 'Return exceeds purchased quantity',
                  'code': 'P0001',
                }, 400)
              : json(outcome == 'malformed' ? {'invalid': true} : payload(op));
        };
        final result = await invoke(op);
        final error = result.fold((dynamic e) => e, (_) => null);
        expect(error, isNotNull);
        expect(op == 'return' ? error.message : error, contains('Oturum'));
        if (op == 'return') expect(error.definitelyRejected, false);
      });
    }
    test('$op accepts unchanged-session token renewal', () async {
      respond = (_) async {
        await session(token: 8);
        return json(payload(op));
      };
      expect((await invoke(op)).isRight(), true);
      expect(calls.length, 1);
    });
  }
  for (final op in [
    'claim',
    'complete',
    'cancel',
    'reconcile',
    'recover',
    'return',
  ]) {
    test(
      '$op never dispatches after replacement during installation read',
      () async {
        installation = () async {
          await bounce();
          return 'installation';
        };
        respond = (_) async => json(payload(op));
        expect((await invoke(op)).isLeft(), true);
        expect(calls, isEmpty);
      },
    );
  }
  test(
    'reward capability response cannot authorize QR creation in another session lifetime',
    () async {
      protocol = QrProtocolV2(client, rewardEarningEnabled: true);
      respond = (r) async {
        if (r.url.path.endsWith('reward_capabilities_v1')) {
          await bounce();
          return json({
            'version': 1,
            'enabled': true,
            'redemption_enabled': false,
          });
        }
        return json(checkoutQr());
      };
      expect((await protocol.create(rewardId)).isLeft(), true);
      expect(calls, ['reward_capabilities_v1']);
    },
  );
  test(
    'completion preflight cannot send a mutation after session bounce',
    () async {
      protocol = QrProtocolV2(
        client,
        installation: () async => 'installation',
        rewardEarningEnabled: true,
      );
      respond = (r) async {
        await bounce();
        return json(
          claimJson(
            status: r.url.path.endsWith('reconcile_claim_v2')
                ? 'claimed'
                : 'used',
          ),
        );
      };
      expect(
        (await protocol.operation('complete_existing_qr_v2', 'claim')).isLeft(),
        true,
      );
      expect(calls, ['reconcile_claim_v2']);
    },
  );
}
