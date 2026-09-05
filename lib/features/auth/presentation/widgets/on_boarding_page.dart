import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/view_models/on_boarding_model.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key, required this.onBoardingModel});

  final OnBoardingModel onBoardingModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize = constraints.maxHeight < 420 ? 132.0 : 176.0;

        return SingleChildScrollView(
          key: ValueKey('onboarding-page-${onBoardingModel.title}'),
          padding: const EdgeInsets.symmetric(
            horizontal: EsnaftaVarSpacing.xl,
            vertical: EsnaftaVarSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 32).clamp(0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  key: ValueKey(
                    'onboarding-illustration-${onBoardingModel.title}',
                  ),
                  width: illustrationSize,
                  height: illustrationSize,
                  decoration: BoxDecoration(
                    color: EsnaftaVarColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(
                      EsnaftaVarRadii.xxLarge,
                    ),
                    border: Border.all(color: EsnaftaVarColors.borderDefault),
                    boxShadow: EsnaftaVarElevation.sm,
                  ),
                  child: Center(
                    child: Container(
                      width: illustrationSize * 0.55,
                      height: illustrationSize * 0.55,
                      decoration: BoxDecoration(
                        color: onBoardingModel.iconSurfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        onBoardingModel.icon,
                        color: onBoardingModel.iconColor,
                        size: illustrationSize * 0.28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xl),
                Semantics(
                  header: true,
                  child: Text(
                    onBoardingModel.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: EsnaftaVarColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
                Text(
                  onBoardingModel.subTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: EsnaftaVarColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
