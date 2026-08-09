import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/chat_message_rules.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  StreamSubscription<ChatMessageEntity>? _messagesSubscription;

  ChatCubit({required this.repository}) : super(ChatInitial());

  List<ChatMessageEntity> _messages = [];
  int _currentPage = 0;
  static const int _limit = 50;
  String? _currentOtherUserId;
  bool _hasLoadedCurrentConversation = false;
  bool _isSendingMessage = false;
  bool _isLoadingMessages = false;
  bool _hasReachedMax = false;

  void startListening() {
    _messagesSubscription?.cancel();
    _messagesSubscription = repository.messagesStream.listen((message) {
      if (_currentOtherUserId != null &&
          _hasLoadedCurrentConversation &&
          (message.senderId == _currentOtherUserId ||
              message.receiverId == _currentOtherUserId)) {
        if (!_addMessageIfNew(message)) return;

        emit(NewMessageReceived(message));
        emit(ChatLoaded(messages: _messages, hasReachedMax: _hasReachedMax));
      }
    });
  }

  Future<void> getMessages(String otherUserId, {bool refresh = false}) async {
    if (_isLoadingMessages) return;

    _isLoadingMessages = true;
    _currentOtherUserId = otherUserId;

    if (refresh) {
      _currentPage = 0;
      _messages = [];
      _hasLoadedCurrentConversation = false;
      _hasReachedMax = false;
    }

    final isInitialPage = _currentPage == 0;
    if (isInitialPage) {
      emit(ChatLoading());
    }

    try {
      final result = await repository.getMessages(
        otherUserId: otherUserId,
        page: _currentPage,
        limit: _limit,
      );

      result.fold(
        (error) {
          _hasLoadedCurrentConversation = true;
          emit(ChatError(error));
          if (!isInitialPage) {
            emit(
              ChatLoaded(messages: _messages, hasReachedMax: _hasReachedMax),
            );
          }
        },
        (messages) {
          _mergeMessages(messages);
          _hasLoadedCurrentConversation = true;
          _hasReachedMax = messages.length < _limit;
          _currentPage++;
          emit(ChatLoaded(messages: _messages, hasReachedMax: _hasReachedMax));
        },
      );
    } finally {
      _isLoadingMessages = false;
    }
  }

  Future<void> loadMoreMessages(String otherUserId) async {
    if (_isLoadingMessages ||
        _hasReachedMax ||
        _currentOtherUserId != otherUserId) {
      return;
    }

    await getMessages(otherUserId);
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    if (_isSendingMessage) return;

    final validationError = ChatMessageRules.validationError(content);
    if (validationError != null) {
      emit(ChatError(validationError));
      return;
    }

    final normalizedContent = ChatMessageRules.normalizeText(content);

    _isSendingMessage = true;
    emit(MessageSending());

    try {
      final result = await repository.sendMessage(
        receiverId: receiverId,
        content: normalizedContent,
        messageType: messageType,
      );

      result.fold((error) => emit(ChatError(error)), (message) {
        _addMessageIfNew(message);
        emit(MessageSent(message));
        emit(ChatLoaded(messages: _messages, hasReachedMax: _hasReachedMax));
      });
    } finally {
      _isSendingMessage = false;
    }
  }

  Future<void> markAsRead(String messageId) async {
    await repository.markAsRead(messageId);
  }

  Future<void> markAllAsRead(String senderId) async {
    await repository.markAllAsRead(senderId);
  }

  bool _addMessageIfNew(ChatMessageEntity message) {
    if (_messages.any((item) => item.id == message.id)) return false;

    _messages = [message, ..._messages]..sort(_compareNewestFirst);
    return true;
  }

  void _mergeMessages(List<ChatMessageEntity> messages) {
    final messageById = <String, ChatMessageEntity>{};

    for (final message in [..._messages, ...messages]) {
      messageById[message.id] = message;
    }

    _messages = messageById.values.toList()..sort(_compareNewestFirst);
  }

  int _compareNewestFirst(ChatMessageEntity a, ChatMessageEntity b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final dateCompare = bDate.compareTo(aDate);

    if (dateCompare != 0) return dateCompare;
    return b.id.compareTo(a.id);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
