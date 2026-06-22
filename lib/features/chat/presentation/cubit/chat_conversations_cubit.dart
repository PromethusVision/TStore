import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';

class ChatConversationsCubit extends Cubit<ChatConversationsState> {
  final ChatRepository repository;

  ChatConversationsCubit({required this.repository})
      : super(ChatConversationsInitial());

  Future<void> loadConversations() async {
    emit(ChatConversationsLoading());

    final result = await repository.getConversations();

    result.fold(
      (error) => emit(ChatConversationsError(error)),
      (threads) => emit(ChatConversationsLoaded(threads)),
    );
  }

  Future<void> refreshConversations() async {
    await loadConversations();
  }
}
