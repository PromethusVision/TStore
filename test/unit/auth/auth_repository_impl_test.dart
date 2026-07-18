import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockSupabaseUser extends Mock implements User {}

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
        () => supabaseService.updatePassword('NewStrong1!'),
      ).thenThrow(const AuthException('Auth session missing!'));

      final result = await repository.updatePassword('NewStrong1!');

      expect(
        result.fold((error) => error, (_) => ''),
        'Şifre yenileme bağlantısı geçersiz veya süresi dolmuş. '
        'Lütfen yeni bir bağlantı isteyin.',
      );
    },
  );
}
