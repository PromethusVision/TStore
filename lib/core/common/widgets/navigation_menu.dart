import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_bottom_navigation.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';

typedef NavigationCurrentUserIdProvider = String? Function();

String? _navigationCurrentUserId() {
  return SupabaseService.instance.currentUser?.id;
}

// lib/features/home/presentation/views/navigation_menu.dart
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({
    super.key,
    this.chatUnreadCubit,
    this.unreadAutoRefreshInterval = const Duration(seconds: 15),
    this.currentUserIdProvider = _navigationCurrentUserId,
  });

  final ChatUnreadCubit? chatUnreadCubit;
  final Duration unreadAutoRefreshInterval;
  final NavigationCurrentUserIdProvider currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    final body = _NavigationMenuBody(
      unreadAutoRefreshInterval: unreadAutoRefreshInterval,
      currentUserIdProvider: currentUserIdProvider,
    );
    final providedCubit = chatUnreadCubit;
    if (providedCubit != null) {
      return BlocProvider<ChatUnreadCubit>.value(
        value: providedCubit,
        child: body,
      );
    }

    return BlocProvider(
      create: (_) => sl<ChatUnreadCubit>()..loadUnreadCount(),
      child: body,
    );
  }
}

class _NavigationMenuBody extends StatefulWidget {
  const _NavigationMenuBody({
    required this.unreadAutoRefreshInterval,
    required this.currentUserIdProvider,
  });

  final Duration unreadAutoRefreshInterval;
  final NavigationCurrentUserIdProvider currentUserIdProvider;

  @override
  State<_NavigationMenuBody> createState() => _NavigationMenuBodyState();
}

class _NavigationMenuBodyState extends State<_NavigationMenuBody>
    with WidgetsBindingObserver {
  Timer? _unreadRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startUnreadRefresh();
  }

  @override
  void dispose() {
    _stopUnreadRefresh();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAndRestart());
      return;
    }

    _stopUnreadRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
      builder: (context, unreadState) {
        final isLoggedIn = widget.currentUserIdProvider() != null;
        final unreadMessageCount = isLoggedIn && unreadState is ChatUnreadLoaded
            ? unreadState.count
            : 0;

        return BlocBuilder<NavigationMenuCubit, NavigationMenuState>(
          builder: (context, state) {
            final selectedIndex = context
                .read<NavigationMenuCubit>()
                .selectedIndex;
            return Scaffold(
              bottomNavigationBar: CustomerBottomNavigation(
                selectedIndex: selectedIndex,
                unreadMessageCount: unreadMessageCount,
                onSelected: (index) =>
                    unawaited(_handleDestinationSelected(index)),
              ),
              body: context.read<NavigationMenuCubit>().getScreen(),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDestinationSelected(int index) async {
    if (index >= 2 && widget.currentUserIdProvider() == null) {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) =>
              const LoginView(returnToCallerAfterCustomerLogin: true),
        ),
      );
      if (!mounted ||
          signedIn != true ||
          widget.currentUserIdProvider() == null) {
        return;
      }
    }

    if (index == 4) {
      unawaited(context.read<ChatUnreadCubit>().refreshUnreadCountSilently());
    }
    context.read<NavigationMenuCubit>().changeIndex(index);
  }

  void _startUnreadRefresh() {
    _unreadRefreshTimer?.cancel();
    _unreadRefreshTimer = Timer.periodic(
      widget.unreadAutoRefreshInterval,
      (_) => unawaited(_refreshUnreadIfVisible()),
    );
  }

  void _stopUnreadRefresh() {
    _unreadRefreshTimer?.cancel();
    _unreadRefreshTimer = null;
  }

  Future<void> _refreshAndRestart() async {
    _stopUnreadRefresh();
    await _refreshUnreadIfVisible();
    if (!mounted) return;

    _startUnreadRefresh();
  }

  Future<void> _refreshUnreadIfVisible() async {
    if (!mounted) return;

    final unreadCubit = context.read<ChatUnreadCubit>();
    if (widget.currentUserIdProvider() == null) {
      unreadCubit.resetUnreadCount();
      return;
    }
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

    await unreadCubit.refreshUnreadCountSilently();
  }
}
