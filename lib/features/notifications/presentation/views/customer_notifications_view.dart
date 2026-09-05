import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/common/widgets/progress_indicator.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

typedef CustomerNotificationDestinationBuilder =
    Widget? Function(NotificationEntity notification);

Widget? buildCustomerNotificationDestination(NotificationEntity notification) {
  return switch (notification.type) {
    NotificationType.order => PurchasesView(
      initialPurchaseId: notification.actionType == 'order_detail'
          ? notification.actionId
          : null,
    ),
    NotificationType.chat =>
      notification.actionType == 'chat_detail' && notification.actionId != null
          ? ChatView(
              receiverId: notification.actionId!,
              receiverName: notification.actionName ?? notification.title,
            )
          : const ConversationsView(),
    NotificationType.promotion || NotificationType.system => null,
  };
}

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

    return buildCustomerNotificationDestination(notification);
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
      child: EsnaftaVarScaffold(
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              key: const Key('customer-notifications-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xs,
                      EsnaftaVarSpacing.md,
                      0,
                    ),
                    child: _NotificationsHeader(),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  Expanded(
                    child: BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, state) {
                        if (state is NotificationsInitial ||
                            state is NotificationsLoading) {
                          return const _NotificationsLoadingState();
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
                          return const _NotificationsLoadingState();
                        }

                        if (state.notifications.isEmpty) {
                          return _NotificationStatus(
                            icon: Icons.notifications_none_rounded,
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
                          color: EsnaftaVarColors.primary,
                          onRefresh: () => context
                              .read<NotificationsCubit>()
                              .getNotifications(refresh: true),
                          child: ListView.separated(
                            key: const Key('customer-notifications-list'),
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              EsnaftaVarSpacing.md,
                              EsnaftaVarSpacing.xxs,
                              EsnaftaVarSpacing.md,
                              EsnaftaVarSpacing.xl,
                            ),
                            itemCount: state.notifications.length + 1,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: EsnaftaVarSpacing.sm),
                            itemBuilder: (context, index) {
                              if (index == state.notifications.length) {
                                return _NotificationsListFooter(state: state);
                              }

                              final notification = state.notifications[index];
                              final canOpenDestination = _canOpenDestination(
                                notification,
                              );
                              final isProcessing =
                                  state.isMarkingAllAsRead ||
                                  state.isDeletingAll ||
                                  state.markingAsReadIds.contains(
                                    notification.id,
                                  ) ||
                                  state.deletingIds.contains(notification.id) ||
                                  _openingNotificationIds.contains(
                                    notification.id,
                                  );
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final loadedState = state is NotificationsLoaded ? state : null;
        final unreadCount = loadedState?.unreadCount ?? 0;
        return Column(
          key: const Key('customer-notifications-header'),
          children: [
            Row(
              children: [
                MergeSemantics(
                  child: EsnaftaVarSurfaceIconButton(
                    buttonKey: const Key('customer-notifications-back-button'),
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Geri',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EsnaftaVarSectionHeader(
                    title: 'Bildirimlerim',
                    subtitle: unreadCount > 0
                        ? '$unreadCount okunmamış bildirim'
                        : 'Alışveriş ve mesaj gelişmelerini takip et',
                  ),
                ),
              ],
            ),
            if (unreadCount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const Key('mark-all-notifications-read-button'),
                  onPressed:
                      loadedState!.isMarkingAllAsRead ||
                          loadedState.markingAsReadIds.isNotEmpty ||
                          loadedState.deletingIds.isNotEmpty ||
                          loadedState.isDeletingAll
                      ? null
                      : () =>
                            context.read<NotificationsCubit>().markAllAsRead(),
                  icon: loadedState.isMarkingAllAsRead
                      ? const TLoadingIndicator(
                          size: 18,
                          label: 'Bildirimler okundu olarak işaretleniyor',
                        )
                      : const Icon(Icons.done_all_rounded),
                  label: const Text('Tümünü oku'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationsLoadingState extends StatelessWidget {
  const _NotificationsLoadingState();
  @override
  Widget build(BuildContext context) => const Center(
    key: Key('customer-notifications-loading-state'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TLoadingIndicator(label: 'Bildirimler yükleniyor'),
        SizedBox(height: 16),
        Text('Bildirimlerin yükleniyor'),
      ],
    ),
  );
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
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
          child: Ink(
            padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
            decoration: BoxDecoration(
              color: EsnaftaVarColors.surface,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
              border: Border.all(
                color: notification.isRead
                    ? EsnaftaVarColors.borderDefault
                    : EsnaftaVarColors.primary.withValues(alpha: 0.3),
              ),
              boxShadow: EsnaftaVarElevation.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typePresentation.background,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    typePresentation.icon,
                    color: typePresentation.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: EsnaftaVarSpacing.sm),
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
                              style: const TextStyle(
                                color: EsnaftaVarColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (isProcessing) ...[
                            const SizedBox(width: EsnaftaVarSpacing.xs),
                            const SizedBox.square(
                              key: Key('notification-read-progress'),
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: EsnaftaVarColors.primary,
                              ),
                            ),
                          ] else if (!notification.isRead) ...[
                            const SizedBox(width: EsnaftaVarSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: EsnaftaVarSpacing.xs,
                                vertical: EsnaftaVarSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: EsnaftaVarColors.accent,
                                borderRadius: BorderRadius.circular(
                                  EsnaftaVarRadii.pill,
                                ),
                              ),
                              child: const Text(
                                'Yeni',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.xs),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: EsnaftaVarColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.sm),
                      Wrap(
                        spacing: EsnaftaVarSpacing.xs,
                        runSpacing: EsnaftaVarSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: EsnaftaVarSpacing.xs,
                              vertical: EsnaftaVarSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: typePresentation.background,
                              borderRadius: BorderRadius.circular(
                                EsnaftaVarRadii.pill,
                              ),
                            ),
                            child: Text(
                              typePresentation.label,
                              style: TextStyle(
                                color: typePresentation.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              _formatDate(createdAt),
                              style: const TextStyle(
                                color: EsnaftaVarColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
        padding: EdgeInsets.symmetric(vertical: EsnaftaVarSpacing.md),
        child: Center(
          child: CircularProgressIndicator(color: EsnaftaVarColors.primary),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Container(
        padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
        ),
        child: Column(
          children: [
            Text(
              state.loadMoreError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: EsnaftaVarColors.textSecondary,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.read<NotificationsCubit>().loadMoreNotifications(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return const SizedBox(height: EsnaftaVarSpacing.xs);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: EsnaftaVarStateCard(
        key: const Key('customer-notifications-status'),
        icon: icon,
        title: title,
        message: description,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

class _NotificationTypePresentation {
  const _NotificationTypePresentation({
    required this.icon,
    required this.label,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color background;

  factory _NotificationTypePresentation.from(NotificationType type) {
    return switch (type) {
      NotificationType.order => const _NotificationTypePresentation(
        icon: Icons.receipt_long_outlined,
        label: 'Alışveriş',
        accent: EsnaftaVarColors.primary,
        background: EsnaftaVarColors.primarySoft,
      ),
      NotificationType.promotion => const _NotificationTypePresentation(
        icon: Icons.local_offer_outlined,
        label: 'Kampanya',
        accent: EsnaftaVarColors.accent,
        background: EsnaftaVarColors.accentSoft,
      ),
      NotificationType.chat => const _NotificationTypePresentation(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Mesaj',
        accent: EsnaftaVarColors.primary,
        background: EsnaftaVarColors.primarySoft,
      ),
      NotificationType.system => const _NotificationTypePresentation(
        icon: Icons.info_outline_rounded,
        label: 'Bilgilendirme',
        accent: EsnaftaVarColors.warning,
        background: EsnaftaVarColors.surfaceAlt,
      ),
    };
  }
}
