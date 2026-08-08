import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
            horizontal: CustomerHomeV1Tokens.space24,
            vertical: CustomerHomeV1Tokens.space16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
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
                    color: CustomerHomeV1Tokens.surface,
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius24,
                    ),
                    border: Border.all(color: CustomerHomeV1Tokens.border),
                    boxShadow: CustomerHomeV1Tokens.softShadow,
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
                const SizedBox(height: CustomerHomeV1Tokens.space24),
                Text(
                  onBoardingModel.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CustomerHomeV1Tokens.navy,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Text(
                  onBoardingModel.subTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CustomerHomeV1Tokens.muted,
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
