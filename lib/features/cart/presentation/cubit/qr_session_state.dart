import 'package:equatable/equatable.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';

abstract class QrSessionState extends Equatable {
  const QrSessionState();

  @override
  List<Object?> get props => [];
}

class QrSessionInitial extends QrSessionState {}

class QrSessionLoading extends QrSessionState {}

class QrSessionCreated extends QrSessionState {
  final QrSessionEntity session;

  const QrSessionCreated(this.session);

  @override
  List<Object?> get props => [session];
}

class QrSessionCompleted extends QrSessionState {}

class QrSessionFailure extends QrSessionState {
  final String message;

  const QrSessionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
