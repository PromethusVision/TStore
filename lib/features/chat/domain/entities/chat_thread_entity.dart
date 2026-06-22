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

  @override
  List<Object?> get props => [
        otherUserId,
        displayName,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
