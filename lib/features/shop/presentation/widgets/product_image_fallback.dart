import 'package:flutter/material.dart';

class ProductImageFallback extends StatelessWidget {
  final double iconSize;

  const ProductImageFallback({super.key, this.iconSize = 36});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      child: Center(
        child: Container(
          width: iconSize * 1.8,
          height: iconSize * 1.8,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: iconSize,
            color: colorScheme.primary.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
