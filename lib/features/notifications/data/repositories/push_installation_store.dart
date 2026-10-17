import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_installation.dart';

/// One instance per app host. No token, account, session or consent is persisted.
class LocalPushInstallationStore implements PushInstallationStore {
  LocalPushInstallationStore(this.role);
  final NotificationAppRole role;
  String get _key => 'push_installation_v1_${role.name}';
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  @override
  String newId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  Future<PushInstallation> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      final value = PushInstallation(newId());
      await save(value);
      return value;
    }
    // Corruption is not a fresh installation: do not discard uncertain binding.
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['id'] is! String ||
          !_uuid.hasMatch(data['id'] as String) ||
          data['cleanup'] is! bool) {
        throw const FormatException();
      }
      return PushInstallation(
        data['id'] as String,
        cleanupRequired: data['cleanup'] as bool,
      );
    } catch (_) {
      throw StateError('push_installation_unreadable');
    }
  }

  @override
  Future<void> save(PushInstallation installation) async {
    if (!_uuid.hasMatch(installation.id)) {
      throw StateError('push_installation_invalid');
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      _key,
      jsonEncode({
        'id': installation.id,
        'cleanup': installation.cleanupRequired,
      }),
    )) {
      throw StateError('push_installation_not_saved');
    }
  }
}
