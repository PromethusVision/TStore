import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';

class ChatThreadModel extends ChatThreadEntity {
  const ChatThreadModel({
    required super.otherUserId,
    required super.displayName,
    required super.lastMessage,
    required super.lastMessageAt,
    super.lastMessageIsMine,
    super.lastMessageIsRead,
    super.unreadCount,
  });

  factory ChatThreadModel.fromConversationSummary(Map<String, dynamic> json) {
    return ChatThreadModel(
      otherUserId: json['other_user_id'] as String,
      displayName: ChatThreadEntity.fallbackDisplayName,
      lastMessage: json['last_message'] as String,
      lastMessageAt: _toNullableDateTime(json['last_message_at']),
      lastMessageIsMine: json['last_message_is_mine'] as bool? ?? false,
      lastMessageIsRead: json['last_message_is_read'] as bool? ?? false,
      unreadCount: _toInt(json['unread_count']),
    );
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
