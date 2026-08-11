import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/main_development.dart' as development_entrypoint;
import 'package:t_store/main_production.dart' as production_entrypoint;

void main() {
  const developmentUrl = 'https://development-test.supabase.co';
  const productionUrl = 'https://production-test.supabase.co';
  const publishableKey = 'sb_publishable_public_test_key';
  const legacyAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJyb2xlIjoiYW5vbiJ9.'
      'test-signature';
  const serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJyb2xlIjoic2VydmljZV9yb2xlIn0.'
      'test-signature';

  group('entrypoint environment selection', () {
    test('development entrypoint selects development configuration', () {
      final config = development_entrypoint.createSupabaseConfig(
        supabaseUrl: developmentUrl,
        supabaseAnonKey: publishableKey,
      );

      expect(development_entrypoint.appEnvironment, AppEnvironment.development);
      expect(
        development_entrypoint.supabaseUrlDartDefine,
        SupabaseConfig.developmentUrlDartDefine,
      );
      expect(
        development_entrypoint.supabaseAnonKeyDartDefine,
        SupabaseConfig.developmentAnonKeyDartDefine,
      );
      expect(config.environment, AppEnvironment.development);
    });

    test('production entrypoint selects production configuration', () {
      final config = production_entrypoint.createSupabaseConfig(
        supabaseUrl: productionUrl,
        supabaseAnonKey: legacyAnonKey,
      );

      expect(production_entrypoint.appEnvironment, AppEnvironment.production);
      expect(
        production_entrypoint.supabaseUrlDartDefine,
        SupabaseConfig.productionUrlDartDefine,
      );
      expect(
        production_entrypoint.supabaseAnonKeyDartDefine,
        SupabaseConfig.productionAnonKeyDartDefine,
      );
      expect(config.environment, AppEnvironment.production);
    });
  });

  group('configuration failures', () {
    test('missing values fail safely without exposing a value', () {
      expect(
        () => SupabaseConfig.fromEnvironmentValues(
          AppEnvironment.production,
          const {},
        ),
        throwsA(
          isA<SupabaseConfigurationException>()
              .having(
                (error) => error.toString(),
                'message',
                contains(SupabaseConfig.productionUrlDartDefine),
              )
              .having(
                (error) => error.toString(),
                'safe message',
                isNot(contains('null')),
              ),
        ),
      );
    });

    test('development never falls back to production values', () {
      expect(
        () => SupabaseConfig.fromEnvironmentValues(
          AppEnvironment.development,
          const {
            SupabaseConfig.productionUrlDartDefine: productionUrl,
            SupabaseConfig.productionAnonKeyDartDefine: publishableKey,
          },
        ),
        throwsA(
          isA<SupabaseConfigurationException>().having(
            (error) => error.toString(),
            'message',
            contains(SupabaseConfig.developmentUrlDartDefine),
          ),
        ),
      );
    });

    test('production never falls back to development values', () {
      expect(
        () => SupabaseConfig.fromEnvironmentValues(
          AppEnvironment.production,
          const {
            SupabaseConfig.developmentUrlDartDefine: developmentUrl,
            SupabaseConfig.developmentAnonKeyDartDefine: publishableKey,
          },
        ),
        throwsA(isA<SupabaseConfigurationException>()),
      );
    });

    test('production rejects insecure or local URLs', () {
      for (final url in const [
        'http://production-test.supabase.co',
        'https://localhost:54321',
      ]) {
        expect(
          () => SupabaseConfig.forEnvironment(
            environment: AppEnvironment.production,
            supabaseUrl: url,
            supabaseAnonKey: publishableKey,
          ),
          throwsA(isA<SupabaseConfigurationException>()),
        );
      }
    });

    test('local HTTP is allowed only for development', () {
      final config = SupabaseConfig.forEnvironment(
        environment: AppEnvironment.development,
        supabaseUrl: 'http://127.0.0.1:54321',
        supabaseAnonKey: publishableKey,
      );

      expect(config.supabaseUrl, 'http://127.0.0.1:54321');
    });
  });

  group('client credential safety', () {
    test('service-role JWT and secret key formats are rejected', () {
      for (final key in const [serviceRoleKey, 'sb_secret_server_test_key']) {
        expect(
          () => SupabaseConfig.forEnvironment(
            environment: AppEnvironment.development,
            supabaseUrl: developmentUrl,
            supabaseAnonKey: key,
          ),
          throwsA(
            isA<SupabaseConfigurationException>().having(
              (error) => error.toString(),
              'safe message',
              isNot(contains(key)),
            ),
          ),
        );
      }
    });

    test('the example contract contains only client configuration fields', () {
      final assignedNames = File('.env.example')
          .readAsLinesSync()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .map((line) => line.split('=').first)
          .toList();

      expect(
        assignedNames,
        unorderedEquals(const [
          SupabaseConfig.developmentUrlDartDefine,
          SupabaseConfig.developmentAnonKeyDartDefine,
          SupabaseConfig.productionUrlDartDefine,
          SupabaseConfig.productionAnonKeyDartDefine,
        ]),
      );
    });

    test('dotenv is not used or bundled by either entrypoint', () {
      final entrypointSources = [
        File('lib/main_development.dart').readAsStringSync(),
        File('lib/main_production.dart').readAsStringSync(),
      ].join('\n');
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(entrypointSources, isNot(contains('flutter_dotenv')));
      expect(entrypointSources, isNot(contains("fileName: '.env'")));
      expect(
        RegExp(r'^\s*-\s*\.env\s*$', multiLine: true).hasMatch(pubspec),
        isFalse,
      );
    });
  });
}
