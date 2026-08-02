import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
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
        Container(
          key: const Key('customer-profile-header'),
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
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.petrol,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.profile_circle,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profilim',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      'Hesabını ve tercihlerini tek yerden yönet',
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
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space12),
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
