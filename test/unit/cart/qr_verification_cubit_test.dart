import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';
import 'package:t_store/features/cart/domain/usecases/confirm_qr_verification_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_verification_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_verification_state.dart';

class MockGetQrVerificationUsecase extends Mock
    implements GetQrVerificationUsecase {}

class MockConfirmQrVerificationUsecase extends Mock
    implements ConfirmQrVerificationUsecase {}

class FakeGetQrVerificationParams extends Fake
    implements GetQrVerificationParams {}

class FakeConfirmQrVerificationParams extends Fake
    implements ConfirmQrVerificationParams {}

void main() {
  late MockGetQrVerificationUsecase mockGetQrVerificationUsecase;
  late MockConfirmQrVerificationUsecase mockConfirmQrVerificationUsecase;
  late QrVerificationCubit qrVerificationCubit;

  final expiresAt = DateTime.utc(2099, 1, 1);
  final verification = QrVerificationEntity(
    sessionId: 'session-1',
    sessionToken: 'token-1',
    status: 'active',
    expiresAt: expiresAt,
    shopId: 'shop-1',
    shopName: 'Test Shop',
    itemCount: 3,
    totalAmount: 124.50,
    items: const [
      QrVerificationItemEntity(
        id: 'item-1',
        shopProductId: 'shop-product-1',
        productName: 'Test Product',
        quantity: 3,
        unitPrice: 41.50,
        lineTotal: 124.50,
      ),
    ],
  );
  final confirmedVerification = QrVerificationEntity(
    sessionId: 'session-1',
    sessionToken: 'token-1',
    status: 'used',
    expiresAt: expiresAt,
    usedAt: DateTime.utc(2098, 12, 31),
    shopId: 'shop-1',
    shopName: 'Test Shop',
    itemCount: 3,
    totalAmount: 124.50,
    items: verification.items,
  );

  setUpAll(() {
    registerFallbackValue(FakeGetQrVerificationParams());
    registerFallbackValue(FakeConfirmQrVerificationParams());
  });

  setUp(() {
    mockGetQrVerificationUsecase = MockGetQrVerificationUsecase();
    mockConfirmQrVerificationUsecase = MockConfirmQrVerificationUsecase();
    qrVerificationCubit = QrVerificationCubit(
      getQrVerificationUsecase: mockGetQrVerificationUsecase,
      confirmQrVerificationUsecase: mockConfirmQrVerificationUsecase,
    );
  });

  tearDown(() async {
    if (!qrVerificationCubit.isClosed) {
      await qrVerificationCubit.close();
    }
  });

  group('QrVerificationCubit', () {
    test('initial state is QrVerificationInitial', () {
      expect(qrVerificationCubit.state, QrVerificationInitial());
    });

    blocTest<QrVerificationCubit, QrVerificationState>(
      'loads a valid QR verification preview',
      build: () {
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(verification));
        return qrVerificationCubit;
      },
      act: (cubit) => cubit.loadVerification('  token-1  '),
      expect: () => [
        QrVerificationLoading(),
        QrVerificationLoaded(verification),
      ],
      verify: (_) {
        final params =
            verify(
                  () => mockGetQrVerificationUsecase(captureAny()),
                ).captured.single
                as GetQrVerificationParams;
        expect(params.sessionToken, 'token-1');
      },
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'emits failure when the QR verification preview cannot be loaded',
      build: () {
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => const Left('QR doğrulanamadı'));
        return qrVerificationCubit;
      },
      act: (cubit) => cubit.loadVerification('token-1'),
      expect: () => [
        QrVerificationLoading(),
        const QrVerificationFailure('QR doğrulanamadı'),
      ],
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'rejects an expired QR before showing the confirmation preview',
      build: () {
        final expiredVerification = QrVerificationEntity(
          sessionId: verification.sessionId,
          sessionToken: verification.sessionToken,
          status: 'expired',
          expiresAt: verification.expiresAt,
          shopId: verification.shopId,
          shopName: verification.shopName,
          itemCount: verification.itemCount,
          totalAmount: verification.totalAmount,
          items: verification.items,
        );
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(expiredVerification));
        return qrVerificationCubit;
      },
      act: (cubit) => cubit.loadVerification('token-1'),
      expect: () => [
        QrVerificationLoading(),
        isA<QrVerificationFailure>().having(
          (state) => state.message,
          'message',
          contains('süresi dolmuş'),
        ),
      ],
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'rejects an empty QR token without calling the usecase',
      build: () => qrVerificationCubit,
      act: (cubit) => cubit.loadVerification('   '),
      expect: () => [
        isA<QrVerificationFailure>().having(
          (state) => state.message,
          'message',
          isNotEmpty,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockGetQrVerificationUsecase(any()));
      },
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'confirms a loaded QR verification',
      build: () {
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(verification));
        when(
          () => mockConfirmQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(confirmedVerification));
        return qrVerificationCubit;
      },
      act: (cubit) async {
        await cubit.loadVerification('token-1');
        await cubit.confirmVerification();
      },
      expect: () => [
        QrVerificationLoading(),
        QrVerificationLoaded(verification),
        QrVerificationConfirming(verification),
        QrVerificationSuccess(confirmedVerification),
      ],
      verify: (_) {
        final params =
            verify(
                  () => mockConfirmQrVerificationUsecase(captureAny()),
                ).captured.single
                as ConfirmQrVerificationParams;
        expect(params.sessionToken, 'token-1');
      },
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'emits failure when confirming the QR verification fails',
      build: () {
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(verification));
        when(
          () => mockConfirmQrVerificationUsecase(any()),
        ).thenAnswer((_) async => const Left('Onay başarısız'));
        return qrVerificationCubit;
      },
      act: (cubit) async {
        await cubit.loadVerification('token-1');
        await cubit.confirmVerification();
      },
      expect: () => [
        QrVerificationLoading(),
        QrVerificationLoaded(verification),
        QrVerificationConfirming(verification),
        const QrVerificationFailure('Onay başarısız'),
      ],
    );

    blocTest<QrVerificationCubit, QrVerificationState>(
      'reset clears the loaded verification and returns to initial state',
      build: () {
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(verification));
        return qrVerificationCubit;
      },
      act: (cubit) async {
        await cubit.loadVerification('token-1');
        cubit.reset();
      },
      expect: () => [
        QrVerificationLoading(),
        QrVerificationLoaded(verification),
        QrVerificationInitial(),
      ],
    );

    late Completer<Either<String, QrVerificationEntity>> confirmationCompleter;

    blocTest<QrVerificationCubit, QrVerificationState>(
      'ignores a second confirmation while the first one is in progress',
      build: () {
        confirmationCompleter =
            Completer<Either<String, QrVerificationEntity>>();
        when(
          () => mockGetQrVerificationUsecase(any()),
        ).thenAnswer((_) async => Right(verification));
        when(
          () => mockConfirmQrVerificationUsecase(any()),
        ).thenAnswer((_) => confirmationCompleter.future);
        addTearDown(() {
          if (!confirmationCompleter.isCompleted) {
            confirmationCompleter.complete(const Left('Test tamamlandı'));
          }
        });
        return qrVerificationCubit;
      },
      act: (cubit) async {
        await cubit.loadVerification('token-1');

        final firstConfirmation = cubit.confirmVerification();
        await Future<void>.delayed(Duration.zero);
        await cubit.confirmVerification();

        confirmationCompleter.complete(Right(confirmedVerification));
        await firstConfirmation;
      },
      expect: () => [
        QrVerificationLoading(),
        QrVerificationLoaded(verification),
        QrVerificationConfirming(verification),
        QrVerificationSuccess(confirmedVerification),
      ],
      verify: (_) {
        verify(() => mockConfirmQrVerificationUsecase(any())).called(1);
      },
    );
  });
}
