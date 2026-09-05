import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({super.key, required this.settingsMenuTileModel});
  final SettingsMenuTileModel settingsMenuTileModel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: EsnaftaVarSpacing.sm,
        vertical: EsnaftaVarSpacing.xxs,
      ),
      minLeadingWidth: 32,
      horizontalTitleGap: EsnaftaVarSpacing.sm,
      title: Text(
        settingsMenuTileModel.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: EsnaftaVarColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: settingsMenuTileModel.onTap,
      subtitle: Text(
        settingsMenuTileModel.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: EsnaftaVarColors.textSecondary,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: EsnaftaVarColors.primarySoft,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
        ),
        child: Icon(
          settingsMenuTileModel.leading,
          color: EsnaftaVarColors.primary,
          size: 20,
        ),
      ),
      trailing:
          settingsMenuTileModel.trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: EsnaftaVarColors.textSecondary,
            size: 20,
          ),
    );
  }
}
