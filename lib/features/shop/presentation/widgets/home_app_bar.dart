import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, this.sessionFullName, this.notificationsCubit});

  final String? sessionFullName;
  final NotificationsCubit? notificationsCubit;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  String currentSessionFullName() {
    if (sessionFullName != null) return sessionFullName!.trim();

    try {
      final fullName =
          SupabaseService.instance.currentUser?.userMetadata?['full_name'];
      return fullName is String ? fullName.trim() : '';
    } catch (_) {
      return '';
    }
  }
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool _isOpeningNotifications = false;

  String _customerDisplayName(AuthState state) {
    if (state is AuthAuthenticated) {
      final authenticatedFullName = state.user.fullName?.trim() ?? '';
      if (authenticatedFullName.isNotEmpty) return authenticatedFullName;
    }

    final currentSessionFullName = widget.currentSessionFullName();
    return currentSessionFullName.isEmpty
        ? TTexts.homeAppbarSubTitle
        : currentSessionFullName;
  }

  Future<void> _openNotifications({required bool isAuthenticated}) async {
    if (_isOpeningNotifications) return;
    _isOpeningNotifications = true;

    try {
      if (!isAuthenticated) {
        final signedIn = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) =>
                const LoginView(returnToCallerAfterCustomerLogin: true),
          ),
        );
        if (!mounted || signedIn != true) return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const CustomerNotificationsView(),
        ),
      );
    } finally {
      _isOpeningNotifications = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;
        return SizedBox(
          key: const Key('customer-home-header'),
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label:
                      'Esnafta Var müşteri ana sayfası, ${_customerDisplayName(state)}',
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomerBrandWordmark(
                        key: Key('home-wordmark'),
                        fontSize: 24,
                      ),
                      SizedBox(height: CustomerHomeV1Tokens.space4),
                      Text(
                        'Kargo Bekleme, Esnafta Var!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      unawaited(_openNotifications(isAuthenticated: isAuthenticated));
    }

    if (!isAuthenticated) {
      return _NotificationIconButton(
        unreadCount: 0,
        onPressed: openNotifications,
      );
    }

    final providedCubit = widget.notificationsCubit;
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
    final button = Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('home-notifications-button'),
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: const Icon(
            Iconsax.notification,
            color: CustomerHomeV1Tokens.petrol,
            size: 21,
          ),
        ),
      ),
    );

    if (unreadCount <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          key: const Key('home-notifications-badge'),
          right: -2,
          top: -3,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.coral,
              shape: BoxShape.circle,
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
