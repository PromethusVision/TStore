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

  testWidgets('konuşmaları mesaj, tarih ve okunmamış sayısıyla gösterir', (
    tester,
  ) async {
    final datedThread = ChatThreadEntity(
      otherUserId: 'owner-dated',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Ürününüz mağazada hazırlandı.',
      lastMessageAt: DateTime(2026, 7, 20, 14, 30),
      unreadCount: 2,
    );

    await tester.pumpWidget(
      buildSubject(state: ChatConversationsLoaded([datedThread])),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-conversations-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-conversations-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-conversations-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('conversation-card-owner-dated')),
      findsOneWidget,
    );
    expect(find.text('Mesajlarım'), findsOneWidget);
    expect(find.text('2 okunmamış mesaj'), findsOneWidget);
    expect(find.text('Mahalle Marketi'), findsOneWidget);
    expect(find.text('Ürününüz mağazada hazırlandı.'), findsOneWidget);
    expect(find.text('20.07.2026'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('müşterinin son mesajını Siz etiketiyle gösterir', (
    tester,
  ) async {
    const ownMessageThread = ChatThreadEntity(
      otherUserId: 'owner-own-message',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Ürün hâlâ mevcut mu?',
      lastMessageAt: null,
      lastMessageIsMine: true,
    );

    await tester.pumpWidget(
      buildSubject(state: const ChatConversationsLoaded([ownMessageThread])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siz: Ürün hâlâ mevcut mu?'), findsOneWidget);
    expect(find.text('Ürün hâlâ mevcut mu?'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('mağazanın son mesajına Siz etiketi eklemez', (tester) async {
    const shopMessageThread = ChatThreadEntity(
      otherUserId: 'owner-shop-message',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Ürün mağazamızda mevcut.',
      lastMessageAt: null,
    );

    await tester.pumpWidget(
      buildSubject(state: const ChatConversationsLoaded([shopMessageThread])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ürün mağazamızda mevcut.'), findsOneWidget);
    expect(find.text('Siz: Ürün mağazamızda mevcut.'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('müşterinin okunmamış son mesajını Gönderildi olarak gösterir', (
    tester,
  ) async {
    const sentThread = ChatThreadEntity(
      otherUserId: 'owner-sent-message',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Ürünü ayırabilir misiniz?',
      lastMessageAt: null,
      lastMessageIsMine: true,
    );

    await tester.pumpWidget(
      buildSubject(state: const ChatConversationsLoaded([sentThread])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gönderildi'), findsOneWidget);
    expect(find.text('Okundu'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('müşterinin okunan son mesajını Okundu olarak gösterir', (
    tester,
  ) async {
    const readThread = ChatThreadEntity(
      otherUserId: 'owner-read-message',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Teşekkür ederim.',
      lastMessageAt: null,
      lastMessageIsMine: true,
      lastMessageIsRead: true,
    );

    await tester.pumpWidget(
      buildSubject(state: const ChatConversationsLoaded([readThread])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Okundu'), findsOneWidget);
    expect(find.text('Gönderildi'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('mağazadan gelen son mesaja teslim durumu eklemez', (
    tester,
  ) async {
    const receivedThread = ChatThreadEntity(
      otherUserId: 'owner-received-message',
      displayName: 'Mahalle Marketi',
      lastMessage: 'Ürünü sizin için ayırdık.',
      lastMessageAt: null,
      lastMessageIsRead: true,
    );

    await tester.pumpWidget(
      buildSubject(state: const ChatConversationsLoaded([receivedThread])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gönderildi'), findsNothing);
    expect(find.text('Okundu'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('yüklenirken markalı bekleme durumunu gösterir', (tester) async {
    await tester.pumpWidget(buildSubject(state: ChatConversationsLoading()));
    await tester.pump();

    expect(
      find.byKey(const Key('customer-conversations-loading-state')),
      findsOneWidget,
    );
    expect(find.text('Mesajların yükleniyor'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('yükleme hatasında yeniden deneme sunar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        state: const ChatConversationsError('Mesajların şu anda yüklenemiyor.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('customer-conversations-status')),
      findsOneWidget,
    );
    expect(find.text('Mesajların yüklenemedi'), findsOneWidget);
    expect(find.text('Mesajların şu anda yüklenemiyor.'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => conversationsCubit.refreshConversations()).called(1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('dar ekranda uzun konuşma bilgileri taşma yapmaz', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 560);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final longThread = ChatThreadEntity(
      otherUserId: 'owner-responsive',
      displayName: 'Mahalledeki Çok Uzun İsimli Elektronik Mağazası',
      lastMessage:
          'Aradığınız ürün hazırlandı, mağazamıza geldiğinizde yardımcı olabiliriz.',
      lastMessageAt: DateTime(2026, 7, 21),
      unreadCount: 125,
    );

    await tester.pumpWidget(
      buildSubject(state: ChatConversationsLoaded([longThread])),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('conversation-card-owner-responsive')),
      findsOneWidget,
    );
    expect(find.text('99+'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

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

  testWidgets('hızlı çift dokunma aynı sohbeti yalnızca bir kez açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    await tester.pumpWidget(
      buildSubject(
        state: const ChatConversationsLoaded([thread]),
        destinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Sohbet hedefi'));
        },
      ),
    );
    await tester.pump();

    final conversationAction = tester
        .widget<InkWell>(find.byKey(const Key('conversation-card-owner-1')))
        .onTap!;
    conversationAction();
    conversationAction();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Sohbet hedefi'), findsOneWidget);

    Navigator.of(tester.element(find.text('Sohbet hedefi'))).pop();
    await tester.pumpAndSettle();

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
