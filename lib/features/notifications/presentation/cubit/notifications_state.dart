import 'package:equatable/equatable.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? loadMoreError;
  final Set<String> markingAsReadIds;
  final bool isMarkingAllAsRead;
  final Set<String> deletingIds;
  final bool isDeletingAll;
  final String? actionError;
  final String? realtimeError;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.markingAsReadIds = const {},
    this.isMarkingAllAsRead = false,
    this.deletingIds = const {},
    this.isDeletingAll = false,
    this.actionError,
    this.realtimeError,
  });

  bool get hasActionInProgress =>
      markingAsReadIds.isNotEmpty ||
      isMarkingAllAsRead ||
      deletingIds.isNotEmpty ||
      isDeletingAll;

  @override
  List<Object?> get props => [
    notifications,
    unreadCount,
    hasReachedMax,
    isLoadingMore,
    loadMoreError,
    markingAsReadIds,
    isMarkingAllAsRead,
    deletingIds,
    isDeletingAll,
    actionError,
    realtimeError,
  ];

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
    Set<String>? markingAsReadIds,
    bool? isMarkingAllAsRead,
    Set<String>? deletingIds,
    bool? isDeletingAll,
    String? actionError,
    bool clearActionError = false,
    String? realtimeError,
    bool clearRealtimeError = false,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
      markingAsReadIds: markingAsReadIds ?? this.markingAsReadIds,
      isMarkingAllAsRead: isMarkingAllAsRead ?? this.isMarkingAllAsRead,
      deletingIds: deletingIds ?? this.deletingIds,
      isDeletingAll: isDeletingAll ?? this.isDeletingAll,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      realtimeError: clearRealtimeError
          ? null
          : realtimeError ?? this.realtimeError,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

class NewNotificationReceived extends NotificationsState {
  final NotificationEntity notification;

  const NewNotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
