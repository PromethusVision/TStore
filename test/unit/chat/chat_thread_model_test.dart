import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/chat/data/models/chat_thread_model.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';

void main() {
  test('konuşma özetini kullanıcıya gösterilecek kayda dönüştürür', () {
    final thread = ChatThreadModel.fromConversationSummary({
      'other_user_id': 'owner-1',
      'last_message': 'Ürün mağazada hazır.',
      'last_message_at': '2026-08-10T12:30:00.000Z',
      'last_message_is_mine': true,
      'last_message_is_read': true,
      'unread_count': 3,
    });

    expect(thread.otherUserId, 'owner-1');
    expect(thread.displayName, ChatThreadEntity.fallbackDisplayName);
    expect(thread.lastMessage, 'Ürün mağazada hazır.');
    expect(thread.lastMessageAt, DateTime.utc(2026, 8, 10, 12, 30));
    expect(thread.lastMessageIsMine, isTrue);
    expect(thread.lastMessageIsRead, isTrue);
    expect(thread.unreadCount, 3);
  });

  test('boş isteğe bağlı alanları güvenli varsayılanlarla karşılar', () {
    final thread = ChatThreadModel.fromConversationSummary({
      'other_user_id': 'owner-2',
      'last_message': 'Merhaba',
      'last_message_at': null,
      'last_message_is_mine': null,
      'last_message_is_read': null,
      'unread_count': '2',
    });

    expect(thread.lastMessageAt, isNull);
    expect(thread.lastMessageIsMine, isFalse);
    expect(thread.lastMessageIsRead, isFalse);
    expect(thread.unreadCount, 2);
  });
}
