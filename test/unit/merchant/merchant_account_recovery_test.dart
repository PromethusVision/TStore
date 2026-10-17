import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/features/merchant/domain/merchant_account_recovery.dart';

class RecoveryBackendFake implements MerchantRecoveryBackend {
  @override
  String? sessionKey;
  final changes = StreamController<void>.broadcast(sync: true);
  @override
  Stream<void> get sessionChanges => changes.stream;
  int sends = 0, verifies = 0, updates = 0, clears = 0;
  bool pending = false,
      failClear = false,
      failMarker = false,
      failUpdate = false,
      recovery = true;
  Completer<void>? sendWait, verifyWait, updateWait, markerWait;
  bool failVerify = false;
  String? failureSession;
  String? verifiedSession = 'merchant-a:session-a';
  @override
  Future<void> sendReset(String email) async {
    sends++;
    await sendWait?.future;
  }

  @override
  Future<MerchantRecoveryGrant> verifyRecovery(Uri uri) async {
    verifies++;
    await verifyWait?.future;
    if (failVerify) {
      if (failureSession != null) sessionKey = failureSession;
      throw StateError('unconfirmed exchange');
    }
    sessionKey = verifiedSession;
    changes.add(null);
    return MerchantRecoveryGrant(verifiedSession, recovery: recovery);
  }

  @override
  Future<void> updatePassword(String password) async {
    updates++;
    await updateWait?.future;
    if (failUpdate) throw StateError('secret-like-provider-error');
  }

  @override
  Future<void> clearLocalSession() async {
    clears++;
    if (failClear) throw StateError('cleanup failed');
    sessionKey = null;
    changes.add(null);
  }

  @override
  Future<void> setPending(bool value) async {
    await markerWait?.future;
    if (failMarker) throw StateError('marker failed');
    pending = value;
  }
}

final pilotCallback = Uri.parse(
  'com.esnaftavar.app.merchant.pilot://login-callback/?code=synthetic&auth_action=password_recovery',
);
void main() {
  late RecoveryBackendFake backend;
  late MerchantAccountRecovery recovery;
  setUp(() {
    backend = RecoveryBackendFake();
    recovery = MerchantAccountRecovery(
      backend: backend,
      contract: AuthCallbackContract.merchantPilot(),
    );
  });
  tearDown(() async {
    recovery.dispose();
    await backend.changes.close();
  });
  test(
    'reset request is validated and serialized, with non-enumerating success',
    () async {
      recovery.request();
      await recovery.send('invalid');
      expect(backend.sends, 0);
      backend.sendWait = Completer();
      final first = recovery.send('a@shop.invalid');
      await recovery.send('b@shop.invalid');
      await recovery.dismiss();
      expect(backend.sends, 1);
      expect(recovery.busy, isTrue);
      backend.sendWait!.complete();
      await first;
      expect(recovery.stage, MerchantRecoveryStage.sent);
      expect(recovery.message, contains('uygunsa'));
    },
  );
  test(
    'callback blocks workspace before verification; duplicate is coalesced',
    () async {
      backend.verifyWait = Completer();
      final first = recovery.receive(pilotCallback);
      expect(recovery.blocksWorkspace, isTrue);
      expect(recovery.busy, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(backend.pending, isTrue);
      await recovery.receive(pilotCallback);
      expect(backend.verifies, 1);
      backend.verifyWait!.complete();
      await first;
      expect(recovery.stage, MerchantRecoveryStage.password);
      await recovery.receive(pilotCallback);
      expect(backend.verifies, 1);
    },
  );
  for (final suffix in [
    '?code=x&code=y',
    '?code=x&token_hash=y&type=recovery',
    '?code=',
    '?code=x&auth_action=other',
    '?token_hash=x&type=recovery',
    '?code=x&access_token=forged',
    '?error_description=secret',
  ]) {
    test(
      'ambiguous/invalid pilot callback $suffix sends no exchange',
      () async {
        await recovery.receive(
          Uri.parse(
            'com.esnaftavar.app.merchant.pilot://login-callback/$suffix',
          ),
        );
        expect(backend.verifies, 0);
        expect(recovery.stage, MerchantRecoveryStage.invalid);
      },
    );
  }
  for (final uri in [
    'com.esnaftavar.app://login-callback/?code=x',
    'com.esnaftavar.app.merchant.pilot://other/?code=x',
    'com.esnaftavar.app.merchant.pilot://login-callback/other?code=x',
    'com.esnaftavar.app.merchant.pilot://login-callback/?code=x#fragment',
  ]) {
    test('foreign callback is ignored: $uri', () async {
      await recovery.receive(Uri.parse(uri));
      expect(backend.verifies, 0);
      expect(recovery.blocksWorkspace, isFalse);
    });
  }
  test(
    'query marker alone cannot turn a signup exchange into recovery',
    () async {
      backend.recovery = false;
      await recovery.receive(pilotCallback);
      expect(recovery.stage, MerchantRecoveryStage.invalid);
      await recovery.update('new-password');
      expect(backend.updates, 0);
      await recovery.dismiss();
      expect(backend.clears, 1);
      expect(backend.pending, isFalse);
    },
  );
  test(
    'direct token hash recovery requires explicit type and successful exchange',
    () async {
      await recovery.receive(
        Uri.parse(
          'com.esnaftavar.app.merchant.pilot://login-callback/?token_hash=synthetic&type=recovery&auth_action=password_recovery',
        ),
      );
      expect(recovery.stage, MerchantRecoveryStage.password);
    },
  );
  test(
    'password update is not repeated, and success requires cleanup',
    () async {
      await recovery.receive(pilotCallback);
      backend.updateWait = Completer();
      final first = recovery.update('new-password');
      await recovery.update('other-password');
      await recovery.dismiss();
      expect(backend.updates, 1);
      expect(backend.clears, 0);
      backend.updateWait!.complete();
      await first;
      expect(backend.clears, 1);
      expect(backend.pending, isFalse);
      expect(recovery.stage, MerchantRecoveryStage.complete);
      expect(recovery.blocksWorkspace, isTrue);
      await recovery.dismiss();
      expect(recovery.blocksWorkspace, isFalse);
    },
  );
  test(
    'same-account replacement before submission rejects the stale form',
    () async {
      await recovery.receive(pilotCallback);
      backend.sessionKey = 'merchant-a:session-b';
      await recovery.update('new-password');
      expect(backend.updates, 0);
      expect(recovery.stage, MerchantRecoveryStage.invalid);
      await recovery.dismiss();
      expect(backend.clears, 0);
    },
  );
  test(
    'account change during password write does not clear the newer session',
    () async {
      await recovery.receive(pilotCallback);
      backend.updateWait = Completer();
      final operation = recovery.update('new-password');
      backend.sessionKey = 'merchant-b:session-b';
      backend.updateWait!.complete();
      await operation;
      expect(recovery.stage, MerchantRecoveryStage.invalid);
      expect(backend.clears, 0);
      await recovery.dismiss();
      expect(backend.sessionKey, 'merchant-b:session-b');
    },
  );
  test(
    'token refresh preserving session key preserves recovery form',
    () async {
      await recovery.receive(pilotCallback);
      backend.changes.add(null);
      expect(recovery.stage, MerchantRecoveryStage.password);
    },
  );
  test(
    'lost update acknowledgement never claims success or auto-repeats',
    () async {
      await recovery.receive(pilotCallback);
      backend.failUpdate = true;
      await recovery.update('new-password');
      expect(recovery.stage, MerchantRecoveryStage.invalid);
      expect(recovery.message, isNot(contains('secret-like')));
      await recovery.update('new-password');
      expect(backend.updates, 1);
    },
  );
  test(
    'cleanup failure blocks workspace and explicit retry settles it',
    () async {
      await recovery.receive(pilotCallback);
      backend.failClear = true;
      await recovery.dismiss();
      expect(recovery.stage, MerchantRecoveryStage.cleanupFailed);
      expect(backend.pending, isTrue);
      backend.failClear = false;
      await recovery.dismiss();
      expect(backend.pending, isFalse);
      expect(recovery.blocksWorkspace, isFalse);
    },
  );
  test('marker failure prevents verification entirely', () async {
    backend.failMarker = true;
    await recovery.receive(pilotCallback);
    expect(backend.verifies, 0);
    expect(recovery.stage, MerchantRecoveryStage.invalid);
  });
  test(
    'restarted recovery cannot open private workspace before cleanup',
    () async {
      backend.pending = true;
      backend.sessionKey = 'merchant-a:old-recovery';
      recovery.restorePending();
      expect(recovery.blocksWorkspace, isTrue);
      await recovery.update('new-password');
      expect(backend.updates, 0);
      await recovery.dismiss();
      expect(backend.sessionKey, isNull);
      expect(backend.pending, isFalse);
    },
  );
  test('session monitor error invalidates the recovery grant', () async {
    await recovery.receive(pilotCallback);
    backend.changes.addError(StateError('failed'));
    expect(recovery.stage, MerchantRecoveryStage.invalid);
    await recovery.update('new-password');
    expect(backend.updates, 0);
  });
  test('dismiss is serialized while durable marker clears', () async {
    recovery.request();
    backend.markerWait = Completer();
    final first = recovery.dismiss();
    expect(recovery.busy, isTrue);
    recovery.request();
    await recovery.receive(pilotCallback);
    expect(backend.verifies, 0);
    backend.markerWait!.complete();
    await first;
    expect(recovery.stage, MerchantRecoveryStage.idle);
  });
  test('failed exchange never adopts or logs out a newer session', () async {
    backend.sessionKey = 'merchant-a:initial';
    backend.failVerify = true;
    backend.failureSession = 'merchant-b:new';
    await recovery.receive(pilotCallback);
    expect(recovery.stage, MerchantRecoveryStage.invalid);
    expect(recovery.message, contains('kapatıp yeniden açın'));
    await recovery.dismiss();
    expect(backend.clears, 0);
    expect(backend.sessionKey, 'merchant-b:new');
    expect(backend.pending, isTrue);
    expect(recovery.blocksWorkspace, isTrue);
  });
  test(
    'failed exchange without a session change leaves normal login untouched',
    () async {
      backend.sessionKey = 'merchant-a:normal';
      backend.failVerify = true;
      await recovery.receive(pilotCallback);
      await recovery.dismiss();
      expect(backend.clears, 0);
      expect(backend.sessionKey, 'merchant-a:normal');
      expect(recovery.blocksWorkspace, isFalse);
      expect(backend.pending, isFalse);
    },
  );
  test(
    'failed newer link preserves the previous verified grant for cleanup',
    () async {
      await recovery.receive(pilotCallback);
      backend.failVerify = true;
      await recovery.receive(
        pilotCallback.replace(queryParameters: {'code': 'second'}),
      );
      await recovery.dismiss();
      expect(backend.clears, 1);
      expect(backend.sessionKey, isNull);
      expect(backend.pending, isFalse);
    },
  );
}
