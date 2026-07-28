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
  final bool isStatusCheckDelayed;

  const QrSessionCreated(this.session, {this.isStatusCheckDelayed = false});

  @override
  List<Object?> get props => [session, isStatusCheckDelayed];
}

class QrSessionCompleted extends QrSessionState {
  final String sessionId;

  const QrSessionCompleted({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class QrSessionCancelled extends QrSessionState {
  const QrSessionCancelled();
}

class QrSessionExpired extends QrSessionState {
  const QrSessionExpired();
}

class QrSessionFailure extends QrSessionState {
  final String message;

  const QrSessionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
