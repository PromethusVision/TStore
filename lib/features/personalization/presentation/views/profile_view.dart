import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_deletion_confirmation_dialog.dart';
import 'package:t_store/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:t_store/features/shop/domain/services/recently_viewed_products_storage.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.user});

  final UserEntity user;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserEntity _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _openEditProfile() async {
    final updatedUser = await showModalBottomSheet<UserEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: CustomerHomeV1Tokens.cream,
      barrierColor: CustomerHomeV1Tokens.navy.withValues(alpha: 0.32),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CustomerHomeV1Tokens.radius24),
        ),
      ),
      builder: (_) => BlocProvider(
        create: (_) => sl<ProfileCubit>(),
        child: EditProfileBottomSheet(user: _user),
      ),
    );

    if (!mounted || updatedUser == null) return;

    setState(() {
      _user = updatedUser;
    });
    context.read<AuthCubit>().syncUserProfile(updatedUser);
  }

  Future<void> _openAccountDeletionConfirmation() async {
    final deleteCurrentCustomerAccount = context
        .read<AuthCubit>()
        .deleteCurrentCustomerAccount;
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccountDeletionConfirmationDialog(
        onConfirm: deleteCurrentCustomerAccount,
      ),
    );
    if (!mounted || deleted != true) return;

    if (sl.isRegistered<RecentlyViewedProductsStorage>()) {
      try {
        await sl<RecentlyViewedProductsStorage>().clear(_user.id);
      } catch (_) {
        // Account deletion has already succeeded. Local history cleanup must
        // never trap the customer on a deleted account screen.
      }
    }
    if (!mounted) return;

    context.read<CartV2Cubit>().clearLocalCart();
    context.read<WishlistCubit>().clearLocalWishlist();
    context.read<NavigationMenuCubit>().changeIndex(0);

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const NavigationMenu()),
      (_) => false,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Hesabınız ve kişisel bilgileriniz silindi.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _displayValue(_user.fullName);
    final email = _displayValue(_user.email);
    final phone = _displayValue(_user.phone);

    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-account-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-account-scroll'),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space24,
              ),
              child: Column(
                children: [
                  const _AccountHeader(),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  _CustomerIdentityCard(fullName: fullName),
                  const SizedBox(height: CustomerHomeV1Tokens.space16),
                  _ContactInformationCard(email: email, phone: phone),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      key: const Key('edit-profile-button'),
                      onPressed: _openEditProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: CustomerHomeV1Tokens.petrol,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radius16,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Iconsax.edit, size: 19),
                      label: const Text('Bilgileri Düzenle'),
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space24),
                  _DangerZoneCard(
                    onDeleteAccount: _openAccountDeletionConfirmation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _displayValue(String? value) {
    final normalizedValue = value?.trim() ?? '';
    return normalizedValue.isEmpty ? 'Belirtilmemiş' : normalizedValue;
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-account-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('customer-account-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hesap Bilgilerim',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Kişisel bilgilerini görüntüle ve düzenle',
                  maxLines: 2,
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
        ],
      ),
    );
  }
}

class _CustomerIdentityCard extends StatelessWidget {
  const _CustomerIdentityCard({required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-account-identity-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space4),
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(TImages.user, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                const Text(
                  'Esnafta Var müşteri hesabı',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.verify5,
              color: CustomerHomeV1Tokens.petrol,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInformationCard extends StatelessWidget {
  const _ContactInformationCard({required this.email, required this.phone});

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-account-contact-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space4),
          const Text(
            'Size ulaşmak için kullanılan hesap bilgileri',
            style: TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          _AccountInfoRow(icon: Iconsax.direct, label: 'E-posta', value: email),
          const Padding(
            padding: EdgeInsets.only(left: 52),
            child: Divider(height: 17, color: CustomerHomeV1Tokens.border),
          ),
          _AccountInfoRow(
            icon: Iconsax.call,
            label: 'Telefon Numarası',
            value: phone,
          ),
        ],
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.mint,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
          ),
          child: Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 20),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({required this.onDeleteAccount});

  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-account-danger-zone'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: const Color(0xFFF0C8BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Iconsax.shield_cross,
                color: CustomerHomeV1Tokens.coral,
                size: 21,
              ),
              SizedBox(width: CustomerHomeV1Tokens.space8),
              Text(
                'Hesap işlemleri',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space8),
          const Text(
            'Hesabını silmek tüm kişisel bilgilerini kalıcı olarak kaldırır.',
            style: TextStyle(
              color: CustomerHomeV1Tokens.muted,
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          TextButton.icon(
            key: const Key('delete-account-button'),
            onPressed: onDeleteAccount,
            style: TextButton.styleFrom(
              foregroundColor: CustomerHomeV1Tokens.coral,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
