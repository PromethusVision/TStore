import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/view_models/profile_entity_tile_model.dart';
import 'package:t_store/features/personalization/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:t_store/features/personalization/presentation/widgets/personal_information_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/profile_information_section.dart';

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
                  onPressed: () {},
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
