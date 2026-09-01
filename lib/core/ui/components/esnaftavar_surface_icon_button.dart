import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class EsnaftaVarSurfaceIconButton extends StatelessWidget {
  const EsnaftaVarSurfaceIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.buttonKey,
    this.badgeCount = 0,
    this.badgeKey,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Key? buttonKey;
  final int badgeCount;
  final Key? badgeKey;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: EsnaftaVarColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: EsnaftaVarTouchTargets.preferred,
            height: EsnaftaVarTouchTargets.preferred,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: EsnaftaVarColors.borderDefault),
              boxShadow: EsnaftaVarElevation.xs,
            ),
            child: Icon(
              icon,
              color: EsnaftaVarColors.primary,
              size: EsnaftaVarIconSizes.large,
            ),
          ),
        ),
      ),
    );

    if (badgeCount <= 0) return button;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          key: badgeKey,
          right: -2,
          top: -3,
          child: Container(
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EsnaftaVarColors.accent,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
              border: Border.all(color: EsnaftaVarColors.surface, width: 2),
            ),
            child: Text(
              badgeCount > 99 ? '99+' : badgeCount.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EsnaftaVarColors.textOnPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
