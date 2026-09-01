import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({
    super.key,
    this.sessionFullName,
    this.notificationsCubit,
    this.visualPrototype = false,
  });

  final String? sessionFullName;
  final NotificationsCubit? notificationsCubit;
  final bool visualPrototype;

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
        final displayName = _customerDisplayName(state);
        final hasKnownIdentity =
            isAuthenticated || displayName != TTexts.homeAppbarSubTitle;
        final greeting = hasKnownIdentity
            ? 'Merhaba, ${_firstName(displayName)}'
            : 'Mahallendeki esnafı keşfet';
        if (widget.visualPrototype) {
          return ConstrainedBox(
            key: const Key('customer-home-header'),
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Esnafta Var müşteri ana sayfası, $displayName',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomerBrandWordmark(
                          key: Key('home-wordmark'),
                          fontSize: 26,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        Row(
                          children: [
                            Text(
                              greeting,
                              key: const Key('home-greeting'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: EsnaftaVarColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: EsnaftaVarSpacing.xs),
                            Expanded(
                              child: Text(
                                hasKnownIdentity
                                    ? 'Mahallende bugün neler var?'
                                    : 'Yakınındaki ürünleri ve esnafı bul',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: EsnaftaVarColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: EsnaftaVarSpacing.sm),
                _buildNotificationAction(
                  context,
                  isAuthenticated: isAuthenticated,
                ),
              ],
            ),
          );
        }
        return ConstrainedBox(
          key: const Key('customer-home-header'),
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Esnafta Var müşteri ana sayfası, $displayName',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomerBrandWordmark(
                        key: Key('home-wordmark'),
                        fontSize: 24,
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space4),
                      Text(
                        greeting,
                        key: const Key('home-greeting'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: EsnaftaVarColors.textSecondary,
                          fontSize: 12,
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

  String _firstName(String displayName) {
    final normalized = displayName.trim();
    if (normalized.isEmpty || normalized == TTexts.homeAppbarSubTitle) {
      return 'komşum';
    }
    return normalized.split(RegExp(r'\s+')).first;
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
    return EsnaftaVarSurfaceIconButton(
      buttonKey: const Key('home-notifications-button'),
      icon: Iconsax.notification,
      tooltip: 'Bildirimler',
      onPressed: onPressed,
      badgeCount: unreadCount,
      badgeKey: const Key('home-notifications-badge'),
    );
  }
}
