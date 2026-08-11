import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/chat/data/services/chat_realtime_snapshot_tracker.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';

void main() {
  const firstMessage = ChatMessageEntity(
    id: 'message-1',
    senderId: 'shop-owner',
    receiverId: 'customer',
    content: 'Merhaba',
  );
  const secondMessage = ChatMessageEntity(
    id: 'message-2',
    senderId: 'shop-owner',
    receiverId: 'customer',
    content: 'Ürün hazır',
  );

  test('ilk Supabase snapshotındaki mesajları bir kez yayınlar', () {
    final tracker = ChatRealtimeSnapshotTracker();

    expect(
      tracker.changesSinceLast(const [firstMessage, secondMessage]),
      const [firstMessage, secondMessage],
    );
  });

  test('reconnect sonrası aynı snapshotı tekrar yayınlamaz', () {
    final tracker = ChatRealtimeSnapshotTracker();
    tracker.changesSinceLast(const [firstMessage, secondMessage]);

    expect(
      tracker.changesSinceLast(const [firstMessage, secondMessage]),
      isEmpty,
    );
  });

  test('tam snapshot yenilendiğinde yalnız yeni mesajı yayınlar', () {
    final tracker = ChatRealtimeSnapshotTracker();
    tracker.changesSinceLast(const [firstMessage]);

    expect(
      tracker.changesSinceLast(const [firstMessage, secondMessage]),
      const [secondMessage],
    );
  });

  test('aynı kimlikli mesajın okundu güncellemesini yayınlar', () {
    final tracker = ChatRealtimeSnapshotTracker();
    tracker.changesSinceLast(const [firstMessage]);
    final readMessage = firstMessage.copyWith(isRead: true);

    expect(tracker.changesSinceLast([readMessage]), [readMessage]);
  });
}
