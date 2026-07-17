import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class SignUpUsecase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  @override
  Future<Either<String, UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      privacyNoticeVersion: params.privacyNoticeVersion,
      termsOfUseVersion: params.termsOfUseVersion,
      phone: params.phone,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String fullName;
  final String privacyNoticeVersion;
  final String termsOfUseVersion;
  final String? phone;

  SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.privacyNoticeVersion,
    required this.termsOfUseVersion,
    this.phone,
  });
}
