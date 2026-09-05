import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/user_profile_tile_model.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({super.key, required this.userProfileTileModel});
  final UserProfileTileModel userProfileTileModel;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('customer-profile-identity-card'),
      color: EsnaftaVarColors.surface,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      child: InkWell(
        onTap: userProfileTileModel.onTap,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(EsnaftaVarSpacing.xxs),
                decoration: const BoxDecoration(
                  color: EsnaftaVarColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: RoundedImage(
                    roundedImageModel: RoundedImageModel(
                      image: userProfileTileModel.leading,
                      width: 46,
                      height: 46,
                      applyImageRadius: true,
                      borderRadius: EsnaftaVarRadii.pill,
                      backgroundColor: EsnaftaVarColors.primarySoft,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileTileModel.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      userProfileTileModel.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.xs),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: EsnaftaVarColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  userProfileTileModel.trailing,
                  color: EsnaftaVarColors.primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
