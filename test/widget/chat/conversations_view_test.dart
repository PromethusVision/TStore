import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';

class MockChatConversationsCubit extends MockCubit<ChatConversationsState>
    implements ChatConversationsCubit {}

void main() {
  late MockChatConversationsCubit conversationsCubit;

  const thread = ChatThreadEntity(
    otherUserId: 'owner-1',
    displayName: 'Mahalle Marketi',
    lastMessage: 'Ürün hazır',
    lastMessageAt: null,
    unreadCount: 2,
  );

  setUp(() {
    conversationsCubit = MockChatConversationsCubit();
    when(() => conversationsCubit.loadConversations()).thenAnswer((_) async {});
    when(
      () => conversationsCubit.refreshConversations(),
    ).thenAnswer((_) async {});
    when(
      () => conversationsCubit.refreshConversationsSilently(),
    ).thenAnswer((_) async {});
    when(() => conversationsCubit.close()).thenAnswer((_) async {});
  });

  Widget buildSubject({
    ChatConversationsState state = const ChatConversationsLoaded(
      <ChatThreadEntity>[],
    ),
    ConversationDestinationBuilder? destinationBuilder,
  }) {
    whenListen(
      conversationsCubit,
      const Stream<ChatConversationsState>.empty(),
      initialState: state,
    );

    return MaterialApp(
      home: ConversationsView(
        conversationsCubit: conversationsCubit,
        autoRefreshInterval: const Duration(seconds: 15),
        destinationBuilder: destinationBuilder,
      ),
    );
  }

  testWidgets('ekran açıkken listeyi on beş saniyede sessizce yeniler', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    verify(() => conversationsCubit.loadConversations()).called(1);
    verifyNever(() => conversationsCubit.refreshConversationsSilently());

    await tester.pump(const Duration(seconds: 15));

    verify(() => conversationsCubit.refreshConversationsSilently()).called(1);
    expect(find.text('Henüz mesajınız yok.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sohbet açıkken durur ve listeye dönünce hemen yenilenir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        state: const ChatConversationsLoaded([thread]),
        destinationBuilder: (_) => Scaffold(
          body: TextButton(
            key: const Key('close-chat'),
            onPressed: () {},
            child: const Text('Sohbet ekranı'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Mahalle Marketi'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 30));
    verifyNever(() => conversationsCubit.refreshConversationsSilently());

    Navigator.of(tester.element(find.text('Sohbet ekranı'))).pop();
    await tester.pumpAndSettle();

    verify(() => conversationsCubit.refreshConversationsSilently()).called(1);

    await tester.pump(const Duration(seconds: 15));
    verify(() => conversationsCubit.refreshConversationsSilently()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('uygulama arka plandayken yenilemeyi durdurur', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    verifyNever(() => conversationsCubit.refreshConversationsSilently());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    verify(() => conversationsCubit.refreshConversationsSilently()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
