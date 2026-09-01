import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

/// Presentation-only contract for the owner-approved five-task reward cycle.
///
/// Progress truth and reward value are supplied by a future Reward Engine. This
/// contract does not persist tasks, issue rewards or define reward economics.
class RewardProgressData {
  const RewardProgressData({
    required this.completedTasks,
    required this.rewardAmountText,
    this.title = 'Görev yap, kazan',
    this.subtitle,
    this.message,
  });

  static const int taskCycleTotal = 5;

  final int completedTasks;
  final String rewardAmountText;
  final String title;
  final String? subtitle;
  final String? message;

  int get totalTasks => taskCycleTotal;

  int get safeCompletedTasks => completedTasks.clamp(0, totalTasks);

  int get remainingTasks => totalTasks - safeCompletedTasks;

  double get safeProgress => safeCompletedTasks / totalTasks;

  bool get isComplete => safeCompletedTasks == totalTasks;

  String get displayRewardAmount {
    final amount = rewardAmountText.trim();
    return amount.isEmpty ? 'Ödül' : amount;
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
    this.compact = false,
  });

  final bool enabled;
  final RewardProgressData? data;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!enabled || data == null) {
      return const SizedBox.shrink(key: Key('reward-progress-slot-off'));
    }
    return RewardProgressCard(data: data!, onTap: onTap, compact: compact);
  }
}

class RewardProgressCard extends StatelessWidget {
  const RewardProgressCard({
    super.key,
    required this.data,
    this.onTap,
    this.compact = false,
  });

  final RewardProgressData data;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      key: const Key('reward-progress-card'),
      constraints: BoxConstraints(minHeight: compact ? 104 : 132),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: compact ? EsnaftaVarColors.accentSoft : EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(
          compact ? EsnaftaVarRadii.xLarge : EsnaftaVarRadii.large,
        ),
        border: compact
            ? null
            : Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: compact ? null : EsnaftaVarElevation.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RewardHeader(data: data),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          _RewardStatus(data: data),
          if (data.message?.trim().isNotEmpty == true) ...[
            const SizedBox(height: EsnaftaVarSpacing.xxs),
            Text(
              data.message!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: EsnaftaVarColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: EsnaftaVarSpacing.xs),
          _RewardSegments(data: data),
        ],
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label:
          '${data.title}. ${data.safeCompletedTasks}/${data.totalTasks} görev tamamlandı. '
          '${data.isComplete ? 'Ödülü kazandın.' : 'Ödüle ${data.remainingTasks} görev kaldı.'} '
          'Ödül ${data.displayRewardAmount}.'
          '${data.subtitle?.trim().isNotEmpty == true ? ' ${data.subtitle!.trim()}.' : ''}'
          '${data.message?.trim().isNotEmpty == true ? ' ${data.message!.trim()}.' : ''}',
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  compact ? EsnaftaVarRadii.xLarge : EsnaftaVarRadii.large,
                ),
                child: content,
              ),
            ),
    );
  }
}

class _RewardHeader extends StatelessWidget {
  const _RewardHeader({required this.data});

  final RewardProgressData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: EsnaftaVarColors.surface,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          ),
          child: Icon(
            data.isComplete
                ? Icons.check_rounded
                : Icons.workspace_premium_rounded,
            color: data.isComplete
                ? EsnaftaVarColors.success
                : EsnaftaVarColors.accent,
            size: EsnaftaVarIconSizes.large,
          ),
        ),
        const SizedBox(width: EsnaftaVarSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: EsnaftaVarColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (data.subtitle?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 1),
                Text(
                  data.subtitle!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: EsnaftaVarSpacing.xs),
        Container(
          key: const Key('reward-amount'),
          constraints: const BoxConstraints(
            minWidth: 62,
            maxWidth: 112,
            minHeight: 38,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: EsnaftaVarSpacing.xs,
            vertical: EsnaftaVarSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: data.isComplete
                ? EsnaftaVarColors.successSoft
                : EsnaftaVarColors.surface,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
            border: Border.all(
              color: data.isComplete
                  ? EsnaftaVarColors.success
                  : EsnaftaVarColors.accent.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ÖDÜL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: data.isComplete
                      ? EsnaftaVarColors.success
                      : EsnaftaVarColors.accent,
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.displayRewardAmount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: EsnaftaVarColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardStatus extends StatelessWidget {
  const _RewardStatus({required this.data});

  final RewardProgressData data;

  @override
  Widget build(BuildContext context) {
    final statusText = data.isComplete
        ? 'Ödülü kazandın'
        : 'Ödüle ${data.remainingTasks} görev kaldı';
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: EsnaftaVarSpacing.xs,
      runSpacing: EsnaftaVarSpacing.xxs,
      children: [
        Text(
          statusText,
          key: const Key('reward-remaining-count'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: data.isComplete
                ? EsnaftaVarColors.success
                : EsnaftaVarColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${data.safeCompletedTasks}/${data.totalTasks} görev tamamlandı',
          key: const Key('reward-completed-count'),
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: EsnaftaVarColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RewardSegments extends StatelessWidget {
  const _RewardSegments({required this.data});

  final RewardProgressData data;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${data.safeCompletedTasks} tamamlanan, ${data.remainingTasks} kalan görev',
      value: '${data.safeCompletedTasks}/${data.totalTasks}',
      child: Row(
        key: const Key('reward-progress-indicator'),
        children: [
          for (var index = 0; index < data.totalTasks; index++) ...[
            if (index > 0) const SizedBox(width: EsnaftaVarSpacing.xxs),
            Expanded(
              child: AnimatedContainer(
                key: Key('reward-task-segment-$index'),
                duration: const Duration(milliseconds: 180),
                height: 8,
                decoration: BoxDecoration(
                  color: index < data.safeCompletedTasks
                      ? data.isComplete
                            ? EsnaftaVarColors.success
                            : EsnaftaVarColors.accent
                      : EsnaftaVarColors.surface,
                  borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
                  border: index < data.safeCompletedTasks
                      ? null
                      : Border.all(
                          color: EsnaftaVarColors.accent.withValues(alpha: 0.2),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
