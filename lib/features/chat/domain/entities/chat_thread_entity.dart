import 'package:equatable/equatable.dart';

class ChatThreadEntity extends Equatable {
  static const String fallbackDisplayName = 'Mağaza görüşmesi';

  final String otherUserId;
  final String displayName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final bool lastMessageIsMine;
  final bool lastMessageIsRead;
  final int unreadCount;

  const ChatThreadEntity({
    required this.otherUserId,
    required this.displayName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.lastMessageIsMine = false,
    this.lastMessageIsRead = false,
    this.unreadCount = 0,
  });

  ChatThreadEntity copyWith({
    String? otherUserId,
    String? displayName,
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? lastMessageIsMine,
    bool? lastMessageIsRead,
    int? unreadCount,
  }) {
    return ChatThreadEntity(
      otherUserId: otherUserId ?? this.otherUserId,
      displayName: displayName ?? this.displayName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageIsMine: lastMessageIsMine ?? this.lastMessageIsMine,
      lastMessageIsRead: lastMessageIsRead ?? this.lastMessageIsRead,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    otherUserId,
    displayName,
    lastMessage,
    lastMessageAt,
    lastMessageIsMine,
    lastMessageIsRead,
    unreadCount,
  ];
}
