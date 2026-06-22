import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/widgets/primary_header_container.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';
import 'package:t_store/features/personalization/presentation/views/user_addresses_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/app_settings_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_view_header_section.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';
import 'package:t_store/features/shop/presentation/views/orders_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
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
        trailing: Switch(
          value: true,
          onChanged: (value) {},
        ),
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "Güvenli Mod",
        subtitle: "Arama sonuçlarını güvenli tut",
        leading: Iconsax.security_user,
        trailing: Switch(
          value: false,
          onChanged: (value) {},
        ),
      ),
      SettingsMenuTileModel(
        onTap: () {},
        title: "HD Görsel Kalitesi",
        subtitle: "Görsel kalitesini yüksek olarak ayarla",
        leading: Iconsax.image,
        trailing: Switch(
          value: true,
          onChanged: (value) {},
        ),
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
        onTap: () {
          final currentUser = SupabaseService.instance.currentUser;
          THelperFunctions.navigateToScreen(
            context,
            currentUser == null ? const LoginView() : const ConversationsView(),
          );
        },
        title: "Mesajlarım",
        subtitle: "Geçmiş konuşmalarını görüntüle",
        leading: Iconsax.direct,
      ),
      SettingsMenuTileModel(
        onTap: () {},
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
      if (kDebugMode)
        SettingsMenuTileModel(
          onTap: () {
            THelperFunctions.navigateToScreen(context, const CartV2View());
          },
          title: "CartV2 Test",
          subtitle: "Mağaza sepeti test ekranı",
          leading: Iconsax.code,
        ),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const PrimaryHeaderContainer(child: SettingsViewHeaderSection()),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  AccountSettingsSection(
                      accountSettingsTiles: accountSettingsTiles),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                  AppSettingsSection(appSettingsTiles: appSettingsTiles),
                  const SizedBox(
                    height: TSizes.spaceBtwItems,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
