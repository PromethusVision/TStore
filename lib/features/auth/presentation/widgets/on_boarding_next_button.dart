import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnBoardingCubit, OnBoardingState>(
      builder: (context, state) {
        final isLastPage = context.read<OnBoardingCubit>().currentIndex == 2;

        return SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            key: const Key('onboarding-next'),
            onPressed: () async {
              await context.read<OnBoardingCubit>().goToNextPage(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EsnaftaVarColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: EsnaftaVarSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
              ),
            ),
            icon: Icon(
              isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
              size: 20,
            ),
            label: Text(isLastPage ? 'Başla' : 'Devam'),
          ),
        );
      },
    );
  }
}
