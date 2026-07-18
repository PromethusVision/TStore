import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';
import 'package:t_store/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/resend_confirmation_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';

// Mocks
class MockSignInUsecase extends Mock implements SignInUsecase {}

class MockSignUpUsecase extends Mock implements SignUpUsecase {}

class MockSignOutUsecase extends Mock implements SignOutUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockResendConfirmationUsecase extends Mock
    implements ResendConfirmationUsecase {}

class MockUpdatePasswordUsecase extends Mock implements UpdatePasswordUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

// Fake classes for registerFallbackValue
class FakeSignInParams extends Fake implements SignInParams {}

class FakeSignUpParams extends Fake implements SignUpParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late AuthCubit authCubit;
  late MockSignInUsecase mockSignInUsecase;
  late MockSignUpUsecase mockSignUpUsecase;
  late MockSignOutUsecase mockSignOutUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockResendConfirmationUsecase mockResendConfirmationUsecase;
  late MockUpdatePasswordUsecase mockUpdatePasswordUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUpAll(() {
    registerFallbackValue(FakeSignInParams());
    registerFallbackValue(FakeSignUpParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockSignInUsecase = MockSignInUsecase();
    mockSignUpUsecase = MockSignUpUsecase();
    mockSignOutUsecase = MockSignOutUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockResendConfirmationUsecase = MockResendConfirmationUsecase();
    mockUpdatePasswordUsecase = MockUpdatePasswordUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();

    authCubit = AuthCubit(
      signInUsecase: mockSignInUsecase,
      signUpUsecase: mockSignUpUsecase,
      signOutUsecase: mockSignOutUsecase,
      resetPasswordUsecase: mockResetPasswordUsecase,
      resendConfirmationUsecase: mockResendConfirmationUsecase,
      updatePasswordUsecase: mockUpdatePasswordUsecase,
      getCurrentUserUsecase: mockGetCurrentUserUsecase,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  // Test data
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testFullName = 'Test User';
  final testUser = UserEntity(
    id: 'test-id',
    email: testEmail,
    fullName: testFullName,
  );

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, AuthInitial());
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is logged in',
        build: () {
          when(
            () => mockGetCurrentUserUsecase(any()),
          ).thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthLoading(), AuthAuthenticated(testUser)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is logged in',
        build: () {
          when(
            () => mockGetCurrentUserUsecase(any()),
          ).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when fetching user fails',
        build: () {
          when(
            () => mockGetCurrentUserUsecase(any()),
          ).thenAnswer((_) async => const Left('Error'));
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );
    });

    group('signIn', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
        build: () {
          when(
            () => mockSignInUsecase(any()),
          ).thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.signIn(email: testEmail, password: testPassword),
        expect: () => [AuthLoading(), AuthAuthenticated(testUser)],
        verify: (_) {
          verify(() => mockSignInUsecase(any())).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(
            () => mockSignInUsecase(any()),
          ).thenAnswer((_) async => const Left('Invalid credentials'));
          return authCubit;
        },
        act: (cubit) => cubit.signIn(email: testEmail, password: testPassword),
        expect: () => [AuthLoading(), const AuthError('Invalid credentials')],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthEmailConfirmationRequired] when email not confirmed',
        build: () {
          when(() => mockSignInUsecase(any())).thenAnswer(
            (_) async =>
                const Left('E-posta adresinizi doğrulamanız gerekiyor.'),
          );
          return authCubit;
        },
        act: (cubit) => cubit.signIn(email: testEmail, password: testPassword),
        expect: () => [
          AuthLoading(),
          const AuthEmailConfirmationRequired(testEmail),
        ],
      );

      test('ignores a second sign in while the first one is loading', () async {
        final result = Completer<Either<String, UserEntity>>();
        when(() => mockSignInUsecase(any())).thenAnswer((_) => result.future);

        final firstRequest = authCubit.signIn(
          email: testEmail,
          password: testPassword,
        );
        await authCubit.signIn(email: testEmail, password: testPassword);

        verify(() => mockSignInUsecase(any())).called(1);

        result.complete(Right(testUser));
        await firstRequest;
        expect(authCubit.state, AuthAuthenticated(testUser));
      });
    });

    group('signUp', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthEmailConfirmationRequired] when sign up succeeds',
        build: () {
          when(
            () => mockSignUpUsecase(any()),
          ).thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.signUp(
          email: testEmail,
          password: testPassword,
          fullName: testFullName,
          privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
          termsOfUseVersion: LegalDocumentVersions.termsOfUse,
        ),
        expect: () => [
          AuthLoading(),
          const AuthEmailConfirmationRequired(testEmail),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(
            () => mockSignUpUsecase(any()),
          ).thenAnswer((_) async => const Left('Email already registered'));
          return authCubit;
        },
        act: (cubit) => cubit.signUp(
          email: testEmail,
          password: testPassword,
          fullName: testFullName,
          privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
          termsOfUseVersion: LegalDocumentVersions.termsOfUse,
        ),
        expect: () => [
          AuthLoading(),
          const AuthError('Email already registered'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'passes phone to usecase when provided',
        build: () {
          when(
            () => mockSignUpUsecase(any()),
          ).thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.signUp(
          email: testEmail,
          password: testPassword,
          fullName: testFullName,
          phone: '+1234567890',
          privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
          termsOfUseVersion: LegalDocumentVersions.termsOfUse,
        ),
        verify: (_) {
          final captured =
              verify(() => mockSignUpUsecase(captureAny())).captured.first
                  as SignUpParams;
          expect(captured.phone, '+1234567890');
          expect(
            captured.privacyNoticeVersion,
            LegalDocumentVersions.privacyNotice,
          );
          expect(captured.termsOfUseVersion, LegalDocumentVersions.termsOfUse);
        },
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
        build: () {
          when(
            () => mockSignOutUsecase(any()),
          ).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(
            () => mockSignOutUsecase(any()),
          ).thenAnswer((_) async => const Left('Sign out failed'));
          return authCubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [AuthLoading(), const AuthError('Sign out failed')],
      );
    });

    group('resetPassword', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthPasswordResetSent] when reset password succeeds',
        build: () {
          when(
            () => mockResetPasswordUsecase(testEmail),
          ).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.resetPassword(testEmail),
        expect: () => [AuthLoading(), const AuthPasswordResetSent(testEmail)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] when reset password fails',
        build: () {
          when(
            () => mockResetPasswordUsecase(testEmail),
          ).thenAnswer((_) async => const Left('E-posta gönderilemedi.'));
          return authCubit;
        },
        act: (cubit) => cubit.resetPassword(testEmail),
        expect: () => [
          AuthLoading(),
          const AuthError('E-posta gönderilemedi.'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'ignores a second reset request while loading',
        build: () => authCubit,
        seed: AuthLoading.new,
        act: (cubit) => cubit.resetPassword(testEmail),
        expect: () => <AuthState>[],
        verify: (_) {
          verifyNever(() => mockResetPasswordUsecase(any()));
        },
      );
    });

    group('updatePassword', () {
      const newPassword = 'NewStrong1!';

      blocTest<AuthCubit, AuthState>(
        'emits success when the recovery password is updated',
        build: () {
          when(
            () => mockUpdatePasswordUsecase(newPassword),
          ).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.updatePassword(newPassword),
        expect: () => [AuthLoading(), AuthPasswordUpdated()],
      );

      blocTest<AuthCubit, AuthState>(
        'emits error when the recovery password cannot be updated',
        build: () {
          when(
            () => mockUpdatePasswordUsecase(newPassword),
          ).thenAnswer((_) async => const Left('Bağlantı geçersiz.'));
          return authCubit;
        },
        act: (cubit) => cubit.updatePassword(newPassword),
        expect: () => [AuthLoading(), const AuthError('Bağlantı geçersiz.')],
      );

      blocTest<AuthCubit, AuthState>(
        'ignores a second password update while loading',
        build: () => authCubit,
        seed: AuthLoading.new,
        act: (cubit) => cubit.updatePassword(newPassword),
        expect: () => <AuthState>[],
        verify: (_) {
          verifyNever(() => mockUpdatePasswordUsecase(any()));
        },
      );
    });

    group('resendConfirmation', () {
      blocTest<AuthCubit, AuthState>(
        'emits success after confirmation email is resent',
        build: () {
          when(
            () => mockResendConfirmationUsecase(testEmail),
          ).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.resendConfirmation(testEmail),
        expect: () => [AuthLoading(), const AuthConfirmationResent(testEmail)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits error when confirmation email cannot be resent',
        build: () {
          when(
            () => mockResendConfirmationUsecase(testEmail),
          ).thenAnswer((_) async => const Left('Çok fazla deneme yapıldı.'));
          return authCubit;
        },
        act: (cubit) => cubit.resendConfirmation(testEmail),
        expect: () => [
          AuthLoading(),
          const AuthError('Çok fazla deneme yapıldı.'),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'ignores a second resend while an auth request is loading',
        build: () => authCubit,
        seed: AuthLoading.new,
        act: (cubit) => cubit.resendConfirmation(testEmail),
        expect: () => <AuthState>[],
        verify: (_) {
          verifyNever(() => mockResendConfirmationUsecase(any()));
        },
      );
    });

    group('clearError', () {
      blocTest<AuthCubit, AuthState>(
        'emits AuthUnauthenticated when current state is AuthError',
        build: () => authCubit,
        seed: () => const AuthError('Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [AuthUnauthenticated()],
      );

      blocTest<AuthCubit, AuthState>(
        'does not emit when current state is not AuthError',
        build: () => authCubit,
        seed: () => AuthUnauthenticated(),
        act: (cubit) => cubit.clearError(),
        expect: () => [],
      );
    });

    group('syncUserProfile', () {
      const updatedUser = UserEntity(
        id: 'test-id',
        email: testEmail,
        fullName: 'Updated User',
        phone: '05551112233',
      );

      blocTest<AuthCubit, AuthState>(
        'updates the authenticated user when account ids match',
        build: () => authCubit,
        seed: () => AuthAuthenticated(testUser),
        act: (cubit) => cubit.syncUserProfile(updatedUser),
        expect: () => [const AuthAuthenticated(updatedUser)],
      );

      blocTest<AuthCubit, AuthState>(
        'does not replace a different authenticated account',
        build: () => authCubit,
        seed: () => AuthAuthenticated(testUser),
        act: (cubit) => cubit.syncUserProfile(
          const UserEntity(id: 'another-id', email: 'another@example.com'),
        ),
        expect: () => <AuthState>[],
      );
    });
  });
}
