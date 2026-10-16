import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';

class _Credentials extends Mock implements MerchantCredentials {}

class _Repository extends Mock implements MerchantRepository {}

void main() {
  late MerchantPreview host;
  late _Credentials credentials;
  MerchantSessionCubit? active;
  setUp(() {
    host = MerchantPreview();
    credentials = _Credentials();
  });
  tearDown(() async {
    await active?.close();
    active = null;
    await host.dispose();
  });
  MerchantSessionCubit make({
    MerchantRepository? repository,
    Future<void> Function()? revoke,
    Duration timeout = const Duration(seconds: 15),
  }) => active = MerchantSessionCubit(
    repository: repository ?? host.repository,
    credentials: credentials,
    sessionChanges: host.changes.stream,
    currentUserId: () => host.currentId,
    beforeSignOut: revoke,
    accessTimeout: timeout,
  );
  MerchantAccess access() =>
      MerchantAccess(user: host.user, shop: host.repository.shop);

  test(
    'quiet refresh retains scope, explicit logout/login creates fresh scope',
    () async {
      final cubit = make();
      await cubit.reload();
      final scope = cubit.state.scopeRevision;
      host.changes.add(host.currentId);
      await pumpEventQueue();
      expect(cubit.state.scopeRevision, scope);
      host.currentId = null;
      host.changes.add(null);
      host.currentId = host.user.id;
      host.changes.add(host.currentId);
      await pumpEventQueue();
      expect(cubit.state.status, MerchantSessionStatus.ready);
      expect(cubit.state.scopeRevision, greaterThan(scope));
    },
  );

  test(
    'quiet is ignored for a different owner and hides old data immediately',
    () async {
      final repo = _Repository();
      when(repo.loadAccess).thenAnswer((_) async => Right(access()));
      final cubit = make(repository: repo);
      await cubit.reload();
      final pending = Completer<Either<String, MerchantAccess?>>();
      when(repo.loadAccess).thenAnswer((_) => pending.future);
      host.currentId = 'new-owner';
      final read = cubit.reload(quiet: true);
      expect(cubit.state.status, MerchantSessionStatus.checking);
      expect(cubit.state.access, isNull);
      pending.complete(Right(access()));
      await read;
      expect(cubit.state.status, MerchantSessionStatus.failure);
    },
  );

  for (final throws in [false, true]) {
    test(
      'quiet read detects identity drift without a stream event, throws=$throws',
      () async {
        final repo = _Repository();
        when(repo.loadAccess).thenAnswer((_) async => Right(access()));
        final cubit = make(repository: repo);
        await cubit.reload();
        final pending = Completer<Either<String, MerchantAccess?>>();
        when(repo.loadAccess).thenAnswer((_) => pending.future);
        final read = cubit.reload(quiet: true);
        host.currentId = 'changed-without-callback';
        if (throws) {
          pending.completeError(StateError('synthetic failure'));
        } else {
          pending.complete(Right(access()));
        }
        await read;
        expect(cubit.state.status, MerchantSessionStatus.failure);
        expect(cubit.state.access, isNull);
        expect(cubit.state.message, merchantSessionChanged);
      },
    );
  }

  test('newer access failure wins against a late successful read', () async {
    final repo = _Repository();
    final pending = Completer<Either<String, MerchantAccess?>>();
    when(repo.loadAccess).thenAnswer((_) => pending.future);
    final cubit = make(repository: repo);
    final old = cubit.reload();
    when(repo.loadAccess).thenAnswer((_) async => const Left('Erişim yok'));
    await cubit.reload();
    pending.complete(Right(access()));
    await old;
    expect(cubit.state.status, MerchantSessionStatus.failure);
    expect(cubit.state.message, 'Erişim yok');
    expect(cubit.state.access, isNull);
  });

  test(
    'access timeout fails closed; late success cannot replace explicit retry',
    () async {
      final repo = _Repository();
      final pending = Completer<Either<String, MerchantAccess?>>();
      when(repo.loadAccess).thenAnswer((_) => pending.future);
      final cubit = make(
        repository: repo,
        timeout: const Duration(milliseconds: 20),
      );
      await cubit.reload();
      expect(cubit.state.status, MerchantSessionStatus.failure);
      when(
        repo.loadAccess,
      ).thenAnswer((_) async => const Left('Hesap durduruldu'));
      await cubit.reload();
      pending.complete(Right(access()));
      await pumpEventQueue();
      expect(cubit.state.message, 'Hesap durduruldu');
      expect(cubit.state.access, isNull);
    },
  );

  test(
    'session error cancels an outstanding read and allows a fresh explicit retry',
    () async {
      final repo = _Repository();
      final pending = Completer<Either<String, MerchantAccess?>>();
      when(repo.loadAccess).thenAnswer((_) => pending.future);
      final cubit = make(repository: repo);
      final read = cubit.reload();
      host.changes.addError(StateError('synthetic transport failure'));
      pending.complete(Right(access()));
      await read;
      expect(cubit.state.status, MerchantSessionStatus.failure);
      when(repo.loadAccess).thenAnswer((_) async => Right(access()));
      await cubit.reload();
      expect(cubit.state.status, MerchantSessionStatus.ready);
    },
  );

  test(
    'closed session monitor cannot regain access by retry or sign-in',
    () async {
      final cubit = make();
      await cubit.reload();
      await host.changes.close();
      await cubit.reload();
      await cubit.signIn('e', 'p');
      expect(cubit.state.status, MerchantSessionStatus.failure);
      expect(cubit.state.canRetry, false);
      verifyNever(() => credentials.signIn(any(), any()));
    },
  );

  test(
    'late login error reloads authenticated identity instead of declaring logout',
    () async {
      host.currentId = null;
      final pending = Completer<Either<String, void>>();
      when(
        () => credentials.signIn('e', 'p'),
      ).thenAnswer((_) => pending.future);
      final cubit = make();
      await cubit.reload();
      final login = cubit.signIn('e', 'p');
      host.currentId = host.user.id;
      host.changes.add(host.currentId);
      await pumpEventQueue();
      expect(cubit.state.access, isNull);
      pending.complete(const Left('Profile request failed'));
      await login;
      expect(cubit.state.status, MerchantSessionStatus.ready);
      expect(cubit.state.busy, false);
    },
  );

  test(
    'login interrupted by session error cannot reopen without a fresh check',
    () async {
      host.currentId = null;
      final pending = Completer<Either<String, void>>();
      when(
        () => credentials.signIn('e', 'p'),
      ).thenAnswer((_) => pending.future);
      final cubit = make();
      final login = cubit.signIn('e', 'p');
      host.currentId = host.user.id;
      host.changes.addError(StateError('synthetic'));
      expect(cubit.state.busy, true);
      await cubit.reload();
      pending.complete(const Right(null));
      await login;
      expect(cubit.state.status, MerchantSessionStatus.failure);
      expect(cubit.state.busy, false);
      await cubit.reload();
      expect(cubit.state.status, MerchantSessionStatus.ready);
    },
  );

  for (final change in [
    'account',
    'same-account-return',
    'stream-error',
    'dispose',
  ]) {
    test('revocation continuation is fenced after $change', () async {
      final pending = Completer<void>();
      final cubit = make(revoke: () => pending.future);
      await cubit.reload();
      final exit = cubit.signOut();
      if (change == 'account') {
        host.currentId = 'other-owner';
        host.changes.add(host.currentId);
      } else if (change == 'same-account-return') {
        host.currentId = null;
        host.changes.add(null);
        host.currentId = host.user.id;
        host.changes.add(host.currentId);
      } else if (change == 'stream-error') {
        host.changes.addError(StateError('synthetic'));
      } else {
        await cubit.close();
        active = null;
      }
      pending.complete();
      await exit;
      verifyNever(credentials.signOut);
      if (change == 'same-account-return') {
        expect(cubit.state.status, MerchantSessionStatus.ready);
      }
      if (change == 'stream-error') {
        expect(cubit.state.status, MerchantSessionStatus.failure);
      }
    });
  }

  test(
    'slow credential logout suppresses refresh and duplicate auth actions',
    () async {
      final pending = Completer<Either<String, void>>();
      when(credentials.signOut).thenAnswer((_) => pending.future);
      final cubit = make();
      await cubit.reload();
      final exit = cubit.signOut();
      await pumpEventQueue();
      host.changes.add(host.currentId);
      await cubit.reload(quiet: true);
      await cubit.signOut();
      await cubit.signIn('e', 'p');
      expect(cubit.state.status, MerchantSessionStatus.checking);
      verify(credentials.signOut).called(1);
      verifyNever(() => credentials.signIn(any(), any()));
      pending.complete(const Left('Çıkış tamamlanmadı'));
      await exit;
      expect(cubit.state.status, MerchantSessionStatus.failure);
      expect(cubit.state.busy, false);
    },
  );

  test(
    'late old logout failure cannot replace the new authenticated owner',
    () async {
      final pending = Completer<Either<String, void>>();
      when(credentials.signOut).thenAnswer((_) => pending.future);
      final cubit = make();
      await cubit.reload();
      final exit = cubit.signOut();
      await pumpEventQueue();
      host.user = host.user.copyWith(id: 'new-owner');
      host.currentId = host.user.id;
      host.repository.shop = host.repository.shop!.copyWith(
        ownerUserId: host.user.id,
      );
      host.changes.add(host.currentId);
      pending.complete(const Left('Old logout failed'));
      await exit;
      expect(cubit.state.status, MerchantSessionStatus.ready);
      expect(cubit.state.access?.user.id, 'new-owner');
      expect(cubit.state.message, isNull);
    },
  );

  test(
    'token refresh cannot reopen workspace during device revocation',
    () async {
      final preview = MerchantPreview();
      final revocation = Completer<void>();
      final cubit = MerchantSessionCubit(
        repository: preview.repository,
        credentials: preview.services.credentials,
        sessionChanges: preview.changes.stream,
        currentUserId: () => preview.currentId,
        beforeSignOut: () => revocation.future,
      );
      addTearDown(() async {
        await cubit.close();
        await preview.dispose();
      });
      await cubit.reload();
      final exit = cubit.signOut();
      preview.changes.add(preview.currentId);
      await pumpEventQueue();
      final duringExit = cubit.state.status;
      revocation.complete();
      await exit;
      expect(duringExit, MerchantSessionStatus.checking);
      expect(cubit.state.status, MerchantSessionStatus.signedOut);
    },
  );

  test(
    'an old exit cannot sign out an account that arrived during revocation',
    () async {
      final preview = MerchantPreview();
      final credentials = _Credentials();
      when(credentials.signOut).thenAnswer((_) async => const Right(null));
      final revocation = Completer<void>();
      final cubit = MerchantSessionCubit(
        repository: preview.repository,
        credentials: credentials,
        sessionChanges: preview.changes.stream,
        currentUserId: () => preview.currentId,
        beforeSignOut: () => revocation.future,
      );
      addTearDown(() async {
        await cubit.close();
        await preview.dispose();
      });
      await cubit.reload();
      final exit = cubit.signOut();
      preview.currentId = 'different-owner';
      preview.changes.add(preview.currentId);
      revocation.complete();
      await exit;
      verifyNever(credentials.signOut);
      expect(cubit.state.access, isNull);
    },
  );

  test('session monitoring ending closes private access', () async {
    final preview = MerchantPreview();
    final cubit = MerchantSessionCubit(
      repository: preview.repository,
      credentials: preview.services.credentials,
      sessionChanges: preview.changes.stream,
      currentUserId: () => preview.currentId,
    );
    await cubit.reload();
    await preview.changes.close();
    await pumpEventQueue();
    expect(cubit.state.status, MerchantSessionStatus.failure);
    expect(cubit.state.access, isNull);
    await cubit.close();
    await preview.dispose();
  });
}
