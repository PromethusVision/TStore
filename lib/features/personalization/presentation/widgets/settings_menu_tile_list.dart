//SettingsMenuTileList >> settings_menu_tile.dart
import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
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
          indent: 68,
          endIndent: CustomerHomeV1Tokens.space12,
          color: CustomerHomeV1Tokens.border,
        ),
      ),
    );
  }
}
