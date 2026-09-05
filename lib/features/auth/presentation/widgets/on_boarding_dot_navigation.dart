import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnBoardingCubit>();
    return Row(
      key: const Key('onboarding-dot-navigation'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final selected = cubit.currentIndex == index;
        return Semantics(
          selected: selected,
          child: IconButton(
            key: ValueKey('onboarding-step-$index'),
            tooltip: '${index + 1}. tanıtım adımı, toplam 3',
            onPressed: () => cubit.dotNavigationClicked(index),
            constraints: const BoxConstraints.tightFor(
              width: EsnaftaVarTouchTargets.minimum,
              height: EsnaftaVarTouchTargets.minimum,
            ),
            padding: EdgeInsets.zero,
            icon: Container(
              width: selected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected
                    ? EsnaftaVarColors.primary
                    : EsnaftaVarColors.borderStrong,
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
              ),
            ),
          ),
        );
      }),
    );
  }
}
