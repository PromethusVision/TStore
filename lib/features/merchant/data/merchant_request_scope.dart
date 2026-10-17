import 'package:t_store/features/merchant/domain/merchant_repository.dart';

/// Local continuation fence. Server authorization remains mandatory.
class MerchantRequestScope {
  MerchantRequestScope({
    required this.userId,
    required this.sessionKey,
    required this.currentUserId,
    required this.currentSessionKey,
  });

  final String? userId, sessionKey;
  final String? Function() currentUserId, currentSessionKey;
  bool _closed = false;

  void check() {
    if (_closed ||
        userId == null ||
        sessionKey == null ||
        currentUserId() != userId ||
        currentSessionKey() != sessionKey) {
      throw const MerchantRequestChanged();
    }
  }

  void expect(String id) {
    check();
    if (id != userId) throw const MerchantRequestChanged();
  }

  Future<T> run<T>(Future<T> Function() request) async {
    check();
    try {
      final value = await request();
      check();
      return value;
    } catch (_) {
      // An old error must not start a fallback with replacement credentials.
      check();
      rethrow;
    }
  }

  void close() => _closed = true;
}

class MerchantRequestChanged implements Exception {
  const MerchantRequestChanged();
  String get message => merchantSessionChanged;
}
