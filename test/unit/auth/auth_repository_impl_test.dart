import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockSupabaseUser extends Mock implements User {}

const _recoveryIdentity = PasswordRecoveryIdentity(
  userId: 'customer-1',
  email: 'customer@example.com',
);
const _newPassword = 'NewStrong1!';

void main() {
  test(
    'sign up sends the accepted legal document versions as metadata',
    () async {
      final supabaseService = MockSupabaseService();
      final response = MockAuthResponse();
      final user = MockSupabaseUser();
      final repository = AuthRepositoryImpl(supabaseService: supabaseService);

      when(() => response.user).thenReturn(user);
      when(() => user.id).thenReturn('customer-1');
      when(
        () => supabaseService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.signUp(
        email: 'customer@example.com',
        password: 'Strong1!',
        fullName: 'Müşteri Kullanıcı',
        phone: '05551234567',
        privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
        termsOfUseVersion: LegalDocumentVersions.termsOfUse,
      );

      expect(result.isRight(), isTrue);

      final capturedData =
          verify(
                () => supabaseService.signUp(
                  email: 'customer@example.com',
                  password: 'Strong1!',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(capturedData['privacy_notice_acknowledged'], isTrue);
      expect(
        capturedData['privacy_notice_version'],
        LegalDocumentVersions.privacyNotice,
      );
      expect(capturedData['terms_of_use_accepted'], isTrue);
      expect(
        capturedData['terms_of_use_version'],
        LegalDocumentVersions.termsOfUse,
      );
    },
  );

  test(
    'existing signup is indistinguishable from confirmation required',
    () async {
      final supabaseService = MockSupabaseService();
      final repository = AuthRepositoryImpl(supabaseService: supabaseService);

      when(
        () => supabaseService.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenThrow(const AuthException('User already registered'));

      final result = await repository.signUp(
        email: 'existing@example.com',
        password: 'Strong1!',
        fullName: 'Mevcut Kullanıcı',
        privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
        termsOfUseVersion: LegalDocumentVersions.termsOfUse,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Existing account details must not be exposed.'),
        (user) => expect(user.email, 'existing@example.com'),
      );
    },
  );

  test('unconfirmed email error is returned in Turkish', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException('Email not confirmed'));

    final result = await repository.signIn(
      email: 'customer@example.com',
      password: 'Strong1!',
    );

    expect(
      result.fold((error) => error, (_) => ''),
      'E-posta adresinizi doğrulamanız gerekiyor.',
    );
  });

  test('invalid credentials are returned without technical details', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));

    final result = await repository.signIn(
      email: 'customer@example.com',
      password: 'wrong-password',
    );

    expect(
      result.fold((error) => error, (_) => ''),
      'E-posta veya şifre hatalı.',
    );
  });

  test('connection failure is returned as a safe Turkish message', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(Exception('ClientException: Failed to fetch secret-host'));

    final result = await repository.signIn(
      email: 'customer@example.com',
      password: 'Strong1!',
    );

    final message = result.fold((error) => error, (_) => '');
    expect(message, 'İnternet bağlantınızı kontrol edip tekrar deneyin.');
    expect(message, isNot(contains('secret-host')));
  });

  test(
    'service failure is returned as an actionable Turkish message',
    () async {
      final supabaseService = MockSupabaseService();
      final repository = AuthRepositoryImpl(supabaseService: supabaseService);

      when(
        () => supabaseService.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('Internal server error'));

      final result = await repository.signIn(
        email: 'customer@example.com',
        password: 'Strong1!',
      );

      expect(
        result.fold((error) => error, (_) => ''),
        'Giriş hizmeti şu anda yanıt vermiyor. '
        'Lütfen kısa süre sonra tekrar deneyin.',
      );
    },
  );

  test('unexpected sign in failure never exposes its details', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(StateError('database-password-was-visible'));

    final result = await repository.signIn(
      email: 'customer@example.com',
      password: 'Strong1!',
    );

    final message = result.fold((error) => error, (_) => '');
    expect(message, 'Giriş yapılamadı. Lütfen tekrar deneyin.');
    expect(message, isNot(contains('database-password-was-visible')));
  });

  test('resend rate limit is not mistaken for an invalid email', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.resendConfirmation('customer@example.com'),
    ).thenThrow(const AuthException('Email rate limit exceeded'));

    final result = await repository.resendConfirmation('customer@example.com');

    expect(
      result.fold((error) => error, (_) => ''),
      'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.',
    );
  });

  test(
    'expired recovery session is returned as a safe Turkish error',
    () async {
      final supabaseService = MockSupabaseService();
      final repository = AuthRepositoryImpl(supabaseService: supabaseService);

      when(
        () => supabaseService.currentSession,
      ).thenReturn(_sessionFor(_recoveryIdentity));
      when(
        () => supabaseService.updatePassword(_newPassword),
      ).thenThrow(const AuthException('Auth session missing!'));

      final result = await repository.updatePassword(
        const UpdatePasswordParams(
          newPassword: _newPassword,
          recoveryIdentity: _recoveryIdentity,
        ),
      );

      expect(
        result.fold((failure) => failure.message, (_) => ''),
        'Şifre yenileme bağlantısı geçersiz veya süresi dolmuş. '
        'Lütfen yeni bir bağlantı isteyin.',
      );
    },
  );

  test(
    'update response without password persistence never reports success',
    () async {
      final service = StatefulRecoverySupabaseService(
        identity: _recoveryIdentity,
        storedPassword: 'OldStrong1!',
        persistPasswordUpdate: false,
      );
      final repository = AuthRepositoryImpl(supabaseService: service);

      final result = await repository.updatePassword(
        const UpdatePasswordParams(
          newPassword: _newPassword,
          recoveryIdentity: _recoveryIdentity,
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((failure) => failure.reason, (_) => null),
        PasswordRecoveryFailureReason.freshLoginInvalidCredentials,
      );
    },
  );

  test('fresh login service failure has a distinct typed result', () async {
    final service = StatefulRecoverySupabaseService(
      identity: _recoveryIdentity,
      storedPassword: 'OldStrong1!',
      freshLoginFailure: const AuthException('Internal server error'),
    );
    final repository = AuthRepositoryImpl(supabaseService: service);

    final result = await repository.updatePassword(
      const UpdatePasswordParams(
        newPassword: _newPassword,
        recoveryIdentity: _recoveryIdentity,
      ),
    );

    expect(
      result.fold((failure) => failure.reason, (_) => null),
      PasswordRecoveryFailureReason.freshLoginFailed,
    );
  });

  test(
    'authoritative recovery succeeds with clean same-password same-user login',
    () async {
      final service = StatefulRecoverySupabaseService(
        identity: _recoveryIdentity,
        storedPassword: 'OldStrong1!',
      );
      final repository = AuthRepositoryImpl(supabaseService: service);

      final result = await repository.updatePassword(
        const UpdatePasswordParams(
          newPassword: _newPassword,
          recoveryIdentity: _recoveryIdentity,
        ),
      );

      expect(
        result,
        const Right(PasswordRecoveryVerification(userId: 'customer-1')),
      );
      expect(service.updatePasswordValue, service.freshLoginPasswordValue);
      expect(
        identical(service.updatePasswordValue, service.freshLoginPasswordValue),
        isTrue,
      );
      expect(service.currentUser?.id, _recoveryIdentity.userId);
    },
  );

  test(
    'update response for another identity is rejected and cleaned',
    () async {
      final service = StatefulRecoverySupabaseService(
        identity: _recoveryIdentity,
        storedPassword: 'OldStrong1!',
        updateResponseUserId: 'customer-2',
      );
      final repository = AuthRepositoryImpl(supabaseService: service);

      final result = await repository.updatePassword(
        const UpdatePasswordParams(
          newPassword: _newPassword,
          recoveryIdentity: _recoveryIdentity,
        ),
      );

      expect(
        result.fold((failure) => failure.reason, (_) => null),
        PasswordRecoveryFailureReason.invalidUpdateResponse,
      );
      expect(service.currentSession, isNull);
      expect(service.freshLoginPasswordValue, isNull);
    },
  );

  test('fresh login with another user identity is rejected', () async {
    final service = StatefulRecoverySupabaseService(
      identity: _recoveryIdentity,
      storedPassword: 'OldStrong1!',
      freshLoginUserId: 'customer-2',
    );
    final repository = AuthRepositoryImpl(supabaseService: service);

    final result = await repository.updatePassword(
      const UpdatePasswordParams(
        newPassword: _newPassword,
        recoveryIdentity: _recoveryIdentity,
      ),
    );

    expect(
      result.fold((failure) => failure.reason, (_) => null),
      PasswordRecoveryFailureReason.identityMismatch,
    );
    expect(service.currentSession, isNull);
  });

  test('recovery session cleanup failure is not treated as success', () async {
    final service = StatefulRecoverySupabaseService(
      identity: _recoveryIdentity,
      storedPassword: 'OldStrong1!',
      cleanupFails: true,
    );
    final repository = AuthRepositoryImpl(supabaseService: service);

    final result = await repository.updatePassword(
      const UpdatePasswordParams(
        newPassword: _newPassword,
        recoveryIdentity: _recoveryIdentity,
      ),
    );

    expect(
      result.fold((failure) => failure.reason, (_) => null),
      PasswordRecoveryFailureReason.sessionCleanupFailed,
    );
    expect(service.freshLoginPasswordValue, isNull);
  });

  test('account deletion calls the protected customer operation', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.deleteCurrentCustomerAccount(),
    ).thenAnswer((_) async {});

    final result = await repository.deleteCurrentCustomerAccount();

    expect(result.isRight(), isTrue);
    verify(() => supabaseService.deleteCurrentCustomerAccount()).called(1);
  });

  test(
    'merchant deletion denial is returned without technical details',
    () async {
      final supabaseService = MockSupabaseService();
      final repository = AuthRepositoryImpl(supabaseService: supabaseService);

      when(() => supabaseService.deleteCurrentCustomerAccount()).thenThrow(
        const PostgrestException(
          message: 'Only customer accounts can be deleted here',
          code: '42501',
        ),
      );

      final result = await repository.deleteCurrentCustomerAccount();
      final message = result.fold((error) => error, (_) => '');

      expect(
        message,
        'Bu hesap müşteri uygulamasından silinemez. '
        'Lütfen destek ekibiyle iletişime geçin.',
      );
      expect(message, isNot(contains('42501')));
    },
  );

  test('unexpected deletion failure never exposes backend details', () async {
    final supabaseService = MockSupabaseService();
    final repository = AuthRepositoryImpl(supabaseService: supabaseService);

    when(
      () => supabaseService.deleteCurrentCustomerAccount(),
    ).thenThrow(StateError('service-role-secret-was-visible'));

    final result = await repository.deleteCurrentCustomerAccount();
    final message = result.fold((error) => error, (_) => '');

    expect(message, 'Hesabınız silinemedi. Lütfen daha sonra tekrar deneyin.');
    expect(message, isNot(contains('service-role-secret-was-visible')));
  });
}

class StatefulRecoverySupabaseService extends Fake implements SupabaseService {
  StatefulRecoverySupabaseService({
    required this.identity,
    required String storedPassword,
    this.persistPasswordUpdate = true,
    this.cleanupFails = false,
    this.freshLoginFailure,
    String? updateResponseUserId,
    String? freshLoginUserId,
  }) : _storedPassword = storedPassword,
       _updateResponseUserId = updateResponseUserId ?? identity.userId,
       _freshLoginUserId = freshLoginUserId ?? identity.userId,
       _currentUser = _userFor(identity.userId, identity.email),
       _currentSession = _sessionFor(identity);

  final PasswordRecoveryIdentity identity;
  final bool persistPasswordUpdate;
  final bool cleanupFails;
  final AuthException? freshLoginFailure;
  final String _updateResponseUserId;
  final String _freshLoginUserId;
  String _storedPassword;
  User? _currentUser;
  Session? _currentSession;
  String? updatePasswordValue;
  String? freshLoginPasswordValue;

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => _currentSession;

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    updatePasswordValue = newPassword;
    if (persistPasswordUpdate) _storedPassword = newPassword;
    return UserResponse.fromJson(
      _userJson(_updateResponseUserId, identity.email),
    );
  }

  @override
  Future<void> clearLocalAuthSession() async {
    if (cleanupFails) throw const AuthException('Sign out failed');
    _currentUser = null;
    _currentSession = null;
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    freshLoginPasswordValue = password;
    final configuredFailure = freshLoginFailure;
    if (configuredFailure != null) throw configuredFailure;
    if (password != _storedPassword) {
      throw const AuthException('Invalid login credentials');
    }

    final user = _userFor(_freshLoginUserId, email);
    final session = _sessionFor(
      PasswordRecoveryIdentity(userId: _freshLoginUserId, email: email),
    );
    _currentUser = user;
    _currentSession = session;
    return AuthResponse(user: user, session: session);
  }
}

Session _sessionFor(PasswordRecoveryIdentity identity) {
  return Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: _userFor(identity.userId, identity.email),
  );
}

User _userFor(String userId, String email) {
  return User(
    id: userId,
    email: email,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-01-01T00:00:00.000Z',
  );
}

Map<String, dynamic> _userJson(String userId, String email) {
  return <String, dynamic>{
    'id': userId,
    'email': email,
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'aud': 'authenticated',
    'created_at': '2026-01-01T00:00:00.000Z',
  };
}
