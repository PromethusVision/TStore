import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/auth_callback_contract.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/merchant/runtime/merchant_pilot_config.dart';

Map<String, String> pilotValues() => {
  'MERCHANT_PILOT_ENABLED': 'true',
  'MERCHANT_PILOT_URL': 'https://tnipyxnvhgelwdpykyez.supabase.co',
  'MERCHANT_PILOT_ANON_KEY': 'sb_publishable_syntheticPilotOnly12345',
};
String jwt(Map<String, Object?> payload) =>
    'e30.${base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '')}.signature';
void main() {
  test(
    'pilot is nonproduction, with a distinct callback and install identity',
    () {
      final config = MerchantPilotConfig.fromValues(pilotValues());
      expect(config.backend.environment, AppEnvironment.development);
      final callback = AuthCallbackContract.merchantPilot();
      expect(
        callback.mobileCallbackUri.scheme,
        MerchantPilotConfig.applicationId,
      );
      expect(
        callback.emailRedirectFor(
          appUri: Uri(),
          isWeb: false,
          action: AuthEmailRedirectAction.passwordRecovery,
        ),
        'com.esnaftavar.app.merchant.pilot://login-callback/?auth_action=password_recovery',
      );
    },
  );
  for (final field in pilotValues().keys) {
    test('missing $field fails closed', () {
      expect(
        () => MerchantPilotConfig.fromValues(pilotValues()..remove(field)),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });
  }
  for (final url in [
    'https://mefhfvrgkwciubeajjeb.supabase.co',
    'http://localhost:54321',
    'https://tnipyxnvhgelwdpykyez.supabase.co.evil.invalid',
    'https://tnipyxnvhgelwdpykyez.supabase.co/',
    'https://tnipyxnvhgelwdpykyez.supabase.co?project=pilot',
    'https://attacker@tnipyxnvhgelwdpykyez.supabase.co',
    'https://another.supabase.co',
  ]) {
    test('reject wrong or ambiguous endpoint $url', () {
      expect(
        () => MerchantPilotConfig.fromValues(
          pilotValues()..['MERCHANT_PILOT_URL'] = url,
        ),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });
  }
  for (final flag in MerchantPilotConfig.forbiddenCapabilities) {
    test('$flag cannot activate in this pilot increment', () {
      expect(
        () => MerchantPilotConfig.fromValues(pilotValues()..[flag] = 'true'),
        throwsA(isA<SupabaseConfigurationException>()),
      );
      expect(
        MerchantPilotConfig.fromValues(pilotValues()..[flag] = 'false'),
        isNotNull,
      );
    });
  }
  for (final key in [
    'SUPABASE_PRODUCTION_URL',
    'SUPABASE_DEVELOPMENT_URL',
    'NEW_PILOT_CAPABILITY',
  ]) {
    test('mixed or unrecognized config $key is rejected', () {
      expect(
        () => MerchantPilotConfig.fromValues(pilotValues()..[key] = 'true'),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });
  }
  for (final key in [
    'sb_secret_doNotPrintThisValue12345',
    'REPLACE_WITH_CLIENT_KEY',
    jwt({'role': 'service_role', 'ref': SupabaseConfig.developmentProjectRef}),
    jwt({'role': 'anon', 'ref': 'wrong-project'}),
    jwt({'role': 'anon'}),
  ]) {
    test('unsafe/mismatched key is rejected without exposing it', () {
      try {
        MerchantPilotConfig.fromValues(
          pilotValues()..['MERCHANT_PILOT_ANON_KEY'] = key,
        );
        fail('accepted unsafe configuration');
      } on SupabaseConfigurationException catch (e) {
        expect(e.toString(), isNot(contains(key)));
      }
    });
  }
  test(
    'matching legacy anon key is accepted offline, without claiming remote proof',
    () {
      expect(
        MerchantPilotConfig.fromValues(
          pilotValues()
            ..['MERCHANT_PILOT_ANON_KEY'] = jwt({
              'role': 'anon',
              'ref': SupabaseConfig.developmentProjectRef,
            }),
        ),
        isNotNull,
      );
    },
  );
  for (final scheme in [
    'com.esnaftavar.app',
    'io.supabase.tstore',
    'com.esnaftavar.app.merchant.dev',
  ]) {
    test('Customer/local callback $scheme is rejected', () {
      expect(
        AuthCallbackContract.merchantPilot().acceptsPkceCallback(
          uri: Uri.parse('$scheme://login-callback/?code=synthetic'),
          appUri: Uri(),
          isWeb: false,
        ),
        isFalse,
      );
    });
  }
}
