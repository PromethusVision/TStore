import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/chat/domain/chat_message_rules.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import '../w47_prototype_support.dart';

class _Chat extends MockCubit<ChatState> implements ChatCubit {}

const _customer = 'fixture-customer';
const _merchant = 'fixture-merchant';

final _messages =
    [
          'Merhaba, nasıl yardımcı olabiliriz?',
          'Pamuklu tişörtün M bedeni mağazada var mı?',
          'Merhaba, M ve L bedenleri mağazamızda var.',
          'Kumaşını ve kalıbını mağazada deneyebilir miyim?',
          'Elbette, gelip deneyebilirsiniz. İki rengi de görebilirsiniz.',
          'Teşekkürler, bugün uğrayacağım.',
        ]
        .asMap()
        .entries
        .map(
          (entry) => ChatMessageEntity(
            id: 'fixture-message-${entry.key}',
            senderId: entry.key.isOdd ? _customer : _merchant,
            receiverId: entry.key.isOdd ? _merchant : _customer,
            content: entry.value,
            createdAt: DateTime(2026, 9, 4, 14, 20 + entry.key),
            isRead: entry.key < 5,
          ),
        )
        .toList()
        .reversed
        .toList();

void main() {
  late _Chat cubit;
  late StreamController<ChatState> states;
  setUpAll(loadW47Fonts);
  setUp(() {
    cubit = _Chat();
    states = StreamController<ChatState>.broadcast();
    whenListen(cubit, states.stream, initialState: ChatLoading());
    when(() => cubit.startListening()).thenAnswer((_) {});
    when(() => cubit.markAllAsRead(any())).thenAnswer((_) async {});
    when(
      () => cubit.getMessages(any(), refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(
      () => cubit.sendMessage(
        receiverId: any(named: 'receiverId'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.loadMoreMessages(any())).thenAnswer((_) async {});
    when(() => cubit.refreshMessagesSilently(any())).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
  });
  tearDown(() async => states.close());
  Widget view({bool prototype = true, String? draft}) => ChatView(
    receiverId: _merchant,
    receiverName: 'Mahalle Giyim',
    chatCubit: cubit,
    currentUserIdProvider: () => _customer,
    initialDraft: draft,
    visualPrototype: prototype,
  );
  Future<void> pump(
    WidgetTester tester, {
    bool prototype = true,
    String? draft,
    List<ChatMessageEntity>? messages,
    bool reachedMax = true,
  }) async {
    setW47Viewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: RepaintBoundary(
          key: const Key('evidence'),
          child: view(prototype: prototype, draft: draft),
        ),
      ),
    );
    states.add(
      ChatLoaded(messages: messages ?? _messages, hasReachedMax: reachedMax),
    );
    await tester.pumpAndSettle();
  }

  for (final prototype in [false, true]) {
    testWidgets('390 px ${prototype ? 'prototype' : 'before'} evidence', (
      tester,
    ) async {
      await pump(tester, prototype: prototype);
      expect(find.text('Mahalle Giyim'), findsOneWidget);
      expect(find.text('Mağaza ile görüşme'), findsOneWidget);
      expect(
        find.byKey(const Key('chat-message-fixture-message-5')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('evidence')),
        matchesGoldenFile(
          'goldens/w47_${prototype ? '' : 'before_'}chat_390.png',
        ),
      );
    });
  }
  testWidgets(
    'send keeps merchant id, trims draft, clears only after success',
    (tester) async {
      await pump(tester, draft: '  M bedenini görmek istiyorum.  ');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .controller!
            .text,
        'M bedenini görmek istiyorum.',
      );
      await tester.tap(find.byKey(const Key('chat-message-send-action')));
      await tester.pump();
      verify(
        () => cubit.sendMessage(
          receiverId: _merchant,
          content: 'M bedenini görmek istiyorum.',
        ),
      ).called(1);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .controller!
            .text,
        isNotEmpty,
      );
      states.add(MessageSending());
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .readOnly,
        isTrue,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('chat-message-send-action')),
            )
            .onPressed,
        isNull,
      );
      states.add(MessageSent(_messages.first));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .controller!
            .text,
        isEmpty,
      );
    },
  );
  testWidgets('empty composer and existing grapheme limit remain enforced', (
    tester,
  ) async {
    await pump(tester);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('chat-message-send-action')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('chat-message-input')),
      'a' * (ChatMessageRules.maxTextLength + 20),
    );
    await tester.pump();
    final text = tester
        .widget<TextField>(find.byKey(const Key('chat-message-input')))
        .controller!
        .text;
    expect(
      ChatMessageRules.characterCount(text),
      ChatMessageRules.maxTextLength,
    );
  });
  testWidgets(
    'actual read status and received-message read marking are preserved',
    (tester) async {
      await pump(tester);
      expect(find.text('Gönderildi'), findsOneWidget);
      expect(
        find.byKey(const Key('chat-message-status-fixture-message-4')),
        findsNothing,
      );
      states.add(
        ChatLoaded(
          messages: [
            _messages.first.copyWith(isRead: true),
            ..._messages.skip(1),
          ],
          hasReachedMax: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gönderildi'), findsNothing);
      expect(
        find.byKey(const Key('chat-message-status-fixture-message-5')),
        findsOneWidget,
      );
      states.add(NewMessageReceived(_messages[1]));
      await tester.pumpAndSettle();
      verify(() => cubit.markAllAsRead(_merchant)).called(2);
      verify(() => cubit.startListening()).called(1);
      verify(() => cubit.getMessages(_merchant, refresh: true)).called(1);
    },
  );
  testWidgets('scrolling keeps reverse chronology and existing pagination', (
    tester,
  ) async {
    final many = List.generate(
      30,
      (index) => ChatMessageEntity(
        id: 'fixture-scroll-$index',
        senderId: index.isEven ? _customer : _merchant,
        receiverId: index.isEven ? _merchant : _customer,
        content: 'Mağazadaki ürün hakkında mesaj $index',
        createdAt: DateTime(2026, 9, 4, 14).subtract(Duration(minutes: index)),
      ),
    );
    await pump(tester, messages: many, reachedMax: false);
    final list = tester.widget<ListView>(
      find.byKey(const Key('customer-chat-message-list')),
    );
    expect(list.reverse, isTrue);
    expect(list.controller!.offset, 0);
    await tester.drag(
      find.byKey(const Key('customer-chat-message-list')),
      const Offset(0, 480),
    );
    await tester.pumpAndSettle();
    expect(list.controller!.offset, greaterThan(0));
    list.controller!.jumpTo(list.controller!.position.maxScrollExtent);
    await tester.pumpAndSettle();
    verify(() => cubit.loadMoreMessages(_merchant)).called(1);
  });
  testWidgets('back returns to existing caller and closes conversation cubit', (
    tester,
  ) async {
    setW47Viewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: EsnaftaVarTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => view())),
              child: const Text('Mesajlarım'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mesajlarım'));
    await tester.pump();
    states.add(ChatLoaded(messages: _messages, hasReachedMax: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('customer-chat-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Mesajlarım'), findsOneWidget);
    verify(() => cubit.close()).called(1);
  });
  test(
    'prototype stays opt-in',
    () => expect(
      const ChatView(
        receiverId: _merchant,
        receiverName: 'Mahalle Giyim',
      ).visualPrototype,
      isFalse,
    ),
  );
}
