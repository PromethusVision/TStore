import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/domain/repositories/chat_repository.dart';

/// A route-owned fence over the existing chat contract, not another chat store.
/// The Merchant host owns authority revision, including between-frame changes.
class MerchantChatRepository implements ChatRepository {
  MerchantChatRepository({
    required this.delegate,
    required this.ownerId,
    required this.isCurrent,
    this.readTimeout = const Duration(seconds: 15),
  });
  final ChatRepository delegate;
  final String ownerId;
  final bool Function() isCurrent;
  final Duration readTimeout;
  bool _closed = false;
  bool get current => !_closed && isCurrent();
  void dispose() => _closed = true;
  static const expired = 'Oturumunuz değişti. Mesajları yeniden açın.';
  static const unavailable = 'Mesajlar yüklenemedi. Lütfen tekrar deneyin.';

  Future<Either<String, T>> _run<T>(
    Future<Either<String, T>> Function() action, {
    bool read = true,
  }) async {
    if (!current) return const Left(expired);
    try {
      final pending = action();
      final result = read ? await pending.timeout(readTimeout) : await pending;
      return current ? result : const Left(expired);
    } catch (_) {
      return Left(
        current
            ? (read
                  ? unavailable
                  : 'İşlem sonucu doğrulanamadı. Mesajları yenileyerek kontrol edin.')
            : expired,
      );
    }
  }

  bool _pair(ChatMessageEntity m, String other) =>
      m.senderId == ownerId && m.receiverId == other ||
      m.senderId == other && m.receiverId == ownerId;

  @override
  Future<Either<String, List<ChatMessageEntity>>> getMessages({
    required String otherUserId,
    int page = 0,
    int limit = 50,
  }) async {
    final result = await _run(
      () => delegate.getMessages(
        otherUserId: otherUserId,
        page: page,
        limit: limit,
      ),
    );
    return result.map(
      (rows) => rows.where((m) => _pair(m, otherUserId)).toList(),
    );
  }

  @override
  Future<Either<String, List<ChatThreadEntity>>> getConversations() async {
    final result = await _run(delegate.getConversations);
    return result.map(
      (rows) => rows
          .where(
            (r) => r.otherUserId.trim().isNotEmpty && r.otherUserId != ownerId,
          )
          .map(
            (r) => r.copyWith(
              displayName:
                  r.displayName == ChatThreadEntity.fallbackDisplayName ||
                      r.displayName.trim().isEmpty
                  ? 'Müşteri görüşmesi'
                  : r.displayName,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Either<String, int>> getUnreadCount() => _run(delegate.getUnreadCount);
  @override
  Future<Either<String, ChatMessageEntity>> sendMessage({
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
  }) => _run(
    () => delegate.sendMessage(
      receiverId: receiverId,
      content: content,
      messageType: messageType,
    ),
    read: false,
  );
  @override
  Future<Either<String, void>> markAsRead(String messageId) =>
      _run(() => delegate.markAsRead(messageId), read: false);
  @override
  Future<Either<String, void>> markAllAsRead(String senderId) =>
      _run(() => delegate.markAllAsRead(senderId), read: false);
  @override
  Stream<ChatMessageEntity> get messagesStream => current
      ? delegate.messagesStream.where((m) => current && m.receiverId == ownerId)
      : const Stream.empty();
}
