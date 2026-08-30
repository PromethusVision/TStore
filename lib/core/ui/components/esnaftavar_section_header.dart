import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class EsnaftaVarSectionHeader extends StatelessWidget {
  const EsnaftaVarSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionKey,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: EsnaftaVarColors.textPrimary,
                ),
              ),
              if (subtitle?.trim().isNotEmpty == true) ...[
                const SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  subtitle!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: EsnaftaVarColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: EsnaftaVarSpacing.xs),
          TextButton.icon(
            key: actionKey,
            onPressed: onAction,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
