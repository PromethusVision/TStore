import 'package:dartz/dartz.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUsecase(this.repository, {this.beforeSignOut});
  final Future<void> Function()? beforeSignOut;

  @override
  Future<Either<String, void>> call(NoParams params) async {
    try {
      await beforeSignOut?.call();
    } catch (_) {
      return const Left(
        'Bildirim bağlantısı kapatılamadı. Çıkışı yeniden deneyin.',
      );
    }
    return await repository.signOut();
  }
}
