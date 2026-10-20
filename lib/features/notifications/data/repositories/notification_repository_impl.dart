import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/authenticated_request_scope.dart';
import 'package:t_store/core/supabase/authenticated_session_key.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/notifications/data/models/notification_model.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';

typedef NotificationRealtimeSource =
    Stream<NotificationEntity> Function(String userId);

class NotificationRepositoryImpl
    implements NotificationRepository, NotificationSessionSource {
  NotificationRepositoryImpl({
    required this.supabaseService,
    NotificationRealtimeSource? realtimeSource,
  }) : _realtimeSource = realtimeSource;

  final SupabaseService supabaseService;
  final NotificationRealtimeSource? _realtimeSource;

  static int _nextRealtimeChannelId = 0;

  String get _userId => supabaseService.currentUser?.id ?? '';

  @override
  String? get currentUserId => supabaseService.currentUser?.id;
  @override
  String? get currentSessionKey =>
      authenticatedSessionKey(supabaseService.client);
  @override
  Stream<String?> get sessionKeyChanges => supabaseService
      .client
      .auth
      .onAuthStateChange
      .map((event) => authenticatedSessionKeyFromSession(event.session));
  AuthenticatedRequestScope _scope(String user) => AuthenticatedRequestScope(
    user: user,
    session: currentSessionKey,
    currentUser: () => currentUserId,
    currentSession: () => currentSessionKey,
    changes: supabaseService.client.auth.onAuthStateChange.map(
      (e) => e.session?.user.id,
    ),
    sessionKeys: sessionKeyChanges,
  );

  @override
  Future<Either<String, List<NotificationEntity>>> getNotifications({
    int page = 0,
    int limit = 20,
  }) async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }
      scope = _scope(userId);
      scope.check();

      final from = page * limit;
      final to = from + limit - 1;

      final response = await supabaseService.client
          .from(SupabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(from, to)
          .timeout(const Duration(seconds: 15));

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      final notifications = (response as List)
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      if (notifications.any((n) => n.userId != userId)) {
        throw const FormatException();
      }
      return Right(notifications);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }
      scope = _scope(userId);
      scope.check();

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirim güncellenemedi. Lütfen tekrar deneyin.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead() async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }
      scope = _scope(userId);
      scope.check();

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler güncellenemedi. Lütfen tekrar deneyin.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Future<Either<String, void>> deleteNotification(String notificationId) async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }
      scope = _scope(userId);
      scope.check();

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirim silinemedi. Lütfen tekrar deneyin.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Future<Either<String, void>> deleteAllNotifications() async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }
      scope = _scope(userId);
      scope.check();

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .delete()
          .eq('user_id', userId);

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler silinemedi. Lütfen tekrar deneyin.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    AuthenticatedRequestScope? scope;
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Right(0);
      }
      scope = _scope(userId);
      scope.check();

      final response = await supabaseService.client
          .from(SupabaseTables.notifications)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .timeout(const Duration(seconds: 15));

      if (!scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return Right((response as List).length);
    } catch (e) {
      if (scope != null && !scope.current) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Okunmamış bildirim sayısı alınamadı.',
        ),
      );
    } finally {
      await scope?.close();
    }
  }

  @override
  Stream<NotificationEntity> get notificationsStream {
    final user = currentUserId;
    if (user == null || user.isEmpty) return const Stream.empty();
    final session = currentSessionKey;
    StreamSubscription<String?>? auth;
    StreamSubscription<NotificationEntity>? source;
    late final StreamController<NotificationEntity> controller;
    bool stopped = false;
    bool current() =>
        !stopped &&
        currentUserId == user &&
        session != null &&
        currentSessionKey == session;
    void stop() {
      if (stopped) return;
      stopped = true;
      unawaited(auth?.cancel());
      unawaited(source?.cancel());
      unawaited(controller.close());
    }

    controller = StreamController<NotificationEntity>(
      onListen: () {
        if (!current()) {
          stop();
          return;
        }
        auth = sessionKeyChanges.listen(
          (key) {
            if (key != session || !current()) stop();
          },
          onError: (Object _) => stop(),
          onDone: stop,
        );
        try {
          source =
              (_realtimeSource?.call(user) ?? _createNotificationsStream(user))
                  .listen(
                    (event) {
                      if (!current()) {
                        stop();
                        return;
                      }
                      if (event.userId == user) controller.add(event);
                    },
                    onError: (Object error, StackTrace stack) {
                      if (current()) {
                        controller.addError(error, stack);
                      } else {
                        stop();
                      }
                    },
                    onDone: stop,
                  );
        } catch (error, stack) {
          if (current()) controller.addError(error, stack);
          stop();
        }
      },
      onCancel: () async {
        stopped = true;
        await auth?.cancel();
        await source?.cancel();
      },
    );
    return controller.stream;
  }

  Stream<NotificationEntity> _createNotificationsStream(String userId) {
    RealtimeChannel? channel;
    late final StreamController<NotificationEntity> controller;

    void addNotification(PostgresChangePayload payload) {
      if (controller.isClosed) return;

      final record = payload.newRecord;
      if (record['user_id'] != userId) return;

      try {
        controller.add(NotificationModel.fromJson(record));
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<NotificationEntity>.broadcast(
      onListen: () {
        try {
          final userFilter = PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          );
          final channelId = _nextRealtimeChannelId++;
          channel = supabaseService.client
              .channel('notifications:$userId:$channelId')
              .onPostgresChanges(
                event: PostgresChangeEvent.insert,
                schema: 'public',
                table: SupabaseTables.notifications,
                filter: userFilter,
                callback: addNotification,
              )
              .onPostgresChanges(
                event: PostgresChangeEvent.update,
                schema: 'public',
                table: SupabaseTables.notifications,
                filter: userFilter,
                callback: addNotification,
              )
              .subscribe((status, error) {
                if (controller.isClosed) return;
                // Keep the SDK's transient reconnect behavior, but expose degraded reads.
                if (status == RealtimeSubscribeStatus.channelError ||
                    status == RealtimeSubscribeStatus.timedOut) {
                  controller.addError(
                    StateError('Notification Realtime is reconnecting.'),
                  );
                  return;
                }
                if (status != RealtimeSubscribeStatus.closed) return;

                controller.addError(
                  error ?? StateError('Notification Realtime channel closed.'),
                );
                unawaited(controller.close());
              });
        } catch (error, stackTrace) {
          controller.addError(error, stackTrace);
          unawaited(controller.close());
        }
      },
      onCancel: () {
        final activeChannel = channel;
        channel = null;
        if (activeChannel != null) {
          unawaited(supabaseService.unsubscribe(activeChannel));
        }
      },
    );

    return controller.stream;
  }
}
