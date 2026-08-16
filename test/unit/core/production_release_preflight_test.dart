import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/production_release_preflight.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_service.dart';

void main() {
  const safePublishableKey = 'sb_publishable_public_client_123456';
  const serviceRoleJwt =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJyb2xlIjoic2VydmljZV9yb2xlIn0.'
      'server-signature';

  Map<String, String> validReleaseManifest() => {
    SupabaseConfig.productionUrlDartDefine:
        'https://abcdefghijklmnopqrst.supabase.co',
    SupabaseConfig.productionAnonKeyDartDefine: safePublishableKey,
    ProductionReleasePreflight.productionProjectRefField:
        'abcdefghijklmnopqrst',
    ProductionReleasePreflight.authSiteUrlField: 'https://app.esnaftavar.com/',
    ProductionReleasePreflight.authWebRedirectUrlField:
        'https://app.esnaftavar.com/?auth_action=password_recovery',
    ProductionReleasePreflight.authMobileCallbackUrlField:
        ProductionReleasePreflight.canonicalMobileCallback,
  };

  void validateRelease(Map<String, String> values) {
    ProductionReleasePreflight.validate(
      mode: ProductionReleasePreflightMode.release,
      values: values,
      target: ProductionReleasePreflight.productionEntrypoint,
    );
  }

  group('Production release config', () {
    test('valid synthetic production structure passes', () {
      expect(() => validateRelease(validReleaseManifest()), returnsNormally);
    });

    test('missing URL, key, and project ref fail closed', () {
      for (final field in const [
        SupabaseConfig.productionUrlDartDefine,
        SupabaseConfig.productionAnonKeyDartDefine,
        ProductionReleasePreflight.productionProjectRefField,
      ]) {
        final values = validReleaseManifest()..remove(field);
        expect(
          () => validateRelease(values),
          throwsA(isA<ProductionReleasePreflightException>()),
        );
      }
    });

    test('Development project ref is rejected in both ref and URL', () {
      final values = validReleaseManifest()
        ..[ProductionReleasePreflight.productionProjectRefField] =
            SupabaseConfig.developmentProjectRef
        ..[SupabaseConfig.productionUrlDartDefine] =
            'https://${SupabaseConfig.developmentProjectRef}.supabase.co';

      expect(
        () => validateRelease(values),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });

    test('localhost, malformed, example, and dummy URLs are rejected', () {
      for (final url in const [
        'https://localhost:54321',
        'not-a-url',
        'https://example.supabase.co',
        'https://dummy-project.supabase.co',
      ]) {
        final values = validReleaseManifest()
          ..[SupabaseConfig.productionUrlDartDefine] = url;
        expect(
          () => validateRelease(values),
          throwsA(isA<SupabaseConfigurationException>()),
          reason: url,
        );
      }
    });

    test('project URL must match the declared Production ref', () {
      final values = validReleaseManifest()
        ..[SupabaseConfig.productionUrlDartDefine] =
            'https://zyxwvutsrqponmlkjihg.supabase.co';

      expect(
        () => validateRelease(values),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });

    test(
      'server/service-role credential styles are rejected without leaks',
      () {
        for (final key in const [
          'sb_secret_server_only_credential',
          serviceRoleJwt,
        ]) {
          final values = validReleaseManifest()
            ..[SupabaseConfig.productionAnonKeyDartDefine] = key;
          expect(
            () => validateRelease(values),
            throwsA(
              isA<SupabaseConfigurationException>().having(
                (error) => error.toString(),
                'safe error',
                isNot(contains(key)),
              ),
            ),
          );
        }
      },
    );

    test('normal client-safe publishable key passes', () {
      final values = validReleaseManifest()
        ..[SupabaseConfig.productionAnonKeyDartDefine] =
            'sb_publishable_another_public_client_key';

      expect(() => validateRelease(values), returnsNormally);
    });

    test('Development namespace and unexpected fields are rejected', () {
      final values = validReleaseManifest()
        ..[SupabaseConfig.developmentUrlDartDefine] =
            'https://${SupabaseConfig.developmentProjectRef}.supabase.co';

      expect(
        () => validateRelease(values),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });

    test('only the Production entrypoint is accepted', () {
      expect(
        () => ProductionReleasePreflight.validate(
          mode: ProductionReleasePreflightMode.release,
          values: validReleaseManifest(),
          target: 'lib/main_development.dart',
        ),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });
  });

  group('Auth redirect decisions', () {
    test('web redirect must be the exact recovery URL on Site URL', () {
      for (final redirect in const [
        'https://other.esnaftavar.com/?auth_action=password_recovery',
        'https://app.esnaftavar.com/callback',
        'https://app.esnaftavar.com/?auth_action=wrong',
      ]) {
        final values = validReleaseManifest()
          ..[ProductionReleasePreflight.authWebRedirectUrlField] = redirect;
        expect(
          () => validateRelease(values),
          throwsA(isA<ProductionReleasePreflightException>()),
        );
      }
    });

    test('Site URL rejects localhost and non-production placeholders', () {
      for (final siteUrl in const [
        'https://localhost/',
        'https://app.example/',
        'https://example.com/',
        'https://app.invalid/',
        'https://app.test/',
        'https://dummy.esnaftavar.com/',
        'https://placeholder.esnaftavar.com/',
        'https://your-app.esnaftavar.com/',
        'https://replace-me.esnaftavar.com/',
        'https://changeme.esnaftavar.com/',
      ]) {
        final values = validReleaseManifest()
          ..[ProductionReleasePreflight.authSiteUrlField] = siteUrl;
        expect(
          () => validateRelease(values),
          throwsA(isA<ProductionReleasePreflightException>()),
        );
      }
    });

    test('mobile callback must match the registered app callback', () {
      final values = validReleaseManifest()
        ..[ProductionReleasePreflight.authMobileCallbackUrlField] =
            'io.supabase.development://login-callback/';

      expect(
        () => validateRelease(values),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });

    test('preflight web redirect stays aligned with runtime recovery URL', () {
      const siteUrl = 'https://app.esnaftavar.com/';
      expect(
        ProductionReleasePreflight.expectedWebRecoveryRedirect(siteUrl),
        SupabaseService.passwordRecoveryRedirectFor(
          appUri: Uri.parse(siteUrl),
          isWeb: true,
        ),
      );
    });
  });

  group('compile-contract isolation', () {
    test('canonical synthetic fixture passes only contract mode', () {
      final fixture = Map<String, String>.from(
        jsonDecode(
              File('tool/production_compile_contract.json').readAsStringSync(),
            )
            as Map<String, dynamic>,
      );

      expect(
        () => ProductionReleasePreflight.validate(
          mode: ProductionReleasePreflightMode.compileContract,
          values: fixture,
          target: ProductionReleasePreflight.productionEntrypoint,
        ),
        returnsNormally,
      );
      expect(
        () => validateRelease(fixture),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });

    test('release example is structurally complete but cannot pass', () {
      final template = Map<String, String>.from(
        jsonDecode(
              File(
                'tool/production_release_config.example.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>,
      );

      expect(
        template.keys,
        unorderedEquals(ProductionReleasePreflight.requiredFields),
      );
      expect(
        () => validateRelease(template),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });
  });
}
