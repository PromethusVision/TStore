import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/cart/domain/usecases/create_qr_session_usecase.dart';
import 'package:t_store/features/cart/domain/usecases/get_qr_session_status_usecase.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/qr_session_state.dart';

class MockCreateQrSessionUsecase extends Mock
    implements CreateQrSessionUsecase {}

class MockGetQrSessionStatusUsecase extends Mock
    implements GetQrSessionStatusUsecase {}

class FakeCreateQrSessionParams extends Fake implements CreateQrSessionParams {}

class FakeGetQrSessionStatusParams extends Fake
    implements GetQrSessionStatusParams {}

void main() {
  late MockCreateQrSessionUsecase mockCreateQrSessionUsecase;
  late MockGetQrSessionStatusUsecase mockGetQrSessionStatusUsecase;
  late QrSessionCubit qrSessionCubit;

  final activeSession = QrSessionEntity(
    id: 'session-1',
    sessionToken: 'token-1',
    userId: 'user-1',
    cartId: 'cart-1',
    shopId: 'shop-1',
    status: 'active',
    expiresAt: DateTime.utc(2099, 1, 1),
    createdAt: DateTime.utc(2098, 12, 1),
    updatedAt: DateTime.utc(2098, 12, 1),
    itemCount: 3,
    totalAmount: 125.50,
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateQrSessionParams());
    registerFallbackValue(FakeGetQrSessionStatusParams());
  });

  setUp(() {
    mockCreateQrSessionUsecase = MockCreateQrSessionUsecase();
    mockGetQrSessionStatusUsecase = MockGetQrSessionStatusUsecase();
    qrSessionCubit = QrSessionCubit(
      createQrSessionUsecase: mockCreateQrSessionUsecase,
      getQrSessionStatusUsecase: mockGetQrSessionStatusUsecase,
      statusCheckInterval: const Duration(days: 1),
    );
  });

  tearDown(() async {
    if (!qrSessionCubit.isClosed) {
      await qrSessionCubit.close();
    }
  });

  group('QrSessionCubit', () {
    test('initial state is QrSessionInitial', () {
      expect(qrSessionCubit.state, QrSessionInitial());
    });

    blocTest<QrSessionCubit, QrSessionState>(
      'creates a QR session successfully',
      build: () {
        when(
          () => mockCreateQrSessionUsecase(any()),
        ).thenAnswer((_) async => Right(activeSession));
        return qrSessionCubit;
      },
      act: (cubit) => cubit.createQrSession('cart-1'),
      expect: () => [QrSessionLoading(), QrSessionCreated(activeSession)],
      verify: (_) {
        final params =
            verify(
                  () => mockCreateQrSessionUsecase(captureAny()),
                ).captured.single
                as CreateQrSessionParams;
        expect(params.cartId, 'cart-1');
      },
    );

    blocTest<QrSessionCubit, QrSessionState>(
      'emits failure when creating a QR session fails',
      build: () {
        when(
          () => mockCreateQrSessionUsecase(any()),
        ).thenAnswer((_) async => const Left('QR oluşturulamadı'));
        return qrSessionCubit;
      },
      act: (cubit) => cubit.createQrSession('cart-1'),
      expect: () => [
        QrSessionLoading(),
        const QrSessionFailure('QR oluşturulamadı'),
      ],
    );

    test('keeps item count and total amount returned by the server', () async {
      when(
        () => mockCreateQrSessionUsecase(any()),
      ).thenAnswer((_) async => Right(activeSession));

      await qrSessionCubit.createQrSession('cart-1');

      final state = qrSessionCubit.state as QrSessionCreated;
      expect(state.session.itemCount, 3);
      expect(state.session.totalAmount, 125.50);
    });

    blocTest<QrSessionCubit, QrSessionState>(
      'emits completed when the server reports used status',
      build: () {
        when(
          () => mockCreateQrSessionUsecase(any()),
        ).thenAnswer((_) async => Right(activeSession));
        when(
          () => mockGetQrSessionStatusUsecase(any()),
        ).thenAnswer((_) async => const Right('used'));
        return qrSessionCubit;
      },
      act: (cubit) async {
        await cubit.createQrSession('cart-1');
        await cubit.checkSessionStatus();
      },
      expect: () => [
        QrSessionLoading(),
        QrSessionCreated(activeSession),
        const QrSessionCompleted(sessionId: 'session-1'),
      ],
      verify: (_) {
        final params =
            verify(
                  () => mockGetQrSessionStatusUsecase(captureAny()),
                ).captured.single
                as GetQrSessionStatusParams;
        expect(params.sessionId, 'session-1');
      },
    );

    blocTest<QrSessionCubit, QrSessionState>(
      'does not complete while the server status remains active',
      build: () {
        when(
          () => mockCreateQrSessionUsecase(any()),
        ).thenAnswer((_) async => Right(activeSession));
        when(
          () => mockGetQrSessionStatusUsecase(any()),
        ).thenAnswer((_) async => const Right('active'));
        return qrSessionCubit;
      },
      act: (cubit) async {
        await cubit.createQrSession('cart-1');
        await cubit.checkSessionStatus();
      },
      expect: () => [QrSessionLoading(), QrSessionCreated(activeSession)],
      verify: (_) {
        verify(() => mockGetQrSessionStatusUsecase(any())).called(1);
      },
    );

    for (final status in ['expired', 'cancelled']) {
      blocTest<QrSessionCubit, QrSessionState>(
        'asks for a new QR when polling returns $status',
        build: () {
          when(
            () => mockCreateQrSessionUsecase(any()),
          ).thenAnswer((_) async => Right(activeSession));
          when(
            () => mockGetQrSessionStatusUsecase(any()),
          ).thenAnswer((_) async => Right(status));
          return qrSessionCubit;
        },
        act: (cubit) async {
          await cubit.createQrSession('cart-1');
          await cubit.checkSessionStatus();
        },
        expect: () => [
          QrSessionLoading(),
          QrSessionCreated(activeSession),
          isA<QrSessionFailure>().having(
            (state) => state.message,
            'message',
            isNotEmpty,
          ),
        ],
        verify: (cubit) {
          expect(cubit.state, isA<QrSessionFailure>());
          verify(() => mockGetQrSessionStatusUsecase(any())).called(1);
        },
      );
    }

    test('closing during a status check is safe', () async {
      final statusCompleter = Completer<Either<String, String>>();
      when(
        () => mockCreateQrSessionUsecase(any()),
      ).thenAnswer((_) async => Right(activeSession));
      when(
        () => mockGetQrSessionStatusUsecase(any()),
      ).thenAnswer((_) => statusCompleter.future);

      await qrSessionCubit.createQrSession('cart-1');
      final statusCheck = qrSessionCubit.checkSessionStatus();
      await Future<void>.delayed(Duration.zero);

      await qrSessionCubit.close();
      statusCompleter.complete(const Right('used'));

      await expectLater(statusCheck, completes);
      expect(qrSessionCubit.state, QrSessionCreated(activeSession));
      verify(() => mockGetQrSessionStatusUsecase(any())).called(1);
    });
  });
}
