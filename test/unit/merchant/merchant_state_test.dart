import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/repositories/qr_session_repository.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';
import 'package:t_store/features/merchant/data/merchant_qr_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_credentials.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_catalog_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

class MockMerchants extends Mock implements MerchantRepository {}

class MockCredentials extends Mock implements MerchantCredentials {}

class MockQr extends Mock implements QrSessionRepository {}

void main() {
  for (final role in ['customer', 'admin']) {
    test('$role is denied without a merchant role', () async {
      final preview = MerchantPreview(role: role);
      final cubit = session(preview);
      await cubit.reload();
      expect(cubit.state.status, MerchantSessionStatus.denied);
      await cubit.close();
      await preview.dispose();
    });
  }
  test('approved merchant without shop enters onboarding', () async {
    final preview = MerchantPreview(hasShop: false);
    final cubit = session(preview);
    await cubit.reload();
    expect(cubit.state.status, MerchantSessionStatus.onboarding);
    await cubit.close();
    await preview.dispose();
  });
  test(
    'late authority response cannot restore a signed-out workspace',
    () async {
      final preview = MerchantPreview();
      final repository = MockMerchants();
      final pending = Completer<Either<String, MerchantAccess?>>();
      when(repository.loadAccess).thenAnswer((_) => pending.future);
      final cubit = MerchantSessionCubit(
        repository: repository,
        credentials: preview.services.credentials,
        sessionChanges: preview.changes.stream,
        currentUserId: () => preview.currentId,
      );
      final reload = cubit.reload();
      preview.currentId = null;
      preview.changes.add(null);
      pending.complete(
        Right(
          MerchantAccess(user: preview.user, shop: preview.repository.shop),
        ),
      );
      await reload;
      expect(cubit.state.status, MerchantSessionStatus.signedOut);
      await cubit.close();
      await preview.dispose();
    },
  );
  test('permission refresh does not destroy ready navigation', () async {
    final preview = MerchantPreview();
    final cubit = session(preview);
    await cubit.reload();
    final states = <MerchantSessionStatus>[];
    final sub = cubit.stream.listen((s) => states.add(s.status));
    await cubit.reload(quiet: true);
    await pumpEventQueue();
    expect(states, [MerchantSessionStatus.ready]);
    preview.user = preview.user.copyWith(role: UserEntity.customerRole);
    await cubit.reload(quiet: true);
    expect(cubit.state.status, MerchantSessionStatus.denied);
    await sub.cancel();
    await cubit.close();
    await preview.dispose();
  });
  test('duplicate login is suppressed during slow auth', () async {
    final preview = MerchantPreview(signedIn: false);
    final credentials = MockCredentials();
    final pending = Completer<Either<String, void>>();
    when(() => credentials.signIn('e', 'p')).thenAnswer((_) => pending.future);
    final cubit = MerchantSessionCubit(
      repository: preview.repository,
      credentials: credentials,
      sessionChanges: preview.changes.stream,
      currentUserId: () => preview.currentId,
    );
    final first = cubit.signIn('e', 'p');
    await cubit.signIn('e', 'p');
    verify(() => credentials.signIn('e', 'p')).called(1);
    pending.complete(const Left('Giriş yapılamadı'));
    await first;
    expect(cubit.state.busy, false);
    await cubit.close();
    await preview.dispose();
  });
  test(
    'failed device revocation blocks logout rather than losing token ownership',
    () async {
      final preview = MerchantPreview();
      final credentials = MockCredentials();
      final cubit = MerchantSessionCubit(
        repository: preview.repository,
        credentials: credentials,
        sessionChanges: preview.changes.stream,
        currentUserId: () => preview.currentId,
        beforeSignOut: () async => throw StateError('failed'),
      );
      await cubit.signOut();
      verifyNever(credentials.signOut);
      expect(cubit.state.status, MerchantSessionStatus.failure);
      await cubit.close();
      await preview.dispose();
    },
  );
  test('a newer catalog search wins against delayed previous page', () async {
    final preview = MerchantPreview();
    final access = MerchantAccess(
      user: preview.user,
      shop: preview.repository.shop,
    );
    final repository = MockMerchants();
    final pending = Completer<Either<String, List<ShopProductEntity>>>();
    when(
      () => repository.listings(access, page: 0, query: ''),
    ).thenAnswer((_) => pending.future);
    when(
      () => repository.listings(access, page: 0, query: 'yeni'),
    ).thenAnswer((_) async => const Right([]));
    final cubit = MerchantCatalogCubit(repository, access);
    final first = cubit.load();
    await cubit.load(refresh: true, query: 'yeni');
    pending.complete(Right(preview.repository.items));
    await first;
    expect(cubit.state.query, 'yeni');
    expect(cubit.state.items, isEmpty);
    await cubit.close();
    await preview.dispose();
  });
  test('QR rejects other-shop response and never confirms it', () async {
    final preview = MerchantPreview();
    final access = MerchantAccess(
      user: preview.user,
      shop: preview.repository.shop,
    );
    final delegate = MockQr();
    final qr = MerchantQrRepository(
      delegate: delegate,
      merchants: preview.repository,
      access: access,
    );
    when(() => delegate.getQrVerification(sessionToken: 'token')).thenAnswer(
      (_) async => Right(
        QrVerificationEntity(
          sessionId: 'session',
          sessionToken: 'token',
          status: 'active',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          shopId: 'other-shop',
          shopName: 'Other',
          itemCount: 0,
          totalAmount: 0,
          items: const [],
        ),
      ),
    );
    final cubit = QrVerificationCubit(
      getQrVerificationUsecase: GetQrVerificationUsecase(qr),
      confirmQrVerificationUsecase: ConfirmQrVerificationUsecase(qr),
    );
    await cubit.loadVerification('token');
    await cubit.confirmVerification();
    expect(cubit.state, isA<QrVerificationFailure>());
    verifyNever(() => delegate.confirmQrVerification(sessionToken: 'token'));
    await cubit.close();
    await preview.dispose();
  });
  test(
    'QR confirmation uses shared state machine and cannot be repeated',
    () async {
      final preview = MerchantPreview();
      final access = MerchantAccess(
        user: preview.user,
        shop: preview.repository.shop,
      );
      final qr = MerchantQrRepository(
        delegate: preview.services.qr,
        merchants: preview.repository,
        access: access,
      );
      final cubit = QrVerificationCubit(
        getQrVerificationUsecase: GetQrVerificationUsecase(qr),
        confirmQrVerificationUsecase: ConfirmQrVerificationUsecase(qr),
      );
      await cubit.loadVerification('merchant-v1-preview');
      expect(cubit.state, isA<QrVerificationLoaded>());
      await cubit.confirmVerification();
      await cubit.confirmVerification();
      expect(cubit.state, isA<QrVerificationSuccess>());
      await cubit.close();
      await preview.dispose();
    },
  );
}

MerchantSessionCubit session(MerchantPreview preview) => MerchantSessionCubit(
  repository: preview.repository,
  credentials: preview.services.credentials,
  sessionChanges: preview.changes.stream,
  currentUserId: () => preview.currentId,
);
