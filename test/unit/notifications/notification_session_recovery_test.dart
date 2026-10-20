import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import '../../helpers/evaluation_auth_fixture.dart';
import '../../helpers/fake_evaluation_repository.dart';

class _Service extends Mock implements SupabaseService {}

void main() {
  late SupabaseClient client;
  late _Service service;
  late NotificationRepositoryImpl repository;
  late Completer<void> started, release;
  final events = <NotificationEntity>[];
  late StreamController<NotificationEntity> realtime;
  setUp(() async {
    events.clear();
    started = Completer<void>();
    release = Completer<void>();
    realtime = StreamController<NotificationEntity>.broadcast(sync: true);
    client = SupabaseClient(
      'http://127.0.0.1:55431',
      'synthetic-anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/rest/v1/notifications');
        expect(request.url.queryParameters['user_id'], 'eq.$evaluationActor');
        started.complete();
        await release.future;
        return http.Response(
          jsonEncode([]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    service = _Service();
    when(() => service.client).thenReturn(client);
    when(() => service.currentUser).thenAnswer((_) => client.auth.currentUser);
    await installEvaluationSession(client, 'S1');
    await pumpEventQueue();
    repository = NotificationRepositoryImpl(
      supabaseService: service,
      realtimeSource: (_) => realtime.stream,
    );
  });
  tearDown(() async {
    await realtime.close();
    await client.dispose();
  });

  for (final operation in [
    'list',
    'count',
    'read',
    'read-all',
    'delete',
    'delete-all',
  ]) {
    for (final replacement in [false, true]) {
      test(
        '$operation ${replacement ? 'rejects same-user replacement' : 'preserves normal renewal'}',
        () async {
          final pending = switch (operation) {
            'list' => repository.getNotifications(),
            'count' => repository.getUnreadCount(),
            'read' => repository.markAsRead('notice'),
            'read-all' => repository.markAllAsRead(),
            'delete' => repository.deleteNotification('notice'),
            _ => repository.deleteAllNotifications(),
          };
          await started.future;
          await installEvaluationSession(
            client,
            replacement ? 'S2' : 'S1',
            tokenRevision: 1,
          );
          await pumpEventQueue();
          release.complete();
          expect((await pending).isLeft(), replacement);
        },
      );
    }
  }

  const notice = NotificationEntity(
    id: 'notice',
    userId: evaluationActor,
    title: 'Yerel bildirim',
    body: 'Sentetik içerik',
    type: NotificationType.system,
  );
  test(
    'queued same-account replacement permanently closes old realtime',
    () async {
      final sub = repository.notificationsStream.listen(
        events.add,
        onError: (Object _) {},
      );
      realtime.add(notice);
      await pumpEventQueue();
      await installEvaluationSession(client, 'S2');
      await installEvaluationSession(client, 'S1');
      await pumpEventQueue();
      realtime.add(notice.copyWith(id: 'stale'));
      await pumpEventQueue();
      expect(events.map((n) => n.id), ['notice']);
      await sub.cancel();
    },
  );
  test(
    'realtime rejects foreign recipients even through the adapter seam',
    () async {
      final sub = repository.notificationsStream.listen(
        events.add,
        onError: (Object _) {},
      );
      realtime.add(notice.copyWith(userId: 'foreign'));
      await pumpEventQueue();
      expect(events, isEmpty);
      await sub.cancel();
    },
  );
}
