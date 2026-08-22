import 'package:equatable/equatable.dart';

/// The user identity captured from a verified password-recovery callback.
///
/// This object intentionally contains no token, session, or password value.
class PasswordRecoveryIdentity extends Equatable {
  const PasswordRecoveryIdentity({required this.userId, required this.email});

  final String userId;
  final String email;

  bool get isValid => userId.trim().isNotEmpty && email.trim().isNotEmpty;

  @override
  List<Object?> get props => [userId, email];
}

enum PasswordRecoveryFailureReason {
  invalidRecoverySession,
  passwordUpdateRejected,
  invalidUpdateResponse,
  sessionCleanupFailed,
  freshLoginInvalidCredentials,
  freshLoginFailed,
  identityMismatch,
}

class PasswordRecoveryFailure extends Equatable {
  const PasswordRecoveryFailure({required this.reason, required this.message});

  final PasswordRecoveryFailureReason reason;
  final String message;

  @override
  List<Object?> get props => [reason, message];
}

class PasswordRecoveryVerification extends Equatable {
  const PasswordRecoveryVerification({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Carries the opaque password only for the duration of the recovery request.
///
/// It deliberately does not implement value equality or `toString`, preventing
/// accidental password disclosure through state, diagnostics, or test output.
class UpdatePasswordParams {
  const UpdatePasswordParams({
    required this.newPassword,
    required this.recoveryIdentity,
  });

  final String newPassword;
  final PasswordRecoveryIdentity recoveryIdentity;
}
