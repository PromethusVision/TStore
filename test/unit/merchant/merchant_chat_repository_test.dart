import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/merchant/data/merchant_chat_repository.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import '../../support/merchant_chat_fakes.dart';

void main() {
  late MerchantChatFake fake;
  late MerchantChatRepository repository;
  var current = true;
  setUp(() {
    fake = MerchantChatFake();
    current = true;
    repository = MerchantChatRepository(
      delegate: fake,
      ownerId: MerchantPreview.userId,
      isCurrent: () => current,
      readTimeout: const Duration(milliseconds: 20),
    );
  });
  tearDown(() async {
    repository.dispose();
    await fake.events.close();
  });
  test('expired route cannot dispatch reads or mutations', () async {
    current = false;
    expect(
      (await repository.getMessages(otherUserId: chatPeer)).isLeft(),
      true,
    );
    expect(
      (await repository.sendMessage(
        receiverId: chatPeer,
        content: 'no',
      )).isLeft(),
      true,
    );
    expect((await repository.markAllAsRead(chatPeer)).isLeft(), true);
    expect((await repository.getUnreadCount()).isLeft(), true);
    expect([fake.reads, fake.writes, fake.marked, fake.counts], [0, 0, 0, 0]);
  });
  test('late read or send cannot return old account data', () async {
    final response = Completer<Either<String, List<ChatMessageEntity>>>();
    fake.readMessages = () => response.future;
    final read = repository.getMessages(otherUserId: chatPeer);
    current = false;
    response.complete(const Right([incomingChat]));
    expect((await read).isLeft(), true);
    current = true;
    final write = Completer<Either<String, ChatMessageEntity>>();
    fake.send = (_) => write.future;
    final sent = repository.sendMessage(receiverId: chatPeer, content: 'reply');
    current = false;
    write.complete(const Right(incomingChat));
    expect((await sent).isLeft(), true);
    expect(fake.writes, 1);
  });
  test('read deadline is finite and never retries transport', () async {
    final response = Completer<Either<String, List<ChatMessageEntity>>>();
    fake.readMessages = () => response.future;
    expect(
      (await repository.getMessages(otherUserId: chatPeer)).isLeft(),
      true,
    );
    response.complete(const Right([incomingChat]));
    expect(fake.reads, 1);
  });
  test(
    'writes remain pending past read deadline and do not auto replay',
    () async {
      final response = Completer<Either<String, ChatMessageEntity>>();
      fake.send = (_) => response.future;
      var finished = false;
      final pending = repository
          .sendMessage(receiverId: chatPeer, content: 'reply')
          .then((r) {
            finished = true;
            return r;
          });
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(finished, false);
      expect(fake.writes, 1);
      response.complete(const Right(incomingChat));
      expect((await pending).isRight(), true);
    },
  );
  test('messages and stream stay within owner and peer', () async {
    const other = ChatMessageEntity(
      id: 'other',
      senderId: 'elsewhere',
      receiverId: 'someone',
      content: 'private',
    );
    fake.messages = [incomingChat, other];
    final rows = (await repository.getMessages(
      otherUserId: chatPeer,
    )).getOrElse(() => []);
    expect(rows, [incomingChat]);
    final events = <ChatMessageEntity>[];
    final subscription = repository.messagesStream.listen(events.add);
    fake.events.add(other);
    fake.events.add(incomingChat);
    current = false;
    fake.events.add(incomingChat);
    await Future<void>.delayed(Duration.zero);
    expect(events, [incomingChat]);
    await subscription.cancel();
  });
  test('close retires same-account continuation permanently', () async {
    repository.dispose();
    expect((await repository.getUnreadCount()).isLeft(), true);
    expect(fake.counts, 0);
  });
  test(
    'missing profile name stays generic; no raw identifier is promoted',
    () async {
      fake.threads = [
        chatThread.copyWith(displayName: ChatThreadEntity.fallbackDisplayName),
      ];
      final rows = (await repository.getConversations()).getOrElse(() => []);
      expect(rows.single.displayName, 'Müşteri görüşmesi');
    },
  );
}
