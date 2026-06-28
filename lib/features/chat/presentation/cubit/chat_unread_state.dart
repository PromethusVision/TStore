import 'package:equatable/equatable.dart';

abstract class ChatUnreadState extends Equatable {
  const ChatUnreadState();

  @override
  List<Object?> get props => [];
}

class ChatUnreadInitial extends ChatUnreadState {}

class ChatUnreadLoading extends ChatUnreadState {}

class ChatUnreadLoaded extends ChatUnreadState {
  final int count;

  const ChatUnreadLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

class ChatUnreadError extends ChatUnreadState {
  final String message;

  const ChatUnreadError(this.message);

  @override
  List<Object?> get props => [message];
}
