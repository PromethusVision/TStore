import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';

/// Local preferences are never advertised as synchronized server consent.
/// Marketing defaults to OFF on every new account/role/install.
class LocalNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  @override
  bool get serverBacked => false;
  String _key(PushIdentity identity) =>
      'notification_preferences_v1_${identity.role.name}_${identity.userId}';
  @override
  Future<NotificationPreferences> read(PushIdentity identity) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(identity));
    if (raw == null) return const NotificationPreferences();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return NotificationPreferences(
      service: data['service'] == true,
      marketing: data['marketing'] == true,
    );
  }

  @override
  Future<void> save(
    PushIdentity identity,
    NotificationPreferences preferences,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _key(identity),
      jsonEncode({
        'service': preferences.service,
        'marketing': preferences.marketing,
      }),
    );
    if (!saved) {
      throw StateError('preferences_not_saved');
    }
  }
}
