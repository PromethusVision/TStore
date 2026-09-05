// Isolated design-review compositions. No production route imports this folder.
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class SweepFrame extends StatelessWidget {
  const SweepFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
    this.showBack = true,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    if (showBack) ...[
                      EsnaftaVarSurfaceIconButton(
                        buttonKey: const Key('sweep-back'),
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Geri',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: EsnaftaVarColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    ?action,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    ),
  );
}

class SweepSurface extends StatelessWidget {
  const SweepSurface({
    super.key,
    required this.child,
    this.color = EsnaftaVarColors.surface,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      border: Border.all(color: EsnaftaVarColors.borderDefault),
    ),
    child: child,
  );
}

class SweepSheet extends StatelessWidget {
  const SweepSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onClose,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      20,
      12,
      20,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: EsnaftaVarColors.borderStrong,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: EsnaftaVarColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('sweep-close'),
              tooltip: 'Kapat',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        child,
      ],
    ),
  );
}

class SweepStars extends StatelessWidget {
  const SweepStars({super.key, required this.rating, this.onChanged});
  final int rating;
  final ValueChanged<int>? onChanged;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var value = 1; value <= 5; value++)
        if (onChanged != null)
          IconButton(
            key: Key('sweep-star-$value'),
            tooltip: '$value yıldız',
            onPressed: () => onChanged!(value),
            iconSize: 36,
            icon: Icon(
              value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: EsnaftaVarColors.highlight,
            ),
          )
        else
          Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 20,
            color: EsnaftaVarColors.highlight,
          ),
    ],
  );
}

String sweepDate(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
}

String sweepTime(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String sweepMoney(double value) =>
    '${value.toStringAsFixed(2).replaceAll('.', ',')} TL';
