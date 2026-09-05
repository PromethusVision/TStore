import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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
      child: EsnaftaVarScaffold(
        safeAreaTop: false,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              key: const Key('customer-signup-content'),
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                key: const Key('customer-signup-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  EsnaftaVarSpacing.md,
                  EsnaftaVarSpacing.xs,
                  EsnaftaVarSpacing.md,
                  EsnaftaVarSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SignUpHeader(onBack: () => Navigator.maybePop(context)),
                    const SizedBox(height: EsnaftaVarSpacing.xl),
                    Text(
                      TTexts.signUpTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: EsnaftaVarColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xs),
                    Text(
                      'Yakındaki ürünleri ve esnafı keşfetmeye başlayın.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: EsnaftaVarColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.lg),
                    CustomerAuthFormCard(
                      key: const Key('customer-signup-form-card'),
                      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
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
        horizontal: EsnaftaVarSpacing.xs,
        vertical: EsnaftaVarSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.sm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('customer-signup-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            color: EsnaftaVarColors.primary,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
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
