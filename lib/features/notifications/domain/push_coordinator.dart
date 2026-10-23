import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/push_installation.dart';

enum PushClientStatus {
  idle,
  pendingConfiguration,
  enabling,
  registered,
  denied,
  cleanupRequired,
  disabling,
  disposed,
}

/// Shared transport state machine. Permission is requested only by enable().
/// A host supplies its validated identity and stable Auth session key, not JWTs.
class PushCoordinator extends ChangeNotifier {
  PushCoordinator({
    required this.provider,
    required this.registry,
    required this.currentIdentity,
    required this.lookup,
    required this.onOpen,
    required String installationId,
    required this.platform,
    this.currentSessionKey,
    this.installations,
    this.lookupTimeout = const Duration(seconds: 15),
  }) : _installationId = installationId;
  final MobilePushProvider provider;
  final PushDeviceRegistry registry;
  final PushIdentity? Function() currentIdentity;
  final String? Function()? currentSessionKey;
  final PushNotificationLookup lookup;
  final void Function(NotificationEntity) onOpen;
  final PushPlatform platform;
  final PushInstallationStore? installations;
  final Duration lookupTimeout;
  String _installationId;
  String get installationId => _installationId;
  PushClientStatus _status = PushClientStatus.idle;
  PushClientStatus get status => _status;
  bool get available => provider.configured && registry.deployed;
  bool get busy => _enrollment != null || _disabling != null;
  StreamSubscription<String>? _tokens;
  StreamSubscription<PushOpenEvent>? _opens;
  int? _opensEpoch;
  Future<PushRegistrationResult>? _enrollment;
  Future<void>? _disabling;
  Future<void> _writes = Future.value();
  final Set<(int, String)> _opening = {};
  final Set<String> _opened = {};
  PushIdentity? _bound;
  String? _boundSession;
  bool _dirty = false, _disposed = false;
  int _epoch = 0;

  void _set(PushClientStatus value) {
    if (_disposed) return;
    _status = value;
    notifyListeners();
  }

  bool _valid(int epoch, PushIdentity identity, String? session) =>
      !_disposed &&
      epoch == _epoch &&
      identity.matches(currentIdentity()) &&
      (currentSessionKey == null ||
          (session != null && session == currentSessionKey!()));

  /// Host starts this only after its authenticated workspace is ready. Taps do
  /// not enroll the device or ask permission; every tap still re-reads the row.
  void observeOpens() {
    if (_disposed ||
        !available ||
        _status == PushClientStatus.cleanupRequired ||
        (_opens != null && _opensEpoch == _epoch)) {
      return;
    }
    unawaited(_opens?.cancel());
    final revision = _epoch;
    final identity = currentIdentity();
    final session = currentSessionKey?.call();
    if (identity == null) return;
    _opensEpoch = revision;
    _opens = provider.opened.listen((event) {
      if (_valid(revision, identity, session)) {
        unawaited(open(event, epoch: revision));
      }
    }, onError: (Object _) => invalidate());
  }

  Future<PushRegistrationResult> enable() {
    if (_disposed || busy || _bound != null || _dirty) {
      return Future.value(PushRegistrationResult.failed);
    }
    if (!available) {
      _set(PushClientStatus.pendingConfiguration);
      return Future.value(PushRegistrationResult.pendingConfiguration);
    }
    final identity = currentIdentity();
    final session = currentSessionKey?.call();
    if (identity == null || (currentSessionKey != null && session == null)) {
      _set(PushClientStatus.denied);
      return Future.value(PushRegistrationResult.denied);
    }
    final epoch = ++_epoch;
    // Capture the pending operation before a status listener can request logout.
    final future = Future<PushRegistrationResult>.microtask(
      () => _enable(identity, session, epoch),
    );
    _enrollment = future;
    return future.whenComplete(() {
      _enrollment = null;
      if (_status == PushClientStatus.enabling) {
        _set(
          _dirty ? PushClientStatus.cleanupRequired : PushClientStatus.denied,
        );
      }
      if (!_disposed) notifyListeners();
    });
  }

  Future<PushRegistrationResult> _enable(
    PushIdentity identity,
    String? session,
    int epoch,
  ) async {
    if (!_valid(epoch, identity, session)) {
      return PushRegistrationResult.denied;
    }
    _set(PushClientStatus.enabling);
    try {
      final store = installations;
      if (store != null) {
        final saved = await store.read();
        _installationId = saved.id;
        if (!_valid(epoch, identity, session)) {
          return PushRegistrationResult.denied;
        }
        if (saved.cleanupRequired) {
          // A previous process cannot prove its final write outcome. Invalidate
          // its provider token before using a fresh installation; do not revoke
          // an old session's binding with a replacement account's credentials.
          _dirty = true;
          await provider.deleteToken();
          final replacement = PushInstallation(store.newId());
          await store.save(replacement);
          _installationId = replacement.id;
          _dirty = false;
        }
      }
      if (!_valid(epoch, identity, session)) {
        return PushRegistrationResult.denied;
      }
      final permission = await provider.requestPermission();
      if (!_valid(epoch, identity, session) ||
          permission != PushPermission.granted) {
        if (epoch == _epoch) _set(PushClientStatus.denied);
        return PushRegistrationResult.denied;
      }
      _dirty = true;
      await installations?.save(
        PushInstallation(_installationId, cleanupRequired: true),
      );
      if (!_valid(epoch, identity, session)) {
        return PushRegistrationResult.denied;
      }
      String? latest;
      var live = false;
      _tokens = provider.tokenChanges.listen(
        (token) {
          if (!_valid(epoch, identity, session)) return;
          latest = token;
          if (live) _queue(token, identity, session, epoch);
        },
        onError: (Object _) => invalidate(),
        onDone: invalidate,
      );
      observeOpens();
      final fetched = await provider.getToken();
      if (!_valid(epoch, identity, session)) {
        return PushRegistrationResult.denied;
      }
      final token = latest ?? fetched;
      if (token == null) throw StateError('push_token_missing');
      _bound = identity;
      _boundSession = session;
      await _register(token, identity, session, epoch);
      if (!_valid(epoch, identity, session)) {
        return PushRegistrationResult.denied;
      }
      live = true;
      if (latest != null && latest != token) {
        _queue(latest!, identity, session, epoch);
        await _writes;
      }
      if (!_valid(epoch, identity, session)) {
        return PushRegistrationResult.failed;
      }
      _set(PushClientStatus.registered);
      return PushRegistrationResult.registered;
    } catch (_) {
      invalidate();
      _set(PushClientStatus.cleanupRequired);
      return PushRegistrationResult.failed;
    }
  }

  void _queue(String token, PushIdentity identity, String? session, int epoch) {
    _writes = _writes
        .then((_) => _register(token, identity, session, epoch))
        .catchError((Object _) => invalidate());
  }

  Future<void> _register(
    String token,
    PushIdentity identity,
    String? session,
    int epoch,
  ) async {
    if (!_valid(epoch, identity, session)) return;
    if (token.isEmpty ||
        token.length > 4096 ||
        RegExp(r'[\x00-\x20]').hasMatch(token)) {
      throw StateError('push_token_invalid');
    }
    await registry.register(
      PushDeviceRegistration(
        identity: identity,
        installationId: _installationId,
        token: token,
        platform: platform,
      ),
    );
  }

  /// Synchronous authority fence, including A -> logout -> A between frames.
  /// Does not claim that an in-flight server write or OS request was cancelled.
  void invalidate() {
    ++_epoch;
    _opened.clear();
    _set(
      _dirty || _bound != null
          ? PushClientStatus.cleanupRequired
          : PushClientStatus.idle,
    );
  }

  Future<void> open(PushOpenEvent event, {int? epoch}) async {
    final revision = epoch ?? _epoch;
    final session = currentSessionKey?.call();
    final key = (revision, event.notificationId);
    if (!_valid(revision, event.identity, session) ||
        event.notificationId.isEmpty ||
        event.notificationId.length > 128 ||
        _opened.contains(event.notificationId) ||
        _opening.length >= 16 ||
        !_opening.add(key)) {
      return;
    }
    try {
      final notification = await lookup(
        event.notificationId,
      ).timeout(lookupTimeout);
      if (!_valid(revision, event.identity, session) ||
          notification == null ||
          notification.userId != event.identity.userId ||
          notification.id != event.notificationId) {
        return;
      }
      final role = notification.data?['app_role'];
      if (role != null && role != event.identity.role.name) return;
      // Bounded session-local tap dedup; failed lookup remains retryable.
      if (_opened.length == 128) _opened.remove(_opened.first);
      _opened.add(event.notificationId);
      onOpen(notification);
    } catch (_) {
      // No provider payload, raw error, token or private record is logged.
    } finally {
      _opening.remove(key);
    }
  }

  /// Coalesces logout/disable requests and waits for SDK operations and writes.
  /// No write timeout: a timeout is not evidence of cancellation.
  Future<void> disable() {
    if (_disposed) return Future.value();
    if (_disabling != null) return _disabling!;
    final future = Future<void>.microtask(_disable);
    _disabling = future;
    invalidate();
    return future.whenComplete(() {
      _disabling = null;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> _disable() async {
    _set(PushClientStatus.disabling);
    try {
      await _enrollment;
      await _tokens?.cancel();
      await _opens?.cancel();
      _tokens = null;
      _opens = null;
      await _writes;
      final saved = await installations?.read();
      if (saved != null) _installationId = saved.id;
      final uncertain = _dirty || saved?.cleanupRequired == true;
      final bound = _bound;
      final sameSession =
          bound != null &&
          bound.matches(currentIdentity()) &&
          (currentSessionKey == null || _boundSession == currentSessionKey!());
      // I0 rejects disable from a replacement Auth session. Foreign/unknown
      // recovery invalidates the provider token and rotates installation instead.
      if (sameSession) await registry.disable(bound, _installationId);
      if (uncertain || bound != null) {
        if (!provider.configured) throw StateError('push_cleanup_unavailable');
        await provider.deleteToken();
      }
      if (installations != null && uncertain) {
        if (!sameSession) _installationId = installations!.newId();
        await installations!.save(PushInstallation(_installationId));
      }
      _dirty = false;
      _bound = null;
      _boundSession = null;
      _set(PushClientStatus.idle);
    } catch (_) {
      _set(PushClientStatus.cleanupRequired);
      throw StateError('push_cleanup_failed');
    }
  }

  @override
  void dispose() {
    ++_epoch;
    _opened.clear();
    _disposed = true;
    _status = PushClientStatus.disposed;
    unawaited(_tokens?.cancel());
    unawaited(_opens?.cancel());
    // Preserve the durable marker for recovery. Never race an unfinished
    // registration with token deletion just because a view was disposed.
    super.dispose();
  }
}
