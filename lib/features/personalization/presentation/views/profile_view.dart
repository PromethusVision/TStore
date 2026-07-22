import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/view_models/profile_entity_tile_model.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_deletion_confirmation_dialog.dart';
import 'package:t_store/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:t_store/features/personalization/presentation/widgets/personal_information_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/profile_information_section.dart';
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
      showDragHandle: true,
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
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccountDeletionConfirmationDialog(
        onConfirm: context.read<AuthCubit>().deleteCurrentCustomerAccount,
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

    final List<ProfileEntityTileModel> profileInformation = [
      ProfileEntityTileModel(title: "Ad Soyad", value: fullName),
    ];
    final List<ProfileEntityTileModel> personalInformation = [
      ProfileEntityTileModel(title: "E-posta", value: email),
      ProfileEntityTileModel(title: "Telefon Numarası", value: phone),
    ];
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title: const Text("Profil"),
          hasArrowBack: true,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                ProfileInformationSection(
                  profileInformation: profileInformation,
                ),
                const SpaceBetweenSectionsWithDivider(),
                PersonalInformationSection(
                  personalInformation: personalInformation,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('edit-profile-button'),
                    onPressed: _openEditProfile,
                    icon: const Icon(Iconsax.edit),
                    label: const Text('Bilgileri Düzenle'),
                  ),
                ),
                const SpaceBetweenSectionsWithDivider(),
                TextButton(
                  key: const Key('delete-account-button'),
                  onPressed: _openAccountDeletionConfirmation,
                  child: const Text(
                    "Hesabı Sil",
                    style: TextStyle(color: TColors.error),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 1.5),
              ],
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

class SpaceBetweenSectionsWithDivider extends StatelessWidget {
  const SpaceBetweenSectionsWithDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: TSizes.spaceBtwItems / 1.5),
        Divider(),
        SizedBox(height: TSizes.spaceBtwItems / 1.5),
      ],
    );
  }
}
