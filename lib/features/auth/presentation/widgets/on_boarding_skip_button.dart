import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';

class OnBoardingSkipButton extends StatelessWidget {
  const OnBoardingSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('onboarding-skip'),
      onPressed: () => context.read<OnBoardingCubit>().skipPage(context),
      style: TextButton.styleFrom(
        foregroundColor: CustomerHomeV1Tokens.petrol,
        minimumSize: const Size(64, 44),
      ),
      child: const Text('Geç', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
