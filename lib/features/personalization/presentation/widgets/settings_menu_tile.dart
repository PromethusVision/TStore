import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({super.key, required this.settingsMenuTileModel});
  final SettingsMenuTileModel settingsMenuTileModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space12,
        vertical: CustomerHomeV1Tokens.space8,
      ),
      minLeadingWidth: 44,
      horizontalTitleGap: CustomerHomeV1Tokens.space12,
      title: Text(
        settingsMenuTileModel.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: CustomerHomeV1Tokens.navy,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: settingsMenuTileModel.onTap,
      subtitle: Text(
        settingsMenuTileModel.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: CustomerHomeV1Tokens.muted,
          fontSize: 10,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.mint,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        ),
        child: Icon(
          settingsMenuTileModel.leading,
          color: CustomerHomeV1Tokens.petrol,
          size: 22,
        ),
      ),
      trailing:
          settingsMenuTileModel.trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: CustomerHomeV1Tokens.muted,
            size: 22,
          ),
    );
  }
}
