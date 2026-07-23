import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;
  StreamSubscription<NotificationEntity>? _notificationsSubscription;

  NotificationsCubit({required this.repository})
    : super(NotificationsInitial());

  List<NotificationEntity> _notifications = [];
  int _currentPage = 0;
  int _unreadCount = 0;
  bool _isLoading = false;
  static const int _limit = 20;

  void startListening() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = repository.notificationsStream.listen((
      notification,
    ) {
      _notifications = [notification, ..._notifications];
      _unreadCount++;
      emit(NewNotificationReceived(notification));
      emit(
        NotificationsLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
    });
  }

  Future<void> getNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _notifications = [];
    }

    final previousState = state is NotificationsLoaded
        ? state as NotificationsLoaded
        : null;

    if (_currentPage == 0) {
      emit(NotificationsLoading());
    } else if (previousState != null) {
      emit(
        previousState.copyWith(isLoadingMore: true, clearLoadMoreError: true),
      );
    }

    _isLoading = true;
    try {
      final result = await repository.getNotifications(
        page: _currentPage,
        limit: _limit,
      );

      await result.fold(
        (_) async {
          if (_currentPage == 0 || previousState == null) {
            emit(
              const NotificationsError(
                'Bildirimlerin şu anda yüklenemiyor. Lütfen tekrar dene.',
              ),
            );
            return;
          }

          emit(
            previousState.copyWith(
              isLoadingMore: false,
              loadMoreError: 'Diğer bildirimler yüklenemedi.',
            ),
          );
        },
        (notifications) async {
          _notifications = {
            for (final notification in _notifications)
              notification.id: notification,
            for (final notification in notifications)
              notification.id: notification,
          }.values.toList();
          _currentPage++;

          final unreadResult = await repository.getUnreadCount();
          _unreadCount = unreadResult.fold(
            (_) => _notifications
                .where((notification) => !notification.isRead)
                .length,
            (count) => count,
          );

          emit(
            NotificationsLoaded(
              notifications: _notifications,
              unreadCount: _unreadCount,
              hasReachedMax: notifications.length < _limit,
            ),
          );
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      if (currentState.hasReachedMax) return;
      await getNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isMarkingAllAsRead ||
        currentState.markingAsReadIds.contains(notificationId)) {
      return;
    }

    final notificationIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (notificationIndex == -1 || _notifications[notificationIndex].isRead) {
      return;
    }

    final markingIds = {...currentState.markingAsReadIds, notificationId};
    emit(
      currentState.copyWith(
        markingAsReadIds: markingIds,
        clearActionError: true,
      ),
    );

    final result = await repository.markAsRead(notificationId);
    result.fold(
      (_) {
        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              markingAsReadIds: {...latestState.markingAsReadIds}
                ..remove(notificationId),
              actionError: 'Bildirim güncellenemedi. Lütfen tekrar deneyin.',
            ),
          );
        }
      },
      (_) {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId && !notification.isRead) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        if (_unreadCount > 0) {
          _unreadCount--;
        }

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: _notifications,
              unreadCount: _unreadCount,
              markingAsReadIds: {...latestState.markingAsReadIds}
                ..remove(notificationId),
              clearActionError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.unreadCount == 0 ||
        currentState.isMarkingAllAsRead ||
        currentState.markingAsReadIds.isNotEmpty) {
      return;
    }

    emit(
      currentState.copyWith(isMarkingAllAsRead: true, clearActionError: true),
    );

    final result = await repository.markAllAsRead();
    result.fold(
      (_) {
        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              isMarkingAllAsRead: false,
              actionError: 'Bildirimler güncellenemedi. Lütfen tekrar deneyin.',
            ),
          );
        }
      },
      (_) {
        _notifications = _notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: _notifications,
              unreadCount: 0,
              isMarkingAllAsRead: false,
              clearActionError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    await repository.deleteNotification(notificationId);
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
    );
    if (!notification.isRead) _unreadCount--;
    _notifications = _notifications
        .where((n) => n.id != notificationId)
        .toList();
    emit(
      NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
      ),
    );
  }

  Future<void> deleteAllNotifications() async {
    await repository.deleteAllNotifications();
    _notifications = [];
    _unreadCount = 0;
    emit(NotificationsLoaded(notifications: [], unreadCount: 0));
  }

  int get unreadCount => _unreadCount;

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
