import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.sessionFullName, this.notificationsCubit});

  final String? sessionFullName;
  final NotificationsCubit? notificationsCubit;

  String _currentSessionFullName() {
    if (sessionFullName != null) return sessionFullName!.trim();

    try {
      final fullName =
          SupabaseService.instance.currentUser?.userMetadata?['full_name'];
      return fullName is String ? fullName.trim() : '';
    } catch (_) {
      return '';
    }
  }

  String _customerDisplayName(AuthState state) {
    if (state is AuthAuthenticated) {
      final authenticatedFullName = state.user.fullName?.trim() ?? '';
      if (authenticatedFullName.isNotEmpty) return authenticatedFullName;
    }

    final currentSessionFullName = _currentSessionFullName();
    return currentSessionFullName.isEmpty
        ? TTexts.homeAppbarSubTitle
        : currentSessionFullName;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;
        return CustomAppBar(
          appBarModel: AppBarModel(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TTexts.homeAppbarTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.apply(color: TColors.grey),
                ),
                Text(
                  _customerDisplayName(state),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.apply(color: TColors.white),
                ),
              ],
            ),
            actions: [
              _buildNotificationAction(
                context,
                isAuthenticated: isAuthenticated,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationAction(
    BuildContext context, {
    required bool isAuthenticated,
  }) {
    void openNotifications() {
      if (!isAuthenticated) {
        THelperFunctions.navigateToScreen(context, const LoginView());
        return;
      }
      THelperFunctions.navigateToScreen(
        context,
        const CustomerNotificationsView(),
      );
    }

    if (!isAuthenticated) {
      return _NotificationIconButton(
        unreadCount: 0,
        onPressed: openNotifications,
      );
    }

    final providedCubit = notificationsCubit;
    if (providedCubit != null) {
      return BlocProvider<NotificationsCubit>.value(
        value: providedCubit,
        child: _NotificationAction(onPressed: openNotifications),
      );
    }

    if (!sl.isRegistered<NotificationsCubit>()) {
      return _NotificationIconButton(
        unreadCount: 0,
        onPressed: openNotifications,
      );
    }

    return BlocProvider<NotificationsCubit>(
      create: (_) => sl<NotificationsCubit>()..getNotifications(refresh: true),
      child: _NotificationAction(onPressed: openNotifications),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded
            ? state.unreadCount
            : 0;
        return _NotificationIconButton(
          unreadCount: unreadCount,
          onPressed: onPressed,
        );
      },
    );
  }
}

class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      key: const Key('home-notifications-button'),
      tooltip: 'Bildirimler',
      onPressed: onPressed,
      icon: const Icon(Iconsax.notification, color: TColors.white),
    );

    if (unreadCount <= 0) return icon;

    return Badge(
      key: const Key('home-notifications-badge'),
      label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
      child: icon,
    );
  }
}
