import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_page_header.dart';
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
  bool _isOpeningEditor = false;
  bool _isOpeningAccountDeletion = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _openEditProfile() async {
    if (_isOpeningEditor) return;

    setState(() => _isOpeningEditor = true);
    UserEntity? updatedUser;
    try {
      updatedUser = await showModalBottomSheet<UserEntity>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: EsnaftaVarColors.background,
        barrierColor: EsnaftaVarColors.textPrimary.withValues(alpha: 0.32),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(EsnaftaVarRadii.xxLarge),
          ),
        ),
        builder: (_) => BlocProvider(
          create: (_) => sl<ProfileCubit>(),
          child: EditProfileBottomSheet(user: _user),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningEditor = false);
      } else {
        _isOpeningEditor = false;
      }
    }

    final savedUser = updatedUser;
    if (!mounted || savedUser == null) return;

    setState(() {
      _user = savedUser;
    });
    context.read<AuthCubit>().syncUserProfile(savedUser);
  }

  Future<void> _openAccountDeletionConfirmation() async {
    if (_isOpeningAccountDeletion) return;

    setState(() => _isOpeningAccountDeletion = true);
    try {
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
    } finally {
      if (mounted) {
        setState(() => _isOpeningAccountDeletion = false);
      } else {
        _isOpeningAccountDeletion = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _displayValue(_user.fullName);
    final email = _displayValue(_user.email);
    final phone = _displayValue(_user.phone);

    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            key: const Key('customer-account-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-account-scroll'),
              padding: const EdgeInsets.fromLTRB(
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xs,
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xl,
              ),
              child: Column(
                children: [
                  const _AccountHeader(),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  _CustomerIdentityCard(fullName: fullName),
                  const SizedBox(height: EsnaftaVarSpacing.md),
                  _ContactInformationCard(email: email, phone: phone),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('edit-profile-button'),
                      onPressed: _isOpeningEditor ? null : _openEditProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: EsnaftaVarColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            EsnaftaVarRadii.large,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      label: const Text('Bilgileri Düzenle'),
                    ),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.xl),
                  _DangerZoneCard(
                    onDeleteAccount: _isOpeningAccountDeletion
                        ? null
                        : _openAccountDeletionConfirmation,
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
  Widget build(BuildContext context) => const AccountPageHeader(
    key: Key('customer-account-header'),
    backKey: Key('customer-account-back-button'),
    title: 'Hesap Bilgilerim',
    subtitle: 'Kişisel bilgilerini görüntüle ve düzenle',
  );
}

class _CustomerIdentityCard extends StatelessWidget {
  const _CustomerIdentityCard({required this.fullName});
  final String fullName;
  @override
  Widget build(BuildContext context) => Card(
    key: const Key('customer-account-identity-card'),
    child: Padding(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: EsnaftaVarColors.primarySoft,
            child: Icon(
              Icons.person_outline_rounded,
              color: EsnaftaVarColors.primary,
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  'Esnafta Var müşteri hesabı',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(
              color: EsnaftaVarColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xxs),
          const Text(
            'Size ulaşmak için kullanılan hesap bilgileri',
            style: TextStyle(
              color: EsnaftaVarColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.md),
          _AccountInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'E-posta',
            value: email,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 52),
            child: Divider(height: 17, color: EsnaftaVarColors.borderDefault),
          ),
          _AccountInfoRow(
            icon: Icons.phone_outlined,
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
            color: EsnaftaVarColors.primarySoft,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          ),
          child: Icon(icon, color: EsnaftaVarColors.primary, size: 20),
        ),
        const SizedBox(width: EsnaftaVarSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: EsnaftaVarColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: EsnaftaVarSpacing.xxs),
              Text(
                value,
                style: const TextStyle(
                  color: EsnaftaVarColors.textPrimary,
                  fontSize: 14,
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

  final VoidCallback? onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-account-danger-zone'),
      width: double.infinity,
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.errorSoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: EsnaftaVarColors.accent,
                size: 21,
              ),
              SizedBox(width: EsnaftaVarSpacing.xs),
              Text(
                'Hesap işlemleri',
                style: TextStyle(
                  color: EsnaftaVarColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          const Text(
            'Hesabını silmek tüm kişisel bilgilerini kalıcı olarak kaldırır.',
            style: TextStyle(
              color: EsnaftaVarColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          TextButton.icon(
            key: const Key('delete-account-button'),
            onPressed: onDeleteAccount,
            style: TextButton.styleFrom(
              foregroundColor: EsnaftaVarColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
