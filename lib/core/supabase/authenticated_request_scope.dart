import 'dart:async';

/// Stable session identity, distinct from the user and refreshed access token.
abstract interface class AuthenticatedSessionSource {
  String? get currentSessionKey;
}

class AuthenticatedRequestChanged implements Exception {
  const AuthenticatedRequestChanged();
}

/// A local continuation fence; server authorization remains authoritative.
/// Closing also prevents abandoned image decoders from starting more requests.
class AuthenticatedRequestScope {
  AuthenticatedRequestScope({
    required this.user,
    required this.session,
    required this.currentUser,
    required this.currentSession,
    required Stream<String?> changes,
    this.allowGuest = false,
  }) {
    _subscription = changes.listen(
      (actor) {
        if (actor != user || !current) _closed = true;
      },
      onError: (Object _) => _closed = true,
      onDone: () => _closed = true,
    );
  }
  final String? user, session;
  final String? Function() currentUser, currentSession;
  final bool allowGuest;
  late final StreamSubscription<String?> _subscription;
  bool _closed = false;
  bool get current =>
      !_closed &&
      (allowGuest && user == null || user != null && session != null) &&
      user == currentUser() &&
      session == currentSession();
  void check() {
    if (!current) throw const AuthenticatedRequestChanged();
  }

  Future<T> run<T>(Future<T> Function() action) async {
    check();
    try {
      final value = await action();
      check();
      return value;
    } catch (_) {
      check();
      rethrow;
    }
  }

  Future<void> close() async {
    _closed = true;
    await _subscription.cancel();
  }
}
