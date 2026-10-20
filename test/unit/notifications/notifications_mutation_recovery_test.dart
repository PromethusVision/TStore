import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class _Repository extends Mock implements NotificationRepository {}

const original = NotificationEntity(
  id: 'old',
  userId: 'owner',
  title: 'Yerel bildirim',
  body: 'Sentetik içerik',
  type: NotificationType.system,
);
void main() {
  late _Repository repository;
  late NotificationsCubit cubit;
  late StreamController<NotificationEntity> events;
  setUp(() async {
    repository = _Repository();
    events = StreamController<NotificationEntity>.broadcast(sync: true);
    when(() => repository.notificationsStream).thenAnswer((_) => events.stream);
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => const Right([original]));
    when(repository.getUnreadCount).thenAnswer((_) async => const Right(1));
    cubit = NotificationsCubit(repository: repository);
    await cubit.getNotifications();
  });
  tearDown(() async {
    await cubit.close();
    await events.close();
  });

  for (final delete in [false, true]) {
    test(
      'late ${delete ? 'delete all' : 'mark all'} acknowledgement preserves newer live arrivals',
      () async {
        final pending = Completer<Either<String, void>>();
        if (delete) {
          when(
            repository.deleteAllNotifications,
          ).thenAnswer((_) => pending.future);
        } else {
          when(repository.markAllAsRead).thenAnswer((_) => pending.future);
        }
        final work = delete
            ? cubit.deleteAllNotifications()
            : cubit.markAllAsRead();
        final arrived = original.copyWith(id: 'new');
        events.add(arrived);
        pending.complete(const Right(null));
        await work;
        final state = cubit.state as NotificationsLoaded;
        expect(state.notifications.where((n) => n.id == 'new'), [arrived]);
        expect(state.unreadCount, 1);
      },
    );
  }
  for (final operation in ['read', 'read-all', 'delete', 'delete-all']) {
    test('thrown $operation is recoverable and releases action lock', () async {
      when(
        () => repository.markAsRead('old'),
      ).thenThrow(StateError('synthetic'));
      when(repository.markAllAsRead).thenThrow(StateError('synthetic'));
      when(
        () => repository.deleteNotification('old'),
      ).thenThrow(StateError('synthetic'));
      when(
        repository.deleteAllNotifications,
      ).thenThrow(StateError('synthetic'));
      Object? error;
      try {
        await switch (operation) {
          'read' => cubit.markAsRead('old'),
          'read-all' => cubit.markAllAsRead(),
          'delete' => cubit.deleteNotification('old'),
          _ => cubit.deleteAllNotifications(),
        };
      } catch (e) {
        error = e;
      }
      expect(error, isNull);
      final state = cubit.state as NotificationsLoaded;
      expect(state.hasActionInProgress, false);
      expect(state.actionError, isNotNull);
      expect(state.notifications, [original]);
    });
  }
  test(
    'late realtime update cannot resurrect an acknowledged deletion',
    () async {
      when(
        () => repository.deleteNotification('old'),
      ).thenAnswer((_) async => const Right(null));
      await cubit.deleteNotification('old');
      events.add(original);
      expect((cubit.state as NotificationsLoaded).notifications, isEmpty);
    },
  );
  test('count response cannot undercount a newer live unread row', () async {
    final count = Completer<Either<String, int>>();
    when(repository.getUnreadCount).thenAnswer((_) => count.future);
    final refresh = cubit.getNotifications(refresh: true);
    cubit.startListening();
    await pumpEventQueue();
    events.add(original.copyWith(id: 'new'));
    count.complete(const Right(1));
    await refresh;
    expect((cubit.state as NotificationsLoaded).unreadCount, 2);
  });
}
