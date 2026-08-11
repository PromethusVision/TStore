import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/chat/data/models/chat_message_model.dart';
import 'package:t_store/features/chat/data/models/chat_thread_model.dart';
import 'package:t_store/features/chat/data/services/chat_realtime_snapshot_tracker.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseService supabaseService;
  StreamController<ChatMessageEntity>? _messagesController;
  StreamSubscription? _messagesRealtimeSubscription;
  int _messagesStreamGeneration = 0;

  ChatRepositoryImpl({required this.supabaseService});

  static const String _messageSelect =
      'id, sender_id, receiver_id, content, message_type, is_read, created_at';
  static const String _conversationSummariesRpc = 'get_customer_conversations';
  static const String _unreadCountRpc = 'get_customer_unread_chat_count';
  static const int _realtimeMessageLimit = 50;

  String get _userId => supabaseService.currentUser?.id ?? '';

  @override
  Future<Either<String, List<ChatMessageEntity>>> getMessages({
    required String otherUserId,
    int page = 0,
    int limit = 50,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      final from = page * limit;
      final to = from + limit - 1;

      final response = await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .select(_messageSelect)
          .or(
            'and(sender_id.eq.$_userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$_userId)',
          )
          .order('created_at', ascending: false)
          .range(from, to);

      final messages = (response as List)
          .map(
            (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(messages);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Mesajlar yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, ChatMessageEntity>> sendMessage({
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      final response = await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .insert({
            'sender_id': _userId,
            'receiver_id': receiverId,
            'content': content,
            'message_type': messageType.name,
          })
          .select(_messageSelect)
          .single();

      return Right(ChatMessageModel.fromJson(response));
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Mesaj gönderilemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String messageId) async {
    try {
      await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .update({'is_read': true})
          .eq('id', messageId)
          .eq('receiver_id', _userId);

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Mesaj okundu olarak işaretlenemedi.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead(String senderId) async {
    try {
      await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', _userId)
          .eq('is_read', false);

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Mesajlar okundu olarak işaretlenemedi.',
        ),
      );
    }
  }

  @override
  Stream<ChatMessageEntity> get messagesStream {
    if (_userId.isEmpty) {
      return Stream.empty();
    }

    final streamGeneration = ++_messagesStreamGeneration;
    _cancelMessagesRealtimeSubscription();
    final previousController = _messagesController;
    _messagesController = null;
    if (previousController != null && !previousController.isClosed) {
      unawaited(previousController.close());
    }

    final snapshotTracker = ChatRealtimeSnapshotTracker();
    late final StreamController<ChatMessageEntity> controller;
    controller = StreamController<ChatMessageEntity>.broadcast(
      onCancel: () => _disposeMessagesStream(streamGeneration, controller),
    );
    _messagesController = controller;

    _messagesRealtimeSubscription = supabaseService.client
        .from(SupabaseTables.chatMessages)
        .stream(primaryKey: ['id'])
        .eq('receiver_id', _userId)
        .order('created_at', ascending: false)
        .limit(_realtimeMessageLimit)
        .listen(
          (data) {
            if (!_isActiveMessagesStream(streamGeneration, controller)) return;

            final snapshot = <ChatMessageEntity>[];
            for (final item in data) {
              try {
                snapshot.add(ChatMessageModel.fromJson(item));
              } catch (_) {}
            }

            for (final message in snapshotTracker.changesSinceLast(snapshot)) {
              if (!_isActiveMessagesStream(streamGeneration, controller)) {
                return;
              }
              controller.add(message);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!_isActiveMessagesStream(streamGeneration, controller)) return;
            controller.addError(error, stackTrace);
          },
          onDone: () {
            if (!_isActiveMessagesStream(streamGeneration, controller)) return;
            unawaited(controller.close());
          },
        );

    return controller.stream;
  }

  void _cancelMessagesRealtimeSubscription() {
    final subscription = _messagesRealtimeSubscription;
    _messagesRealtimeSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  bool _isActiveMessagesStream(
    int streamGeneration,
    StreamController<ChatMessageEntity> controller,
  ) {
    return streamGeneration == _messagesStreamGeneration &&
        identical(_messagesController, controller) &&
        !controller.isClosed;
  }

  void _disposeMessagesStream(
    int streamGeneration,
    StreamController<ChatMessageEntity> controller,
  ) {
    if (!_isActiveMessagesStream(streamGeneration, controller)) return;

    _messagesStreamGeneration++;
    _cancelMessagesRealtimeSubscription();
    _messagesController = null;
    if (!controller.isClosed) {
      unawaited(controller.close());
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    if (_userId.isEmpty) {
      return const Right(0);
    }

    try {
      final response = await supabaseService.client.rpc(_unreadCountRpc);
      return Right(_parseCount(response));
    } catch (e) {
      if (_isMissingRpc(e, _unreadCountRpc)) {
        return _getUnreadCountLegacy();
      }

      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Okunmamış mesaj sayısı alınamadı.',
        ),
      );
    }
  }

  Future<Either<String, int>> _getUnreadCountLegacy() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .select('id')
          .eq('receiver_id', _userId)
          .eq('is_read', false);

      return Right((response as List).length);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Okunmamış mesaj sayısı alınamadı.',
        ),
      );
    }
  }

  @override
  Future<Either<String, List<ChatThreadEntity>>> getConversations() async {
    if (_userId.isEmpty) {
      return const Left(CustomerErrorMessage.signInRequired);
    }

    try {
      final response = await supabaseService.client.rpc(
        _conversationSummariesRpc,
      );
      final threads = (response as List)
          .map(
            (json) => ChatThreadModel.fromConversationSummary(
              json as Map<String, dynamic>,
            ),
          )
          .toList();

      return Right(threads);
    } catch (e) {
      if (_isMissingRpc(e, _conversationSummariesRpc)) {
        return _getConversationsLegacy();
      }

      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Konuşmalar yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  Future<Either<String, List<ChatThreadEntity>>>
  _getConversationsLegacy() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.chatMessages)
          .select(_messageSelect)
          .or('sender_id.eq.$_userId,receiver_id.eq.$_userId')
          .order('created_at', ascending: false);

      final messages = (response as List)
          .map(
            (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final groupedMessages = <String, List<ChatMessageEntity>>{};
      for (final message in messages) {
        final otherUserId = message.senderId == _userId
            ? message.receiverId
            : message.senderId;
        groupedMessages.putIfAbsent(otherUserId, () => []).add(message);
      }

      final threads =
          groupedMessages.entries.map((entry) {
            final threadMessages = entry.value;
            final latestMessage = threadMessages.first;
            final unreadCount = threadMessages
                .where(
                  (message) =>
                      message.receiverId == _userId && message.isRead == false,
                )
                .length;

            return ChatThreadEntity(
              otherUserId: entry.key,
              displayName: ChatThreadEntity.fallbackDisplayName,
              lastMessage: latestMessage.content,
              lastMessageAt: latestMessage.createdAt,
              lastMessageIsMine: latestMessage.senderId == _userId,
              lastMessageIsRead: latestMessage.isRead,
              unreadCount: unreadCount,
            );
          }).toList()..sort((a, b) {
            final aDate =
                a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

      return Right(threads);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Konuşmalar yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  int _parseCount(dynamic value) {
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;

    throw const FormatException('Unread chat count is not numeric.');
  }

  bool _isMissingRpc(Object error, String functionName) {
    if (error is! PostgrestException) return false;

    if (error.code == 'PGRST202' || error.code == '42883') return true;

    final normalizedMessage = error.message.toLowerCase();
    return normalizedMessage.contains(functionName.toLowerCase()) &&
        normalizedMessage.contains('could not find');
  }
}
