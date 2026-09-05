import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';
import 'package:t_store/features/auth/presentation/view_models/on_boarding_model.dart';
import 'package:t_store/features/auth/presentation/widgets/on_boarding_dot_navigation.dart';
import 'package:t_store/features/auth/presentation/widgets/on_boarding_next_button.dart';
import 'package:t_store/features/auth/presentation/widgets/on_boarding_page.dart';
import 'package:t_store/features/auth/presentation/widgets/on_boarding_skip_button.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnBoardingCubit, OnBoardingState>(
      builder: (context, state) {
        final onBoardingCubit = context.read<OnBoardingCubit>();
        final pageController = onBoardingCubit.pageController;
        return EsnaftaVarScaffold(
          safeAreaTop: false,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                key: const Key('customer-onboarding-content'),
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Container(
                      key: const Key('customer-onboarding-header'),
                      margin: const EdgeInsets.fromLTRB(
                        EsnaftaVarSpacing.md,
                        EsnaftaVarSpacing.xs,
                        EsnaftaVarSpacing.md,
                        0,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        EsnaftaVarSpacing.md,
                        EsnaftaVarSpacing.sm,
                        EsnaftaVarSpacing.xs,
                        EsnaftaVarSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.xLarge,
                        ),
                        border: Border.all(
                          color: EsnaftaVarColors.borderDefault,
                        ),
                        boxShadow: EsnaftaVarElevation.sm,
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: CustomerBrandWordmark(
                                key: Key('onboarding-wordmark'),
                                fontSize: 28,
                              ),
                            ),
                          ),
                          OnBoardingSkipButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        key: const Key('onboarding-page-view'),
                        controller: pageController,
                        onPageChanged: (index) {
                          context.read<OnBoardingCubit>().updatePageIndicator(
                            index,
                          );
                        },
                        physics: const BouncingScrollPhysics(),
                        children: const [
                          OnBoardingPage(
                            onBoardingModel: OnBoardingModel(
                              icon: Icons.search_rounded,
                              iconColor: EsnaftaVarColors.primary,
                              iconSurfaceColor: EsnaftaVarColors.primarySoft,
                              title: TTexts.onBoardingTitle1,
                              subTitle: TTexts.onBoardingSubTitle1,
                            ),
                          ),
                          OnBoardingPage(
                            onBoardingModel: OnBoardingModel(
                              icon: Icons.storefront_rounded,
                              iconColor: EsnaftaVarColors.accent,
                              iconSurfaceColor: EsnaftaVarColors.highlight,
                              title: TTexts.onBoardingTitle2,
                              subTitle: TTexts.onBoardingSubTitle2,
                            ),
                          ),
                          OnBoardingPage(
                            onBoardingModel: OnBoardingModel(
                              icon: Icons.qr_code_rounded,
                              iconColor: EsnaftaVarColors.success,
                              iconSurfaceColor: EsnaftaVarColors.primarySoft,
                              title: TTexts.onBoardingTitle3,
                              subTitle: TTexts.onBoardingSubTitle3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      key: const Key('customer-onboarding-footer'),
                      margin: const EdgeInsets.fromLTRB(
                        EsnaftaVarSpacing.md,
                        0,
                        EsnaftaVarSpacing.md,
                        EsnaftaVarSpacing.md,
                      ),
                      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.xLarge,
                        ),
                        border: Border.all(
                          color: EsnaftaVarColors.borderDefault,
                        ),
                        boxShadow: EsnaftaVarElevation.sm,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 310) {
                            return const Column(
                              children: [
                                OnBoardingDotNavigation(),
                                SizedBox(height: EsnaftaVarSpacing.xs),
                                SizedBox(
                                  width: double.infinity,
                                  child: OnBoardingNextButton(),
                                ),
                              ],
                            );
                          }
                          return const Row(
                            children: [
                              Expanded(child: OnBoardingDotNavigation()),
                              SizedBox(width: EsnaftaVarSpacing.sm),
                              OnBoardingNextButton(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
