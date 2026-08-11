import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';

/// Converts Supabase's full-table stream snapshots into new or changed rows.
class ChatRealtimeSnapshotTracker {
  Map<String, ChatMessageEntity> _previousMessageById = {};

  List<ChatMessageEntity> changesSinceLast(
    Iterable<ChatMessageEntity> snapshot,
  ) {
    final nextMessageById = <String, ChatMessageEntity>{};
    final changes = <ChatMessageEntity>[];

    for (final message in snapshot) {
      nextMessageById[message.id] = message;
      if (_previousMessageById[message.id] != message) {
        changes.add(message);
      }
    }

    _previousMessageById = nextMessageById;
    return changes;
  }
}
