import 'dart:async';
import 'push_contract.dart';

/// In-memory protection for the existing preference adapter, not a retry queue.
/// Reopened views wait for a still-pending write before reading its current state.
/// It cannot cancel a server operation or prove persistence after process death.
class NotificationPreferenceWrites {
  final _pending = <(String, NotificationAppRole), Completer<void>>{};

  Future<T> read<T>(PushIdentity identity, Future<T> Function() action) async {
    final key = (identity.userId, identity.role);
    while (true) {
      final pending = _pending[key];
      if (pending == null) break;
      await pending.future;
    }
    return action();
  }

  Future<void> save(
    PushIdentity identity,
    Future<void> Function() action,
  ) async {
    final key = (identity.userId, identity.role);
    if (_pending.containsKey(key)) {
      throw StateError('notification_preference_write_pending');
    }
    final pending = Completer<void>();
    _pending[key] = pending;
    try {
      await action();
    } finally {
      _pending.remove(key);
      // A failed transport also settles this local barrier. Its actual result
      // must be read; this completion is never a successful-write receipt.
      pending.complete();
    }
  }
}
