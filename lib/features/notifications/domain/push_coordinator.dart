import 'dart:async';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';

/// Shared by customer/merchant entry points once provider and schema are deployed.
/// Explicit opt-in only: permission is never requested during app startup.
class PushCoordinator {
  PushCoordinator({
    required this.provider,
    required this.registry,
    required this.currentIdentity,
    required this.lookup,
    required this.onOpen,
    required this.installationId,
    required this.platform,
  });
  final MobilePushProvider provider;
  final PushDeviceRegistry registry;
  final PushIdentity? Function() currentIdentity;
  final PushNotificationLookup lookup;
  final void Function(NotificationEntity) onOpen;
  final String installationId;
  final PushPlatform platform;
  StreamSubscription<String>? _tokens;
  StreamSubscription<PushOpenEvent>? _opens;
  Future<void> _writes = Future.value();
  final Set<String> _opening = {};
  PushIdentity? _bound;
  bool _enabling = false;
  int _epoch = 0;

  Future<PushRegistrationResult> enable() async {
    if (!provider.configured || !registry.deployed) {
      return PushRegistrationResult.pendingConfiguration;
    }
    if (_bound != null || _enabling) return PushRegistrationResult.failed;
    final identity = currentIdentity();
    if (identity == null) return PushRegistrationResult.denied;
    final epoch = ++_epoch;
    _enabling = true;
    try {
      final permission = await provider.requestPermission();
      if (permission != PushPermission.granted || !_valid(epoch, identity)) {
        return PushRegistrationResult.denied;
      }
      final token = await provider.getToken();
      if (!_valid(epoch, identity) || token == null || token.isEmpty) {
        return PushRegistrationResult.denied;
      }
      _bound = identity;
      final initialWrite = _writes.then(
        (_) => _register(token, identity, epoch),
      );
      _writes = initialWrite.catchError((Object _) {});
      await initialWrite;
      if (!_valid(epoch, identity)) return PushRegistrationResult.denied;
      _tokens = provider.tokenChanges.listen((token) {
        // Serialize rotation writes so an older token cannot win a slow race.
        _writes = _writes
            .then((_) async {
              if (_valid(epoch, identity)) {
                await _register(token, identity, epoch);
              }
            })
            .catchError((Object _) {});
      }, onError: (Object _) {});
      _opens = provider.opened.listen((event) {
        unawaited(open(event, epoch: epoch));
      }, onError: (Object _) {});
      return PushRegistrationResult.registered;
    } catch (_) {
      // A lost response may follow a successful registration. Keep ownership
      // until revocation succeeds; never reuse it for another account.
      try {
        await disable();
      } catch (_) {
        // The bound identity remains blocked until explicit revocation succeeds.
      }
      return PushRegistrationResult.failed;
    } finally {
      _enabling = false;
    }
  }

  bool _valid(int epoch, PushIdentity identity) =>
      epoch == _epoch && identity.matches(currentIdentity());

  Future<void> _register(String token, PushIdentity identity, int epoch) async {
    if (!_valid(epoch, identity)) return;
    if (token.isEmpty ||
        token.length > 4096 ||
        RegExp(r'[\x00-\x20]').hasMatch(token)) {
      throw StateError('push_token_invalid');
    }
    await registry.register(
      PushDeviceRegistration(
        identity: identity,
        installationId: installationId,
        token: token,
        platform: platform,
      ),
    );
  }

  /// Cold-start and foreground taps use the same authoritative in-app record.
  Future<void> open(PushOpenEvent event, {int? epoch}) async {
    final revision = epoch ?? _epoch;
    if (!_valid(revision, event.identity) ||
        !_opening.add(event.notificationId)) {
      return;
    }
    try {
      final notification = await lookup(event.notificationId);
      if (!_valid(revision, event.identity) ||
          notification == null ||
          notification.userId != event.identity.userId ||
          notification.id != event.notificationId) {
        return;
      }
      final role = notification.data?['app_role'];
      if (role != null && role != event.identity.role.name) return;
      onOpen(notification);
    } catch (_) {
      // Fail closed; raw provider/server errors may contain tokens or identities.
    } finally {
      _opening.remove(event.notificationId);
    }
  }

  /// Call before sign-out/account switch. Failure must be surfaced, not ignored:
  /// future host integration must not reuse a device token while revocation fails.
  Future<void> disable() async {
    ++_epoch;
    await _tokens?.cancel();
    await _opens?.cancel();
    _tokens = null;
    _opens = null;
    await _writes;
    final bound = _bound;
    try {
      if (bound != null) await registry.disable(bound, installationId);
    } finally {
      await provider.deleteToken();
    }
    _bound = null;
  }
}
