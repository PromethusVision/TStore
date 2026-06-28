import 'package:equatable/equatable.dart';

enum MessageType { text, image, system }

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final bool isRead;
  final DateTime? createdAt;

  // Joined data
  final String? senderName;
  final String? senderAvatar;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    this.isRead = false,
    this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  bool isFromUser(String userId) => senderId == userId;

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        content,
        messageType,
        isRead,
        createdAt,
      ];

  ChatMessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? messageType,
    bool? isRead,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatar,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }
}
