import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';
import 'package:t_store/features/personalization/presentation/views/customer_coupons_view.dart';
import 'package:t_store/features/personalization/presentation/views/customer_saved_locations_view.dart';
import 'package:t_store/features/personalization/presentation/views/help_and_support_view.dart';
import 'package:t_store/features/personalization/presentation/views/privacy_and_permissions_view.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/app_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_menu_tile_list.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_view_header_section.dart';
import 'package:t_store/features/purchases/presentation/views/customer_ratings_view.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';

typedef SettingsCurrentUserIdProvider = String? Function();

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    this.currentUserIdProvider,
    this.locationPermissionLoader,
    this.unreadAutoRefreshInterval = const Duration(seconds: 15),
    this.useInheritedChatUnreadCubit = false,
  });

  final SettingsCurrentUserIdProvider? currentUserIdProvider;
  final CustomerLocationPermissionLoader? locationPermissionLoader;
  final Duration unreadAutoRefreshInterval;
  final bool useInheritedChatUnreadCubit;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? get _currentUserId {
    final currentUserIdProvider = widget.currentUserIdProvider;
    if (currentUserIdProvider != null) return currentUserIdProvider();
    return SupabaseService.instance.currentUser?.id;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = _currentUserId;
      if (!mounted || currentUserId == null) return;

      final authCubit = context.read<AuthCubit>();
      final authState = authCubit.state;
      final hasCurrentProfile =
          authState is AuthAuthenticated && authState.user.id == currentUserId;
      if (!hasCurrentProfile && authState is! AuthLoading) {
        authCubit.checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId;
    final isLoggedIn = currentUserId != null;

    if (!isLoggedIn) {
      return _buildSettingsContent(
        context,
        isLoggedIn: false,
        currentUserId: null,
      );
    }

    final content = Builder(
      builder: (context) => _buildSettingsContent(
        context,
        isLoggedIn: true,
        currentUserId: currentUserId,
      ),
    );
    if (widget.useInheritedChatUnreadCubit) {
      return content;
    }

    return BlocProvider(
      create: (_) => sl<ChatUnreadCubit>()..loadUnreadCount(),
      child: _UnreadCountAutoRefresh(
        interval: widget.unreadAutoRefreshInterval,
        child: content,
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context, {
    required bool isLoggedIn,
    required String? currentUserId,
  }) {
    final List<SettingsMenuTileModel> accountSettingsTiles = [
      SettingsMenuTileModel(
        onTap: () async {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ConversationsView()));
          if (!context.mounted) return;

          await context.read<ChatUnreadCubit>().refreshUnreadCountSilently();
        },
        title: "Mesajlarım",
        subtitle: "Geçmiş konuşmalarını görüntüle",
        leading: Iconsax.direct,
        trailing: isLoggedIn ? const _UnreadBadge() : null,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(context, const PurchasesView());
        },
        title: "Alışverişlerim",
        subtitle: "Doğrulanan alışverişlerini görüntüle",
        leading: Icons.receipt_long_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            const CustomerCouponsView(),
          );
        },
        title: "Kuponlarım",
        subtitle: "Kullanabileceğin kuponları görüntüle",
        leading: Icons.local_offer_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn || currentUserId == null) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            RecentlyViewedProductsView(customerId: currentUserId),
          );
        },
        title: "Son Görüntülediklerim",
        subtitle: "İncelediğin ürünlere yeniden ulaş",
        leading: Icons.history_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            const CustomerRatingsView(),
          );
        },
        title: "Değerlendirmelerim",
        subtitle: "Mağazalara verdiğin puanları görüntüle",
        leading: Icons.star_outline,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            const CustomerNotificationsView(),
          );
        },
        title: "Bildirimlerim",
        subtitle: "Kampanya ve alışveriş bildirimlerini görüntüle",
        leading: Icons.notifications_none,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            const CustomerSavedLocationsView(),
          );
        },
        title: "Kayıtlı Konumlarım",
        subtitle: "Kaydettiğin konumları yönet",
        leading: Icons.location_on_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated &&
              authState.user.id == currentUserId) {
            THelperFunctions.navigateToScreen(
              context,
              ProfileView(user: authState.user),
            );
            return;
          }

          context.read<AuthCubit>().checkAuthStatus();
          THelperFunctions.showSnackBar(
            context: context,
            message: 'Hesap bilgilerin yükleniyor. Lütfen tekrar dene.',
          );
        },
        title: "Hesap Bilgilerim",
        subtitle: "Kişisel bilgilerini görüntüle ve düzenle",
        leading: Icons.person_outline,
      ),
      SettingsMenuTileModel(
        onTap: () {
          THelperFunctions.navigateToScreen(
            context,
            HelpAndSupportView(
              onOpenPurchases: () {
                if (!isLoggedIn) {
                  THelperFunctions.navigateToScreen(context, const LoginView());
                  return;
                }

                THelperFunctions.navigateToScreen(
                  context,
                  const PurchasesView(),
                );
              },
              onOpenMessages: () async {
                if (!isLoggedIn) {
                  THelperFunctions.navigateToScreen(context, const LoginView());
                  return;
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConversationsView()),
                );
                if (!context.mounted) return;

                await context
                    .read<ChatUnreadCubit>()
                    .refreshUnreadCountSilently();
              },
              onOpenSavedLocations: () {
                if (!isLoggedIn) {
                  THelperFunctions.navigateToScreen(context, const LoginView());
                  return;
                }

                THelperFunctions.navigateToScreen(
                  context,
                  const CustomerSavedLocationsView(),
                );
              },
            ),
          );
        },
        title: "Yardım ve Destek",
        subtitle: "Sık sorulan sorular ve destek",
        leading: Icons.help_outline,
      ),
      SettingsMenuTileModel(
        onTap: () {
          THelperFunctions.navigateToScreen(
            context,
            PrivacyAndPermissionsView(
              locationPermissionLoader: widget.locationPermissionLoader,
            ),
          );
        },
        title: "Gizlilik ve İzinler",
        subtitle: "Gizlilik tercihlerini ve izinlerini yönet",
        leading: Icons.privacy_tip_outlined,
      ),
    ];
    return ColoredBox(
      color: CustomerHomeV1Tokens.cream,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-profile-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-profile-scroll'),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space24,
              ),
              child: Column(
                children: [
                  SettingsViewHeaderSection(currentUserId: currentUserId),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  _CustomerProfileMenuSection(
                    key: const Key('customer-profile-activity-section'),
                    title: 'Alışveriş ve iletişim',
                    subtitle:
                        'Siparişlerini, mesajlarını ve fırsatlarını yönet',
                    tiles: accountSettingsTiles.take(6).toList(),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  _CustomerProfileMenuSection(
                    key: const Key('customer-profile-account-section'),
                    title: 'Hesap ve destek',
                    subtitle:
                        'Bilgilerini, konumlarını ve tercihlerini düzenle',
                    tiles: accountSettingsTiles.skip(6).toList(),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  const AppSettingsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerProfileMenuSection extends StatelessWidget {
  const _CustomerProfileMenuSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tiles,
  });

  final String title;
  final String subtitle;
  final List<SettingsMenuTileModel> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CustomerHomeV1Tokens.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space12),
        SettingsMenuTileList(settingsMenuTiles: tiles),
      ],
    );
  }
}

class _UnreadCountAutoRefresh extends StatefulWidget {
  const _UnreadCountAutoRefresh({required this.interval, required this.child});

  final Duration interval;
  final Widget child;

  @override
  State<_UnreadCountAutoRefresh> createState() =>
      _UnreadCountAutoRefreshState();
}

class _UnreadCountAutoRefreshState extends State<_UnreadCountAutoRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAndRestart());
      return;
    }

    _stopTimer();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      unawaited(_refreshIfVisible());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _refreshAndRestart() async {
    _stopTimer();
    await _refreshIfVisible();
    if (!mounted) return;

    _startTimer();
  }

  Future<void> _refreshIfVisible() async {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return;

    await context.read<ChatUnreadCubit>().refreshUnreadCountSilently();
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
      builder: (context, state) {
        if (state is! ChatUnreadLoaded || state.count <= 0) {
          return const Icon(Icons.chevron_right);
        }

        final label = state.count > 99 ? '99+' : state.count.toString();

        return UnconstrainedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 24,
                constraints: const BoxConstraints(minWidth: 24),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: CustomerHomeV1Tokens.coral,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      },
    );
  }
}
