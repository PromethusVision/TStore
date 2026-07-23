import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class RecordingNavigatorObserver extends NavigatorObserver {
  int notificationPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name?.startsWith('customer-notification-') ?? false) {
      notificationPushCount++;
    }
  }
}

void main() {
  late MockNotificationsCubit notificationsCubit;

  setUp(() {
    notificationsCubit = MockNotificationsCubit();
    when(
      () => notificationsCubit.getNotifications(refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(
      () => notificationsCubit.loadMoreNotifications(),
    ).thenAnswer((_) async {});
    when(() => notificationsCubit.markAsRead(any())).thenAnswer((_) async {});
    when(() => notificationsCubit.markAllAsRead()).thenAnswer((_) async {});
    when(() => notificationsCubit.close()).thenAnswer((_) async {});
  });

  Widget buildSubject(
    NotificationsState state, {
    CustomerNotificationDestinationBuilder? destinationBuilder,
    List<NavigatorObserver> navigatorObservers = const [],
  }) {
    whenListen(
      notificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: state,
    );

    return MaterialApp(
      navigatorObservers: navigatorObservers,
      home: CustomerNotificationsView(
        notificationsCubit: notificationsCubit,
        notificationDestinationBuilder: destinationBuilder,
      ),
    );
  }

  testWidgets('bildirimleri türü, tarihi ve okunma durumuyla gösterir', (
    tester,
  ) async {
    final notifications = [
      NotificationEntity(
        id: 'notification-1',
        userId: 'customer-1',
        title: 'Alışverişin doğrulandı',
        body: 'Mağaza alışverişini onayladı.',
        type: NotificationType.order,
        createdAt: DateTime(2026, 7, 16, 14, 5),
      ),
      NotificationEntity(
        id: 'notification-2',
        userId: 'customer-1',
        title: 'Yeni kampanya',
        body: 'Yakınındaki mağazada fırsat var.',
        type: NotificationType.promotion,
        isRead: true,
        createdAt: DateTime(2026, 7, 15, 9, 30),
      ),
    ];

    await tester.pumpWidget(
      buildSubject(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: 1,
          hasReachedMax: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bildirimlerim'), findsOneWidget);
    expect(find.text('Alışverişin doğrulandı'), findsOneWidget);
    expect(find.text('Yeni kampanya'), findsOneWidget);
    expect(find.text('Alışveriş'), findsOneWidget);
    expect(find.text('Kampanya'), findsOneWidget);
    expect(find.text('Yeni'), findsOneWidget);
    expect(find.text('Tümünü oku'), findsOneWidget);
    expect(find.text('16.07.2026 • 14:05'), findsOneWidget);
    expect(find.text('15.07.2026 • 09:30'), findsOneWidget);
    verify(() => notificationsCubit.getNotifications(refresh: true)).called(1);
    verifyNever(() => notificationsCubit.markAllAsRead());
    verifyNever(() => notificationsCubit.deleteAllNotifications());
  });

  testWidgets('genel bildirime dokununca yalnızca okundu işlemini başlatır', (
    tester,
  ) async {
    const notification = NotificationEntity(
      id: 'notification-1',
      userId: 'customer-1',
      title: 'Yeni bilgilendirme',
      body: 'Uygulama bilgisi güncellendi.',
      type: NotificationType.system,
    );

    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(
          notifications: [notification],
          unreadCount: 1,
          hasReachedMax: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('notification-card-notification-1')));
    await tester.pump();

    verify(() => notificationsCubit.markAsRead('notification-1')).called(1);
    expect(find.text('Bildirimlerim'), findsOneWidget);
  });

  testWidgets('alışveriş bildirimi okundu yapılırken hedef ekranı açar', (
    tester,
  ) async {
    final markAsReadCompleter = Completer<void>();
    when(
      () => notificationsCubit.markAsRead('notification-order'),
    ).thenAnswer((_) => markAsReadCompleter.future);
    const notification = NotificationEntity(
      id: 'notification-order',
      userId: 'customer-1',
      title: 'Alışverişin doğrulandı',
      body: 'Doğrulanan alışverişini görüntüle.',
      type: NotificationType.order,
    );

    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(
          notifications: [notification],
          unreadCount: 1,
          hasReachedMax: true,
        ),
        destinationBuilder: (notification) =>
            notification.type == NotificationType.order
            ? const Scaffold(body: Text('Alışveriş hedefi'))
            : null,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('notification-card-notification-order')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alışveriş hedefi'), findsOneWidget);
    verify(() => notificationsCubit.markAsRead('notification-order')).called(1);

    markAsReadCompleter.complete();
  });

  testWidgets(
    'okunmuş mesaj bildirimi yeniden okundu yapmadan mesajları açar',
    (tester) async {
      const notification = NotificationEntity(
        id: 'notification-chat',
        userId: 'customer-1',
        title: 'Yeni mesajın var',
        body: 'Mağaza mesajına yanıt verdi.',
        type: NotificationType.chat,
        isRead: true,
      );

      await tester.pumpWidget(
        buildSubject(
          const NotificationsLoaded(
            notifications: [notification],
            hasReachedMax: true,
          ),
          destinationBuilder: (notification) =>
              notification.type == NotificationType.chat
              ? const Scaffold(body: Text('Mesaj hedefi'))
              : null,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('notification-card-notification-chat')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mesaj hedefi'), findsOneWidget);
      verifyNever(() => notificationsCubit.markAsRead(any()));
    },
  );

  testWidgets('çift dokunmada hedef ekranı yalnızca bir kez açar', (
    tester,
  ) async {
    final navigatorObserver = RecordingNavigatorObserver();
    const notification = NotificationEntity(
      id: 'notification-order',
      userId: 'customer-1',
      title: 'Alışverişin doğrulandı',
      body: 'Doğrulanan alışverişini görüntüle.',
      type: NotificationType.order,
    );

    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(
          notifications: [notification],
          unreadCount: 1,
          hasReachedMax: true,
        ),
        destinationBuilder: (_) =>
            const Scaffold(body: Text('Alışveriş hedefi')),
        navigatorObservers: [navigatorObserver],
      ),
    );
    await tester.pumpAndSettle();

    final card = tester.widget<InkWell>(
      find.byKey(const Key('notification-card-notification-order')),
    );
    card.onTap!();
    card.onTap!();
    await tester.pumpAndSettle();

    expect(navigatorObserver.notificationPushCount, 1);
    verify(() => notificationsCubit.markAsRead('notification-order')).called(1);
  });

  testWidgets('tümünü oku butonu toplu işlemi başlatır', (tester) async {
    const notification = NotificationEntity(
      id: 'notification-1',
      userId: 'customer-1',
      title: 'Yeni bildirim',
      body: 'Bildirim açıklaması',
      type: NotificationType.system,
    );

    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(
          notifications: [notification],
          unreadCount: 1,
          hasReachedMax: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('mark-all-notifications-read-button')),
    );
    await tester.pump();

    verify(() => notificationsCubit.markAllAsRead()).called(1);
  });

  testWidgets('işlem sürerken bildirim ve toplu buton devre dışıdır', (
    tester,
  ) async {
    const notification = NotificationEntity(
      id: 'notification-1',
      userId: 'customer-1',
      title: 'Yeni bildirim',
      body: 'Bildirim açıklaması',
      type: NotificationType.system,
    );

    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(
          notifications: [notification],
          unreadCount: 1,
          hasReachedMax: true,
          markingAsReadIds: {'notification-1'},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('notification-read-progress')), findsOneWidget);
    final button = tester.widget<TextButton>(
      find.byKey(const Key('mark-all-notifications-read-button')),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byKey(const Key('notification-card-notification-1')));
    await tester.pump();

    verifyNever(() => notificationsCubit.markAsRead(any()));
    verifyNever(() => notificationsCubit.markAllAsRead());
  });

  testWidgets('boş durumda anlaşılır bilgi ve yenileme sunar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const NotificationsLoaded(notifications: [], hasReachedMax: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz bildirimin yok'), findsOneWidget);
    expect(
      find.text('Alışveriş, mesaj ve kampanya bildirimlerin burada görünecek.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Yenile'));
    await tester.pump();

    verify(() => notificationsCubit.getNotifications(refresh: true)).called(2);
  });

  testWidgets('yükleme hatasında tekrar deneme sunar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        const NotificationsError(
          'Bildirimlerin şu anda yüklenemiyor. Lütfen tekrar dene.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bildirimlerin yüklenemedi'), findsOneWidget);
    expect(
      find.text('Bildirimlerin şu anda yüklenemiyor. Lütfen tekrar dene.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => notificationsCubit.getNotifications(refresh: true)).called(2);
  });
}
