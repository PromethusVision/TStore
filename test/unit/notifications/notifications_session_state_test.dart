import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import '../../helpers/inbox_recovery_fixture.dart';

void main() {
  late FakeInboxRepository repository;
  late NotificationsCubit cubit;
  setUp(() {
    repository = FakeInboxRepository();
    cubit = NotificationsCubit(repository: repository);
  });
  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  for (final actor in <String?>['owner', 'other', null]) {
    test(
      'session replacement for $actor clears rows and count permanently',
      () async {
        await cubit.getNotifications();
        repository.replace(actor == null ? null : 'S2', actor: actor);
        expect(cubit.state, isA<NotificationsError>());
        expect(cubit.unreadCount, 0);
        repository.replace('S1');
        repository.live.add(inboxNotice);
        await cubit.getNotifications(refresh: true);
        expect(cubit.state, isA<NotificationsError>());
        expect(repository.pages, [0]);
        await cubit.markAsRead(inboxNotice.id);
        expect(repository.writes, isEmpty);
      },
    );
  }
  for (final waitForCount in [false, true]) {
    test(
      'late ${waitForCount ? 'count' : 'page'} cannot restore private data',
      () async {
        final page = Completer<Either<String, List<NotificationEntity>>>();
        final count = Completer<Either<String, int>>();
        repository.read = () => page.future;
        repository.count = () => count.future;
        final pending = cubit.getNotifications();
        if (waitForCount) {
          page.complete(const Right([inboxNotice]));
          await pumpEventQueue();
        }
        repository.replace('S2');
        if (!waitForCount) page.complete(const Right([inboxNotice]));
        count.complete(const Right(200));
        await pending;
        expect(cubit.state, isA<NotificationsError>());
        expect(cubit.unreadCount, 0);
        expect(repository.counts, waitForCount ? 1 : 0);
      },
    );
  }
  for (final operation in ['read', 'read-all', 'delete', 'delete-all']) {
    test(
      'late $operation completion detects replacement without delivered event',
      () async {
        await cubit.getNotifications();
        final write = Completer<Either<String, void>>();
        repository.write = () => write.future;
        final pending = switch (operation) {
          'read' => cubit.markAsRead(inboxNotice.id),
          'read-all' => cubit.markAllAsRead(),
          'delete' => cubit.deleteNotification(inboxNotice.id),
          _ => cubit.deleteAllNotifications(),
        };
        repository.currentSessionKey = 'S2';
        write.complete(const Right(null));
        await pending;
        expect(cubit.state, isA<NotificationsError>());
        expect(cubit.unreadCount, 0);
        expect(cubit.sessionCurrent, false);
      },
    );
  }
  test('ordinary renewal preserves pending action and loaded rows', () async {
    await cubit.getNotifications();
    final write = Completer<Either<String, void>>();
    repository.write = () => write.future;
    final pending = cubit.markAsRead(inboxNotice.id);
    repository.replace('S1');
    final before = cubit.state as NotificationsLoaded;
    expect(before.notifications, [inboxNotice]);
    expect(before.hasActionInProgress, true);
    write.complete(const Right(null));
    await pending;
    expect(
      (cubit.state as NotificationsLoaded).notifications.single.isRead,
      true,
    );
    expect(cubit.sessionCurrent, true);
  });
  for (final failure in [false, true]) {
    test(
      'session observer ${failure ? 'error' : 'closure'} removes private state',
      () async {
        await cubit.getNotifications();
        if (failure) {
          repository.sessions.addError(StateError('synthetic'));
        } else {
          await repository.sessions.close();
        }
        expect(cubit.state, isA<NotificationsError>());
        expect(cubit.unreadCount, 0);
      },
    );
  }
  test(
    'foreign realtime recipient is rejected without corrupting unread count',
    () async {
      await cubit.getNotifications();
      repository.live.add(inboxNotice.copyWith(id: 'other', userId: 'other'));
      expect((cubit.state as NotificationsLoaded).notifications, [inboxNotice]);
      expect(cubit.unreadCount, 1);
    },
  );
  test(
    'connection error preserves rows and clears after a valid live event',
    () async {
      await cubit.getNotifications();
      repository.live.addError(
        StateError('synthetic token must not be exposed'),
      );
      final error = cubit.state as NotificationsLoaded;
      expect(error.realtimeError, isNotNull);
      expect(error.realtimeError, isNot(contains('token')));
      expect(error.notifications, [inboxNotice]);
      repository.live.add(inboxNotice);
      expect((cubit.state as NotificationsLoaded).realtimeError, null);
    },
  );
}
