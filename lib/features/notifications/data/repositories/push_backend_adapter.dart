import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/notifications/data/models/notification_model.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/notification_preference_writes.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';

/// Not registered in production DI until the separately reviewed schema deploy.
/// RLS and RPCs derive ownership from auth.uid(); a caller cannot select a user.
class SupabasePushBackend
    implements
        PushDeviceRegistry,
        NotificationPreferencesRepository,
        NotificationSessionSource {
  SupabasePushBackend(
    this.client, {
    this.deployed = false,
    String? Function()? sessionKey,
  }) : sessionKey = sessionKey ?? (() => authenticatedSessionKey(client)),
       _writes = _clientWrites[client] ??= NotificationPreferenceWrites();
  static final _clientWrites = Expando<NotificationPreferenceWrites>();
  final SupabaseClient client;
  final String? Function() sessionKey;
  final NotificationPreferenceWrites _writes;
  @override
  String? get currentUserId => client.auth.currentUser?.id;
  @override
  String? get currentSessionKey => sessionKey();
  @override
  Stream<String?> get sessionKeyChanges => client.auth.onAuthStateChange.map(
    (event) => authenticatedSessionKeyFromSession(event.session),
  );
  @override
  final bool deployed;
  @override
  bool get serverBacked => deployed;
  String _check(String userId) {
    final key = sessionKey();
    if (!deployed || currentUserId != userId || key == null) {
      throw StateError('push_backend_unavailable');
    }
    return key;
  }

  Future<T> _withScope<T>(
    String userId,
    Future<T> Function(AuthenticatedRequestScope scope) action,
  ) async {
    final key = _check(userId);
    final scope = AuthenticatedRequestScope(
      user: userId,
      session: key,
      currentUser: () => currentUserId,
      currentSession: () => currentSessionKey,
      changes: client.auth.onAuthStateChange.map(
        (event) => event.session?.user.id,
      ),
      sessionKeys: sessionKeyChanges,
    );
    try {
      scope.check();
      final value = await action(scope);
      scope.check();
      return value;
    } catch (_) {
      if (!scope.current) throw StateError('push_backend_session_changed');
      rethrow;
    } finally {
      await scope.close();
    }
  }

  @override
  Future<void> register(PushDeviceRegistration registration) => _withScope(
    registration.identity.userId,
    (scope) => scope.run(() async {
      await client.rpc(
        'register_push_device_v1',
        params: {
          'p_installation_id': registration.installationId,
          'p_app_role': registration.identity.role.name,
          'p_push_token': registration.token,
          'p_platform': registration.platform.name,
        },
      );
    }),
  );

  @override
  Future<void> disable(PushIdentity identity, String installationId) =>
      _withScope(
        identity.userId,
        (scope) => scope.run(() async {
          await client.rpc(
            'disable_push_device_v1',
            params: {
              'p_installation_id': installationId,
              'p_app_role': identity.role.name,
            },
          );
        }),
      );

  @override
  Future<NotificationPreferences> read(PushIdentity identity) => _withScope(
    identity.userId,
    (scope) => _writes.read(
      identity,
      () => scope.run(() async {
        final row = await client
            .from('notification_preferences')
            .select('service_enabled,marketing_enabled')
            .eq('user_id', identity.userId)
            .eq('app_role', identity.role.name)
            .maybeSingle();
        if (row == null) return const NotificationPreferences();
        if (row['service_enabled'] is! bool ||
            row['marketing_enabled'] is! bool) {
          throw const FormatException('Invalid notification preferences');
        }
        return NotificationPreferences(
          service: row['service_enabled'] as bool,
          marketing: row['marketing_enabled'] as bool,
        );
      }),
    ),
  );

  @override
  Future<void> save(
    PushIdentity identity,
    NotificationPreferences preferences,
  ) => _writes.save(
    identity,
    () => _withScope(
      identity.userId,
      (scope) => scope.run(() async {
        await client.rpc(
          'set_notification_preferences_v1',
          params: {
            'p_app_role': identity.role.name,
            'p_service': preferences.service,
            'p_marketing': preferences.marketing,
          },
        );
      }),
    ),
  );

  Future<NotificationEntity?> lookup(String id) async {
    final userId = client.auth.currentUser?.id;
    if (!deployed || userId == null || currentSessionKey == null) return null;
    try {
      return await _withScope(
        userId,
        (scope) => scope.run(() async {
          final row = await client
              .from('notifications')
              .select()
              .eq('id', id)
              .eq('user_id', userId)
              .maybeSingle();
          if (row == null || row['user_id'] != userId) return null;
          return NotificationModel.fromJson(row);
        }),
      );
    } on StateError {
      return null;
    }
  }
}
