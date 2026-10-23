import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';

const chatPeer = '33333333-3333-4333-8333-333333333333';
const chatThread = ChatThreadEntity(
  otherUserId: chatPeer,
  displayName: 'Deneme müşterisi',
  lastMessage: 'Powerbank mevcut mu?',
  lastMessageAt: null,
  unreadCount: 1,
);
const incomingChat = ChatMessageEntity(
  id: 'incoming',
  senderId: chatPeer,
  receiverId: MerchantPreview.userId,
  content: 'Powerbank mevcut mu?',
);

class MerchantChatFake implements ChatRepository {
  final events = StreamController<ChatMessageEntity>.broadcast(sync: true);
  List<ChatThreadEntity> threads = [chatThread];
  List<ChatMessageEntity> messages = [incomingChat];
  Future<Either<String, List<ChatThreadEntity>>> Function()? readThreads;
  Future<Either<String, List<ChatMessageEntity>>> Function()? readMessages;
  Future<Either<String, ChatMessageEntity>> Function(String)? send;
  int reads = 0, writes = 0, marked = 0, counts = 0;
  @override
  Future<Either<String, List<ChatThreadEntity>>> getConversations() async =>
      readThreads == null ? Right(threads) : readThreads!();
  @override
  Future<Either<String, List<ChatMessageEntity>>> getMessages({
    required String otherUserId,
    int page = 0,
    int limit = 50,
  }) async {
    reads++;
    return readMessages == null ? Right(messages) : readMessages!();
  }

  @override
  Future<Either<String, ChatMessageEntity>> sendMessage({
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
  }) async {
    writes++;
    if (send != null) return send!(content);
    final m = ChatMessageEntity(
      id: 'reply-$writes',
      senderId: MerchantPreview.userId,
      receiverId: receiverId,
      content: content,
    );
    messages = [m, ...messages];
    return Right(m);
  }

  @override
  Future<Either<String, void>> markAsRead(String id) async {
    marked++;
    return const Right(null);
  }

  @override
  Future<Either<String, void>> markAllAsRead(String id) async {
    marked++;
    messages = messages.map((m) => m.copyWith(isRead: true)).toList();
    return const Right(null);
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    counts++;
    return Right(
      messages
          .where((m) => m.receiverId == MerchantPreview.userId && !m.isRead)
          .length,
    );
  }

  @override
  Stream<ChatMessageEntity> get messagesStream => events.stream;
}
