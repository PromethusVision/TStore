import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}

void main() {
  late MockChatCubit chatCubit;

  setUp(() {
    chatCubit = MockChatCubit();
    whenListen(
      chatCubit,
      const Stream<ChatState>.empty(),
      initialState: const ChatLoaded(messages: []),
    );
    when(() => chatCubit.startListening()).thenAnswer((_) {});
    when(() => chatCubit.markAllAsRead(any())).thenAnswer((_) async {});
    when(
      () => chatCubit.getMessages(any(), refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(
      () => chatCubit.sendMessage(
        receiverId: any(named: 'receiverId'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(() => chatCubit.loadMoreMessages(any())).thenAnswer((_) async {});
    when(() => chatCubit.close()).thenAnswer((_) async {});
  });

  List<ChatMessageEntity> longConversation() {
    return List.generate(50, (index) {
      return ChatMessageEntity(
        id: 'message-$index',
        senderId: index.isEven ? 'customer-1' : 'owner-1',
        receiverId: index.isEven ? 'owner-1' : 'customer-1',
        content: 'Geçmiş mesaj $index',
        createdAt: DateTime(2026, 7, 31, 12).subtract(Duration(minutes: index)),
      );
    });
  }

  Widget buildLongConversation({required bool hasReachedMax}) {
    whenListen(
      chatCubit,
      Stream<ChatState>.value(
        ChatLoaded(messages: longConversation(), hasReachedMax: hasReachedMax),
      ),
      initialState: ChatLoading(),
    );

    return MaterialApp(
      home: ChatView(
        receiverId: 'owner-1',
        receiverName: 'Mahalle Marketi',
        chatCubit: chatCubit,
        currentUserIdProvider: () => 'customer-1',
      ),
    );
  }

  testWidgets('ürün mesajını taslak olarak açar ve otomatik göndermez', (
    tester,
  ) async {
    const initialDraft = 'Merhaba, "Deneme Ürünü" mağazanızda mevcut mu?';

    await tester.pumpWidget(
      MaterialApp(
        home: ChatView(
          receiverId: 'owner-1',
          receiverName: 'Mahalle Marketi',
          initialDraft: initialDraft,
          chatCubit: chatCubit,
          currentUserIdProvider: () => 'customer-1',
        ),
      ),
    );
    await tester.pump();

    final messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(messageField.controller?.text, initialDraft);
    verifyNever(
      () => chatCubit.sendMessage(
        receiverId: any(named: 'receiverId'),
        content: any(named: 'content'),
      ),
    );
  });

  testWidgets('müşteri taslağı düzenledikten sonra gönderir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatView(
          receiverId: 'owner-1',
          receiverName: 'Mahalle Marketi',
          initialDraft: 'İlk taslak',
          chatCubit: chatCubit,
          currentUserIdProvider: () => 'customer-1',
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('chat-message-input')),
      'Düzenlenmiş müşteri mesajı',
    );
    await tester.tap(find.byKey(const Key('chat-message-send-action')));
    await tester.pump();

    verify(
      () => chatCubit.sendMessage(
        receiverId: 'owner-1',
        content: 'Düzenlenmiş müşteri mesajı',
      ),
    ).called(1);
  });

  testWidgets('listenin üstüne yaklaşınca eski mesajları yükler', (
    tester,
  ) async {
    final loadMoreResult = Completer<void>();
    when(
      () => chatCubit.loadMoreMessages('owner-1'),
    ).thenAnswer((_) => loadMoreResult.future);

    await tester.pumpWidget(buildLongConversation(hasReachedMax: false));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(find.byType(ListView));
    final controller = listView.controller!;
    expect(controller.position.maxScrollExtent, greaterThan(0));

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    verify(() => chatCubit.loadMoreMessages('owner-1')).called(1);
    expect(find.byKey(const Key('chat-load-more-progress')), findsOneWidget);

    controller.jumpTo(controller.position.maxScrollExtent - 1);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    verifyNever(() => chatCubit.loadMoreMessages('owner-1'));

    loadMoreResult.complete();
    await tester.pump();
    expect(find.byKey(const Key('chat-load-more-progress')), findsNothing);
  });

  testWidgets('eski mesajların sonuna gelindiyse yeni istek göndermez', (
    tester,
  ) async {
    await tester.pumpWidget(buildLongConversation(hasReachedMax: true));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(find.byType(ListView));
    final controller = listView.controller!;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    verifyNever(() => chatCubit.loadMoreMessages(any()));
    expect(find.byKey(const Key('chat-load-more-progress')), findsNothing);
  });
}
