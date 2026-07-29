import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    when(() => chatCubit.close()).thenAnswer((_) async {});
  });

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
}
