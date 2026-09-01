import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class EsnaftaVarStateCard extends StatelessWidget {
  const EsnaftaVarStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.primarySoft,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
        ),
        child: Column(
          children: [
            Icon(icon, color: EsnaftaVarColors.primary, size: 30),
            const SizedBox(height: EsnaftaVarSpacing.xs),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: EsnaftaVarColors.textPrimary,
              ),
            ),
            const SizedBox(height: EsnaftaVarSpacing.xxs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: EsnaftaVarColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: EsnaftaVarSpacing.xs),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
