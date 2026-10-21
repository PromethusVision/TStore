import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';

/// Local continuation fence. Server authorization remains mandatory.
class MerchantRequestScope {
  MerchantRequestScope({
    required this.userId,
    required this.sessionKey,
    required this.currentUserId,
    required this.currentSessionKey,
    required Stream<String?> changes,
    required Stream<String?> sessionKeys,
  }) : _scope = AuthenticatedRequestScope(
         user: userId,
         session: sessionKey,
         currentUser: currentUserId,
         currentSession: currentSessionKey,
         changes: changes,
         sessionKeys: sessionKeys,
       );

  final String? userId, sessionKey;
  final String? Function() currentUserId, currentSessionKey;
  final AuthenticatedRequestScope _scope;

  void check() {
    if (!_scope.current) {
      throw const MerchantRequestChanged();
    }
  }

  void expect(String id) {
    check();
    if (id != userId) throw const MerchantRequestChanged();
  }

  Future<T> run<T>(Future<T> Function() request) async {
    try {
      return await _scope.run(request);
    } on AuthenticatedRequestChanged {
      throw const MerchantRequestChanged();
    }
  }

  Future<void> close() => _scope.close();
}

class MerchantRequestChanged implements Exception {
  const MerchantRequestChanged();
  String get message => merchantSessionChanged;
}
