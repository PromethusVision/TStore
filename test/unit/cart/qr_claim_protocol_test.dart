import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_session_status_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';

Map<String, dynamic> claimJson({
  String status = 'claimed',
  String claim = 'claim',
}) => {
  'protocol_version': 2,
  'session_id': 'qr',
  'session_token': 'token',
  'claim_id': claim,
  'status': status,
  'expires_at': '2000-01-01T00:00:00Z',
  'completion_expires_at': '2099-01-01T00:10:00Z',
  'used_at': status == 'used' ? '2026-10-15T00:00:00Z' : null,
  'purchase_id': status == 'used' ? 'purchase' : null,
  'shop_id': 'shop',
  'shop_name': 'Örnek Esnaf',
  'item_count': 3,
  'total_amount': 36,
  'items': [
    {
      'id': 'item',
      'shop_product_id': 'listing',
      'product_id': 'product',
      'product_name': 'Örnek ürün',
      'quantity': 3,
      'unit_price': 12,
      'line_total': 36,
    },
  ],
};
QrVerificationEntity claimValue({
  String status = 'claimed',
  String claim = 'claim',
}) => QrVerificationModel.fromJson(claimJson(status: status, claim: claim));

class ClaimTestRepository extends Fake
    implements QrSessionRepository, QrClaimRepository {
  @override
  bool get claimsEnabled => true;
  int claims = 0, completions = 0, reconciliations = 0;
  final requests = <String>[];
  Future<Either<String, QrVerificationEntity>> Function()? claimAction,
      completeAction,
      reconcileAction;
  QrVerificationEntity? recovered;
  @override
  Future<Either<String, QrVerificationEntity>> claimVerification({
    required String shopId,
    required String requestId,
    String? sessionToken,
    String? manualCode,
  }) async {
    claims++;
    requests.add(requestId);
    return claimAction == null ? Right(claimValue()) : claimAction!();
  }

  @override
  Future<Either<String, QrVerificationEntity>> completeClaim(String id) async {
    completions++;
    return completeAction == null
        ? Right(claimValue(status: 'used'))
        : completeAction!();
  }

  @override
  Future<Either<String, QrVerificationEntity>> reconcileClaim(String id) async {
    reconciliations++;
    return reconcileAction == null ? Right(claimValue()) : reconcileAction!();
  }

  @override
  Future<Either<String, QrVerificationEntity>> cancelClaim(String id) async =>
      Right(claimValue(status: 'cancelled'));
  @override
  Future<Either<String, QrVerificationEntity?>> recoverClaim(
    String shopId,
  ) async => Right(recovered);
  QrSessionEntity customer(String status) => QrSessionEntity(
    id: 'qr',
    sessionToken: 'token',
    userId: 'customer',
    cartId: 'cart',
    shopId: 'shop',
    status: status,
    expiresAt: DateTime.utc(2000),
    createdAt: DateTime.utc(2000),
    updatedAt: DateTime.utc(2000),
    protocolVersion: 2,
    completionExpiresAt: DateTime.utc(2099),
    itemCount: 3,
    totalAmount: 36,
  );
  String customerStatus = 'claimed';
  @override
  Future<Either<String, QrSessionEntity>> createQrSession({
    required String cartId,
  }) async => Right(customer(customerStatus));
  @override
  Future<Either<String, QrSessionEntity>> readCustomerSession(
    String sessionId,
  ) async => Right(customer(customerStatus));
}

QrVerificationCubit claimCubit(ClaimTestRepository r) => QrVerificationCubit(
  shopId: 'shop',
  getQrVerificationUsecase: GetQrVerificationUsecase(r),
  confirmQrVerificationUsecase: ConfirmQrVerificationUsecase(r),
);

void main() {
  test(
    'claimed confirmation uses completion deadline, and requires immutable purchase evidence for success',
    () {
      expect(claimValue().canBeConfirmed, true);
      expect(
        () => QrVerificationModel.fromJson({
          ...claimJson(status: 'used'),
          'purchase_id': null,
        }),
        throwsFormatException,
      );
      expect(
        () => QrVerificationModel.fromJson({
          ...claimJson(),
          'completion_expires_at': null,
        }),
        throwsFormatException,
      );
      expect(
        () =>
            QrVerificationModel.fromJson({...claimJson(), 'status': 'active'}),
        throwsFormatException,
      );
      expect(
        () => QrVerificationModel.fromJson({
          ...claimJson(),
          'protocol_version': 3,
        }),
        throwsFormatException,
      );
    },
  );
  test('double tap creates one claim and one completion', () async {
    final r = ClaimTestRepository();
    final c = claimCubit(r);
    addTearDown(c.close);
    final pending = Completer<Either<String, QrVerificationEntity>>();
    r.claimAction = () => pending.future;
    final call = c.claimVerification(manualCode: '123456');
    await c.claimVerification(manualCode: '123456');
    expect(r.claims, 1);
    pending.complete(Right(claimValue()));
    await call;
    final completing = Completer<Either<String, QrVerificationEntity>>();
    r.completeAction = () => completing.future;
    final submit = c.confirmVerification();
    await c.confirmVerification();
    expect(r.completions, 1);
    completing.complete(Right(claimValue(status: 'used')));
    await submit;
    expect(c.state, isA<QrVerificationSuccess>());
  });
  test(
    'claim failure requires recovery before an exact retry; invalid input never sent',
    () async {
      final r = ClaimTestRepository()
        ..claimAction = () async => const Left('network');
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '12');
      expect(r.claims, 0);
      await c.claimVerification(manualCode: '123456');
      await c.claimVerification(manualCode: '123456');
      expect(r.requests.length, 1);
      expect(c.state, isA<QrClaimRecoveryRequired>());
      await c.recoverClaim();
      await c.claimVerification(manualCode: '123456');
      expect(r.requests[0], r.requests[1]);
      await c.recoverClaim();
      await c.claimVerification(manualCode: '654321');
      expect(r.requests[2], isNot(r.requests[0]));
    },
  );
  test(
    'lost completion response reconciles same claim, no new purchase call',
    () async {
      final r = ClaimTestRepository();
      r.completeAction = () async => const Left('network');
      r.reconcileAction = () async => Right(claimValue(status: 'used'));
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.loadVerification('token');
      await c.confirmVerification();
      expect(c.state, isA<QrVerificationSuccess>());
      expect(r.completions, 1);
      expect(r.reconciliations, 1);
    },
  );
  test(
    'unknown outcome blocks re-submit/reset/new claim until authoritative reconciliation',
    () async {
      final r = ClaimTestRepository();
      r.completeAction = () async => const Left('network');
      r.reconcileAction = () async => const Left('offline');
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.loadVerification('token');
      await c.confirmVerification();
      expect(c.state, isA<QrVerificationUncertain>());
      c.reset();
      await c.confirmVerification();
      await c.loadVerification('other');
      expect(c.state, isA<QrVerificationUncertain>());
      expect(r.completions, 1);
      expect(r.claims, 1);
      r.reconcileAction = () async => Right(claimValue(status: 'used'));
      await c.refreshClaim();
      expect(c.state, isA<QrVerificationSuccess>());
    },
  );
  test(
    'foreign claim response never becomes success and closed cubit drops response',
    () async {
      final r = ClaimTestRepository()
        ..completeAction = () async =>
            Right(claimValue(status: 'used', claim: 'foreign'));
      final c = claimCubit(r);
      await c.loadVerification('token');
      await c.confirmVerification();
      expect(c.state, isA<QrVerificationUncertain>());
      await c.close();
      final pending = Completer<Either<String, QrVerificationEntity>>();
      final lateR = ClaimTestRepository()..claimAction = () => pending.future;
      final lateC = claimCubit(lateR);
      final future = lateC.loadVerification('token');
      await lateC.close();
      pending.complete(Right(claimValue()));
      await future;
      expect(lateC.state, isA<QrVerificationLoading>());
    },
  );
  test(
    'app reopen recovers existing claim and cancellation permits new scan',
    () async {
      final r = ClaimTestRepository()..recovered = claimValue();
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.recoverClaim();
      expect(c.state, isA<QrVerificationLoaded>());
      await c.cancelClaim();
      expect(c.state, isA<QrVerificationFailure>());
      c.reset();
      expect(c.state, isA<QrVerificationInitial>());
    },
  );
  test(
    'Customer polling continues past scan expiry for claimed v2 session',
    () async {
      final r = ClaimTestRepository();
      final c = QrSessionCubit(
        createQrSessionUsecase: CreateQrSessionUsecase(r),
        getQrSessionStatusUsecase: GetQrSessionStatusUsecase(r),
        statusCheckInterval: const Duration(hours: 1),
      );
      addTearDown(c.close);
      await c.createQrSession('cart');
      await c.checkSessionStatus();
      expect((c.state as QrSessionCreated).session.status, 'claimed');
      r.customerStatus = 'used';
      await c.checkSessionStatus();
      expect(c.state, isA<QrSessionCompleted>());
    },
  );
  test(
    'transport accepts a valid claim and sends the same request identity',
    () async {
      final client = SupabaseClient(
        'http://localhost:54321',
        'synthetic-key',
        httpClient: MockClient((request) async {
          expect(request.url.path, endsWith('/claim_existing_qr_v2'));
          expect(jsonDecode(request.body), {
            'p_shop_id': 'shop',
            'p_installation_id': 'installation',
            'p_request_id': 'request',
            'p_session_token': null,
            'p_manual_code': '123456',
          });
          return http.Response(
            jsonEncode(claimJson()),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final protocol = QrProtocolV2(
        client,
        installation: () async => 'installation',
        sessionIdentity: () => 'owner:session',
      );
      final result = await protocol.claim(
        shopId: 'shop',
        requestId: 'request',
        manualCode: '123456',
      );
      expect(result.fold((error) => error, (value) => value.claimId), 'claim');
    },
  );
  test(
    'transport rejects response after auth-session switch and never falls back to legacy',
    () async {
      var identity = 'owner:session';
      final calls = <String>[];
      final client = SupabaseClient(
        'http://localhost:54321',
        'synthetic-key',
        httpClient: MockClient((request) async {
          calls.add(request.url.path);
          identity = 'owner:new-session';
          return http.Response(
            jsonEncode(claimJson()),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final p = QrProtocolV2(
        client,
        installation: () async => 'installation',
        sessionIdentity: () => identity,
      );
      final result = await p.claim(
        shopId: 'shop',
        requestId: 'request',
        sessionToken: 'token',
      );
      expect(
        result.fold((error) => error, (_) => 'success'),
        contains('Oturumunuz değişti'),
      );
      expect(calls.single, endsWith('/claim_existing_qr_v2'));
    },
  );
  test(
    'transport verifies shop and claim identity; rate limit is an error, not empty success',
    () async {
      for (final payload in [
        {...claimJson(), 'shop_id': 'foreign'},
        {'error': 'QR_RATE_LIMITED'},
      ]) {
        final client = SupabaseClient(
          'http://localhost:54321',
          'synthetic-key',
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode(payload),
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            ),
          ),
        );
        final p = QrProtocolV2(
          client,
          installation: () async => 'installation',
          sessionIdentity: () => 'owner:session',
        );
        final result = await p.claim(
          shopId: 'shop',
          requestId: 'request',
          manualCode: '123456',
        );
        expect(
          result.fold((error) => error, (_) => 'success'),
          contains(
            payload.containsKey('error')
                ? 'Çok fazla'
                : 'Sunucunun işlem bilgisi',
          ),
        );
        await client.dispose();
      }
    },
  );
}
