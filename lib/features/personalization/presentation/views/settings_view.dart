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
import 'package:t_store/features/personalization/presentation/views/user_addresses_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/app_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_view_header_section.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';
import 'package:t_store/features/shop/presentation/views/my_shop_view.dart';
import 'package:t_store/features/shop/presentation/views/orders_view.dart';

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
    final authState = context.watch<AuthCubit>().state;
    final canManageShop =
        authState is AuthAuthenticated &&
        authState.user.id == currentUserId &&
        authState.user.canManageShop;

    if (!isLoggedIn) {
      return _buildSettingsContent(
        context,
        isLoggedIn: false,
        canManageShop: false,
        currentUserId: null,
      );
    }

    return BlocProvider(
      create: (_) => sl<ChatUnreadCubit>()..loadUnreadCount(),
      child: Builder(
        builder: (context) => _buildSettingsContent(
          context,
          isLoggedIn: true,
          canManageShop: canManageShop,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context, {
    required bool isLoggedIn,
    required bool canManageShop,
    required String? currentUserId,
  }) {
    final List<SettingsMenuTileModel> appSettingsTiles = [
      SettingsMenuTileModel(
        onTap: () {},
        title: "Veri Yükleme",
        subtitle: "Verilerini sunucuya yükle",
        leading: Iconsax.document_upload,
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Konum",
        subtitle: "Konuma göre önerileri düzenle",
        leading: Iconsax.document_download,
        trailing: Switch(value: true, onChanged: (value) {}),
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Güvenli Mod",
        subtitle: "Arama sonuçlarını güvenli tut",
        leading: Iconsax.security_user,
        trailing: Switch(value: false, onChanged: (value) {}),
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "HD Görsel Kalitesi",
        subtitle: "Görsel kalitesini yüksek olarak ayarla",
        leading: Iconsax.image,
        trailing: Switch(value: true, onChanged: (value) {}),
      ),
    ];
    final List<SettingsMenuTileModel> accountSettingsTiles = [
      SettingsMenuTileModel(
        onTap: () {
          //navigateToScreen UserAddressesView
          THelperFunctions.navigateToScreen(context, const UserAddressesView());
        },
        title: "Adreslerim",
        subtitle: "Adres ve konum bilgilerini düzenle",
        leading: Iconsax.safe_home,
      ),
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
        onTap: () {
          if (!isLoggedIn) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          if (canManageShop) {
            THelperFunctions.navigateToScreen(context, const MyShopView());
            return;
          }

          THelperFunctions.navigateToScreen(
            context,
            const LoginView(isMerchantLogin: true),
          );
        },
        title: canManageShop ? "Mağazam" : "Esnaf Ol",
        subtitle: canManageShop
            ? "Mağaza bilgilerini görüntüle"
            : "Esnaf başvurusu yakında eklenecek",
        leading: Icons.storefront_outlined,
      ),
      SettingsMenuTileModel(
        onTap: () {
          if (_currentUserId == null) {
            THelperFunctions.navigateToScreen(context, const LoginView());
            return;
          }

          THelperFunctions.navigateToScreen(context, const CartV2View());
        },
        title: "Sepetim",
        subtitle: "Mağazada doğrulamak için ürünlerini hazırla",
        leading: Iconsax.shopping_cart,
      ),
      SettingsMenuTileModel(
        onTap: () {
          //navigateToScreen UserAddressesView
          THelperFunctions.navigateToScreen(context, const OrdersView());
        },
        title: "İşlemlerim",
        subtitle: "Devam eden ve tamamlanan alışveriş kayıtların",
        leading: Iconsax.bag,
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Banka Hesabı",
        subtitle: "Kayıtlı banka hesabı bilgilerini yönet",
        leading: Iconsax.bank,
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Kuponlarım",
        subtitle: "İndirim ve kampanya kuponlarını görüntüle",
        leading: Iconsax.discount_shape,
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Bildirimler",
        subtitle: "Bildirim tercihlerini düzenle",
        leading: Iconsax.notification,
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Hesap Gizliliği",
        subtitle: "Veri kullanımı ve bağlantılı hesapları yönet",
        leading: Iconsax.security_card,
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
                  AppSettingsSection(appSettingsTiles: appSettingsTiles),
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
          return const SizedBox.shrink();
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
            ],
          ),
        );
      },
    );
  }
}
