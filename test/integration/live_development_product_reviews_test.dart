import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';

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
const _verifiedEmail = String.fromEnvironment('W6_LIVE_VERIFIED_EMAIL');
const _verifiedPassword = String.fromEnvironment('W6_LIVE_VERIFIED_PASSWORD');
const _unverifiedEmail = String.fromEnvironment('W6_LIVE_UNVERIFIED_EMAIL');
const _unverifiedPassword = String.fromEnvironment(
  'W6_LIVE_UNVERIFIED_PASSWORD',
);
const _productId = String.fromEnvironment('W6_LIVE_PRODUCT_ID');

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
    'normal Auth clients verified lifecycle ve unverified rejection görür',
    () async {
      final config = _requireDevelopmentConfig(
        enabled: _runLive,
        supabaseUrl: _developmentUrl,
        supabaseAnonKey: _developmentAnonKey,
      );
      final credentials = _requireLiveCredentials();
      final verifiedClient = _newClient(config);
      final unverifiedClient = _newClient(config);
      var verifiedSignedIn = false;
      var unverifiedSignedIn = false;
      String? reviewIdForCleanup;

      addTearDown(() async {
        try {
          if (reviewIdForCleanup != null &&
              verifiedClient.auth.currentSession != null) {
            await verifiedClient.rpc<dynamic>(
              'delete_product_review',
              params: {'p_review_id': reviewIdForCleanup},
            );
          }
          if (unverifiedSignedIn &&
              unverifiedClient.auth.currentSession != null) {
            await unverifiedClient.rpc<void>('delete_current_customer_account');
          }
          if (verifiedSignedIn && verifiedClient.auth.currentSession != null) {
            await verifiedClient.rpc<void>('delete_current_customer_account');
          }
        } finally {
          await unverifiedClient.dispose();
          await verifiedClient.dispose();
        }
      });

      final verifiedAuth = await verifiedClient.auth.signInWithPassword(
        email: credentials.verifiedEmail,
        password: credentials.verifiedPassword,
      );
      verifiedSignedIn = verifiedAuth.session != null;
      expect(
        verifiedAuth.session,
        isNotNull,
        reason: 'Verified normal customer Auth session required.',
      );

      final unverifiedAuth = await unverifiedClient.auth.signInWithPassword(
        email: credentials.unverifiedEmail,
        password: credentials.unverifiedPassword,
      );
      unverifiedSignedIn = unverifiedAuth.session != null;
      expect(
        unverifiedAuth.session,
        isNotNull,
        reason: 'Unverified normal customer Auth session required.',
      );

      final baseline = await _getReviews(verifiedClient, credentials.productId);
      final baselineCount = (baseline['review_count'] as num).toInt();
      final baselineDistribution = _jsonObject(baseline['rating_distribution']);

      final verifiedEligibility = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'get_product_review_eligibility',
          params: {'p_product_id': credentials.productId},
        ),
      );
      expect(verifiedEligibility['product_id'], credentials.productId);
      expect(verifiedEligibility['eligible'], isTrue);
      expect(verifiedEligibility['can_submit'], isTrue);
      expect(verifiedEligibility['existing_review_id'], isNull);
      expect(verifiedEligibility['verified_transaction_item_id'], isNotNull);
      expect(verifiedEligibility['verified_transaction_id'], isNotNull);

      final unverifiedEligibility = _jsonObject(
        await unverifiedClient.rpc<dynamic>(
          'get_product_review_eligibility',
          params: {'p_product_id': credentials.productId},
        ),
      );
      expect(unverifiedEligibility['eligible'], isFalse);
      expect(unverifiedEligibility['can_submit'], isFalse);
      expect(unverifiedEligibility['existing_review_id'], isNull);

      try {
        await unverifiedClient.rpc<dynamic>(
          'submit_product_review',
          params: {
            'p_product_id': credentials.productId,
            'p_rating': 5,
            'p_title': 'w6 live unverified rejection',
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

      final created = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'submit_product_review',
          params: {
            'p_product_id': credentials.productId,
            'p_rating': 5,
            'p_title': 'w6 live create',
            'p_comment': 'canonical create smoke',
          },
        ),
      );
      expect(created['created'], isTrue);
      final createdReview = _jsonObject(created['review']);
      final firstReviewId = createdReview['id'] as String;
      reviewIdForCleanup = firstReviewId;
      expect(createdReview['product_id'], credentials.productId);
      expect(createdReview['rating'], 5);
      expect(createdReview['is_verified_purchase'], isTrue);

      final duplicate = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'submit_product_review',
          params: {
            'p_product_id': credentials.productId,
            'p_rating': 1,
            'p_title': 'must not replace',
            'p_comment': null,
          },
        ),
      );
      expect(duplicate['created'], isFalse);
      final duplicateReview = _jsonObject(duplicate['review']);
      expect(duplicateReview['id'], firstReviewId);
      expect(duplicateReview['rating'], 5);
      expect(duplicateReview['title'], 'w6 live create');

      final afterDuplicateEligibility = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'get_product_review_eligibility',
          params: {'p_product_id': credentials.productId},
        ),
      );
      expect(afterDuplicateEligibility['eligible'], isTrue);
      expect(afterDuplicateEligibility['can_submit'], isFalse);
      expect(afterDuplicateEligibility['existing_review_id'], firstReviewId);

      final updated = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'update_product_review',
          params: {
            'p_review_id': firstReviewId,
            'p_rating': 4,
            'p_title': 'w6 live update',
            'p_comment': 'canonical update smoke',
          },
        ),
      );
      expect(updated['id'], firstReviewId);
      expect(updated['rating'], 4);
      expect(updated['title'], 'w6 live update');
      expect(updated['is_verified_purchase'], isTrue);

      final afterUpdate = await _getReviews(
        verifiedClient,
        credentials.productId,
      );
      expect(afterUpdate['review_count'], baselineCount + 1);
      final afterUpdateDistribution = _jsonObject(
        afterUpdate['rating_distribution'],
      );
      expect(
        afterUpdateDistribution['4'],
        (baselineDistribution['4'] as num).toInt() + 1,
      );
      final listedUpdated = _reviewById(afterUpdate, firstReviewId);
      expect(listedUpdated['rating'], 4);
      expect(listedUpdated['can_edit'], isTrue);
      expect(listedUpdated['is_verified_purchase'], isTrue);

      final deleted = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'delete_product_review',
          params: {'p_review_id': firstReviewId},
        ),
      );
      reviewIdForCleanup = null;
      expect(deleted['review_id'], firstReviewId);
      expect(deleted['deleted'], isTrue);

      final afterDeleteEligibility = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'get_product_review_eligibility',
          params: {'p_product_id': credentials.productId},
        ),
      );
      expect(afterDeleteEligibility['eligible'], isTrue);
      expect(afterDeleteEligibility['can_submit'], isTrue);
      expect(afterDeleteEligibility['existing_review_id'], isNull);
      final afterDelete = await _getReviews(
        verifiedClient,
        credentials.productId,
      );
      expect(afterDelete['review_count'], baselineCount);
      expect(
        _jsonObject(afterDelete['rating_distribution']),
        baselineDistribution,
      );

      final recreated = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'submit_product_review',
          params: {
            'p_product_id': credentials.productId,
            'p_rating': 3,
            'p_title': 'w6 live recreate',
            'p_comment': 'canonical recreate smoke',
          },
        ),
      );
      expect(recreated['created'], isTrue);
      final recreatedReview = _jsonObject(recreated['review']);
      final recreatedReviewId = recreatedReview['id'] as String;
      reviewIdForCleanup = recreatedReviewId;
      expect(recreatedReviewId, isNot(firstReviewId));
      expect(recreatedReview['rating'], 3);
      expect(recreatedReview['is_verified_purchase'], isTrue);

      final afterRecreate = await _getReviews(
        verifiedClient,
        credentials.productId,
      );
      expect(afterRecreate['review_count'], baselineCount + 1);
      final afterRecreateDistribution = _jsonObject(
        afterRecreate['rating_distribution'],
      );
      expect(
        afterRecreateDistribution['3'],
        (baselineDistribution['3'] as num).toInt() + 1,
      );
      expect(_reviewById(afterRecreate, recreatedReviewId)['rating'], 3);

      final finalDelete = _jsonObject(
        await verifiedClient.rpc<dynamic>(
          'delete_product_review',
          params: {'p_review_id': recreatedReviewId},
        ),
      );
      reviewIdForCleanup = null;
      expect(finalDelete['deleted'], isTrue);
      final finalRead = await _getReviews(
        verifiedClient,
        credentials.productId,
      );
      expect(finalRead['review_count'], baselineCount);
      expect(
        _jsonObject(finalRead['rating_distribution']),
        baselineDistribution,
      );
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

_LiveCredentials _requireLiveCredentials() {
  if (_verifiedEmail.isEmpty ||
      _verifiedPassword.isEmpty ||
      _unverifiedEmail.isEmpty ||
      _unverifiedPassword.isEmpty ||
      _productId.isEmpty) {
    throw StateError(
      'Complete ephemeral Wave 6 live fixture defines required.',
    );
  }
  if (!_verifiedEmail.contains('@') ||
      !_unverifiedEmail.contains('@') ||
      !RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      ).hasMatch(_productId)) {
    throw StateError('Wave 6 live fixture defines are malformed.');
  }
  return const _LiveCredentials(
    verifiedEmail: _verifiedEmail,
    verifiedPassword: _verifiedPassword,
    unverifiedEmail: _unverifiedEmail,
    unverifiedPassword: _unverifiedPassword,
    productId: _productId,
  );
}

SupabaseClient _newClient(SupabaseConfig config) {
  return SupabaseClient(
    config.supabaseUrl,
    config.supabaseAnonKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: false,
      authFlowType: AuthFlowType.implicit,
    ),
  );
}

Future<Map<String, dynamic>> _getReviews(
  SupabaseClient client,
  String productId,
) async {
  final response = _jsonObject(
    await client.rpc<dynamic>(
      'get_product_reviews',
      params: {'p_product_id': productId, 'p_limit': 50, 'p_offset': 0},
    ),
  );
  expect(response['product_id'], productId);
  expect(response['average_rating'], isA<num>());
  expect(response['review_count'], isA<num>());
  expect(response['rating_distribution'], isA<Map>());
  expect(response['reviews'], isA<List>());
  return response;
}

Map<String, dynamic> _reviewById(
  Map<String, dynamic> response,
  String reviewId,
) {
  final reviews = (response['reviews'] as List)
      .map(_jsonObject)
      .where((review) => review['id'] == reviewId)
      .toList();
  expect(reviews, hasLength(1));
  return reviews.single;
}

Map<String, dynamic> _jsonObject(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.length == 1) return _jsonObject(value.single);
  throw FormatException('Expected one JSON object.');
}

class _LiveCredentials {
  const _LiveCredentials({
    required this.verifiedEmail,
    required this.verifiedPassword,
    required this.unverifiedEmail,
    required this.unverifiedPassword,
    required this.productId,
  });

  final String verifiedEmail;
  final String verifiedPassword;
  final String unverifiedEmail;
  final String unverifiedPassword;
  final String productId;
}
