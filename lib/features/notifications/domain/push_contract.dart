import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';

enum NotificationAppRole { customer, merchant }

enum PushPlatform { android, ios }

enum PushPermission { granted, denied, unavailable }

enum PushRegistrationResult { registered, pendingConfiguration, denied, failed }

class NotificationPreferences {
  const NotificationPreferences({this.service = true, this.marketing = false});
  final bool service;
  final bool marketing;
}

/// IDs are local ownership boundaries; neither tokens nor identities enter logs.
class PushIdentity {
  const PushIdentity(this.userId, this.role);
  final String userId;
  final NotificationAppRole role;
  bool matches(PushIdentity? other) =>
      other?.userId == userId && other?.role == role;
  @override
  String toString() => 'PushIdentity(redacted)';
}

class PushDeviceRegistration {
  const PushDeviceRegistration({
    required this.identity,
    required this.installationId,
    required this.token,
    required this.platform,
  });
  final PushIdentity identity;
  final String installationId;
  final String token;
  final PushPlatform platform;
  @override
  String toString() => 'PushDeviceRegistration(redacted)';
}

/// Providers carry an existing notification ID, never a new client-authored event.
class PushOpenEvent {
  const PushOpenEvent({required this.notificationId, required this.identity});
  final String notificationId;
  final PushIdentity identity;
}

abstract interface class MobilePushProvider {
  bool get configured;
  Future<PushPermission> requestPermission();
  Future<String?> getToken();
  Stream<String> get tokenChanges;
  Stream<PushOpenEvent> get opened;
  Future<void> deleteToken();
}

/// No SDK initialization, permission prompt or network activity without setup.
class UnconfiguredMobilePushProvider implements MobilePushProvider {
  const UnconfiguredMobilePushProvider();
  @override
  bool get configured => false;
  @override
  Future<PushPermission> requestPermission() async =>
      PushPermission.unavailable;
  @override
  Future<String?> getToken() async => null;
  @override
  Stream<String> get tokenChanges => const Stream.empty();
  @override
  Stream<PushOpenEvent> get opened => const Stream.empty();
  @override
  Future<void> deleteToken() async {}
}

abstract interface class PushDeviceRegistry {
  bool get deployed;
  Future<void> register(PushDeviceRegistration registration);

  /// Must run while the old user's session is still valid, before sign-out.
  Future<void> disable(PushIdentity identity, String installationId);
}

abstract interface class NotificationPreferencesRepository {
  bool get serverBacked;
  Future<NotificationPreferences> read(PushIdentity identity);
  Future<void> save(PushIdentity identity, NotificationPreferences preferences);
}

typedef PushNotificationLookup =
    Future<NotificationEntity?> Function(String id);
