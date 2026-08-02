import 'package:flutter/material.dart';
import 'package:t_store/core/common/view_models/rounded_image_view_model.dart';
import 'package:t_store/core/common/widgets/rounded_image.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/user_profile_tile_model.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({super.key, required this.userProfileTileModel});
  final UserProfileTileModel userProfileTileModel;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('customer-profile-identity-card'),
      color: CustomerHomeV1Tokens.surface,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
      child: InkWell(
        onTap: userProfileTileModel.onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(CustomerHomeV1Tokens.space4),
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: RoundedImage(
                    roundedImageModel: RoundedImageModel(
                      image: userProfileTileModel.leading,
                      width: 46,
                      height: 46,
                      applyImageRadius: true,
                      borderRadius: CustomerHomeV1Tokens.radiusPill,
                      backgroundColor: CustomerHomeV1Tokens.mint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfileTileModel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      userProfileTileModel.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space8),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  userProfileTileModel.trailing,
                  color: CustomerHomeV1Tokens.petrol,
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
