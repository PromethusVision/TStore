import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/personalization/presentation/view_models/profile_entity_tile_model.dart';
import 'package:t_store/features/personalization/presentation/widgets/personal_information_section.dart';
import 'package:t_store/features/personalization/presentation/widgets/profile_information_section.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProfileEntityTileModel> profileInformation = [
      ProfileEntityTileModel(
        title: "Ad Soyad",
        value: "Turgut Duman",
        onTap: () {},
      ),
      const ProfileEntityTileModel(
        title: "Kullanıcı Adı",
        value: "turgutduman",
      ),
    ];
    final List<ProfileEntityTileModel> personalInformation = [
      ProfileEntityTileModel(
        trailing: Iconsax.copy,
        title: "Kullanıcı ID",
        value: "EV-0001",
        onTap: () {},
      ),
      const ProfileEntityTileModel(
        title: "E-posta",
        value: "turgut.duman@example.com",
      ),
      const ProfileEntityTileModel(
        title: "Telefon Numarası",
        value: "+90 555 123 45 67",
      ),
      const ProfileEntityTileModel(
        title: "Cinsiyet",
        value: "Erkek",
      ),
      const ProfileEntityTileModel(
        title: "Doğum Tarihi",
        value: "01/01/1990",
      ),
    ];
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel:
            AppBarModel(title: const Text("Profil"), hasArrowBack: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              ProfileInformationSection(profileInformation: profileInformation),
              const SpaceBetweenSectionsWithDivider(),
              PersonalInformationSection(
                  personalInformation: personalInformation),
              const SpaceBetweenSectionsWithDivider(),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Hesabı Sil",
                    style: TextStyle(color: TColors.error),
                  )),
              const SizedBox(
                height: TSizes.spaceBtwItems / 1.5,
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class SpaceBetweenSectionsWithDivider extends StatelessWidget {
  const SpaceBetweenSectionsWithDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: TSizes.spaceBtwItems / 1.5,
        ),
        Divider(),
        SizedBox(
          height: TSizes.spaceBtwItems / 1.5,
        ),
      ],
    );
  }
}
