import 'package:equatable/equatable.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';

abstract class ChatConversationsState extends Equatable {
  const ChatConversationsState();

  @override
  List<Object?> get props => [];
}

class ChatConversationsInitial extends ChatConversationsState {}

class ChatConversationsLoading extends ChatConversationsState {}

class ChatConversationsLoaded extends ChatConversationsState {
  final List<ChatThreadEntity> threads;

  const ChatConversationsLoaded(this.threads);

  @override
  List<Object?> get props => [threads];
}

class ChatConversationsError extends ChatConversationsState {
  final String message;

  const ChatConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}
