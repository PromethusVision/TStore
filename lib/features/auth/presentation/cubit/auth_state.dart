import 'package:equatable/equatable.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Keeps the recovery route stable while its session is cleaned and verified.
class AuthPasswordRecoveryVerifying extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthPasswordUpdated extends AuthState {}

class AuthPasswordRecoveryFailed extends AuthState {
  const AuthPasswordRecoveryFailed(this.failure);

  final PasswordRecoveryFailure failure;

  @override
  List<Object?> get props => [failure];
}

class AuthEmailConfirmationRequired extends AuthState {
  final String email;

  const AuthEmailConfirmationRequired(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthConfirmationResent extends AuthState {
  final String email;

  const AuthConfirmationResent(this.email);

  @override
  List<Object?> get props => [email];
}
