import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
        return Scaffold(
          backgroundColor: CustomerHomeV1Tokens.cream,
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
                        CustomerHomeV1Tokens.space16,
                        CustomerHomeV1Tokens.space8,
                        CustomerHomeV1Tokens.space16,
                        0,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        CustomerHomeV1Tokens.space16,
                        CustomerHomeV1Tokens.space12,
                        CustomerHomeV1Tokens.space8,
                        CustomerHomeV1Tokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: CustomerHomeV1Tokens.surface,
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius20,
                        ),
                        border: Border.all(color: CustomerHomeV1Tokens.border),
                        boxShadow: CustomerHomeV1Tokens.softShadow,
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: CustomerBrandWordmark(
                              key: Key('onboarding-wordmark'),
                              fontSize: 28,
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
                              iconColor: CustomerHomeV1Tokens.petrol,
                              iconSurfaceColor: CustomerHomeV1Tokens.mint,
                              title: TTexts.onBoardingTitle1,
                              subTitle: TTexts.onBoardingSubTitle1,
                            ),
                          ),
                          OnBoardingPage(
                            onBoardingModel: OnBoardingModel(
                              icon: Icons.storefront_rounded,
                              iconColor: CustomerHomeV1Tokens.coral,
                              iconSurfaceColor: CustomerHomeV1Tokens.yellow,
                              title: TTexts.onBoardingTitle2,
                              subTitle: TTexts.onBoardingSubTitle2,
                            ),
                          ),
                          OnBoardingPage(
                            onBoardingModel: OnBoardingModel(
                              icon: Icons.qr_code_rounded,
                              iconColor: CustomerHomeV1Tokens.green,
                              iconSurfaceColor: CustomerHomeV1Tokens.mint,
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
                        CustomerHomeV1Tokens.space16,
                        0,
                        CustomerHomeV1Tokens.space16,
                        CustomerHomeV1Tokens.space16,
                      ),
                      padding: const EdgeInsets.all(
                        CustomerHomeV1Tokens.space12,
                      ),
                      decoration: BoxDecoration(
                        color: CustomerHomeV1Tokens.surface,
                        borderRadius: BorderRadius.circular(
                          CustomerHomeV1Tokens.radius20,
                        ),
                        border: Border.all(color: CustomerHomeV1Tokens.border),
                        boxShadow: CustomerHomeV1Tokens.softShadow,
                      ),
                      child: const Row(
                        children: [
                          Expanded(child: OnBoardingDotNavigation()),
                          SizedBox(width: CustomerHomeV1Tokens.space12),
                          OnBoardingNextButton(),
                        ],
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
