import 'dart:async';
import '../domain/push_contract.dart';

/// Small SDK boundary: tests exercise lifecycle without contacting Firebase.
abstract interface class FcmMobileClient {
  Future<PushPermission> requestPermission();
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> disableAutoInit();
  Stream<String> get tokenChanges;
  Stream<Map<String, dynamic>> get opens;
  Stream<Map<String, dynamic>> get messages;
  Future<Map<String, dynamic>?> initialOpen();
  Future<void> showGeneric(Map<String, String> data);
  Future<void> clearNotifications();
}

class FcmMobilePushProvider implements MobilePushProvider {
  FcmMobilePushProvider({
    required this.client,
    required this.role,
    required this.currentIdentity,
    required this.currentSessionKey,
  });
  final FcmMobileClient client;
  final NotificationAppRole role;
  final PushIdentity? Function() currentIdentity;
  final String? Function() currentSessionKey;
  final _opened = StreamController<PushOpenEvent>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _listening = false, _disposed = false;
  @override
  bool get configured => !_disposed;

  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  PushOpenEvent? decode(Map<String, dynamic> data) {
    final notification = data['notification_id'];
    final user = data['user_id'];
    if (notification is! String ||
        !_uuid.hasMatch(notification) ||
        user is! String ||
        !_uuid.hasMatch(user) ||
        data['app_role'] != role.name) {
      return null;
    }
    return PushOpenEvent(
      notificationId: notification,
      identity: PushIdentity(user, role),
    );
  }

  void _emit(Map<String, dynamic> data) {
    if (_disposed) return;
    final event = decode(data);
    if (event != null && event.identity.matches(currentIdentity())) {
      _opened.add(event);
    }
  }

  // Taps work independently of enrollment. No permission/token request here.
  void _listen() {
    if (_listening || _disposed) return;
    _listening = true;
    _subscriptions.add(client.opens.listen(_emit, onError: (Object _) {}));
    _subscriptions.add(
      client.messages.listen((data) async {
        final event = decode(data);
        if (_disposed ||
            event == null ||
            !event.identity.matches(currentIdentity())) {
          return;
        }
        try {
          await client.showGeneric({
            'notification_id': event.notificationId,
            'user_id': event.identity.userId,
            'app_role': role.name,
          });
        } catch (_) {
          /* Inbox remains available; never log payloads. */
        }
      }, onError: (Object _) {}),
    );
    // Attach the stream listener before resolving the cold-start event.
    final identity = currentIdentity();
    final session = currentSessionKey();
    unawaited(
      Future<void>.microtask(() async {
        try {
          final data = await client.initialOpen();
          if (data != null &&
              identity != null &&
              session != null &&
              identity.matches(currentIdentity()) &&
              session == currentSessionKey()) {
            _emit(data);
          }
        } catch (_) {
          /* An unavailable tap never becomes permission. */
        }
      }),
    );
  }

  @override
  Stream<PushOpenEvent> get opened {
    _listen();
    return _opened.stream;
  }

  @override
  Stream<String> get tokenChanges => client.tokenChanges;
  @override
  Future<PushPermission> requestPermission() => client.requestPermission();
  @override
  Future<String?> getToken() => client.getToken();
  @override
  Future<void> deleteToken() async {
    // Never enable auto-init, including after explicit permission. Await SDK
    // deletion acknowledgement; propagate uncertainty to coordinator cleanup.
    await client.disableAutoInit();
    await client.deleteToken();
    await client.clearNotifications();
  }

  Future<void> dispose() async {
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _opened.close();
  }
}
