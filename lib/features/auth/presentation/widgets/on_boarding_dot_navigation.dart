import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SmoothPageIndicator(
        key: const Key('onboarding-dot-navigation'),
        controller: context.read<OnBoardingCubit>().pageController,
        count: 3,
        axisDirection: Axis.horizontal,
        onDotClicked: (index) {
          context.read<OnBoardingCubit>().dotNavigationClicked(index);
        },
        effect: const ExpandingDotsEffect(
          dotHeight: 8,
          dotWidth: 8,
          spacing: CustomerHomeV1Tokens.space8,
          expansionFactor: 3,
          dotColor: CustomerHomeV1Tokens.border,
          activeDotColor: CustomerHomeV1Tokens.petrol,
        ),
      ),
    );
  }
}
