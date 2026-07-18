import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/usecases/usecase.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/resend_confirmation_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:t_store/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const Duration _userInitiatedSignOutWindow = Duration(seconds: 5);

  final SignInUsecase signInUsecase;
  final SignUpUsecase signUpUsecase;
  final SignOutUsecase signOutUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final ResendConfirmationUsecase resendConfirmationUsecase;
  final UpdatePasswordUsecase updatePasswordUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  DateTime? _userInitiatedSignOutAt;

  AuthCubit({
    required this.signInUsecase,
    required this.signUpUsecase,
    required this.signOutUsecase,
    required this.resetPasswordUsecase,
    required this.resendConfirmationUsecase,
    required this.updatePasswordUsecase,
    required this.getCurrentUserUsecase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await getCurrentUserUsecase(const NoParams());

    result.fold((error) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    final result = await signInUsecase(
      SignInParams(email: email, password: password),
    );

    result.fold((error) {
      if (error.contains('doğrulamanız gerekiyor')) {
        emit(AuthEmailConfirmationRequired(email));
      } else {
        emit(AuthError(error));
      }
    }, (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String privacyNoticeVersion,
    required String termsOfUseVersion,
    String? phone,
  }) async {
    emit(AuthLoading());

    final result = await signUpUsecase(
      SignUpParams(
        email: email,
        password: password,
        fullName: fullName,
        privacyNoticeVersion: privacyNoticeVersion,
        termsOfUseVersion: termsOfUseVersion,
        phone: phone,
      ),
    );

    result.fold(
      (error) => emit(AuthError(error)),
      (user) => emit(AuthEmailConfirmationRequired(email)),
    );
  }

  Future<void> signOut() async {
    if (state is AuthLoading) return;

    _userInitiatedSignOutAt = DateTime.now();
    emit(AuthLoading());

    final result = await signOutUsecase(const NoParams());

    result.fold((error) {
      _userInitiatedSignOutAt = null;
      emit(AuthError(error));
    }, (_) => emit(AuthUnauthenticated()));
  }

  bool handleSignedOutEvent() {
    final requestedAt = _userInitiatedSignOutAt;
    final isUserInitiated =
        requestedAt != null &&
        DateTime.now().difference(requestedAt) <= _userInitiatedSignOutWindow;

    _userInitiatedSignOutAt = null;
    if (state is! AuthUnauthenticated) {
      emit(AuthUnauthenticated());
    }

    return isUserInitiated;
  }

  Future<void> resetPassword(String email) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    final result = await resetPasswordUsecase(email);

    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthPasswordResetSent(email)),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    final result = await updatePasswordUsecase(newPassword);

    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthPasswordUpdated()),
    );
  }

  Future<void> resendConfirmation(String email) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    final result = await resendConfirmationUsecase(email);

    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthConfirmationResent(email)),
    );
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  void syncUserProfile(UserEntity user) {
    final currentState = state;
    if (currentState is AuthAuthenticated && currentState.user.id == user.id) {
      emit(AuthAuthenticated(user));
    }
  }
}
