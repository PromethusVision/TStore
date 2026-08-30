import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

/// Presentation-only contract for a future reward source.
///
/// It deliberately carries no point formula, money value, expiry, threshold
/// economics or backend behavior.
class RewardProgressData {
  const RewardProgressData({
    required this.progress,
    required this.title,
    this.currentMilestone,
    this.nextMilestone,
    this.contextualMessage,
  });

  final double progress;
  final String title;
  final String? currentMilestone;
  final String? nextMilestone;
  final String? contextualMessage;

  double get safeProgress {
    if (!progress.isFinite) return 0;
    return progress.clamp(0, 1).toDouble();
  }
}

/// Capability-gated slot placed in the final Home composition.
///
/// Runtime defaults to hidden. Preview and widget tests must opt in explicitly
/// and provide isolated fixture data.
class RewardProgressSlot extends StatelessWidget {
  const RewardProgressSlot({
    super.key,
    this.enabled = false,
    this.data,
    this.onTap,
  });

  final bool enabled;
  final RewardProgressData? data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!enabled || data == null) {
      return const SizedBox.shrink(key: Key('reward-progress-slot-off'));
    }
    return RewardProgressCard(data: data!, onTap: onTap);
  }
}

class RewardProgressCard extends StatelessWidget {
  const RewardProgressCard({super.key, required this.data, this.onTap});

  final RewardProgressData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = data.safeProgress;
    final content = Container(
      key: const Key('reward-progress-card'),
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: EsnaftaVarTouchTargets.minimum,
                height: EsnaftaVarTouchTargets.minimum,
                decoration: BoxDecoration(
                  color: EsnaftaVarColors.accentSoft,
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: EsnaftaVarColors.accent,
                  size: EsnaftaVarIconSizes.large,
                ),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: EsnaftaVarColors.textPrimary,
                      ),
                    ),
                    if (data.contextualMessage?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      Text(
                        data.contextualMessage!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: EsnaftaVarColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const SizedBox(
                  width: EsnaftaVarTouchTargets.minimum,
                  height: EsnaftaVarTouchTargets.minimum,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: EsnaftaVarColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          Semantics(
            label: 'Ödül ilerlemesi yüzde ${(progress * 100).round()}',
            value: '${(progress * 100).round()}%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
              child: LinearProgressIndicator(
                key: const Key('reward-progress-indicator'),
                minHeight: 9,
                value: progress,
                color: EsnaftaVarColors.rewardProgress,
                backgroundColor: EsnaftaVarColors.rewardTrack,
              ),
            ),
          ),
          if (_hasMilestoneLabels) ...[
            const SizedBox(height: EsnaftaVarSpacing.xs),
            Row(
              children: [
                if (data.currentMilestone?.trim().isNotEmpty == true)
                  Expanded(
                    child: Text(
                      data.currentMilestone!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: EsnaftaVarColors.textSecondary,
                      ),
                    ),
                  ),
                if (data.nextMilestone?.trim().isNotEmpty == true)
                  Expanded(
                    child: Text(
                      data.nextMilestone!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: EsnaftaVarColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: 'Ödül ilerleme kartı',
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
                child: content,
              ),
            ),
    );
  }

  bool get _hasMilestoneLabels =>
      data.currentMilestone?.trim().isNotEmpty == true ||
      data.nextMilestone?.trim().isNotEmpty == true;
}
