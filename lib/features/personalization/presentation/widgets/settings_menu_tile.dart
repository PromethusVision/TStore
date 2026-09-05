import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/personalization/presentation/view_models/settings_menu_tile_model.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({super.key, required this.settingsMenuTileModel});
  final SettingsMenuTileModel settingsMenuTileModel;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: settingsMenuTileModel.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: EsnaftaVarColors.primarySoft,
                      borderRadius: BorderRadius.circular(
                        EsnaftaVarRadii.medium,
                      ),
                    ),
                    child: Icon(
                      settingsMenuTileModel.leading,
                      color: EsnaftaVarColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: EsnaftaVarSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settingsMenuTileModel.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        Text(
                          settingsMenuTileModel.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: EsnaftaVarSpacing.xs),
                  settingsMenuTileModel.trailing ??
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: EsnaftaVarColors.textSecondary,
                        size: 20,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
