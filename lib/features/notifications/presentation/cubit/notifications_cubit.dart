import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required this.repository})
    : super(NotificationsInitial());

  final NotificationRepository repository;

  StreamSubscription<NotificationEntity>? _notificationsSubscription;
  List<NotificationEntity> _notifications = [];
  final Map<String, int> _realtimeRevisions = {};
  int _currentPage = 0;
  int _unreadCount = 0;
  int _requestGeneration = 0;
  int _realtimeRevision = 0;
  int? _activeRequestGeneration;
  int? _activeRequestPage;

  static const int _limit = 20;

  void startListening() {
    if (isClosed || _notificationsSubscription != null) return;

    try {
      late final StreamSubscription<NotificationEntity> subscription;
      subscription = repository.notificationsStream.listen(
        _handleRealtimeNotification,
        onError: (Object _, StackTrace _) {},
        onDone: () {
          if (identical(_notificationsSubscription, subscription)) {
            _notificationsSubscription = null;
          }
        },
      );
      _notificationsSubscription = subscription;
    } catch (_) {
      _notificationsSubscription = null;
    }
  }

  void _handleRealtimeNotification(NotificationEntity notification) {
    if (isClosed) return;

    final notificationIndex = _notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    final isNewNotification = notificationIndex == -1;

    if (!isNewNotification &&
        _notifications[notificationIndex] == notification) {
      return;
    }

    _realtimeRevision++;
    _realtimeRevisions[notification.id] = _realtimeRevision;

    if (isNewNotification) {
      _notifications = [notification, ..._notifications];
      if (!notification.isRead) _unreadCount++;
    } else {
      final previousNotification = _notifications[notificationIndex];
      final wasUnread = !previousNotification.isRead;
      final isUnread = !notification.isRead;
      if (wasUnread != isUnread) {
        _unreadCount += isUnread ? 1 : -1;
        if (_unreadCount < 0) _unreadCount = 0;
      }

      _notifications = [..._notifications]..[notificationIndex] = notification;
    }

    final previousState = state;
    if (isNewNotification) {
      emit(NewNotificationReceived(notification));
    }
    if (isClosed) return;

    if (previousState is NotificationsLoaded) {
      emit(
        previousState.copyWith(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ),
      );
      return;
    }

    emit(
      NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
      ),
    );
  }

  Future<void> getNotifications({bool refresh = false}) async {
    if (isClosed || _hasMutationInProgress(state)) return;

    if (_activeRequestGeneration != null) {
      final isInitialPageLoading = _activeRequestPage == 0;
      if (!refresh || isInitialPageLoading) return;
    }

    final previousState = state is NotificationsLoaded
        ? state as NotificationsLoaded
        : null;

    if (refresh) {
      final subscription = _notificationsSubscription;
      _notificationsSubscription = null;
      if (subscription != null) {
        unawaited(subscription.cancel());
      }

      _requestGeneration++;
      _currentPage = 0;
      _notifications = [];
      _realtimeRevisions.clear();
    }

    final requestGeneration = _requestGeneration;
    final requestedPage = _currentPage;
    final realtimeRevisionAtStart = _realtimeRevision;
    _activeRequestGeneration = requestGeneration;
    _activeRequestPage = requestedPage;

    if (requestedPage == 0) {
      emit(NotificationsLoading());
    } else if (previousState != null) {
      emit(
        previousState.copyWith(isLoadingMore: true, clearLoadMoreError: true),
      );
    }

    try {
      final result = await repository.getNotifications(
        page: requestedPage,
        limit: _limit,
      );
      if (!_isCurrentRequest(requestGeneration, requestedPage)) return;

      await result.fold(
        (_) async {
          if (!_isCurrentRequest(requestGeneration, requestedPage)) return;

          if (requestedPage == 0 || previousState == null) {
            emit(
              const NotificationsError(
                'Bildirimlerin şu anda yüklenemiyor. Lütfen tekrar dene.',
              ),
            );
            return;
          }

          final latestState = state;
          final stateToPreserve = latestState is NotificationsLoaded
              ? latestState
              : previousState;
          emit(
            stateToPreserve.copyWith(
              isLoadingMore: false,
              loadMoreError: 'Diğer bildirimler yüklenemedi.',
            ),
          );
        },
        (notifications) async {
          final unreadResult = await repository.getUnreadCount();
          if (!_isCurrentRequest(requestGeneration, requestedPage)) return;

          final mergedNotifications = [..._notifications];
          final notificationIndexes = <String, int>{
            for (var index = 0; index < mergedNotifications.length; index++)
              mergedNotifications[index].id: index,
          };

          for (final notification in notifications) {
            final existingIndex = notificationIndexes[notification.id];
            if (existingIndex == null) {
              notificationIndexes[notification.id] = mergedNotifications.length;
              mergedNotifications.add(notification);
              continue;
            }

            final realtimeRevision = _realtimeRevisions[notification.id] ?? 0;
            if (realtimeRevision <= realtimeRevisionAtStart) {
              mergedNotifications[existingIndex] = notification;
            }
          }

          _notifications = mergedNotifications;
          _currentPage = requestedPage + 1;
          _unreadCount = unreadResult.fold(
            (_) => _notifications.where((item) => !item.isRead).length,
            (count) => count,
          );

          emit(
            NotificationsLoaded(
              notifications: _notifications,
              unreadCount: _unreadCount,
              hasReachedMax: notifications.length < _limit,
            ),
          );
          startListening();
        },
      );
    } finally {
      if (_activeRequestGeneration == requestGeneration &&
          _activeRequestPage == requestedPage) {
        _activeRequestGeneration = null;
        _activeRequestPage = null;
      }
    }
  }

  bool _isCurrentRequest(int generation, int page) {
    return !isClosed &&
        _activeRequestGeneration == generation &&
        _activeRequestPage == page;
  }

  bool _hasMutationInProgress(NotificationsState currentState) {
    return currentState is NotificationsLoaded &&
        currentState.hasActionInProgress;
  }

  Future<void> loadMoreNotifications() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore ||
        currentState.hasActionInProgress) {
      return;
    }
    await getNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isLoadingMore ||
        currentState.isMarkingAllAsRead ||
        currentState.isDeletingAll ||
        currentState.markingAsReadIds.contains(notificationId) ||
        currentState.deletingIds.contains(notificationId)) {
      return;
    }

    final notificationIndex = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (notificationIndex == -1 || _notifications[notificationIndex].isRead) {
      return;
    }

    emit(
      currentState.copyWith(
        markingAsReadIds: {...currentState.markingAsReadIds, notificationId},
        clearActionError: true,
      ),
    );

    final result = await repository.markAsRead(notificationId);
    if (isClosed) return;

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
        final latestNotificationIndex = _notifications.indexWhere(
          (notification) => notification.id == notificationId,
        );
        if (latestNotificationIndex != -1 &&
            !_notifications[latestNotificationIndex].isRead) {
          _notifications = [..._notifications]
            ..[latestNotificationIndex] =
                _notifications[latestNotificationIndex].copyWith(isRead: true);
          if (_unreadCount > 0) _unreadCount--;
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
        currentState.isLoadingMore ||
        currentState.unreadCount == 0 ||
        currentState.hasActionInProgress) {
      return;
    }

    emit(
      currentState.copyWith(isMarkingAllAsRead: true, clearActionError: true),
    );

    final result = await repository.markAllAsRead();
    if (isClosed) return;

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
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isLoadingMore ||
        currentState.isMarkingAllAsRead ||
        currentState.isDeletingAll ||
        currentState.markingAsReadIds.contains(notificationId) ||
        currentState.deletingIds.contains(notificationId) ||
        !_notifications.any(
          (notification) => notification.id == notificationId,
        )) {
      return;
    }

    emit(
      currentState.copyWith(
        deletingIds: {...currentState.deletingIds, notificationId},
        clearActionError: true,
      ),
    );

    final result = await repository.deleteNotification(notificationId);
    if (isClosed) return;

    result.fold(
      (_) {
        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              deletingIds: {...latestState.deletingIds}..remove(notificationId),
              actionError: 'Bildirim silinemedi. Lütfen tekrar deneyin.',
            ),
          );
        }
      },
      (_) {
        final notificationIndex = _notifications.indexWhere(
          (notification) => notification.id == notificationId,
        );
        if (notificationIndex != -1) {
          if (!_notifications[notificationIndex].isRead && _unreadCount > 0) {
            _unreadCount--;
          }
          _notifications = [..._notifications]..removeAt(notificationIndex);
          _realtimeRevisions.remove(notificationId);

          final nextPage = _notifications.length ~/ _limit;
          if (_currentPage > nextPage) _currentPage = nextPage;
        }

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: _notifications,
              unreadCount: _unreadCount,
              deletingIds: {...latestState.deletingIds}..remove(notificationId),
              clearActionError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> deleteAllNotifications() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.notifications.isEmpty ||
        currentState.isLoadingMore ||
        currentState.hasActionInProgress) {
      return;
    }

    emit(currentState.copyWith(isDeletingAll: true, clearActionError: true));

    final result = await repository.deleteAllNotifications();
    if (isClosed) return;

    result.fold(
      (_) {
        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              isDeletingAll: false,
              actionError: 'Bildirimler silinemedi. Lütfen tekrar deneyin.',
            ),
          );
        }
      },
      (_) {
        _notifications = [];
        _realtimeRevisions.clear();
        _currentPage = 0;
        _unreadCount = 0;

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: const [],
              unreadCount: 0,
              hasReachedMax: true,
              isDeletingAll: false,
              clearActionError: true,
            ),
          );
        }
      },
    );
  }

  int get unreadCount => _unreadCount;

  @override
  Future<void> close() async {
    _requestGeneration++;
    _activeRequestGeneration = null;
    _activeRequestPage = null;

    final subscription = _notificationsSubscription;
    _notificationsSubscription = null;
    await subscription?.cancel();
    await super.close();
  }
}
