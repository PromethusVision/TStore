import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_session_status_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';
import 'package:t_store/features/merchant/presentation/merchant_return_controller.dart';
import 'package:t_store/features/merchant/data/merchant_qr_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/purchases/domain/repositories/purchase_evidence_repository.dart';
import '../cart/qr_claim_protocol_test.dart';
import 'merchant_return_recovery_test.dart';
import 'merchant_qr_recovery_test.dart' show AccessRepo;
import '../../widget/merchant/merchant_qr_slice_b_test.dart' show purchase;

class SessionQr extends ClaimTestRepository
    implements AuthenticatedSessionEvents {
  final keys = StreamController<String?>.broadcast();
  @override
  String? currentSessionKey = 'owner:S1';
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  void bounce() {
    keys.add('owner:S2');
    keys.add(currentSessionKey);
  }
}

class SessionReturn extends ReturnRepo implements AuthenticatedSessionEvents {
  final keys = StreamController<String?>.broadcast();
  @override
  String? get currentSessionKey => currentQrSessionIdentity;
  @override
  Stream<String?> get sessionKeyChanges => keys.stream;
  void bounce() {
    keys.add('owner:replacement');
    keys.add(currentSessionKey);
  }
}

void main() {
  test(
    'merchant ownership preflight cannot dispatch after queued replacement',
    () async {
      final delegate = SessionQr();
      final preview = MerchantPreview();
      addTearDown(preview.dispose);
      final access = (await preview.repository.loadAccess()).getOrElse(
        () => null,
      )!;
      final wait = Completer<Either<String, MerchantAccess?>>();
      final merchants = AccessRepo()..action = () => wait.future;
      final repo = MerchantQrRepository(
        delegate: delegate,
        merchants: merchants,
        access: access,
      );
      final call = repo.claimVerification(
        shopId: access.shop!.id,
        requestId: 'request',
        manualCode: '123456',
      );
      delegate.bounce();
      await pumpEventQueue();
      wait.complete(Right(access));
      expect((await call).isLeft(), true);
      expect(delegate.claims, 0);
      await delegate.keys.close();
    },
  );
  test(
    'reopening customer QR after replacement uses a fresh lifetime',
    () async {
      final repo = SessionQr();
      QrSessionCubit open() => QrSessionCubit(
        createQrSessionUsecase: CreateQrSessionUsecase(repo),
        getQrSessionStatusUsecase: GetQrSessionStatusUsecase(repo),
      );
      final old = open();
      await old.createQrSession('cart');
      repo.bounce();
      await pumpEventQueue();
      expect(old.state, isA<QrSessionFailure>());
      final fresh = open();
      await fresh.createQrSession('cart');
      expect(fresh.state, isA<QrSessionCreated>());
      await old.close();
      await fresh.close();
      await repo.keys.close();
    },
  );
  for (final action in ['bounce', 'logout', 'error', 'closed']) {
    test('merchant QR retires loaded claim on $action', () async {
      final repo = SessionQr(), c = claimCubit(repo);
      await c.loadVerification('token');
      expect(c.state, isA<QrVerificationLoaded>());
      if (action == 'bounce') {
        repo.bounce();
      }
      if (action == 'logout') {
        repo.currentSessionKey = null;
        repo.keys.add(null);
      }
      if (action == 'error') {
        repo.keys.addError(StateError('session source'));
      }
      if (action == 'closed') {
        await repo.keys.close();
      }
      await pumpEventQueue();
      expect(c.state, isA<QrVerificationFailure>());
      await c.confirmVerification();
      await c.recoverClaim();
      await c.loadVerification('another');
      c.reset();
      expect(repo.completions, 0);
      expect(repo.claims, 1);
      expect(c.state, isA<QrVerificationFailure>());
      await c.close();
      if (action != 'closed') await repo.keys.close();
    });
  }
  test(
    'late QR completion cannot reconcile through a replacement session',
    () async {
      final repo = SessionQr(), c = claimCubit(repo);
      final wait = Completer<Either<String, QrVerificationEntity>>();
      repo.completeAction = () => wait.future;
      await c.loadVerification('token');
      final operation = c.confirmVerification();
      repo.bounce();
      await pumpEventQueue();
      wait.complete(const Left('lost acknowledgement'));
      await operation;
      expect(repo.reconciliations, 0);
      expect(c.state, isA<QrVerificationFailure>());
      await c.close();
      await repo.keys.close();
    },
  );
  test(
    'customer QR removes old code and stops polling after session bounce',
    () async {
      final repo = SessionQr();
      final c = QrSessionCubit(
        createQrSessionUsecase: CreateQrSessionUsecase(repo),
        getQrSessionStatusUsecase: GetQrSessionStatusUsecase(repo),
      );
      await c.createQrSession('cart');
      expect(c.state, isA<QrSessionCreated>());
      repo.bounce();
      await pumpEventQueue();
      expect(c.state, isA<QrSessionFailure>());
      await c.createQrSession('cart');
      await c.checkSessionStatus();
      expect(c.state, isA<QrSessionFailure>());
      await c.close();
      await repo.keys.close();
    },
  );
  test('ordinary renewal preserves a loaded claim', () async {
    final repo = SessionQr(), c = claimCubit(repo);
    await c.loadVerification('token');
    repo.keys.add(repo.currentSessionKey);
    await pumpEventQueue();
    expect(c.state, isA<QrVerificationLoaded>());
    await c.confirmVerification();
    expect(c.state, isA<QrVerificationSuccess>());
    await c.close();
    await repo.keys.close();
  });
  for (final phase in ['disk', 'success', 'rejection']) {
    test(
      'session bounce during return $phase preserves original durable intent',
      () async {
        final repo = SessionReturn(), store = ReturnStore();
        final c = MerchantReturnController(
          repository: repo,
          store: store,
          purchase: purchase(),
        );
        await c.restore();
        final wait =
            Completer<Either<PurchaseReturnFailure, PurchaseEvidence>>();
        if (phase == 'disk') {
          store.saving = Completer<void>();
        }
        repo.write = () => wait.future;
        final call = c.submit(quantities: {'item': 1}, reason: 'İade');
        await pumpEventQueue();
        repo.bounce();
        await pumpEventQueue();
        if (phase == 'disk') {
          store.saving!.complete();
          wait.complete(Right(purchase(returned: 1)));
        } else if (phase == 'success') {
          wait.complete(Right(purchase(returned: 1)));
        } else {
          wait.complete(
            const Left(
              PurchaseReturnFailure('rejected', definitelyRejected: true),
            ),
          );
        }
        await call;
        expect(c.current, false);
        expect(store.clears, 0);
        expect(store.value, isNotNull);
        expect(c.confirmed, false);
        if (phase == 'disk') expect(repo.sent, isEmpty);
        c.dispose();
        await repo.keys.close();
      },
    );
  }
}
