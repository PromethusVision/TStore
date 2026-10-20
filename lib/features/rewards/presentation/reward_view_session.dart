import 'dart:async';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';

/// A private view belongs to the session that opened it, including queued events.
/// This is a presentation fence; authorization remains in the existing RPCs.
class RewardViewSession {
  RewardViewSession({
    required this.repository,
    required this.owner,
    required this.currentUser,
    required Stream<String?>? changes,
    required this.onLost,
    this.originIsCurrent,
  }) {
    if (repository case AuthenticatedSessionSource source) {
      _key = source.currentSessionKey;
    }
    _actors = changes?.listen(
      (actor) {
        if (actor != owner || !current) retire();
      },
      onError: (Object _) => retire(),
      onDone: retire,
    );
    if (repository case AuthenticatedSessionEvents source) {
      _keys = source.sessionKeyChanges.listen(
        (key) {
          if (key != _key || !current) retire();
        },
        onError: (Object _) => retire(),
        onDone: retire,
      );
    }
  }
  final Object repository;
  final String? owner;
  final String? Function()? currentUser;
  final bool Function()? originIsCurrent;
  final void Function() onLost;
  String? _key;
  bool _closed = false;
  StreamSubscription<String?>? _actors, _keys;
  bool get current =>
      !_closed &&
      (originIsCurrent?.call() ?? true) &&
      (currentUser == null || owner != null && currentUser!() == owner) &&
      (repository is! AuthenticatedSessionSource ||
          _key != null &&
              (repository as AuthenticatedSessionSource).currentSessionKey ==
                  _key);
  bool check() {
    if (!current) {
      retire();
      return false;
    }
    return true;
  }

  void retire() {
    if (_closed) return;
    _closed = true;
    onLost();
  }

  void close() {
    _closed = true;
    unawaited(_actors?.cancel());
    unawaited(_keys?.cancel());
  }
}
