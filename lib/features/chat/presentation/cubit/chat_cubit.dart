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
  bool _isDisposing = false;
  int _messagesListenerGeneration = 0;

  bool get _canEmit => !_isDisposing && !isClosed;

  void startListening() {
    final listenerGeneration = ++_messagesListenerGeneration;
    unawaited(_messagesSubscription?.cancel());
    _messagesSubscription = repository.messagesStream.listen((message) {
      if (!_canEmit || listenerGeneration != _messagesListenerGeneration) {
        return;
      }
      if (_currentOtherUserId != null &&
          _hasLoadedCurrentConversation &&
          (message.senderId == _currentOtherUserId ||
              message.receiverId == _currentOtherUserId)) {
        if (!_upsertMessage(message)) return;

        emit(NewMessageReceived(message));
        _emitLoaded();
      }
    }, onError: (_, _) {});
  }

  Future<void> getMessages(String otherUserId, {bool refresh = false}) async {
    if (_isLoadingMessages || !_canEmit) return;

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
      if (!_canEmit || _currentOtherUserId != otherUserId) return;

      result.fold(
        (error) {
          _hasLoadedCurrentConversation = true;
          emit(ChatError(error));
          if (!isInitialPage) {
            _emitLoaded();
          }
        },
        (messages) {
          _mergeMessages(messages);
          _hasLoadedCurrentConversation = true;
          _hasReachedMax = messages.length < _limit;
          _currentPage++;
          _emitLoaded();
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

  Future<void> refreshMessagesSilently(String otherUserId) async {
    if (_isLoadingMessages ||
        !_hasLoadedCurrentConversation ||
        _currentOtherUserId != otherUserId) {
      return;
    }

    _isLoadingMessages = true;
    try {
      final result = await repository.getMessages(
        otherUserId: otherUserId,
        page: 0,
        limit: _limit,
      );
      if (!_canEmit || _currentOtherUserId != otherUserId) return;

      result.fold((_) {}, (messages) {
        _mergeMessages(messages);
        if (_currentPage <= 1) {
          _hasReachedMax = messages.length < _limit;
        }
        _emitLoaded();
      });
    } finally {
      _isLoadingMessages = false;
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    if (_isSendingMessage || !_canEmit) return;

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
      if (!_canEmit) return;

      _isSendingMessage = false;
      result.fold((error) => emit(ChatError(error)), (message) {
        _upsertMessage(message);
        emit(MessageSent(message));
        _emitLoaded();
      });
    } catch (_) {
      if (_canEmit) {
        _isSendingMessage = false;
        emit(const ChatError('Mesaj gönderilemedi. Lütfen tekrar deneyin.'));
      }
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

  bool _upsertMessage(ChatMessageEntity message) {
    final existingIndex = _messages.indexWhere((item) => item.id == message.id);
    if (existingIndex >= 0) {
      if (_messages[existingIndex] == message) return false;
      _messages[existingIndex] = message;
    } else {
      _messages = [message, ..._messages];
    }

    _messages.sort(_compareNewestFirst);
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

  void _emitLoaded() {
    if (!_canEmit) return;
    emit(
      ChatLoaded(
        messages: _messages,
        hasReachedMax: _hasReachedMax,
        isSending: _isSendingMessage,
      ),
    );
  }

  @override
  Future<void> close() async {
    _isDisposing = true;
    _messagesListenerGeneration++;
    final subscription = _messagesSubscription;
    _messagesSubscription = null;
    await subscription?.cancel();
    await super.close();
  }
}
