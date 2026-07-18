import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/supabase_service.dart';

void main() {
  group('password recovery launch', () {
    test('recognizes only the password recovery action', () {
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=password_recovery&code=temporary-code',
          ),
        ),
        isTrue,
      );
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          Uri.parse(
            'http://127.0.0.1:7357/'
            '?auth_action=email_confirmation&code=temporary-code',
          ),
        ),
        isFalse,
      );
      expect(
        SupabaseService.isPasswordRecoveryLaunchUri(
          Uri.parse('http://127.0.0.1:7357/'),
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
          verifyToken: (tokenHash) async {
            receivedTokenHash = tokenHash;
            return true;
          },
        );

        expect(status, PasswordRecoveryLaunchStatus.verified);
        expect(receivedTokenHash, 'one-time-token');
      },
    );

    test('rejects a recovery link without a usable token hash', () async {
      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse(
          'http://127.0.0.1:7357/'
          '?auth_action=password_recovery&type=recovery',
        ),
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
        verifyToken: (_) async => throw Exception('expired'),
      );

      expect(status, PasswordRecoveryLaunchStatus.invalid);
    });

    test('does not verify ordinary app launches', () async {
      var verifierCalled = false;

      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: Uri.parse('http://127.0.0.1:7357/'),
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
      );

      expect(redirect, 'http://127.0.0.1:7357/?auth_action=password_recovery');
    });

    test('builds a mobile recovery redirect with the same action', () {
      final redirect = SupabaseService.passwordRecoveryRedirectFor(
        appUri: Uri.parse('http://127.0.0.1:7357/'),
        isWeb: false,
      );

      expect(
        redirect,
        'io.supabase.tstore://login-callback/'
        '?auth_action=password_recovery',
      );
    });
  });
}
