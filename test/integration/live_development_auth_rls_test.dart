import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';

const _liveOptInDartDefine = 'RUN_W4A1_LIVE_DEVELOPMENT_AUTH_RLS';
const _expectedDevelopmentProjectRef = 'tnipyxnvhgelwdpykyez';
const _expectedDevelopmentUrl =
    'https://$_expectedDevelopmentProjectRef.supabase.co';
const _runLive = bool.fromEnvironment(_liveOptInDartDefine);
const _developmentUrl = String.fromEnvironment(
  SupabaseConfig.developmentUrlDartDefine,
);
const _developmentAnonKey = String.fromEnvironment(
  SupabaseConfig.developmentAnonKeyDartDefine,
);
const _missingProductId = '00000000-0000-4000-8000-000000000001';

void main() {
  group('Wave 4 Agent 1 live development safety gate', () {
    test('requires an explicit live-test opt-in', () {
      expect(
        () => _requireLiveDevelopmentConfig(
          enabled: false,
          supabaseUrl: '',
          supabaseAnonKey: '',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(_liveOptInDartDefine),
          ),
        ),
      );
    });

    test('rejects every backend except the assigned development project', () {
      expect(
        () => _requireLiveDevelopmentConfig(
          enabled: true,
          supabaseUrl: 'https://not-the-assigned-project.supabase.co',
          supabaseAnonKey: 'sb_publishable_contract_test_value',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('assigned EsnaftaVar Development project'),
          ),
        ),
      );
    });
  });

  test(
    'normal Auth clients enforce live development customer ownership and RLS',
    () async {
      final config = _requireLiveDevelopmentConfig(
        enabled: _runLive,
        supabaseUrl: _developmentUrl,
        supabaseAnonKey: _developmentAnonKey,
      );
      final runId = _newRunId();
      final clientA = _newClient(config);
      final clientB = _newClient(config);
      final anonClient = _newClient(config);

      addTearDown(() async {
        final cleanupFailures = <String>[];
        await _deleteOwnTestAccount(clientB, 'Customer B', cleanupFailures);
        await _deleteOwnTestAccount(clientA, 'Customer A', cleanupFailures);
        await anonClient.dispose();
        if (cleanupFailures.isNotEmpty) {
          fail(
            'Normal customer account cleanup failed for '
            '${cleanupFailures.join(', ')}. No privileged cleanup was attempted.',
          );
        }
      });

      final password = 'W4a1!${runId}SafeCustomer';
      AuthResponse? authA;
      AuthResponse? authB;
      Object? authAError;
      Object? authBError;
      try {
        authA = await _signUpCustomer(
          clientA,
          email: 'w4a1_${runId}_a@example.com',
          password: password,
          label: 'A',
        );
      } catch (error) {
        authAError = error;
      }
      try {
        authB = await _signUpCustomer(
          clientB,
          email: 'w4a1_${runId}_b@example.com',
          password: password,
          label: 'B',
        );
      } catch (error) {
        authBError = error;
      }

      if (authAError != null || authBError != null) {
        fail(
          'LIVE_AUTH_SIGNUP_BLOCKER: normal signup failed. '
          'Customer A=${_safeAuthFailure(authAError)}, '
          'Customer B=${_safeAuthFailure(authBError)}. Auth settings were not '
          'changed and no privileged user operation was attempted.',
        );
      }

      final responseA = authA!;
      final responseB = authB!;
      if (responseA.session == null || responseB.session == null) {
        fail(
          'LIVE_AUTH_CONFIRMATION_BLOCKER: normal signup did not return '
          'authenticated sessions for both customers. Auth settings were not '
          'changed and no privileged user operation was attempted.',
        );
      }

      final userA = responseA.user!;
      final userB = responseB.user!;
      expect(userA.id, isNot(userB.id));

      await _verifySignupProfileAndConsents(clientA, userA.id, 'A');
      await _verifySignupProfileAndConsents(clientB, userB.id, 'B');
      await _verifyProfileIsolation(
        clientA: clientA,
        clientB: clientB,
        anonClient: anonClient,
        userAId: userA.id,
        runId: runId,
      );
      await _verifySavedLocations(
        clientA: clientA,
        clientB: clientB,
        anonClient: anonClient,
        userAId: userA.id,
        runId: runId,
      );
      await _verifyAddresses(
        clientA: clientA,
        clientB: clientB,
        anonClient: anonClient,
        userAId: userA.id,
        runId: runId,
      );
      await _verifyWishlist(
        clientA: clientA,
        clientB: clientB,
        anonClient: anonClient,
        userAId: userA.id,
      );
    },
    skip: _runLive
        ? false
        : 'Requires $_liveOptInDartDefine=true and development Dart defines.',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

String _safeAuthFailure(Object? error) {
  if (error == null) return 'none';
  if (error is AuthException) {
    return '${error.statusCode ?? 'unknown-status'}/'
        '${error.code ?? 'unknown-code'}';
  }
  return error.runtimeType.toString();
}

SupabaseConfig _requireLiveDevelopmentConfig({
  required bool enabled,
  required String supabaseUrl,
  required String supabaseAnonKey,
}) {
  if (!enabled) {
    throw StateError(
      'Set $_liveOptInDartDefine=true explicitly to run this remote test.',
    );
  }

  final config = SupabaseConfig.forEnvironment(
    environment: AppEnvironment.development,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  final uri = Uri.parse(config.supabaseUrl);
  if (config.supabaseUrl != _expectedDevelopmentUrl ||
      uri.host != '$_expectedDevelopmentProjectRef.supabase.co') {
    throw StateError(
      'Live test configuration must target only the assigned EsnaftaVar '
      'Development project.',
    );
  }
  return config;
}

SupabaseClient _newClient(SupabaseConfig config) => SupabaseClient(
  config.supabaseUrl,
  config.supabaseAnonKey,
  authOptions: const AuthClientOptions(
    autoRefreshToken: false,
    authFlowType: AuthFlowType.implicit,
  ),
);

String _newRunId() {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final random = Random.secure().nextInt(0x7fffffff).toRadixString(16);
  return '${timestamp}_$random';
}

Future<AuthResponse> _signUpCustomer(
  SupabaseClient client, {
  required String email,
  required String password,
  required String label,
}) async {
  final response = await client.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': 'w4a1_customer_$label',
      'phone': '+900000000000',
      'privacy_notice_acknowledged': true,
      'privacy_notice_version': LegalDocumentVersions.privacyNotice,
      'terms_of_use_accepted': true,
      'terms_of_use_version': LegalDocumentVersions.termsOfUse,
    },
  );
  expect(response.user, isNotNull, reason: 'Customer $label signup failed.');
  return response;
}

Future<void> _verifySignupProfileAndConsents(
  SupabaseClient client,
  String userId,
  String label,
) async {
  final profile = await client
      .from('profiles')
      .select('id, email, full_name, phone, role')
      .eq('id', userId)
      .single();
  expect(profile['id'], userId);
  expect(profile['role'], 'customer');
  expect(profile['full_name'], 'w4a1_customer_$label');

  final consents = await client
      .from('legal_consents')
      .select('user_id, document_type, document_version, source')
      .eq('user_id', userId)
      .order('document_type');
  expect(consents, hasLength(2));
  expect(consents.every((row) => row['user_id'] == userId), isTrue);
  expect(consents.every((row) => row['source'] == 'customer_signup'), isTrue);
  expect(consents.map((row) => row['document_type']).toSet(), {
    'privacy_notice_acknowledged',
    'terms_of_use_accepted',
  });
  expect(consents.map((row) => row['document_version']).toSet(), {
    LegalDocumentVersions.privacyNotice,
  });
  expect(
    LegalDocumentVersions.privacyNotice,
    LegalDocumentVersions.termsOfUse,
    reason:
        'The canonical signup trigger currently requires one shared version.',
  );
}

Future<void> _verifyProfileIsolation({
  required SupabaseClient clientA,
  required SupabaseClient clientB,
  required SupabaseClient anonClient,
  required String userAId,
  required String runId,
}) async {
  final updatedName = 'w4a1_updated_$runId';
  final updated = await clientA
      .from('profiles')
      .update({'full_name': updatedName, 'phone': '+900000000001'})
      .eq('id', userAId)
      .select('id, full_name, phone, role')
      .single();
  expect(updated['id'], userAId);
  expect(updated['full_name'], updatedName);
  expect(updated['role'], 'customer');

  final crossUserUpdate = await clientB
      .from('profiles')
      .update({'full_name': 'w4a1_forbidden_profile_change'})
      .eq('id', userAId)
      .select('id');
  expect(crossUserUpdate, isEmpty);
  await _expectNoVisibleRows(
    () => clientB.from('profiles').select('id').eq('id', userAId),
  );
  await _expectNoVisibleRows(
    () => anonClient.from('profiles').select('id').eq('id', userAId),
  );

  for (final privilegedRole in ['merchant', 'admin']) {
    await _expectDatabaseDenied(
      () => clientA
          .from('profiles')
          .update({'role': privilegedRole})
          .eq('id', userAId)
          .select('id'),
    );
    final roleCheck = await clientA
        .from('profiles')
        .select('role')
        .eq('id', userAId)
        .single();
    expect(
      roleCheck['role'],
      'customer',
      reason: 'CRITICAL: client role escalation must never persist.',
    );
  }
}

Future<void> _verifySavedLocations({
  required SupabaseClient clientA,
  required SupabaseClient clientB,
  required SupabaseClient anonClient,
  required String userAId,
  required String runId,
}) async {
  final created = await clientA
      .from('customer_saved_locations')
      .insert({
        'user_id': userAId,
        'name': 'w4a1_$runId',
        'address_text': 'w4a1 development test location',
        'latitude': 41.015137,
        'longitude': 28.979530,
      })
      .select('id, user_id, name')
      .single();
  final locationId = created['id'] as String;
  expect(created['user_id'], userAId);

  final ownRead = await clientA
      .from('customer_saved_locations')
      .select('id')
      .eq('id', locationId);
  expect(ownRead, hasLength(1));
  final ownUpdate = await clientA
      .from('customer_saved_locations')
      .update({'address_text': 'w4a1 updated development test location'})
      .eq('id', locationId)
      .select('id');
  expect(ownUpdate, hasLength(1));

  await _expectNoVisibleRows(
    () => clientB
        .from('customer_saved_locations')
        .select('id')
        .eq('id', locationId),
  );
  final crossUpdate = await clientB
      .from('customer_saved_locations')
      .update({'address_text': 'w4a1 forbidden location change'})
      .eq('id', locationId)
      .select('id');
  expect(crossUpdate, isEmpty);
  final crossDelete = await clientB
      .from('customer_saved_locations')
      .delete()
      .eq('id', locationId)
      .select('id');
  expect(crossDelete, isEmpty);
  await _expectNoVisibleRows(
    () => anonClient
        .from('customer_saved_locations')
        .select('id')
        .eq('id', locationId),
  );
  await _expectDatabaseDenied(
    () => clientB
        .from('customer_saved_locations')
        .insert({
          'user_id': userAId,
          'name': 'w4a1_forbidden_location',
          'address_text': 'w4a1 cross-user row',
          'latitude': 41.0,
          'longitude': 29.0,
        })
        .select('id'),
  );

  final ownDelete = await clientA
      .from('customer_saved_locations')
      .delete()
      .eq('id', locationId)
      .select('id');
  expect(ownDelete, hasLength(1));
}

Future<void> _verifyAddresses({
  required SupabaseClient clientA,
  required SupabaseClient clientB,
  required SupabaseClient anonClient,
  required String userAId,
  required String runId,
}) async {
  final created = await clientA
      .from('addresses')
      .insert({
        'user_id': userAId,
        'full_name': 'w4a1_$runId',
        'phone': '+900000000002',
        'address_line1': 'w4a1 development address',
        'city': 'Istanbul',
        'country': 'TR',
      })
      .select('id, user_id')
      .single();
  final addressId = created['id'] as String;
  expect(created['user_id'], userAId);

  final ownRead = await clientA
      .from('addresses')
      .select('id')
      .eq('id', addressId);
  expect(ownRead, hasLength(1));
  final ownUpdate = await clientA
      .from('addresses')
      .update({'address_line1': 'w4a1 updated development address'})
      .eq('id', addressId)
      .select('id');
  expect(ownUpdate, hasLength(1));

  await _expectNoVisibleRows(
    () => clientB.from('addresses').select('id').eq('id', addressId),
  );
  final crossUpdate = await clientB
      .from('addresses')
      .update({'address_line1': 'w4a1 forbidden address change'})
      .eq('id', addressId)
      .select('id');
  expect(crossUpdate, isEmpty);
  final crossDelete = await clientB
      .from('addresses')
      .delete()
      .eq('id', addressId)
      .select('id');
  expect(crossDelete, isEmpty);
  await _expectNoVisibleRows(
    () => anonClient.from('addresses').select('id').eq('id', addressId),
  );
  await _expectDatabaseDenied(
    () => clientB
        .from('addresses')
        .insert({
          'user_id': userAId,
          'full_name': 'w4a1_forbidden_address',
          'phone': '+900000000003',
          'address_line1': 'w4a1 cross-user row',
          'city': 'Istanbul',
          'country': 'TR',
        })
        .select('id'),
  );

  final ownDelete = await clientA
      .from('addresses')
      .delete()
      .eq('id', addressId)
      .select('id');
  expect(ownDelete, hasLength(1));
}

Future<void> _verifyWishlist({
  required SupabaseClient clientA,
  required SupabaseClient clientB,
  required SupabaseClient anonClient,
  required String userAId,
}) async {
  final products = await clientA.from('products').select('id').limit(1);
  final productId = products.isEmpty ? null : products.single['id'] as String;

  if (productId == null) {
    final ownRows = await clientA
        .from('wishlist')
        .select('id')
        .eq('user_id', userAId);
    expect(ownRows, isEmpty);
    await _expectDatabaseFailureCode(
      () => clientA
          .from('wishlist')
          .insert({'user_id': userAId, 'product_id': _missingProductId})
          .select('id'),
      '23503',
    );
  } else {
    final created = await clientA
        .from('wishlist')
        .insert({'user_id': userAId, 'product_id': productId})
        .select('id, user_id, product_id')
        .single();
    final wishlistId = created['id'] as String;
    expect(created['user_id'], userAId);
    final ownRead = await clientA
        .from('wishlist')
        .select('id')
        .eq('id', wishlistId);
    expect(ownRead, hasLength(1));
    await _expectNoVisibleRows(
      () => clientB.from('wishlist').select('id').eq('id', wishlistId),
    );
    final crossDelete = await clientB
        .from('wishlist')
        .delete()
        .eq('id', wishlistId)
        .select('id');
    expect(crossDelete, isEmpty);
    final ownDelete = await clientA
        .from('wishlist')
        .delete()
        .eq('id', wishlistId)
        .select('id');
    expect(ownDelete, hasLength(1));
  }

  await _expectNoVisibleRows(
    () => anonClient.from('wishlist').select('id').eq('user_id', userAId),
  );
  await _expectDatabaseDenied(
    () => clientB
        .from('wishlist')
        .insert({
          'user_id': userAId,
          'product_id': productId ?? _missingProductId,
        })
        .select('id'),
  );
}

Future<void> _expectNoVisibleRows(
  Future<List<Map<String, dynamic>>> Function() operation,
) async {
  try {
    final rows = await operation();
    expect(rows, isEmpty);
  } on PostgrestException catch (error) {
    expect(error.code, '42501');
  }
}

Future<void> _expectDatabaseDenied(Future<Object?> Function() operation) =>
    _expectDatabaseFailureCode(operation, '42501');

Future<void> _expectDatabaseFailureCode(
  Future<Object?> Function() operation,
  String expectedCode,
) async {
  try {
    await operation();
    fail('Expected database rejection with code $expectedCode.');
  } on PostgrestException catch (error) {
    expect(error.code, expectedCode);
  }
}

Future<void> _deleteOwnTestAccount(
  SupabaseClient client,
  String label,
  List<String> cleanupFailures,
) async {
  try {
    if (client.auth.currentSession != null) {
      await client.rpc<void>('delete_current_customer_account');
    }
  } catch (_) {
    cleanupFailures.add(label);
  } finally {
    await client.dispose();
  }
}
