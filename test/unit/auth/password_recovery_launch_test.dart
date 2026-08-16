import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';

void main() {
  final webAppUri = Uri.parse('http://127.0.0.1:7357/');
  final developmentContract = AuthCallbackContract.forEnvironment(
    AppEnvironment.development,
  );

  group('password recovery launch', () {
    test('recognizes only the password recovery action', () {
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          uri: Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=password_recovery&code=temporary-code',
          ),
          appUri: webAppUri,
          isWeb: true,
          environment: AppEnvironment.development,
        ),
        isTrue,
      );
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          uri: Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=email_confirmation&code=temporary-code',
          ),
          appUri: webAppUri,
          isWeb: true,
          environment: AppEnvironment.development,
        ),
        isFalse,
      );
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          uri: Uri.parse('http://127.0.0.1:7357/'),
          appUri: webAppUri,
          isWeb: true,
          environment: AppEnvironment.development,
        ),
        isFalse,
      );
    });

    test(
      'verifies a recovery token hash without browser-local state',
      () async {
        String? receivedTokenHash;

        final status = await SupabaseService.resolvePasswordRecoveryLaunch(
          uri: Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=password_recovery'
            '&token_hash=one-time-token'
            '&type=recovery',
          ),
          appUri: webAppUri,
          isWeb: true,
          contract: developmentContract,
          verifyToken: (tokenHash) async {
            receivedTokenHash = tokenHash;
            return true;
          },
        );

        expect(status, PasswordRecoveryLaunchStatus.verified);
        expect(receivedTokenHash, 'one-time-token');
      },
    );

    test(
      'accepts a recovery session already verified by PKCE startup',
      () async {
        var verifierCalled = false;

        final status = await SupabaseService.resolvePasswordRecoveryLaunch(
          uri: Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=password_recovery&code=one-time-code',
          ),
          appUri: webAppUri,
          isWeb: true,
          contract: developmentContract,
          recoverySessionVerified: true,
          verifyToken: (_) async {
            verifierCalled = true;
            return false;
          },
        );

        expect(status, PasswordRecoveryLaunchStatus.verified);
        expect(verifierCalled, isFalse);
      },
    );

    test('rejects an unverified PKCE recovery callback', () async {
      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse(
          'http://127.0.0.1:7357/'
          '?auth_action=password_recovery&code=expired-code',
        ),
        appUri: webAppUri,
        isWeb: true,
        contract: developmentContract,
        verifyToken: (_) async => true,
      );

      expect(status, PasswordRecoveryLaunchStatus.invalid);
    });

    test('rejects a recovery link without a usable token hash', () async {
      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse(
          'http://127.0.0.1:7357/'
          '?auth_action=password_recovery&type=recovery',
        ),
        appUri: webAppUri,
        isWeb: true,
        contract: developmentContract,
        verifyToken: (_) async => true,
      );

      expect(status, PasswordRecoveryLaunchStatus.invalid);
    });

    test('rejects an expired or already used recovery token', () async {
      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse(
          'http://127.0.0.1:7357/'
          '?auth_action=password_recovery'
          '&token_hash=expired-token'
          '&type=recovery',
        ),
        appUri: webAppUri,
        isWeb: true,
        contract: developmentContract,
        verifyToken: (_) async => throw Exception('expired'),
      );

      expect(status, PasswordRecoveryLaunchStatus.invalid);
    });

    test('does not verify ordinary app launches', () async {
      var verifierCalled = false;

      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse('http://127.0.0.1:7357/'),
        appUri: webAppUri,
        isWeb: true,
        contract: developmentContract,
        verifyToken: (_) async {
          verifierCalled = true;
          return true;
        },
      );

      expect(status, PasswordRecoveryLaunchStatus.none);
      expect(verifierCalled, isFalse);
    });

    test('builds a web recovery redirect without carrying page state', () {
      final redirect = SupabaseService.passwordRecoveryRedirectFor(
        appUri: Uri.parse('http://127.0.0.1:7357/products/42?existing=value'),
        isWeb: true,
        environment: AppEnvironment.development,
      );

      expect(redirect, 'http://127.0.0.1:7357/?auth_action=password_recovery');
    });

    test('builds a mobile recovery redirect with the same action', () {
      final redirect = SupabaseService.passwordRecoveryRedirectFor(
        appUri: Uri.parse('http://127.0.0.1:7357/'),
        isWeb: false,
        environment: AppEnvironment.development,
      );

      expect(
        redirect,
        'io.supabase.tstore://login-callback/'
        '?auth_action=password_recovery',
      );
    });
  });
}
