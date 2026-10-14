import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

String newQrRequestId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// Installation is audit context only. Server verifies Auth session independently.
class QrInstallation {
  static Future<String>? _pending;
  static Future<String> load() => _pending ??= _load();
  static Future<String> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'merchant_qr_installation_v2';
      final existing = prefs.getString(key);
      if (existing != null) return existing;
      final value = newQrRequestId();
      if (!await prefs.setString(key, value)) {
        throw StateError('Installation persistence unavailable');
      }
      return value;
    } catch (_) {
      _pending = null;
      rethrow;
    }
  }
}
