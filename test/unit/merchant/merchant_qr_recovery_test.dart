import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/cart/data/models/qr_verification_model.dart';
import 'package:t_store/features/cart/data/qr_protocol_v2.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_claim_repository.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';
import 'package:t_store/features/merchant/data/merchant_qr_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/purchases/data/repositories/supabase_purchase_evidence_repository.dart';
import '../cart/qr_claim_protocol_test.dart'
    show ClaimTestRepository, claimCubit, claimValue, claimJson;

class RecoveryRepo extends ClaimTestRepository implements QrSessionIdentity {
  @override
  String? currentQrSessionIdentity = 'owner:session';
  Future<Either<String, QrVerificationEntity?>> Function()? recovery;
  int recoveries = 0, cancellations = 0;
  @override
  Future<Either<String, QrVerificationEntity?>> recoverClaim(
    String shopId,
  ) async {
    recoveries++;
    return recovery == null ? Right(recovered) : recovery!();
  }

  @override
  Future<Either<String, QrVerificationEntity>> cancelClaim(String id) async {
    cancellations++;
    return super.cancelClaim(id);
  }
}

class AccessRepo extends Fake implements MerchantRepository {
  Future<Either<String, MerchantAccess?>> Function()? action;
  @override
  Future<Either<String, MerchantAccess?>> loadAccess() => action!();
}

void main() {
  test(
    'lost first claim acknowledgement blocks new input until recovered',
    () async {
      final r = RecoveryRepo()..claimAction = () async => const Left('offline');
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      c.reset();
      await c.claimVerification(manualCode: '654321');
      await c.confirmVerification();
      expect(c.state, isA<QrClaimRecoveryRequired>());
      expect(r.claims, 1);
      expect(r.completions, 0);
      r.recovered = claimValue();
      await c.refreshClaim();
      expect(c.state, isA<QrVerificationLoaded>());
      expect(r.claims, 1);
    },
  );
  test(
    'failed startup recovery remains closed and explicit retry can reopen input',
    () async {
      final r = RecoveryRepo()..recovery = () async => throw StateError('raw');
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.recoverClaim();
      await c.claimVerification(manualCode: '123456');
      c.reset();
      expect(c.state, isA<QrClaimRecoveryRequired>());
      expect(r.claims, 0);
      r.recovery = () async => const Right(null);
      await c.refreshClaim();
      expect(c.state, isA<QrVerificationInitial>());
    },
  );
  test('no input or two input channels never dispatches a claim', () async {
    final r = RecoveryRepo();
    final c = claimCubit(r);
    addTearDown(c.close);
    await c.claimVerification();
    await c.claimVerification(manualCode: '123456', sessionToken: 'token');
    expect(r.claims, 0);
  });
  test(
    'premature confirm cannot abandon a still-pending first claim',
    () async {
      final pending = Completer<Either<String, QrVerificationEntity>>();
      final r = RecoveryRepo()..claimAction = () => pending.future;
      final c = claimCubit(r);
      addTearDown(c.close);
      final first = c.claimVerification(manualCode: '123456');
      await c.confirmVerification();
      await c.claimVerification(manualCode: '654321');
      expect(c.state, isA<QrVerificationLoading>());
      expect(r.claims, 1);
      expect(r.completions, 0);
      pending.complete(Right(claimValue()));
      await first;
      expect(c.state, isA<QrVerificationLoaded>());
    },
  );
  test(
    'known uncertain claim cannot be replaced by latest-null recovery',
    () async {
      final r = RecoveryRepo();
      r.completeAction = () async => const Left('offline');
      r.reconcileAction = () async => const Left('offline');
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      await c.confirmVerification();
      await c.recoverClaim();
      await c.cancelClaim();
      expect(c.state, isA<QrVerificationUncertain>());
      expect(r.recoveries, 0);
      expect(r.cancellations, 0);
    },
  );
  test('throwing completion and reconciliation remain recoverable', () async {
    final r = RecoveryRepo();
    r.completeAction = () async => throw StateError('transport');
    r.reconcileAction = () async => throw StateError('transport');
    final c = claimCubit(r);
    addTearDown(c.close);
    await c.claimVerification(manualCode: '123456');
    await c.confirmVerification();
    expect(c.state, isA<QrVerificationUncertain>());
    r.reconcileAction = () async => Right(claimValue(status: 'used'));
    await c.refreshClaim();
    expect(c.state, isA<QrVerificationSuccess>());
  });
  test(
    'duplicate recovery and reset cannot abandon in-flight request',
    () async {
      final pending = Completer<Either<String, QrVerificationEntity?>>();
      final r = RecoveryRepo()..recovery = () => pending.future;
      final c = claimCubit(r);
      addTearDown(c.close);
      final first = c.recoverClaim();
      await c.recoverClaim();
      c.reset();
      expect(c.state, isA<QrVerificationLoading>());
      expect(r.recoveries, 1);
      pending.complete(Right(claimValue()));
      await first;
      expect(c.state, isA<QrVerificationLoaded>());
    },
  );
  test(
    'new failed claim does not reconcile a previous completed purchase',
    () async {
      final r = RecoveryRepo();
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      await c.confirmVerification();
      r.claimAction = () async => const Left('offline');
      await c.claimVerification(manualCode: '654321');
      await c.refreshClaim();
      expect(r.recoveries, 1);
      expect(r.reconciliations, 0);
      expect(c.state, isA<QrVerificationInitial>());
    },
  );
  for (final change in <String, dynamic>{
    'expires_at': '2001-01-01T00:00:00Z',
    'completion_expires_at': '2099-02-01T00:00:00Z',
    'shop_id': 'foreign',
    'session_token': 'foreign',
  }.entries) {
    test('reconciliation cannot change immutable ${change.key}', () async {
      final r = RecoveryRepo()
        ..reconcileAction = () async => Right(
          QrVerificationModel.fromJson({
            ...claimJson(status: 'used'),
            change.key: change.value,
          }),
        );
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      await c.refreshClaim();
      expect(c.state, isA<QrVerificationUncertain>());
    });
  }
  test(
    'a confirmed claim cannot reconcile to a different purchase receipt',
    () async {
      final r = RecoveryRepo();
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      await c.confirmVerification();
      r.reconcileAction = () async => Right(
        QrVerificationModel.fromJson({
          ...claimJson(status: 'used'),
          'purchase_id': 'other-purchase',
        }),
      );
      await c.refreshClaim();
      expect(c.state, isA<QrVerificationUncertain>());
    },
  );
  test(
    'foreign initial claim is not accepted even from a faulty adapter',
    () async {
      final r = RecoveryRepo()
        ..claimAction = () async => Right(
          QrVerificationModel.fromJson({...claimJson(), 'shop_id': 'foreign'}),
        );
      final c = claimCubit(r);
      addTearDown(c.close);
      await c.claimVerification(manualCode: '123456');
      expect(c.state, isA<QrClaimRecoveryRequired>());
    },
  );
  test(
    'workspace session change during access read cannot dispatch a claim',
    () async {
      final preview = MerchantPreview();
      addTearDown(preview.dispose);
      final access = MerchantAccess(
        user: preview.user,
        shop: preview.repository.shop,
      );
      final pending = Completer<Either<String, MerchantAccess?>>();
      final merchant = AccessRepo()..action = () => pending.future;
      final delegate = RecoveryRepo();
      final scoped = MerchantQrRepository(
        delegate: delegate,
        merchants: merchant,
        access: access,
      );
      final first = scoped.claimVerification(
        shopId: access.shop!.id,
        requestId: 'r',
        manualCode: '123456',
      );
      delegate.currentQrSessionIdentity = 'owner:replacement';
      pending.complete(Right(access));
      expect((await first).isLeft(), true);
      expect(delegate.claims, 0);
      expect((await scoped.recoverClaim(access.shop!.id)).isLeft(), true);
      expect(delegate.recoveries, 0);
    },
  );
  test('thrown access read denies before dispatch', () async {
    final preview = MerchantPreview();
    addTearDown(preview.dispose);
    final access = MerchantAccess(
      user: preview.user,
      shop: preview.repository.shop,
    );
    final merchant = AccessRepo()
      ..action = () async => throw StateError('offline');
    final delegate = RecoveryRepo();
    final scoped = MerchantQrRepository(
      delegate: delegate,
      merchants: merchant,
      access: access,
    );
    expect(
      (await scoped.claimVerification(
        shopId: access.shop!.id,
        requestId: 'r',
        manualCode: '123456',
      )).isLeft(),
      true,
    );
    expect(delegate.claims, 0);
  });
  for (final mode in ['server', 'format', 'protocol', 'transport']) {
    test(
      'late $mode error loses old-session authority and cannot release return',
      () async {
        var identity = 'owner:session';
        var callbacks = 0;
        final client = SupabaseClient(
          'http://localhost:54321',
          'synthetic-key',
        );
        addTearDown(client.dispose);
        final p = QrProtocolV2(client, sessionIdentity: () => identity);
        final result = await p.run<void>(() async {
          identity = 'owner:replacement';
          switch (mode) {
            case 'server':
              throw const PostgrestException(
                message: 'Return exceeds purchased quantity',
                code: 'P0001',
              );
            case 'format':
              throw const FormatException('raw');
            case 'protocol':
              throw const QrProtocolFailure('raw');
            default:
              throw StateError('raw');
          }
        }, onServerError: (_) => callbacks++);
        expect(
          result.fold((e) => e, (_) => ''),
          contains('Oturumunuz değişti'),
        );
        expect(callbacks, 0);
      },
    );
  }
  test(
    'real return adapter stale rejection is uncertain, preserving pending intent',
    () async {
      var identity = 'owner:session';
      final client = SupabaseClient(
        'http://localhost:54321',
        'synthetic-key',
        httpClient: MockClient((request) async {
          identity = 'owner:replacement';
          return http.Response(
            jsonEncode({
              'code': 'P0001',
              'message': 'Return exceeds purchased quantity',
            }),
            400,
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
          sessionIdentity: () => identity,
        ),
      );
      final result = await repo.recordReturn(
        purchaseId: 'purchase',
        requestId: 'request',
        quantities: {'item': 1},
        reason: 'İade',
      );
      expect(result.fold((e) => e.definitelyRejected, (_) => true), false);
    },
  );
}
