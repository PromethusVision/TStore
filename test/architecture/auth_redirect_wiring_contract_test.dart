import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth redirect wiring contract', () {
    final serviceSource = File(
      'lib/core/supabase/supabase_service.dart',
    ).readAsStringSync();

    test('Supabase broad automatic URI detection stays disabled', () {
      expect(serviceSource, contains('detectSessionInUri: false'));
      expect(serviceSource, contains('exchangeValidatedPkceCallback('));
    });

    test('signup and resend pass an explicit email redirect', () {
      expect(
        RegExp(
          r'client\.auth\.signUp\([\s\S]*?emailRedirectTo:\s*'
          r'_emailConfirmationRedirect,[\s\S]*?\);',
        ).hasMatch(serviceSource),
        isTrue,
      );
      expect(
        RegExp(
          r'client\.auth\.resend\([\s\S]*?emailRedirectTo:\s*'
          r'_emailConfirmationRedirect,[\s\S]*?\);',
        ).hasMatch(serviceSource),
        isTrue,
      );
    });

    test('recovery passes the central action-specific redirect', () {
      expect(serviceSource, contains('passwordRecoveryRedirectFor('));
      expect(
        serviceSource,
        contains('resetPasswordForEmail(email, redirectTo: redirectTo)'),
      );
    });

    test('Production runtime service has no hard-coded legacy callback', () {
      expect(serviceSource, isNot(contains('io.supabase.tstore')));
    });
  });
}
