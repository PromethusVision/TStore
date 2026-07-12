import 'package:equatable/equatable.dart';
import 'package:t_store/features/cart/domain/entities/qr_verification_entity.dart';

abstract class QrVerificationState extends Equatable {
  const QrVerificationState();

  @override
  List<Object?> get props => [];
}

class QrVerificationInitial extends QrVerificationState {}

class QrVerificationLoading extends QrVerificationState {}

class QrVerificationLoaded extends QrVerificationState {
  final QrVerificationEntity verification;

  const QrVerificationLoaded(this.verification);

  @override
  List<Object?> get props => [verification];
}

class QrVerificationConfirming extends QrVerificationState {
  final QrVerificationEntity verification;

  const QrVerificationConfirming(this.verification);

  @override
  List<Object?> get props => [verification];
}

class QrVerificationSuccess extends QrVerificationState {
  final QrVerificationEntity verification;

  const QrVerificationSuccess(this.verification);

  @override
  List<Object?> get props => [verification];
}

class QrVerificationFailure extends QrVerificationState {
  final String message;

  const QrVerificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
