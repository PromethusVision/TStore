import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/merchant/merchant_app.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/domain/merchant_session_identity.dart';
import 'package:t_store/features/merchant/preview/merchant_preview.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import '../../support/merchant_chat_fakes.dart';
import '../w48/w48_fixture.dart' show w48Fonts;

void main() {
  setUpAll(w48Fonts);
  late MerchantPreview preview;
  late MerchantChatFake chat;
  late StreamController<MerchantSessionIdentity> sessions;
  var sessionKey = 's1';
  Future<void> host(
    WidgetTester t, {
    double width = 390,
    double scale = 1,
  }) async {
    preview = MerchantPreview();
    chat = MerchantChatFake();
    sessions = StreamController.broadcast(sync: true);
    sessionKey = 's1';
    t.view.physicalSize = Size(width, 844);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    final base = preview.services;
    addTearDown(() async {
      await t.pumpWidget(const SizedBox());
      await t.runAsync(() async {
        await chat.events.close();
        await sessions.close();
        await preview.dispose();
      });
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
      t.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await t.pumpWidget(
      RepaintBoundary(
        key: const Key('merchant-chat-proof'),
        child: MerchantApp(
          services: MerchantServices(
            merchants: base.merchants,
            credentials: base.credentials,
            notifications: base.notifications,
            qr: base.qr,
            preferences: base.preferences,
            sessionChanges: base.sessionChanges,
            currentUserId: base.currentUserId,
            currentSessionKey: () => sessionKey,
            sessionIdentities: sessions.stream,
            chatRepositoryFactory: () => chat,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> list(WidgetTester t) async {
    await t.tap(find.byKey(const Key('merchant-messages-entry')));
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, String name) async {
    if (!const bool.fromEnvironment('MERCHANT_CHAT_CAPTURE')) return;
    final render = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('merchant-chat-proof')),
    );
    await t.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await Directory('.buildlog/chat-visual').create(recursive: true);
      await File(
        '.buildlog/chat-visual/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  Future<void> thread(WidgetTester t) async {
    await list(t);
    await t.tap(find.byKey(const Key('conversation-card-$chatPeer')));
    await t.pumpAndSettle();
  }

  void replaceSession() {
    sessionKey = 's2';
    sessions.add(
      MerchantSessionIdentity(
        userId: preview.currentId,
        sessionKey: sessionKey,
      ),
    );
  }

  NotificationEntity note({String peer = chatPeer, bool read = false}) =>
      NotificationEntity(
        id: 'chat-note',
        userId: MerchantPreview.userId,
        title: 'Yeni mesaj',
        body: 'Bir müşteri yazdı',
        type: NotificationType.chat,
        isRead: read,
        data: {
          'app_role': 'merchant',
          'action_type': 'chat_detail',
          'action_id': peer,
        },
      );

  testWidgets('merchant dashboard has an accessible messages entry', (t) async {
    await host(t);
    expect(find.byKey(const Key('merchant-messages-entry')), findsOneWidget);
    expect(find.text('Mesajlar · 1 okunmamış'), findsOneWidget);
    await capture(t, 'dashboard-390');
    await list(t);
    expect(find.text('Müşterilerinle görüşmelerin.'), findsOneWidget);
    expect(find.text('Powerbank mevcut mu?'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'live shared notification updates unread entry without a second inbox',
    (t) async {
      await host(t);
      chat.messages = [incomingChat, incomingChat.copyWith(id: 'second')];
      preview.notifications.events.add(note());
      await t.pumpAndSettle();
      expect(find.text('Mesajlar · 2 okunmamış'), findsOneWidget);
    },
  );
  testWidgets(
    'opens existing customer thread and replies with shared composer',
    (t) async {
      await host(t);
      await thread(t);
      expect(find.text('Müşteri ile görüşme'), findsOneWidget);
      await t.enterText(
        find.byKey(const Key('chat-message-input')),
        'Evet, mağazamızda mevcut.',
      );
      await t.pump();
      await t.tap(find.byKey(const Key('chat-message-send-action')));
      await t.pumpAndSettle();
      expect(chat.writes, 1);
      expect(find.text('Evet, mağazamızda mevcut.'), findsOneWidget);
      expect(
        t
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .controller!
            .text,
        isEmpty,
      );
      await t.tap(find.byKey(const Key('customer-chat-back-button')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('customer-conversations-back-button')));
      await t.pumpAndSettle();
      expect(find.text('Mesajlar'), findsOneWidget);
    },
  );
  testWidgets(
    'pending send prevents double tap; failure retains draft without replay',
    (t) async {
      await host(t);
      await thread(t);
      final pending = Completer<Either<String, ChatMessageEntity>>();
      chat.send = (_) => pending.future;
      await t.enterText(
        find.byKey(const Key('chat-message-input')),
        'Taslak cevap',
      );
      await t.pump();
      await t.tap(find.byKey(const Key('chat-message-send-action')));
      await t.pump();
      await t.tap(
        find.byKey(const Key('chat-message-send-action')),
        warnIfMissed: false,
      );
      await t.pump();
      expect(chat.writes, 1);
      pending.complete(const Left('Yanıt alınamadı'));
      await t.pumpAndSettle();
      expect(
        t
            .widget<TextField>(find.byKey(const Key('chat-message-input')))
            .controller!
            .text,
        'Taslak cevap',
      );
      expect(chat.writes, 1);
    },
  );
  testWidgets(
    'read chat notification remains actionable and resolves exact existing peer',
    (t) async {
      await host(t);
      preview.notifications.items = [note(read: true)];
      await t.tap(find.text('Bildirim').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Yeni mesaj'));
      await t.pumpAndSettle();
      expect(find.byType(ChatView), findsOneWidget);
      expect(find.text('Deneme müşterisi'), findsOneWidget);
      expect(chat.reads, 1);
    },
  );
  testWidgets(
    'notification cannot create a composer for a peer absent from owned history',
    (t) async {
      await host(t);
      preview.notifications.items = [note(peer: 'foreign-peer')];
      await t.tap(find.text('Bildirim').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Yeni mesaj'));
      await t.pumpAndSettle();
      expect(find.byType(ChatView), findsNothing);
      expect(chat.reads, 0);
      expect(chat.marked, 0);
      expect(
        find.textContaining('Bu görüşme artık kullanılamıyor'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'same-account replacement clears composer and ignores delayed message result',
    (t) async {
      await host(t);
      final pending = Completer<Either<String, List<ChatMessageEntity>>>();
      chat.readMessages = () => pending.future;
      await list(t);
      await t.tap(find.byKey(const Key('conversation-card-$chatPeer')));
      await t.pump();
      await t.pump();
      replaceSession();
      await t.pumpAndSettle();
      pending.complete(const Right([incomingChat]));
      await t.pumpAndSettle();
      expect(find.byType(ChatView), findsNothing);
      expect(find.text('Powerbank mevcut mu?'), findsNothing);
    },
  );
  testWidgets('ordinary renewal preserves the current composer draft', (
    t,
  ) async {
    await host(t);
    await thread(t);
    await t.enterText(
      find.byKey(const Key('chat-message-input')),
      'Kaybolmayan taslak',
    );
    sessions.add(
      MerchantSessionIdentity(
        userId: preview.currentId,
        sessionKey: sessionKey,
      ),
    );
    await t.pumpAndSettle();
    expect(
      t
          .widget<TextField>(find.byKey(const Key('chat-message-input')))
          .controller!
          .text,
      'Kaybolmayan taslak',
    );
  });
  testWidgets(
    'between tap and first frame replacement cannot show previous thread',
    (t) async {
      await host(t);
      await list(t);
      await t.tap(find.byKey(const Key('conversation-card-$chatPeer')));
      replaceSession();
      await t.pumpAndSettle();
      expect(find.byType(ChatView), findsNothing);
      expect(find.text('Powerbank mevcut mu?'), findsNothing);
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('merchant empty and thread states fit $width at large text', (
      t,
    ) async {
      await host(t, width: width, scale: 1.3);
      chat.threads = [];
      await list(t);
      expect(find.text('Ürünleri Keşfet'), findsNothing);
      expect(find.text('Yenile'), findsOneWidget);
      chat.threads = [chatThread];
      await t.tap(find.text('Yenile'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('conversation-card-$chatPeer')));
      await t.pumpAndSettle();
      expect(find.byType(ChatView), findsOneWidget);
      await capture(t, 'thread-${width.toInt()}');
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'list failure offers retry and recovers without fake empty success',
    (t) async {
      await host(t);
      chat.readThreads = () async => const Left('Bağlantı yok');
      await list(t);
      expect(find.text('Bağlantı yok'), findsOneWidget);
      expect(find.text('Henüz mesajın yok'), findsNothing);
      chat.readThreads = null;
      await t.tap(find.text('Tekrar Dene'));
      await t.pumpAndSettle();
      expect(find.text('Powerbank mevcut mu?'), findsOneWidget);
    },
  );
}
