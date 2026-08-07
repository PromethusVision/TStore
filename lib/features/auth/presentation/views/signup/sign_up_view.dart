import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_up_form_section.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key, this.returnToCallerAfterCustomerLogin = false});

  final bool returnToCallerAfterCustomerLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: CustomerHomeV1Tokens.cream,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              key: const Key('customer-signup-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                key: const Key('customer-signup-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space8,
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SignUpHeader(onBack: () => Navigator.maybePop(context)),
                    const SizedBox(height: CustomerHomeV1Tokens.space24),
                    Text(
                      TTexts.signUpTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: CustomerHomeV1Tokens.navy,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    Text(
                      'Yakındaki ürünleri ve esnafı keşfetmeye başlayın.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: CustomerHomeV1Tokens.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space20),
                    CustomerAuthFormCard(
                      key: const Key('customer-signup-form-card'),
                      padding: const EdgeInsets.all(
                        CustomerHomeV1Tokens.space16,
                      ),
                      child: SignUpFormSection(
                        returnToCallerAfterCustomerLogin:
                            returnToCallerAfterCustomerLogin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-signup-header'),
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space8,
        vertical: CustomerHomeV1Tokens.space12,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('customer-signup-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            color: CustomerHomeV1Tokens.petrol,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          const Expanded(
            child: CustomerBrandWordmark(
              key: Key('signup-wordmark'),
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
