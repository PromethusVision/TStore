import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/notifications/data/models/notification_model.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';

/// Not registered in production DI until the separately reviewed schema deploy.
/// RLS and RPCs derive ownership from auth.uid(); a caller cannot select a user.
class SupabasePushBackend
    implements PushDeviceRegistry, NotificationPreferencesRepository {
  SupabasePushBackend(this.client, {this.deployed = false});
  final SupabaseClient client;
  @override
  final bool deployed;
  @override
  bool get serverBacked => deployed;
  void _check(PushIdentity identity) {
    if (!deployed || client.auth.currentUser?.id != identity.userId) {
      throw StateError('push_backend_unavailable');
    }
  }

  @override
  Future<void> register(PushDeviceRegistration registration) async {
    _check(registration.identity);
    await client.rpc(
      'register_push_device_v1',
      params: {
        'p_installation_id': registration.installationId,
        'p_app_role': registration.identity.role.name,
        'p_push_token': registration.token,
        'p_platform': registration.platform.name,
      },
    );
    _check(registration.identity);
  }

  @override
  Future<void> disable(PushIdentity identity, String installationId) async {
    _check(identity);
    await client.rpc(
      'disable_push_device_v1',
      params: {
        'p_installation_id': installationId,
        'p_app_role': identity.role.name,
      },
    );
    _check(identity);
  }

  @override
  Future<NotificationPreferences> read(PushIdentity identity) async {
    _check(identity);
    final row = await client
        .from('notification_preferences')
        .select('service_enabled,marketing_enabled')
        .eq('user_id', identity.userId)
        .eq('app_role', identity.role.name)
        .maybeSingle();
    _check(identity);
    return NotificationPreferences(
      service: row?['service_enabled'] as bool? ?? true,
      marketing: row?['marketing_enabled'] as bool? ?? false,
    );
  }

  @override
  Future<void> save(
    PushIdentity identity,
    NotificationPreferences preferences,
  ) async {
    _check(identity);
    await client.rpc(
      'set_notification_preferences_v1',
      params: {
        'p_app_role': identity.role.name,
        'p_service': preferences.service,
        'p_marketing': preferences.marketing,
      },
    );
    _check(identity);
  }

  Future<NotificationEntity?> lookup(String id) async {
    final userId = client.auth.currentUser?.id;
    if (!deployed || userId == null) return null;
    final row = await client
        .from('notifications')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null || userId != client.auth.currentUser?.id) return null;
    return NotificationModel.fromJson(row);
  }
}
