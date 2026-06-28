import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';

class ChatUnreadCubit extends Cubit<ChatUnreadState> {
  final ChatRepository chatRepository;

  ChatUnreadCubit({required this.chatRepository})
      : super(ChatUnreadInitial());

  Future<void> loadUnreadCount() async {
    emit(ChatUnreadLoading());

    final result = await chatRepository.getUnreadCount();

    result.fold(
      (error) => emit(ChatUnreadError(error)),
      (count) => emit(ChatUnreadLoaded(count)),
    );
  }

  Future<void> refreshUnreadCount() async {
    await loadUnreadCount();
  }
}
