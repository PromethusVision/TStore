//SettingsMenuTileList >> settings_menu_tile.dart
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';
import 'package:t_store/features/personalization/presentation/widgets/settings_menu_tile.dart';

class SettingsMenuTileList extends StatelessWidget {
  const SettingsMenuTileList({super.key, required this.settingsMenuTiles});
  final List<SettingsMenuTileModel> settingsMenuTiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: settingsMenuTiles.length,
        itemBuilder: (context, index) =>
            SettingsMenuTile(settingsMenuTileModel: settingsMenuTiles[index]),
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 1,
          indent: 56,
          endIndent: EsnaftaVarSpacing.sm,
          color: EsnaftaVarColors.borderDefault,
        ),
      ),
    );
  }
}
