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
    when(
      () => chatCubit.refreshMessagesSilently(any()),
    ).thenAnswer((_) async {});
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

  Widget buildSubject({
    String receiverName = 'Mahalle Marketi',
    String? initialDraft,
    Duration autoRefreshInterval = const Duration(seconds: 15),
  }) {
    return MaterialApp(
      home: ChatView(
        receiverId: 'owner-1',
        receiverName: receiverName,
        initialDraft: initialDraft,
        chatCubit: chatCubit,
        currentUserIdProvider: () => 'customer-1',
        autoRefreshInterval: autoRefreshInterval,
      ),
    );
  }

  testWidgets('başlık, boş konuşma ve mesaj alanını gösterir', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-chat-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-chat-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-chat-empty-state')), findsOneWidget);
    expect(find.byKey(const Key('customer-chat-input-area')), findsOneWidget);
    expect(find.text('Mahalle Marketi'), findsOneWidget);
    expect(find.text('Mağaza ile görüşme'), findsOneWidget);
    expect(find.text('Henüz mesaj yok.'), findsOneWidget);
  });

  testWidgets('gelen ve gönderilen mesajları tarih ve saatleriyle ayırır', (
    tester,
  ) async {
    final messages = [
      ChatMessageEntity(
        id: 'message-mine',
        senderId: 'customer-1',
        receiverId: 'owner-1',
        content: 'Ürün için geleceğim.',
        createdAt: DateTime(2026, 8, 1, 14, 5),
      ),
      ChatMessageEntity(
        id: 'message-shop',
        senderId: 'owner-1',
        receiverId: 'customer-1',
        content: 'Ürününüz hazırdır.',
        createdAt: DateTime(2026, 8, 1, 14),
      ),
    ];
    whenListen(
      chatCubit,
      Stream<ChatState>.value(ChatLoaded(messages: messages)),
      initialState: ChatLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-chat-message-list')), findsOneWidget);
    expect(find.byKey(const Key('chat-message-message-mine')), findsOneWidget);
    expect(find.byKey(const Key('chat-message-message-shop')), findsOneWidget);
    expect(find.text('Ürün için geleceğim.'), findsOneWidget);
    expect(find.text('Ürününüz hazırdır.'), findsOneWidget);
    expect(find.text('01.08.2026'), findsOneWidget);
    expect(find.text('14:05'), findsOneWidget);
    expect(find.text('14:00'), findsOneWidget);
  });

  testWidgets('yalnız gönderilen mesajın gerçek okundu durumunu gösterir', (
    tester,
  ) async {
    final stateController = StreamController<ChatState>();
    addTearDown(stateController.close);
    whenListen(chatCubit, stateController.stream, initialState: ChatLoading());

    final sentMessage = ChatMessageEntity(
      id: 'status-mine',
      senderId: 'customer-1',
      receiverId: 'owner-1',
      content: 'Ürün mağazada var mı?',
      isRead: false,
      createdAt: DateTime(2026, 8, 10, 11),
    );
    final receivedMessage = ChatMessageEntity(
      id: 'status-shop',
      senderId: 'owner-1',
      receiverId: 'customer-1',
      content: 'Evet, ürün mevcut.',
      isRead: true,
      createdAt: DateTime(2026, 8, 10, 11, 1),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    stateController.add(ChatLoaded(messages: [receivedMessage, sentMessage]));
    await tester.pump();

    expect(
      find.byKey(const Key('chat-message-status-status-mine')),
      findsOneWidget,
    );
    expect(find.text('Gönderildi'), findsOneWidget);
    expect(
      find.byKey(const Key('chat-message-status-status-shop')),
      findsNothing,
    );

    stateController.add(
      ChatLoaded(
        messages: [receivedMessage, sentMessage.copyWith(isRead: true)],
      ),
    );
    await tester.pump();

    expect(find.text('Gönderildi'), findsNothing);
    expect(find.text('Okundu'), findsOneWidget);
  });

  testWidgets('ilk yüklemede markalı bekleme durumunu gösterir', (
    tester,
  ) async {
    whenListen(
      chatCubit,
      const Stream<ChatState>.empty(),
      initialState: ChatLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(
      find.byKey(const Key('customer-chat-loading-state')),
      findsOneWidget,
    );
    expect(find.text('Mesajlar yükleniyor'), findsOneWidget);
  });

  testWidgets(
    'ilk yükleme hatasını boş sohbetten ayırır ve yeniden denemeyi tamamlar',
    (tester) async {
      final stateController = StreamController<ChatState>();
      addTearDown(stateController.close);
      whenListen(
        chatCubit,
        stateController.stream,
        initialState: const ChatError(
          'Bağlantını kontrol edip tekrar deneyebilirsin.',
        ),
      );

      await tester.pumpWidget(buildSubject(initialDraft: 'Korunan taslak'));
      await tester.pump();

      expect(
        find.byKey(const Key('customer-chat-load-error-state')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('customer-chat-empty-state')), findsNothing);
      expect(find.text('Mesajlar yüklenemedi'), findsOneWidget);
      expect(
        find.text('Bağlantını kontrol edip tekrar deneyebilirsin.'),
        findsOneWidget,
      );

      var messageField = tester.widget<TextField>(
        find.byKey(const Key('chat-message-input')),
      );
      expect(messageField.readOnly, isTrue);
      expect(messageField.controller?.text, 'Korunan taslak');

      clearInteractions(chatCubit);
      await tester.tap(
        find.byKey(const Key('customer-chat-load-retry-action')),
      );
      await tester.pump();

      verify(() => chatCubit.getMessages('owner-1', refresh: true)).called(1);

      stateController.add(ChatLoading());
      await tester.pump();
      expect(
        find.byKey(const Key('customer-chat-loading-state')),
        findsOneWidget,
      );

      stateController.add(const ChatLoaded(messages: []));
      await tester.pump();
      expect(
        find.byKey(const Key('customer-chat-empty-state')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer-chat-load-error-state')),
        findsNothing,
      );

      messageField = tester.widget<TextField>(
        find.byKey(const Key('chat-message-input')),
      );
      expect(messageField.readOnly, isFalse);
      expect(messageField.controller?.text, 'Korunan taslak');
    },
  );

  testWidgets('ekran açıkken sohbeti düzenli olarak sessizce yeniler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(autoRefreshInterval: const Duration(seconds: 1)),
    );
    await tester.pump();

    verifyNever(() => chatCubit.refreshMessagesSilently(any()));

    await tester.pump(const Duration(seconds: 1));

    verify(() => chatCubit.refreshMessagesSilently('owner-1')).called(1);
    expect(find.byKey(const Key('customer-chat-empty-state')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('arka planda yenilemeyi durdurur ve dönüşte hemen eşitler', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(autoRefreshInterval: const Duration(seconds: 1)),
    );
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 2));
    verifyNever(() => chatCubit.refreshMessagesSilently(any()));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    verify(() => chatCubit.refreshMessagesSilently('owner-1')).called(1);

    clearInteractions(chatCubit);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    verifyNever(() => chatCubit.refreshMessagesSilently(any()));
  });

  testWidgets('gönder düğmesi yalnızca gerçek mesaj yazıldığında açılır', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    IconButton sendButton() => tester.widget<IconButton>(
      find.byKey(const Key('chat-message-send-action')),
    );

    expect(sendButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('chat-message-input')), '   ');
    await tester.pump();
    expect(sendButton().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('chat-message-input')),
      'Mağazada mevcut mu?',
    );
    await tester.pump();
    expect(sendButton().onPressed, isNotNull);

    final overLimitMessage = List.filled(1001, 'a').join();
    await tester.enterText(
      find.byKey(const Key('chat-message-input')),
      overLimitMessage,
    );
    await tester.pump();

    final messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(messageField.controller?.text.length, 1000);
    expect(find.text('1000 / 1000'), findsOneWidget);
    expect(sendButton().onPressed, isNotNull);
  });

  testWidgets('mesaj gönderilirken ikinci gönderimi engeller', (tester) async {
    whenListen(
      chatCubit,
      const Stream<ChatState>.empty(),
      initialState: MessageSending(),
    );

    await tester.pumpWidget(buildSubject(initialDraft: 'Gönderilecek mesaj'));
    await tester.pump();

    final sendButton = tester.widget<IconButton>(
      find.byKey(const Key('chat-message-send-action')),
    );
    final messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(sendButton.onPressed, isNull);
    expect(messageField.readOnly, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat-message-send-action')));
    await tester.pump();
    verifyNever(
      () => chatCubit.sendMessage(
        receiverId: any(named: 'receiverId'),
        content: any(named: 'content'),
      ),
    );
  });

  testWidgets('realtime yenilemesi sırasında gönderim kilidini görünür tutar', (
    tester,
  ) async {
    whenListen(
      chatCubit,
      const Stream<ChatState>.empty(),
      initialState: const ChatLoaded(messages: [], isSending: true),
    );

    await tester.pumpWidget(buildSubject(initialDraft: 'Korunan taslak'));
    await tester.pump();

    final sendButton = tester.widget<IconButton>(
      find.byKey(const Key('chat-message-send-action')),
    );
    final messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(sendButton.onPressed, isNull);
    expect(messageField.readOnly, isTrue);
    expect(messageField.controller?.text, 'Korunan taslak');
  });

  testWidgets('mesaj hatasında taslağı korur ve yeniden düzenlemeye açar', (
    tester,
  ) async {
    final stateController = StreamController<ChatState>();
    addTearDown(stateController.close);
    whenListen(
      chatCubit,
      stateController.stream,
      initialState: const ChatLoaded(messages: []),
    );

    await tester.pumpWidget(buildSubject(initialDraft: 'Korunacak taslak'));
    await tester.pump();

    stateController.add(MessageSending());
    await tester.pump();
    await tester.pump();

    var messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(messageField.readOnly, isTrue);
    expect(messageField.controller?.text, 'Korunacak taslak');

    stateController.add(const ChatError('Mesaj gönderilemedi.'));
    await tester.pump();
    await tester.pump();

    messageField = tester.widget<TextField>(
      find.byKey(const Key('chat-message-input')),
    );
    expect(messageField.readOnly, isFalse);
    expect(messageField.controller?.text, 'Korunacak taslak');
  });

  testWidgets('mesaj hatasını kullanıcıya gösterir', (tester) async {
    final stateController = StreamController<ChatState>();
    addTearDown(stateController.close);
    whenListen(
      chatCubit,
      stateController.stream,
      initialState: const ChatLoaded(messages: []),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    stateController.add(const ChatError('Mesaj şu anda gönderilemedi.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Mesaj şu anda gönderilemedi.'), findsOneWidget);
    expect(
      find.byKey(const Key('customer-chat-load-error-state')),
      findsNothing,
    );
  });

  testWidgets('dar ekranda uzun mesaj ve mağaza adı taşma yapmaz', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 560);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final message = ChatMessageEntity(
      id: 'message-responsive',
      senderId: 'owner-1',
      receiverId: 'customer-1',
      content:
          'Aradığınız ürün mağazamızda hazır, geldiğinizde size yardımcı olabiliriz.',
      createdAt: DateTime(2026, 8, 2, 12),
    );
    whenListen(
      chatCubit,
      Stream<ChatState>.value(ChatLoaded(messages: [message])),
      initialState: ChatLoading(),
    );

    await tester.pumpWidget(
      buildSubject(
        receiverName: 'Mahalledeki Çok Uzun İsimli Elektronik Mağazası',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('chat-message-message-responsive')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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
