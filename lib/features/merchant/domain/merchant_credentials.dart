import 'package:dartz/dartz.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

/// Small host port, backed by the existing shared AuthRepository.
abstract interface class MerchantCredentials {
  Future<Either<String, void>> signIn(String email, String password);
  Future<Either<String, void>> signOut();
}

class SharedMerchantCredentials implements MerchantCredentials {
  const SharedMerchantCredentials(this.auth);
  final AuthRepository auth;
  @override
  Future<Either<String, void>> signIn(String email, String password) async =>
      (await auth.signIn(email: email.trim(), password: password)).map((_) {});
  @override
  Future<Either<String, void>> signOut() => auth.signOut();
}
