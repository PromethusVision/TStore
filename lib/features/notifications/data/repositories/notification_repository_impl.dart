import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/notifications/data/models/notification_model.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';

typedef NotificationRealtimeSource =
    Stream<NotificationEntity> Function(String userId);

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.supabaseService,
    NotificationRealtimeSource? realtimeSource,
  }) : _realtimeSource = realtimeSource;

  final SupabaseService supabaseService;
  final NotificationRealtimeSource? _realtimeSource;

  static int _nextRealtimeChannelId = 0;

  String get _userId => supabaseService.currentUser?.id ?? '';

  bool _isCurrentSession(String userId) {
    try {
      return userId.isNotEmpty && _userId == userId;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<String, List<NotificationEntity>>> getNotifications({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      final from = page * limit;
      final to = from + limit - 1;

      final response = await supabaseService.client
          .from(SupabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(from, to);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      final notifications = (response as List)
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(notifications);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirim güncellenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead() async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler güncellenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> deleteNotification(String notificationId) async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirim silinemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> deleteAllNotifications() async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      await supabaseService.client
          .from(SupabaseTables.notifications)
          .delete()
          .eq('user_id', userId);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Bildirimler silinemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    try {
      final userId = _userId;
      if (userId.isEmpty) {
        return const Right(0);
      }

      final response = await supabaseService.client
          .from(SupabaseTables.notifications)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      if (!_isCurrentSession(userId)) {
        return const Left(CustomerErrorMessage.sessionExpired);
      }

      return Right((response as List).length);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Okunmamış bildirim sayısı alınamadı.',
        ),
      );
    }
  }

  @override
  Stream<NotificationEntity> get notificationsStream {
    final userId = _userId;
    if (userId.isEmpty) {
      return Stream.empty();
    }

    final realtimeSource = _realtimeSource;
    if (realtimeSource != null) {
      return realtimeSource(userId);
    }

    return _createNotificationsStream(userId);
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
                if (status != RealtimeSubscribeStatus.channelError &&
                    status != RealtimeSubscribeStatus.timedOut &&
                    status != RealtimeSubscribeStatus.closed) {
                  return;
                }
                if (controller.isClosed) return;

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
