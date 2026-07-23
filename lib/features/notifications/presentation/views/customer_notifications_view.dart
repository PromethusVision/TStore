import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

typedef CustomerNotificationDestinationBuilder =
    Widget? Function(NotificationEntity notification);

class CustomerNotificationsView extends StatelessWidget {
  const CustomerNotificationsView({
    super.key,
    this.notificationsCubit,
    this.notificationDestinationBuilder,
  });

  final NotificationsCubit? notificationsCubit;
  final CustomerNotificationDestinationBuilder? notificationDestinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (notificationsCubit ?? sl<NotificationsCubit>())
            ..getNotifications(refresh: true),
      child: _CustomerNotificationsContent(
        notificationDestinationBuilder: notificationDestinationBuilder,
      ),
    );
  }
}

class _CustomerNotificationsContent extends StatefulWidget {
  const _CustomerNotificationsContent({
    required this.notificationDestinationBuilder,
  });

  final CustomerNotificationDestinationBuilder? notificationDestinationBuilder;

  @override
  State<_CustomerNotificationsContent> createState() =>
      _CustomerNotificationsContentState();
}

class _CustomerNotificationsContentState
    extends State<_CustomerNotificationsContent> {
  late final ScrollController _scrollController;
  final Set<String> _openingNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMoreIfNeeded);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreIfNeeded)
      ..dispose();
    super.dispose();
  }

  void _loadMoreIfNeeded() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 300) {
      return;
    }

    final cubit = context.read<NotificationsCubit>();
    final state = cubit.state;
    if (state is NotificationsLoaded &&
        !state.hasReachedMax &&
        !state.isLoadingMore) {
      cubit.loadMoreNotifications();
    }
  }

  bool _canOpenDestination(NotificationEntity notification) {
    final destinationBuilder = widget.notificationDestinationBuilder;
    if (destinationBuilder != null) {
      return destinationBuilder(notification) != null;
    }

    return notification.type == NotificationType.order ||
        notification.type == NotificationType.chat;
  }

  Widget? _buildDestination(NotificationEntity notification) {
    final destinationBuilder = widget.notificationDestinationBuilder;
    if (destinationBuilder != null) {
      return destinationBuilder(notification);
    }

    return switch (notification.type) {
      NotificationType.order => const PurchasesView(),
      NotificationType.chat => const ConversationsView(),
      NotificationType.promotion || NotificationType.system => null,
    };
  }

  String? _interactionHint(
    NotificationEntity notification,
    bool canOpenDestination,
  ) {
    if (canOpenDestination && !notification.isRead) {
      return 'Okundu yapıp ilgili ekranı açmak için dokun';
    }
    if (canOpenDestination) {
      return 'İlgili ekranı açmak için dokun';
    }
    if (!notification.isRead) {
      return 'Okundu olarak işaretlemek için dokun';
    }
    return null;
  }

  Future<void> _handleNotificationTap(NotificationEntity notification) async {
    if (_openingNotificationIds.contains(notification.id)) return;

    final destination = _buildDestination(notification);
    if (notification.isRead && destination == null) return;

    setState(() => _openingNotificationIds.add(notification.id));

    final cubit = context.read<NotificationsCubit>();
    final markAsReadFuture = notification.isRead
        ? Future<void>.value()
        : cubit.markAsRead(notification.id);

    try {
      if (destination == null) {
        await markAsReadFuture;
        return;
      }

      unawaited(markAsReadFuture);
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          settings: RouteSettings(
            name: 'customer-notification-${notification.type.name}',
          ),
          builder: (_) => destination,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingNotificationIds.remove(notification.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) {
        if (current is! NotificationsLoaded || current.actionError == null) {
          return false;
        }
        return previous is! NotificationsLoaded ||
            previous.actionError != current.actionError;
      },
      listener: (context, state) {
        final message = (state as NotificationsLoaded).actionError;
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bildirimlerim'),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is! NotificationsLoaded || state.unreadCount == 0) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(right: TSizes.sm),
                  child: TextButton.icon(
                    key: const Key('mark-all-notifications-read-button'),
                    onPressed:
                        state.isMarkingAllAsRead ||
                            state.markingAsReadIds.isNotEmpty
                        ? null
                        : () => context
                              .read<NotificationsCubit>()
                              .markAllAsRead(),
                    icon: state.isMarkingAllAsRead
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.done_all_rounded),
                    label: const Text('Tümünü oku'),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsInitial ||
                state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationsError) {
              return _NotificationStatus(
                icon: Icons.notifications_off_outlined,
                title: 'Bildirimlerin yüklenemedi',
                description: state.message,
                actionLabel: 'Tekrar Dene',
                onAction: () => context
                    .read<NotificationsCubit>()
                    .getNotifications(refresh: true),
              );
            }

            if (state is! NotificationsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.notifications.isEmpty) {
              return _NotificationStatus(
                icon: Icons.notifications_none,
                title: 'Henüz bildirimin yok',
                description:
                    'Alışveriş, mesaj ve kampanya bildirimlerin burada görünecek.',
                actionLabel: 'Yenile',
                onAction: () => context
                    .read<NotificationsCubit>()
                    .getNotifications(refresh: true),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<NotificationsCubit>()
                  .getNotifications(refresh: true),
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                itemCount: state.notifications.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: TSizes.spaceBtwItems),
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return _NotificationsListFooter(state: state);
                  }

                  final notification = state.notifications[index];
                  final canOpenDestination = _canOpenDestination(notification);
                  final isProcessing =
                      state.isMarkingAllAsRead ||
                      state.markingAsReadIds.contains(notification.id) ||
                      _openingNotificationIds.contains(notification.id);
                  final canTap =
                      !isProcessing &&
                      (!notification.isRead || canOpenDestination);

                  return _NotificationCard(
                    notification: notification,
                    isProcessing: isProcessing,
                    interactionHint: _interactionHint(
                      notification,
                      canOpenDestination,
                    ),
                    onTap: canTap
                        ? () => _handleNotificationTap(notification)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isProcessing,
    required this.interactionHint,
    required this.onTap,
  });

  final NotificationEntity notification;
  final bool isProcessing;
  final String? interactionHint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typePresentation = _NotificationTypePresentation.from(
      notification.type,
    );
    final createdAt = notification.createdAt;

    return Semantics(
      button: interactionHint != null,
      enabled: onTap != null,
      label:
          '${notification.isRead ? 'Okunmuş' : 'Yeni'} bildirim: ${notification.title}',
      hint: interactionHint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('notification-card-${notification.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          child: Ink(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? colorScheme.surface
                  : colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              border: Border.all(
                color: notification.isRead
                    ? colorScheme.outlineVariant
                    : colorScheme.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    typePresentation.icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (isProcessing) ...[
                            const SizedBox(width: TSizes.sm),
                            const SizedBox.square(
                              key: Key('notification-read-progress'),
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ] else if (!notification.isRead) ...[
                            const SizedBox(width: TSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.sm,
                                vertical: TSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Yeni',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: TSizes.sm),
                      Wrap(
                        spacing: TSizes.sm,
                        runSpacing: TSizes.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            typePresentation.label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (createdAt != null)
                            Text(
                              _formatDate(createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year} '
        '• ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _NotificationsListFooter extends StatelessWidget {
  const _NotificationsListFooter({required this.state});

  final NotificationsLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: TSizes.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadMoreError != null) {
      return Column(
        children: [
          Text(
            state.loadMoreError!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: () =>
                context.read<NotificationsCubit>().loadMoreNotifications(),
            child: const Text('Tekrar Dene'),
          ),
        ],
      );
    }

    return const SizedBox(height: TSizes.sm);
  }
}

class _NotificationStatus extends StatelessWidget {
  const _NotificationStatus({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTypePresentation {
  const _NotificationTypePresentation({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  factory _NotificationTypePresentation.from(NotificationType type) {
    return switch (type) {
      NotificationType.order => const _NotificationTypePresentation(
        icon: Icons.receipt_long_outlined,
        label: 'Alışveriş',
      ),
      NotificationType.promotion => const _NotificationTypePresentation(
        icon: Icons.local_offer_outlined,
        label: 'Kampanya',
      ),
      NotificationType.chat => const _NotificationTypePresentation(
        icon: Icons.chat_bubble_outline,
        label: 'Mesaj',
      ),
      NotificationType.system => const _NotificationTypePresentation(
        icon: Icons.info_outline,
        label: 'Bilgilendirme',
      ),
    };
  }
}
