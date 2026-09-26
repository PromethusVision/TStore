import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';

class MerchantLogoBubbles extends StatelessWidget {
  const MerchantLogoBubbles({super.key, required this.merchants});
  final List<RewardEligibleMerchant> merchants;
  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) return const SizedBox.shrink();
    final visible = merchants.take(3).toList();
    return Semantics(
      label: '${merchants.length} uygun esnaf',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32 + (visible.length - 1) * 24,
            height: 32,
            child: Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Positioned(
                    left: i * 24,
                    child: Tooltip(
                      message: visible[i].name,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: EsnaftaVarColors.surface,
                          border: Border.all(
                            color: EsnaftaVarColors.borderDefault,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(child: _logo(visible[i])),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (merchants.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '+${merchants.length - 3}',
                style: const TextStyle(color: EsnaftaVarColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _logo(RewardEligibleMerchant merchant) {
    final uri = Uri.tryParse(merchant.logoUrl ?? '');
    final fallback = Center(
      child: Text(
        merchant.name.trim().isEmpty
            ? 'E'
            : merchant.name.trim().characters.first.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: EsnaftaVarColors.primary,
        ),
      ),
    );
    return uri?.scheme == 'https' &&
            uri!.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? Image.network(
            uri.toString(),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => fallback,
          )
        : fallback;
  }
}

class RewardCounterCard extends StatefulWidget {
  const RewardCounterCard({super.key, required this.progress, this.onTap});
  final RewardProgress progress;
  final VoidCallback? onTap;
  @override
  State<RewardCounterCard> createState() => _RewardCounterCardState();
}

class _RewardCounterCardState extends State<RewardCounterCard>
    with TickerProviderStateMixin {
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _feedback = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _celebration = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  late Animation<double> _value = AlwaysStoppedAnimation(
    widget.progress.fraction,
  );
  bool _reduce = false;
  int _delta = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (_reduce) {
      _bar.stop();
      _feedback.stop();
      _celebration.stop();
      _value = AlwaysStoppedAnimation(widget.progress.fraction);
    }
  }

  @override
  void didUpdateWidget(covariant RewardCounterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress.completed == widget.progress.completed) return;
    final before = _value.value;
    _bar.stop();
    _feedback.reset();
    _celebration.reset();
    _delta = widget.progress.completed - oldWidget.progress.completed;
    _value = _reduce
        ? AlwaysStoppedAnimation(widget.progress.fraction)
        : Tween<double>(
            begin: before,
            end: widget.progress.fraction,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_bar);
    if (!_reduce) {
      _bar.forward(from: 0);
      if (_delta > 0) {
        _feedback.forward();
        if (widget.progress.completed == RewardProgress.goal) {
          _celebration.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _bar.dispose();
    _feedback.dispose();
    _celebration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_bar, _feedback, _celebration]),
    builder: (context, _) {
      final progress = widget.progress;
      final content = Container(
        key: const Key('reward-progress-card'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _feedback.isAnimating
                ? EsnaftaVarColors.primary
                : EsnaftaVarColors.borderDefault,
          ),
          boxShadow: _feedback.isAnimating
              ? [
                  BoxShadow(
                    color: EsnaftaVarColors.primary.withValues(
                      alpha: 0.10 * math.sin(_feedback.value * math.pi),
                    ),
                    blurRadius: 14,
                  ),
                ]
              : EsnaftaVarElevation.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: EsnaftaVarColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ödül Sayacı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: EsnaftaVarColors.textPrimary,
                    ),
                  ),
                ),
                if (_feedback.isAnimating)
                  Text(
                    '+$_delta',
                    key: const Key('reward-increment'),
                    style: const TextStyle(
                      color: EsnaftaVarColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completed} / ${RewardProgress.goal}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: EsnaftaVarColors.textPrimary,
                  ),
                ),
                Text(
                  progress.completed == RewardProgress.goal
                      ? 'Sayaç tamamlandı'
                      : 'Ödüle ${progress.remaining} adım kaldı',
                  style: const TextStyle(color: EsnaftaVarColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                key: const Key('reward-counter-bar'),
                value: _value.value,
                minHeight: 8,
                backgroundColor: EsnaftaVarColors.primarySoft,
                color: EsnaftaVarColors.primary,
                semanticsLabel: 'Ödül Sayacı, ${progress.completed} / 5',
              ),
            ),
            if (progress.merchants.isNotEmpty) ...[
              const SizedBox(height: 12),
              MerchantLogoBubbles(merchants: progress.merchants),
            ],
            if (!progress.available) ...[
              const SizedBox(height: 8),
              const Text(
                'Ödül programı yakında. Katılım koşulları burada paylaşılacak.',
                style: TextStyle(
                  fontSize: 12,
                  color: EsnaftaVarColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
      return Semantics(
        container: true,
        button: widget.onTap != null,
        liveRegion: _delta > 0,
        label: 'Ödül Sayacı, ${progress.completed} / 5',
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: content,
              ),
            ),
            if (_celebration.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const Key('reward-celebration'),
                    painter: _CelebrationPainter(_celebration.value),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _CelebrationPainter extends CustomPainter {
  _CelebrationPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var i = 0; i < 18; i++) {
      final angle = i * math.pi * 2 / 18;
      final r = (0.15 + progress * 0.5) * size.shortestSide;
      final point = Offset(
        size.width / 2 + math.cos(angle) * r,
        size.height / 2 + math.sin(angle) * r + progress * 20,
      );
      final color = [
        EsnaftaVarColors.primary,
        EsnaftaVarColors.highlight,
        EsnaftaVarColors.accent,
      ][i % 3];
      canvas.drawCircle(
        point,
        2.5,
        Paint()..color = color.withValues(alpha: 1 - progress),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
