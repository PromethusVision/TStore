import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

class MockUser extends Mock implements User {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseService supabaseService;

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.insert);
    registerFallbackValue(
      PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: 'fallback-user',
      ),
    );
    registerFallbackValue((PostgresChangePayload _) {});
    registerFallbackValue((RealtimeSubscribeStatus _, Object? _) {});
  });

  setUp(() {
    supabaseService = MockSupabaseService();
  });

  test('oturum yokken yazma işlemleri başarılıymış gibi davranmaz', () async {
    when(() => supabaseService.currentUser).thenReturn(null);
    final repository = NotificationRepositoryImpl(
      supabaseService: supabaseService,
    );

    expect(
      await repository.markAsRead('notification-1'),
      const Left<String, void>(CustomerErrorMessage.signInRequired),
    );
    expect(
      await repository.markAllAsRead(),
      const Left<String, void>(CustomerErrorMessage.signInRequired),
    );
    expect(
      await repository.deleteNotification('notification-1'),
      const Left<String, void>(CustomerErrorMessage.signInRequired),
    );
    expect(
      await repository.deleteAllNotifications(),
      const Left<String, void>(CustomerErrorMessage.signInRequired),
    );
    expect(await repository.getUnreadCount(), const Right<String, int>(0));
    expect(await repository.notificationsStream.toList(), isEmpty);
  });

  test('Realtime kaynağını aktif kullanıcı kimliğiyle açar', () async {
    final user = MockUser();
    when(() => user.id).thenReturn('customer-1');
    when(() => supabaseService.currentUser).thenReturn(user);

    final controller = StreamController<NotificationEntity>();
    addTearDown(controller.close);
    String? requestedUserId;
    final repository = NotificationRepositoryImpl(
      supabaseService: supabaseService,
      realtimeSource: (userId) {
        requestedUserId = userId;
        return controller.stream;
      },
    );
    final receivedNotifications = <NotificationEntity>[];
    final subscription = repository.notificationsStream.listen(
      receivedNotifications.add,
    );

    const notification = NotificationEntity(
      id: 'notification-1',
      userId: 'customer-1',
      title: 'Yeni bildirim',
      body: 'Bildirim açıklaması',
      type: NotificationType.system,
    );
    controller.add(notification);
    await pumpEventQueue();

    expect(requestedUserId, 'customer-1');
    expect(receivedNotifications, const [notification]);
    await subscription.cancel();
  });

  test(
    'Realtime dinleyicilerine benzersiz kanal açar ve ayrılınca kapatır',
    () async {
      final user = MockUser();
      final channel = MockRealtimeChannel();
      final client = MockSupabaseClient();
      final callbacks =
          <
            ({
              PostgresChangeEvent event,
              void Function(PostgresChangePayload) callback,
            })
          >[];
      final statusCallbacks =
          <void Function(RealtimeSubscribeStatus, Object?)>[];
      when(() => user.id).thenReturn('customer-1');
      when(() => supabaseService.currentUser).thenReturn(user);
      when(() => supabaseService.client).thenReturn(client);
      when(() => client.channel(any())).thenReturn(channel);
      when(
        () => channel.onPostgresChanges(
          event: any(named: 'event'),
          schema: any(named: 'schema'),
          table: any(named: 'table'),
          filter: any(named: 'filter'),
          callback: any(named: 'callback'),
        ),
      ).thenAnswer((invocation) {
        callbacks.add((
          event: invocation.namedArguments[#event]! as PostgresChangeEvent,
          callback:
              invocation.namedArguments[#callback]!
                  as void Function(PostgresChangePayload),
        ));
        return channel;
      });
      when(() => channel.subscribe(any())).thenAnswer((invocation) {
        statusCallbacks.add(
          invocation.positionalArguments.first
              as void Function(RealtimeSubscribeStatus, Object?),
        );
        return channel;
      });
      when(() => supabaseService.unsubscribe(channel)).thenAnswer((_) async {});
      final repository = NotificationRepositoryImpl(
        supabaseService: supabaseService,
      );

      final firstNotifications = <NotificationEntity>[];
      final firstDone = Completer<void>();
      final firstSubscription = repository.notificationsStream.listen(
        firstNotifications.add,
        onError: (Object _) {},
        onDone: firstDone.complete,
      );
      final secondSubscription = repository.notificationsStream.listen((_) {});
      final channelNames = verify(
        () => client.channel(captureAny()),
      ).captured.cast<String>();
      expect(channelNames, hasLength(2));
      expect(
        channelNames.every(
          (name) => name.startsWith('notifications:customer-1:'),
        ),
        isTrue,
      );
      expect(channelNames.first, isNot(channelNames.last));
      verify(
        () => channel.onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.notifications,
          filter: any(named: 'filter'),
          callback: any(named: 'callback'),
        ),
      ).called(2);
      verify(
        () => channel.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: SupabaseTables.notifications,
          filter: any(named: 'filter'),
          callback: any(named: 'callback'),
        ),
      ).called(2);

      callbacks
          .firstWhere(
            (registration) => registration.event == PostgresChangeEvent.insert,
          )
          .callback(
            PostgresChangePayload(
              schema: 'public',
              table: SupabaseTables.notifications,
              commitTimestamp: DateTime(2026, 8, 11),
              eventType: PostgresChangeEvent.insert,
              newRecord: const {
                'id': 'notification-realtime',
                'user_id': 'customer-1',
                'title': 'Yeni bildirim',
                'body': 'Bildirim açıklaması',
                'type': 'system',
                'is_read': false,
              },
              oldRecord: const {},
              errors: null,
            ),
          );
      await pumpEventQueue();

      expect(firstNotifications, hasLength(1));
      expect(firstNotifications.single.id, 'notification-realtime');

      statusCallbacks.first(
        RealtimeSubscribeStatus.channelError,
        StateError('channel failed'),
      );
      await firstDone.future;
      await firstSubscription.cancel();
      await secondSubscription.cancel();
      await pumpEventQueue();

      verify(() => supabaseService.unsubscribe(channel)).called(2);
    },
  );
}
