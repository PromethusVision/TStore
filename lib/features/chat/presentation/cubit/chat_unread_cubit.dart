import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';

class ChatUnreadCubit extends Cubit<ChatUnreadState> {
  final ChatRepository chatRepository;
  bool _isLoading = false;

  ChatUnreadCubit({required this.chatRepository}) : super(ChatUnreadInitial());

  Future<void> loadUnreadCount() async {
    await _loadUnreadCount(showLoading: true, preserveLoadedState: false);
  }

  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount(showLoading: true, preserveLoadedState: false);
  }

  Future<void> refreshUnreadCountSilently() async {
    await _loadUnreadCount(showLoading: false, preserveLoadedState: true);
  }

  Future<void> _loadUnreadCount({
    required bool showLoading,
    required bool preserveLoadedState,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    final previousState = state;
    if (showLoading) {
      emit(ChatUnreadLoading());
    }

    try {
      final result = await chatRepository.getUnreadCount();

      result.fold((error) {
        if (preserveLoadedState && previousState is ChatUnreadLoaded) return;
        emit(ChatUnreadError(error));
      }, (count) => emit(ChatUnreadLoaded(count)));
    } finally {
      _isLoading = false;
    }
  }
}
