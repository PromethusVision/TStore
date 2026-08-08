// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/data/services/customer_onboarding_preferences.dart';

part 'on_boarding_state.dart';

typedef OnBoardingCompletionWriter = Future<void> Function();
typedef OnBoardingDestinationBuilder = Widget Function(BuildContext context);

Widget _defaultOnBoardingDestinationBuilder(BuildContext context) {
  return const NavigationMenu();
}

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit({
    this.completionWriter = CustomerOnboardingPreferences.markCompleted,
    this.destinationBuilder = _defaultOnBoardingDestinationBuilder,
  }) : super(OnBoardingInitial());

  final OnBoardingCompletionWriter completionWriter;
  final OnBoardingDestinationBuilder destinationBuilder;
  final PageController pageController = PageController();
  int currentIndex = 0;
  bool _isCompleting = false;

  void dotNavigationClicked(int index) {
    currentIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    emit(OnBoardingUpdateIndicator(currentIndex));
  }

  Future<void> goToNextPage(BuildContext context) async {
    if (currentIndex != 2) {
      currentIndex++;

      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      emit(OnBoardingUpdateIndicator(currentIndex));
      return;
    }

    await _completeOnBoarding(context);
  }

  void updatePageIndicator(int index) {
    currentIndex = index;
    emit(OnBoardingUpdateIndicator(currentIndex));
  }

  Future<void> skipPage(BuildContext context) async {
    await _completeOnBoarding(context);
  }

  Future<void> _completeOnBoarding(BuildContext context) async {
    if (_isCompleting) return;
    _isCompleting = true;

    try {
      try {
        await completionWriter();
      } catch (_) {
        // Local storage must not prevent the customer from discovering shops.
      }

      if (!context.mounted) return;
      THelperFunctions.navigateReplacementToScreen(
        context,
        destinationBuilder(context),
      );
    } finally {
      _isCompleting = false;
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
