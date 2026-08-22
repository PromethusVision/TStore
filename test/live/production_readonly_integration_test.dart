import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/main_production.dart' as production_entrypoint;

const _liveOptIn = 'RUN_PRODUCTION_READONLY_SMOKE';
const _runLive = bool.fromEnvironment(_liveOptIn);
const _expectedProjectRef = 'mefhfvrgkwciubeajjeb';
const _expectedUrl = 'https://$_expectedProjectRef.supabase.co';
const _expectedHost = '$_expectedProjectRef.supabase.co';
const _productionUrl = String.fromEnvironment(
  SupabaseConfig.productionUrlDartDefine,
);
const _productionAnonKey = String.fromEnvironment(
  SupabaseConfig.productionAnonKeyDartDefine,
);

const _readOnlyTableCounts = <String, int>{
  SupabaseTables.categories: 4,
  SupabaseTables.products: 20,
  SupabaseTables.shops: 57,
  SupabaseTables.banners: 0,
};

const _storageProbePaths = <String, String>{
  SupabaseConfig.productImagesBucket:
      'catalog/00000000-0000-0000-0000-000000000001/'
      'v20260816000000/e1-readonly-probe.webp',
  SupabaseConfig.categoryImagesBucket:
      'catalog/00000000-0000-0000-0000-000000000002/'
      'v20260816000000/e1-readonly-probe.webp',
  SupabaseConfig.bannerImagesBucket:
      'catalog/00000000-0000-0000-0000-000000000003/'
      'v20260816000000/e1-readonly-probe.webp',
};

void main() {
  group('Production read-only smoke safety gate', () {
    test('requires explicit opt-in', () {
      expect(
        () => _requireProductionConfig(
          enabled: false,
          supabaseUrl: '',
          supabaseAnonKey: '',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects Development and every non-canonical Production URL', () {
      for (final url in const [
        'https://${SupabaseConfig.developmentProjectRef}.supabase.co',
        'https://abcdefghijklmnopqrst.supabase.co',
      ]) {
        expect(
          () => _requireProductionConfig(
            enabled: true,
            supabaseUrl: url,
            supabaseAnonKey: 'sb_publishable_readonly_contract_key',
          ),
          throwsA(
            anyOf(isA<SupabaseConfigurationException>(), isA<StateError>()),
          ),
          reason: url,
        );
      }
    });

    test('uses the production entrypoint and frozen public read surfaces', () {
      final config = _requireProductionConfig(
        enabled: true,
        supabaseUrl: _expectedUrl,
        supabaseAnonKey: 'sb_publishable_readonly_contract_key',
      );

      expect(production_entrypoint.appEnvironment, AppEnvironment.production);
      expect(config.environment, AppEnvironment.production);
      expect(config.supabaseUrl, _expectedUrl);
      expect(_readOnlyTableCounts, const {
        'categories': 4,
        'products': 20,
        'shops': 57,
        'banners': 0,
      });
      expect(_storageProbePaths.keys, const [
        'product-images',
        'category-images',
        'banner-images',
      ]);
    });

    test('harness source contains no database, Auth, or Storage mutation', () {
      final source = File(
        'test/live/production_readonly_integration_test.dart',
      ).readAsStringSync();
      for (final verb in const [
        'insert',
        'update',
        'upsert',
        'delete',
        'post',
        'put',
        'patch',
        'rpc',
        'invoke',
        'signUp',
        'signIn',
        'signInWithPassword',
        'signInWithOAuth',
        'signOut',
        'resend',
        'verifyOTP',
        'updateUser',
        'resetPasswordForEmail',
        'upload',
        'uploadBinary',
        'updateBinary',
        'move',
        'copy',
        'remove',
      ]) {
        expect(source, isNot(contains('.$verb(')), reason: verb);
      }
    });
  });

  test(
    'anonymous Production client initializes and sees canonical demo reads',
    () async {
      final config = _requireProductionConfig(
        enabled: _runLive,
        supabaseUrl: _productionUrl,
        supabaseAnonKey: _productionAnonKey,
      );
      final client = SupabaseClient(
        config.supabaseUrl,
        config.supabaseAnonKey,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.pkce),
      );
      addTearDown(client.dispose);

      expect(client.auth.currentSession, isNull);
      expect(client.auth.currentUser, isNull);

      for (final entry in _readOnlyTableCounts.entries) {
        final rows = await client.from(entry.key).select('id');
        expect(
          rows,
          hasLength(entry.value),
          reason: '${entry.key} must match the canonical demo baseline.',
        );
      }

      for (final entry in _storageProbePaths.entries) {
        final bucket = client.storage.from(entry.key);
        final listedObjects = await bucket.list(
          searchOptions: const SearchOptions(limit: 1),
        );
        expect(
          listedObjects,
          isEmpty,
          reason: '${entry.key} must expose no client-visible object listing.',
        );

        final publicUrl = bucket.getPublicUrl(entry.value);
        final publicUri = Uri.parse(publicUrl);
        expect(publicUri.scheme, 'https');
        expect(publicUri.host, _expectedHost);
        expect(
          publicUri.path,
          '/storage/v1/object/public/${entry.key}/${entry.value}',
        );

        final response = await http.get(
          publicUri,
          headers: {'apikey': config.supabaseAnonKey},
        );
        expect(
          response.statusCode,
          anyOf(400, 404),
          reason:
              '${entry.key} probe must remain a non-existent public object.',
        );
      }
    },
    skip: _runLive
        ? false
        : 'Production read-only smoke requires $_liveOptIn=true.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

SupabaseConfig _requireProductionConfig({
  required bool enabled,
  required String supabaseUrl,
  required String supabaseAnonKey,
}) {
  if (!enabled) {
    throw StateError(
      'Production read-only smoke requires explicit $_liveOptIn opt-in.',
    );
  }

  final config = production_entrypoint.createSupabaseConfig(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  final uri = Uri.parse(config.supabaseUrl);
  if (config.environment != AppEnvironment.production ||
      config.supabaseUrl != _expectedUrl ||
      uri.host != _expectedHost ||
      uri.host.contains(SupabaseConfig.developmentProjectRef)) {
    throw StateError(
      'Read-only smoke is locked to the canonical EsnaftaVar Production ref.',
    );
  }
  return config;
}
