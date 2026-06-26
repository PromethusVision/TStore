import 'package:equatable/equatable.dart';

class ChatThreadEntity extends Equatable {
  final String otherUserId;
  final String displayName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatThreadEntity({
    required this.otherUserId,
    required this.displayName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  ChatThreadEntity copyWith({
    String? otherUserId,
    String? displayName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatThreadEntity(
      otherUserId: otherUserId ?? this.otherUserId,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        otherUserId,
        displayName,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
