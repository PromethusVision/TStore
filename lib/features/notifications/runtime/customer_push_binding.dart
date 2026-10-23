import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/supabase/authenticated_session_key.dart';
import '../../../core/supabase/supabase_service.dart';
import '../data/repositories/push_backend_adapter.dart';
import '../data/repositories/push_installation_store.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/push_contract.dart';
import '../domain/push_coordinator.dart';

/// Development composition only. Existing Customer screens share this binding;
/// they never instantiate a second device registry or notification repository.
class CustomerPushBinding {
  CustomerPushBinding(this.service, MobilePushProvider provider)
    : preferences = SupabasePushBackend(
        service.client,
        deployed: provider.configured,
      ) {
    coordinator = PushCoordinator(
      provider: provider,
      registry: preferences,
      currentIdentity: () => service.currentUser == null
          ? null
          : PushIdentity(service.currentUser!.id, NotificationAppRole.customer),
      currentSessionKey: () => authenticatedSessionKey(service.client),
      lookup: preferences.lookup,
      onOpen: _opens.add,
      installationId: 'not-loaded',
      installations: LocalPushInstallationStore(NotificationAppRole.customer),
      platform: PushPlatform.android,
    );
    _session = authenticatedSessionKey(service.client);
    _auth = service.authStateChanges.listen(
      (event) {
        final next = authenticatedSessionKeyFromSession(event.session);
        if (next != _session) {
          _session = next;
          coordinator.invalidate();
          authority.value++;
        }
      },
      onError: (Object _) {
        _session = null;
        coordinator.invalidate();
        authority.value++;
      },
    );
  }
  final SupabaseService service;
  final SupabasePushBackend preferences;
  late final PushCoordinator coordinator;
  final authority = ValueNotifier<int>(0);
  final _opens = StreamController<NotificationEntity>.broadcast(sync: true);
  Stream<NotificationEntity> get opens => _opens.stream;
  StreamSubscription<dynamic>? _auth;
  String? _session;
  String? get session => _session;
  Future<void> beforeSignOut() async {
    final session = authenticatedSessionKey(service.client);
    await coordinator.disable();
    if (session != authenticatedSessionKey(service.client)) {
      throw StateError('push_signout_session_changed');
    }
  }

  Future<void> dispose() async {
    await _auth?.cancel();
    coordinator.dispose();
    authority.dispose();
    await _opens.close();
  }
}
