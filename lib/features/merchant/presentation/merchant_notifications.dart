import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

/// Merchant presentation over the shared repository, Realtime and state machine.
class MerchantNotifications extends StatefulWidget {
  const MerchantNotifications({
    super.key,
    required this.repository,
    required this.identity,
    required this.currentUserId,
  });
  final NotificationRepository repository;
  final PushIdentity identity;
  final String? Function() currentUserId;
  @override
  State<MerchantNotifications> createState() => _MerchantNotificationsState();
}

class _MerchantNotificationsState extends State<MerchantNotifications> {
  late final NotificationsCubit _cubit;
  bool get _current => widget.currentUserId() == widget.identity.userId;
  @override
  void initState() {
    super.initState();
    _cubit = NotificationsCubit(repository: widget.repository)
      ..getNotifications();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<NotificationsCubit, NotificationsState>(
    bloc: _cubit,
    buildWhen: (_, next) => next is! NewNotificationReceived,
    builder: (context, state) {
      final loaded = state is NotificationsLoaded ? state : null;
      final items =
          loaded?.notifications
              .where(
                (n) =>
                    n.userId == widget.identity.userId &&
                    (n.data?['app_role'] == null ||
                        n.data?['app_role'] ==
                            NotificationAppRole.merchant.name),
              )
              .toList() ??
          [];
      return MerchantPage(
        title: 'Bildirimler',
        onRefresh: () async {
          if (_current) await _cubit.getNotifications(refresh: true);
        },
        children: [
          if (state is NotificationsLoading || state is NotificationsInitial)
            const Center(child: CircularProgressIndicator()),
          if (state is NotificationsError)
            MerchantNotice(
              state.message,
              error: true,
              onRetry: () {
                if (_current) _cubit.getNotifications(refresh: true);
              },
            ),
          if (loaded?.actionError != null)
            MerchantNotice(loaded!.actionError!, error: true),
          if (loaded != null && items.isEmpty)
            const MerchantNotice('Henüz bildirimin yok.'),
          for (final item in items)
            Card(
              child: ListTile(
                leading: Icon(
                  item.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active_outlined,
                ),
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: item.isRead
                    ? null
                    : const Icon(Icons.circle, size: 10),
                onTap: item.isRead || loaded!.markingAsReadIds.contains(item.id)
                    ? null
                    : () {
                        if (_current) _cubit.markAsRead(item.id);
                      },
              ),
            ),
          if (loaded?.loadMoreError != null)
            MerchantNotice(loaded!.loadMoreError!, error: true),
          if (loaded != null && !loaded.hasReachedMax)
            OutlinedButton(
              onPressed: loaded.isLoadingMore
                  ? null
                  : () {
                      if (_current) _cubit.getNotifications();
                    },
              child: Text(
                loaded.isLoadingMore ? 'Yükleniyor…' : 'Daha fazla bildirim',
              ),
            ),
        ],
      );
    },
  );
}
