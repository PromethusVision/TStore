import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';

const _liveOptIn = 'RUN_W6A2_LIVE_PRODUCT_REVIEW';
const _expectedProjectRef = 'tnipyxnvhgelwdpykyez';
const _expectedUrl = 'https://$_expectedProjectRef.supabase.co';
const _runLive = bool.fromEnvironment(_liveOptIn);
const _developmentUrl = String.fromEnvironment(
  SupabaseConfig.developmentUrlDartDefine,
);
const _developmentAnonKey = String.fromEnvironment(
  SupabaseConfig.developmentAnonKeyDartDefine,
);

void main() {
  group('Wave 6 Agent 2 live review safety gate', () {
    test('explicit opt-in gerektirir', () {
      expect(
        () => _requireDevelopmentConfig(
          enabled: false,
          supabaseUrl: '',
          supabaseAnonKey: '',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('yalnız atanmış Development ref kabul edilir', () {
      expect(
        () => _requireDevelopmentConfig(
          enabled: true,
          supabaseUrl: 'https://production-like.supabase.co',
          supabaseAnonKey: 'sb_publishable_contract_test_value',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('EsnaftaVar Development'),
          ),
        ),
      );
    });
  });

  test(
    'normal Auth client canonical review read ve unverified rejection görür',
    () async {
      final config = _requireDevelopmentConfig(
        enabled: _runLive,
        supabaseUrl: _developmentUrl,
        supabaseAnonKey: _developmentAnonKey,
      );
      final client = SupabaseClient(
        config.supabaseUrl,
        config.supabaseAnonKey,
        authOptions: const AuthClientOptions(
          autoRefreshToken: false,
          authFlowType: AuthFlowType.implicit,
        ),
      );
      final runId = _newRunId();
      var signedUp = false;

      addTearDown(() async {
        try {
          if (signedUp && client.auth.currentSession != null) {
            await client.rpc<void>('delete_current_customer_account');
          }
        } finally {
          await client.dispose();
        }
      });

      final auth = await client.auth.signUp(
        email: 'w6a2_review_$runId@example.com',
        password: 'W6a2!${runId}SafeReview',
        data: {
          'full_name': 'w6a2_review_customer',
          'phone': '+900000000000',
          'privacy_notice_acknowledged': true,
          'privacy_notice_version': LegalDocumentVersions.privacyNotice,
          'terms_of_use_accepted': true,
          'terms_of_use_version': LegalDocumentVersions.termsOfUse,
        },
      );
      signedUp = auth.user != null;
      expect(auth.session, isNotNull, reason: 'Normal Auth session required.');

      final products = await client
          .from('products')
          .select('id')
          .eq('is_active', true)
          .limit(1);
      expect(
        products,
        isNotEmpty,
        reason: 'Development needs one active product.',
      );
      final productId = products.single['id'] as String;

      final read = _jsonObject(
        await client.rpc<dynamic>(
          'get_product_reviews',
          params: {'p_product_id': productId, 'p_limit': 20, 'p_offset': 0},
        ),
      );
      expect(read['product_id'], productId);
      expect(read['average_rating'], isA<num>());
      expect(read['review_count'], isA<num>());
      expect(read['rating_distribution'], isA<Map>());
      expect(read['reviews'], isA<List>());

      final eligibility = _jsonObject(
        await client.rpc<dynamic>(
          'get_product_review_eligibility',
          params: {'p_product_id': productId},
        ),
      );
      expect(eligibility['product_id'], productId);
      expect(eligibility['eligible'], isFalse);
      expect(eligibility['can_submit'], isFalse);
      expect(eligibility['existing_review_id'], isNull);

      try {
        await client.rpc<dynamic>(
          'submit_product_review',
          params: {
            'p_product_id': productId,
            'p_rating': 5,
            'p_title': 'w6a2 live smoke',
            'p_comment': null,
          },
        );
        fail(
          'Unverified normal customer review submit unexpectedly succeeded.',
        );
      } on PostgrestException catch (error) {
        expect(error.code, '42501');
        expect(error.message, contains('[REVIEW_NOT_VERIFIED]'));
      }
    },
    skip: _runLive
        ? false
        : 'Requires $_liveOptIn=true and Development Dart defines.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

SupabaseConfig _requireDevelopmentConfig({
  required bool enabled,
  required String supabaseUrl,
  required String supabaseAnonKey,
}) {
  if (!enabled) {
    throw StateError(
      'Set $_liveOptIn=true explicitly to run this remote test.',
    );
  }
  final config = SupabaseConfig.forEnvironment(
    environment: AppEnvironment.development,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  final uri = Uri.parse(config.supabaseUrl);
  if (config.supabaseUrl != _expectedUrl ||
      uri.host != '$_expectedProjectRef.supabase.co') {
    throw StateError(
      'Live test must target only the assigned EsnaftaVar Development project.',
    );
  }
  return config;
}

Map<String, dynamic> _jsonObject(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.length == 1) return _jsonObject(value.single);
  throw FormatException('Expected one JSON object.');
}

String _newRunId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(0x7fffffff).toRadixString(16);
  return '${timestamp}_$random';
}
