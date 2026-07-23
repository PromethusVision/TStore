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

  Widget buildSubject(NotificationsState state) {
    whenListen(
      notificationsCubit,
      const Stream<NotificationsState>.empty(),
      initialState: state,
    );

    return MaterialApp(
      home: CustomerNotificationsView(notificationsCubit: notificationsCubit),
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

  testWidgets('yeni bildirime dokununca okundu işlemini başlatır', (
    tester,
  ) async {
    const notification = NotificationEntity(
      id: 'notification-1',
      userId: 'customer-1',
      title: 'Yeni mesajın var',
      body: 'Mağaza mesajına yanıt verdi.',
      type: NotificationType.chat,
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
