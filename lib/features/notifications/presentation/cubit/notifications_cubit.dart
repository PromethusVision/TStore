import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.repository,
    this.readTimeout = const Duration(seconds: 15),
    NotificationSessionSource? sessionSource,
  }) : assert(readTimeout > Duration.zero),
       _sessionSource =
           sessionSource ??
           (repository is NotificationSessionSource
               ? repository as NotificationSessionSource
               : null),
       super(NotificationsInitial()) {
    _actor = _sessionSource?.currentUserId;
    _session = _sessionSource?.currentSessionKey;
    _sessionSubscription = _sessionSource?.sessionKeyChanges.listen(
      (key) {
        if (key != _session || !sessionCurrent) _expire();
      },
      onError: (Object _) => _expire(),
      onDone: _expire,
    );
  }

  final NotificationRepository repository;
  final NotificationSessionSource? _sessionSource;

  /// Long-lived hosts may replace this cubit; an expired instance never revives.
  NotificationSessionSource? get sessionSource => _sessionSource;
  late final String? _actor, _session;
  StreamSubscription<String?>? _sessionSubscription;
  bool _expired = false;
  bool get sessionCurrent =>
      !_expired &&
      (_sessionSource == null ||
          (_actor != null &&
              _session != null &&
              _sessionSource.currentUserId == _actor &&
              _sessionSource.currentSessionKey == _session));
  bool _ensureSession() {
    if (isClosed) return false;
    if (!sessionCurrent) {
      _expire();
      return false;
    }
    return true;
  }

  void _expire() {
    if (isClosed || _expired) return;
    _expired = true;
    ++_requestGeneration;
    ++_subscriptionGeneration;
    _activeRequestGeneration = null;
    _activeRequestPage = null;
    _notifications = [];
    _unreadCount = 0;
    _realtimeRevisions.clear();
    _deletedIds.clear();
    final subscription = _notificationsSubscription;
    _notificationsSubscription = null;
    unawaited(subscription?.cancel());
    emit(
      const NotificationsError(
        'Oturumunuz değişti. Bu ekranı kapatıp yeniden açın.',
      ),
    );
  }

  /// Bounds reads only. A deadline never cancels or retries a mutation.
  final Duration readTimeout;

  StreamSubscription<NotificationEntity>? _notificationsSubscription;
  List<NotificationEntity> _notifications = [];
  final Map<String, int> _realtimeRevisions = {};
  int _currentPage = 0;
  int _unreadCount = 0;
  int _requestGeneration = 0;
  int _realtimeRevision = 0;
  int? _activeRequestGeneration;
  int? _activeRequestPage;
  int _subscriptionGeneration = 0;
  final Set<String> _deletedIds = {};
  String? _realtimeError;
  static const _connectionError =
      'Canlı bildirim bağlantısı kesildi. Listeyi yenileyerek tekrar deneyin.';

  static const int _limit = 20;

  void startListening() {
    if (!_ensureSession() || _notificationsSubscription != null) return;
    final generation = ++_subscriptionGeneration;

    try {
      late final StreamSubscription<NotificationEntity> subscription;
      subscription = repository.notificationsStream.listen(
        (event) {
          if (generation == _subscriptionGeneration && _ensureSession()) {
            _handleRealtimeNotification(event);
          }
        },
        onError: (Object _, StackTrace _) {
          if (generation == _subscriptionGeneration && _ensureSession()) {
            _realtimeError = _connectionError;
            final current = state;
            if (current is NotificationsLoaded) {
              emit(current.copyWith(realtimeError: _realtimeError));
            }
          }
        },
        onDone: () {
          if (identical(_notificationsSubscription, subscription)) {
            _notificationsSubscription = null;
            ++_subscriptionGeneration;
          }
        },
      );
      _notificationsSubscription = subscription;
    } catch (_) {
      _notificationsSubscription = null;
    }
  }

  void _handleRealtimeNotification(NotificationEntity notification) {
    if (!_ensureSession() ||
        _deletedIds.contains(notification.id) ||
        (_actor != null && notification.userId != _actor)) {
      return;
    }
    _realtimeError = null;
    if (state case final NotificationsLoaded loaded
        when loaded.realtimeError != null) {
      emit(loaded.copyWith(clearRealtimeError: true));
    }

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

    // Buffer live revisions until the initial snapshot settles. Exposing a
    // partial Loaded state here allows writes whose action flags the pending
    // snapshot would then overwrite, permitting duplicate submissions.
    if (_activeRequestGeneration != null && _activeRequestPage == 0) return;

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
    if (!_ensureSession() || _hasMutationInProgress(state)) return;

    if (_activeRequestGeneration != null) {
      final isInitialPageLoading = _activeRequestPage == 0;
      if (!refresh || isInitialPageLoading) return;
    }

    final previousState = state is NotificationsLoaded
        ? state as NotificationsLoaded
        : null;

    if (refresh) {
      ++_subscriptionGeneration;
      _realtimeError = null;
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

    void readFailed() {
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
      final preserved = latestState is NotificationsLoaded
          ? latestState
          : previousState;
      emit(
        preserved.copyWith(
          isLoadingMore: false,
          loadMoreError: 'Diğer bildirimler yüklenemedi.',
        ),
      );
    }

    try {
      final result = await repository
          .getNotifications(page: requestedPage, limit: _limit)
          .timeout(readTimeout);
      if (!_isCurrentRequest(requestGeneration, requestedPage)) return;

      await result.fold(
        (_) async {
          readFailed();
        },
        (notifications) async {
          // The secondary count must not strand an otherwise available inbox.
          // Keep the existing visible-item fallback on count errors/deadlines.
          int? unreadCount;
          final countRevision = _realtimeRevision;
          try {
            final unreadResult = await repository.getUnreadCount().timeout(
              readTimeout,
            );
            unreadCount = unreadResult.fold((_) => null, (count) => count);
          } catch (_) {}
          if (!_isCurrentRequest(requestGeneration, requestedPage)) return;

          final mergedNotifications = [..._notifications];
          final notificationIndexes = <String, int>{
            for (var index = 0; index < mergedNotifications.length; index++)
              mergedNotifications[index].id: index,
          };

          for (final notification in notifications) {
            if (_deletedIds.contains(notification.id) ||
                (_actor != null && notification.userId != _actor)) {
              continue;
            }
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
          final visibleUnread = _notifications
              .where((item) => !item.isRead)
              .length;
          _unreadCount =
              unreadCount == null || countRevision != _realtimeRevision
              ? visibleUnread
              : (unreadCount < visibleUnread ? visibleUnread : unreadCount);

          emit(
            NotificationsLoaded(
              notifications: _notifications,
              unreadCount: _unreadCount,
              hasReachedMax: notifications.length < _limit,
              realtimeError: _realtimeError,
            ),
          );
          startListening();
        },
      );
    } catch (_) {
      readFailed();
    } finally {
      if (_activeRequestGeneration == requestGeneration &&
          _activeRequestPage == requestedPage) {
        _activeRequestGeneration = null;
        _activeRequestPage = null;
      }
    }
  }

  bool _isCurrentRequest(int generation, int page) {
    return _ensureSession() &&
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
    if (!_ensureSession()) return;
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

    final result = await _write(() => repository.markAsRead(notificationId));
    if (!_ensureSession()) return;

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
    if (!_ensureSession()) return;
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isLoadingMore ||
        currentState.unreadCount == 0 ||
        currentState.hasActionInProgress) {
      return;
    }

    final affected = _notifications.map((n) => n.id).toSet();
    final initialUnread = _unreadCount;
    emit(
      currentState.copyWith(isMarkingAllAsRead: true, clearActionError: true),
    );

    final result = await _write(repository.markAllAsRead);
    if (!_ensureSession()) return;

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
            .map(
              (notification) => affected.contains(notification.id)
                  ? notification.copyWith(isRead: true)
                  : notification,
            )
            .toList();
        _unreadCount = _remainingUnread(initialUnread);

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: _notifications,
              unreadCount: _unreadCount,
              isMarkingAllAsRead: false,
              clearActionError: true,
            ),
          );
        }
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    if (!_ensureSession()) return;
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

    final result = await _write(
      () => repository.deleteNotification(notificationId),
    );
    if (!_ensureSession()) return;

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
        _deletedIds.add(notificationId);
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
    if (!_ensureSession()) return;
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.notifications.isEmpty ||
        currentState.isLoadingMore ||
        currentState.hasActionInProgress) {
      return;
    }

    final affected = _notifications.map((n) => n.id).toSet();
    final initialUnread = _unreadCount;
    emit(currentState.copyWith(isDeletingAll: true, clearActionError: true));

    final result = await _write(repository.deleteAllNotifications);
    if (!_ensureSession()) return;

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
        _deletedIds.addAll(affected);
        _notifications = _notifications
            .where((n) => !affected.contains(n.id))
            .toList();
        _realtimeRevisions.removeWhere((id, _) => affected.contains(id));
        _currentPage = 0;
        _unreadCount = _remainingUnread(initialUnread);

        final latestState = state;
        if (latestState is NotificationsLoaded) {
          emit(
            latestState.copyWith(
              notifications: _notifications,
              unreadCount: _unreadCount,
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

  int _remainingUnread(int initialUnread) {
    final delta = _unreadCount - initialUnread;
    final visible = _notifications.where((n) => !n.isRead).length;
    return delta > visible ? delta : visible;
  }

  Future<Either<String, void>> _write(
    Future<Either<String, void>> Function() action,
  ) async {
    try {
      return await action();
    } catch (_) {
      return const Left(
        'İşlem sonucu doğrulanamadı. Listeyi yenileyip tekrar deneyin.',
      );
    }
  }

  @override
  Future<void> close() async {
    _expired = true;
    ++_subscriptionGeneration;
    _requestGeneration++;
    _activeRequestGeneration = null;
    _activeRequestPage = null;

    final sessions = _sessionSubscription;
    _sessionSubscription = null;
    final subscription = _notificationsSubscription;
    _notificationsSubscription = null;
    // Invalidate synchronously and start all cleanup before awaiting an adapter.
    // A delayed Auth cancellation must not keep the retired state/listener alive.
    await Future.wait([
      if (sessions != null) sessions.cancel(),
      if (subscription != null) subscription.cancel(),
      super.close(),
    ]);
  }
}
