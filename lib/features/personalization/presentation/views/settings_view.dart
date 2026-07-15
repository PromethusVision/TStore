import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/widgets/primary_header_container.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_unread_state.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/app_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_view_header_section.dart';

typedef SettingsCurrentUserIdProvider = String? Function();

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.currentUserIdProvider});

  final SettingsCurrentUserIdProvider? currentUserIdProvider;

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

    return BlocProvider(
      create: (_) => sl<ChatUnreadCubit>()..loadUnreadCount(),
      child: Builder(
        builder: (context) => _buildSettingsContent(
          context,
          isLoggedIn: true,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context, {
    required bool isLoggedIn,
    required String? currentUserId,
  }) {
    void showComingSoon(String title) {
      THelperFunctions.showSnackBar(
        context: context,
        message: '$title bölümü hazırlanıyor.',
      );
    }

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

          await context.read<ChatUnreadCubit>().refreshUnreadCount();
        },
        title: "Mesajlarım",
        subtitle: "Geçmiş konuşmalarını görüntüle",
        leading: Iconsax.direct,
        trailing: isLoggedIn ? const _UnreadBadge() : null,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Alışverişlerim'),
        title: "Alışverişlerim",
        subtitle: "Doğrulanan alışverişlerini görüntüle",
        leading: Icons.receipt_long_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Kuponlarım'),
        title: "Kuponlarım",
        subtitle: "Kullanabileceğin kuponları görüntüle",
        leading: Icons.local_offer_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Son Görüntülediklerim'),
        title: "Son Görüntülediklerim",
        subtitle: "İncelediğin ürünlere yeniden ulaş",
        leading: Icons.history_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Değerlendirmelerim'),
        title: "Değerlendirmelerim",
        subtitle: "Mağazalara verdiğin puanları görüntüle",
        leading: Icons.star_outline,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Bildirimlerim'),
        title: "Bildirimlerim",
        subtitle: "Kampanya ve alışveriş bildirimlerini görüntüle",
        leading: Icons.notifications_none,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Kayıtlı Konumlarım'),
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
        onTap: () => showComingSoon('Yardım ve Destek'),
        title: "Yardım ve Destek",
        subtitle: "Sık sorulan sorular ve destek",
        leading: Icons.help_outline,
      ),
      SettingsMenuTileModel(
        onTap: () => showComingSoon('Gizlilik ve İzinler'),
        title: "Gizlilik ve İzinler",
        subtitle: "Gizlilik tercihlerini ve izinlerini yönet",
        leading: Icons.privacy_tip_outlined,
      ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: SettingsViewHeaderSection(currentUserId: currentUserId),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  AccountSettingsSection(
                    accountSettingsTiles: accountSettingsTiles,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const AppSettingsSection(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
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
