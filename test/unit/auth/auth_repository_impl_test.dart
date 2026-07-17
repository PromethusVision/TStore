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
}
