import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/production_release_preflight.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

void main() {
  Map<String, String> template() => Map<String, String>.from(
    jsonDecode(
          File(
            'tool/production_mobile_release_config.example.json',
          ).readAsStringSync(),
        )
        as Map,
  );

  void validate(Map<String, String> values) =>
      ProductionReleasePreflight.validate(
        mode: ProductionReleasePreflightMode.release,
        values: values,
        target: ProductionReleasePreflight.productionEntrypoint,
      );

  test(
    'owner-selected endpoint is explicit but template cannot be released',
    () {
      final values = template();
      expect(values['PRODUCTION_PROJECT_REF'], 'mefhfvrgkwciubeajjeb');
      expect(
        values[SupabaseConfig.productionUrlDartDefine],
        'https://mefhfvrgkwciubeajjeb.supabase.co',
      );
      expect(
        () => validate(values),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    },
  );

  test(
    'complete mobile contract accepts client-safe input structurally only',
    () {
      final values = template()
        ..[SupabaseConfig.productionAnonKeyDartDefine] =
            'sb_publishable_public_client_123456';
      expect(() => validate(values), returnsNormally);
    },
  );

  for (final field in [
    'SUPABASE_DEVELOPMENT_URL',
    'ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY',
    'REWARD_RUNTIME_ENABLED',
    'FIXTURE_MODE',
    'VERBOSE_LOGGING',
  ]) {
    test('release manifest rejects injected $field', () {
      final values = template()
        ..[SupabaseConfig.productionAnonKeyDartDefine] =
            'sb_publishable_public_client_123456'
        ..[field] = 'true';
      expect(
        () => validate(values),
        throwsA(isA<ProductionReleasePreflightException>()),
      );
    });
  }
}
