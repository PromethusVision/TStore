import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/personalization/presentation/view_models/user_profile_tile_model.dart';
import 'package:t_store/features/personalization/presentation/views/profile_view.dart';
import 'package:t_store/features/personalization/presentation/widgets/user_profile_tile.dart';

class SettingsViewHeaderSection extends StatelessWidget {
  const SettingsViewHeaderSection({super.key, required this.currentUserId});

  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          appBarModel: AppBarModel(
            title: Text(
              TTexts.account,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.apply(color: TColors.white),
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user =
                state is AuthAuthenticated && state.user.id == currentUserId
                ? state.user
                : null;

            if (user != null) {
              return _AuthenticatedProfileTile(user: user);
            }

            if (currentUserId == null) {
              return UserProfileTile(
                userProfileTileModel: UserProfileTileModel(
                  title: 'Giriş yap',
                  subtitle: 'Hesabını ve alışverişlerini görüntüle',
                  onTap: () => THelperFunctions.navigateToScreen(
                    context,
                    const LoginView(),
                  ),
                  trailing: Icons.login,
                  leading: TImages.user,
                ),
              );
            }

            final isLoading =
                state is AuthInitial ||
                state is AuthLoading ||
                state is AuthAuthenticated;

            return UserProfileTile(
              userProfileTileModel: UserProfileTileModel(
                title: isLoading
                    ? 'Bilgiler yükleniyor'
                    : 'Bilgiler yüklenemedi',
                subtitle: isLoading
                    ? 'Lütfen kısa bir süre bekleyin'
                    : 'Tekrar denemek için dokunun',
                onTap: isLoading
                    ? null
                    : () => context.read<AuthCubit>().checkAuthStatus(),
                trailing: isLoading ? Icons.hourglass_empty : Icons.refresh,
                leading: TImages.user,
              ),
            );
          },
        ),
        const SizedBox(height: TSizes.spaceBtwSections * 1.2),
      ],
    );
  }
}

class _AuthenticatedProfileTile extends StatelessWidget {
  const _AuthenticatedProfileTile({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final fullName = user.fullName?.trim() ?? '';
    final email = user.email.trim();

    return UserProfileTile(
      userProfileTileModel: UserProfileTileModel(
        title: fullName.isEmpty ? 'Ad soyad eklenmemiş' : fullName,
        subtitle: email.isEmpty ? 'E-posta bilgisi bulunamadı' : email,
        onTap: () =>
            THelperFunctions.navigateToScreen(context, ProfileView(user: user)),
        trailing: Iconsax.arrow_right_34,
        leading: TImages.user,
      ),
    );
  }
}
