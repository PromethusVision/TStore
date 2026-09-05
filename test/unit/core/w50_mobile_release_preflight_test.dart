import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/production_release_preflight.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

void main() {
  Map<String, String> manifest() => {
    SupabaseConfig.productionUrlDartDefine:
        'https://abcdefghijklmnopqrst.supabase.co',
    SupabaseConfig.productionAnonKeyDartDefine:
        'sb_publishable_public_client_123456',
    ProductionReleasePreflight.productionProjectRefField:
        'abcdefghijklmnopqrst',
    ProductionReleasePreflight.authSiteUrlField:
        ProductionReleasePreflight.canonicalMobileCallback,
    ProductionReleasePreflight.authWebRedirectUrlField: '',
    ProductionReleasePreflight.authMobileCallbackUrlField:
        ProductionReleasePreflight.canonicalMobileCallback,
  };

  void validate(Map<String, String> values) {
    ProductionReleasePreflight.validate(
      mode: ProductionReleasePreflightMode.release,
      values: values,
      target: ProductionReleasePreflight.productionEntrypoint,
    );
  }

  test('owner-final mobile Site URL needs no invented web destination', () {
    expect(() => validate(manifest()), returnsNormally);
  });

  test('mobile-only mode rejects a mixed web destination', () {
    final values = manifest()
      ..[ProductionReleasePreflight.authWebRedirectUrlField] =
          'https://app.esnaftavar.com/?auth_action=password_recovery';
    expect(
      () => validate(values),
      throwsA(isA<ProductionReleasePreflightException>()),
    );
  });

  for (final site in [
    'io.supabase.tstore://login-callback/',
    'com.esnaftavar.app://login-callback',
    'com.esnaftavar.app://login-callback/?code=untrusted',
    'com.esnaftavar.app://login-callback/other',
    'com.esnaftavar.app://other/',
    'com.esnaftavar.app://login-callback/#fragment',
  ]) {
    test('mobile Site URL rejects noncanonical variant: $site', () {
      final values = manifest()
        ..[ProductionReleasePreflight.authSiteUrlField] = site;
      expect(
        () => validate(values),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });
  }

  test('mobile mode still requires the complete explicit manifest', () {
    for (final field in ProductionReleasePreflight.requiredFields) {
      expect(
        () => validate(manifest()..remove(field)),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    }
  });

  test(
    'mobile mode still rejects Development config before Auth decisions',
    () {
      final values = manifest()
        ..[SupabaseConfig.productionUrlDartDefine] =
            'https://${SupabaseConfig.developmentProjectRef}.supabase.co'
        ..[ProductionReleasePreflight.productionProjectRefField] =
            SupabaseConfig.developmentProjectRef;
      expect(
        () => validate(values),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    },
  );

  test('mobile mode still rejects synthetic compile-only credentials', () {
    final values = manifest()
      ..[SupabaseConfig.productionUrlDartDefine] =
          ProductionReleasePreflight.compileContractSupabaseUrl
      ..[SupabaseConfig.productionAnonKeyDartDefine] =
          ProductionReleasePreflight.compileContractPublishableKey
      ..[ProductionReleasePreflight.productionProjectRefField] =
          ProductionReleasePreflight.compileContractProjectRef;
    expect(
      () => validate(values),
      throwsA(isA<ProductionReleasePreflightException>()),
    );
  });

  test('mobile mode does not relax the environment-owned callback', () {
    final values = manifest()
      ..[ProductionReleasePreflight.authMobileCallbackUrlField] =
          'io.supabase.tstore://login-callback/';
    expect(
      () => validate(values),
      throwsA(isA<ProductionReleasePreflightException>()),
    );
  });
}
