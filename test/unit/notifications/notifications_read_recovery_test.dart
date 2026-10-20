import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class _Repository extends Mock implements NotificationRepository {}

const _notice = NotificationEntity(
  id: 'notice',
  userId: 'owner',
  title: 'Yerel bildirim',
  body: 'İşlem',
  type: NotificationType.system,
);

void main() {
  late _Repository repository;
  late NotificationsCubit cubit;
  setUp(() {
    repository = _Repository();
    when(
      () => repository.notificationsStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.getUnreadCount(),
    ).thenAnswer((_) async => const Right(1));
    cubit = NotificationsCubit(repository: repository);
  });
  tearDown(() => cubit.close());

  for (final waitingForCount in [false, true]) {
    testWidgets(
      'realtime cannot expose mutable partial inbox while ${waitingForCount ? 'count' : 'first page'} is pending',
      (tester) async {
        final events = StreamController<NotificationEntity>.broadcast(
          sync: true,
        );
        addTearDown(events.close);
        when(
          () => repository.notificationsStream,
        ).thenAnswer((_) => events.stream);
        final page = Completer<Either<String, List<NotificationEntity>>>();
        final count = Completer<Either<String, int>>();
        final write = Completer<Either<String, void>>();
        when(
          () => repository.getNotifications(page: 0, limit: 20),
        ).thenAnswer((_) => page.future);
        when(repository.getUnreadCount).thenAnswer((_) => count.future);
        when(
          () => repository.markAsRead(_notice.id),
        ).thenAnswer((_) => write.future);
        cubit.startListening();
        final read = cubit.getNotifications();
        if (waitingForCount) {
          page.complete(const Right([_notice]));
          await tester.pump();
        }
        events.add(_notice);
        final newer = _notice.copyWith(title: 'Güncel canlı bildirim');
        events.add(newer);
        final pendingState = cubit.state;
        final prematureWrite = cubit.markAsRead(_notice.id);
        if (!waitingForCount) page.complete(const Right([_notice]));
        count.complete(const Right(1));
        await read;
        final settled = cubit.state as NotificationsLoaded;
        final allowedWrite = cubit.markAsRead(_notice.id);
        write.complete(const Right(null));
        await Future.wait([prematureWrite, allowedWrite]);

        expect(
          pendingState,
          isA<NotificationsLoading>(),
          reason: 'A realtime event cannot finish the initial snapshot early.',
        );
        expect(
          settled.notifications,
          [newer],
          reason: 'Buffer the event without losing the newer revision.',
        );
        verify(() => repository.markAsRead(_notice.id)).called(1);
      },
    );
  }

  test(
    'thrown first-page failure becomes retryable state, not unhandled error',
    () async {
      when(
        () => repository.getNotifications(page: 0, limit: 20),
      ).thenThrow(StateError('transport closed'));
      Object? uncaught;
      try {
        await cubit.getNotifications();
      } catch (error) {
        uncaught = error;
      }
      expect(uncaught, isNull);
      expect(cubit.state, isA<NotificationsError>());
      when(
        () => repository.getNotifications(page: 0, limit: 20),
      ).thenAnswer((_) async => const Right([_notice]));
      await cubit.getNotifications(refresh: true);
      expect((cubit.state as NotificationsLoaded).notifications, [_notice]);
    },
  );

  testWidgets('hung first page leaves loading within the read deadline', (
    tester,
  ) async {
    final pending = Completer<Either<String, List<NotificationEntity>>>();
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) => pending.future);
    final request = cubit.getNotifications();
    await tester.pump(const Duration(seconds: 16));
    final atDeadline = cubit.state;
    pending.complete(const Right([_notice]));
    await request;
    expect(atDeadline, isA<NotificationsError>());
    expect(
      cubit.state,
      isA<NotificationsError>(),
      reason: 'Late data cannot reopen an expired read.',
    );
  });

  testWidgets('hung unread count cannot strand an already loaded inbox', (
    tester,
  ) async {
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => const Right([_notice]));
    final pending = Completer<Either<String, int>>();
    when(repository.getUnreadCount).thenAnswer((_) => pending.future);
    final request = cubit.getNotifications();
    await tester.pump();
    await tester.pump(const Duration(seconds: 16));
    final atDeadline = cubit.state;
    pending.complete(const Right(500));
    await request;
    expect(atDeadline, isA<NotificationsLoaded>());
    expect(
      (cubit.state as NotificationsLoaded).unreadCount,
      1,
      reason: 'Late count cannot overwrite the visible unread fallback.',
    );
  });

  testWidgets('expired first page cannot replace a successful explicit retry', (
    tester,
  ) async {
    final pending = Completer<Either<String, List<NotificationEntity>>>();
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) => pending.future);
    final expired = cubit.getNotifications();
    await tester.pump(const Duration(seconds: 16));
    await expired;
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => Right([_notice.copyWith(title: 'Güncel')]));
    await cubit.getNotifications(refresh: true);
    pending.complete(const Right([_notice]));
    await tester.pump();
    expect(
      (cubit.state as NotificationsLoaded).notifications.single.title,
      'Güncel',
    );
    verify(repository.getUnreadCount).called(1);
  });

  testWidgets(
    'pagination deadline preserves visible rows and retries same page',
    (tester) async {
      final first = List.generate(20, (i) => _notice.copyWith(id: 'row-$i'));
      when(
        () => repository.getNotifications(page: 0, limit: 20),
      ).thenAnswer((_) async => Right(first));
      await cubit.getNotifications();
      final pending = Completer<Either<String, List<NotificationEntity>>>();
      when(
        () => repository.getNotifications(page: 1, limit: 20),
      ).thenAnswer((_) => pending.future);
      final expired = cubit.loadMoreNotifications();
      await tester.pump(const Duration(seconds: 16));
      await expired;
      final failed = cubit.state as NotificationsLoaded;
      expect(failed.notifications, first);
      expect(failed.isLoadingMore, isFalse);
      expect(failed.loadMoreError, isNotNull);
      when(
        () => repository.getNotifications(page: 1, limit: 20),
      ).thenAnswer((_) async => const Right([_notice]));
      await cubit.loadMoreNotifications();
      pending.complete(Right([_notice.copyWith(id: 'expired')]));
      await tester.pump();
      final recovered = cubit.state as NotificationsLoaded;
      expect(recovered.notifications, [...first, _notice]);
      expect(recovered.loadMoreError, isNull);
      expect(recovered.hasReachedMax, isTrue);
    },
  );

  testWidgets(
    'refresh supersedes pagination while its count is still pending',
    (tester) async {
      final first = List.generate(20, (i) => _notice.copyWith(id: 'row-$i'));
      when(
        () => repository.getNotifications(page: 0, limit: 20),
      ).thenAnswer((_) async => Right(first));
      await cubit.getNotifications();
      when(
        () => repository.getNotifications(page: 1, limit: 20),
      ).thenAnswer((_) async => const Right([_notice]));
      final count = Completer<Either<String, int>>();
      when(repository.getUnreadCount).thenAnswer((_) => count.future);
      final oldPage = cubit.loadMoreNotifications();
      await tester.pump();
      when(
        () => repository.getNotifications(page: 0, limit: 20),
      ).thenAnswer((_) async => const Right([_notice]));
      when(repository.getUnreadCount).thenAnswer((_) async => const Right(1));
      await cubit.getNotifications(refresh: true);
      count.complete(const Right(999));
      await oldPage;
      expect((cubit.state as NotificationsLoaded).notifications, [_notice]);
      expect(cubit.unreadCount, 1);
    },
  );

  test('thrown secondary count uses loaded-item fallback', () async {
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => const Right([_notice]));
    when(repository.getUnreadCount).thenThrow(StateError('transport closed'));
    await cubit.getNotifications();
    expect((cubit.state as NotificationsLoaded).unreadCount, 1);
  });

  test('closing during a read suppresses its later response', () async {
    final pending = Completer<Either<String, List<NotificationEntity>>>();
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) => pending.future);
    final read = cubit.getNotifications();
    await cubit.close();
    pending.complete(const Right([_notice]));
    await read;
    verifyNever(repository.getUnreadCount);
  });

  testWidgets('read deadline never declares an outstanding write failed', (
    tester,
  ) async {
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => const Right([_notice]));
    await cubit.getNotifications();
    final pending = Completer<Either<String, void>>();
    when(
      () => repository.markAsRead(_notice.id),
    ).thenAnswer((_) => pending.future);
    final write = cubit.markAsRead(_notice.id);
    await tester.pump(const Duration(seconds: 31));
    expect(
      (cubit.state as NotificationsLoaded).markingAsReadIds,
      contains(_notice.id),
    );
    expect((cubit.state as NotificationsLoaded).actionError, isNull);
    pending.complete(const Right(null));
    await write;
    expect(
      (cubit.state as NotificationsLoaded).notifications.single.isRead,
      isTrue,
    );
    verify(() => repository.markAsRead(_notice.id)).called(1);
  });
}
