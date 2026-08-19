import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';

void main() {
  final production = AuthCallbackContract.forEnvironment(
    AppEnvironment.production,
  );
  final development = AuthCallbackContract.forEnvironment(
    AppEnvironment.development,
  );
  final webAppUri = Uri.parse('https://app.esnaftavar.com/products/42');

  group('environment callback selection', () {
    test('Production email flows use only the final callback', () {
      expect(
        production.emailRedirectFor(
          appUri: Uri.base,
          isWeb: false,
          action: AuthEmailRedirectAction.confirmation,
        ),
        AuthCallbackContract.productionMobileCallback,
      );
      expect(
        production.emailRedirectFor(
          appUri: Uri.base,
          isWeb: false,
          action: AuthEmailRedirectAction.passwordRecovery,
        ),
        'com.esnaftavar.app://login-callback/'
        '?auth_action=password_recovery',
      );
    });

    test('Development keeps its existing callback without fallback', () {
      expect(
        development.emailRedirectFor(
          appUri: Uri.base,
          isWeb: false,
          action: AuthEmailRedirectAction.confirmation,
        ),
        AuthCallbackContract.developmentMobileCallback,
      );
      expect(
        development.mobileCallbackUri,
        isNot(production.mobileCallbackUri),
      );
    });

    test('signup and resend share an explicit confirmation redirect', () {
      final signupRedirect = SupabaseService.emailConfirmationRedirectFor(
        appUri: Uri.base,
        isWeb: false,
        environment: AppEnvironment.production,
      );
      final resendRedirect = SupabaseService.emailConfirmationRedirectFor(
        appUri: Uri.base,
        isWeb: false,
        environment: AppEnvironment.production,
      );

      expect(signupRedirect, AuthCallbackContract.productionMobileCallback);
      expect(resendRedirect, signupRedirect);
    });

    test('web email flows use the current origin root explicitly', () {
      expect(
        production.emailRedirectFor(
          appUri: webAppUri,
          isWeb: true,
          action: AuthEmailRedirectAction.confirmation,
        ),
        'https://app.esnaftavar.com/',
      );
      expect(
        production.emailRedirectFor(
          appUri: webAppUri,
          isWeb: true,
          action: AuthEmailRedirectAction.passwordRecovery,
        ),
        'https://app.esnaftavar.com/?auth_action=password_recovery',
      );
    });
  });

  group('PKCE callback validation', () {
    test('accepts only the selected environment scheme, host, and path', () {
      expect(
        production.acceptsPkceCallback(
          uri: Uri.parse(
            'com.esnaftavar.app://login-callback/?code=one-time-code',
          ),
          appUri: Uri.base,
          isWeb: false,
        ),
        isTrue,
      );

      for (final rejected in [
        'io.supabase.tstore://login-callback/?code=one-time-code',
        'com.esnaftavar.app://wrong-host/?code=one-time-code',
        'com.esnaftavar.app://login-callback/wrong?code=one-time-code',
        'com.esnaftavar.app://login-callback/?code=',
        'https://attacker.invalid/?code=one-time-code',
      ]) {
        expect(
          production.acceptsPkceCallback(
            uri: Uri.parse(rejected),
            appUri: Uri.base,
            isWeb: false,
          ),
          isFalse,
          reason: rejected,
        );
      }
    });

    test('arbitrary web origins cannot trigger PKCE exchange', () {
      expect(
        production.acceptsPkceCallback(
          uri: Uri.parse('https://attacker.invalid/?code=one-time-code'),
          appUri: webAppUri,
          isWeb: true,
        ),
        isFalse,
      );
      expect(
        production.acceptsPkceCallback(
          uri: Uri.parse('https://app.esnaftavar.com/?code=one-time-code'),
          appUri: webAppUri,
          isWeb: true,
        ),
        isTrue,
      );
    });

    test('rejected callbacks never reach the PKCE exchange function', () async {
      var exchangeCount = 0;

      final exchanged = await SupabaseService.exchangeValidatedPkceCallback(
        uri: Uri.parse(
          'io.supabase.tstore://login-callback/?code=one-time-code',
        ),
        appUri: Uri.base,
        isWeb: false,
        contract: production,
        exchangeCode: (_) async => exchangeCount++,
      );

      expect(exchanged, isFalse);
      expect(exchangeCount, 0);
    });

    test('valid Production recovery PKCE remains verified', () async {
      final uri = Uri.parse(
        'com.esnaftavar.app://login-callback/'
        '?auth_action=password_recovery&code=one-time-code',
      );
      var exchangeCount = 0;

      final exchanged = await SupabaseService.exchangeValidatedPkceCallback(
        uri: uri,
        appUri: Uri.base,
        isWeb: false,
        contract: production,
        exchangeCode: (_) async => exchangeCount++,
      );
      final status = await SupabaseService.resolvePasswordRecoveryLaunch(
        uri: uri,
        appUri: Uri.base,
        isWeb: false,
        contract: production,
        recoverySessionVerified: exchanged,
        verifyToken: (_) async => false,
      );

      expect(exchanged, isTrue);
      expect(exchangeCount, 1);
      expect(status, PasswordRecoveryLaunchStatus.verified);
    });

    test(
      'valid confirmation callback reports the refreshed session state',
      () async {
        final callback = Uri.parse(
          'com.esnaftavar.app://login-callback/?code=one-time-code',
        );

        expect(
          await SupabaseService.resolveEmailConfirmationCallback(
            uri: callback,
            appUri: Uri.base,
            isWeb: false,
            contract: production,
            exchangeCode: (_) async => true,
          ),
          EmailConfirmationCallbackStatus.authenticated,
        );
        expect(
          await SupabaseService.resolveEmailConfirmationCallback(
            uri: callback,
            appUri: Uri.base,
            isWeb: false,
            contract: production,
            exchangeCode: (_) async => false,
          ),
          EmailConfirmationCallbackStatus.confirmedWithoutSession,
        );
      },
    );

    test(
      'malformed confirmation is rejected without attempting exchange',
      () async {
        var exchangeCount = 0;

        final status = await SupabaseService.resolveEmailConfirmationCallback(
          uri: Uri.parse('com.esnaftavar.app://login-callback/'),
          appUri: Uri.base,
          isWeb: false,
          contract: production,
          exchangeCode: (_) async {
            exchangeCount++;
            return true;
          },
        );

        expect(status, EmailConfirmationCallbackStatus.invalid);
        expect(exchangeCount, 0);
      },
    );

    test('Production ignores Development and recovery callbacks', () async {
      var exchangeCount = 0;

      for (final callback in [
        Uri.parse('io.supabase.tstore://login-callback/?code=development-code'),
        Uri.parse(
          'com.esnaftavar.app://login-callback/'
          '?auth_action=password_recovery&code=recovery-code',
        ),
      ]) {
        expect(
          await SupabaseService.resolveEmailConfirmationCallback(
            uri: callback,
            appUri: Uri.base,
            isWeb: false,
            contract: production,
            exchangeCode: (_) async {
              exchangeCount++;
              return true;
            },
          ),
          isNull,
        );
      }

      expect(exchangeCount, 0);
    });

    test(
      'missing local PKCE verifier falls back to confirmed login safely',
      () {
        expect(
          SupabaseService.emailConfirmationStatusForExchangeError(
            'PKCE code verifier not found in local storage',
          ),
          EmailConfirmationCallbackStatus.confirmedWithoutSession,
        );
        expect(
          SupabaseService.emailConfirmationStatusForExchangeError(
            'invalid authorization code',
          ),
          EmailConfirmationCallbackStatus.invalid,
        );
      },
    );
  });
}
